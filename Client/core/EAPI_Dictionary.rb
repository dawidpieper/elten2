#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module Dictionary
def load_locale(file,lang='en_GB')
  if FileTest.exists?(file)
  fp=File.open(file,"rb")
  $locales=Marshal.load(Zlib::Inflate.inflate(fp.read))
  fp.close
            set_locale(lang)
            end
  end
    
  def set_locale(lang)
  if $locales!=nil
    for locale in $locales
      $dict=locale if locale['_code'][0..1].downcase==lang[0..1].downcase
      end
    end
    $dict=$locales[0] if $dict=={}
    end
  
    def load_dict(file,reset=false)
    r=IO.read(file)
    r.gsub!("\"\r\n\"","\r\n")
    r.gsub!("\"\n\"","\n")
    li = r.split("\n")
$dict={} if $dict==nil or reset==true
last=''
for l in li
r.chop! if r[-1..-1]=="\r"
  if (/msgid "([^"]+)"/=~l)!=nil
  last=$1.delete("\r\n")
end
if (/msgstr "([^"]+)"/=~l)!=nil
      $dict.store(last,$1.delete("\r\n"))
end
  end
end  

  def _(msg)
  $dict={} if $dict==nil
    return ((($dict!=nil)?($dict[msg]):nil)||(($locales.is_a?(Array) and $locales.size>0)?($locales[0][msg]):nil)||msg).deep_dup
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