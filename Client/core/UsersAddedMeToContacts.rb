#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Users_AddedMeToContacts
  def main
                @usr = srvproc("contacts_addedme","name=#{$name}\&token=#{$token}")
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
    @sel = Select.new(selt,true,0,"Użytkownicy, którzy dodali mnie do swoich kontaktów")
    @user = usr
    loop do
loop_update
      @sel.update
      if escape
        $scene = Scene_Main.new
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
@menu = menulr(sel = [@user[@sel.index],"Odświerz","Anuluj"])
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
Graphics.transition(10)
main if @main == true
return
end
end
#Copyright (C) 2014-2016 Dawid Pieper