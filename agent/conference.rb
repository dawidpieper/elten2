# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Conference
  class ChannelPosition
    attr_accessor :x, :y, :dir
    attr_reader :mutex

    def initialize
      @x, @y = 0, 0
      @dir = 0
      @mutex = Mutex.new
    end
  end

  class WaitingUser
    attr_accessor :id, :name
  end

  class Transmitter
    attr_reader :decoder, :stream
    attr_reader :listener_x, :listener_y, :transmitter_x, :transmitter_y
    attr_reader :username
    attr_reader :losses

    def initialize(channels, framesize, preskip, starttime, spatialization, position, username, volume = nil)
      @channels = channels
      @framesize = framesize
      @lastframetime = starttime
      @preskip = preskip
      @listener_dir = 0
      @listener_x = -1
      @listener_y = -1
      @position = position
      @transmitter_x = -1
      @transmitter_y = -1
      @decoder = Opus::Decoder.new(48000, channels)
      @losses = []
      flags = 0x200000
      flags |= 256 if spatialization == 1
      ch = @channels
      ch = 2 if spatialization == 1
      @stream = Bass::BASS_StreamCreate.call(48000, ch, flags, -1, nil)
      @whisper = Bass::BASS_StreamCreate.call(48000, ch, flags, -1, nil)
      @username = username
      @hrtf = nil
      @hrtf_effect = nil
      @spatialization = spatialization
      @mutex = Mutex.new
      setvolume(volume)
      @sec = 0
      @fsec = 0
      @queue = {}
      @starttime = Time.now.to_f
      @lasttime = Time.now.to_f
      @ogg_mutex = Mutex.new
      @thread = Thread.new { thread }
    end

    def set_mixer(mixer, whispermixer)
      Bass::BASS_Mixer_StreamAddChannel.call(mixer, @stream, 0)
      Bass::BASS_Mixer_StreamAddChannel.call(whispermixer, @whisper, 0)
    end

    def setvolume(volume)
      if volume.is_a?(Array)
        vol = volume[0]
        @volume = vol
      else
        @volume = 100
      end
      update_position
    end

    def move(nx, ny)
      return if nx <= 0 || ny <= 0
      @transmitter_x = nx
      @transmitter_y = ny
      update_position
    end

    def update_position
      @listener_x = @position.x
      @listener_y = @position.y
      @listener_dir = @position.dir
      if @listener_y > 0 && @listener_x > 0 && @transmitter_x > 0 && @transmitter_y > 0
        @rx = (@transmitter_x - @listener_x) / 8.0
        @ry = (@transmitter_y - @listener_y) / 8.0
        if @position.dir != 0
          sn = Math::sin(Math::PI / 180 * -@listener_dir)
          cs = Math::cos(Math::PI / 180 * -@listener_dir)
          px = @rx * cs - @ry * sn
          py = @rx * sn + @ry * cs
          @rx = px
          @ry = py
        end
        pos = @rx
        pos = -1 if pos < -1
        pos = 1 if pos > 1
        vol = (1 - Math::sqrt((@ry.abs * 0.5) ** 2 + (@rx.abs * 0.5) ** 2)) * @volume / 100.0
        vol = 0 if vol < 0
        @mutex.synchronize {
          if @spatialization == 0
            Bass::BASS_ChannelSetAttribute.call(@stream, 3, [pos].pack("F").unpack("i")[0])
            Bass::BASS_ChannelSetAttribute.call(@whisper, 3, [pos].pack("F").unpack("i")[0])
          end
          Bass::BASS_ChannelSetAttribute.call(@stream, 2, [vol].pack("f").unpack("i")[0])
          Bass::BASS_ChannelSetAttribute.call(@whisper, 2, [vol].pack("f").unpack("i")[0])
        }
      end
    end

    def set_hrtf(hrtf)
      @mutex.synchronize {
        @hrtf = hrtf
        @hrtf_effect = nil
        @hrtf_effect = @hrtf.add_effect(@channels) if @hrtf != nil
      }
    end

    def reset
      @mutex.synchronize {
        @decoder.reset
      }
    end

    def begin_save(dir, id, savetime)
      @ogg_mutex.synchronize {
        msec = ((Time.now.to_f - savetime) * 1000).round
        file = dir + "/transmitters/#{msec}_#{id}_#{@username}.opus"
        @lastframetime = savetime
        @ogg = ([nil, 0, 0, 0, 0, 0, 0, 0, 0, 0] + [0] * 282 + [0, 0, 0, 0, 0, 0, 0]).pack("piiiiqiiii" + "C" * 282 + "iiiiiqq")
        @ogg_file = File.open(file, "wb")
        @ogg_lastpacket = nil
        $ogg_stream_init.call(@ogg, rand(2 ** 32) - 2 ** 31)
        head = "OpusHead".b
        head += [1].pack("C")
        head += [@channels].pack("C")
        head += [@preskip].pack("S")
        head += [48000].pack("I")
        head += [0].pack("S")
        head += [0].pack("C")
        @packetno = 0
        @granulepos = 0
        ogg_addpacket(head, true, false)
        tags = "OpusTags".b
        ver = Opus.get_version_string.to_s
        tags += [ver.bytesize].pack("I")
        tags += ver
        tags += [1].pack("I")
        encinfo = "ENCODER=ELTEN"
        tags += [encinfo.bytesize].pack("I")
        tags += encinfo
        ogg_addpacket(tags, false, false, false)
      }
    end

    def ogg_addpacket(data, b_o_s = false, e_o_s = false, writepages = true)
      if @ogg_lastpacket != nil
        $ogg_stream_packetin.call(@ogg, @ogg_lastpacket)
        if writepages
          og = [nil, 0, nil, 0].pack("pipi")
          while $ogg_stream_pageout.call(@ogg, og) != 0
            page = og.unpack("iiii")
            head = "\0" * page[1]
            body = "\0" * page[3]
            $rtlmovememory.call(head, page[0], head.bytesize)
            $rtlmovememory.call(body, page[2], body.bytesize)
            @ogg_file.write(head)
            @ogg_file.write(body)
          end
        end
      end
      if data != nil
        @packetno += 1
        @ogg_lastpacket = [data, data.bytesize, (b_o_s) ? (1) : (0), (e_o_s) ? (1) : (0), @granulepos, @packetno].pack("piiiqq")
      end
    end

    def end_save
      return if @ogg == nil
      @ogg_mutex.synchronize {
        ogg_addpacket("") if @ogg_lastpacket == nil
        pc = @ogg_lastpacket.unpack("piiiqq")
        pc[3] = 1
        @ogg_lastpacket = pc.pack("piiiqq")
        ogg_addpacket(nil)
        @ogg_file.close
        $ogg_stream_clear.call(@ogg)
        @ogg = @ogg_file = nil
      }
    end

    def put(frame, type = 1, x = -1, y = -1, frame_id = 0, index = -1)
      @lastindex ||= 0
      if @thread != nil && @thread.status != false
        n = index
        n += 65535 if n < 100
        if @lastindex < index || index < 100
          @queue[n] = @lastqueue = [frame, type, x, y, index, frame_id]
          @thread.wakeup
          @lastindex = index
        end
      end
    end

    def free
      end_save if @ogg != nil
      @mutex.synchronize {
        Bass::BASS_StreamFree.call(@stream)
        Bass::BASS_StreamFree.call(@whisper)
        @decoder.free
        @stream = nil
        @decoder = nil
      }
      @thread.exit if @thread != nil
    rescue Exception
      log(2, "Conference: Transmitter free error: " + $!.to_s + " " + $@.to_s)
    end

    private

    def thread
      last_frame_id = 0
      loop {
        sleep(0.001)
        while @queue.size > 0
          key = @queue.keys.sort.first
          ar = @queue[key]
          frame, type, x, y, index, frame_id = ar
          @queue.delete(key)
          fid = frame_id
          fid += 60000 if fid > 0 && fid < 100 && last_frame_id > 59000
          lostframes = 0
          if last_frame_id != 0
            if frame_id == 0
              lostframes = ((Time.now.to_f - @lastframetime - @framesize / 1000.0) / (@framesize / 1000.0)).floor
            else
              lostframes = fid - last_frame_id - 1
              @losses.push(lostframes)
              @losses.delete_at(0) while @losses.size > 6000
              lf = lostframes
              lf = 3 if lf > 3
              lf.times {
                pcm = ""
                if lostframes == 1
                  pcm = @decoder.decode(nil) if @decoder != nil
                else
                  pcm = @decoder.decode(frame, true) if @decoder != nil
                end
                out = ""
                if @spatialization == 1 || @spatialization == 2
                  out = pcm.unpack("s" * (pcm.bytesize / 2)).map { |s| s / 32768.0 }.pack("f" * (pcm.bytesize / 2))
                  suc = false
                  if @hrtf != nil && @rx != nil && @ry != nil
                    suc = true
                    if @spatialization == 1 || (@rx != 0 || @ry != 0)
                      rx = @rx
                      rz = @ry
                      ry = 0
                      ry = -0.2 if @spatialization == 2
                      rz = -0.075 if rz == 0
                      out = @hrtf.process(@hrtf_effect, out, rx, ry, rz)
                    else
                      rx = @rx
                      rz = @ry
                      ry = 0
                      rz = -0.075 if rz == 0
                      out = @hrtf.process(@hrtf_effect, out, rx, ry, rz)
                    end
                  else
                    rout = out.unpack("f" * (out.bytesize / 4))
                    fout = []
                    rout.each { |f| fout.push(f, f) }
                    out = fout.pack("f" * fout.size)
                  end
                else
                  out = pcm
                end
                stream = @stream
                stream = @whisper if type == 3
                Bass::BASS_StreamPutData.call(stream, out, out.bytesize) if stream != nil
              }
            end
          end
          last_frame_id = frame_id
          if x != nil && y != nil && x > 0 && y > 0
            if x != @transmitter_x || y != @transmitter_y || @listener_x != @position.x || @listener_y != @position.y || @listener_dir != @position.dir
              @position.mutex.synchronize {
                move(x, y)
              }
            end
          end
          @ogg_mutex.synchronize {
            if @ogg != nil
              if lostframes > 0
                e = Opus::Encoder.new(48000, @channels)
                fr = e.encode("\0" * @framesize * 48 * 2 * @channels, 48 * @framesize)
                e.free
                lostframes.times {
                  @granulepos += @framesize * 48
                  ogg_addpacket(fr)
                }
              end
              @granulepos += @framesize * 48
              ogg_addpacket(frame)
            end
          }
          @lastframetime = Time.now.to_f
          @mutex.synchronize {
            pcm = ""
            pcm = @decoder.decode(frame) if @decoder != nil
            if @sec != Time.now.to_i
              @sec = Time.now.to_i
              @fsec = 0
            end
            @fsec += 1
            out = ""
            if @spatialization == 1 || @spatialization == 2
              out = pcm.unpack("s" * (pcm.bytesize / 2)).map { |s| s / 32768.0 }.pack("f" * (pcm.bytesize / 2))
              suc = false
              if @hrtf != nil && @rx != nil && @ry != nil
                suc = true
                rx = @rx
                rz = @ry
                ry = 0
                rz = -0.075 if rz == 0
                out = @hrtf.process(@hrtf_effect, out, rx, ry, rz)
              else
                rout = out.unpack("f" * (out.bytesize / 4))
                fout = []
                rout.each { |f| fout.push(f, f) }
                out = fout.pack("f" * fout.size)
              end
            else
              out = pcm
            end
            stream = @stream
            stream = @whisper if type == 3
            ps = 0
            ps = Bass::BASS_StreamPutData.call(stream, out, out.bytesize) if @stream != nil
            ps += Bass::BASS_ChannelGetData.call(stream, nil, 0) if stream != nil
            fl = 2
            fl = 4 if @spatialization == 1 || @spatialization == 2
            ch = @channels
            ch = 2 if @spatialization == 1 || @spatialization == 2
            if ps - out.bytesize > 48000 * ch * fl * 0.25
              dt = "\0" * ps
              Bass::BASS_ChannelGetData.call(stream, dt, dt.bytesize)
            end
          }
        end
        Thread.stop
      }
    rescue Exception
      log(2, "Conference: Decoding error: " + $!.to_s + " " + $@.to_s)
    end
  end

  class ChannelObject
    attr_reader :stream
    attr_reader :listener_x, :listener_y, :transmitter_x, :transmitter_y
    attr_reader :id, :resid

    def initialize(id, resid, position, transmitter_x, transmitter_y, spatialization, framesize)
      @id, @resid, @framesize = id, resid, framesize
      @transmitter_x, @transmitter_y, @position = transmitter_x, transmitter_y, position
      @listener_x, @listener_y, @listener_dir = position.x, position.y, position.dir
      @stream = Bass::BASS_StreamCreate.call(48000, 2, 0x200000 | 256, -1, nil)
      @url = resid
      @url = "https://srvapi.elten.link/leg1/conferences/resources/" + resid[1..-1] if resid[0..0] == "$"
      @source = 0
      @source_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x1000 | 0x200000 | 256)
      @hrtf = nil
      @hrtf_effect = nil
      @spatialization = spatialization
      @mutex = Mutex.new
      update_position
      @thread = Thread.new { thread }
    end

    def set_mixer(mixer)
      Bass::BASS_Mixer_StreamAddChannel.call(mixer, @stream, 0)
    end

    def update_position
      @listener_x, @listener_y, @listener_dir = @position.x, @position.y, @position.dir
      if @listener_y > 0 && @listener_x > 0 && @transmitter_x > 0 && @transmitter_y > 0
        @rx = (@transmitter_x - @listener_x) / 8.0
        @ry = (@transmitter_y - @listener_y) / 8.0
        if @position.dir != 0
          sn = Math::sin(Math::PI / 180 * -@listener_dir)
          cs = Math::cos(Math::PI / 180 * -@listener_dir)
          px = @rx * cs - @ry * sn
          py = @rx * sn + @ry * cs
          @rx = px
          @ry = py
        end
        @rx = @ry = 0 if @transmitter_x == 0 || @transmitter_y == 0
        pos = @rx
        pos = -1 if pos < -1
        pos = 1 if pos > 1
        vol = (1 - Math::sqrt((@ry.abs * 0.5) ** 2 + (@rx.abs * 0.5) ** 2))
        vol = 0 if vol < 0
        @mutex.synchronize {
          if @spatialization == 0
            Bass::BASS_ChannelSetAttribute.call(@stream, 3, [pos].pack("F").unpack("i")[0])
          end
          Bass::BASS_ChannelSetAttribute.call(@stream, 2, [vol].pack("f").unpack("i")[0])
        }
      end
    end

    def set_hrtf(hrtf)
      @mutex.synchronize {
        @hrtf = hrtf
        @hrtf_effect = nil
        @hrtf_effect = @hrtf.add_effect(2) if @hrtf != nil
      }
    end

    def free
      @mutex.synchronize {
        Bass::BASS_StreamFree.call(@stream)
        Bass::BASS_StreamFree.call(@source) if @source != nil && @source != 0
        Bass::BASS_StreamFree.call(@source_mixer)
        @stream = @source = nil
      }
      @thread.exit if @thread != nil
    rescue Exception
      log(2, "Conference: Object free error: " + $!.to_s + " " + $@.to_s)
    end

    private

    def thread
      @source = Bass::BASS_StreamCreateURL.call(@url, 0, 0x200000 | 4 | 256, 0, 0)
      Bass::BASS_Mixer_StreamAddChannel.call(@source_mixer, @source, 0)
      queue = "".b
      fsize = 48 * @framesize * 2 * 4
      buf = "\0" * fsize
      loop {
        if (sz = Bass::BASS_ChannelGetData.call(@source_mixer, buf, fsize)) > 0
          queue += buf.byteslice(0...sz)
        end
        while queue.size > fsize
          frame = queue.byteslice(0...fsize)
          queue = queue.byteslice(fsize..-1)
          update_position if @listener_x != @position.x || @listener_y != @position.y || @listener_dir != @position.dir
          @mutex.synchronize {
            out = frame
            spt = false
            if (@spatialization == 1 || @spatialization == 2) && @transmitter_x != 0 && @transmitter_y != 0
              suc = false
              if @hrtf != nil && @rx != nil && @ry != nil
                spt = true
                suc = true
                rx = @rx
                rz = @ry
                ry = 0
                rz = -0.075 if rz == 0
                out = @hrtf.process(@hrtf_effect, out, rx, ry, rz)
              end
            end
            ps = 0
            ps = Bass::BASS_StreamPutData.call(@stream, out, out.bytesize) if @stream != nil
            ps += Bass::BASS_ChannelGetData.call(@stream, nil, 0) if @stream != nil
            t = ps / 48000.0 / 4 / 2.0
            sl = @framesize / 1000.0 - 0.02
            sl = 0.001 if sl <= 0
            sleep(sl)
            if t > 0.1
              sleep(0.02)
            end
          }
        end
      }
    rescue Exception
      log(2, "Conference: ChannelObject error: " + $!.to_s + " " + $@.to_s)
    end
  end

  class ChatMessage
    attr_accessor :userid, :username, :message, :time

    def initialize(userid = 0, username = "", message = "")
      @userid, @username, @message = userid, username, message
      @time = Time.now
    end
  end

  def initialize(nick = nil)
    @whisper = 0
    @channels = 0
    @position = ChannelPosition.new
    @width = 15
    @height = 15
    @sltime = 0.05
    @input_volume = 100
    @stream_volume = 50
    @stream_lastfile = nil
    @stream_lastposition = nil
    @card = nil
    @pushtotalk = false
    @pushtotalk_keys = []
    @chid = 0
    @waiting_channel_id = 0
    @frame_id = 0
    @chat = []
    if nick == nil
      @username = $name
      @token = $token
    else
      @username = "guest: #{nick}"
      @token = "guest"
    end
    Bass.record_prepare
    @muteme = true
    @transmitters = {}
    @objects = {}
    @volumes = { @username => [100, true] }
    @volume = 100
    @muted = false
    @stream_mutex = Mutex.new
    @saver_mutex = Mutex.new
    @lastframe_mutex = Mutex.new
    @saver_file = nil
    @saver_filename = nil
    @waiting_users = []
    @callingplaying = true
    @voip = VoIP.new
    @starttime = Time.now.to_f
    @encoder = nil
    @speexdsp = nil
    @speexdsp_echo = nil
    @speexdsp_framesize = 0
    @encoder_mutex = Mutex.new
    @record_mutex = Mutex.new
    @lastframe = ""
    @voip.on_receive { |userid, type, message, p1, p2, p3, p4, index| onreceive(userid, type, message, p1, p2, p3, p4, index) }
    @voip.on_status { |latency, sendbytes, receivedbytes, curlost, curpackets, time| onstatus(latency, sendbytes, receivedbytes, curlost, curpackets, time) }
    @framesize = 0
    @voip.on_params { |params| onparams(params) }
    @voip.on_ping { |t| onping(t) }
    @voip.connect(@username, @token)
    snd = getsound("conference_whisper")
    @whisper_sound = nil
    @whisper_sound = Bass::BASS_StreamCreateFile.call(1, snd, 0, 0, snd.bytesize, 0, 256) if snd != nil
    @device = nil
    prepare_mixers
    @recorder_thread = Thread.new { recorder_thread }
    @output_thread = Thread.new { output_thread }
    @saver_thread = Thread.new { saver_thread }
    @processor_thread = Thread.new { processor_thread }
    @channel_hooks = []
    @waitingchannel_hooks = []
    @volumes_hooks = []
    @user_hooks = []
    @waitinguser_hooks = []
    @status_hooks = []
    @text_hooks = []
    @ping_hooks = []
    @diceroll_hooks = []
    @card_hooks = []
    @change_hooks = []
  end

  def pushtotalk
    return @pushtotalk
  end

  def pushtotalk=(v)
    @pushtotalk = (v == true)
    @change_hooks.each { |h| h.call("pushtotalk", v == true) }
  end

  def pushtotalk_keys
    @pushtotalk_keys
  end

  def pushtotalk_keys=(v)
    v = [] if !v.is_a?(Array)
    @pushtotalk_keys = v
  end

  def saving?
    return @saver_file != nil
  end

  def begin_fullsave(dir)
    Dir.mkdir(dir) if !FileTest.exists?(dir)
    Dir.mkdir(dir + "/transmitters") if !FileTest.exists?(dir + "/transmitters")
    @fullsave_dir = dir
    @fullsave_time = Time.now.to_f
    @fullsave_chat = File.open(dir + "/chat.csv", "wb")
    @fullsave_chat.write("time,transmitter,username,message\n")
    @fullsave_chat.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")},0,,\"Begin of save\"\n")
    @fullsave_myrec = $vorbisrecorderinit.call(unicode(dir + "/myrec.ogg"), 48000, 2, 500000)
    for t in @transmitters.keys
      @transmitters[t].begin_save(dir, t, @fullsave_time)
    end
    begin_save(dir + "/mixed.ogg")
  rescue Exception
    log(2, "Conference: full save error " + $!.to_s + " " + $@.to_s)
  end

  def begin_save(file)
    end_save if @saver_file != nil
    log(-1, "Conference: beginning save to file #{file}")
    case File.extname(file).downcase
    when ".w64"
      fp = File.open(file, "wb")
      fp.write("\0" * 160)
      @saver_mutex.synchronize {
        @saver_file = fp
        @saver_filename = file
      }
    when ".ogg"
      fp = $vorbisrecorderinit.call(unicode(file), 48000, 2, 500000)
      @saver_mutex.synchronize {
        @saver_file = fp
        @saver_filename = file
      }
    end
  rescue Exception
  end

  def end_save
    log(-1, "Conference: ending save")
    return if @saver_file == nil
    if @fullsave_chat != nil
      @fullsave_chat.close
      @fullsave_chat = nil
    end
    if @fullsave_dir != nil
      @fullsave_dir = nil
      @fullsave_time = nil
      for t in @transmitters.values
        t.end_save
      end
    end
    case File.extname(@saver_filename).downcase
    when ".w64"
      guids = {
        "RIFF" => ["726966662E91CF11A5D628DB04C10000"].pack("H*"),
        "WAVE" => ["77617665F3ACD3118CD100C04F8EDB8A"].pack("H*"),
        "fmt " => ["666D7420F3ACD3118CD100C04F8EDB8A"].pack("H*"),
        "fact" => ["66616374F3ACD3118CD100C04F8EDB8A"].pack("H*"),
        "data" => ["64617461F3ACD3118CD100C04F8EDB8A"].pack("H*")
      }
      @saver_mutex.synchronize {
        fp = @saver_file
        ns = (fp.pos - 160) / 4 / 2
        siz = fp.pos
        fp.seek(0)
        fp.write(guids["RIFF"])
        fp.write([siz].pack("q"))
        fp.write(guids["WAVE"])
        fp.write(guids["fmt "])
        fp.write([64].pack("q"))
        fp.write([3].pack("s"))
        fp.write([2].pack("s"))
        fp.write([48000].pack("i"))
        fp.write([48000 * 4 * 2].pack("i"))
        fp.write([4 * 2].pack("s"))
        fp.write([32].pack("s"))
        fp.write([22].pack("s"))
        fp.write("\0" * 22)
        fp.write(guids["fact"])
        fp.write([32].pack("q"))
        fp.write([2 * ns].pack("q"))
        fp.write(guids["data"])
        fp.write([24 + 4 * 2 * ns].pack("q"))
        fp.close
        @saver_file = nil
        @saver_filename = nil
      }
    when ".ogg"
      $vorbisrecorderclose.call(@saver_file)
      @saver_file = nil
      @saver_filename = nil
    end
    $vorbisrecorderclose.call(@fullsave_myrec) if @fullsave_myrec != nil
    @fullsave_myrec = nil
  end

  def add_card(cardid, listen = false)
    log(-1, "Conference: mixing card #{cardid}")
    remove_card if @card != nil
    Bass::BASS_RecordInit.call(cardid)
    Bass::BASS_RecordSetDevice.call(cardid)
    @card = Bass::BASS_RecordStart.call(0, 0, 0, 0, 0)
    @card_uploader = Bass::BASS_Split_StreamCreate.call(@card, 0x200000, nil)
    @card_listener = Bass::BASS_Split_StreamCreate.call(@card, 0x200000, nil)
    Bass::BASS_Mixer_StreamAddChannel.call(@output_mixer, @card_uploader, 0)
    Bass::BASS_Mixer_StreamAddChannel.call(@myself_mixer, @card_listener, 0) if listen
    Bass.record_resetdevice
  end

  def remove_card
    log(-1, "Conference: unmixing cards")
    if @card != nil
      Bass::BASS_ChannelStop.call(@card)
      Bass::BASS_StreamFree.call(@card)
    end
    @card = @card_uploader = @card_listener = nil
  end

  def set_stream(file = nil, position = 0)
    log(-1, "Conference: setting stream from #{file}")
    position = @stream_lastposition if file == nil
    file = @stream_lastfile if file == nil
    @stream_lastfile = file
    if file != nil
      remove_stream if @stream != nil
      @stream_mutex.synchronize {
        @stream = Bass::BASS_StreamCreateFile.call(0, unicode(file), 0, 0, 0, 0, [256 | 0x80000000 | 0x200000].pack("I").unpack("i").first)
        Bass::BASS_ChannelSetAttribute.call(@stream, 13, [0.1].pack("F").unpack("i")[0])
        Bass::BASS_ChannelSetAttribute.call(@stream, 5, [1].pack("F").unpack("i")[0])
        @stream_uploader = Bass::BASS_Split_StreamCreate.call(@stream, 0x200000, nil)
        @stream_listener = Bass::BASS_Split_StreamCreate.call(@stream, 0x200000, nil)
        Bass::BASS_Mixer_StreamAddChannel.call(@output_mixer, @stream_uploader, 0)
        Bass::BASS_Mixer_StreamAddChannel.call(@stream_mixer, @stream_listener, 0)
        Bass::BASS_ChannelSetAttribute.call(@stream_uploader, 2, [(@stream_volume / 100.0)].pack("f").unpack("i")[0]) if @stream_uploader != nil
        Bass::BASS_ChannelSetAttribute.call(@stream_listener, 2, [(@stream_volume / 100.0)].pack("f").unpack("i")[0]) if @stream_listener != nil
      }
      self.stream_position = position if position != 0 && position != nil
      @change_hooks.each { |h| h.call("streaming", true) }
    end
    return @stream
  end

  def remove_stream(hook = true)
    log(-1, "Conference: removing file stream")
    @stream_mutex.synchronize {
      Bass::BASS_StreamFree.call(@stream) if @stream != nil
      @stream = @mystream = @stream_listener = @stream_uploader = nil
    }
    @change_hooks.each { |h| h.call("streaming", false) } if hook
  end

  def streaming?
    return @stream != nil
  end

  def input_volume
    vl = [0].pack("f")
    Bass::BASS_ChannelGetAttribute.call(@recordstream, 2, vl)
    vl = vl.unpack("f").first
    if vl <= 1
      vol = (vl * 100.0).round
    else
      vol = (100 + (vl - 1) * 10.0).round
    end
    return vol
  end

  def input_volume=(vol)
    vol = 0 if vol < 0
    vol = 300 if vol > 300
    vl = vol
    if vol <= 100
      vl = vol / 100.0
    else
      vl = 1 + (vol - 100) / 10.0
    end
    Bass::BASS_ChannelSetAttribute.call(@recordstream, 2, [(vl)].pack("f").unpack("i")[0])
    @input_volume = vol
    vol
  end

  def volume
    vl = [0].pack("f")
    Bass::BASS_ChannelGetAttribute.call(@listen_mixer_listener, 2, vl)
    return (vl.unpack("f").first * 100).round
  end

  def volume=(vol)
    vol = 100 if vol > 100
    vol = 0 if vol < 0
    Bass::BASS_ChannelSetAttribute.call(@listen_mixer_listener, 2, [(vol / 100.0)].pack("f").unpack("i")[0])
    @volume = vol
    vol
  end

  def stream_position
    return 0 if @stream == nil
    pos = 0
    @stream_mutex.synchronize {
      bpos = Bass::BASS_ChannelGetPosition.call(@stream, 0)
      pos = Bass::BASS_ChannelBytes2Seconds.call(@stream, bpos)
    }
    return pos
  end

  def stream_position=(pos)
    pos = 0 if pos < 0
    return 0 if @stream == nil
    @stream_mutex.synchronize {
      bpos = Bass::BASS_ChannelSeconds2Bytes.call(@stream, pos)
      Bass::BASS_ChannelSetPosition.call(@stream, bpos, 0)
    }
    return pos
  end

  def toggle_stream
    if @stream_uploader != nil
      @stream_lastposition = stream_position
      remove_stream(false)
    else
      set_stream
    end
  end

  def stream_volume
    return @stream_volume if @stream_uploader == nil
    vol = 0
    @stream_mutex.synchronize {
      if @stream_uploader != nil
        vl = [0].pack("f")
        Bass::BASS_ChannelGetAttribute.call(@stream_uploader, 2, vl)
        vol = (vl.unpack("f").first * 100).round
      end
    }
    return vol
  end

  def stream_volume=(vol)
    vol = 100 if vol > 100
    vol = 0 if vol < 0
    @stream_mutex.synchronize {
      Bass::BASS_ChannelSetAttribute.call(@stream_uploader, 2, [(vol / 100.0)].pack("f").unpack("i")[0]) if @stream_uploader != nil
      Bass::BASS_ChannelSetAttribute.call(@stream_listener, 2, [(vol / 100.0)].pack("f").unpack("i")[0]) if @stream_listener != nil
      @stream_volume = vol
    }
    vol
  end

  def muted
    @muted
  end

  def muted=(mt)
    @muted = (mt != false)
    @change_hooks.each { |h| h.call("muted", mt) }
    @muted
  end

  def reset
    @record_mutex.synchronize {
      Bass::BASS_Mixer_ChannelRemove.call(@record)
      Bass::BASS_ChannelStop.call(@record) if @record != nil
      Bass.record_prepare
      @record = Bass::BASS_RecordStart.call(0, 0, 0, 0, 0)
      Bass::BASS_ChannelSetAttribute.call(@record, 2, [(@input_volume || 100) / 100.0].pack("F").unpack("i")[0])
      Bass::BASS_Mixer_StreamAddChannel.call(@record_mixer, @record, 0)
      Bass::BASS_ChannelPlay.call(@record, 0)
      @encoder_mutex.synchronize {
        @speexdsp.noise_reduction = ($usedenoising || 0) > 0 if @speexdsp != nil
        @encoder.reset if @encoder != nil
      }
    }
    Bass::BASS_ChannelStop.call(@whisper_mixer)
    Bass::BASS_ChannelStop.call(@listen_mixer_listener)
    Bass::BASS_ChannelSetDevice.call(@whisper_mixer, Bass.cardid)
    Bass::BASS_ChannelSetDevice.call(@listen_mixer_listener, current_device)
    Bass::BASS_ChannelPlay.call(@whisper_mixer, 1)
    Bass::BASS_ChannelPlay.call(@listen_mixer_listener, 1)
    Bass::BASS_SetDevice.call(Bass.cardid)
  end

  def set_device(dev)
    dev = dev.force_encoding("UTF-8") if dev != nil
    log(0, "Conference: changing output device to #{dev}")
    @device = dev
    reset
  end

  def current_device
    return Bass.cardid if @device == nil
    id = nil
    soundcards = Bass.soundcards
    for s in soundcards
      next if !s.is_a?(String)
    end
    id = soundcards.index(@device)
    if id == nil
      log(1, "Conferences: cannot find device named #{@device.b}, found: #{soundcards.compact.map { |c| c.b }.join(", ")}")
      id = Bass.cardid
    else
      Bass::BASS_Init.call(id, 48000, 4, $hwnd || 0, nil)
      Bass::BASS_SetDevice.call(Bass.cardid)
    end
    return id
  end

  def setvolume(user, volume = 100, muted = false)
    volume = 100 if volume > 100
    volume = 10 if volume < 10
    v = [volume, muted]
    @volumes[user] = v
    for t in @transmitters.values
      t.setvolume(v) if t.username == user
    end
    if muted
      @voip.mute(user)
    else
      @voip.unmute(user)
    end
    if user == @username
      if !muted
        Bass::BASS_ChannelSetAttribute.call(@myself_mixer, 2, [0.0].pack("F").unpack("i")[0])
        @muteme = false
      else
        Bass::BASS_ChannelSetAttribute.call(@myself_mixer, 2, [1.0].pack("F").unpack("i")[0])
        @muteme = true
      end
    end
    @volumes_hooks.each { |h| h.call(@volumes) }
  end

  def kick(userid)
    @voip.kick(userid)
  end

  def accept(userid)
    @voip.accept(userid)
  end

  def ban(username)
    @voip.ban(username)
  end

  def unban(username)
    @voip.unban(username)
  end

  def admin(username)
    @voip.admin(username)
  end

  def coordinates(userid)
    u = @transmitters[userid]
    return [-1, -1] if u == nil
    return u.transmitter_x, u.transmitter_y
  end

  def on_channel(&block)
    @channel_hooks.push(block) if block != nil
  end

  def on_waitingchannel(&block)
    @waitingchannel_hooks.push(block) if block != nil
  end

  def on_user(&block)
    @user_hooks.push(block) if block != nil
  end

  def on_waitinguser(&block)
    @waitinguser_hooks.push(block) if block != nil
  end

  def on_volumes(&block)
    @volumes_hooks.push(block) if block != nil
  end

  def on_status(&block)
    @status_hooks.push(block) if block != nil
  end

  def on_text(&block)
    @text_hooks.push(block) if block != nil
  end

  def on_ping(&block)
    @ping_hooks.push(block) if block != nil
  end

  def on_diceroll(&block)
    @diceroll_hooks.push(block) if block != nil
  end

  def on_card(&block)
    @card_hooks.push(block) if block != nil
  end

  def on_change(&block)
    @change_hooks.push(block) if block != nil
  end

  def x
    return @position.x
  end

  def y
    return @position.y
  end

  def dir
    return @position.dir
  end

  def goto(id)
    @position.mutex.synchronize {
      if id != @voip.uid && @transmitters[id] != nil
        tx, ty = (@transmitters[id].transmitter_x), (@transmitters[id].transmitter_y)
        if tx > 0 && ty > 0
          @position.x = tx
          @position.y = ty
        end
      elsif id == @voip.uid
        @position.x = (@width + 1) / 2
        @position.y = (@height + 1) / 2
      end
    }
  end

  def x=(nx)
    @position.mutex.synchronize {
      nx = 1 if nx < 1
      nx = @width if nx > @width
      @position.x = nx
    }
    nx
  end

  def y=(ny)
    @position.mutex.synchronize {
      ny = 1 if ny < 1
      ny = @height if ny > @height
      @position.y = ny
    }
    ny
  end

  def dir=(d)
    @position.mutex.synchronize {
      @position.dir = d % 360
    }
    d
  end

  def free(subs = true)
    calling_stop
    @output_thread.exit if @output_thread != nil
    begin
      @recorder_thread.exit if @recorder_thread != nil
      if subs
        for t in @transmitters.values
          t.free
        end
        for o in @objects.keys
          @objects[o].free
        end
      end
    rescue Exception
      log(2, "Conference: subs error: " + $!.to_s + " " + $@.to_s)
    end
    @saver_thread.exit if @saver_thread != nil
    begin
      Bass::BASS_ChannelStop.call(@record)
      Bass::BASS_StreamFree.call(@record_mixer)
      Bass::BASS_StreamFree.call(@recordstream)
      Bass::BASS_StreamFree.call(@channel_mixer)
      Bass::BASS_StreamFree.call(@whisper_mixer)
      if subs
        @encoder_mutex.synchronize {
          @encoder.free if @encoder != nil
          @speexdsp.free if @speexdsp != nil
          @speexdsp_echo.free if @speexdsp_echo != nil
          @hrtf.free if @hrtf != nil
        }
      end
      Bass::BASS_StreamFree.call(@whisper_sound) if @whisper_sound != nil
    rescue Exception
      log(2, "Conference: Free error: " + $!.to_s + " " + $@.to_s)
    end
    begin
      Bass::BASS_StreamFree.call(@stream_mixer)
      Bass::BASS_StreamFree.call(@myself_mixer)
      Bass::BASS_StreamFree.call(@listen_mixer)
      Bass::BASS_StreamFree.call(@processor_mixer)
      Bass::BASS_StreamFree.call(@stream) if @stream != nil
      Bass::BASS_StreamFree.call(@output_stream) if @output_stream != nil
      if @card != nil
        Bass::BASS_ChannelStop.call(@card)
        Bass::BASS_StreamFree.call(@card)
      end
      Bass::BASS_StreamFree.call(@output) if @output != 0
      Bass::BASS_StreamFree.call(@output_mixer)
    rescue Exception
      log(2, "Conference: Free error: " + $!.to_s + " " + $@.to_s)
    end
    @voip.free if subs
    if subs
      end_save if @saver_file != nil
    end
  end

  def list_channels
    @voip.list_channels || []
  end

  def join_channel(ch, password = nil)
    calling_stop
    @voip.join_channel(ch, password)
  end

  def leave_channel
    calling_stop
    @voip.leave_channel
  end

  def create_channel(params)
    calling_stop
    resp = @voip.create_channel(params)
    if resp.is_a?(Hash)
      return resp["id"]
    else
      return nil
    end
  end

  def edit_channel(id, params)
    calling_stop
    resp = @voip.edit_channel(id, params)
    if resp.is_a?(Hash)
      return resp["id"]
    else
      return nil
    end
  end

  def send_text(message)
    return if message == nil || message == ""
    messages = []
    if message.bytesize < 1400
      messages = [message]
    else
      buf = message + ""
      while buf.bytesize > 1400
        lastsp = 1400
        i = 1400
        while i > 1000 && lastsp == 140
          i -= 1
          lastsp = i if buf.getbyte(i) == 32
        end
        messages.push(buf.byteslice(0..lastsp))
        buf = buf.byteslice(lastsp + 1..-1)
      end
      messages.push(buf) if buf.bytesize > 0
    end
    for m in messages
      @voip.send(2, m, 0, 0)
    end
  end

  def whisper
    @whisper
  end

  def whisper=(w)
    if w.is_a?(Integer) && w >= 0 && w < 256 ** 2
      log(-1, "Conference: whispering to #{w}")
      @whisper_key = @voip.public_key(w)
      @whisper_aes = OpenSSL::Cipher::AES128.new(:CBC)
      @whisper_aes_key = @whisper_aes.random_key
      @whisper = w
      if w > 0
        play "recording_start"
      else
        play "recording_stop"
      end
    end
    @whisper
  end

  def object_add(resid, name, x, y)
    log(-1, "Conference: adding object #{name} at #{x}, #{y}")
    @voip.object_add(resid, name, x, y)
  end

  def object_remove(id)
    log(-1, "Conference: removing object")
    @voip.object_remove(id)
  end

  def ping
    @voip.ping
  end

  def diceroll(t = 6)
    @voip.diceroll(t)
  end

  def decks
    @voip.decks
  end

  def deck_add(type)
    @voip.deck_add(type)
  end

  def deck_reset(deck)
    @voip.deck_reset(deck)
  end

  def deck_remove(deck)
    @voip.deck_remove(deck)
  end

  def cards
    @voip.cards
  end

  def card_pick(deck, cid = 0)
    @voip.card_pick(deck, cid)
  end

  def card_change(deck, cid)
    @voip.card_change(deck, cid)
  end

  def card_place(deck, cid)
    @voip.card_place(deck, cid)
  end

  def packetloss
    return 0 if @framesize == 0
    losses = 0
    all = 0
    fs = (5000 / @framesize.to_f).to_i
    for t in @transmitters.values
      if t.losses.size > fs
        all += fs
        losses = t.losses[-fs..-1].sum
      end
    end
    return 0 if all == 0
    return losses.to_f / (all.to_f + losses.to_f) * 100.0
  end

  def transmitters
    @transmitters.dup
  end

  def volumes
    @volumes.dup
  end

  def is_muted_user(username)
    return false if !@volumes[username].is_a?(Array)
    return @volumes[username][1]
  end

  def toggle_muted_user(username)
    v = @volumes[username]
    return false if v == nil
    v[1] = !v[1]
    setvolume(username, v[0], v[1])
    return v[1]
  end

  def chat
    @chat.dup
  end

  def calling_play
    @callingplaying = true
    play("calling", true)
  end

  def calling_stop
    if @callingplaying == true
      if $bgplayer != nil
        $bgplayer.close
        $bgplayer = nil
      end
      @callingplaying = false
    end
  end

  private

  def prepare_mixers
    @output_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x200000 | 0x1000)
    @whisper_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x1000 | 256)
    Bass::BASS_ChannelSetAttribute.call(@whisper_mixer, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@whisper_mixer, 5, [1].pack("F").unpack("i")[0])
    @channel_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x200000 | 0x1000 | 256)
    @channel_mixer_saver = Bass::BASS_Split_StreamCreate.call(@channel_mixer, 0x1000 | 0x200000, nil)
    @channel_mixer_listener = Bass::BASS_Split_StreamCreate.call(@channel_mixer, 0x200000, nil)
    Bass::BASS_ChannelSetAttribute.call(@channel_mixer, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@channel_mixer, 5, [1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@channel_mixer_listener, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@channel_mixer_listener, 5, [1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@channel_mixer_saver, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@channel_mixer_saver, 5, [1].pack("F").unpack("i")[0])
    @myself_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x200000 | 0x1000 | 256)
    Bass::BASS_ChannelSetAttribute.call(@myself_mixer, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@myself_mixer, 5, [1].pack("F").unpack("i")[0])
    @listen_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x200000 | 0x1000 | 256)
    @listen_mixer_listener = Bass::BASS_Split_StreamCreate.call(@listen_mixer, 0, nil)
    @listen_mixer_preprocessor = Bass::BASS_Split_StreamCreate.call(@listen_mixer, 0x1000 | 0x200000, nil)
    @processor_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x200000 | 0x1000)
    Bass::BASS_Mixer_StreamAddChannel.call(@processor_mixer, @listen_mixer_preprocessor, 0x4000)
    Bass::BASS_ChannelSetAttribute.call(@listen_mixer, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@listen_mixer, 5, [1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@listen_mixer_listener, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@listen_mixer_listener, 5, [1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelPlay.call(@listen_mixer_listener, 1)
    Bass::BASS_ChannelPlay.call(@whisper_mixer, 1)
    @saver = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x200000 | 0x1000 | 256)
    Bass::BASS_ChannelSetAttribute.call(@saver, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_ChannelSetAttribute.call(@saver, 5, [1].pack("F").unpack("i")[0])
    Bass::BASS_Mixer_StreamAddChannel.call(@listen_mixer, @channel_mixer_listener, 0)
    Bass::BASS_Mixer_StreamAddChannel.call(@listen_mixer, @myself_mixer, 0)
    Bass::BASS_Mixer_StreamAddChannel.call(@saver, @channel_mixer_saver, 0)
    @output = 0
    @output_stream = 0
    @stream_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x1000 | 0x200000 | 256)
    Bass::BASS_ChannelSetAttribute.call(@stream_mixer, 13, [0.1].pack("F").unpack("i")[0])
    Bass::BASS_Mixer_StreamAddChannel.call(@myself_mixer, @stream_mixer, 0)
    @stream = nil
    @record = Bass::BASS_RecordStart.call(0, 0, 0, 0, 0)
    @record_mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x1000 | 0x200000)
    Bass::BASS_Mixer_StreamAddChannel.call(@record_mixer, @record, 0)
    @recordstream = Bass::BASS_StreamCreate.call(48000, 2, 0x200000, -1, nil)
    Bass::BASS_Mixer_StreamAddChannel.call(@output_mixer, @recordstream, 0x4000)
    reset
  end

  def onreceive(userid, type, message, p1, p2, p3, p4, index)
    if type == 1
      pos_x = p1
      pos_y = p2
      pos_x = -1 if pos_x < 1 || pos_x > 255
      pos_y = -1 if pos_y < 1 || pos_y > 255
      frame_id = p3 * 256 + p4
      if @transmitters[userid] != nil
        @transmitters[userid].put(message, type, pos_x, pos_y, frame_id, index)
      end
    elsif type == 2
      c = ChatMessage.new(userid, @transmitters[userid].username, message)
      @chat.push(c)
      if @transmitters[userid] != nil
        @fullsave_chat.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")},#{userid},#{@transmitters[userid].username},\"#{message.gsub("\\", "\\\\").gsub("\"", "\\\"")}\"\n") if @fullsave_chat != nil
        @text_hooks.each { |h| h.call(@transmitters[userid].username, userid, message) }
      end
    elsif type == 3
      if @whisper_sound != nil
        Bass::BASS_ChannelSetAttribute.call(@whisper_sound, 2, [($volume / 100.0)].pack("f").unpack("i")[0]) if $volume != nil
        Bass::BASS_ChannelPlay.call(@whisper_sound, 0)
      end
      pos_x = @position.x
      pos_y = @position.y
      @transmitters[userid].put(message, type, pos_x, pos_y, 0, index)
    elsif type == 4
      if @whisper_sound != nil
        Bass::BASS_ChannelSetAttribute.call(@whisper_sound, 2, [($volume / 100.0)].pack("f").unpack("i")[0]) if $volume != nil
        Bass::BASS_ChannelPlay.call(@whisper_sound, 0)
      end
      pos_x = @position.x
      pos_y = @position.y
      begin
        head = @voip.key.private_decrypt(message.byteslice(0...256))
        keysize = head.getbyte(0)
        aes = nil
        case keysize
        when 128
          aes = OpenSSL::Cipher::AES128.new(:CBC)
        when 192
          aes = OpenSSL::Cipher::AES192.new(:CBC)
        end
        if aes != nil
          aes.decrypt
          aes.key = head.byteslice(1..keysize / 8)
          aes.iv = head[keysize / 8 + 1...keysize / 8 + 1 + aes.iv_len]
          msg = head.byteslice(1 + keysize / 8 + aes.iv_len..-1)
          rest = message.byteslice(256..-1)
          if rest != nil && rest.bytesize > 0
            msg += aes.update(rest) + aes.final
          end
          @transmitters[userid].put(msg, 3, pos_x, pos_y, 0, index)
        end
      rescue Exception
        log(2, "Conference: receive encrypted whisper - #{$!.to_s}")
      end
    elsif type == 101
      if @transmitters[userid] != nil
        @fullsave_chat.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")},#{userid},#{@transmitters[userid].username},\"Dice roll: #{p2}\"\n") if @fullsave_chat != nil
        @diceroll_hooks.each { |h| h.call(@transmitters[userid].username, userid, p2, p1) }
      end
    elsif type == 111
      if @transmitters[userid] != nil
        @fullsave_chat.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")},#{userid},#{@transmitters[userid].username},\"Card pick: #{p1}\"\n") if @fullsave_chat != nil
        @card_hooks.each { |h| h.call(@transmitters[userid].username, userid, "pick", p1, p2) }
      end
    elsif type == 112
      if @transmitters[userid] != nil
        @fullsave_chat.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")},#{userid},#{@transmitters[userid].username},\"Card change: #{p1}\"\n") if @fullsave_chat != nil
        @card_hooks.each { |h| h.call(@transmitters[userid].username, userid, "change", p1, p2) }
      end
    elsif type == 113
      if @transmitters[userid] != nil
        @fullsave_chat.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")},#{userid},#{@transmitters[userid].username},\"Card change: #{p1}\"\n") if @fullsave_chat != nil
        @card_hooks.each { |h| h.call(@transmitters[userid].username, userid, "place", p1, p2) }
      end
    elsif type == 114
      if @transmitters[userid] != nil
        @fullsave_chat.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")},#{userid},#{@transmitters[userid].username},\"Deck shuffle: #{p1}\"\n") if @fullsave_chat != nil
        @card_hooks.each { |h| h.call(@transmitters[userid].username, userid, "shuffle", p1, p2) }
      end
    end
  end

  def onstatus(latency, sendbytes, receivedbytes, curlost, curpackets, time)
    status = {}
    status["latency"] = latency + @framesize / 1000.0
    status["latency"] = 0 if latency == 0
    status["sendbytes"] = sendbytes
    status["receivedbytes"] = receivedbytes
    status["curlostpackets"] = curlost
    status["curpackets"] = curpackets
    pc = 0
    pc = (curlost.to_f / (curpackets + curlost).to_f) * 100.0
    status["curpacketloss"] = packetloss
    status["time"] = time
    @status_hooks.each { |h| h.call(status) }
  end

  def onping(t)
    @ping_hooks.each { |h| h.call(t) }
  end

  def onparams(params)
    @position.mutex.synchronize {
      @encoder_mutex.synchronize {
        if params["channel"].is_a?(Hash)
          if @chid != params["channel"]["id"]
            @chid = params["channel"]["id"]
            @position.x = 0
            @position.y = 0
          end
          @encoder.free if @encoder != nil
          app = :voip
          app = :audio if params["channel"]["codec_application"] == 1
          @encoder = Opus::Encoder.new(48000, params["channel"]["channels"], app)
          case params["channel"]["vbr_type"]
          when 0
            @encoder.vbr = 0
            @encoder.cvbr = 0
          when 2
            @encoder.vbr = 1
            @encoder.cvbr = 1
          else
            @encoder.vbr = 1
            @encoder.cvbr = 0
          end
          @encoder.packetloss = 10
          @encoder.prediction_disabled = true if params["channel"]["prediction_disabled"] == true
          @encoder.inband_fec = true if params["channel"]["fec"] == true
          @encoder.bitrate = params["channel"]["bitrate"] * 1000
          @sltime = params["channel"]["framesize"] / 1000.0
          @sltime = 0.01 if @sltime < 0.01
          @sltime = 0.1 if @sltime > 0.1
          @framesize = params["channel"]["framesize"]
          @width = params["channel"]["width"]
          @height = params["channel"]["height"]
          @position.x = (@width + 1) / 2 if @position.x == 0 || @position.x > @width
          @position.y = (@height + 1) / 2 if @position.y == 0 || @position.y > @height
          sfs = 20
          sfs = params["channel"]["framesize"] if params["channel"]["framesize"] < 20
          if @speexdsp_framesize != sfs
            @speexdsp.free if @speexdsp != nil
            @speexdsp_echo.free if @speexdsp_echo != nil
            @speexdsp = nil
            @speexdsp_echo = nil
          end
          if sfs >= 10
            if @speexdsp == nil
              @speexdsp = SpeexDSP::Processor.new(48000, 2, sfs)
              @speexdsp_echo = SpeexDSP::Echo.new(48000, 2, sfs)
              @speexdsp.noise_reduction = ($usedenoising || 0) > 0
              @speexdsp_framesize = sfs
            end
          else
            @speexdsp_framesize = 0
          end
          @hrtf.free if @hrtf != nil
          @hrtf = nil
          @hrtf = SteamAudio.new(48000, @framesize) if SteamAudio.loaded? if params["channel"]["spatialization"] == 1 || params["channel"]["spatialization"] == 2
          if params["channel"]["channels"] != @channels
            Bass::BASS_StreamFree.call(@output) if @output != 0
            Bass::BASS_StreamFree.call(@output_stream) if @output_stream != 0
            @output = Bass::BASS_Mixer_StreamCreate.call(48000, params["channel"]["channels"], 0x200000 | 0x1000)
            @output_stream = Bass::BASS_StreamCreate.call(48000, params["channel"]["channels"], 0x200000, -1, nil)
            Bass::BASS_Mixer_StreamAddChannel.call(@output, @output_mixer, 0)
            Bass::BASS_Mixer_StreamAddChannel.call(@saver, @output_stream, 0x4000)
            @channels = params["channel"]["channels"]
            for t in @transmitters.keys
              @transmitters[t].free
              @transmitters.delete(t)
            end
          end
          frs = @transmitters.size == 0
          upusers = []
          for u in params["channel"]["users"]
            uid = u["id"]
            upusers.push(uid)
            if @transmitters.include?(uid)
              @transmitters[uid].set_hrtf(@hrtf)
              @transmitters[uid].reset
            else
              calling_stop
              @user_hooks.each { |h| h.call(true, u["name"], uid) } if frs == false
              log(-1, "Conference: registering new transmitter #{uid}")
              @transmitters[uid] = Transmitter.new(params["channel"]["channels"], params["channel"]["framesize"], @encoder.preskip, @starttime, params["channel"]["spatialization"], @position, u["name"], @volumes[u["name"]])
              @transmitters[uid].set_hrtf(@hrtf) if params["channel"]["spatialization"] == 1 || params["channel"]["spatialization"] == 2
              @transmitters[uid].set_mixer(@channel_mixer, @whisper_mixer)
              if @fullsave_dir != nil
                @transmitters[uid].begin_save(dir, uid, @fullsave_time)
              end
            end
          end
          @channel_hooks.each { |h| h.call(params["channel"]) }
          @volumes_hooks.each { |h| h.call(@volumes) }
          for t in @transmitters.keys
            if !upusers.include?(t)
              @whisper = 0 if @whisper == t
              @user_hooks.each { |h| h.call(false, @transmitters[t].username, t) } if frs == false
              log(-1, "Conference: unregistering transmitter #{t}")
              @transmitters[t].free
              @transmitters.delete(t)
            end
          end
          upobjects = []
          for o in params["channel"]["objects"]
            oid = o["id"]
            upobjects.push(oid)
            if @objects.include?(oid)
              @objects[oid].set_hrtf(@hrtf)
              @objects[oid].set_mixer(@channel_mixer)
            else
              log(-1, "Conference: registering new object #{o["name"]}")
              @objects[oid] = ChannelObject.new(oid, o["resid"], @position, o["x"], o["y"], params["channel"]["spatialization"], params["channel"]["framesize"])
              @objects[oid].set_hrtf(@hrtf) if params["channel"]["spatialization"] == 1 || params["channel"]["spatialization"] == 2
              @objects[oid].set_mixer(@channel_mixer)
            end
          end
          for o in @objects.keys
            if !upobjects.include?(o)
              log(-1, "Conference: unregistering object #{o}")
              @objects[o].free
              @objects.delete(o)
            end
          end
          if params["channel"]["waiting_users"].is_a?(Array)
            upwaiting = []
            for w in params["channel"]["waiting_users"]
              upwaiting.push(w["id"])
              if !@waiting_users.map { |u| u.id }.include?(w["id"])
                wu = WaitingUser.new
                wu.id = w["id"]
                wu.name = w["name"]
                @waiting_users.push(wu)
                @waitinguser_hooks.each { |h| h.call(true, w["name"], w["id"]) }
              end
            end
            todel = []
            for w in @waiting_users
              if !upwaiting.include?(w.id)
                todel.push(w)
                @waitinguser_hooks.each { |h| h.call(false, w.name, w.id) }
              end
            end
            todel.each { |w|
              @waiting_users.delete(w) if w != nil
            }
          end
        end
        if params["waiting_channel"].is_a?(Integer)
          if @waiting_channel_id != params["waiting_channel"]
            @waiting_channel_id = params["waiting_channel"]
            @waitingchannel_hooks.each { |h| h.call(params["waiting_channel"]) }
          end
        end
      }
    }
  end

  def is_muted
    return true if @muted
    return true if $disableconferencemiconrecord == 1 && $recording == true
    return false if @whisper != 0
    if @pushtotalk == true
      return true if @pushtotalk_keys.size == 0
      suc = true
      $neededkeys = @pushtotalk_keys
      for k in @pushtotalk_keys
        if $key[k] == false
          suc = false
          break
        end
      end
      return !suc
    end
    return false
  end

  def recorder_thread
    bufsize = 384000
    buf = "\0" * bufsize
    queued = "".b
    vorqueued = "".b
    loop {
      sleep(@sltime)
      sf = @framesize
      sf = 2.5 if sf == 0 || sf == nil
      sf = @speexdsp_framesize if @speexdsp_framesize != nil and @speexdsp_framesize > 0
      sf *= 48 * 2 * 2
      sz = 0
      @record_mutex.synchronize {
        if (sz = Bass::BASS_ChannelGetData.call(@record_mixer, buf, bufsize)) > 0
          queued << buf.byteslice(0...sz)
        end
      }
      f = queued.bytesize / sf * sf
      io = StringIO.new(queued.byteslice(0...f)).binmode
      queued = queued.byteslice(f..-1)
      until io.eof?
        frame = io.read(sf)
        @last_muted ||= false
        im = is_muted
        if im != @last_muted
          @last_muted = im
          if @pushtotalk == true
            if !im
              play("conference_pushin")
            else
              play("conference_pushout")
            end
          end
        end
        if !im
          if $useechocancellation != nil && $useechocancellation > 0
            @lastframe_mutex.synchronize {
              if @lastframe != "" && @speexdsp_echo != nil && @lastframe.bytesize >= sf
                frame = @speexdsp_echo.cancellation(frame, @lastframe.byteslice(0...sf)) if $useechocancellation != nil && $useechocancellation > 0
              end
            }
          end
          frame = @speexdsp.process(frame) if @speexdsp != nil && ($usedenoising || 0) > 0
          vorqueued += frame
          Bass::BASS_StreamPutData.call(@recordstream, frame, frame.bytesize)
        else
          frame = ("\0" * frame.bytesize).b
          vorqueued << frame.b
          Bass::BASS_StreamPutData.call(@recordstream, frame, frame.bytesize)
        end
      end
      if @fullsave_myrec != nil
        if vorqueued.bytesize >= 48000 * 2 * 2
          fr = vorqueued.unpack("s" * (vorqueued.bytesize / 2)).map { |s| s / 32768.0 }.pack("f" * (vorqueued.bytesize / 2))
          $vorbisrecordproc.call(0, fr, fr.bytesize, @fullsave_myrec)
          vorqueued = "".b
        end
      else
        vorqueued = "".b
      end
      reset if sz > 96000
    }
  end

  def output_thread
    bufsize = 384000
    buf = "\0" * bufsize
    audio = ""
    loop {
      sleep(@sltime)
      if @output != nil && (sz = Bass::BASS_ChannelGetData.call(@output, buf, bufsize)) > 0
        @encoder_mutex.synchronize {
          if @framesize > 0 and @channels != nil
            fs = @framesize * 48 * 2 * @channels
            au = (audio || "").b + buf.byteslice(0...sz).b
            audio.clear
            index = 0
            while au.bytesize - index >= fs
              part = au.byteslice(index...index + fs)
              frame = nil
              if @output_stream != nil && @output_stream != 0
                if @muteme && @whisper == 0
                  Bass::BASS_StreamPutData.call(@output_stream, part, part.bytesize)
                else
                  Bass::BASS_StreamPutData.call(@output_stream, "\0" * part.bytesize, part.bytesize)
                end
              end
              if part.bytesize != part.b.count("\0")
                if @encoder != nil
                  frame = @encoder.encode(part, fs / 2 / @channels)
                end
                if frame != nil
                  if @whisper == 0
                    @frame_id = 0 if @frame_id > 60000
                    @frame_id += 1
                    @voip.send(1, frame, @position.x, @position.y, @frame_id / 256, @frame_id % 256)
                  else
                    if @whisper_key == nil || @framesize == nil || @framesize < 10
                      @voip.send(3, frame, @whisper % 256, @whisper / 256)
                    else
                      begin
                        @whisper_aes.encrypt
                        iv = @whisper_aes.random_iv
                        @whisper_aes.key = @whisper_aes_key
                        mat = [128].pack("C") + @whisper_aes_key + iv
                        sz = mat.bytesize
                        mat += frame.byteslice(0...245 - sz)
                        msg = @whisper_key.public_encrypt(mat)
                        rest = frame.byteslice(245 - sz..-1)
                        if rest != nil && rest.bytesize > 0
                          msg += @whisper_aes.update(rest) + @whisper_aes.final
                        end
                        @voip.send(4, msg, @whisper % 256, @whisper / 256)
                      rescue Exception
                        log(2, "Conference: whisper error: #{$!.to_s} - #{$@.to_s}")
                      end
                    end
                  end
                end
              end
              index += fs
            end
            audio = au.byteslice(index..-1)
          else
            audio.clear
          end
        }
      end
    }
  end

  def saver_thread
    begin
      bufsize = 2097152
      buf = "\0" * bufsize
      loop {
        sleep(1.2)
        @saver_mutex.synchronize {
          if @saver != nil && (sz = Bass::BASS_ChannelGetData.call(@saver, buf, bufsize)) > 0
            if @saver_file != nil
              if buf[0...sz].b.count("\0") != sz
                case File.extname(@saver_filename).downcase
                when ".w64"
                  @saver_file.write(buf.byteslice(0...sz))
                when ".ogg"
                  $vorbisrecordproc.call(0, buf.byteslice(0...sz), sz, @saver_file)
                end
              end
            end
          end
        }
      }
    rescue Exception
      log(2, "Conference saver: " + $!.to_s + " " + $@.to_s)
    end
  end

  def processor_thread
    bufsize = 2097152
    buf = "\0" * bufsize
    audio = ""
    audiobuf = "".b
    loop {
      sleep(0.01)
      sf = 2.5
      sf = @speexdsp_framesize if @speexdsp_framesize != nil and @speexdsp_framesize > 0
      sf *= 48 * 2 * 2
      if $useechocancellation != nil && $useechocancellation > 0
        if (sz = Bass::BASS_ChannelGetData.call(@processor_mixer, buf, bufsize)) > 0
          audiobuf << buf.byteslice(0..sz)
          audiobuf = audiobuf.byteslice(-sf..-1) if audiobuf.bytesize > sf
          @lastframe_mutex.synchronize {
            @lastframe = audiobuf
          }
        end
      end
    }
  end
end
