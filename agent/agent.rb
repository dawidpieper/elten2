# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

Encoding.default_internal = Encoding::UTF_8
$VERBOSE = nil
require "base64"
require "json/ext"
require "digest"
require "securerandom"
require "digest/sha1"
require "digest/sha2"
require "digest/md5"
require "digest/rmd160"
require "digest/bubblebabble"
require "openssl"
require "fiddle"
require "fiddle/import"
require "fiddle/types"
require "zlib"
require "socket"
require "uri"
require "win32ole"
require "http/2"
require "./dlls.rb"
require("./eltenapi.rb")
require("./opus.rb")
require("./speexdsp.rb")
require("./steamaudio.rb")
require("./voip.rb")
require("./conference.rb")
require("audio3d.rb")

class Notification
  attr_accessor :alert, :sound, :id

  def initialize(alert = nil, sound = nil, id = "nocat".rand(10 ** 16).to_s)
    @alert, @sound, @id = alert, sound, id
  end
end

$sigids = []
$audio3ds = {}

module Notifications
  class << self
    def notifications
      @notifications ||= {}
    end

    def notids
      @notids ||= []
    end

    def join(alert, sound = nil, id = "jn_" + rand(10 ** 10).to_s)
      push Notification.new(alert, sound, id)
    end

    def push(n)
      if !notids.include?(n.id)
        notifications[n.id] = n
        notids.push(n.id)
        return true
      else
        return false
      end
    end

    def queue
      arr = notifications.values.dup
      notifications.clear
      return arr
    end
  end
end

def ewrite(data)
  dt = ""
  for kp in data.keys
    v = data[kp]
    k = kp.dup.force_encoding("binary")
    next if !v.is_a?(String) && !v.is_a?(Integer) && !v.is_a?(Float) && v != true && v != false
    type = "I"
    type = "S" if v.is_a?(String)
    type = "F" if v.is_a?(Float)
    type = "B" if v == false || v == true
    v = v.to_s.dup.force_encoding("binary")
    dt += [k.bytesize, v.bytesize].pack("II") + type + k + v
  end
  z = Zlib::Deflate.deflate(dt)
  $stdout_mutex ||= Mutex.new
  $stdout_mutex.synchronize {
    STDOUT.binmode.write([z.bytesize].pack("I"))
    STDOUT.binmode.write(z)
    STDOUT.flush
  }
rescue Exception
  log(2, $!.to_s + ": " + $@.to_s)
  play "signal"
end

begin
  $setcurrentdirectory.call("..") if FileTest.exists?("../elten.ini") and !FileTest.exists?("elten.ini")
  $setcurrentdirectory.call("..\\..") if FileTest.exists?("../../elten.ini") and !FileTest.exists?("elten.ini")
  $setdlldirectory.call(".")
  $eltendata = getdirectory(26) + "\\elten"
  $eltendata = ".\\eltendata" if readini("elten.ini", "Elten", "Portable", "0").to_i.to_i != 0
  $soundthemesdata = $eltendata + "\\soundthemes"
  $bindata = $eltendata + "\\bin"
  if !FileTest.exists?($eltendata + "\\appid.dat")
    $appid = ""
    chars = ("A".."Z").to_a + ("a".."z").to_a + ("0".."9").to_a
    64.times { $appid += chars[rand(chars.length)] }
    IO.write($eltendata + "\\appid.dat", $appid)
  else
    $appid = IO.read($eltendata + "\\appid.dat")
  end
  $donotdisturb = false
  $version = readini("./elten.ini", "Elten", "Version", "").to_f
  begin
    $rsa = OpenSSL::PKey::RSA.new(IO.binread("./Data/eltenpub.pem"))
  rescue Exception
  end
  $rsa = OpenSSL::PKey::RSA.new(2048) if $rsa == nil
  use_soundtheme("Data/Audio.elsnd", true)
  if $*.include?("/autostart")
    lg = read_logindata
    if lg[0] != 3
      $messagebox.call(0, "Cannot start Elten automatically, because autologin is disabled", "Elten autostart failed", 16)
    end
    $name = lg[1]
    token = lg[2]
    tokenenc = lg[3]
    token = decrypt(token) if tokenenc == 1
    if tokenenc == 2
      $messagebox.call(0, "Cannot start Elten automatically, because the autologin token is protected with a pin code", "Elten autostart failed", 16)
      exit
    end
    erequest("login", "login=1\&name=#{$name}\&token=#{token}\&version=#{$version}+agent\&beta=#{readini("elten.ini", "Elten", "Beta", "")}\&appid=#{$appid}\&crp=#{Base64.urlsafe_encode64(cryptmessage(JSON.generate({ "name" => $name, "time" => Time.now.to_i })))}") { |ans|
      if ans.is_a?(String)
        d = ans.split("\r\n")
        if d[0].to_i == 0
          $token = d[1]
          $showtray.call(0)
        else
          exit
        end
      end
    }
    sleep(0.1) while !$token
  end
  Bass.init(0)

  #p SteamAudio.load("c:\\users\\dawid\\appdata\\roaming\\elten\\extras\\phonon.dll")
  #def ewrite(s);p s;end
  #$name='pajper'
  #c=Conference.new
  #p c.create_channel({'name'=>'abc','password'=>'pao', 'framesize'=>60, 'channels'=>1, 'spatialization'=>1})
  ##c.begin_save("c:\\users\\dawid\\desktop\\save.ogg")
  #muted=true
  #streaming=false
  #recording=false
  #loop do
  #s=STDIN.gets.delete("\r\n")
  #case s
  #when "r"
  #if recording
  #c.end_save
  #else
  #c.begin_fullsave("c:\\users\\dawid\\desktop\\test")
  #end
  #recording=!recording
  #when "."
  #c.input_volume+=10
  #p c.input_volume
  #when ","
  #c.input_volume-=10
  #p c.input_volume
  #when "m"
  #muted=!muted
  #c.setvolume($name, 100, muted)
  #when "t"
  #if !streaming
  #c.set_stream('C:\Users\dawid\Music\Celtic Woman\Ancient Land (Deluxe)\04 - Follow Me.flac')
  #else
  #c.remove_stream
  #end
  #streaming=!streaming
  #when "a"
  #c.x-=1
  #when "d"
  #c.x+=1
  #when "s"
  #c.y+=1
  #when "w"
  #c.y-=1
  #when "q"
  #break
  #end
  #end
  #c.free
  #exit

  $wn = {}
  $li = 0
  $soundcard = nil
  $microphone = nil
  $key = [false] * 256
  log(0, "Agent initialized")
  loop do
    for i in 1..255
      $key[i] = ($getasynckeystate.call(i) < 0)
    end
    if ($li % 20) == 0
      exit if $*.include?("/autostart") and $findwindow.call("RGSS PLAYER", "ELTEN") != 0
      if $hwnd != nil
        exit if !$iswindow.call($hwnd)
        if ($phwnd = $getforegroundwindow.call) != $hwnd and $getparent.call($phwnd) != $hwnd
          log(0, "Elten window minimized") if $shown == true
          $shown = false
          if $hidewindow == 1
            if $tray != true
              play("minimize")
              $showwindow.call($hwnd, 0)
              ewrite({ "func" => "tray" })
              $tray = true
            end
          end
        else
          log(0, "Elten window restored") if $shown == false
          $shown = true
          $tray = false
        end
      end
    end
    if FileTest.exists?($eltendata + "\\!show.dat")
      sleep(0.25)
      play "signal"
      begin
        File.delete($eltendata + "\\!show.dat")
        $showwindow.call($hwnd, 5)
        $setforegroundwindow.call($hwnd)
        $setactivewindow.call($hwnd)
        $setfocus.call($hwnd)
        $showwindow.call($hwnd, 3)
      rescue Exception
      end
    end
    while STDIN.ready?
      if !STDIN.eof?
        data = Marshal.load(STDIN)
        if data["func"] == "srvproc"
          data["reqtime"] = Time.now.to_f
          erequest(data["mod"], data["param"], data["post"], data["headers"], data) { |resp, d|
            if resp.is_a?(ERUploadProgress)
              ewrite({ "func" => "srvproc_uploadprogress", "id" => d["id"], "percent" => resp.percent })
            elsif resp == :error
              log(2, "Request error: #{d["func"]}")
              d["resptime"] = Time.now.to_f
              d["resp"] = "-4"
            elsif resp.is_a?(String)
              d["resp"] = (resp || "").force_encoding("UTF-8")
              d["resptime"] = Time.now.to_f
              ewrite(d)
            end
          }
        elsif data["func"] == "downloadfile"
          data["reqtime"] = Time.now.to_f
          downloadfile(data["source"], data["destination"], data) { |resp, d|
            if resp.is_a?(ERDownloadProgress)
              ewrite({ "func" => "downloadfile_downloadprogress", "id" => d["id"], "percent" => resp.percent })
            elsif resp == :error
              log(2, "DownloadFile error: #{d["func"]}")
            elsif resp.is_a?(Integer)
              d["size"] = resp
              d["resptime"] = Time.now.to_f
              ewrite(d)
            end
          }
        elsif data["func"] == "jproc"
          data["reqtime"] = Time.now.to_f
          ejrequest(data["method"], data["path"], data["params"], data) { |resp, d|
            if resp == :error
              log(2, "Request error: #{d["func"]}")
              d["resptime"] = Time.now.to_f
              d["resp"] = nil
            else
              d["resp"] = resp
              d["resptime"] = Time.now.to_f
              ewrite(d)
              play "signal"
            end
          }
        elsif data["func"] == "srvverify"
          t = SecureRandom.alphanumeric(32)
          r = { "time" => Time.now.to_f, "text" => t, "seed" => SecureRandom.alphanumeric(32) }
          enc = $rsa.public_encrypt(JSON.generate(r))
          erequest("verifier", "ac=verify", enc, {}, t) { |resp, d|
            if resp.is_a?(String)
              suc = false
              begin
                dec = $rsa.public_decrypt(resp)
                j = JSON.load(dec)
                suc = true if j["time"].to_f > Time.now.to_f - 60 && t.reverse == j["text"]
              rescue Exception
                log(1, $!.to_s + ": " + $@.to_s)
                log(1, resp)
              end
              ewrite({ "func" => "srvverify", "succeeded" => suc })
            end
          }
        elsif data["func"] == "readurl"
          uri = URI.parse(data["url"])
          s = TCPSocket.new(uri.host, uri.port)
          if uri.scheme == "https"
            ctx = OpenSSL::SSL::SSLContext.new
            ctx.alpn_protocols = [DRAFT]
            sock = OpenSSL::SSL::SSLSocket.new(s, ctx)
            sock.sync_close = true
            sock.hostname = uri.host
            sock.connect
          else
            sock = s
          end
          http = HTTP2::Client.new
          http.on(:frame) { |bytes|
            sock.print bytes
            sock.flush
          }
          sockthread = Thread.new {
            while !sock.closed? && !sock.eof?
              dt = sock.read_nonblock(1024)
              http << dt
            end
          }
          stream = http.new_stream
          head = {
            ":scheme" => uri.scheme,
            ":authority" => "#{uri.host}:#{uri.port}",
            ":path" => uri.path,
            "User-Agent" => "Elten #{$version} agent",
            "Connection" => "close"
          }
          head[":method"] = data["method"] || "GET"
          head["content-length"] = data["body"].bytesize if data["body"] != nil
          data["headers"].keys.each { |k| head[k] = data["headers"][k] } if data["headers"].is_a?(Hash)
          stream.headers(head, end_stream: (data["body"] == nil || data["body"] == ""))
          if data["body"] != nil && data["body"] != ""
            until data["body"].empty?
              ch = data["body"].slice!(0...4096)
              stream.data(ch, end_stream: (data["body"].empty?))
            end
          end
          headers = {}
          body = ""
          stream.on(:headers) { |hd| headers = hd.map { |h| h[0] + ": " + h[1] }.join("\n") }
          stream.on(:data) { |ch| body += ch }
          stream.on(:half_close) { stream.close }
          stream.on(:close) {
            http.goaway
            sock.close
            d = { "func" => "readurl" }
            d["id"] = data["id"]
            d["body"] = body
            d["headers"] = headers
            ewrite(d)
          }
        elsif data["func"] == "eltsock_create"
          d = data.dup
          $eltsocks ||= []
          $eltsocks.push(EltenSock.new)
          d["sockid"] = $eltsocks.size - 1
          ewrite(d)
        elsif data["func"] == "eltsock_write"
          d = data.dup
          $eltsocks ||= {}
          if $eltsocks[data["sockid"]] != nil
            $eltsocks[data["sockid"]].write(data["message"])
            d["status"] = 1
            ewrite(d)
          end
        elsif data["func"] == "eltsock_read"
          d = data.dup
          $eltsocks ||= {}
          if $eltsocks[data["sockid"]] != nil
            d["message"] = $eltsocks[data["sockid"]].read(data["size"])
            ewrite(d)
          end
        elsif data["func"] == "eltsock_close"
          d = data.dup
          $eltsocks ||= {}
          if $eltsocks[data["sockid"]] != nil
            $eltsocks[data["sockid"]].close
            $eltsocks[data["sockid"]] = nil
            d["status"] = 1
            ewrite(d)
          end
        elsif data["func"] == "activity_register"
          erequest("activities", "name=#{$name}\&token=#{$token}\&ac=register", JSON.generate(data["activity"]), { "Content-Type" => "application/json" }) { |resp|
            log(-1, "Activity registration: #{resp.to_s}") if resp.is_a?(String)
          }
        elsif data["func"] == "donotdisturb_on"
          $donotdisturb = true
        elsif data["func"] == "donotdisturb_off"
          $donotdisturb = false
        elsif data["func"] == "alarm_stop"
          $alarmstop = true
        elsif data["func"] == "relogin"
          if $conference != nil
            begin
              $conference.free
              $conference = nil
            rescue Exception
            end
            ewrite({ "func" => "conference_close" })
          end
          $name = data["name"]
          $token = data["token"]
          $hwnd = data["hwnd"] if data["hwnd"] != nil
        elsif data["func"] == "msg_suppress"
          $msg_suppress = true
        elsif data["func"] == "steamaudio_load"
          log(-1, "Loading SteamAudio library from: " + data["file"])
          log(2, "Failed to load SteamAudio from: " + data["file"]) if SteamAudio.load(data["file"]) == false
          Audio3D.load if SteamAudio.loaded?
        elsif data["func"] == "conference_move"
          x_plus = data["x_plus"] || 0
          y_plus = data["y_plus"] || 0
          if $conference != nil
            $conference.x += x_plus
            $conference.y += y_plus
          end
        elsif data["func"] == "conference_scrollstream"
          pos_plus = data["pos_plus"] || 0
          if $conference != nil
            $conference.stream_position += pos_plus
          end
        elsif data["func"] == "conference_togglestream"
          if $conference != nil
            $conference.toggle_stream
          end
        elsif data["func"] == "conference_whisper"
          if $conference != nil
            $conference.whisper = data["userid"]
          end
        elsif data["func"] == "conference_goto"
          if $conference != nil && data["x"].is_a?(Integer) && data["y"].is_a?(Integer)
            $conference.x = data["x"]
            $conference.y = data["y"]
          end
        elsif data["func"] == "conference_gotouser"
          if $conference != nil
            $conference.goto(data["userid"].to_i)
          end
        elsif data["func"] == "conference_open"
          begin
            $conference.free if $conference != nil
          rescue Exception
          end
          $conference = Conference.new
          $conference.volume = data["volume"] if data["volume"].is_a?(Integer)
          $conference.input_volume = data["input_volume"] if data["input_volume"].is_a?(Integer)
          $conference.stream_volume = data["stream_volume"] if data["stream_volume"].is_a?(Integer)
          $conference.pushtotalk = data["pushtotalk"] if data["pushtotalk"] != nil
          $conference.pushtotalk_keys = data["pushtotalk_keys"].split(",").map { |k| k.to_i } if data["pushtotalk_keys"].is_a?(String)
          $conference.on_channel { |ch|
            Thread.new {
              dt = { "func" => "conference_channel", "channel" => JSON.generate(ch) }
              ewrite(dt)
            }
          }
          $conference.on_status { |st|
            Thread.new {
              ewrite({ "func" => "conference_status", "status" => JSON.generate(st) })
            }
          }
          $conference.on_volumes { |vl|
            Thread.new {
              dt = { "func" => "conference_volumes", "volumes" => JSON.generate(vl) }
              ewrite(dt)
            }
          }
          $conference.on_user { |joined, username|
            Thread.new {
              if joined
                play("conference_userjoin")
              else
                play("conference_userleave")
              end
              speak(username)
              while speech_actived
                speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
                sleep 0.01
              end
            }
          }
          $conference.on_text { |username, userid, message|
            Thread.new {
              speak(username + ": " + message)
              ewrite({ "func" => "conference_text", "username" => username, "userid" => userid, "text" => message })
              play "conference_message"
              while speech_actived
                speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
                sleep 0.01
              end
            }
          }
          ewrite({ "func" => "conference_open", "volume" => $conference.volume, "input_volume" => $conference.input_volume, "stream_volume" => $conference.stream_volume, "muted" => $conference.muted, "pushtotalk" => $conference.pushtotalk, "pushtotalk_keys" => $conference.pushtotalk_keys.map { |k| k.to_s }.join(",") })
        elsif data["func"] == "conference_close"
          if $conference != nil
            begin
              $conference.free
            rescue Exception
            end
            $conference = nil
          end
          ewrite({ "func" => "conference_close" })
        elsif data["func"] == "conference_addcard"
          cardid = -1
          mics = Bass.microphones
          for i in 1...mics.size
            if mics[i] == data["card"]
              cardid = i
              break
            end
          end
          if cardid > -1
            $conference.add_card(cardid, data["listen"] == true) if $conference != nil
          end
        elsif data["func"] == "conference_pushtotalk"
          $conference.pushtotalk = data["pushtotalk"] if $conference != nil and data["pushtotalk"] != nil
          $conference.pushtotalk_keys = data["pushtotalk_keys"].split(",").map { |k| k.to_i } if $conference != nil and data["pushtotalk_keys"].is_a?(String)
        elsif data["func"] == "conference_removecard"
          $conference.remove_card if $conference != nil
        elsif data["func"] == "conference_setstream"
          $conference.set_stream(data["file"]) if $conference != nil
        elsif data["func"] == "conference_removestream"
          $conference.remove_stream if $conference != nil
        elsif data["func"] == "conference_setmuted"
          $conference.muted = data["muted"] if $conference != nil
        elsif data["func"] == "conference_setinputvolume"
          $conference.input_volume = data["volume"] if $conference != nil
        elsif data["func"] == "conference_setoutputvolume"
          $conference.volume = data["volume"] if $conference != nil
        elsif data["func"] == "conference_setstreamvolume"
          $conference.stream_volume = data["volume"] if $conference != nil
        elsif data["func"] == "conference_setvolume"
          if $conference != nil
            $conference.setvolume(data["user"], data["volume"], data["muted"])
          end
        elsif data["func"] == "conference_beginsave"
          $conference.begin_save(data["file"]) if data["file"].is_a?(String) and $conference != nil
        elsif data["func"] == "conference_beginfullsave"
          $conference.begin_fullsave(data["dir"]) if data["dir"].is_a?(String) and $conference != nil
        elsif data["func"] == "conference_endsave"
          $conference.end_save if $conference != nil
        elsif data["func"] == "conference_addobject"
          if $conference != nil
            x = 0
            y = 0
            if data["location"] == 0
              x = $conference.x
              y = $conference.y
            end
            $conference.object_add(data["resid"], data["name"], x, y)
          end
        elsif data["func"] == "conference_removeobject"
          $conference.object_remove(data["id"]) if $conference != nil
        elsif data["func"] == "conference_sendtext"
          if $conference != nil
            $conference.send_text(data["text"])
          end
        elsif data["func"] == "conference_listchannels"
          chans = []
          if $conference != nil
            for ch in $conference.list_channels
              chans.push(ch)
            end
          end
          ewrite({ "func" => "conference_listchannels", "channels" => JSON.generate(chans) })
        elsif data["func"] == "conference_createchannel"
          if $conference != nil
            id = nil
            id = $conference.create_channel(data) if $conference != nil
            ewrite({ "func" => "conference_createchannel", "channel" => id })
          end
        elsif data["func"] == "conference_leavechannel"
          if $conference != nil
            $conference.leave_channel
          end
        elsif data["func"] == "conference_joinchannel"
          if $conference != nil
            $conference.join_channel(data["channel"], data["password"]) if $conference != nil
          end
        elsif data["func"] == "audio3d_new"
          if $audio3ds[data["id"]] == nil
            a = Audio3D.new
            a.file = data["file"]
            $audio3ds[data["id"]] = a
          end
        elsif data["func"] == "audio3d_play"
          a = $audio3ds[data["id"]]
          a.play if a != nil
        elsif data["func"] == "audio3d_stop"
          a = $audio3ds[data["id"]]
          a.stop if a != nil
        elsif data["func"] == "audio3d_volume"
          a = $audio3ds[data["id"]]
          a.volume = data["volume"] if data["volume"].is_a?(Numeric) && a != nil
        elsif data["func"] == "audio3d_move"
          a = $audio3ds[data["id"]]
          if a != nil
            a.x = data["x"] if data["x"].is_a?(Numeric)
            a.y = data["y"] if data["y"].is_a?(Numeric)
            a.z = data["z"] if data["z"].is_a?(Numeric)
          end
        elsif data["func"] == "audio3d_free"
          a = $audio3ds[data["id"]]
          if a != nil
            a.free
            $audio3ds.delete(data["id"])
          end
        end
      end
    end
    $msg ||= 0
    if $li == 0
      $lasttime ||= Time.now.to_i
      $lastvoice = $voice
      $lastrate = $rate
      $lastvolume = $volume
      $lastsapipitch = $sapipitch
      $lastsoundcard = $soundcard
      $lastmicrophone = $microphone
      $lastusedenoising = $usedenoising
      $voice = readconfig("Voice", "Voice", "")
      $rate = readconfig("Voice", "Rate", "50").to_i
      if $voice != $lastvoice
        sapivoices = listsapivoices
        for i in 0...sapivoices.size
          $sapisetvoice.call(i) if sapivoices[i].voiceid == $voice
        end
      end
      $sapisetrate.call(readconfig("Voice", "Rate", "50").to_i) if $lastrate != $rate
      $sapipitch = readconfig("Voice", "Pitch", "50").to_i
      $hidewindow = readconfig("Interface", "HideWindow", "0").to_i
      $SoundThemeActivation = readconfig("Interface", "SoundThemeActivation", "1").to_i
      $refreshtime = readconfig("Advanced", "AgentRefreshTime", "1").to_i
      $volume = readconfig("Interface", "MainVolume", "70").to_i
      $soundcard = readconfig("SoundCard", "SoundCard", nil)
      $microphone = readconfig("SoundCard", "Microphone", nil)
      $microphone = nil if $mictophone == ""
      $soundcard = nil if $soundcard == ""
      if $lastsoundcard != $soundcard
        log(0, "SoundCard changed: #{$soundcard}")
        if $soundcard == nil
          Bass.set_card("default", $hwnd || 0)
          $sapisetdevice.call(-1)
          $conference.reset if $conference != nil
        else
          Bass.set_card($soundcard, $hwnd || 0)
          $conference.reset if $conference != nil
          sapidevices = listsapidevices
          for i in 0...sapidevices.size
            $sapisetdevice.call(i) if sapidevices[i] == $soundcard
          end
        end
      end
      if $microphone != $lastmicrophone
        log(0, "Microphone changed: #{$microphone}")
        mc = Bass.microphones
        for i in 0...mc.size
          if mc[i] == $microphone
            Bass.setrecorddevice(i)
            s = true
          end
        end
        Bass.setrecorddevice(-1) if s == false
        $conference.reset if $conference != nil
      end
      $soundtheme = readconfig("Interface", "SoundTheme", "")
      if $soundtheme != $lastsoundtheme
        if $soundtheme.size > 0
          use_soundtheme($soundthemesdata + "\\" + $soundtheme + ".elsnd")
        else
          use_soundtheme(nil)
        end
      end
      $lastsoundtheme = $soundtheme
      $usedenoising = readconfig("Advanced", "UseDenoising", "0").to_i
      $useechocancellation = readconfig("Advanced", "UseEchoCancellation", "0").to_i
      $conference.reset if $conference != nil && $usedenoising != $lastusedenoising
      if $name != nil and $name != ""
        pr = "name=#{$name}\&token=#{$token}\&agent=1\&gz=1\&lasttime=#{$wnlasttime || Time.now.to_i}"
        pr += "\&shown=1" if $shown == true
        begin
          erequest("wn_agent", pr, nil, nil, nil, true) { |ans|
            if ans.is_a?(String)
              begin
                rsp = JSON.load(Zlib.inflate(ans))
                $wnlasttime = rsp["time"] if rsp["time"].is_a?(Integer)
                $ag_msg ||= rsp["msg"].to_i
                if $ag_msg < (rsp["msg"].to_i || 0)
                  $ag_msg = rsp["msg"].to_i
                  ewrite({ "func" => "msg", "msgs" => $ag_msg })
                end
                if rsp["signals"].is_a?(Array)
                  for sig in rsp["signals"]
                    if !$sigids.include?(sig["id"])
                      ewrite({ "func" => "sig", "appid" => sig["appid"], "time" => sig["time"], "packet" => sig["packet"], "sender" => sig["sender"], "id" => sig["id"] })
                      $sigids.push(sig["id"])
                    end
                  end
                end
                if rsp["premiumpackages"].is_a?(Array)
                  if $premiumpackages != rsp["premiumpackages"]
                    play "signal" if $premiumpackages.is_a?(Array)
                    $premiumpackages = rsp["premiumpackages"]
                    ewrite({ "func" => "premiumpackages", "premiumpackages" => $premiumpackages.join(",") })
                  end
                end
                if rsp["call"].is_a?(Hash)
                  if rsp["call"]["id"] != @call_id
                    if $bgplayer != nil
                      $bgplayer.close
                      $bgplayer = nil
                    end
                    @ringingplaying = true
                    @call_id = rsp["call"]["id"]
                    play("ringing", true)
                    ewrite({ "func" => "call_start", "call_id" => rsp["call"]["id"], "caller" => rsp["call"]["caller"], "channel" => rsp["call"]["channel"].to_i, "password" => rsp["call"]["channel_password"] })
                  end
                else
                  if @ringingplaying == true
                    @ringingplaying = false
                    if $bgplayer != nil
                      $bgplayer.close
                      $bgplayer = nil
                    end
                    ewrite({ "func" => "call_stop" })
                    @call_id = 0
                  end
                end
                if rsp["wn"].is_a?(Array)
                  rsp["wn"].each do |n|
                    Notifications.join(n["alert"], n["sound"], n["id"])
                  end
                end
                if (rsp["wn"] || []).size == 0
                  $wn_agent ||= 2
                else
                  $wn_agent ||= 1
                end
              rescue JSON::ParserError => e
                log(2, "JSON Parse Error")
              end
            end
          }
        end
      end
      q = Notifications.queue
      if q.size > 10
        play "new"
      else
        2.times { $getasynckeystate.call(0x11) }
        if $wn_agent != 1
          q.each do |n|
            log(0, "New notification: #{n.id.to_s}, #{n.alert.to_s}")
            if $donotdisturb != true
              speak n.alert
              play n.sound if n.sound != nil
              while speech_actived
                speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
                sleep 0.01
              end
            end
          end
        else
          $wn_agent = 2
        end
      end
    end
    sleep(0.02)
    $li += 1
    $li = 0 if $li >= $refreshtime * 50
    $tm = $wnlasttime if $wnlasttime != nil
    $tm = Time.now.to_i if $synctime == 0 or $tm == nil
    tim = Time.at($tm)
    m = tim.min
    if $timelastsay != tim.hour * 60 + tim.min
      $saytimeperiod = readconfig("Clock", "SayTimePeriod", "1").to_i
      $saytimetype = readconfig("Clock", "SayTimeType", "1").to_i
      $synctime = readconfig("Advanced", "SyncTime", "1").to_i
      if (($saytimeperiod > 0 and m == 0) or ($saytimeperiod > 1 and m == 30) or ($saytimeperiod >= 2 and (m == 15 or m == 45)))
        if $donotdisturb != true
          play("clock") if $saytimetype == 1 or $saytimetype == 3
          speak(sprintf("%02d:%02d", tim.hour, tim.min)) if $saytimetype == 1 or $saytimetype == 2
        end
      end
      alarms = []
      if FileTest.exists?($eltendata + "\\alarms.dat")
        alarms = Marshal.load(IO.binread($eltendata + "\\alarms.dat"))
      end
      asc = nil
      for i in 0..alarms.size - 1
        a = alarms[i]
        if tim.hour == a[0] and tim.min == a[1]
          asc = i
        end
      end
      if asc != nil
        a = alarms[asc]
        if a[2] == 0
          alarms.delete_at(asc)
          IO.binwrite($eltendata + "\\alarms.dat", Marshal.dump(alarms))
        end
        @alarmplaying = true
        play("alarm", true)
        ewrite({ "func" => "alarm", "description" => a[3] })
      end
      $timelastsay = tim.hour * 60 + tim.min
    end
    if @alarmplaying == true and $alarmstop == true
      $alarmstop = false
      @alarmplaying = false
      if $bgplayer != nil
        $bgplayer.close
        $bgplayer = nil
      end
    end
  end
rescue Interrupt
rescue SystemExit
  #rescue Exception
  #ewrite({'func'=>'error','msg'=>$!.to_s,'loc'=>$@.to_s})
ensure
  Audio3D.free
  SteamAudio.free
  Bass.free
  $sslsock.close if $sslsock != nil and !$sslsock.closed?
end
