#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module External
    private
# Functions using external APIs
   
   # Translates a string to another language using Yandex
    #
    # @param from [String] source language code (if 0, the language autodetection is used)
    # @param to [String] destination language code
    # @param text [String] a text to translate
    # @return [String] the translation result
   def ytranslate(from,to,text,quiet=false)
     return "" if text==""||text==nil
     text="" if text==nil
     text=text.to_s
          text=text.gsub("\004LINE\004","\r\n")
     text.gsub!("\r\n"," \r\n")
     text.gsub!("\004","")
text.gsub!("-"," ")
     text=text.urlenc
               to = to[0..1]
               text[0]=0 if text[0..0]=="+"
               text.delete!("\0")
                              if from == 0
       download("https://translate.yandex.net/api/v1.5/tr.json/detect?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}",Dirs.temp+"/trans")
               a = readfile(Dirs.temp+"/trans")
File.delete(Dirs.temp+"/trans")
 c = JSON.load(a)
return "" if c==nil
if c['code']!=200
  alert(p_("EAPI_External", "An error occurred while translating.")) if quiet==false
  return c['code']
end
from = c['lang']       
end
to=to.downcase
download("https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}\&lang=#{from}-#{to}",Dirs.temp+"/trans")
          a =  readfile(Dirs.temp+"/trans")
     File.delete(Dirs.temp+"/trans")
     c = JSON.load(a)
if c.is_a?(Hash)
if c['code']!=200
  alert(p_("EAPI_External", "An error occurred while translating.")) if quiet==false
  return c['code']
end
r = ""
for l in c['text']
  r += l
end
return r
else
  return ""
  end
     end
   # Translates a string to another language using selected API
    #
    # @param from [String] source language code (if 0, the language autodetection is used)
    # @param to [String] destination language code
    # @param text [String] a text to translate
    # @param api [Int] 0=AUTO, 1=GOOGLE, 2=YANDEX
    # @return [String] the translation result
def translatetext(from,to,text,api=0)
  case api
  when 0
    t=gtranslate(from,to,text)
            t=ytranslate(from,to,text) if t==nil||t==""
    return t
  when 1
    return gtranslate(from,to,text)
    when 2
      return ytranslate(from,to,text)
  end
end

def gtranslate(from, to, text)
  from="auto" if from==0 || from==nil || from==""
rest=text[5001..-1]
text=text[0..5000]
  url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=#{from}&tl=#{to}&dt=t&q=#{text.urlenc}"
  download(url, Dirs.temp+"\\trans")
  j=readfile(Dirs.temp+"\\trans")
  if j!=""
  h=JSON.load(j)
  return "" if !h[0].is_a?(Array)
  t=""
  for a in h[0]
    return "" if !a[0].is_a?(String)
    t+=a[0]
  end
  t+=gtranslate(from, to, rest) if rest!=nil && rest!=""
  return t
  else
  return ""
  end
  end

# Opens a translator dialog
#
# @param text [String] a text to translate
     def translator(text)
  dialog_open
  download("https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&ui=#{$language[0..1]}",Dirs.temp+"/trans")
  a = readfile(Dirs.temp+"/trans")
 File.delete(Dirs.temp+"/trans")
  c = JSON.load(a)
  return "" if !c.is_a?(Hash)
 langs=c['langs']
  from=ListBox.new([p_("EAPI_External", "recognize automatically")]+langs.values,p_("EAPI_External", "source language"),0, 0, true)
 ind=0
 for i in 0..langs.keys.size-1
   ind=i if $language[0..1].downcase==langs.keys[i].downcase
   end
 to=ListBox.new(langs.values,p_("EAPI_External", "destination language"),ind,0,true)
 submit=Button.new(p_("EAPI_External", "Translate"))
 cancel=Button.new(_("Cancel"))
 form=Form.new([from,to,submit,cancel])
loop do
  loop_update
  form.update
  if escape or ((space or enter) and form.index==3)
    dialog_close
    loop_update
    return -1
  end
  if (space or enter) and form.index == 2
        break
    end
  end
  lfrom=0
  if from.index==0
      lfrom=0
    else
        lfrom=langs.keys[from.index-1]
      end
      lto=langs.keys[to.index]
      ef = translatetext(lfrom,lto,text)
      lfrom = "AUTO" if lfrom==0
      input_text("#{lfrom} - #{lto}",EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly,ef)
      loop_update
    dialog_close
  end


def convert_book(src,dst)
  if src[-3..-1].downcase=="txt" and dst[-3..-1].downcase=="txt"
    r=readfile(src)
        writefile(dst,r)
    end
  if !FileTest.exists?(Dirs.extras+"\\Calibre Portable\\Calibre\\ebook-convert.exe")
    s=confirm(p_("EAPI_External", "The file you're trying to open was saved in format that Elten does not support. Do you want to download and install Calibre Library that will allow Elten to read Ebooks?"))
    if s==1
      downloadfile("http://download.calibre-ebook.com/3.46.0/calibre-portable-installer-3.46.0.exe",Dirs.temp+"\\calibre.exe",p_("EAPI_External", "Please wait, downloading Calibre..."))
      return if !FileTest.exists?(Dirs.temp+"\\calibre.exe") or File.size(Dirs.temp+"\\calibre.exe")<1048576
      speak(p_("EAPI_External", "Please wait, extracting Calibre..."))
      waiting
      executeprocess(Dirs.temp+"\\calibre.exe \".\"",true,0,true,"C:\\")
      copydir("C:\\Calibre Portable",Dirs.extras+"/Calibre Portable")
      deldir("C:\\Calibre Portable")
      waiting_end
      File.delete(Dirs.temp+"\\calibre.exe")
    else
      return
    end
    end
    executeprocess("\""+Dirs.extras+"\\Calibre Portable\\Calibre\\ebook-convert.exe"+"\" \"#{src}\" \"#{dst}\"",true)
    
  end
end
include External
end