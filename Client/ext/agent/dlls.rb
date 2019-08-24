if FileTest.exists?("screenreaderapi.dll") and FileTest.exists?("bass.dll")
$dlldir="."
elsif FileTest.exists?("..\\screenreaderapi.dll") and FileTest.exists?("..\\bass.dll")
$dlldir=".."
elsif FileTest.exists?("..\\..\\screenreaderapi.dll") and FileTest.exists?("..\\..\\bass.dll")
$dlldir="..\\.."
end

$kernel32 = Fiddle.dlopen('kernel32.dll')
$setcurrentdirectory = Fiddle::Function.new($kernel32['SetCurrentDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$setdlldirectory = Fiddle::Function.new($kernel32['SetDllDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$multibytetowidechar = Fiddle::Function.new($kernel32['MultiByteToWideChar'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$widechartomultibyte = Fiddle::Function.new($kernel32['WideCharToMultiByte'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$getprivateprofilestring = Fiddle::Function.new($kernel32['GetPrivateProfileStringW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$writeprivateprofilestring = Fiddle::Function.new($kernel32['WritePrivateProfileStringW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$createprocess = Fiddle::Function.new($kernel32['CreateProcess'], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, ], Fiddle::TYPE_INT)

$user32 = Fiddle.dlopen("user32")
$showwindow = Fiddle::Function.new($user32['ShowWindow'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$getforegroundwindow = Fiddle::Function.new($user32['GetForegroundWindow'], [], Fiddle::TYPE_INT)
$getparent = Fiddle::Function.new($user32['GetParent'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$iswindow = Fiddle::Function.new($user32['IsWindow'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$findwindow = Fiddle::Function.new($user32['FindWindow'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$getasynckeystate = Fiddle::Function.new($user32['GetAsyncKeyState'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)

$shell32 = Fiddle.dlopen("shell32")
$shgetfolderpath = Fiddle::Function.new($shell32['SHGetFolderPathW'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$setdlldirectory.call($dlldir)

begin
begin
$eltenvc=Fiddle.dlopen("eltenvc")
rescue Exception
$eltenvc=Fiddle.dlopen("elten")
end
$cryptmessage = Fiddle::Function.new($eltenvc['CryptMessage'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
rescue Exception
end

$screenreaderapi=Fiddle.dlopen("screenreaderapi")
$saystring = Fiddle::Function.new($screenreaderapi['sayStringW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisaystring = Fiddle::Function.new($screenreaderapi['sapiSayStringW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$stopspeech = Fiddle::Function.new($screenreaderapi['stopSpeech'], [], Fiddle::TYPE_INT)
$sapistopspeech = Fiddle::Function.new($screenreaderapi['sapiStopSpeech'], [], Fiddle::TYPE_INT)
$sapisetvolume = Fiddle::Function.new($screenreaderapi['sapiSetVolume'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetrate = Fiddle::Function.new($screenreaderapi['sapiSetRate'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetvoice = Fiddle::Function.new($screenreaderapi['sapiSetVoice'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapigetvolume = Fiddle::Function.new($screenreaderapi['sapiGetVolume'], [], Fiddle::TYPE_INT)
$sapigetrate = Fiddle::Function.new($screenreaderapi['sapiGetRate'], [], Fiddle::TYPE_INT)
$sapigetvoice = Fiddle::Function.new($screenreaderapi['sapiGetVoice'], [], Fiddle::TYPE_INT)
$sapiisspeaking = Fiddle::Function.new($screenreaderapi['sapiIsSpeaking'], [], Fiddle::TYPE_INT)
