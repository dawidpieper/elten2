#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Admins
  def initialize
            @admins = srvproc("admins","name=#{$name}\&token=#{$token}")
            for i in 0..@admins.size - 1
      @admins[i].delete!("\r")
      @admins[i].delete!("\r\n")
    end
        adm = []
    for i in 1..@admins.size - 1
      adm.push(@admins[i]) if @admins[i].size > 0
    end
        selt = []
    for i in 0..adm.size - 1
      selt[i] = adm[i] + "." + " " + getstatus(adm[i])
      end
    @sel = Select.new(selt,true,0,_("Admins:head"),true)
    speech_stop
    @adm = adm
    end
    def main
                        @sel.focus
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
                usermenu(@adm[@sel.index],false)
        end
      break if $scene != self
      end
    end
    def menu
play("menu_open")
play("menu_background")
@menu = menulr(sel = [@adm[@sel.index],_("General:str_refresh"),_("General:str_cancel")])
loop do
loop_update
@menu.update
break if $scene != self
if enter
  case @menu.index
  when 0
    if usermenu(@adm[@sel.index],true) != "ALT"
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
  if usermenu(@adm[@sel.index],true) != "ALT"
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
if @main == true
  initialize
  main
  end
return
end
end
#Copyright (C) 2014-2019 Dawid Pieper