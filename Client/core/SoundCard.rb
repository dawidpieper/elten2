#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_SoundCard
  def main
    soundcards=Bass.soundcards
    sc=soundcards.dup
    sc[0]=_("SoundCard:opt_default")
    microphones=[_("SoundCard:opt_default")]+Recorder.devices.values
    @form=Form.new([Select.new(sc,true,0,_("SoundCard:head_play"),true), Select.new(microphones,true,0,_("SoundCard:head_record"),true), Button.new(_("General:str_save")), Button.new(_("General:str_cancel"))])
    loop do
      loop_update
      @form.update
      if (enter and @form.index<=2) or (space and @form.index==2)
        soundcard=soundcards[@form.fields[0].index]
        soundcard=nil if @form.fields[0].index==0
        $interface_soundcard=soundcard
                writeini($configdata + "\\interface.ini","Interface","SoundCard",$interface_soundcard)
                        ind=@form.fields[0].index
        ind=-1 if ind==0
        Bass.setdevice(ind)
        play("right")
        microphone=microphones[@form.fields[1].index]
        microphone=nil if @form.fields[1].index==0
        $interface_microphone=microphone
                writeini($configdata + "\\interface.ini","Interface","Microphone",$interface_microphone)
        speech(_("General:info_saved"))
        speech_wait
        break
        end
      break if escape or ((enter or space) and @form.index==3)
    end
    $scene=Scene_Main.new
  end
  end
#Copyright (C) 2014-2019 Dawid Pieper