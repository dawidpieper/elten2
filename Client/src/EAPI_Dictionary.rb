#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module Dictionary
    private
    @@cache={}
    @@docs={}
@@file=nil
  @@sources=[]
  @@translations=[]
  @@nplurals=2
  @@plurals="0"
  @@nstrings=0
  def setlocale(lang)
    lang.gsub!("_","-")
    file="locale/#{lang}/lc_messages/elten.mo"
   loadlocale(file)
   if File.directory?("locale/#{lang}")
     d=Dir.entries("locale/#{lang}")
     for f in d
       if File.extname(f)==".md"
         @@docs[f[0..-4]]=readfile("locale/#{lang}/#{f}")
         end
       end
     end
            end
def loadlocale(file)
      @@cache={}
      if !FileTest.exists?(file)
    @@file=nil
  @@sources=[]
  @@translations=[]
  @@nplurals=2
  @@plurals="0"
  @@nstrings=0
  return
    end
        @@file=file
  data=readfile(@@file)
  return if data==nil
  magic=data[0..3].unpack("I").first
  return if magic!=0x950412de
  format=data[4..7].unpack("I").first
  return if format!=0
  @@nstrings=data[8..11].unpack("I").first
  src=data[12..15].unpack("I").first
  dst=data[16..19].unpack("I").first
  for i in 0...@@nstrings
src_length = data[src+8*i..src+8*i+3].unpack("I").first
src_offset = data[src+8*i+4..src+8*i+7].unpack("I").first
dst_length = data[dst+8*i..dst+8*i+3].unpack("I").first
dst_offset = data[dst+8*i+4..dst+8*i+7].unpack("I").first
@@sources.push(data[src_offset..src_offset+src_length].split("\0"))
@@translations.push(data[dst_offset..dst_offset+dst_length].split("\0"))
if @@sources.last==[]
  t=@@translations.last
  setparams(t[0]) if t[0].is_a?(String)
end
@@cache[@@sources.last.first]||=[]
@@cache[@@sources.last.first].push(@@sources.size-1)
end
end
def _doc(d)
  @@docs[d]||readfile("locale/en-GB/#{d}.md")||""
  end
def _(src)
  find(src)[0]
end
def n_(*pr)
 forms=[]
 n=0
 for param in pr
   if param.is_a?(String)
   forms.push(param)
 elsif param.is_a?(Integer)
   n=param
   end
 end
 find(*forms)[pluralform(n)]
end
def p_(context, src)
  _(context+"\004"+src).gsub(context+"\004","")
end
def s_(str)
  s=_(str)
  if s==str
    return str[str.index("|")+1..-1]
  else
    return str
    end
  end
  def pn_(context, src, *params)
  n_(context+"\004"+src, *params).gsub(context+"\004","")
end
def sn_(context, src, *params)
  str=n_(context+"|"+src, *params)
  str.sub(context+"|","")
end
def N_(*params);end
  def Nn_(*params);end
private
def find(*forms)
  c=@@cache[forms.first]
  return forms if c==nil
  for i in c
    return @@translations[i] if @@sources[i].size>=forms.size && @@sources[i][0...forms.size]==forms
  end
  return forms
end
def setparams(t)
  pr=t.split("\n")
  for param in pr
    c=param.index(": ")
    next if c==nil
    head=param[0...c]
    val=param[c+2..-1]
    if head=='Plural-Forms'
      parse_plurals(val)
      end
    end
  end
  def parse_plurals(pl)
    pl=pl.delete(" \t")
    if (/nplurals=(\d+)/=~pl)!=nil
      @@nplurals=$1.to_i
    end
    if (/plural=([^;]+);/=~pl)!=nil
      @@plurals=$1
    end
  end
  def pluralform(n)
    eval(@@plurals)
  rescue Exception
    return 0
    end
    end
  end