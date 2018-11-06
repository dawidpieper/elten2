#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Languages
  def main
    sel=[]
    $locales.each {|locale| sel.push(locale['_name']) }
      sel.push(_("Languages:opt_download"))
@sel = Select.new(sel,true,0,_("Languages:head"))
loop do
  loop_update
  @sel.update
  update
  if $scene != self
    break
    end
  end
end
def update
  if escape
        if $token != "" and $token != nil and $name != "" and $name != nil
    $scene = Scene_Main.new
  else
    $scene = Scene_Loading.new
    end
  end
if enter
  play("right")
  if @sel.index < $locales.size
lng = $locales[@sel.index]['_code']
                   iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Language','Language',lng,utf8($configdata + "\\language.ini"))
$language = lng
set_locale($language)
speech(_("General:info_saved"))
speech_wait
main
return
else
    downloadfile($url+"locale.dat","temp/locale_new.dat")
  begin
    fp=File.open("temp/locale_new.dat","rb")
  loc =Marshal.load(Zlib::Inflate.inflate(fp.read))
  fp.close
if loc.is_a?(Array) and loc.size>0
  $locales=loc
  set_locale($language)
  writefile("Data/locale.dat",read("temp/locale_new.dat"))
    end
speech(_("Languages:info_downloaded"))
    rescue Exception
    speech(_("General:error"))
    end
  speech_wait
main
return
    end
  end
  end
  end
#Copyright (C) 2014-2018 Dawid Pieper