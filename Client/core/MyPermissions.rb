#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_MyPermissions
  def main
    if $rang_moderator != 0 or $rang_media_administrator != 0 or $rang_translator != 0 or $rang_developer != 0 or $rang_tester != 0
            sel = []
      sel.push("Betatesterzy") if $rang_tester > 0
      sel.push("Moderatorzy") if $rang_moderator > 0
      sel.push("Administratorzy mediów") if $rang_media_administrator > 0
      sel.push("Tłumacze") if $rang_translator > 0
      sel.push("Programiści") if $rang_developer > 0
      @sel = Select.new(sel,true,0,"Należysz do następujących grup")
      loop do
loop_update
        @sel.update
        if alt
          menu
          end
        if escape
          $scene = Scene_Main.new
          break
        end
        break if $scene != self
        end
    else
      speech("Nie posiadasz żadnych specjalnych uprawnień.")
      speech_wait
      $scene = Scene_Main.new
      end
    end
    def menu
play("menu_open")
play("menu_background")
@menu = SelectLR.new(["Anuluj"])
loop do
loop_update
@menu.update
if enter
$scene = Scene_Main.new
break
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
Graphics.transition(10)
return
end
  end
#Copyright (C) 2014-2016 Dawid Pieper