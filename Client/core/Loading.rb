#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Loading
  def main
        $restart=false
                                $volume=100
            $preinitialized = false
    $eltenlib = "./eltenvc"
    begin
          $hook = Win32API.new($eltenlib,"hook",'','i').call
  rescue Exception
    $eltenlib = "elten"
    begin
      $hook = Win32API.new($eltenlib,"hook",'','i').call
    rescue Exception
      $hook=0
      end
      end
      $scenes = []
    $volume = 80
    $speech_to_utf = true
    $instance = Elten::Engine::Kernel.getmodulehandle(0)
    $process = Elten::Engine::Kernel.getcurrentprocess
    $path=Elten::Engine::Kernel.getmodulefilename.delete("\0")
            if $wnd==nil
    $wnd = Win32API.new("user32","FindWindow",'pp','i').call("RGSS Player",nil)
    $cwnd = Win32API.new("user32","GetActiveWindow",'','i').call
    if $cwnd != $wnd
      $ccwnd = Win32API.new("user32","GetForegroundWindow",'','i').call
      if $ccwnd == $wnd
        $wnd = $ccwnd
      elsif $cwnd == $wnd
        $wnd = $cwnd
      elsif $ccwnd == $cwnd
        $wnd = $cwnd
        end
      end
      end      
      $computer=Elten::Engine::Kernel.getcomputername.delete("\0")
            Bass.init($wnd) if $usebass==true
      writefile("hwnd",$wnd.to_s)
      if $ruby != true
            $sprite = Sprite.new
    $sprite.bitmap = Bitmap.new("elten.jpg") if FileTest.exists?("elten.jpg")
    Graphics.freeze
    Graphics.transition(0)
    end
        $name = ""
    $token = ""
    $url = "https://elten-net.eu/srv/"
    $srv = "elten-net.eu"
    Graphics.frame_rate = 60 if $ruby != true
              $appdata = getdirectory(26)
$userprofile = getdirectory(40)
$portable=readini("./elten.ini","Elten","Portable","0").to_i
if $portable == 0
$eltendata = $appdata + "\\elten"
else
  $eltendata = ".\\eltendata"
end
$commandline=Elten::Engine::Kernel.getcommandline
          if (/\/datadir \"([a-zA-Z0-9\\:\/ ]+)\"/=~$commandline) != nil
                $reld=$1
        $eltendata=$reld
            end    
      $configdata = $eltendata + "\\config"
$bindata = $eltendata + "\\bin"
$appsdata = $eltendata + "\\apps"
$extrasdata = $eltendata + "\\extras"
$soundthemesdata = $eltendata + "\\soundthemes"
$langdata = $eltendata + "\\lng"
Dir.mkdir($eltendata)
if FileTest.exists?($langdata)==false
    Dir.mkdir($langdata)
  $l = false
  langtemp = srvproc("languages","langtemp")
    err = langtemp[0].to_i
  case err
  when 0
    $l = true
      end
    if $l == true
          langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg", "#{$langdata}/"+langs[i].to_s + ".elg")
end
end  
if Elten::Engine::Kernel.getuserdefaultuilanguage != 1045
  download(url = $url + "lng/EN_US.elg",$langdata + "\\EN_US.elg")
writeini($configdata + "\\language.ini",'Language','Language',"EN_US")
  end
end
Dir.mkdir($configdata)
Dir.mkdir($bindata)
Dir.mkdir($appsdata)
Dir.mkdir($extrasdata)
Dir.mkdir($appsdata + "\\inis")
Dir.mkdir($soundthemesdata)
Dir.mkdir($soundthemesdata + "\\inis")
Dir.mkdir($langdata)
Dir.mkdir("temp")
$LOAD_PATH << $appsdata
if FileTest.exists?($configdata+"\\interface.ini") and FileTest.exists?($configdata+"\\advanced.ini") == false
keyms=readini($configdata+"\\interface.ini","Interface","KeyUpdateTime","")  
  hs=readini($configdata+"\\interface.ini","Interface","HexSpecial","")  
  yf=readini($configdata+"\\interface.ini","Interface","YTFormat","")  
  ss=readini($configdata+"\\interface.ini","Interface","SoundStreaming","")  
  writeini($configdata+"\\advanced.ini","Advanced","KeyUpdateTime",keyms) if keyms!=""
  writeini($configdata+"\\advanced.ini","Advanced","HexSpecial",hs) if hs!=""
  writeini($configdata+"\\advanced.ini","Advanced","YTFormat",yf) if yf!=""
  writeini($configdata+"\\advanced.ini","Advanced","SoundStreaming",ss) if ss!=""
  end
  $interface_listtype = readini($configdata + "\\interface.ini","Interface","ListType","0").to_i
$advanced_keyms = readini($configdata + "\\advanced.ini","Advanced","KeyUpdateTime","75").to_i
$advanced_ackeyms = $advanced_keyms * 3
$interface_soundthemeactivation = readini($configdata + "\\interface.ini","Interface","SoundThemeActivation","1").to_i
$interface_typingecho = readini($configdata + "\\interface.ini","Interface","TypingEcho","0").to_i  
$interface_linewrapping = readini($configdata + "\\interface.ini","Interface","LineWrapping","1").to_i
$interface_hidewindow = readini($configdata + "\\interface.ini","Interface","HideWindow","0").to_i
$interface_fullscreen = readini($configdata + "\\interface.ini","Interface","StartFullScreen","0").to_i
$advanced_hexspecial = readini($configdata + "\\advanced.ini","Advanced","HexSpecial","1").to_i
$advanced_refreshtime = readini($configdata + "\\advanced.ini","Advanced","RefreshTime","5").to_i        
if $advanced_refreshtime==1
writeini($configdata + "\\advanced.ini","Advanced","RefreshTime","5")
$advanced_refreshtime=5
end
$advanced_ytformat = readini($configdata + "\\advanced.ini","Advanced","YTFormat","wav").to_s
$advanced_ytformat="wav" if $advanced_ytformat!="mp3"
$advanced_soundstreaming = readini($configdata + "\\advanced.ini","Advanced","SoundStreaming","1").to_i
$advanced_synctime = readini($configdata + "\\advanced.ini","Advanced","SyncTime","1").to_i
if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
    File.delete("testtemp") if FileTest.exists?("testtemp")
      $url = "http://elten-net.eu/srv/"
      if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
      File.delete("testtemp") if FileTest.exists?("testtemp")
    $neterror=true
  else
    #sslerror
            end
    else
      $neterror=true
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
Win32API.new("bass","BASS_SetConfigPtr",'ip','l').call(0x10403,utf8($extrasdata+"\\soundfont.sf2")) if FileTest.exists?($extrasdata+"\\soundfont.sf2")
      version = readini(".\\elten.ini","Elten","Version",0).to_f
                beta = readini(".\\elten.ini","Elten","Beta","0").to_i
                                isbeta = readini(".\\elten.ini","Elten","IsBeta","0").to_i
alpha = readini(".\\elten.ini","Elten","Alpha","0").to_i
                      nversion = readini($bindata + "\\newest.ini","Elten","Version","0").to_f
                    nbeta = readini($bindata + "\\newest.ini","Elten","Beta",0).to_i
                    nalpha = readini($bindata + "\\newest.ini","Elten","Alpha",0).to_i
        $beta = Elten.beta
        $alpha = Elten.alpha
    $version = Elten.version
    $isbeta = Elten.isbeta
    $nbeta = nbeta
    $nalpha = nalpha
    $nversion = nversion
        if $showm == nil and $interface_fullscreen == 1
    $showm = Win32API.new('user32', 'keybd_event', 'LLLL', '')
$showm.call(18,0,0,0)
$showm.call(13,0,0,0)
$showm.call(13,0,2,0)
$showm.call(18,0,2,0)
    Graphics.update
    end
    File.delete("temp/agent_tray.tmp") if FileTest.exists?("temp/agent_tray.tmp")
    speech_stop
    startmessage = "ELTEN: " + $version.to_s
    startmessage += " BETA #{$beta.to_s}" if $isbeta == 1
startmessage += " RC #{$alpha.to_s}" if $isbeta == 2
            $playlist = []
$playlistindex = 0
$start = Time.now.to_i
$thr1=Thread.new{thr1} if $thr1==nil
$thr2=Thread.new{thr2} if $thr2==nil
$thr3=Thread.new{thr3} if $thr3==nil
$thr4=Thread.new{thr4} if $thr4==nil
$thr5=Thread.new{thr5} if $thr5==nil
$voice = readini($configdata + "\\sapi.ini","Sapi","Voice","-2").to_i if $voice == nil
if $rvc==nil
      if (/\/voice (-?)(\d+)/=~$commandline) != nil
        $rvc=$1+$2
        $voice=$rvc.to_i
            end    
    end
          if $voice == -2 or $voice == -3
          v=$voice
          $voice=-1
          speech("Nie wybrano głosu programu. Naciśnij enter, aby wybrać głos SAPI lub escape, aby użyć głosu domyślnego lub aktywnego czytnika ekranu.")
          until enter or escape
            loop_update
          end
if enter
          $voice=v
      $scene = Scene_Voice_Voice.new
    else
      $voice=-1
            writeini($configdata + "\\sapi.ini","Sapi","Voice","-1") if $voice != -3
      end
      return
    else
      Elten::Engine::Speech.setvoice($voice) if $voice != -3
                  $rate = readini($configdata + "\\sapi.ini","Sapi","Rate",50).to_i
        if $rvcr==nil
      if (/\/voicerate (\d+)/=~$commandline) != nil
        $rvcr=$1
        $rate=$rvcr.to_i
            end    
    end
                  Elten::Engine::Speech.setrate($rate)
    $sapivolume = readini($configdata + "\\sapi.ini","Sapi","Volume",100).to_i
    if $rvcv==nil
      if (/\/voicevolume (\d+)/=~$commandline) != nil
        $rvcv=$1
        $sapivolume=$rvcv.to_i
            end    
    end
    Elten::Engine::Speech.setvolume($sapivolume)
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
      $langwords = read($langdata + "\\" + $language + ".elg",false,true).split("\n")
            $langwords.delete_at(0)
      $langwords.delete_at(0)
      $langwords.delete_at(0)
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
if $silentstart==nil
  $silentstart=true if $commandline.include?("/silentstart")
end
speech(startmessage) if $silentstart != true
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
      $speech_wait = true if $silentstart != true
        if (((nversion > version+0.00001 or (nalpha > alpha and isbeta==2) or (nalpha == 0 and alpha > 0 and isbeta == 2))) or (isbeta==1 and nversion==version)) and $denyupdate != true
if $portable != 1
          $scene = Scene_Update_Confirmation.new
      return
    else
      speech("Dostępna jest nowa wersja programu.")
      speech_wait
      end
    end
            if $neterror == true
      if (download($url,"testtemp") == 0 and FileTest.exists?("testtemp"))
        File.delete("testtemp") if FileTest.exists?("testtemp")
        $neterror = false
      else
        speech("Błąd. Nie mogę połączyć się z serwerem.")
        $offline=true
        delay(3)
        speech_wait
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
        if autologin.to_i > 0 and $offline!=true
            $scene = Scene_Login.new
      return
    end
    $cw = Select.new(["Zaloguj Się","Rejestracja","Reset hasła","Otwórz na koncie gościa","Ustawienia interfejsu","Zmień syntezator mowy","Language / Język","Wymuś aktualizację lub reinstalację z serwera","Wyjście"])
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
              $scene=Scene_ForgotPassword.new
              when 3
                $name="guest"
                $token="guest"
                $rang_moderator=0
                $rang_tester=0
                $rang_developer=0
                $rang_translator=0
                $rang_mediaadministrator=0
                writefile("temp/agent.tmp","#{$name}\r\n#{$token}\r\n#{$wnd.to_s}")
  if $agentloaded != true
  agent_start
$agentloaded = true
end
                $scene=Scene_Main.new
                when 4
              $scene = Scene_Interface.new
              when 5
                $scene = Scene_Voice_Voice.new
              when 6
                $scene = Scene_Languages.new
                when 7
                  $scene = Scene_Update.new
              when 8
                $scene = nil
        end
        end
      end
    end
#Copyright (C) 2014-2016 Dawid Pieper