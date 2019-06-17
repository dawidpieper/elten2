#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Object
  def deep_dup
        dup if self!=nil
  end
end

class Numeric
    def deep_dup
    self
  end
def to_b
  return false if self<=0
  return true
  end
  end

class TrueClass
    def deep_dup
    self
  end
  def to_i
    return 1
    end
end

class FalseClass
    def deep_dup
    self
  end
  def to_i
    return 0
    end
end

class Array
    def find_index(str,ows=0)
        for i in 0..self.size-1
      return i if self[i]==str
    end
    return ows
    end
      def deep_dup
    return [] if self == []
        map {|x| x.deep_dup}
  end    
  def count(o)
    r=0
    for v in self
      r+=1 if v==o
    end
    return r
    end
    def to_s
      return self.join("")
    end
    def shuffle
t=self+[]      
res=[]
for o in t
  v=-1
  while v==-1 or res[v]!=nil
  v=rand(t.size)
  end
    res[v]=o
  end
  return res  
  end
  def shuffle!
    n=shuffle
    for i in 0..n.size-1
      self[i]=n[i]
      end
    return self
      end
  end

class Fixnum
  alias greater >
  alias less <
  alias greaterq >=
  alias lessq <=
  def >(i)
        greater(i.to_f)
  end
  def <(i)
    less(i.to_f)
    end
  def >=(i)
    greaterq(i.to_f)
  end
  def <=(i)
    lessq(i.to_f)
    end
  end
  class Float
  alias greater >
  alias less <
  alias greaterq >=
  alias lessq <=
  def >(i)
        greater(i.to_f)
  end
  def <(i)
    less(i.to_f)
    end
  def >=(i)
    greaterq(i.to_f)
  end
  def <=(i)
    lessq(i.to_f)
    end
    end

class String
  def to_b
    self.to_i.to_b
    end
  def delline(lines=1)
    self.gsub!("\004LINE\004","\r\n")    
    str = ""
foundlines = 1
    for i in 0..self.size - 1
      str += self[i..i]
      foundlines += 1 if self[i..i] == "\n"
    end
    fl = 0
    ret = ""
    for i in 0..str.size - 1
      fl += 1 if str[i..i] == "\r" or (str[i..i] == "\n" and str[i-1..i-1] != "\r")
      if foundlines - lines > fl
        ret += str[i..i]
        end
      end
      return ret.to_s
    end
    def strbyline
str = self
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
def rdelete!(i)
    b = i[0]
  x = 0
  for i in 1..self.size
    if self[self.size - i] == b
      x += 1
    else
      break
    end
       end
  for i in 0..x-1
    chop!
    end
  end
  def maintext
    str = ""
    for i in 0..self.size - 1
            str += self[i..i]
            break if self[i+1..i+1] == "\003"
    end
    return str
  end
  def lore
    str = ""
    s = false
    for i in 0..self.size - 1
            str += self[i..i] if s == true
            s = true if self[i..i] == "\003"
    end
    str=maintext if str==""
    return str
  end
  def b
    o = []
    for i in 0..self.size - 1
      o.push(" "[self[i]])
    end
    return o
    end
  def urlenc(binary=false)
    string = self+""
            r = string.gsub(/([^ a-zA-Z0-9_.-]+)/) do |m|
      '%' + m.unpack('H2' * m.size).join('%').upcase
    end.tr(' ', '+')
        return r
  end
    def urldec
    string = self+""
    r=string
    o=""
    while r != o
      o=r
          r = string.gsub(/%([a-fA-F0-9][a-fA-F0-9])/) do |m|
      s="\0"
      s[0]=m[1..2].to_i(16)
      s
    end.tr('+', ' ')
string=r
    end
    return    r
  end
  def delspecial
    string = self+""
    from=["ą","ć","ę","ł","ń","ó","ś","ź","ż","Ą","Ć","Ę","Ń","Ó","Ł","Ś","Ź","Ż","-"]
    to=["a","c","e","l","n","o","s","z","z","A","C","E","L","N","O","S","Z","Z","_"]
    for i in 0..to.size-1
      string.gsub!(from[i],to[i])
      end
    r = string.gsub(/([^ a-zA-Z0-9_.-]+)/) do |m|
      ''
    end.tr(' ', '_')
    return r
  end
  def bigletter(type=0)
    if self.size==1
    return true if self[0]>64 and self[0]<91 and type==0
    elsif self.bytesize==2
    return true if self=="Ą" or self=="Ć" or self=="Ę" or self=="Ł" or self == "Ń" or self=="Ó" or self=="Ś" or self=="Ź" or self=="Ż"
  end
  return true if lngkeys(1)[self]==1
    return false
    end
  alias strupcase upcase
  def upcase
    src=["ą","ć","ę","ł","ń","ó","ś","ź","ż"]
    dst=["Ą","Ć","Ę","Ł","Ń","Ó","Ś","Ź","Ż"]
    for i in 0..src.size-1
    self.gsub!(src[i],dst[i])
    end
    strupcase
  end
  if $ruby != true
      def bytesize
    return size
  end
else
  alias arr []
  def [](*args)
    return arr(*args) if args.size>1
    b = args[0]
    if b.is_a?(Integer)
    return self.getbyte(b)
  else
    return arr(b)
    end
  end
    def []=(i,b)
    if b.is_a?(Integer)
    return self.setbyte(i,b)
  else
    return arr(b)
    end
  end
end
  def indices e
    start, result = -1, []
    result << start while start = (self.index e, start + 1)
    result
  end
        end
  
  class NilClass
    def join(v=nil)
      return ""
      end
    def delete(s)
      return ""
    end
    def +(s)
      return s
    end
    def to_s
      return ""
    end
    def to_i
      return 0
      end
    end
  
    class Dir
def self.entries(dir)
files=[]
      finddata = [0, 0,0, 0,0, 0,0, 0,0,0,0].pack("IIIIIIIIIII")
      len = finddata.length
      finddata = finddata + '\0'*260 + '\0'*14
dirf=utf8(dir+"\\*")
handle = Win32API.new("kernel32","FindFirstFile",'pp','i').call(dirf,finddata)
return []  if handle==-1
loop do
basename = futf8(finddata[len,260].gsub(/\0.*/,""))
files.push(basename)
break if Win32API.new("kernel32","FindNextFile",'ip','i').call(handle,finddata)==0
end
Win32API.new("kernel32","FindClose",'i','i').call(handle)
return files
end
def self.size(dir)
        finddata = [0, 0,0, 0,0, 0,0, 0,0,0,0].pack("IIIIIIIIIII")
      len = finddata.length
      finddata = finddata + '\0'*260 + '\0'*14
dirf=utf8(dir+"\\*")
handle = Win32API.new("kernel32","FindFirstFile",'pp','i').call(dirf,finddata)
return 0 if handle==-1
size=0
loop do
  basename=futf8(finddata[len,260].gsub(/\0.*/,""))
    if basename!="." and basename!=".."
    fd=finddata.unpack("iiiiiiiiii")
if (fd[0]&16)>0
  size+=self.size(dir+"\\"+basename)
else
  size+=(fd[7]*(0xffffffff+1)+fd[8])
  end
end
  break if Win32API.new("kernel32","FindNextFile",'ip','i').call(handle,finddata)==0
end
Win32API.new("kernel32","FindClose",'i','i').call(handle)
return size
end
end

module FileTest
  class <<self
def self.exists?(file)
self.exist?(file)
end
def self.exist?(file)
attrib=Win32API.new("kernel32","GetFileAttributes",'p','i').call(utf8(file))
if attrib==-1
return false
else
return true
end
end
end
end

class File
def self.directory?(file)
  attrib=Win32API.new("kernel32","GetFileAttributes",'p','i').call(utf8(file))
if attrib==-1
return false
else
  if (attrib&16)>0
return true
else
    return false
end
end
end
def self.file?(file)
attrib=Win32API.new("kernel32","GetFileAttributes",'p','i').call(utf8(file))
if attrib==-1
return false
else
    if (attrib&16)>0
return false
else
  return true
end
end
end
def self.delete(file)
if Win32API.new("kernel32","DeleteFile",'p','i').call(utf8(file))==0
return false
else
return true
end
end
def self.size(file)
  createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(utf8(file),1,1|2|4,nil,4,0,0)
return -1 if handler == -1
  readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
sz = "\0"*8
Win32API.new("kernel32","GetFileSizeEx",'ip','l').call(handler,sz)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
return size = sz.unpack("L")[0]
  end
end
#Copyright (C) 2014-2019 Dawid Pieper