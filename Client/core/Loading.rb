#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Loading
  def main
        $preinitialized = false
    $eltenlib = "eltenvc"
    begin
    $winver = Win32API.new($eltenlib,"WindowsVersion",'v','i')
  rescue Exception
    $eltenlib = "elten"
    retry
    end
    $scenes = []
    $volume = 80
    $speech_to_utf = true
    $instance = Win32API.new("kernel32","GetModuleHandle",'i','i').call(0)
    $wnd = Win32API.new("user32","FindWindow",'pp','i').call("RGSS Player",nil)
    $cwnd = Win32API.new("user32","GetActiveWindow",'v','i').call
    if $cwnd != $wnd
      $ccwnd = Win32API.new("user32","GetForegroundWindow",'v','i').call
      if $ccwnd == $wnd
        $wnd = $ccwnd
      elsif $cwnd == $wnd
        $wnd = $cwnd
      elsif $ccwnd == $cwnd
        $wnd = $cwnd
        end
      end
            writefile("hwnd",$wnd.to_s)
    $sprite = Sprite.new
    $sprite.bitmap = Bitmap.new("elten.jpg")
    Graphics.freeze
    Graphics.transition(0)
    $name = ""
    $token = ""
    $url = "https://elten-net.eu/"
    $srv = "elten-net.eu"
Graphics.frame_rate = 60
              $appdata = getdirectory(26)
$userprofile = getdirectory(40)
$eltendata = $appdata + "\\elten"
$configdata = $eltendata + "\\config"
$bindata = $eltendata + "\\bin"
$appsdata = $eltendata + "\\apps"
$soundthemesdata = $eltendata + "\\soundthemes"
$langdata = $eltendata + "\\lng"
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($eltendata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($configdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($bindata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($appsdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($appsdata + "\\inis"),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata + "\\inis"),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($langdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call("temp",nil)
$LOAD_PATH << $appsdata
  $interface_listtype = readini($configdata + "\\interface.ini","Interface","ListType","0").to_i
$interface_keyms = readini($configdata + "\\interface.ini","Interface","KeyUpdateTime","75").to_i
$interface_ackeyms = $interface_keyms * 3
$interface_soundthemeactivation = readini($configdata + "\\interface.ini","Interface","SoundThemeActivation","1").to_i
$interface_typingecho = readini($configdata + "\\interface.ini","Interface","TypingEcho","0").to_i  
$interface_hidewindow = readini($configdata + "\\interface.ini","Interface","HideWindow","0").to_i
$interface_fullscreen = readini($configdata + "\\interface.ini","Interface","FullScreen","0").to_i
$interface_hexspecial = readini($configdata + "\\interface.ini","Interface","HexSpecial","1").to_i
$interface_refreshtime = readini($configdata + "\\interface.ini","Interface","RefreshTime","1").to_i        
$interface_ytbuffering = readini($configdata + "\\interface.ini","Interface","YTBuffering","1").to_i        
if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
      File.delete("testtemp") if FileTest.exists?("testtemp")
      $neterror = true
      end
      if $neterror == true
      download($url + "redirect","redirect")
    if FileTest.exist?("redirect")
      $neterror = false
      rdr = IO.readlines("redirect")
      File.delete("redirect") if $DEBUG != true and FileTest.exists?
      ("redirect") if $DEBUG != true
      if rdr.size > 0
          if rdr[0].size > 0
            $url = rdr[0].delete("\r\n")
            end
        end
if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
$neterror = true
end
        end
      end  
      version = readini(".\\elten.ini","Elten","Version",0).to_f
                beta = readini(".\\elten.ini","Elten","Beta","0").to_i
                      isbeta = readini(".\\elten.ini","Elten","IsBeta","0").to_i
alpha = readini(".\\elten.ini","Elten","Alpha","0").to_i
                      nversion = readini($bindata + "\\newest.ini","Elten","Version","0").to_f
                    nbeta = readini($bindata + "\\newest.ini","Elten","Beta",0).to_i
                    nalpha = readini($bindata + "\\newest.ini","Elten","Alpha",0).to_i
        $beta = beta
        $alpha = alpha
    $version = version
    $isbeta = isbeta
    $nbeta = nbeta
    $nalpha = nalpha
    $nversion = nversion
        if $showm == nil and $interface_fullscreen == 1
    $showm = Win32API.new 'user32', 'keybd_event', %w(l l l l), ''
$showm.call(18,0,0,0)
$showm.call(13,0,0,0)
$showm.call(13,0,2,0)
$showm.call(18,0,2,0)
    Graphics.update
    end
    speech_stop
    startmessage = "ELTEN: " + $version.to_s
    startmessage += " BETA #{$beta.to_s}" if $isbeta == 1
startmessage += " ALFA #{$alpha.to_s}" if $isbeta == 2
    $voice = 0
            $playlist = []
$playlistindex = 0
$start = Time.now.to_i
$thr1=Thread.new{thr1} if $thr1==nil
$thr2=Thread.new{thr2} if $thr2==nil
$thr3=Thread.new{thr3} if $thr3==nil
$thr4=Thread.new{thr4} if $thr4==nil
$thr5=Thread.new{thr5} if $thr5==nil
$voice = readini($configdata + "\\sapi.ini","Sapi","Voice","-2").to_i
        if $voice == -2
      print("Nie wybrano głosu programu.\r\nPo potwierdzeniu tego komunikatu użyj strzałek góra-duł, aby wybrać głos.")
      $scene = Scene_Voice_Voice.new
      return
    else
      Win32API.new("screenreaderapi","sapiSetVoice",'i','i').call($voice)
                  $rate = readini($configdata + "\\sapi.ini","Sapi","Rate",50).to_i
        Win32API.new("screenreaderapi","sapiSetRate",'i','i').call($rate)
    $sapivolume = readini($configdata + "\\sapi.ini","Sapi","Volume",100).to_i
    Win32API.new("screenreaderapi","sapiSetVolume",'i','i').call($sapivolume)
  end
          $soundthemespath = readini($configdata + "\\soundtheme.ini","SoundTheme","Path","")
            if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
                    $language = readini($configdata + "\\language.ini","Language","Language","PL_PL")
                  $lang_src = []
      $lang_dst = []
    if $language != "PL_PL"
      $langwords = readlines($langdata + "\\" + $language + ".elg")
                          for i in 0..$langwords.size - 1
        $langwords[i].delete!("\n")
        $langwords[i].gsub!('\r\n',"\r\n")
        s = false
        $lang_src[i] = ""
        $lang_dst[i] = ""
        for j in 0..$langwords[i].size - 1
          if s == false
            if $langwords[i][j..j] != "|" and $langwords[i][j..j] != "\\"
            $lang_src[i] += $langwords[i][j..j]
          else
            s = true
          end
        else
          if $langwords[i][j..j] != "|" and $langwords[i][j..j] != "\\"
            $lang_dst[i] += $langwords[i][j..j]
            end
            end
          end
      end
end
speech(startmessage)
if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
            $neterror = true
      end
      if $neterror == true
      download($url + "redirect","redirect")
    if FileTest.exist?("redirect")
      $neterror = false
      rdr = IO.readlines("redirect")
      File.delete("redirect") if $DEBUG != true
      if rdr.size > 0
          if rdr[0].size > 0
            $url = rdr[0].delete("\r\n")
            end
        end
if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
$neterror = true
end
        end
      end  
loop_update
      $speech_wait = true
        if ((nversion > version)) and $denyupdate != true
      $scene = Scene_Update_Confirmation.new
      return
    end
    if $neterror = true
      if (download($url,"testtemp") == 0 and FileTest.exists?("testtemp"))
        File.delete("testtemp") if FileTest.exists?("testtemp")
        $neterror = false
      else
        speech("Błąd. Nie mogę połączyć się z serwerem. Upewnij się, że komputer ma dostęp do Internetu i spróbuj jeszcze raz.")
        speech_wait
        $scene = nil
        return
      end
      end
      volume = readini($configdata + "\\interface.ini","Interface","MainVolume","-1").to_i
      if volume == -1
$exit = true
        license
        $exit = nil
        writeini($configdata + "\\interface.ini","Interface","MainVolume","80")
        else
        $volume = volume
        end
      autologin = readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i
        if autologin.to_i > 0
            $scene = Scene_Login.new
      return
    end
    $cw = Select.new(["Zaloguj Się","Rejestracja","Ustawienia interfejsu","Zmień syntezator mowy","Language / Język","Wymuś aktualizację lub reinstalację z serwera","Wyjście"])
    loop do
loop_update
      $cw.update
      update
      if $scene != self
        break
      end
      end
    end
    def update
      if enter
        case $cw.index
        when 0
          $scene = Scene_Login.new
          when 1
            $scene = Scene_Registration.new
            when 2
              $scene = Scene_Interface.new
              when 3
                $scene = Scene_Voice_Voice.new
              when 4
                $scene = Scene_Languages.new
                when 5
                  $scene = Scene_Update.new
              when 6
                $scene = nil
        end
        end
      end
    end
#Copyright (C) 2014-2016 Dawid Pieper