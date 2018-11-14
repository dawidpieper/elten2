#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Users_AddedMeToContacts
  def initialize(new=false)
    @new=new
    end
  def main
    if $name=="guest"
      speech(_("UsersAddedMeToGeneral:error_guest"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
      if @new==false          
      @usr = srvproc("contacts_addedme","name=#{$name}\&token=#{$token}")
    else
      @usr = srvproc("contacts_addedme","name=#{$name}\&token=#{$token}\&new=1")
      end
        for i in 0..@usr.size - 1
      @usr[i].delete!("\r")
      @usr[i].delete!("\n")
    end
        usr = []
    for i in 1..@usr.size - 1
      usr.push(@usr[i]) if @usr[i].size > 0
    end
    selt = []
    for i in 0..usr.size - 1
      selt[i] = usr[i] + "." + " " + getstatus(usr[i])
      end
    header=_("UsersAddedMeToContacts:head")
    header="" if @new==true
      @sel = Select.new(selt,true,0,header)
    @user = usr
    loop do
loop_update
      @sel.update
      if escape
        srvproc("contacts_addedme","name=#{$name}\&token=#{$token}\&new=2")
        if @new==false
        $scene = Scene_Main.new
      else
        $scene=Scene_WhatsNew.new
        end
        break
      end
      if alt
                menu
                loop_update
              end
      if enter
                usermenu(@user[@sel.index],false)
        end
      break if $scene != self
      end
    end
    def menu
play("menu_open")
play("menu_background")
@menu = menulr(sel = [@user[@sel.index],_("General:str_refresh"),_("General:str_cancel")])
loop do
loop_update
@menu.update
break if $scene != self
if enter
  case @menu.index
  when 0
    if usermenu(@user[@sel.index],true) != "ALT"
          @menu = menulr(sel)
        else
          break
        end
        when 1
          @main = true
  when 2
$scene = Scene_Main.new
end
break
end
if Input.trigger?(Input::DOWN) and @menu.index == 0
    Input.update
  if usermenu(@user[@sel.index],true) != "ALT"
    @menu = menulr(sel)
  else
    break
    end
  end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
main if @main == true
return
end
end
#Copyright (C) 2014-2018 Dawid Pieper