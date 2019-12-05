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
  def to_b
    return true
    end
end

class FalseClass
    def deep_dup
    self
  end
  def to_i
    return 0
  end
  def to_b
    return false
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
  def sum
    return 0 if self.size==0
    s=self[0]
    self[1..-1].each {|a| s+=a}
    return s
  end
  def polsort
    cs=Win32API.new("kernel32", "CompareStringW", 'iipipi', 'i')
    a=self.sort {|a,b|
    if !a.is_a?(String) || !b.is_a?(String)
      a<=>b
    else
      ua=unicode(a)
      ub=unicode(b)
      cs.call(0x400, 0x10|8, ua, ua.size/2, ub, ub.size/2)-2
              end
    }
    return a
poses = [["a", "A"], ["b", "B"], ["c", "C"], ["ć", "Ć"], ["d", "D"], ["e", "E"], ["ę", "Ę"], ["f", "F"],["g", "G"], ["h", "H"], ["i", "I"], ["j", "J"], ["k", "K"], ["l", "L"], ["ł", "Ł"], ["m", "M"], ["n", "N"], ["ń", "Ń"], ["o", "O"], ["ó", "Ó"], ["p", "P"], ["q", "Q"], ["r", "R"], ["s", "S"], ["ś", "Ś"], ["t", "T"], ["u", "U"], ["v", "V"], ["w", "W"], ["x", "X"], ["y", "Y"], ["z","Z"], ["ź", "Ź"], ["ż", "Ż"]]
        self.sort {|a,b|
    if a==b
      0
      elsif a==""
      -1
    elsif b==""
      1
    elsif a.is_a?(String) and b.is_a?(String)
      i1=-1
      i2=-1
      ind=0
      sz=a.split("").size
      sz2=b.split("").size
      sz=sz2 if sz2<sz
      as=a.split("")
      bs=b.split("")
      while i1==i2 and ind<sz
      for i in 0...poses.size
        i1=i if poses[i][0]==as[ind] or poses[i][1]==as[ind]
        i2=i if poses[i][0]==bs[ind] or poses[i][1]==bs[ind]
      end
      ind+=1
      end
      if i1!=-1 and i2!=-1
      i1<=>i2
    else
      a<=>b
    end
  else
    a<=>b
      end
    }
  end
  def polsort!
    a=self.polsort
    for i in 0...self.size
      self[i]=a[i]
      end
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
  def bigletter
    return self!=self.downcase
          return false
    end
  alias strupcase upcase
  def upcase
d=unicode(self)
                        Win32API.new("user32", "CharUpperBuffW", 'pi', 'i').call(d, d.size/2)
                return deunicode(d)
      end
      def downcase
            d=unicode(self)
                        Win32API.new("user32", "CharLowerBuffW", 'pi', 'i').call(d, d.size/2)
                return deunicode(d)
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
      finddata = ([0, 0,0, 0,0, 0,0, 0]+[0]*260*2+[0]*14*2).pack("IIIIIIII"+"C"*2*260+"C"*2*14)
      len=44
      dirf=unicode(dir+"\\*")
handle = Win32API.new("kernel32","FindFirstFileW",'pp','i').call(dirf,finddata)
return []  if handle==-1
loop do
    basename = deunicode(finddata[len,260*2])
    files.push(basename)
break if Win32API.new("kernel32","FindNextFileW",'ip','i').call(handle,finddata)==0
end
Win32API.new("kernel32","FindClose",'i','i').call(handle)
return files
end
def self.size(dir)
        finddata = ([0, 0,0, 0,0, 0,0, 0]+[0]*260*2+[0]*14*2).pack("IIIIIIII"+"C"*2*260+"C"*2*14)
      len=44
      dirf=unicode(dir+"\\*")
handle = Win32API.new("kernel32","FindFirstFileW",'pp','i').call(dirf,finddata)
return 0 if handle==-1
size=0
loop do
  basename=deunicode(finddata[len,260*2])
    if basename!="." and basename!=".."
    fd=finddata.unpack("iiiiiiiiii")
if (fd[0]&16)>0
  size+=self.size(dir+"\\"+basename)
else
  size+=(fd[7]*(0xffffffff+1)+fd[8])
  end
end
  break if Win32API.new("kernel32","FindNextFileW",'ip','i').call(handle,finddata)==0
end
Win32API.new("kernel32","FindClose",'i','i').call(handle)
return size
end
end

module FileTest
  def self.exists?(file)
self.exist?(file)
end
def self.exist?(file)
attrib=Win32API.new("kernel32","GetFileAttributesW",'p','i').call(unicode(file))
if attrib==-1
return false
else
return true
end
end
end

class File
def self.directory?(file)
  attrib=Win32API.new("kernel32","GetFileAttributesW",'p','i').call(unicode(file))
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
attrib=Win32API.new("kernel32","GetFileAttributesW",'p','i').call(unicode(file))
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
if Win32API.new("kernel32","DeleteFileW",'p','i').call(unicode(file))==0
return false
else
return true
end
end
def self.size(file)
  createfile = Win32API.new("kernel32","CreateFileW",'piipili','l')
handler = createfile.call(unicode(file),1,1|2|4,nil,4,0,0)
return -1 if handler == -1
  readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
sz = "\0"*8
Win32API.new("kernel32","GetFileSizeEx",'ip','l').call(handler,sz)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
return size = sz.unpack("L")[0]
  end
end
#Copyright (C) 2014-2019 Dawid Pieper