#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Loading
  def main
            $eresps={}
            $restart=false
                                $volume=100
            $preinitialized = false
    $eltenlib = "./eltenvc"
    begin
          $hook = Win32API.new($eltenlib,"hook",'','i').call
        rescue Exception
          p 'eltenvc'
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
    $instance = Win32API.new("kernel32","GetModuleHandle",'i','i').call(0)
    $process = Win32API.new("kernel32","GetCurrentProcess",'','i').call
    $path="\0"*1024
    Win32API.new("kernel32","GetModuleFileName",'ipi','i').call($instance,$path,$path.size)
    $path.delete!("\0")
  
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
      $computer="\0"*128
      siz=[$computer.size].pack("i")
      Win32API.new("kernel32","GetComputerName",'pp','i').call($computer,siz)
      $computer.delete!("\0")
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
$commandline=Win32API.new("kernel32","GetCommandLine",'','p').call.to_s
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
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($eltendata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($configdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($bindata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($appsdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($extrasdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($appsdata + "\\inis"),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata + "\\inis"),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($langdata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call("temp",nil)
$LOAD_PATH << $appsdata
if FileTest.exists?($configdata+"\\appid.dat")
$appid=read($configdata+"\\appid.dat")
else
  $appid = ""
  chars = ("A".."Z").to_a+("a".."z").to_a+("0".."9").to_a
  64.times do
    $appid << chars[rand(chars.length-1)]
  end
    writefile($configdata+"\\appid.dat",$appid)
  end
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
  $interface_soundcard = readini($configdata + "\\interface.ini","Interface","SoundCard","")
  $interface_microphone = readini($configdata + "\\interface.ini","Interface","Microphone","")
$advanced_keyms = readini($configdata + "\\advanced.ini","Advanced","KeyUpdateTime","75").to_i
$advanced_ackeyms = $advanced_keyms * 3
$interface_soundthemeactivation = readini($configdata + "\\interface.ini","Interface","SoundThemeActivation","1").to_i
$interface_typingecho = readini($configdata + "\\interface.ini","Interface","TypingEcho","0").to_i  
$interface_linewrapping = readini($configdata + "\\interface.ini","Interface","LineWrapping","1").to_i
$interface_hidewindow = readini($configdata + "\\interface.ini","Interface","HideWindow","0").to_i
$advanced_hexspecial = readini($configdata + "\\advanced.ini","Advanced","HexSpecial","1").to_i
$advanced_refreshtime = readini($configdata + "\\advanced.ini","Advanced","AgentRefreshTime","1").to_i        
if $advanced_refreshtime==1
writeini($configdata + "\\advanced.ini","Advanced","AgentRefreshTime","1")
$advanced_refreshtime=5
end
$advanced_ytformat = readini($configdata + "\\advanced.ini","Advanced","YTFormat","wav").to_s
$advanced_ytformat="wav" if $advanced_ytformat!="mp3"
$advanced_soundstreaming = readini($configdata + "\\advanced.ini","Advanced","SoundStreaming","1").to_i
$advanced_synctime = readini($configdata + "\\advanced.ini","Advanced","SyncTime","1").to_i
Bass.init($wnd) if $usebass==true
if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
          $url = "http://elten-net.eu/srv/"
      if download($url + "bin/elten.ini",$bindata + "\\newest.ini") != 0
          $neterror=true
  else
    #sslerror
            end
    else
      $neterror=false
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
                speech_stop
    startmessage = "ELTEN: " + $version.to_s.delete(".").split("").join(".")
    startmessage += " BETA #{$beta.to_s}" if $isbeta == 1
startmessage += " RC #{$alpha.to_s}" if $isbeta == 2
            $playlist = []
$playlistindex = 0
$start = Time.now.to_i
$thr1=Thread.new{thr1} if $thr1==nil
$thr2=Thread.new{thr2} if $thr2==nil
$thr3=Thread.new{thr3} if $thr3==nil
$thr4=Thread.new{thr4} if $thr4==nil
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
          speech(_("Loading:info_novoice"))
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
      Win32API.new("screenreaderapi","sapiSetVoice",'i','i').call($voice) if $voice != -3
                  $rate = readini($configdata + "\\sapi.ini","Sapi","Rate",50).to_i
        if $rvcr==nil
      if (/\/voicerate (\d+)/=~$commandline) != nil
        $rvcr=$1
        $rate=$rvcr.to_i
            end    
    end
                  Win32API.new("screenreaderapi","sapiSetRate",'i','i').call($rate)
    $sapivolume = readini($configdata + "\\sapi.ini","Sapi","Volume",100).to_i
    if $rvcv==nil
      if (/\/voicevolume (\d+)/=~$commandline) != nil
        $rvcv=$1
        $sapivolume=$rvcv.to_i
            end    
    end
    Win32API.new("screenreaderapi","sapiSetVolume",'i','i').call($sapivolume)
  end
          $soundthemespath = readini($configdata + "\\soundtheme.ini","SoundTheme","Path","")
            if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
                    $language = readini($configdata + "\\language.ini","Language","Language","")
                    if FileTest.exists?("Data/langs.dat")
                      $langs=load_data("Data/langs.dat")
                    else
                      $langs={}
                    end
                    if FileTest.exists?("Data/locations.dat")
                      $locations=load_data("Data/locations.dat")
                    else
                      $locations=[]
                    end
                    if !FileTest.exists?("Data/locale.dat")
                    mod="\0"*1024
Win32API.new("kernel32","GetModuleFileName",'ipi','i').call(0,mod,mod.size)
ind=(0...mod.size).find_all {|c| mod[c..c]=="\\" or mod[c..c]=="/"}.last
fol=mod[0...ind]
Win32API.new("kernel32","SetCurrentDirectory",'p','i').call(fol)
end
                    load_locale("Data/locale.dat",$language)
                    if $language==""
                                          lcid=Win32API.new("kernel32","GetUserDefaultLCID",'','i').call
                                                              $locales.each {|l| $language=l['_code'] if l['_lcid']==lcid }
                                                                                  $language='en_GB' if $language==""
                                                                                  set_locale($language)
                      end
if $silentstart==nil
  $silentstart=true if $commandline.include?("/silentstart")
end
speech(startmessage) if $silentstart != true
            $speech_wait = true if $silentstart != true
            bid=srvproc("bin/buildid","build_id=#{Elten.build_id.to_s}",1).to_i
        if Elten.build_id!=bid and $denyupdate != true
if $portable != 1
          $scene = Scene_Update_Confirmation.new
      return
    else
      speech(_("Loading:alert_newversion"))
      speech_wait
      end
    end
            if $neterror == true
      if (download($url,"testtemp") == 0 and FileTest.exists?("testtemp"))
        File.delete("testtemp") if FileTest.exists?("testtemp")
        $neterror = false
      else
        speech(_("General:error"))
        $offline=true
        delay(3)
        speech_wait
                      end
                    end
                          volume = readini($configdata + "\\interface.ini","Interface","MainVolume","-1").to_i
      if volume == -1
        writeini($configdata + "\\interface.ini","Interface","MainVolume","80")
      else
                $volume = volume
        end
if !FileTest.exists?($eltendata+"\\license_agreed.dat")
        $exit = true
license
                $exit = nil
                writefile($eltendata+"\\license_agreed.dat","\001")
        end
              if FileTest.exists?($eltendata+"\\update.last")
        l=Zlib::Inflate.inflate(read($eltendata+"\\update.last")).split(" ")
        lversion,lbeta,lalpha,lisbeta=l[0].to_f,l[1].to_i,l[2].to_i,l[3].to_i
        if lversion<2.32
          if $language[0..1].downcase=='pl'
            $remauth=lversion
            speech("Uwaga! Od przyszłych wersji Eltena usunięte zostaną pliki udostępnione. W razie chęci zachowania obecnie udostępnianych plików, prosimy o ich pobranie. Naciśnij enter, aby kontynuować.") if lversion<2.32
          else
            speech("Warning! Shared files will be deleted from the next versions of Elten. Users are asked to download their data now in case of lack of local backups. Press enter to continue.") if lversion<2.32
          end
          t=Time.now.to_f
          loop do
            loop_update
           break if enter or t<Time.now.to_f-30 or lversion>=2.32
            end
          end
        File.delete($eltendata+"\\update.last")
        end
        autologin = readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i
        if autologin.to_i > 0 and $offline!=true
            $scene = Scene_Login.new
      return
    end
    srvstate
    $cw = Select.new([_("Loading:opt_login"),_("Loading:opt_register"),_("Loading:opt_forgottenpass"),_("Loading:opt_guest"),_("Loading:opt_interfacesettings"),_("Loading:opt_changesynth"),"Language / Język",_("Loading:opt_reinstall"),_("General:str_quit")])
    $cw.disable_item(1) if $eltsuspend
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
#Copyright (C) 2014-2019 Dawid Pieper