# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

if FileTest.exists?("bin\\bass.dll")
$dlldir=".\\bin"
elsif FileTest.exists?("..\\bin\\bass.dll")
$dlldir="..\\bin"
elsif FileTest.exists?("..\\..\\bass.dll")
$dlldir="..\\..\\bin"
end

$kernel32 = Fiddle.dlopen('kernel32.dll')
$setcurrentdirectory = Fiddle::Function.new($kernel32['SetCurrentDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$setdlldirectory = Fiddle::Function.new($kernel32['SetDllDirectory'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$multibytetowidechar = Fiddle::Function.new($kernel32['MultiByteToWideChar'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$widechartomultibyte = Fiddle::Function.new($kernel32['WideCharToMultiByte'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$getprivateprofilestring = Fiddle::Function.new($kernel32['GetPrivateProfileStringW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$writeprivateprofilestring = Fiddle::Function.new($kernel32['WritePrivateProfileStringW'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$createprocess = Fiddle::Function.new($kernel32['CreateProcess'], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, ], Fiddle::TYPE_INT)
$rtlmovememory = Fiddle::Function.new($kernel32['RtlMoveMemory'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$localfree = Fiddle::Function.new($kernel32['LocalFree'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)

$user32 = Fiddle.dlopen("user32")
$messagebox = Fiddle::Function.new($user32['MessageBox'], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$showwindow = Fiddle::Function.new($user32['ShowWindow'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$setactivewindow = Fiddle::Function.new($user32['SetActiveWindow'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$setforegroundwindow = Fiddle::Function.new($user32['SetForegroundWindow'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$setfocus = Fiddle::Function.new($user32['SetFocus'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$getforegroundwindow = Fiddle::Function.new($user32['GetForegroundWindow'], [], Fiddle::TYPE_INT)
$getparent = Fiddle::Function.new($user32['GetParent'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$iswindow = Fiddle::Function.new($user32['IsWindow'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$findwindow = Fiddle::Function.new($user32['FindWindow'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$getasynckeystate = Fiddle::Function.new($user32['GetAsyncKeyState'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)

$shell32 = Fiddle.dlopen("shell32")
$shgetfolderpath = Fiddle::Function.new($shell32['SHGetFolderPathW'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$extracticon = Fiddle::Function.new($shell32['ExtractIcon'], [Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$shell_notifyicon = Fiddle::Function.new($shell32['Shell_NotifyIcon'], [Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$msvcrt=Fiddle.dlopen("msvcrt")
$strcpy = Fiddle::Function.new($msvcrt['strcpy'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$wcscpy = Fiddle::Function.new($msvcrt['wcscpy'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$wcslen = Fiddle::Function.new($msvcrt['wcslen'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$crypt32 = Fiddle.dlopen("crypt32")
$cryptprotectdata = Fiddle::Function.new($crypt32['CryptProtectData'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$cryptunprotectdata = Fiddle::Function.new($crypt32['CryptUnprotectData'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

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

$eltenvc=Fiddle.dlopen("..\\eltenvc")
$showtray = Fiddle::Function.new($eltenvc['showTray'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$hidetray = Fiddle::Function.new($eltenvc['hideTray'], [], Fiddle::TYPE_VOID)
$sapisaystring = Fiddle::Function.new($eltenvc['SapiSpeak'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$sapispeakssml = Fiddle::Function.new($eltenvc['SapiSpeakSSML'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$sapistopspeech = Fiddle::Function.new($eltenvc['SapiStop'], [], Fiddle::TYPE_INT)
$sapisetvolume = Fiddle::Function.new($eltenvc['SapiSetVolume'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetrate = Fiddle::Function.new($eltenvc['SapiSetRate'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetvoice = Fiddle::Function.new($eltenvc['SapiSetVoice'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapigetvolume = Fiddle::Function.new($eltenvc['SapiGetVolume'], [], Fiddle::TYPE_INT)
$sapigetrate = Fiddle::Function.new($eltenvc['SapiGetRate'], [], Fiddle::TYPE_INT)
$sapigetvoice = Fiddle::Function.new($eltenvc['SapiGetVoice'], [], Fiddle::TYPE_INT)
$sapiisspeaking = Fiddle::Function.new($eltenvc['SapiIsSpeaking'], [], Fiddle::TYPE_INT)
$sapilistvoices = Fiddle::Function.new($eltenvc['SapiListVoices'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapifreevoices = Fiddle::Function.new($eltenvc['SapiFreeVoices'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapilistdevices = Fiddle::Function.new($eltenvc['SapiListDevices'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapifreedevices = Fiddle::Function.new($eltenvc['SapiFreeDevices'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetdevice = Fiddle::Function.new($eltenvc['SapiSetDevice'], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)

$nvdahelperremote=Fiddle.dlopen("nvdaHelperRemote")
$saystring = Fiddle::Function.new($nvdahelperremote['nvdaController_speakText'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$stopspeech = Fiddle::Function.new($nvdahelperremote['nvdaController_cancelSpeech'], [], Fiddle::TYPE_INT)