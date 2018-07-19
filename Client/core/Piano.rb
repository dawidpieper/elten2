#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Piano
  def main
    loop do
      freq=0
      loop_update
      if escape
        $scene=Scene_Main.new
        break
        end
freq=77.8 if getkeychar=="1"
        freq=92.5 if getkeychar=="3"
        freq=103.8 if getkeychar=="4"
        freq=116.6 if getkeychar=="5"
        freq=138.6 if getkeychar=="7"
        freq=155.6 if getkeychar=="8"
        freq=185.0 if getkeychar=="9"
        freq=207.7 if getkeychar=="-"
        freq=266.2 if getkeychar=="="
        freq=82.4 if getkeychar=="q"
        freq=87.3 if getkeychar=="w"
        freq=98.0 if getkeychar=="e"
        freq=110.0 if getkeychar=="r"
        freq=123.5 if getkeychar=="t"
        freq=130.8 if getkeychar=="y"
        freq=146.9 if getkeychar=="u"
        freq=164.8 if getkeychar=="i"
        freq=174.6 if getkeychar=="o"
        freq=192 if getkeychar=="p"
        freq=220.0 if getkeychar=="["
        freq=246.9 if getkeychar=="]"
        freq=261.6 if getkeychar=="a"
freq=293.7 if getkeychar=="s"
freq=329.6 if getkeychar=="d"
freq=349.2 if getkeychar=="f"
freq=392.0 if getkeychar=="g"
freq=440.0 if getkeychar=="h"
freq=493.9 if getkeychar=="j"
freq=523.3 if getkeychar=="k"
freq=587.3 if getkeychar=="l"
freq=659.3 if getkeychar==";"
freq=698.5 if getkeychar=="'"
freq=277.2 if getkeychar=="z"
freq=311.1 if getkeychar=="x"
freq=370.0 if getkeychar=="v"
freq=415.3 if getkeychar=="b"
freq=466.2 if getkeychar=="n"
freq=554.4 if getkeychar==","
freq=622.3 if getkeychar=="."
freq=740.0 if getkeychar=="/"
if freq != 0
a=AudioFile.new("Audio/SE/signal.ogg")
a.frequency=a.frequency/466.2*freq
  a.frequency+=freq
a.play
end
      end
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper