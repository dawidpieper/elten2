# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

if FileTest.exist?("bin\\bass.dll")
  $dlldir = ".\\bin"
elsif FileTest.exist?("..\\bin\\bass.dll")
  $dlldir = "..\\bin"
elsif FileTest.exist?("..\\..\\bass.dll")
  $dlldir = "..\\..\\bin"
end

$kernel32 = Fiddle.dlopen("kernel32.dll")
$setcurrentdirectory = Fiddle::Function.new($kernel32["SetCurrentDirectory"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$setdlldirectory = Fiddle::Function.new($kernel32["SetDllDirectory"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$multibytetowidechar = Fiddle::Function.new($kernel32["MultiByteToWideChar"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$widechartomultibyte = Fiddle::Function.new($kernel32["WideCharToMultiByte"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$getprivateprofilestring = Fiddle::Function.new($kernel32["GetPrivateProfileStringW"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$writeprivateprofilestring = Fiddle::Function.new($kernel32["WritePrivateProfileStringW"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$createprocess = Fiddle::Function.new($kernel32["CreateProcess"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$openprocess = Fiddle::Function.new($kernel32["OpenProcess"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$getexitcodeprocess = Fiddle::Function.new($kernel32["GetExitCodeProcess"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$rtlmovememory = Fiddle::Function.new($kernel32["RtlMoveMemory"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$localfree = Fiddle::Function.new($kernel32["LocalFree"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$closehandle = Fiddle::Function.new($kernel32["CloseHandle"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)

$user32 = Fiddle.dlopen("user32")
$messagebox = Fiddle::Function.new($user32["MessageBox"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$showwindow = Fiddle::Function.new($user32["ShowWindow"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$setactivewindow = Fiddle::Function.new($user32["SetActiveWindow"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$setforegroundwindow = Fiddle::Function.new($user32["SetForegroundWindow"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$setfocus = Fiddle::Function.new($user32["SetFocus"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$getforegroundwindow = Fiddle::Function.new($user32["GetForegroundWindow"], [], Fiddle::TYPE_INT)
$getparent = Fiddle::Function.new($user32["GetParent"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$iswindow = Fiddle::Function.new($user32["IsWindow"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$findwindow = Fiddle::Function.new($user32["FindWindow"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$getasynckeystate = Fiddle::Function.new($user32["GetAsyncKeyState"], [Fiddle::TYPE_INT], Fiddle::TYPE_SHORT)
$getkeyboardstate = Fiddle::Function.new($user32["GetKeyboardState"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$shell32 = Fiddle.dlopen("shell32")
$shgetfolderpath = Fiddle::Function.new($shell32["SHGetFolderPathW"], [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$extracticon = Fiddle::Function.new($shell32["ExtractIcon"], [Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$shell_notifyicon = Fiddle::Function.new($shell32["Shell_NotifyIcon"], [Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$msvcrt = Fiddle.dlopen("msvcrt")
$strcpy = Fiddle::Function.new($msvcrt["strcpy"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$wcscpy = Fiddle::Function.new($msvcrt["wcscpy"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$wcslen = Fiddle::Function.new($msvcrt["wcslen"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$crypt32 = Fiddle.dlopen("crypt32")
$cryptprotectdata = Fiddle::Function.new($crypt32["CryptProtectData"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$cryptunprotectdata = Fiddle::Function.new($crypt32["CryptUnprotectData"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$setdlldirectory.call($dlldir)

begin
  begin
    $eltenvc = Fiddle.dlopen("eltenvc")
  rescue Exception
    $eltenvc = Fiddle.dlopen("elten")
  end
  $cryptmessage = Fiddle::Function.new($eltenvc["CryptMessage"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
rescue Exception
end

$eltenvc = Fiddle.dlopen("eltenvc")
$showtray = Fiddle::Function.new($eltenvc["showTray"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$hidetray = Fiddle::Function.new($eltenvc["hideTray"], [], Fiddle::TYPE_VOID)
$sapisaystring = Fiddle::Function.new($eltenvc["SapiSpeak"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$sapispeakssml = Fiddle::Function.new($eltenvc["SapiSpeakSSML"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$sapistopspeech = Fiddle::Function.new($eltenvc["SapiStop"], [], Fiddle::TYPE_INT)
$sapisetvolume = Fiddle::Function.new($eltenvc["SapiSetVolume"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetrate = Fiddle::Function.new($eltenvc["SapiSetRate"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetvoice = Fiddle::Function.new($eltenvc["SapiSetVoice"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapigetvolume = Fiddle::Function.new($eltenvc["SapiGetVolume"], [], Fiddle::TYPE_INT)
$sapigetrate = Fiddle::Function.new($eltenvc["SapiGetRate"], [], Fiddle::TYPE_INT)
$sapigetvoice = Fiddle::Function.new($eltenvc["SapiGetVoice"], [], Fiddle::TYPE_INT)
$sapiisspeaking = Fiddle::Function.new($eltenvc["SapiIsSpeaking"], [], Fiddle::TYPE_INT)
$sapilistvoices = Fiddle::Function.new($eltenvc["SapiListVoices"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapifreevoices = Fiddle::Function.new($eltenvc["SapiFreeVoices"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapilistdevices = Fiddle::Function.new($eltenvc["SapiListDevices"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapifreedevices = Fiddle::Function.new($eltenvc["SapiFreeDevices"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$sapisetdevice = Fiddle::Function.new($eltenvc["SapiSetDevice"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$vorbisrecorderinit = Fiddle::Function.new($eltenvc["VorbisRecorderInit"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$vorbisrecorderclose = Fiddle::Function.new($eltenvc["VorbisRecorderClose"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$vorbisrecordproc = Fiddle::Function.new($eltenvc["_VorbisRecordProc@16"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$opusrecorderinit = Fiddle::Function.new($eltenvc["OpusRecorderInit"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$opusrecorderclose = Fiddle::Function.new($eltenvc["OpusRecorderClose"], [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$opusrecordproc = Fiddle::Function.new($eltenvc["_OpusRecordProc@16"], [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$showmessager = Fiddle::Function.new($eltenvc["showMessager"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$hidemessager = Fiddle::Function.new($eltenvc["hideMessager"], [], Fiddle::TYPE_VOID)
$getmessager = Fiddle::Function.new($eltenvc["getMessager"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$showwriter = Fiddle::Function.new($eltenvc["showWriter"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$hidewriter = Fiddle::Function.new($eltenvc["hideWriter"], [], Fiddle::TYPE_VOID)
$getwriter = Fiddle::Function.new($eltenvc["getWriter"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$createemptywindow = Fiddle::Function.new($eltenvc["createEmptyWindow"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$destroyemptywindow = Fiddle::Function.new($eltenvc["destroyEmptyWindow"], [], Fiddle::TYPE_VOID)
$showemptywindow = Fiddle::Function.new($eltenvc["showEmptyWindow"], [], Fiddle::TYPE_VOID)
$hideemptywindow = Fiddle::Function.new($eltenvc["hideEmptyWindow"], [], Fiddle::TYPE_VOID)
$updateemptywindow = Fiddle::Function.new($eltenvc["updateEmptyWindow"], [], Fiddle::TYPE_VOID)
$getemptywindow = Fiddle::Function.new($eltenvc["getEmptyWindow"], [], Fiddle::TYPE_INT)
$showfileopen = Fiddle::Function.new($eltenvc["showFileOpen"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$hidefileopen = Fiddle::Function.new($eltenvc["hideFileOpen"], [], Fiddle::TYPE_VOID)
$getfileopen = Fiddle::Function.new($eltenvc["getFileOpen"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$inithk = Fiddle::Function.new($eltenvc["initHK"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$destroyhk = Fiddle::Function.new($eltenvc["destroyHK"], [], Fiddle::TYPE_VOID)
$gethk = Fiddle::Function.new($eltenvc["getHK"], [], Fiddle::TYPE_INT)
$f32letos16le = Fiddle::Function.new($eltenvc["F32LEToS16LE"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$s16letof32le = Fiddle::Function.new($eltenvc["S16LEToF32LE"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)

$nvdahelperremote = Fiddle.dlopen("nvdaHelperRemote")
$saystring = Fiddle::Function.new($nvdahelperremote["nvdaController_speakText"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$stopspeech = Fiddle::Function.new($nvdahelperremote["nvdaController_cancelSpeech"], [], Fiddle::TYPE_INT)

$ogg = Fiddle.dlopen("ogg")
$ogg_stream_init = Fiddle::Function.new($ogg["ogg_stream_init"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
$ogg_stream_packetin = Fiddle::Function.new($ogg["ogg_stream_packetin"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$ogg_stream_pageout = Fiddle::Function.new($ogg["ogg_stream_pageout"], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
$ogg_stream_clear = Fiddle::Function.new($ogg["ogg_stream_clear"], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_INT)
