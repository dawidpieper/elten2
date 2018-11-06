#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module Dictionary
def load_locale(file,lang='en_GB')
      $locales=load_data(file)
    set_locale(lang)
  end
    
  def set_locale(lang)
  if $locales!=nil
    for locale in $locales.keys
      $dict=$locales[locale] if locale[0..1].downcase==lang[0..1].downcase
      end
    end
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
    return $dict[msg]||msg
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
#Copyright (C) 2014-2018 Dawid Pieper