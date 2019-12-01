#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Voice
  def main
        sel = [_("Voice:opt_changesynth"),_("Voice:opt_changerate"),_("Voice:opt_changevol"),_("Voice:opt_usedefault")]
    @sel = Select.new(sel,true,0,_("Voice:head"))
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
                      writeconfig("Voice", "Voice", -1)
                                $voice = -1
                alert(_("Voice:info_useddefault"))
       end
       end
     end
  end

class Scene_Voice_Voice
  def initialize(settings=0)
    @settings = settings
    end
    def main
      @selectedvoice = false
      nv = Win32API.new("bin\\screenreaderapi", "sapiGetNumVoices", '', 'i')
      @numvoice = nv.call() - 1
      @@setvoice = Win32API.new("bin\\screenreaderapi", "sapiSetVoice", 'i', 'i')
      @@setvoice.call(0)
      @@voicename = Win32API.new("bin\\screenreaderapi", "sapiGetVoiceNameW", 'i', 'i')
              vc="\0"*1024
              Win32API.new("msvcrt", "wcscpy", 'pp', 'i').call(vc,@@voicename.call(0))
      speech(deunicode(vc))
      @curnum = 0
      loop do
loop_update
    update
    if $scene != self
      break
    end
    end
                  end
    def update
      if arrow_down
        speech_stop
        if @curnum + 1 <= @numvoice
          @curnum = @curnum + 1
        else
          @curnum = 0
        end
        @@setvoice.call(@curnum)
        vc="\0"*1024
              Win32API.new("msvcrt", "wcscpy", 'pp', 'i').call(vc,@@voicename.call(@curnum))
        speech(deunicode(vc))
      end
            if arrow_up
        speech_stop
        if @curnum - 1 >= 0
          @curnum = @curnum - 1
        else
          @curnum = @numvoice
        end
        @@setvoice.call(@curnum)
        vc="\0"*1024
              Win32API.new("msvcrt", "wcscpy", 'pp', 'i').call(vc,@@voicename.call(@curnum))
        speech(deunicode(vc))
      end
      if alt
                menu
        end
      if enter or @selectedvoice == true
                                writeconfig("Voice", "Voice", @curnum)
                $voice = @curnum.to_i
                vc="\0"*1024
              Win32API.new("msvcrt", "wcscpy", 'pp', 'i').call(vc,@@voicename.call(@curnum))
                                      mow = "#{_("Voice:info_phr_selectedvoice")}: " + deunicode(vc)
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
sel = [_("Voice:opt_select")]
sel.push(_("General:str_cancel")) if @settings != 0
@menu = menulr(sel)
loop do
loop_update
@menu.update
if enter
  case @menu.index
  when 0
@selectedvoice = true
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
return
end
end

class Scene_Voice_Rate
  def main
        sel = []
    for i in 0..100
      sel.push((100-i).to_s)
    end
        @rate = Win32API.new("bin\\screenreaderapi","sapiGetRate",'','i').call
    @startrate = @rate
    @sel = Select.new(sel,true,(100-@rate),_("Voice:head_changerate"))
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
if @rate != 100-@sel.index
  @rate = 100-@sel.index
  Win32API.new("bin\\screenreaderapi","sapiSetRate",'i','i').call(@rate)
  end
            if escape
                @rate = @startrate
        Win32API.new("bin\\screenreaderapi","sapiSetRate",'i','i').call(@rate)
        $scene = Scene_Voice.new
      end
      if enter
                     writeconfig("Voice", "Rate", @rate)
     alert(_("General:info_saved"))
     $scene = Scene_Voice.new
        end
      end
    end
    
    class Scene_Voice_Volume
  def main
        sel = []
    for i in 0..100
      sel.push((100-i).to_s)
    end
        @volume = Win32API.new("bin\\screenreaderapi","sapiGetVolume",'','i').call
    @startvolume = @volume
    @sel = Select.new(sel,true,(100-@volume),_("Voice:head_changevol"))
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
if @volume != 100-@sel.index
  @volume = 100-@sel.index
  Win32API.new("bin\\screenreaderapi","sapiSetVolume",'i','i').call(@volume)
  end
            if escape
                @volume = @startvolume
        Win32API.new("bin\\screenreaderapi","sapiSetVolume",'i','i').call(@volume)
        $scene = Scene_Voice.new
      end
      if enter
                                     writeconfig("Voice", "Volume", @volume)
     alert(_("General:info_saved"))
     $scene = Scene_Voice.new
        end
      end
    end
#Copyright (C) 2014-2019 Dawid Pieper