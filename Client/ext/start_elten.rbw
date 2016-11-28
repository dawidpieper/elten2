require("win32api")
def utf8(text)
  text = "" if text == nil
ext = "\0" if text == nil
to_char = Win32API.new("kernel32", "MultiByteToWideChar", 'ilpipi', 'i') 
to_byte = Win32API.new("kernel32", "WideCharToMultiByte", 'ilpipipp', 'i')
utf8 = 65001
w = to_char.call(utf8, 0, text, text.size, nil, 0)
b = "\0" * (w*2)
w = to_char.call(utf8, 0, text, text.size, b, b.size/2)
w = to_byte.call(0, 0, b, b.size/2, nil, 0, nil, nil)
b2 = "\0" * w
w = to_byte.call(0, 0, b, b.size/2, b2, b2.size, nil, nil)
return(b2)
  end
begin
    $appdata = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("appdata",$appdata,$appdata.size)
$appdata = $appdata.to_s
for i in 0..$appdata.size - 1
$appdata = $appdata.sub("\0","")
end
$eltendata = $appdata + "\\elten"
$configdata = $eltendata + "\\config"
$bindata = $eltendata + "\\bin"
cmd = $*.to_s
cmd.gsub("/wait") do
sleep(3)
end
Win32API.new("user32","MessageBeep",'i','i').call(0)
if FileTest.exist?($bindata + "\\elten.exe")
system("\"#{$bindata}\\elten.exe\"")
else
Win32API.new("kernel32","CreateDirectory",'ppi','i').call($eltendata,nil)
Win32API.new("kernel32","CreateDirectory",'ppi','i').call($bindata,nil)
Win32API.new("kernel32","CopyFile",'ppi','i').call("start_elten.exe",$bindata + "\\start_elten.exe",0)
Win32API.new("kernel32","CopyFile",'ppi','i').call("download_elten.exe",$bindata + "\\download_elten.exe",0)
if Win32API.new("kernel32","GetUserDefaultUILanguage",'v','i').call != 1045
ef = Win32API.new("user32","MessageBox",'lppl','i').call(0,utf8("Elten wasn't installed on tis user account.\r\nDo you want to download and install it now?                "),"ELTEN",4|32)
else
ef = Win32API.new("user32","MessageBox",'lppl','i').call(0,utf8("Na tym koncie użytkownika Elten nie został zainstalowany.\r\nCzy chcesz go pobrać i zainstalować?                "),"ELTEN",4|32)
end
if ef == 6
system("download_elten.exe")
end
end
end