#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Users
  def main
            @users = srvproc("users","name=#{$name}\&token=#{$token}")
        err = @users[0].to_i
    case err
    when -1
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        $scene = Scene_Main.new
        return
        when -3
          speech(_("General:error_permissions"))
          $scene = Scene_Main.new
          return
    end
        for i in 0..@users.size - 1
      @users[i].delete!("\r")
      @users[i].delete!("\n")
    end
        usr = []
    for i in 1..@users.size - 1
      usr.push(@users[i]) if @users[i].size > 0
    end
        selt = []
    for i in 0..usr.size - 1
      selt[i] = usr[i] + ". " + getstatus(usr[i])
      end
    @sel = Select.new(selt,false,0,_("Users:head"))
    @usr = usr
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
                usermenu(@usr[@sel.index],false)
                        end
      break if $scene != self
      end
    end
    def menu
play("menu_open")
play("menu_background")
@menu = menulr(sel = [@usr[@sel.index],_("General:str_refresh"),_("General:str_cancel")])
loop do
loop_update
@menu.update
break if $scene != self
if enter
  case @menu.index
  when 0
    if usermenu(@usr[@sel.index],true) != "ALT"
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
  if usermenu(@usr[@sel.index],true) != "ALT"
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
delay(0.25)
main if @main == true
return
end
end
#Copyright (C) 2014-2016 Dawid Pieper