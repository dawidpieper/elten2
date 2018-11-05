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
  
    def update_dicts
  
  end
    
    def load_dict(file="locale/pl_PL/LC_MESSAGES/elten.po")
    li=IO.readlines(file)
$dict={}
last=''
for l in li
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