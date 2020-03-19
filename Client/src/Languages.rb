#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Languages
  def main
    l=Dir.entries("locale")
    l.delete(".")
    l.delete("..")
    @langs=["en"]
    for d in l
      if FileTest.exists?("locale/#{d}/lc_messages/elten.mo")
        @langs.push(d.downcase)
        end
      end
      sel=@langs.map{|l|$langs[l[0..1].downcase]['name']+" ("+$langs[l[0..1].downcase]['nativeName']+")"}
      @sel = Select.new(sel,true,0,p_("Languages", "Manage languages"))
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
lng = @langs[@sel.index]
                                   writeconfig("Interface", "Language", lng)
$language = lng
setlocale($language)
alert(_("Saved"))
speech_wait
main
return
  end
  end
  end