#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Voice
  def main
        sel = ["Zmień syntezator","Zmień szybkość syntezatora","Zmień głośność syntezy","Używaj głosu aktywnego czytnika ekranowego lub domyślnego głosu systemu"]
    @sel = Select.new(sel,true,0,"Ustawienia mowy")
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
              speech_stop
       $scene = Scene_Main.new
     end
     if enter
              case @sel.index
       when 0
       $scene = Scene_Voice_Voice.new(1)
       when 1
         $scene = Scene_Voice_Rate.new
         when 2
           $scene = Scene_Voice_Volume.new
         when 3
                                      writeini($configdata + "\\sapi.ini",'Sapi','Voice',-1.to_s)
                                $voice = -1
                speech("Wybrano obsługę czytnika ekranowego.")
       end
       end
     end
  end

class Scene_Voice_Voice
  def initialize(settings=0)
    @settings = settings
    end
    def main
      $selectedvoice = false
            $numvoice=Elten::Engine::Speech.getnumvoices-1
            Elten::Engine::Speech.setvoice(0)
                  speech(Elten::Engine::Speech.getvoicename(0))
      $curnum = 0
      loop do
loop_update
    update
    if $scene != self
      break
    end
    end
                  end
    def update
      if Input.trigger?(Input::DOWN)
        speech_stop
        if $curnum + 1 <= $numvoice
          $curnum = $curnum + 1
        else
          $curnum = 0
        end
        Elten::Engine::Speech.setvoice($curnum)
        speech(Elten::Engine::Speech.getvoicename($curnum))
      end
            if Input.trigger?(Input::UP)
        speech_stop
        if $curnum - 1 >= 0
          $curnum = $curnum - 1
        else
          $curnum = $numvoice
        end
        Elten::Engine::Speech.setvoice($curnum)
        speech(Elten::Engine::Speech.getvoicename($curnum))
      end
      if alt
                menu
        end
      if enter or $selectedvoice == true
                                writeini($configdata + "\\sapi.ini",'Sapi','Voice',$curnum.to_s) if $voice != -3 or @settings != 0
                $voice = $curnum.to_i
                                      mow = "Wybrany głos: " + Elten::Engine::Speech.getvoicename($curnum)
        speech(mow)
speech_wait
if @settings == 0
$scene = Scene_Loading.new
else
  $scene = Scene_Voice.new
  end
end
if escape and @settings != 0
  $scene = Scene_Voice.new
  end
      end
          def menu
play("menu_open")
play("menu_background")
sel = ["Wybierz"]
sel.push("Anuluj") if @settings != 0
@menu = menulr(sel)
loop do
loop_update
@menu.update
if enter
  case @menu.index
  when 0
$selectedvoice = true
break
when 1
  if @settings != 0
    $scene = Scene_Voice.new
    break
    end
end
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
delay(0.25)
return
end
end

class Scene_Voice_Rate
  def main
        sel = []
    for i in 1..100
      sel.push(i.to_s)
    end
    Graphics.update
    @rate = Elten::Engine::Speech.getrate
    @startrate = @rate
    @sel = Select.new(sel,true,@rate - 1,"Wybierz szybkość głosu.")
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
if @rate - 1 != @sel.index
  @rate = @sel.index + 1
  Elten::Engine::Speech.setrate(@rate)
  end
      @rate = @sel.index + 1
      if escape
                @rate = @startrate
        Elten::Engine::Speech.setrate(@rate)
        $scene = Scene_Voice.new
      end
      if enter
                                     writeini($configdata + "\\sapi.ini",'Sapi','Rate',@rate.to_s)
     speech("Zapisano.")
     speech_wait
     $scene = Scene_Voice.new
        end
      end
    end
    
    class Scene_Voice_Volume
  def main
        sel = []
    for i in 1..100
      sel.push(i.to_s)
    end
        @volume = Elten::Engine::Speech.getvolume
    @startvolume = @volume
    @sel = Select.new(sel,true,@volume - 1,"Wybierz głośność syntezy.")
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
if @volume - 1 != @sel.index
  @volume = @sel.index + 1
  Elten::Engine::Speech.setvolume(@volume)
  end
      @volume = @sel.index + 1
      if escape
                @volume = @startvolume
        Elten::Engine::Speech.setvolume(@volume)
        $scene = Scene_Voice.new
      end
      if enter
                                     writeini($configdata + "\\sapi.ini",'Sapi','Volume',@volume.to_s)
     speech("Zapisano.")
     speech_wait
     $scene = Scene_Voice.new
        end
      end
  end
#Copyright (C) 2014-2016 Dawid Pieper