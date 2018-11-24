#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_MyPermissions
  def main
    if $rang_moderator != 0 or $rang_media_administrator != 0 or $rang_translator != 0 or $rang_developer != 0 or $rang_tester != 0
            sel = []
      sel.push(_("MyPermissions:opt_betatesters")) if $rang_tester > 0
      sel.push(_("MyPermissions:opt_moderators")) if $rang_moderator > 0
      sel.push(_("MyPermissions:opt_mediaadministrators")) if $rang_media_administrator > 0
      sel.push(_("MyPermissions:opt_translators")) if $rang_translator > 0
      sel.push(_("MyPermissions:opt_developers")) if $rang_developer > 0
      @sel = Select.new(sel,true,0,_("Permissions:head"))
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
      speech(_("MyPermissions:info_nopermissions"))
      speech_wait
      $scene = Scene_Main.new
      end
    end
    def menu
play("menu_open")
play("menu_background")
@menu = menulr([_("General:str_cancel")])
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
return
end
  end
#Copyright (C) 2014-2018 Dawid Pieper