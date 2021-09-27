# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

Encoding.default_internal = Encoding::UTF_8
$VERBOSE = nil
require "base64"
require "json"
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
require "base62"
require "socket"
require "uri"
require "cgi"
require "win32ole"
require "http/2"
require "zstd-ruby"
require "./dlls.rb"
require("./eltenapi.rb")
require("./opus.rb")
require("./speexdsp.rb")
require("./steamaudio.rb")
require("./voip.rb")
require("./conference.rb")
require("./audio3d.rb")
require("./quicknav.rb")
require "./eprocessor.rb"
# Libraries requiring dll search location to be set
require "xz"

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
  if $*.include?("/debug")
    file = ENV["temp"] + "\\eltenagent.txt"
    if $debugfile == nil
      $debugfile = File.open(file, "wb")
    end
    $debugfile.write(data.inspect + "\n")
  end
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
  loadlocaledata("Data/locale.dat")
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
  $eltencred = OpenSSL::PKey::RSA.new(IO.binread("./Data/eltencredpub.pem"))
  $eltencred_mutex = Mutex.new
  use_soundtheme("Data/Audio.elsnd", true)
  $ag_wnd = $createemptywindow.call(unicode("ELTEN Agent"))
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
  #$name='test'
  #$token="test"
  #c=Conference.new
  #c.on_ping{|t|puts "Ping: "+t.to_s}
  #c.on_diceroll{|username,userid,roll|puts "#{username}: rolled #{roll}"}
  #c.on_card{|username,userid,type,deck,card|puts "#{username}: #{type}, #{deck}, #{card}"}
  #p c.create_channel({'name'=>'abc','password'=>'pao', 'bitrate'=>192, 'framesize'=>10, 'channels'=>2, 'spatialization'=>0, 'key_len'=>256})
  #p c.deck_add("full")
  ##c.begin_save("c:\\users\\dawid\\desktop\\save.ogg")
  #muted=true
  #streaming=false
  #c.shoutcast_start("elten.link:8000,1", "password3")
  ##recording=false
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
  #c.input_volume+=10;p c.input_volume
  #when ","
  #c.input_volume-=10;p c.input_volume
  #when "m"
  #muted=!muted;c.setvolume($name, 100, muted)
  #when "t"
  #if !streaming
  #c.set_stream('C:\Users\dawid\Music\Irena Santor\Moja Warszawa\04 - Deszcz.flac')
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
  #when "p"
  #c.ping
  #when "q"
  #break
  #else
  #c.diceroll(s.to_i) if s.to_i.to_s==s
  #end
  #end
  #c.free
  #exit

  class FeedMessage
    attr_accessor :id, :user, :time, :message, :response, :responses, :liked, :likes

    def initialize(id = 0, user = "", time = 0, message = "", response = 0, responses = 0, liked = false, likes = 0)
      @id, @user, @time, @message, @response, @responses, @liked, @likes = id, user, time, message, response, responses, liked, likes
    end

    def to_h
      return { "id" => @id, "message" => @message, "time" => @time, "user" => @user, "response" => @response, "responses" => @responses, "liked" => @liked, "likes" => @likes }
    end
  end

  def fetch_feeds
    $feedstime ||= 0
    return if $name == nil || $name == "" || $name == "guest"
    erequest("feeds", "name=#{$name}\&token=#{$token}\&ac=showcontacted\&time=#{$feedstime}\&details=2") { |d|
      begin
        if d.is_a?(String)
          l = d.force_encoding("UTF-8").split("\r\n")
          if l[0].to_i == 0
            $feeds = {}
            feed = nil
            c = 0
            for i in 2...l.size
              case c
              when 0
                feed = FeedMessage.new(l[i].to_i)
              when 1
                feed.user = l[i]
              when 2
                feed.time = l[i].to_i
              when 3
                if l[i] != "\004END\004"
                  feed.message += "\n" if feed.message != ""
                  feed.message += l[i]
                  c -= 1
                end
              when 4
                feed.response = l[i].to_i
              when 5
                feed.responses = l[i].to_i
              when 6
                feed.likes = l[i].to_i
              when 7
                feed.liked = (l[i].to_i == 1)
                $feeds[feed.id] = feed
                c = -1
              end
              c += 1
            end
            changed = []
            played = false
            for f in $feeds.keys
              if $lastfeeds == nil || $lastfeeds[f] == nil || $lastfeeds[f].message != $feeds[f].message || $lastfeeds[f].responses != $feeds[f].responses || $lastfeeds[f].likes != $feeds[f].likes || $lastfeeds[f].liked != $feeds[f].liked
                if (/\@#{Regexp.escape($name)}([^a-zA-Z0-9\.\-\_]|$)/i =~ $feeds[f].message) != nil && ($lastfeeds == nil || $lastfeeds[f] == nil)
                  play "feed_mention" if $lastfeeds != nil && $donotdisturb != true
                end
                if played == false && ($lastfeeds != nil && $lastfeeds[f] == nil)
                  played = true
                  play("feed_update") if $lastfeeds != nil && $donotdisturb != true && $disablefeednotifications != 1
                end
                changed.push($feeds[f])
              end
            end
            if changed.size > 0
              ewrite({ "func" => "feeds", "changed" => JSON.generate(changed.map { |f| f.to_h }) })
            end
            $lastfeeds = $feeds
          end
        end
      rescue Exception
        log(2, "Feeds error: #{$!.to_s}")
      end
    }
  end

  $wn = {}
  $li = 0
  $soundcard = nil
  $microphone = nil
  $key = [false] * 256
  $neededkeys = []
  $iimodifiers = nil
  $iicards = []
  $message_id = 0
  $feeds = {}
  $watcher = Thread.new {
    x = [0].pack("I")
    loop {
      sleep(0.5)
      if $hwnd != nil and !$iswindow.call($hwnd)
        Process.exit
      end
      if $superpid != nil
        h = $openprocess.call(0x1000, 0, $superpid)
        if h != 0
          $getexitcodeprocess.call(h, x)
          if x.unpack("I").first != 259
            Process.exit
          end
          $closehandle.call(h)
        else
          Process.exit
        end
      end
    }
  }
  log(0, "Agent initialized")
  $auctions = false
  loop do
    $ag_wnd = $createemptywindow.call(unicode("ELTEN Agent")) if $getemptywindow.call == 0
    $updateemptywindow.call
    if $li % 3 == 0
      if $fileopen_hook != nil
        file = "\0" * 260 * 2
        st = $getfileopen.call(file, 260)
        if st == 0
          $fileopen_hook = nil
        elsif st == 2
          f = deunicode(file)
          fl = f[0...f.index("\0") || f.size]
          $hidefileopen.call
          $fileopen_hook.call(fl)
          $fileopen_hook = nil
        end
      end
    end
    if $li % 2 == 0
      for i in $neededkeys.uniq
        $key[i] = ($getasynckeystate.call(i) < 0)
      end
    end
    if $li % 3 == 0
      if $name != nil && $token != nil && $message_id == 0
        erequest("messages_quickread", "name=#{$name}&token=#{$token}&ac=lastid") { |d|
          if d.is_a?(String)
            l = d.split("\r\n")
            if l[0].to_i == 0
              $message_id = l[1].to_i
            end
          end
        }
      end
      if $name != nil && $token != nil && $message_id > 0
        k = $gethk.call
        if k > 0x8000
          key = k - 0x8000
          case key
          when 0x25
            nav :left
          when 0x26
            nav :up
          when 0x27
            nav :right
          when 0x28
            nav :down
          when 0x23
            nav :first
          when 0x24
            nav :last
          when 0x21
            nav :pageup
          when 0x22
            nav :pagedown
          when 0x20
            nav :say
          when 0x08
            nav :stop
          when 0xd
            nav :select
          when 77
            nav :message
          when 70
            nav :feed
          when 82
            nav :reply
          end
        end
      end
      msgcheck
      feedcheck
      chatcheck
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
        EProcessor.process(data)
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
      $lastlanguage = $language
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
      $refreshtime = readconfig("Advanced", "AgentSessionTime", "2").to_i
      $volume = readconfig("Interface", "MainVolume", "70").to_i
      $disablefeednotifications = readconfig("Interface", "DisableFeedNotifications", "0").to_i
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
        s = false
        for i in 0...mc.size
          if mc[i].name == $microphone
            Bass.setrecorddevice(i)
            s = true
          end
        end
        if s == false
          defl = mc.index(mc.find { |m| m.default? }) || -1
          Bass.setrecorddevice(defl)
        end
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
      $language = readconfig("Interface", "Language", "")
      if $lastlanguage != $language
        setlocale($language)
      end
      $lastsoundtheme = $soundtheme
      $usedenoising = readconfig("Advanced", "UseDenoising", "0").to_i
      $disableconferencemiconrecord = readconfig("Advanced", "DisableConferenceMicOnRecord", "0").to_i
      $enableaudiobuffering = readconfig("Advanced", "EnableAudioBuffering", "0").to_i
      $useechocancellation = readconfig("Advanced", "UseEchoCancellation", "0").to_i
      $usebilinearhrtf = readconfig("Advanced", "UseBilinearHRTF", "0").to_i
      $iimodifiers = readconfig("InvisibleInterface", "IIModifiers", (0).to_s).to_i
      $iicards = readconfig("InvisibleInterface", "Cards", "messages,feed,conference").split(",")
      if $lastiimodifiers != $iimodifiers
        possible = [0x1 | 0x2 | 0x8, 0x1 | 0x4 | 0x8, 0x1 | 0x2 | 0x4, 0x1 | 0x2, 0x1 | 0x4]
        keys = [0x25, 0x26, 0x27, 0x28, 0x20, 0x21, 0x22, 0x24, 0x23, 0xd, 0x08, 70, 77, 82].uniq
        if $iimodifiers == 0
          for ii in possible
            m = "".b
            cnt = 0
            for k in keys
              s = [0x8000 + k, ii, k].pack("iII")
              m += s
              cnt += 1
            end
            if (e = $inithk.call(m, cnt)) == 0
              writeconfig("InvisibleInterface", "IIModifiers", ii.to_s)
              $iimodifiers = ii
              ewrite({ "func" => "ii_hkset", "ii" => ii })
              break
            end
          end
        end
        m = "".b
        cnt = 0
        ii = $iimodifiers
        for k in keys
          s = [0x8000 + k, ii, k].pack("iII")
          m += s
          cnt += 1
        end
        if (e = $inithk.call(m, cnt)) > 0
          ewrite({ "func" => "ii_hkerrors", "errors" => e })
        end
        $lastiimodifiers = $iimodifiers
      end
      $conference.reset if $conference != nil && $usedenoising != $lastusedenoising
      if $name != nil and $name != ""
        pr = "name=#{$name}\&token=#{$token}\&agent=1\&gz=1\&lasttime=#{$wnlasttime || Time.now.to_i}"
        pr += "\&shown=1" if $shown == true
        begin
          erequest("wn_agent", pr, nil, nil, nil, true) { |ans|
            if ans.is_a?(String)
              begin
                rsp = JSON.load(Zlib.inflate(ans))
                if $auctions != (rsp["auctions"] == true)
                  $auctions = rsp["auctions"]
                  ewrite({ "func" => "auctions", "auctions" => $auctions })
                end
                $wnlasttime = rsp["time"] if rsp["time"].is_a?(Integer)
                $ag_msg ||= rsp["msg"].to_i
                $ag_feed ||= 0
                $ag_feedtime ||= 0
                if $ag_msg < (rsp["msg"].to_i || 0)
                  $ag_msg = rsp["msg"].to_i
                  ewrite({ "func" => "msg", "msgs" => $ag_msg })
                end
                if $ag_feed != (rsp["feed"].to_i || 0) || $ag_feedtime < (rsp["feedtime"].to_i || 0)
                  $ag_feed = rsp["feed"].to_i
                  $ag_feedtime = rsp["feedtime"].to_i
                  fetch_feeds
                  #ewrite({'func'=>'msg','msgs'=>$ag_msg})
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
                    voice = "ringing"
                    if $premiumpackages.is_a?(Array) && $premiumpackages.include?("audiophile")
                      if FileTest.exists?($eltendata + "\\ringtones.json")
                        begin
                          json = JSON.load(IO.binread($eltendata + "\\ringtones.json"))
                          vc = json[rsp["call"]["caller"]]
                          voice = vc if vc != nil && FileTest.exists?(vc)
                        rescue Exception
                        end
                      end
                    end
                    @ringingplaying = true
                    @call_id = rsp["call"]["id"]
                    play(voice, true, true)
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
              speak n.alert if n.alert != ""
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
        play("alarm", true, true)
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
ensure
  $destroyemptywindow.call
  Audio3D.free
  SteamAudio.free
  Bass.free
  $sslsock.close if $sslsock != nil and !$sslsock.closed?
end
