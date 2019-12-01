#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module Dictionary
def load_locale(file,lang='en_GB')
  Log.info("Loading locale data: #{file}")
  if FileTest.exists?(file)
  fp=File.open(file,"rb")
  $locales=Marshal.load(Zlib::Inflate.inflate(fp.read))
  fp.close
            set_locale(lang)
            end
  end
    
  def set_locale(lang)
    Log.info("Changing locale: #{lang}")
  if $locales!=nil
    for locale in $locales
      $dict=locale if locale['_code'][0..1].downcase==lang[0..1].downcase
      end
    end
    $dict=$locales[0] if $dict=={}
    end
  
    def load_dict(file,reset=false)
      Log.info("Loading GetText dictionary from file: #{file}")
    r=readfile(file)
    r.gsub!("\"\r\n\"","\r\n")
    r.gsub!("\"\n\"","\n")
    li = r.split("\n")
$dict={} if $dict==nil or reset==true
id=''
ctxt=''
for l in li
r.chop! if r[-1..-1]=="\r"
if (/msgctxt "([^"]+)"/=~l)!=nil
  ctxt=$1.delete("\r\n")
end
  if (/msgid "([^"]+)"/=~l)!=nil
  id=$1.delete("\r\n")
end
if (/msgstr "([^"]+)"/=~l)!=nil
  d=$1
  msgid=id
  for k in $locales[0].keys
    msgid=k if k[0...k.index(":")||0]==ctxt and $locales[0][k]==id.gsub(/ \{([^\}]+)\}/,"")
  end
          $dict.store(msgid,d.delete("\r\n"))
end
  end
end  

  def _(msg)
  $dict={} if $dict==nil
    r=((($dict!=nil)?($dict[msg]):nil)||(($locales.is_a?(Array) and $locales.size>0)?($locales[0][msg]):nil)||msg).deep_dup
    Log.warning("Message not in locale dictionary: #{msg}") if r==msg
    return r
end

def s_(msg, params)
  str=_(msg)
  for param in params.keys
    str.gsub!("%{#{param}}",params[param])
  end
  return str
end
end
end
#Copyright (C) 2014-2019 Dawid Pieper