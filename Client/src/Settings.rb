#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Settings
  def initialize
    @settings=[]
    @values={}
  end
  def currentconfig(group, key)
    return @values[[group,key]]||readconfig(group,key)
  end
  def setcurrentconfig(group,key,val)
@values[[group,key]]=val.to_s
end
def speaker_waiter
 loop do
   loop_update
   if $key.include?(true)
     speech_stop
     keys_copyvalues
     end
   break if speech_actived==false
   end
  end
  def setting_category(cat)
    @settings.push([cat, nil])
    @form.fields[0].commandoptions.push(cat)
  end
  def on_load(&func)
    return if @settings.size==0
    @settings.last[1]=func
    end
def make_setting(label, type, section, config=nil, mapping=nil)
  return if @settings.size==0
  mapping=mapping.map{|x|x.to_s} if mapping!=nil
  @settings.last.push([label, type, section, config, mapping])
end
def save_category
  for i in 2...@settings[@category].size
    setting=@settings[@category][i]
    next if setting[1]==:custom
    index=i-1
    val=@form.fields[index].value
    val=val.to_i if setting[1]==:number or setting[1]==:bool
    val=setting[4][val] if setting[4]!=nil
    setcurrentconfig(setting[2], setting[3], val)
    end
  end
def show_category(id)
  return if @form==nil or @settings[id]==nil
  save_category if @category!=nil
  @category=id
  @form.show_all
  @form.fields[1..-4]=nil
  f=[]
for s in @settings[id][2..-1]
  label, type, section, config, mapping = s
  field=nil
  case type
  when :text
    field=Edit.new(label, "", currentconfig(section, config),true)
    when :number
    field=Edit.new(label, "NUMBERS", currentconfig(section, config),true)
    when :bool
      field=CheckBox.new(label, (currentconfig(section, config).to_i!=0).to_i)
      when :custom
        field=Button.new(label)
        proc=section
        field.on(:press, 0, true) {
        proc.call
        }
    else
      index=currentconfig(section, config)
      index=mapping.find_index(index)||0 if mapping!=nil
      field=Select.new(type, true, index.to_i, label, true)
    end
@form.fields.insert(-4, field)
end
@settings[id][1].call if @settings[id][1]!=nil
end
def apply_settings
  save_category
  for k in @values.keys
    v=@values[k]
    writeconfig(k[0], k[1], v)
  end
  load_configuration
  end
def make_window
  @form=Form.new
  @form.fields[0] = Select.new([], true, 0, p_("Settings", "Category"), true)
  @form.fields[1]=Button.new(_("Apply"))
  @form.fields[2]=Button.new(_("Save"))
  @form.fields[3]=Button.new(_("Cancel"))
  end
  def load_general
    setting_category(p_("Settings", "General"))
        l=Dir.entries("locale")
    l.delete(".")
    l.delete("..")
    langsmapping=["en-GB"]
    for d in l
      if FileTest.exists?("locale/#{d}/lc_messages/elten.mo")
        langsmapping.push(d)
        end
      end
      langs=langsmapping.map{|l|$langs[l[0..1].downcase]['name']+" ("+$langs[l[0..1].downcase]['nativeName']+")"}
      make_setting(p_("Settings", "Language"), langs, "Interface", "Language", langsmapping)
                            make_setting(p_("Settings", "Automatically minimize Elten Window to system tray"), :bool, "Interface", "HideWindow")
                            d=-1
                            l=readconfig("Login","AutoLogin").to_i
                            d=l if l>0
            make_setting(p_("Settings", "Enable auto log in"), :bool, "Login", "AutoLogin", [0, d])
        make_setting(p_("Settings", "Automatically start Elten after I log on to Windows"), :bool, "System", "AutoStart")
      end
      def load_interface
        setting_category(p_("Settings", "Interface"))
                make_setting(p_("Settings", "Play sounds of soundthemes"), :bool, "Interface", "SoundThemeActivation")
                soundthemes=[p_("Settings", "Use default")]
                soundthemesmapping=[""]
               for d in Dir.entries($soundthemesdata)
                 next if d=="." or d==".."
                 dir=$soundthemesdata+"\\"+d
                 if FileTest.exists?(dir+"\\__name.txt")
                   soundthemesmapping.push(d)
                   soundthemes.push(readfile(dir+"\\__name.txt"))
                   end
                 end
                 make_setting(p_("Settings", "Sound theme"), soundthemes, "Interface", "SoundTheme", soundthemesmapping)
                 make_setting(p_("Settings", "Manage sound themes"), :custom, Proc.new{insert_scene(Scene_SoundThemes.new)})
                    make_setting(p_("Settings", "Wrap long lines in text fields"), :bool, "Interface", "LineWrapping")
            make_setting(p_("Settings", "The display method of selection lists"), [p_("Settings", "Linear"),p_("Settings", "Circular")], "Interface", "ListType")                    
            on_load {
            @form.fields[1].on(:change) {
            if @form.fields[1].checked.to_i==1
              @form.show(2)
              @form.show(3)
            else
              @form.hide(2)
              @form.hide(3)
              end
            }
            @form.fields[1].trigger(:change)
            }
        end
      def load_voice
        setting_category(p_("Settings", "Voice"))
        sel=[p_("Settings", "Use screenreader")]+listsapivoices
        make_setting(p_("Settings", "Voice"), sel, "Voice", "Voice", (-1...sel.size-1).to_a)
        make_setting(p_("Settings", "Speech rate"), (0..100).to_a.reverse.map{|x|x.to_s+"%"}, "Voice", "Rate", (0..100).to_a.reverse)
        make_setting(p_("Settings", "Speech volume"), (5..100).to_a.reverse.map{|x|x.to_s+"%"}, "Voice", "Volume", (5..100).to_a.reverse)
                        make_setting(p_("Settings", "Typing echo"), [p_("Settings", "Characters"),p_("Settings", "Words"),p_("Settings", "Characters and words"),p_("Settings", "None")], "Interface", "TypingEcho")
        on_load {
        @form.fields[1].on(:move) {
        if @form.fields[1].index==0
          @form.hide(2)
          @form.hide(3)
        else
          @form.show(2)
          @form.show(3)
          end
        }
        @form.fields[1].trigger(:move)
        @form.fields[1].on(:move) {
        speech_stop
          Win32API.new("screenreaderapi", "sapiSetVoice", 'i', 'i').call(@form.fields[1].index-1)
          vc=$voice
          $voice=@form.fields[1].index-1
          speak(@form.fields[1].commandoptions[@form.fields[1].index])
          speaker_waiter
          $voice=vc
          Win32API.new("screenreaderapi", "sapiSetVoice", 'i', 'i').call($voice)
        }
        @form.fields[2].on(:move) {
        speech_stop
        Win32API.new("screenreaderapi", "sapiSetRate", 'i', 'i').call(100-@form.fields[2].index)
                speak(@form.fields[2].commandoptions[@form.fields[2].index])
                speaker_waiter
                Win32API.new("screenreaderapi", "sapiSetRate", 'i', 'i').call($rate)
        }
        @form.fields[3].on(:move) {
        speech_stop
        Win32API.new("screenreaderapi", "sapiSetVolume", 'i', 'i').call(100-@form.fields[3].index)
        speak(@form.fields[3].commandoptions[@form.fields[3].index])
        speaker_waiter
        Win32API.new("screenreaderapi", "sapiSetVolume", 'i', 'i').call($sapivolume)
        }
        }
      end
      def load_clock
        setting_category(p_("Settings", "Clock"))
        make_setting(p_("Settings", "Clock information"), [p_("Settings", "None"),p_("Settings", "Voice and sound"),p_("Settings", "Voice only"),p_("Settings", "Sound only")], "Clock", "SayTimeType")
        make_setting(p_("Settings", "announcement time"), [p_("Settings", "every hour"),p_("Settings", "every half hour"),p_("Settings", "every quarter of an hour")], "Clock", "SayTimePeriod", [1, 2, 3])
        make_setting(p_("Settings", "Alarms"), :custom, Proc.new{insert_scene(Scene_Clock.new)})
        on_load {
        @form.fields[1].on(:move) {
        if @form.fields[1].index==0
          @form.hide(2)
        else
          @form.show(2)
          end
        }
        @form.fields[1].trigger(:move)
        }
      end
      def load_soundcards
        setting_category(p_("Settings", "Sound devices"))
        if @soundsettings==nil
            @soundcards=Bass.soundcards
            @microphones=Recorder.devices.values
    @soundcards[0]=p_("Settings", "Use Default")
    @microphones=[p_("Settings", "Use Default")]+@microphones
    @soundcardsmapping=@soundcards.dup
    @soundcardsmapping[0]=""
    @microphonesmapping=@microphones.dup
    @microphonesmapping[0]=""
    @soundsettings=true
    end
    make_setting(p_("Settings", "Output device"), @soundcards, "SoundCard", "SoundCard", @soundcardsmapping)
    make_setting(p_("Settings", "Input device"), @microphones, "SoundCard", "Microphone", @microphonesmapping)
        end
      def main
        make_window
        load_general
        load_interface
        load_voice
        load_clock
        load_soundcards
        @form.focus
        loop do
          loop_update
          @form.update
          show_category(@form.fields[0].index) if @category!=@form.fields[0].index
          if @form.fields[-3].pressed?
            apply_settings
            speak(_("Saved"))
          end
                    if @form.fields[-2].pressed? or (enter and !@form.fields[@form.index].is_a?(Button))
            apply_settings
            $scene=Scene_Main.new
          end
          if escape or @form.fields[-1].pressed?
            $scene=Scene_Main.new
          end
          break if $scene!=self
        end
      end
      end