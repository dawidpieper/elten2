#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

# EltenAPI functions
module EltenAPI

  def unicode(str)
    buf="\0"*Win32API.new("kernel32","MultiByteToWideChar",'iipipi','i').call(65001,0,str,str.bytesize,nil,0)*2
Win32API.new("kernel32","MultiByteToWideChar",'iipipi','i').call(65001,0,str,str.size,buf,buf.bytesize/2)
return buf<<0
end
  
  def deunicode(str,nulled=false)
                    str.chop! if str[-1..-1]=="\0" and (str.bytesize.to_i/2!=str.bytesize.to_f/2.0)
        str<<"\0\0" if nulled and str[-2..-1]!="\0\0"
    sz=str.bytesize/2
    sz=-1 if nulled
                buf="\0"*Win32API.new("kernel32","WideCharToMultiByte",'iipipipp','i').call(65001,0,str,sz,nil,0,nil,nil)
                                                                Win32API.new("kernel32","WideCharToMultiByte",'iipipipp','i').call(65001,0,str,sz,buf,buf.size,nil,nil)
                                                                    return buf[0..(buf.index("\0")||0)-1]
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
def oldcrypt(msg)
  cipher = Cipher.new ar = ["K","D","w","H","X","3","e","1","S","B","g","a","y","v","I","6","u","W","C","0","9","b","z","T","A","q","U","4","O","o","E","N","r","n","m","d","k","x","P","t","R","s","J","L","f","h","Z","j","Y","5","7","l","p","c","2","8","M","V","G","i"," ","Q","F","?",">","<","\"",":","/",".",",","'",":","[","]","{","}","-","=","_","+","\\","|","@","\#","!","`","$","^","\%","\&","*",")","(","\001","\002","\003","\004","\005","\006","\007","\008","\009","\0"]
crypted = cipher.encrypt msg
return(crypted)
end

# @note this function is reserved.
def olddecrypt(msg)
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
  cf = Win32API.new("kernel32","CreateFileW",'piipiip','i')
handle = cf.call(unicode(file),2,1|2|4,nil,2,0,nil)
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
def  run(file,hide=false,stdinrd=nil,stdinwr=nil,stdoutrd=nil,stdoutwr=nil)
  cp=Win32API.new("kernel32","CreatePipe",'pppi','i')
  shi=Win32API.new("kernel32","SetHandleInformation",'iii','i')
   if stdoutrd!=nil and stdoutwr!=nil
  cp.call(stdoutrd,stdoutwr,nil,16384)
  shi.call(stdoutrd.unpack("I")[0],1,0)
  end
   if stdinrd!=nil and stdinwr!=nil
  cp.call(stdinrd,stdinwr,nil,16384)
  shi.call(stdinrd.unpack("I")[0],1,0)
  end
    params = 'LPLLLLLPPP'
createprocess = Win32API.new('kernel32','CreateProcess', params, 'I')
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
         flags=0
                           startinfo = [0,0,0,0,0,0,0,0,0,0,0,0x100,0,0,0,(stdinrd||"").unpack("i")[0],(stdoutwr||"").unpack("I")[0],0]
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,1|0x100,0,0,0,(stdinwr||"").unpack("i")[0],(stdoutwr||"").unpack("i")[0],0] if hide
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
        pr = createprocess.call(0, utf8(file), 0, 0, 0, 0, 0, $path[0...$path.size-($path.reverse.index("\\"))], startinfo, procinfo)
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

# Reads a file
#
# @param file [String] a file to read
# @return [String] a file text
  def read(file,sizeonly=false,reencode=false)
        createfile = Win32API.new("kernel32","CreateFileW",'piipili','l')
handler = createfile.call(unicode(file),1,1|2|4,nil,4,0,0)
if handler < 64
  return nil
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
    break if !$key[0xd] and !$key[0x20] and i > 10
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

def readconfig(group, key, val="")
  r=readini($eltendata+"\\elten.ini", group, key, val.to_s)
  return r.to_i if val.is_a?(Integer)
  return r
end

def writeconfig(group, key, val)
  writeini($eltendata+"\\elten.ini", group, key, val.to_s)
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
        r="\0"*16384
            sz=Win32API.new("kernel32","GetPrivateProfileStringW",'pppplp','i').call(unicode(group),unicode(key),unicode(default),r,r.size*2,unicode(file))
            return deunicode(r[0...sz*2])
  end
  
  # Writes a specified value to an INI file
  #
  # @param file [String] a file to write
  # @param group [String] an INI group to write
  # @param key [String] an INI key to write
  # @param value [String] a value to write
  def writeini(file,group,key,value)
    value.delete!("\r\n") if value.is_a?(String)
    if value != nil
    iniw = Win32API.new('kernel32','WritePrivateProfileStringW','pppp','i')
                iniw.call(unicode(group),unicode(key),unicode(value.to_s),unicode(file))
              else
                iniw = Win32API.new('kernel32','WritePrivateProfileStringW','pppp','i')
                iniw.call(unicode(group),unicode(key),nil,unicode(file))
                end
              end

# Calls a SHGetFilePath from shell32 library
#
# @param type [Numeric] a directory id
# @return [String] directory path
def getdirectory(type)
  dr = "\0" * 1040
  Win32API.new("shell32","SHGetFolderPathW",'iiiip','i').call(0,type,0,0,dr)
    fdr=deunicode(dr)
        return fdr
  end

  # evaluates a code
  #
  # @param string [String] a code to eval
  # @return [Object] a return value of the code
  def codeeval(string , binding , filename ,lineno)  
  eval(string , binding , filename ,lineno)
end


def insert_scene(scene)
  return if ($scenes[0]!=nil and $scenes[0].is_a?(scene.class)) or $scene.is_a?(scene.class)
  if $scene.is_a?(Scene_Main) and $scenes.size==0
    return $scene=scene
    end
  $scenes.insert(0,scene)
  t=Time.now.to_f
  loop_update while Time.now.to_f-t<0.2
end

      def crypt(data,code=nil)
        pin=[data.size,data].pack("ip")
pout=[0,nil].pack("ip")
pcode=nil
pcode=[code.size,code].pack("ip") if code!=nil
Win32API.new("crypt32", "CryptProtectData", 'pppppip','i').call(pin,nil,pcode,nil,nil,0,pout)
s,t = pout.unpack("ii")
m="\0"*s
Win32API.new("kernel32","RtlMoveMemory",'pii','i').call(m,t,s)
Win32API.new("kernel32","LocalFree",'i','i').call(t)
return m
        end
        
        def decrypt(data,code=nil)
        pin=[data.size,data].pack("ip")
pout=[0,nil].pack("ip")
pcode=nil
pcode=[code.size,code].pack("ip") if code!=nil
Win32API.new("crypt32", "CryptUnprotectData", 'pppppip','i').call(pin,nil,pcode,nil,nil,0,pout)
s,t = pout.unpack("ii")
m="\0"*s
Win32API.new("kernel32","RtlMoveMemory",'pii','i').call(m,t,s)
Win32API.new("kernel32","LocalFree",'i','i').call(t)  
return m
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
      
class ChildProc
  attr_reader :pid
  def initialize(file)
@stdin_rd = "\0"*4
@stdin_wr = "\0"*4
@stdout_rd = "\0"*4
@stdout_wr = "\0"*4
saAttr=[12,nil,1].pack("ipi")
Win32API.new("kernel32","CreatePipe",'pppi','i').call(@stdout_rd, @stdout_wr, saAttr, 1048576*32)
Win32API.new("kernel32","SetHandleInformation",'iii','i').call(@stdout_rd.unpack("i").first, 1, 0)
Win32API.new("kernel32","CreatePipe",'pppi','i').call(@stdin_rd, @stdin_wr, saAttr, 1048576*32)
Win32API.new("kernel32","SetHandleInformation",'iii','i').call(@stdin_wr.unpack("i").first, 1, 0)
    params = 'LPPPLLLPPP'
createprocess = Win32API.new('kernel32','CreateProcess', params, 'I')
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
      
                           si = [68,0,0,0,0,0,0,0,0,0,0,1|0x100,0,0,0,@stdin_rd.unpack("I").first,@stdout_wr.unpack("I").first,nil]
    startinfo = si.pack('IIIIIIIIIIIISSIIII')
        @procinfo  = [0,0,0,0].pack('LLLL')
        pr = createprocess.call(0, file, nil, nil, 1, 0, 0, $path[0...$path.size-($path.reverse.index("\\"))], startinfo, @procinfo)
            @pid = @procinfo.unpack('LLLL').first
          end
          def terminate
            Win32API.new("kernel32","TerminateProcess",'ip','i').call(@pid,"")
          end
    def avail
      dread=[0].pack("I")
      dleft=[0].pack("I")
      dtotal=[0].pack("I")
      buf=""
      Win32API.new("kernel32","PeekNamedPipe",'ipippp','i').call(@stdout_rd.unpack("I").first,buf,0,dread,dtotal,dleft)
    
      return dtotal.unpack("I").first
      end
          def read(size=nil)
            size=avail if size==nil
            return "" if size==0
        dread = [0].pack("i")
      buf="\0"*size
      readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
        readfile.call(@stdout_rd.unpack("i").first, buf, size, dread, nil)        
        return "" if dread.unpack("i").first==0
        return buf[0..dread.unpack("i").first-1]
      end
      def write(text)
         dwritten = [0].pack("i")
writefile = Win32API.new("kernel32","WriteFile",'ipipi','I')
        writefile.call(@stdin_wr.unpack("i").first, text, text.bytesize, dwritten, 0)
      end
      def close
       
      end
      end
#Copyright (C) 2014-2019 Dawid Pieper