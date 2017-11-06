# encoding: utf-8
$stdout.reopen("_stdout.txt","w")
$stderr.reopen("_stderr.txt","w")
puts("Initializing Ruby...")
$ruby=true
puts("Detected Ruby Version: #{RUBY_VERSION}")
puts("Detected platform: #{RUBY_PLATFORM}")
puts("Load PATH: #{$LOAD_PATH}")
puts("Initializing Win32 Libraries...")
if defined?(eimp)!=nil
puts("Ruby Elten Launcher Functions Found.")
puts("Loading Encodings DataBase...")
require("encdb.so")
puts("Loading fiddle...")
eimp("fiddle")
puts("Loading WinSock...")
eimp("socket")
else
puts("Cannot find predefined Elten Launcher functions, generating...")
puts("Requiring Zlib...")
require("zlib")
puts("Loading fiddle...")
require("fiddle")
require("win32api")
puts("Loading WinSock...")
require("socket")
puts("Loading Encodings DataBase...")
require("enc/encdb")
end
puts("Testing encodings...")
puts("Found encodings: #{Encoding.name_list.join(", ")}.")
puts("Testing UTF8...")
begin
puts("UTF8 support found...")
rescue Exception
puts("Warning, UTF8 support not found.")
end
puts("Registering exceptions...")
class Hangup < Exception
end
class String
def include(str)
include?(str)
end
end
puts("Registering EltenAPI Wrapper Functions...")
def load_data(file)
fp=File.open(file,"rb")
r=Marshal.load(fp)
fp.close
return r
end
class Grph
attr_accessor :frame_rate
def initialize
@frame_rate=40
end
def transition(t=1)
sleep(t*0.025)
end
def update
end
end
Graphics=Grph.new
puts("Initializing Windows API Functions...")
MessageBox = Win32API.new("user32", "MessageBox", "ippi", "i")
def msg_box(title, text)
MessageBox.call(0, text.to_s, title.to_s, 0)
end
Win32API.new("user32", "ShowWindow", "li", "i").call(Win32API.new("kernel32", "GetConsoleWindow", 'l', 'l').call(0),0)
WS_OVERLAPPEDWINDOW = 0xcf0000
WS_CAPTION=0xC00000
WS_VISIBLE = 0x10000000
IDI_APPLICATION = 32512
SW_HIDE = 0
SW_NORMAL = 1
IDC_ARROW = 32512
COLOR_WINDOW = 5
GetLastError = Win32API.new("kernel32", "GetLastError", nil, "i")
GetProcAddress = Win32API.new("kernel32", "GetProcAddress", "lp", "l")
GetModuleHandle = Win32API.new("kernel32", "GetModuleHandle", "l", "l")
GetModuleHandleByName = Win32API.new("kernel32", "GetModuleHandle", "p", "l")
LoadLibrary = Win32API.new("kernel32", "LoadLibrary", "p", "l")
RegisterClass = Win32API.new("user32", "RegisterClass", "p", "i")
FreeLibrary = Win32API.new("kernel32", "FreeLibrary", "l", "i")
CreateWindowEx = Win32API.new("user32", "CreateWindowEx", "lppliiiillll", "l")
GetMessage = Win32API.new("user32", "GetMessage","plll", "i")
DispatchMessage = Win32API.new("user32", "DispatchMessage", "p", "i")
def windowcreate(title="ELTEN      ")
classname = "eltenwc"
hInstance = GetModuleHandle.call 0
hDll = LoadLibrary.call "user32.dll"
Win32API.new("user32", "UnregisterClass", "pl", "i").call(classname, hInstance)
ar_DefWindowProc = GetProcAddress.call hDll, "DefWindowProcW"
wc = [0, ar_DefWindowProc, 0, 0, hInstance, Win32API.new("user32", "LoadIcon", "ll", "l").call(hInstance, IDI_APPLICATION), Win32API.new("user32", "LoadCursor", "ll", "l").call(hInstance, IDC_ARROW), COLOR_WINDOW + 1, 0, classname].pack("lllllllllp")
puts("Registering Window Class...")
if RegisterClass.call(wc) == 0
raise "Elten Agent fail to register window class, Error code:#{GetLastError.call}"
return 0
end
puts("Creating App Window...")
hWnd = CreateWindowEx.call(0, classname, title, WS_VISIBLE | WS_CAPTION, 0x80000000, 0x80000000, 640, 480, 0, 0, hInstance, 0)
puts("Main Window Created, HWND="+hWnd.to_s+".")
Win32API.new("user32", "ShowWindow", "li", "i").call hWnd, SW_NORMAL
if hWnd == 0
msg_box("Error!", "Elten Agent failed to CreateWindow")
return 0
end
return hWnd
end
begin
Thread.new do
puts("Initializing window...")
hWnd=windowcreate
$wnd=hWnd
puts("Initializing Window Messages Processing...")
msg = "0"*24
while GetMessage.call(msg, 0, 0, 0)
DispatchMessage.call(msg)
hwnd, message, wparam, lparam, time, pt = msg.unpack('lllll')
if hwnd!=Win32API.new("user32","GetActiveWindow",'','i').call
$windowminimized=true
else
$windowminimized=false
end

end
end
pth=""
puts("Looking for Elten Binaries...")
if FileTest.exists?("elten.exe") and FileTest.exists?("Data")
pth="."
else
def getdirectory(type)
  dr = "\0" * 1024
  Win32API.new("shell32","SHGetFolderPath",'iiiip','i').call(0,type,0,0,dr)
  dr.delete!("\0")
  fdr=futf8(dr)
    return fdr
  end
def futf8(text)
            mw = Win32API.new("kernel32", "MultiByteToWideChar", "ilpipi", "i")
    wm = Win32API.new("kernel32", "WideCharToMultiByte", "ilpipipp", "i")
    len = mw.call(0, 0, text, -1, nil, 0)
    buf = "\0" * (len*2)
    mw.call(0, 0, text, -1, buf, buf.size/2)
    len = wm.call(65001, 0, buf, -1, nil, 0, nil, nil)
    ret = "\0" * len
    wm.call(65001, 0, buf, -1, ret, ret.size, nil, nil)
    for i in 0..ret.size - 1
      ret[i..i] = "\0" if ret[i] == 0
    end
    ret.delete!("\0")
    return ret
  end
pth=getdirectory(26)+"\\elten\\bin\\elten"
end
puts("Looking in #{pth}.")
if FileTest.exists?(pth+"\\elten.exe")==false
raise("No Elten binaries found.")
end
def utf8(text,cp=65001)
      text = "" if text == nil or text == false
ext = "\0" if text == nil
to_char = Win32API.new("kernel32", "MultiByteToWideChar", 'ilpipi', 'i') 
to_byte = Win32API.new("kernel32", "WideCharToMultiByte", 'ilpipipp', 'i')
utf8 = cp
w = to_char.call(utf8, 0, text.to_s, text.bytesize, nil, 0)
b = "\0" * (w*2)
w = to_char.call(utf8, 0, text.to_s, text.bytesize, b, b.bytesize/2)
w = to_byte.call(0, 0, b, b.bytesize/2, nil, 0, nil, nil)
b2 = "\0" * w
w = to_byte.call(0, 0, b, b.bytesize/2, b2, b2.bytesize, nil, nil)
b2.delete!("\0") if $ruby != true
  return(b2)
end
puts("Loading Elten Binaries...")
Win32API.new("kernel32","SetDllDirectory",'p','i').call(utf8(pth))
Win32API.new("kernel32","SetCurrentDirectory",'p','i').call(utf8(pth))
puts("Loading data...")
fp = File.open("Data/elten.edb","r")
core = Marshal.load(fp)
fp.close
puts("#{core.size} modules found...")
puts("Loading Elten...")
for scr in core
puts("Loading #{scr[1]}...")
eval("# encoding: utf-8\r\n"+Zlib::inflate(scr[2]),nil,scr[1])
end
puts("Elten core code imported succesfully...")
puts("Unregistering window class...")
hInstance = GetModuleHandle.call 0
Win32API.new("user32", "UnregisterClass", "pl", "i").call("eltenwc", hInstance)
puts("Elten Exited with ExitCode 0.")
end