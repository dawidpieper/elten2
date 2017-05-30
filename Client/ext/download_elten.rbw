require("win32api")
require("seven_zip_ruby")

  def futf8(text)
    mw = Win32API.new("kernel32", "MultiByteToWideChar", "ilpipi", "i")
    wm = Win32API.new("kernel32", "WideCharToMultiByte", "ilpipipp", "i")
    len = mw.call(0, 0, text, -1, nil, 0)
    buf = "\0" * (len*2)
    mw.call(0, 0, text, -1, buf, buf.bytesize/2)
    len = wm.call(65001, 0, buf, -1, nil, 0, nil, nil)
    ret = "\0" * len
    wm.call(65001, 0, buf, -1, ret, ret.bytesize, nil, nil)
    for i in 0..ret.bytesize - 1
      ret[i..i] = "\0" if ret[i] == 0
    end
    ret.delete!("\0")
    return ret
  end

def utf8(text)
  text = "" if text == nil or text == false
ext = "\0" if text == nil
to_char = Win32API.new("kernel32", "MultiByteToWideChar", 'ilpipi', 'i') 
to_byte = Win32API.new("kernel32", "WideCharToMultiByte", 'ilpipipp', 'i')
utf8 = 65001
w = to_char.call(utf8, 0, text.to_s, text.bytesize, nil, 0)
b = "\0" * (w*2)
w = to_char.call(utf8, 0, text.to_s, text.bytesize, b, b.bytesize/2)
w = to_byte.call(0, 0, b, b.bytesize/2, nil, 0, nil, nil)
b2 = "\0" * w
w = to_byte.call(0, 0, b, b.bytesize/2, b2, b2.bytesize, nil, nil)
return(b2)
  end

def run(file)
  params = 'LPLLLLLLPP'
createprocess = Win32API.new('kernel32','CreateProcess', params, 'I')
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
        createprocess.call(0, utf8(file), 0, 0, 0, 0, 0, 0, startinfo, procinfo)
            return procinfo[8,4].unpack('L').first # pid
          end
begin
    $appdata = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("appdata",$appdata,$appdata.bytesize)
for i in 0..$appdata.bytesize - 1
$appdata = $appdata.sub("\0","")
end
$appdata = futf8($appdata.encode(Encoding::CP852))
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
Win32API.new("user32","MessageBeep",'i','i').call(0)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($bindata),nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call($configdata,nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($langdata),nil)
Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,url = $url + "bin/elten.exe",utf8($bindata + "\\elten.exe"),0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(url)
Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,url = $url + "bin/elten.ini",utf8($bindata + "\\elten.ini"),0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(url)
Win32API.new("user32","MessageBeep",'i','i').call(0)
if Win32API.new("kernel32","GetUserDefaultUILanguage",'i','i').call(0) != 1045
Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,url = $url + "lng/EN_US.elg",$langdata + "\\EN_US.elg",0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(url)
iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
iniw.call('Language','Language',"EN_US",$configdata + "\\language.ini")
end
Win32API.new("urlmon","URLDownloadToFile",'ppplp','i').call(nil,$url + "bin/download/elten.7z",utf8($bindata + "\\elten.7z"),0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call($url + "bin/download/elten.7z")
SevenZipRuby::Reader.open_file($bindata + "\\elten.7z") do |szr|
  szr.extract(:all, $bindata + "\\elten")
end
run("#{$bindata}\\elten.exe")
end