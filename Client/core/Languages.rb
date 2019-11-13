#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Languages
  def main
    sel=[]
    $locales.each {|locale| sel.push(locale['_name']) }
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
                                   writeconfig("Interface", "Language", lng)
$language = lng
set_locale($language)
speech(_("General:info_saved"))
speech_wait
main
return
    end
  end
  end
  end
#Copyright (C) 2014-2019 Dawid Pieper