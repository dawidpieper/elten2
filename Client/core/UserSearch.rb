#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_UserSearch
  def main
    usr=""
    while usr==""
      usr=input_text("Szukanie użytkowników","ACCEPTESCAPE")
    end
    if usr=="\004ESCAPE\004"
      $scene=Scene_Main.new
      return
      end
    usf=srvproc("user_search","name=#{$name}\&token=#{$token}\&search=#{usr}")    
if usf[0].to_i<0
  speech("Błąd")
  speech_wait
    $scene=Scene_Main.new
    return
  end
@results=[]
if usf[1].to_i==0
  speech("Nie znaleziono dopasowania.")
  speech_wait
  $scene=Scene_Main.new
  return
end
for u in usf[2..1+usf[1].to_i]
  @results.push(u.delete("\r\n"))
end
selt=[]
for r in @results
  selt.push(r+".\r\n"+getstatus(r))
  end
@sel=Select.new(selt,true,0,"Wyniki wyszukiwania")
loop do
  loop_update
  @sel.update
  usermenu(@results[@sel.index]) if enter
  menu if alt
  $scene=Scene_Main.new if escape
  break if $scene!=self
  end
end
def menu
play("menu_open")
play("menu_background")
@menu = menulr(sel = [@results[@sel.index],"Wyszukaj ponownie","Anuluj"])
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
if Input.trigger?(Input::DOWN) and @menu.index == 0
    Input.update
  if usermenu(@results[@sel.index],true) != "ALT"
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
if @main == true
  initialize
  main
  end
return
end
end
#Copyright (C) 2014-2016 Dawid Pieper