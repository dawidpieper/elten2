require("win32api")
def run(file)
  params = 'LPLLLLLLPP'
createprocess = Win32API.new('kernel32','CreateProcess', params, 'I')
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
        createprocess.call(0, file, 0, 0, 0, 0, 0, 0, startinfo, procinfo)
            return procinfo[8,4].unpack('L').first # pid
          end
def getdirectory(type)
  dr = "\0" * 1024
  Win32API.new("shell32","SHGetFolderPath",'iiiip','i').call(0,type,0,0,dr)
  dr.delete!("\0")
  return dr
end
begin
    $appdata = getdirectory(26)
$eltendata = $appdata + "\\elten"
$configdata = $eltendata + "\\config"
$bindata = $eltendata + "\\bin"
$langdata = $eltendata + "\\lng"
cmd = $*.to_s
cmd.gsub("/wait") do
sleep(3)
end
$url = "https://elten-net.eu/"
Win32API.new("urlmon","URLDownloadToFile",'ppplp','i').call(nil,$url + "redirect","redirect",0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call($url + "redirect")
    if FileTest.exist?("redirect")
      rdr = IO.readlines("redirect")
      File.delete("redirect") if $DEBUG != true
      if rdr.size > 0
          if rdr[0].size > 0
            $url = rdr[0].delete("\r\n")
            end
        end
      end
if FileTest.exist?($bindata + "\\elten.exe") == false
if Win32API.new("kernel32","GetUserDefaultUILanguage",'i','i').call(0) != 1045
Win32API.new("user32","MessageBox",'lppl','i').call(0,"Elten is not installed on this computer. Please press OK and wait, while setup will be downloading the newest version of Elten. This can take several minutes.","ELTEN",0)
else
Win32API.new("user32","MessageBox",'lppl','i').call(0,"Elten nie jest zainstalowany. Kliknij OK i poczekaj kilka minut. Instalator pobierze program na dysk, po czym go uruchomi.","ELTEN",0)
end
Win32API.new("user32","MessageBeep",'i','i').call(0)
Win32API.new("kernel32","CreateDirectory",'pp','i').call($eltendata,nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call($bindata,nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call($configdata,nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call($langdata,nil)
Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,url = $url + "bin/download_elten.exe","download_elten.exe",0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(url)
Win32API.new("kernel32","CopyFile",'ppi','i').call("./download_elten.exe",$bindata+"\\download_elten.exe",0)
Win32API.new("user32","MessageBeep",'i','i').call(0)
if Win32API.new("kernel32","GetUserDefaultUILanguage",'i','i').call(0) != 1045
Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,url = $url + "lng/EN_US.elg",$langdata + "\\EN_US.elg",0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(url)
iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
iniw.call('Language','Language',"EN_US",$configdata + "\\language.ini")
end
run($bindata+"\\download_elten.exe")
$runned = true
else
run($bindata+"\\elten.exe")
end
end