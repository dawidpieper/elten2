#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Online
  def main
                    @online = srvproc("online",{})
    @onl=[]
            for o in @online[1..-1]
      @onl.push(o.delete("\r\n"))
    end
    @onl.polsort!
                selt = []
    for u in @onl
      selt.push(u + ". " + getstatus(u,false))
      end
    @sel = Select.new(selt,true,0,_("Online:head"))
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
                usermenu(@onl[@sel.index],false)
        end
      break if $scene != self
      end
    end
    def menu
play("menu_open")
play("menu_background")
@menu = menulr(sel = [@onl[@sel.index],_("General:str_refresh"),_("General:str_cancel")])
loop do
loop_update
@menu.update
break if $scene != self
if enter
  case @menu.index
  when 0
    if usermenu(@onl[@sel.index],true) != "ALT"
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
if arrow_down and @menu.index == 0
    loop_update
  if usermenu(@onl[@sel.index],true) != "ALT"
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