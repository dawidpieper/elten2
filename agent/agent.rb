# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
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
require "zlib"
require "socket"
require "uri"
require "win32ole"
require "http/2"
require "./dlls.rb"
require("./eltenapi.rb")
require("./opus.rb")

class Notification
  attr_accessor :alert, :sound, :id

  def initialize(alert = nil, sound = nil, id = "nocat".rand(10 ** 16).to_s)
    @alert, @sound, @id = alert, sound, id
  end
end

$sigids = []

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
  STDOUT.binmode.write([z.bytesize].pack("I"))
  STDOUT.binmode.write(z)
  STDOUT.flush
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
  if $*.include?("/autostart")
    $name = readconfig("Login", "Name", "")
    token = readconfig("Login", "Token", "")
    tokenenc = readconfig("Login", "TokenEncrypted", "-1").to_i
    token = decrypt(Base64.strict_decode64(token)) if tokenenc == 1
    if tokenenc == 2
      $messagebox.call(0, "Cannot start Elten automatically, because the autologin token is protected with a pin code", "Elten autostart failed", 16)
      exit
    end
    erequest("login", "login=1\&name=#{$name}\&token=#{token}\&version=#{$version}+agent\&beta=#{readini("elten.ini", "Elten", "Beta", "")}\&appid=#{$appid}\&crp=#{Base64.urlsafe_encode64(cryptmessage(JSON.generate({ "name" => $name, "time" => Time.now.to_i })))}") { |ans|
      if ans != nil
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
  $upd = {}
  $upd["version"] = readini("./elten.ini", "Elten", "Version", "0").to_f
  $upd["alpha"] = readini("./elten.ini", "Elten", "Alpha", "0").to_i
  $upd["beta"] = readini("./elten.ini", "Elten", "Beta", "0").to_i
  $upd["isbeta"] = readini("./elten.ini", "Elten", "IsBeta", "0").to_i
  $wn = {}
  $li = 0
  $soundcard = nil
  log(0, "Agent initialized")
  loop do
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
    while STDIN.ready? and ($istream == nil || $istream.eof?)
      data = Marshal.load(STDIN)
      if data["func"] == "srvproc"
        data["reqtime"] = Time.now.to_f
        erequest(data["mod"], data["param"], data["post"], data["headers"], data) { |resp, d|
          if resp == :error
            log(2, "Request error: #{d["func"]}")
            d["resptime"] = Time.now.to_f
            d["resp"] = "-4"
          else
            d["resp"] = (resp || "").force_encoding("UTF-8")
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
          if resp != nil
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
        #Thread.new {
        d = data.dup
        $eltsocks ||= {}
        if $eltsocks[data["sockid"]] != nil
          $eltsocks[data["sockid"]].write(data["message"])
          d["status"] = 1
          ewrite(d)
        end
        #}
      elsif data["func"] == "eltsock_read"
        #Thread.new {
        d = data.dup
        $eltsocks ||= {}
        if $eltsocks[data["sockid"]] != nil
          d["message"] = $eltsocks[data["sockid"]].read(data["size"])
          ewrite(d)
        end
        #}
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
          log(-1, "Activity registration: #{resp.to_s}")
        }
      elsif data["func"] == "donotdisturb_on"
        $donotdisturb = true
      elsif data["func"] == "donotdisturb_off"
        $donotdisturb = false
      elsif data["func"] == "alarm_stop"
        $alarmstop = true
      elsif data["func"] == "chat_open"
        $chat = true
      elsif data["func"] == "chat_close"
        $chat = false
      elsif data["func"] == "relogin"
        $name = data["name"]
        $token = data["token"]
        $hwnd = data["hwnd"] if data["hwnd"] != nil
      elsif data["func"] == "msg_suppress"
        $msg_suppress = true
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
      $soundcard = nil if $soundcard == ""
      if $lastsoundcard != $soundcard
        log(0, "SoundCard changed: #{$soundcard}")
        if $soundcard == nil
          Bass.set_card("default", $hwnd || 0)
          $sapisetdevice.call(-1)
        else
          Bass.set_card($soundcard, $hwnd || 0)
          sapidevices = listsapidevices
          for i in 0...sapidevices.size
            $sapisetdevice.call(i) if sapidevices[i] == $soundcard
          end
        end
      end
      $soundthemespath = readconfig("Interface", "SoundTheme", "")
      if $soundthemespath.size > 0
        $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
      else
        $soundthemepath = "Audio"
      end
      if $name != nil and $name != ""
        pr = "name=#{$name}\&token=#{$token}\&agent=1\&gz=1\&lasttime=#{$wnlasttime || Time.now.to_i}"
        pr += "\&shown=1" if $shown == true
        pr += "\&chat=1" if $chat == true
        pr += "\&upd=1" if ($updlasttime || 0) < Time.now.to_i - 60
        begin
          erequest("wn_agent", pr, nil, nil, nil, true) { |ans|
            if ans != nil
              begin
                rsp = JSON.load(Zlib.inflate(ans))
                $wnlasttime = rsp["time"] if rsp["time"].is_a?(Integer)
                $updlasttime = rsp["time"] if rsp["time"].is_a?(Integer) and rsp["upd"] != nil
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
                begin
                  if rsp["upd"].is_a?(Hash)
                    if rsp["upd"]["version"].to_f > $upd["version"].to_f
                      Notifications.join("Elten " + rsp["upd"]["version"].to_s, "new", "upd_" + rsp["upd"]["version"].to_s)
                    elsif rsp["upd"]["beta"].to_f > $upd["beta"].to_f and $upd["isbeta"] == 1
                      Notifications.join("Elten " + $upd["version"].to_s + " beta " + rsp["upd"]["beta"].to_s, "new", "upd_" + rsp["upd"]["beta"].to_s)
                    end
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
              speech n.alert
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
          speech(sprintf("%02d:%02d", tim.hour, tim.min)) if $saytimetype == 1 or $saytimetype == 2
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
rescue Exception
  ewrite({ "func" => "error", "msg" => $!.to_s, "loc" => $@.to_s })
end
$sslsock.close if $sslsock != nil and !$sslsock.closed?
