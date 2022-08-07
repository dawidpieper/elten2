# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module Bass
  ENV["path"] += ";.\\bin"
  BassLib = "bin\\bass"
  BassfxLib = "bin\\bass_fx"
  BassmixLib = "bin\\bassmix"
  BassEltLib = "bin\\basselt"
  BASS_GetVersion = Win32API.new(BassLib, "BASS_GetVersion", "", "I")
  BASS_ErrorGetCode = Win32API.new(BassLib, "BASS_ErrorGetCode", "", "I")
  BASS_Init = Win32API.new(BassLib, "BASS_Init", "IIII", "I")
  BASS_GetInfo = Win32API.new(BassLib, "BASS_GetInfo", "P", "I")
  BASS_RecordInit = Win32API.new(BassLib, "BASS_RecordInit", "I", "I")
  BASS_GetConfig = Win32API.new(BassLib, "BASS_GetConfig", "I", "I")
  BASS_SetConfig = Win32API.new(BassLib, "BASS_SetConfig", "II", "I")
  BASS_SetConfigPtr = Win32API.new(BassLib, "BASS_SetConfigPtr", "ip", "l")
  BASS_SetDevice = Win32API.new(BassLib, "BASS_SetDevice", "i", "i")
  BASS_GetDeviceInfo = Win32API.new(BassLib, "BASS_GetDeviceInfo", "ip", "i")
  BASS_RecordGetDeviceInfo = Win32API.new(BassLib, "BASS_RecordGetDeviceInfo", "ip", "i")
  BASS_PluginLoad = Win32API.new(BassLib, "BASS_PluginLoad", "p", "i")
  BASS_Free = Win32API.new(BassLib, "BASS_Free", "", "I")
  BASS_RecordFree = Win32API.new(BassLib, "BASS_RecordFree", "", "I")
  BASS_Apply3D = Win32API.new(BassLib, "BASS_Apply3D", "", "i")
  BASS_Start = Win32API.new(BassLib, "BASS_Start", "", "I")
  BASS_Stop = Win32API.new(BassLib, "BASS_Stop", "", "I")
  BASS_Pause = Win32API.new(BassLib, "BASS_Pause", "", "I")
  BASS_SetVolume = Win32API.new(BassLib, "BASS_SetVolume", "I", "I")
  BASS_GetVolume = Win32API.new(BassLib, "BASS_GetVolume", "", "I")
  BASS_RecordStart = Win32API.new(BassLib, "BASS_RecordStart", "IIIIII", "I")
  BASS_SampleLoad = Win32API.new(BassLib, "BASS_SampleLoad", "IPIIIII", "I")
  BASS_SampleCreate = Win32API.new(BassLib, "BASS_SampleCreate", "IIIII", "I")
  BASS_SampleFree = Win32API.new(BassLib, "BASS_SampleFree", "I", "I")
  BASS_SampleGetChannel = Win32API.new(BassLib, "BASS_SampleGetChannel", "II", "I")
  BASS_SampleStop = Win32API.new(BassLib, "BASS_SampleStop", "I", "I")
  BASS_StreamCreateFile = Win32API.new(BassLib, "BASS_StreamCreateFile", "IPLIIII", "I")
  BASS_StreamCreateURL = Win32API.new(BassLib, "BASS_StreamCreateURL", "PIIII", "I")
  BASS_StreamFree = Win32API.new(BassLib, "BASS_StreamFree", "I", "I")
  BASS_ChannelFlags = Win32API.new(BassLib, "BASS_ChannelFlags", "III", "I")
  BASS_ChannelPlay = Win32API.new(BassLib, "BASS_ChannelPlay", "II", "I")
  BASS_ChannelStop = Win32API.new(BassLib, "BASS_ChannelStop", "I", "I")
  BASS_ChannelPause = Win32API.new(BassLib, "BASS_ChannelPause", "I", "I")
  BASS_ChannelGetData = Win32API.new(BassLib, "BASS_ChannelGetData", "IPI", "I")
  BASS_ChannelGetLength = Win32API.new(BassLib, "BASS_ChannelGetLength", "II", "L")
  BASS_ChannelGetTags = Win32API.new(BassLib, "BASS_ChannelGetTags", "II", "I")
  BASS_ChannelGetAttribute = Win32API.new(BassLib, "BASS_ChannelGetAttribute", "IIP", "I")
  BASS_ChannelSetAttribute = Win32API.new(BassLib, "BASS_ChannelSetAttribute", "III", "I")
  BASS_ChannelSlideAttribute = Win32API.new(BassLib, "BASS_ChannelSlideAttribute", "IIII", "I")
  BASS_ChannelIsSliding = Win32API.new(BassLib, "BASS_ChannelIsSliding", "II", "I")
  BASS_ChannelIsActive = Win32API.new(BassLib, "BASS_ChannelIsActive", "I", "I")
  BASS_ChannelSeconds2Bytes = Win32API.new(BassLib, "BASS_ChannelSeconds2Bytes", "III", "I")
  BASS_ChannelBytes2Seconds = Win32API.new(BassLib, "BASS_ChannelBytes2Seconds", "IL", "I")
  BASS_ChannelGetPosition = Win32API.new(BassLib, "BASS_ChannelGetPosition", "II", "I")
  BASS_ChannelGetInfo = Win32API.new(BassLib, "BASS_ChannelGetInfo", "IP", "I")
  BASS_ChannelSetPosition = Win32API.new(BassLib, "BASS_ChannelSetPosition", "ILLL", "I")
  BASS_ChannelSet3DPosition = Win32API.new(BassLib, "BASS_ChannelSet3DPosition", "IPPP", "I")
  BASS_StreamGetFilePosition = Win32API.new(BassLib, "BASS_StreamGetFilePosition", "II", "I")
  BASS_Mixer_StreamCreate = Win32API.new(BassmixLib, "BASS_Mixer_StreamCreate", "iii", "i")
  BASS_Mixer_StreamAddChannel = Win32API.new(BassmixLib, "BASS_Mixer_StreamAddChannel", "iii", "i")
  BASSELT_ChannelGetPositionPtr = Win32API.new(BassEltLib, "BASSELT_ChannelGetPositionPtr", "IIP", "I")
  BASSELT_ChannelGetLengthPtr = Win32API.new(BassEltLib, "BASSELT_ChannelGetLengthPtr", "IIP", "I")

  Errmsg = {
    1 => "MEM", 2 => "FILEOPEN", 3 => "DRIVER", 4 => "BUFLOST", 5 => "HANDLE", 6 => "FORMAT", 7 => "POSITION", 8 => "INIT",
    9 => "START", 14 => "ALREADY", 18 => "NOCHAN", 19 => "ILLTYPE", 20 => "ILLPARAM", 21 => "NO3D", 22 => "NOEAX", 23 => "DEVICE",
    24 => "NOPLAY", 25 => "FREQ", 27 => "NOTFILE", 29 => "NOHW", 31 => "EMPTY", 32 => "NONET", 33 => "CREATE", 34 => "NOFX",
    37 => "NOTAVAIL", 38 => "DECODE", 39 => "DX", 40 => "TIMEOUT", 41 => "FILEFORM", 42 => "SPEAKER", 43 => "VERSION", 44 => "CODEC",
    45 => "ENDED", -1 => " UNKNOWN"
  }

  class Device
    attr_accessor :name, :driver, :flags

    def initialize(name = "", driver = "", flags = 0)
      @name = name
      @driver = driver
      @flags = flags
    end

    def enabled?
      (@flags & 1) != 0
    end

    def disabled?
      !enabled?
    end

    def default?
      (@flags & 2) != 0
    end

    def initialized?
      (@flags & 4) != 0
    end

    def loopback?
      (@flags & 8) != 0
    end
  end

  def self.soundcards
    BASS_SetConfig.call(36, 1)
    BASS_SetConfig.call(42, 1)
    ret = []
    index = 0
    tmp = [nil, nil, 0].pack("ppi")
    cds = {}
    while BASS_GetDeviceInfo.call(index, tmp) > 0
      a = tmp.unpack("iii")
      o = "\0" * 1024
      Win32API.new("msvcrt", "strcpy", "pi", "i").call(o, a[0])
      sc = (o[0...(o.index("\0") || -1)]).deutf8
      name = sc
      driver = ""
      if a[1] != 0
        o = "\0" * 1024
        Win32API.new("msvcrt", "strcpy", "pi", "i").call(o, a[1])
        driver = (o[0...(o.index("\0") || -1)]).deutf8
      end
      flags = a[2]
      cds[name] ||= 0
      cds[name] += 1
      name += " (#{cds[name]})" if cds[name] > 1
      ret.push(Device.new(name, driver, flags))
      index += 1
    end
    return ret
  end

  def self.microphones
    BASS_SetConfig.call(42, 1)
    microphones = []
    index = 0
    tmp = [nil, nil, 0].pack("ppi")
    cds = {}
    while BASS_RecordGetDeviceInfo.call(index, tmp) > 0
      a = tmp.unpack("iii")
      o = "\0" * 1024
      Win32API.new("msvcrt", "strcpy", "pi", "i").call(o, a[0])
      sc = (o[0...(o.index("\0") || -1)]).deutf8
      driver = ""
      if a[1] != 0
        o = "\0" * 1024
        Win32API.new("msvcrt", "strcpy", "pi", "i").call(o, a[1])
        driver = (o[0...(o.index("\0") || -1)]).deutf8
      end
      flags = a[2]
      cds[sc] ||= 0
      cds[sc] += 1
      sc += " (#{cds[sc]})" if cds[sc] > 1
      microphones.push(Device.new(sc, driver, flags))
      index += 1
    end
    return microphones
  end

  def self.setdevice(d, hWnd = nil, samplerate = 48000)
    $soundthemesounds.values.each { |g| g.close if g != nil and !g.closed } if $soundthemesounds != nil
    $soundthemesounds = {}
    hWnd ||= $wnd || 0
    @@device = d
    if @init == true
      BASS_Free.call
      BASS_Init.call(d, samplerate, 4, hWnd)
      BASS_SetDevice.call(d)
    else
      @setdeviceoninit = d
    end
  end

  @@recorddevice = -1
  @@recordinit = false
  def self.setrecorddevice(i)
    @@recorddevice = i
    BASS_RecordFree.call if @@recordinit
    @@recordinit = false
  end

  def self.reset
    self.setdevice(@@device)
  end

  def self.test
    filename = ENV["WINDIR"] + "\\Media\\tada.wav"
    h = BASS_StreamCreateFile.call(0, unicode(filename), 0, 0, 0, 0, 0x80000000 | 0x200000)
    if h == 0
      return false
    end
    begin
      bass_FX_TempoCreate ||= Win32API.new(BassfxLib, "BASS_FX_TempoCreate", "ii", "i")
      ch = bass_FX_TempoCreate.call(h, 0)
      if ch == 0
        BASS_StreamFree.call(h)
        return false
      end
    rescue Exception
      BASS_StreamFree.call(h)
      return false
    end
    BASS_StreamFree.call(h)
    return true
  end

  def self.record_prepare
    if @@recordinit == false
      BASS_RecordInit.call(@@recorddevice)
      @@recordinit = true
    end
  end

  def self.version
    v = BASS_GetVersion.call
    return [v].pack("I").unpack("CCCC").map { |s| s.to_s }.reverse.join(".")
  end

  def self.init(hWnd, samplerate = 48000)
    return if @init == true
    @init = true
    BASS_SetConfig.call(36, 1)
    BASS_SetConfig.call(42, 1)
    if (BASS_GetVersion.call >> 16) != 0x0204
      raise("bass.dllバージョン2.4系以外には対応しておりません")
    end
    devs = []
    card = -1
    card = @setdeviceoninit if @setdeviceoninit != nil
    @@device = card
    if BASS_Init.call(card, samplerate, 4, hWnd) == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
    plugins = ["bassopus", "bassflac", "bassmidi", "basswebm", "basswma", "bass_aac", "bass_ac3", "bass_spx", "basshls", "bassalac"]
    for pl in plugins
      if BASS_PluginLoad.call("bin\\#{pl}.dll") == 0
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end
    BASS_SetConfig.call(0, 1000)
    BASS_SetConfig.call(1, 100)
    BASS_SetConfig.call(11, 3000)
    BASS_SetConfig.call(12, 10000)
    BASS_SetConfig.call(15, 25)
    BASS_SetConfigPtr.call(16, "Elten")
    BASS_SetConfig.call(21, 1)
    BASS_SetConfig.call(0x20000, 0)
    BASS_SetDevice.call(card) if card > 0
  end

  def self.free
    @init = false
    if BASS_Free.call == 0
      raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
    end
  end

  def self.loadSample(filename, max = 1)
    return Sample.new(filename, max)
  end

  def self.loadStream(filename, pos = 0, u3d = false, stream = nil)
    return Stream.new(filename, pos, 10, u3d, stream)
  end

  class Sample
    @@exiters = {}
    attr_reader :ch

    def initialize(filename, max = 1)
      ObjectSpace.define_finalizer(self,
                                   self.class.method(:finalize).to_proc)
      if filename[0..3] == "http"
        return Bass::Stream.new(filename)
      else
        @handle = BASS_SampleLoad.call(0, unicode(filename), 0, 0, 0, max, 0x20000 | 0x80000000 | 0x200000 | 256)
      end
      @@exiters[self.object_id] = [@handle]
      @ch = BASS_SampleGetChannel.call(@handle, 0)
      if @handle == 0
        return Bass::Stream.new(filename)
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    end

    def newchannel
      @ch = BASS_SampleGetChannel.call(@handle, 0)
    end

    def free
      BASS_SampleFree.call(@handle)
      @@exiters[self.object_id] = nil
    end

    def self.finalize(id)
      if @@exiters[id].is_a?(Array)
        for e in @@exiters[id]
          BASS_SampleFree.call(e)
        end
        @@exiters[id] = nil
      end
    end

    def play(option = {})
      ch = @ch || BASS_SampleGetChannel.call(@handle, 1)
      if ch == 0
        return
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end

      if false
        if option[:loop]
          if BASS_ChannelFlags.call(ch, 4, 4) == -1
            raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
          end
        end
        if option[:pan]
          if BASS_ChannelSetAttribute.call(ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1
            raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
          end
        end
        if option[:volume]
          if BASS_ChannelSetAttribute.call(ch, 2, [option[:volume]].pack("f").unpack("I")[0]) == -1
            raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
          end
        end
      end
      #BASS_ChannelSetAttribute.call(ch, 2, [0.1].pack("f").unpack("I")[0])
      if BASS_ChannelPlay.call(ch, 0) == 0
        err = BASS_ErrorGetCode.call
        if err == 9
          Bass.reset
          return
        end
        raise("BASS_ERROR_#{Errmsg[err]}")
      end
      return ch
    rescue Exception
      Log.error("Cannot play audio: " + $!.to_s + " " + $@.to_s)
    end

    def setPan(ch, pan)
      if BASS_ChannelSetAttribute.call(ch, 3, [pan].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    rescue Exception
      Log.error("Cannot set pan: " + $!.to_s + " " + $@.to_s)
    end

    def setVolume(ch, v)
      if BASS_ChannelSetAttribute.call(ch, 2, [v].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    rescue Exception
      Log.error("Cannot set volume: " + $!.to_s + " " + $@.to_s)
    end

    def stop(ch = nil)
      if ch == nil
        if BASS_SampleStop.call(@handle) == 0
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      else
        if BASS_ChannelStop.call(ch) == 0
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
    rescue Exception
      Log.error("Cannot stop audio: " + $!.to_s + " " + $@.to_s)
    end
  end

  class Stream
    @@exiters = {}

    attr_reader :ch

    def initialize(filename, pos = 0, tries = 10, u3d = false, stream = nil)
      ObjectSpace.define_finalizer(self,
                                   self.class.method(:finalize).to_proc)
      pos = pos.to_i
      flags = 256
      flags |= 0x200000 if Configuration.usefx == 1
      @stream = stream
      @@exiters[self.object_id] = []
      if filename == nil && stream != nil
        @cha = BASS_StreamCreateFile.call(1, @stream, 0, 0, @stream.bytesize, 0, flags)
      elsif filename[0..3] == "http"
        @cha = BASS_StreamCreateURL.call(unicode(filename), pos, 0x80000000 | flags, 0, 0)
      else
        for i in 1..10
          @cha = BASS_StreamCreateFile.call(0, unicode(filename), pos, 0, 0, 0, flags | 0x80000000 | 0x20000)
          if @cha == 0
            Bass.init($wnd)
          else
            break
          end
        end
      end
      if @cha == 0
        return initialize(filename, pos = 0, tries - 1) if tries > 0 and !$DEBUG
        #print("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
      @@exiters[self.object_id].push(@cha)
      if Configuration.usefx == 1
        @@BASS_FX_TempoCreate ||= Win32API.new(BassfxLib, "BASS_FX_TempoCreate", "ii", "i")
        @ch = @@BASS_FX_TempoCreate.call(@cha, 0)
        @@exiters[self.object_id].push(@ch)
      else
        @ch = @cha
      end
    rescue Exception
      Log.error("Cannot play audio: " + $!.to_s + " " + $@.to_s)
    end

    def free
      return if @ch == 0
      if BASS_StreamFree.call(@ch) == 0
        print("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}") if $DEBUG
      end
      if @ch != @cha
        if BASS_StreamFree.call(@cha) == 0
          print("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}") if $DEBUG
        end
      end
    end

    def self.finalize(id)
      if @@exiters[id].is_a?(Array)
        for e in @@exiters[id]
          BASS_StreamFree.call(e)
        end
        @@exiters[id] = nil
      end
    end

    def play(option = {})
      if option[:loop]
        if BASS_ChannelFlags.call(@ch, 4, 4) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:pan]
        if BASS_ChannelSetAttribute.call(@ch, 3, [option[:pan]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:frequency]
        if BASS_ChannelSetAttribute.call(@ch, 3, [option[:frequency]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if option[:volume]
        if BASS_ChannelSetAttribute.call(@ch, 4, [option[:volume]].pack("f").unpack("I")[0]) == -1
          raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
        end
      end
      if BASS_ChannelPlay.call(@ch, 0) == 0
        return nil
      end
    rescue Exception
      Log.error("Cannot play audio: " + $!.to_s + " " + $@.to_s)
    end

    def pan=(pan)
      if BASS_ChannelSetAttribute.call(@ch, 3, [pan].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    rescue Exception
      Log.error("Cannot set pan: " + $!.to_s + " " + $@.to_s)
    end

    def volume=(v)
      if BASS_ChannelSetAttribute.call(@ch, 2, [v].pack("f").unpack("I")[0]) == -1
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    rescue Exception
      Log.error("Cannot set volume: " + $!.to_s + " " + $@.to_s)
    end

    def stop
      if BASS_ChannelStop.call(@ch) == 0
        raise("BASS_ERROR_#{Errmsg[BASS_ErrorGetCode.call]}")
      end
    rescue Exception
      Log.error("Cannot stop audio: " + $!.to_s + " " + $@.to_s)
    end
  end

  class AudioInfo
    class ID3Frame
      attr_accessor :id, :size, :encrypted, :compressed, :grouped, :group, :numvalue, :strvalue
      attr_reader :subframes

      def initialize
        @id = ""
        @size = 0
        @encrypted = false
        @compressed = false
        @grouped = false
        @group = 0
        @numvalue = 0
        @strvalue = ""
        @subframes = []
      end
    end

    class Chapter
      attr_accessor :id, :name, :time
    end

    def initialize(channel)
      @channel = channel
    end

    def tags_ogg
      return {} if @channel == nil || @channel == 0
      tags = {}
      t = BASS_ChannelGetTags.call(@channel, 2)
      if t != 0
        m = ""
        movemem = Win32API.new("kernel32", "RtlMoveMemory", "pii", "i")
        i = 0
        pt = "\0"
        m = ""
        loop do
          movemem.call(pt, t + i, 1)
          if pt[0] != 0
            m += "\0"
            m[-1] = pt[0]
          elsif m.size > 0
            r = m.index("=") || m.size
            k = m[0...r]
            v = m[(r + 1)..-1] || ""
            tags[k] = v
            m = ""
          elsif m.size == 0
            break
          end
          i += 1
        end
      end
      return tags
    end

    def tags_id3v2
      return [] if @channel == nil || @channel == 0
      tags = []
      t = BASS_ChannelGetTags.call(@channel, 1)
      if t != 0
        q = t
        movemem = Win32API.new("kernel32", "RtlMoveMemory", "pii", "i")
        header = "\0" * 10
        movemem.call(header, q, 10)
        return nil if header[3] < 3 || header[3] > 4
        unsync = (header[5] & 128) > 0
        extheader = (header[5] & 64) > 0
        size = header[9] + header[8] * 128 + header[7] * 16384 + header[6] * 2097152
        q += 10
        if extheader
          ehsize = "\0" * 4
          movemem.call(ehsize, q, 4)
          q += 4 + ehsize[3] + ehsize[2] * 256 + ehsize[1] * 65536 + ehsize[0] * 16777216
        end
        tags = id3_getframes(q, size, header[3])
      end
      return tags
    end

    @@idd = 0

    def id3_getframes(q, size, version)
      movemem = Win32API.new("kernel32", "RtlMoveMemory", "pii", "i")
      r = []
      final = q + size
      tt = "\0" * size
      movemem.call(tt, q, size)
      @@idd += 1
      while q < final
        header = "\0" * 10
        movemem.call(header, q, 10)
        q += 10
        if header[0] == 0
          q += 1
          next
        end
        f = ID3Frame.new
        f.id = header[0...4]
        f.size = header[7] + header[6] * 256 + header[5] * 65536 + header[4] * 16777216
        f.size = unsynchsafe(f.size) if version == 4
        f.compressed = (header[9] & 128) > 0
        f.encrypted = (header[9] & 64) > 0
        f.grouped = (header[9] & 32) > 0
        left = f.size
        if (f.grouped)
          t = "\0"
          movemem.call(t, q, 1)
          q += 1
          f.group = t[0]
          left -= 1
        end
        if !f.compressed && !f.encrypted
          if f.id == "CHAP"
            loop do
              t = "\0"
              movemem.call(t, q, 1)
              q += 1
              left -= 1
              break if t[0] == 0
            end
            timings = "\0" * 16
            movemem.call(timings, q, 16)
            q += 16
            left -= 16
            if timings[0] != 0xff || timings[1] != 0xff || timings[2] != 0xff || timings[3] != 0xff
              f.numvalue = timings[3] + timings[2] * 256 + timings[1] * 65536 + timings[0] * 16777216
            else
              f.numvalue = timings[7] + timings[6] * 256 + timings[5] * 65536 + timings[4] * 16777216
            end
            id3_getframes(q, left, version).each { |m| f.subframes.push(m) }
          elsif f.id[0..0] == "T" && f.id[1..1] != "X"
            t = "\0"
            movemem.call(t, q, 1)
            q += 1
            left -= 1
            encoding = :ASCII
            if t[0] == 0
              encoding = :ISO_8859_1
            elsif t[0] == 1
              u = "\0" * 2
              movemem.call(u, q, 2)
              q += 2
              left -= 2
              if u[1] == 0xff
                encoding = :UnicodeFFE
              else
                encoding = :UTF16
              end
            elsif t[0] == 2
              encoding = :UTF16
            elsif t[0] == 3
              encoding = :UTF8
            end
            content = "\0" * left
            movemem.call(content, q, left)
            case encoding
            when :UTF8
              content = content.deutf8
            when :UTF16
              content = deunicode(content)
            when :UnicodeFFE
              for i in 0...content.bytesize / 2
                s = i * 2
                c = content[s]
                content[s] = content[s + 1]
                content[s + 1] = c
              end
              content = deunicode(content)
            end
            f.strvalue = content
            q += left
            left = 0
          end
        end
        q += left
        r.push(f)
      end
      return r
    rescue Exception
      return []
    end

    def like_ogg
      t = tags_ogg
      return t if t != {}
      t = tags_id3v2
      if t != nil
        tgs = {}
        mapper = { "TIT2" => "TITLE", "TALB" => "ALBUM", "TPE1" => "ARTIST", "TRCK" => "TRACKNUMBER", "TCOM" => "COMPOSER", "TCOP" => "COPYRIGHT" }
        for d, o in mapper
          f = t.find { |f| f.id == d }
          tgs[o] = f.strvalue if f != nil
        end
        chs = t.select { |f| f.id == "CHAP" }
        i = 0
        for c in chs
          time = c.numvalue / 1000.0
          name = ""
          sf = c.subframes.find { |s| s.id == "TIT2" }
          name = sf.strvalue if sf != nil
          h = sprintf("CHAPTER%03d", i)
          t = sprintf("%02d:%02d:%02d.%03d", time / 3600, (time / 60) % 60, time % 60, time - time.to_i)
          tgs[h] = t
          tgs["#{h}NAME"] = name
          i += 1
        end
        return tgs
      end
      return {}
    end

    def title
      auto_get("TITLE", "TIT2")
    end

    def album
      auto_get("ALBUM", "TALB")
    end

    def artist
      auto_get("ARTIST", "TPE1")
    end

    def track_number
      auto_get("TRACKNUMBER", "TRCK")
    end

    def copyright
      auto_get("COPYRIGHT", "TCOP")
    end

    def chapters
      return @chapters if @chapters != nil && @chapters != []
      chapters = []
      if (t = tags_ogg) != nil
        for i in 0..999
          d = sprintf("%03d", i)
          if t["CHAPTER#{d}"] != nil && t["CHAPTER#{d}NAME"] != nil
            tm = t["CHAPTER#{d}"]
            time = tm.split(":").map { |x| x.to_f }.inject(0) { |a, b| a * 60 + b }
            name = t["CHAPTER#{d}NAME"].deutf8
            ch = Chapter.new
            ch.time = time
            ch.name = name
            ch.id = i
            chapters.push(ch)
          end
        end
      end
      if (t = tags_id3v2) != nil
        for f in t
          if f.id == "CHAP" && f.subframes.size > 0
            c = Chapter.new
            c.time = f.numvalue / 1000.0
            c.name = ""
            for g in f.subframes
              c.name = g.strvalue if (g.id == "TIT2")
            end
            chapters.push(c)
          end
        end
      end
      @chapters = chapters
      return chapters
    end

    private

    def auto_get(ogg, id3)
      if (t = tags_ogg) != nil
        return t[ogg.upcase] if t[ogg.upcase] != nil
      end
      if (t = tags_id3v2) != nil
        for r in t
          if r.id == id3
            return r.strvalue[0...r.strvalue.index("\0") || r.strvalue.size]
          end
        end
      end
      return nil
    end
  end

  class Sound
    attr_reader :file
    attr_reader :channel
    attr_reader :type
    attr_reader :cls
    include Bass
    attr_reader :file
    attr_reader :basefrequency

    def initialize(file, type = 1, looper = false, u3d = false, stream = nil)
      @looper = looper
      @file = file
      @startposition = 0
      if file != nil
        ext = File.extname(file).downcase
        type = 1 if file[0..3] == "http"
      else
        type = 1
      end
      @type = type
      case type
      when 1
        begin
          @cls = Bass.loadStream(file, 0, u3d, stream)
        rescue Exception
          Log.error("Cannot play audio file: #{file}")
        end
      else
        @cls = Bass.loadSample(file)
      end
      return nil if @cls == nil
      @channel = @cls.ch
      @basefrequency = frequency
      BASS_ChannelFlags.call(@channel, 0x200000, 0x200000) if @channel != nil
      BASS_ChannelFlags.call(channel, 4, 4) if looper == true && @channel != nil
    end

    def playing?
      playing
    end

    def playing
      return false if @channel == nil
      if status == 1
        return true
      else
        return false
      end
    end

    def channels
      return 0 if @channel == nil
      rinfo = [0, 0, 0, 0, 0, 0, 0, ""].pack("iiiiiiip")
      BASS_ChannelGetInfo.call(@channel, rinfo)
      info = rinfo.unpack("iiiiiii")
      return info[1]
    end

    def data(len = length(true))
      return nil if @channel == nil
      buf = "\0" * len
      BASS_ChannelGetData.call(@channel, len, len.size)
    end

    def status
      return 0 if @channel == nil
      @lastupdate = 0 if @lastupdate == nil
      return 1 if @lastupdate < Time.now.to_i * 1000000 + Time.now.usec + 50000
      BASS_ChannelIsActive.call(@cls)
    end

    def play
      return if @channel == nil
      #@cls.play if @cls!=nil
      BASS_ChannelPlay.call(@channel, 0) if @cls != nil
    end

    def stop
      return if @channel == nil
      @cls.stop if @cls != nil
    end

    def pause
      return if @channel == nil
      BASS_ChannelPause.call(@channel) if @cls != nil
    end

    def audioinfo
      AudioInfo.new(@channel)
    end

    def chapters
      AudioInfo.new(@channel).chapters
    end

    def free
      return if @channel == nil
      @stream = nil
      if @closed != true and @cls != nil
        @cls.free
      end
      @closed = true
    end

    def close
      free
    end

    def closed
      return true if @closed
      return false
    end

    def frequency
      return 0 if @channel == nil
      frq = [0].pack("f")
      BASS_ChannelGetAttribute.call(@channel, 1, frq)
      return frq.unpack("f")[0].to_i
    end

    def frequency=(f)
      return if @channel == nil
      frq = [f].pack("f").unpack("i")[0]
      BASS_ChannelSetAttribute.call(@channel, 1, frq)
      return frq
    end

    def pan
      return 0 if @channel == nil
      pn = [0].pack("f")
      BASS_ChannelGetAttribute.call(@channel, 3, pn)
      return pn.unpack("f")[0]
    end

    def pan=(n)
      return if @channel == nil
      pn = [n].pack("f").unpack("i")[0]
      BASS_ChannelSetAttribute.call(@channel, 3, pn)
      return pn
    end

    def tempo
      return 0 if @channel == nil
      tm = [0].pack("f")
      BASS_ChannelGetAttribute.call(@channel, 0x10000, tm)
      return tm.unpack("f")[0]
    end

    def tempo=(n)
      return if @channel == nil
      if @tempo == nil
        @tempo = n
        BASS_ChannelSetAttribute.call(@channel, 65555, 60)
        BASS_ChannelSetAttribute.call(@channel, 65554, 1)
      end
      tm = [n].pack("f").unpack("i")[0]
      BASS_ChannelSetAttribute.call(@channel, 0x10000, tm)
      return tm
    end

    def set3d(a1 = nil, a2 = nil, a3 = nil, b1 = nil, b2 = nil, b3 = nil, c1 = nil, c2 = nil, c3 = nil)
      return if @channel == nil
      a, b, c = nil, nil, nil
      if a1 != nil && a2 != nil && a3 != nil
        a = [a1, a2, a3].pack("fff")
      end
      if b1 != nil && b2 != nil && b3 != nil
        b = [b1, b2, b3].pack("fff")
      end
      if c1 != nil && c2 != nil && c3 != nil
        c = [c1, c2, c3].pack("fff")
      end
      BASS_ChannelSet3DPosition.call(@channel, a, b, c)
      BASS_Apply3D.call
    end

    def volume
      return 0 if @channel == nil
      vol = [0].pack("f")
      BASS_ChannelGetAttribute.call(@channel, 2, vol)
      return vol.unpack("f")[0]
    end

    def newchannel
      return if @channel == nil
      if @type == 0
        @channel = @cls.newchannel
        BASS_ChannelFlags.call(@channel, 4, 4) if @looper == true
      else
        @channel
      end
    end

    def volume=(v)
      return if @channel == nil
      vol = [v].pack("f").unpack("i")[0]
      BASS_ChannelSetAttribute.call(@channel, 2, vol)
      return vol
    end

    def length(bytes = false)
      return 0 if @channel == nil
      ch = channels
      ch = 1 if ch == 0
      pt = [0].pack("Q")
      BASSELT_ChannelGetLengthPtr.call(@channel, 0, pt)
      bts = pt.unpack("Q").first + @startposition * @basefrequency * 4 * ch
      return 0 if (bts.to_f.infinite?) != nil || bts.to_f.nan?
      return 0 if bts <= 0
      return bts if bytes == true
      if @type == 0
        r = [BASS_ChannelBytes2Seconds.call(@channel, bts)].pack("i").unpack("d")[0]
        return 0 if (r.to_f.infinite?) != nil || r.to_f.nan?
        return r
      end
      r = bts.to_f / (@basefrequency * 4 * ch)
      return 0 if r.to_f.nan? || (r.to_f.infinite?) != nil
      return r
    rescue Exception
      return 0
    end

    def position(bytes = false, useold = true)
      return 0 if @channel == nil
      pt = [0].pack("Q")
      BASSELT_ChannelGetPositionPtr.call(@channel, 0, pt)
      bts = pt.unpack("Q").first
      bts += @startposition if useold == true
      return bts if bytes == true
      @basefrequency = frequency if @basefrequency == 0
      ch = channels
      ch = 1 if ch == 0
      return bts.to_f / (@basefrequency * 4 * ch)
    end

    def position=(val, bytes = false)
      return if val.to_f.nan?
      val = 0 if !val.is_a?(Numeric)
      return if @channel == nil
      val = 0 if val < 0
      return 0 if @closed
      @posupdated = true
      if bytes == false
        ch = channels
        ch = 1 if ch == 0
        val = val * @basefrequency * 4 * ch
      end
      return if val.to_f.nan?
      val = 0 if val < 0
      val = val.to_i
      v1, v2 = [val].pack("Q").unpack("II")
      a = BASS_ChannelSetPosition.call(@channel, v1, v2, 0)
      return val
    end

    def wait
      return if @channel == nil
      ld = 0
      while length(true) == -1
        sleep(0.025)
        ld += 1
        break if (ld == 400 and position <= 0) or length(true) >= 0
      end
      while position(true) < length(true) - @basefrequency * 4 / 1000 * 100 or length(true) == 0 or position(true) == 0
        sleep(0.05)
      end
      pos = position
      l = length
      return
      while position <= 0.03
        sleep(0.01)
      end
      BASS_ChannelFlags.call(@channel, 4, 4) if closed == false
      loop do
        sleep(0.01)
        sleep(0.01) while @updating
        BASS_ChannelFlags.call(@channel, 4, 4) if closed == false if @closed != true
        return if @omit
        @lastupdate = 0 if @lastupdate == nil
        sleep(0.07) if @lastupdate < Time.now.to_i * 1000000 + Time.now.usec + 70000
        @posupdated = false
        if position(false, false) <= 0.07 and BASS_ChannelIsActive.call(@channel) == 1
          break
        end
      end
      return
    end
  end
end

Sound = Bass::Sound
