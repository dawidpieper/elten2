#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_SoundCard
  def main
    soundcards=Bass.soundcards
    sc=soundcards.dup
    sc[0]=p_("SoundCard", "Use Default")
    microphones=[p_("SoundCard", "Use Default")]+Recorder.devices.values
    @form=Form.new([Select.new(sc,true,0,p_("SoundCard", "Output device"),true), Select.new(microphones,true,0,p_("SoundCard", "Input device"),true), Button.new(_("Save")), Button.new(_("Cancel"))])
    loop do
      loop_update
      @form.update
      if (enter and @form.index<=2) or (space and @form.index==2)
        soundcard=soundcards[@form.fields[0].index]
        soundcard=nil if @form.fields[0].index==0
        $interface_soundcard=soundcard
                writeconfig("SoundCard","SoundCard",$interface_soundcard)
                        ind=@form.fields[0].index
        ind=-1 if ind==0
        Bass.setdevice(ind)
        play("right")
        microphone=microphones[@form.fields[1].index]
        microphone=nil if @form.fields[1].index==0
        $interface_microphone=microphone
                writeconfig("SoundCard","Microphone",$interface_microphone)
        alert(_("Saved"))
        break
        end
      break if escape or ((enter or space) and @form.index==3)
    end
    $scene=Scene_Main.new
  end
  end