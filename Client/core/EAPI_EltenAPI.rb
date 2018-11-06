#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

# EltenAPI functions
module EltenAPI

  def unicode(str)
    buf="\0"*Win32API.new("kernel32","MultiByteToWideChar",'iipipi','i').call(65001,0,str,str.bytesize,nil,0)*2
Win32API.new("kernel32","MultiByteToWideChar",'iipipi','i').call(65001,0,str,str.size,buf,buf.bytesize/2)
return buf    <<"\0"
end
  
  def deunicode(str)
    buf="\0"*Win32API.new("kernel32","WideCharToMultiByte",'iipipi','i').call(65001,0,str,str.bytesize,nil,0)
Win32API.new("kernel32","WideCharToMultiByte",'iipipi','i').call(65001,0,str,str.bytesize,buf,buf.bytesize/2)
buf=buf<<0
buf.delete!("\0")
return buf
end

  # Converts a text from UTF8 to CP852
  #
  # @param text [String] a text to convert
  # @return [String] a converted text
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

  # Converts a text from CP852 to UTF8
  #
  # @param text [String] a text to convert
  # @return [String] a converted text
def utf8(text)
    text = "" if text == nil or text == false
ext = "\0" if text == nil
to_char = Win32API.new("kernel32", "MultiByteToWideChar", 'ilpipi', 'i') 
to_byte = Win32API.new("kernel32", "WideCharToMultiByte", 'ilpipipp', 'i')
w = to_char.call(65001, 0, text.to_s, text.bytesize, nil, 0)
b = "\0" * w*2
w = to_char.call(65001, 0, text.to_s, text.bytesize, b, b.bytesize/2)
w = to_byte.call(0, 0, b, b.bytesize, nil, 0, nil, nil)
b2 = "\0" * w
w = to_byte.call(0, 0, b, b.bytesize/2, b2, b2.bytesize, nil, nil)
  return(b2).delete("\0")
end

# Returns an ASCII character of a specified code
#
# @param code [Numeric] an ASCII code
# @return [String] an ASCII character of specified code
def ASCII(code)
  r="\0"
  r[0]=code.to_i
  return r
end

# @note this function is reserved.
def crypt(msg)
  cipher = Cipher.new ar = ["K","D","w","H","X","3","e","1","S","B","g","a","y","v","I","6","u","W","C","0","9","b","z","T","A","q","U","4","O","o","E","N","r","n","m","d","k","x","P","t","R","s","J","L","f","h","Z","j","Y","5","7","l","p","c","2","8","M","V","G","i"," ","Q","F","?",">","<","\"",":","/",".",",","'",":","[","]","{","}","-","=","_","+","\\","|","@","\#","!","`","$","^","\%","\&","*",")","(","\001","\002","\003","\004","\005","\006","\007","\008","\009","\0"]
crypted = cipher.encrypt msg
return(crypted)
end

# @note this function is reserved.
def decrypt(msg)
 cipher = Cipher.new ar = ["K","D","w","H","X","3","e","1","S","B","g","a","y","v","I","6","u","W","C","0","9","b","z","T","A","q","U","4","O","o","E","N","r","n","m","d","k","x","P","t","R","s","J","L","f","h","Z","j","Y","5","7","l","p","c","2","8","M","V","G","i"," ","Q","F","?",">","<","\"",":","/",".",",","'",":","[","]","{","}","-","=","_","+","\\","|","@","\#","!","`","$","^","\%","\&","*",")","(","\001","\002","\003","\004","\005","\006","\007","\008","\009","\0"]
decrypted = cipher.decrypt msg
return(decrypted)
end

# @note this function is reserved.
def exceptionlist
  errors=""
exceptions = []
tree = {}
ObjectSpace.each_object(Class) do |cls|
  next unless cls.ancestors.include? Exception
  next if exceptions.include? cls
  next if cls.superclass == SystemCallError # avoid dumping Errno's
  exceptions << cls
  cls.ancestors.delete_if {|e| [Object, Kernel].include? e }.reverse.inject(tree) {|memo,cls| memo[cls] ||= {}}
end
indent = 0
tree_printer = Proc.new do |t|
  t.keys.sort { |c1,c2| c1.name <=> c2.name }.each do |k|
    space = (' ' * indent); space ||= ''
    errors += space + k.to_s + "\r\n"
    indent += 2; tree_printer.call t[k]; indent -= 2
  end
end
tree_printer.call tree
p tree
end

# Reads a file and returns it as an array of lines
#
# @param file [String] a file name or path
# @return [Array] an array of lines
  def readlines(file)
    createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(file,1,1|2|4,nil,4,0,0)
if handler < 64
  speech(_("General:error"))
  speech_wait
  end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
sz = "\0"*8
Win32API.new("kernel32","GetFileSizeEx",'ip','l').call(handler,sz)
size = sz.unpack("L")[0]
b = "\0" * size
bp = "\0" * size
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
r = []
c = 0
r[c] = ""
for i in 0..b.size - 1
  b = b.sub("\004LINE\004","\n")
  end
b.delete("\r")
  lin=b.split("\n")
  for i in 0..lin.size-1
  lin[i]+="\r\n"
  end
return lin
end

# Writes a specified text to a file
#
# @param file [String] a file name or path
# @param text [String] a text to write
# @param utf [Boolean] encode in UTF8
# @return [Numeric] a number of written characters
def writefile(file,text,utf=false)
  if text.is_a?(Array)
    t = ""
    for i in text
      t += i + "\r\n"
    end
    text = t
    end
  cf = Win32API.new("kernel32","CreateFile",'piipiip','i')
handle = cf.call(utf8(file),2,1|2|4,nil,2,0,nil)
writefile = Win32API.new("kernel32","WriteFile",'ipipi','I')
bp = "\0" * text.size
text=utf8(text) if utf
r = writefile.call(handle,text,text.size,bp,0)
bp = nil
Win32API.new("kernel32","CloseHandle",'i','i').call(handle)
handle = 0
return r
end

# Runs a binary file
#
# @param file [String] a file to run
# @param hide [Boolean] if true, the new process's window is hidden
# @return [Numeric] the pid of a created process
def run(file,hide=false)
  params = 'LPLLLLLPPP'
createprocess = Win32API.new('kernel32','CreateProcess', params, 'I')
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,0x100,0,0,0,0,0,0]
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,1|0x100,0,0,0,0,0,0] if hide
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
        pr = createprocess.call(0, utf8(file), 0, 0, 0, 0, 0, ".", startinfo, procinfo)
            procinfo[0,4].unpack('L').first # pid
            $procs=[] if $procs==nil
            $procs.push(procinfo.unpack('llll')[0])
            return procinfo.unpack('llll')[0]
          end
        
          # Executes a process and waits for it to close
          #
          # @param cmdline [String] a command line to execute
          # @param hidewindow [Boolean] hide a process window
          # @param tmax [Numeric] maximum execution time, 0 = Infinity
          def executeprocess(cmdline,hide=false,tmax=0,update=true)
            h=run(cmdline,hide)
                  t = 0
            loop do
        if update
              loop_update
            else
              sleep(0.1)
              end
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
if x != "\003\001"
  break
  end
t += 10.0/Graphics.frame_rate
if t > tmax and tmax!=0
    return -1
  break
end
end
x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
return x
            end
          
          # @deprecated this class is deprecated.
          class IOT
    def self.readlines(file)
    createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(file,1,1|2|4,nil,4,0,0)
if handler < 64
  speech(_("General:error"))
  speech_wait
  end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
b = "\0" * 1048576
bp = "\0" * 1048576
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
b.delete!("\0")
bp.delete!("\0")
r = []
c = 0
r[c] = ""
for i in 0..b.size - 1
  b = b.sub("\004LINE\004","\n")
  end
for i in 0..b.size - 1
  r[c] += b[i..i]
  if b[i..i] == "\n"
    c += 1
    r[c] = ""
    end
  end
return(r.to_s)
end
end

# Reads a file
#
# @param file [String] a file to read
# @return [String] a file text
  def read(file,sizeonly=false,reencode=false)
        createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(utf8(file),1,1|2|4,nil,4,0,0)
if handler < 64
  speech(_("General:error"))
  speech_wait
  end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
file
sz = "\0"*8
Win32API.new("kernel32","GetFileSizeEx",'ip','l').call(handler,sz)
size = sz.unpack("L")[0]
if sizeonly
  Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
  return size
  end
b = "\0" * (size.to_i)
bp = "\0" * (size.to_i)
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
bp.delete!("\0") if $ruby != true
b=fixencoding(b) if reencode==true
return b
end

      def fixencoding(text)
        text=futf8(text) if futf8(text).size>text.size and futf8(text).split("").size==text.split("").size
        return text
        end

# Wait for a specified time
#
# @param time [Float] a time to delay, in seconds
def delay(time=0)
  if time == 0
    if $ruby != true
  sec = Graphics.frame_rate
else
  sec=0.025
  end
  for i in 1..sec.to_f*0.75
    Graphics.update
    break if Win32API.new("user32","GetAsyncKeyState",'i','i').call(0xd) == 0 and Win32API.new("user32","GetAsyncKeyState",'i','i').call(0x20) == 0 and i > 10
  end
  for i in 1..255
    $keyms[i] = 70
    $key[i] = false
    end
  else
  for i in 1..Graphics.frame_rate*time
    loop_update
    end
  end
end

# Reads an ini value
#
# @param file [String] a file to read
# @param group [String] an INI group
# @param key [String] an INI key
# @param default [String] this string will be returned if the specified key or file doesn't exist
# @return [String] the ini value of a specified key
            def readini(file,group,key,default="\0")
        default = default.to_s if default.is_a?(Integer)
        r = "\0" * 16384
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call(group,key,default,r,r.size,utf8(file))
    r.delete!("\0")
    return futf8(r.to_s    )
  end
  
  # Writes a specified value to an INI file
  #
  # @param file [String] a file to write
  # @param group [String] an INI group to write
  # @param key [String] an INI key to write
  # @param value [String] a value to write
  def writeini(file,group,key,value)
    if value != nil
    iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call(group,key,utf8(value.to_s),utf8(file))
              else
                iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call(group,key,nil,utf8(file))
                end
              end
              
              # @deprecated use {#split} insted
              def strbyline(str)
  byline = []
  index = 0
  byline[index] = ""
  for i in 0..str.size - 1
    if str[i..i] != "\n" and str[i..i] != "\r"
    byline[index] += str[i..i]
  elsif str[i..i] == "\n"
    index += 1
    byline[index] = ""
    end
  end
  return byline
end

# @deprecated use {#read} instead.
def readfile(file,maxsize=1048576)
createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(utf8(file),1,1|2|4,nil,4,0,0)
if handler < 64
raise(RuntimeError)
end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
b = "\0" * maxsize
bp = "\0" * maxsize
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
b.rdelete!("\0")
bp.delete!("\0")
return b
end

# Calls a SHGetFilePath from shell32 library
#
# @param type [Numeric] a directory id
# @return [String] directory path
def getdirectory(type)
  dr = "\0" * 2048
  Win32API.new("shell32","SHGetFolderPath",'iiiip','i').call(0,type,0,0,dr)
  dr.delete!("\0")
  fdr=futf8(dr)
      return fdr
  end
  
  # @note this function is reserved
def preproc(string,dir=".")
  cdc = strbyline(string)
for i in 0..cdc.size - 1
  if cdc[i].size > 0
    if cdc[i][0..8] == "#include "
      fl = cdc[i][9..cdc[i].size-1].delete("\r\n")
      if FileTest.exists?(fl) or FileTest.exists?(dir+"/"+fl)
        a = IO.readlines(fl) if FileTest.exists?(fl)
        a = IO.readlines(dir+"/"+fl) if FileTest.exists?(dir+"/"+fl)
        b = ""
        for j in 0..a.size-1
          b += a[j]
          end
        c = preproc(b,dir)
                cdc[i] = c
        end
      end
    if cdc[i][0..0] == "*"
    s = ""
    a = 0
    for j in 1..cdc[i].size-1
      s += cdc[i][j..j] if cdc[i][j..j] != " "
      a += 1
      break if cdc[i][j..j] == " "
          end
    if eval("defined?(#{s})") != nil
      prm = ""
      for j in a+1..cdc[i].size-1
        prm += cdc[i][j..j]
      end
      prm.gsub!("\"","\\\"")
      cdc[i] = "#{s}(\"#{prm}\")"
      end
    end
  end
  end
    r = ""
for i in 0..cdc.size - 1
    r += cdc[i] + "\r\n"
end
return r
  end

  # evaluates a code
  #
  # @param string [String] a code to eval
  # @return [Object] a return value of the code
  def codeeval(string , binding , filename ,lineno)  
  eval(string , binding , filename ,lineno)
end


  include UI
  include UI::Keyboard
  include Speech
  include Controls
  include Network
  include EltenSRV
  include Common
  include External
  include Dictionary
end
class Reset < Exception
end
class OClipboard
  def self.text
    futf8(Win32API.new($eltenlib,"PasteFromClipboard",'','p').call)
  end
  def self.text=(txt)
    Win32API.new($eltenlib,"CopyToClipboard",'pi','i').call(utf8(txt),utf8(txt).size+1)
    return txt
        end
  end
if $ruby == true
  module Input
          attr_reader :A
      attr_reader :B
      attr_reader :C
      attr_reader :UP
      attr_reader :DOWN
      attr_reader :LEFT
      attr_reader :RIGHT
      attr_reader :CTRL
              LEFT=0x25
        UP=0x26
        RIGHT=0x27
        DOWN=0x28
        class <<self      
        if $ruby==true
          def update
          end
          end
          def trigger?(x)
        return $key[x]
      end
      def repeat?(x)
        return $key[x]                
        k=$keyr[x]
        k=false if $keyms[x]<50
        k=true if $key[x]
        return k
        end
      end
      

    end
  end
#Copyright (C) 2014-2018 Dawid Pieper