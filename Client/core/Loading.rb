#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Loading
  def initialize(skiplogin=false)
    @skiplogin=skiplogin
    end
  def main
            $eresps={}
            $restart=false
                                $volume=70
            $preinitialized = false
    $eltenlib = "./eltenvc"
    h=Win32API.new($eltenlib, "hook", '', 'i').call
        if h!=0
        print("Failed to setup Window Hook")
            exit
          end
          Log.info("Window hook registered")
          $scenes = []
    $volume = 70
    $speech_to_utf = true
    $instance = Win32API.new("kernel32","GetModuleHandle",'i','i').call(0)
    $process = Win32API.new("kernel32","GetCurrentProcess",'','i').call
    $path="\0"*1024
    Win32API.new("kernel32","GetModuleFileName",'ipi','i').call($instance,$path,$path.size)
    $path.delete!("\0")
  Log.info("Exec path: #{$path}")
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
    Log.info("HWND: #{$wnd.to_s}")
      $computer="\0"*128
      siz=[$computer.size].pack("i")
      Win32API.new("kernel32","GetComputerName",'pp','i').call($computer,siz)
      $computer.delete!("\0")
      Log.info("Computer: #{$computer}")
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
      $extrasdata = $eltendata + "\\extras"
$soundthemesdata = $eltendata + "\\soundthemes"
$tempdir=$eltendata+"\\temp"
createdirifneeded($eltendata)
createdirifneeded($extrasdata)
createdirifneeded($soundthemesdata)
createdirifneeded($tempdir)
#upd
deldir($eltendata+"\\apps") if FileTest.exists?($eltendata+"\\apps")
deldir($eltendata+"\\bin") if FileTest.exists?($eltendata+"\\bin")
if FileTest.exists?($eltendata+"\\config")
v={
'Advanced'=>[['KeyUpdateTime'], ['RefreshTime'], ['SyncTime'], ['AgentRefreshTime']],
'Interface' => [['ListType'], ['SoundThemeActivation'], ['TypingEcho'], ['HideWindow'], ['MainVolume'], ['SayTimePeriod','Clock'], ['SayTimeType','Clock'], ['LineWrapping'], ['SoundCard', 'SoundCard'], ['Microphone', 'SoundCard']],
'Language' => [['Language','Interface']],
'Login' => [['AutoLogin'], ['Name'], ['Token'], ['TokenEncrypted']],
'Sapi' => [['Voice','Voice'], ['Rate','Voice'], ['Volume','Voice']],
'SoundTheme' => [['Path','Interface','SoundTheme']]
}
begin
for k in v.keys
  for o in v[k]
    o[1]=k if o[1]==nil
    o[2]=o[0] if o[2]==nil
        val=readini($eltendata+"\\config\\"+(k+"")+".ini", k+"", o[0], "")
    writeconfig(o[1]+"", o[2]+"", val) if val!=""
    end
  end
rescue Exception
  Log.error("UPD: #{$!.to_s} #{$@.to_s}")
end
copyfile($eltendata+"\\config\\appid.dat", $eltendata+"\\appid.dat")
deldir($eltendata+"\\config")
end
begin
deldir($eltendata+"\\lng")
if FileTest.exists?($soundthemesdata+"\\inis")
d=Dir.entries($soundthemesdata+"\\inis")
for f in d
  next if !f.include?(".ini")
  name=readini($soundthemesdata+"\\inis\\"+f, "SoundTheme", "Name", "")
  path=readini($soundthemesdata+"\\inis\\"+f, "SoundTheme", "Path", "")
  writefile($soundthemesdata+"\\"+path+"\\__name.txt", name)
end
end
rescue Exception
  end
#endupd
if FileTest.exists?($eltendata+"\\appid.dat")
$appid=readfile($eltendata+"\\appid.dat")
else
  Log.info("Generating new AppID")
  $appid = ""
  chars = ("A".."Z").to_a+("a".."z").to_a+("0".."9").to_a
  64.times do
    $appid << chars[rand(chars.length-1)]
  end
    writefile($eltendata+"\\appid.dat",$appid)
  end
  Log.info("Loading configuration")
  $interface_listtype = readconfig("Interface", "ListType", 0)
  $interface_soundcard = readconfig("SoundCard", "SoundCard", "")
  $interface_microphone = readconfig("SoundCard", "Microphone", "")
$advanced_keyms = readconfig("Advanced", "KeyUpdateTime", 75)
$advanced_ackeyms = $advanced_keyms * 3
$interface_soundthemeactivation = readconfig("Interface", "SoundThemeActivation", 1)
$interface_typingecho = readconfig("Interface", "TypingEcho", 0)
$interface_linewrapping = readconfig("Interface", "LineWrapping", 1)
$interface_hidewindow = readconfig("Interface", "HideWindow", 0)
$advanced_refreshtime = readconfig("Advanced", "AgentRefreshTime", 1)
$advanced_synctime = readconfig("Advanced", "SyncTime", 1)
Log.info("Initializing Bass")
Bass.init($wnd) if $usebass==true
Log.info("Initializing NVDA Support")
NVDA.init
loop_update while !NVDA.prepared?
Log.info("Connecting to Elten server")
if srvproc("init",{})[0].to_i<0
          $url = "http://elten-net.eu/srv/"
      if srvproc("init",{})[0].to_i<0
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
            if rdr.size > 0
          if rdr[0].size > 0
                        $url = rdr[0].delete("\r\n")
                        Log.info("Elten redirected to: #{$url}")
            end
        end
if srvproc("init",{})[0].to_i<0
  Log.error("Failed to connect to Elten server")
$neterror = true
end
        end
      end  
      Win32API.new("bass","BASS_SetConfigPtr",'ip','l').call(0x10403,$extrasdata+"\\soundfont.sf2") if FileTest.exists?($extrasdata+"\\soundfont.sf2")
                                    $beta = Elten.beta
        $alpha = Elten.alpha
    $version = Elten.version
    $isbeta = Elten.isbeta
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
$voice = readconfig("Voice","Voice",-2)
if $rvc==nil
      if (/\/voice (-?)(\d+)/=~$commandline) != nil
        $rvc=$1+$2
        $voice=$rvc.to_i
            end    
          end
          $language = readconfig("Interface", "Language", "")
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
          if $voice == -2 or $voice == -3
          v=$voice
          $voice=-1
          alert(_("Loading:info_novoice"))
          until enter or escape
            loop_update
          end
if enter
          $voice=v
      $scene = Scene_Voice_Voice.new
    else
      $voice=-1
            writeconfig("Voice","Voice",-1) if $voice != -3
      end
      return
    else
      Win32API.new("bin\\screenreaderapi","sapiSetVoice",'i','i').call($voice) if $voice != -3
                  $rate = readconfig("Voice","Rate",50)
        if $rvcr==nil
      if (/\/voicerate (\d+)/=~$commandline) != nil
        $rvcr=$1
        $rate=$rvcr.to_i
            end    
    end
                  Win32API.new("bin\\screenreaderapi","sapiSetRate",'i','i').call($rate)
                      $sapivolume = readconfig("Voice","Volume",100)
    if $rvcv==nil
      if (/\/voicevolume (\d+)/=~$commandline) != nil
        $rvcv=$1
        $sapivolume=$rvcv.to_i
            end    
    end
    Win32API.new("bin\\screenreaderapi","sapiSetVolume",'i','i').call($sapivolume)
  end
          $soundthemespath = readconfig("Interface","SoundTheme","")
            if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
                                                                                                                                                                  if $silentstart==nil
  $silentstart=true if $commandline.include?("/silentstart")
end
v=14
if Win32API.new("bin\\screenreaderapi", "getCurrentScreenReader", '', 'i').call==2 && (!NVDA.check || NVDA.getversion!=v)
  if !NVDA.check
  str=_("Loading:alert_nvdaaddon")
elsif NVDA.getversion!=v
  str=_("Loading:alert_nvdaaddonupdate")
    end
  if FileTest.exists?($appdata+"\\nvda")
 confirm(str) {
 File.delete($tempdir+"\\nvda.pipe")
 decompress("Data/ELTEN.nvda-addon", $appdata+"\\nvda\\addons\\ELTEN")
 pth=getdirectory(38)+"\\nvda\\nvda.exe"
 if FileTest.exists?(pth)
 s="\"\"#{pth}\" \"#{pth}\" -r\""
   run("cmd /c "+s, true)
 waiting
  t=Time.now.to_f
  loop_update while Time.now.to_f-t<10 and Win32API.new("bin\\screenreaderapi", "getCurrentScreenReader", '', 'i').call==2
  t=Time.now.to_f
  loop_update while Time.now.to_f-t<10 and Win32API.new("bin\\screenreaderapi", "getCurrentScreenReader", '', 'i').call!=2
 delay(3)
 NVDA.init
 loop_update while !NVDA.prepared?
  waiting_end
 end
 }
  end
end
Log.info("NVDA Version: "+NVDA.getnvdaversion.to_s) if NVDA.check
speech(startmessage) if $silentstart != true
            $speech_wait = true if $silentstart != true
            bid=srvproc("bin/buildid","build_id=#{Elten.build_id.to_s}",1).to_i
                    if Elten.build_id!=bid and bid>0 and $denyupdate != true
                      Log.info("New update available (BuildID: #{bid.to_s})")
if $portable != 1
              $scene = Scene_Update_Confirmation.new
      return
    else
      alert(_("Loading:alert_newversion"))
      end
    end
            if $neterror == true
      if (download($url,"testtemp") == 0 and FileTest.exists?("testtemp"))
        File.delete("testtemp") if FileTest.exists?("testtemp")
        $neterror = false
      else
        alert(_("General:error"))
        $offline=true
        delay(3)
        speech_wait
                      end
                    end
                          $volume = readconfig("Interface", "MainVolume", 70)
      if !FileTest.exists?($eltendata+"\\license_agreed.dat")
        $exit = true
license
                $exit = nil
                writefile($eltendata+"\\license_agreed.dat","\001")
        end
              if FileTest.exists?($eltendata+"\\update.last")
                        l=Zlib::Inflate.inflate(readfile($eltendata+"\\update.last")).split(" ")
        lversion,lbeta,lalpha,lisbeta=l[0].to_f,l[1].to_i,l[2].to_i,l[3].to_i
        Log.info("Update completed from version #{lversion.to_s}")
        if lversion<2.35
          @runkey=Win32::Registry::HKEY_CURRENT_USER.create("Software\\Microsoft\\Windows\\CurrentVersion\\Run")
begin
  @runkey['elten']
  @autostart=true
  rescue Exception
  @autostart=false
end
@runkey['elten']=@runkey['elten'].gsub("agentc.dat","agent.dat") if @autostart==true and @runkey['elten'].include?("agentc.dat")
@runkey.close
          if $language[0..1].downcase=='pl'
            s="Przez pięć lat od wydania pierwszej wersji programu, Elten wielokrotnie się zmieniał. W rezultacie wiele plików przez niego utworzonych nie jest już używanych. Czy chcesz usunąć te pliki?"
          else
            s="During five years of development, Elten has changed many times. As a result, many of the files included in previous versions are no longer used. Do you want to delete thesem?"
          end
          confirm(s) {
          begin
          $ofiles=load_data("Data/files.dat")
          for i in 0...$ofiles.size
            $ofiles[i].downcase!
            end
          $files=[]
def getfiles(dir)
d=Dir.entries(dir)
d.delete(".")
d.delete("..")
for f in d
fi=dir+"/"+f
if !File.directory?(fi)
$files.push(fi.downcase)
else
getfiles(fi)
end
end
end
getfiles(".")
$dfiles=[]
for fi in $files
  $dfiles.push(fi) if !$ofiles.include?(fi.downcase)
end
for fi in $dfiles
  pth=fi.split("/")
  if (pth[1].downcase!='audio' or (pth[2].downcase=='bgs' or pth[2].downcase=='se')) and pth[1].downcase!='temp'
    begin
      File.delete(fi)
    rescue Exception
            end
    end
  end
            rescue Exception
            end
          }
          if $language[0..1].downcase=='pl'
            speech('Drodzy Eltenowicze.
W związku z rosnącymi kosztami utrzymywania serwera Eltena, których nie jestem w stanie dalej pokrywać samodzielnie, rozwój aplikacji został uzależniony od możliwości złożenia się na serwer za rok 2020. Jeśli nie uda się zrealizować tego celu do 31 grudnia, rozwój aplikacji zostanie zakończony, a Elten zamknięty.
Więcej szczegółów można odnaleźć na forum "Elten Network" grupy "Rozwój Eltena".
Naciśnij enter, aby kontynuować.')
          else
            speech('Dear users.
            Due to the increasing costs of leasing the Elten server, which I am no longer able to cover on my own, the development of the application was made dependent on the possibility to concur to maintain the server for the year 2020. If this goal is not achieved by 31 December, the development of the application will be finished and Elten will be closed.
            More details can be found in the "Elten" forum of "English Elten Community" group.
Press enter to continue.')
end
loop do
loop_update
break if enter
end
                    end
        File.delete($eltendata+"\\update.last")
        end
        autologin = readconfig("Login", "AutoLogin", 0)
        if autologin.to_i > 0 and $offline!=true and @skiplogin==false
          Log.info("Processing with autologin")
            $scene = Scene_Login.new
      return
    end
        $cw = Select.new([_("Loading:opt_login"),_("Loading:opt_register"),_("Loading:opt_forgottenpass"),_("Loading:opt_guest"),_("Loading:opt_generalsettings"),_("Loading:opt_changesynth"),"Language / Język",_("Loading:opt_reinstall"),_("General:str_quit")])
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
              $scene = Scene_General.new
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