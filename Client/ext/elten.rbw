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
begin
    $appdata = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("appdata",$appdata,$appdata.size)
for i in 0..$appdata.size - 1
$appdata = $appdata.sub("\0","")
end
$eltendata = $appdata + "\\elten"
$configdata = $eltendata + "\\config"
$bindata = $eltendata + "\\bin"
$langdata = $eltendata + "\\lng"
$url = "https://elten-net.eu/"
if FileTest.exists?($bindata + "\\elten")
run($bindata + "\\elten\\elten.exe")
else
Win32API.new("urlmon","URLDownloadToFile",'ppplp','i').call(nil,$url + "bin/download_elten.exe",$bindata + "\\download_elten.exe",0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call($url + "bin/download_elten.exe")
run($bindata + "\\download_elten.exe")
end
end