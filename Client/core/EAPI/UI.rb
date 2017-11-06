#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  # User interface related functions
  module UI
    # Plays a soundtheme sound
    #
    # @param voice [String] a voice name
    # @param volume [Numeric] the volume
    # @param pitch [Numeric] the pitch
    # @example
    #  play("list_focus",80,100)
    def play(voice,volume=100,pitch=100)
                        if $interface_soundthemeactivation != 0
                        if volume >= 0
                          volume = (volume.to_f * $volume.to_f / 100.0)
                        volume = 100 if volume > 100
                          volume = 1 if volume < 1
                                                volume = volume.to_i
                                              else
                                                volume = volume * -1
                                                volume = 100 if volume > 100
                                                end
                        if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mid")
                          Audio.se_play("#{$soundthemepath}/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mid")
                          Audio.bgs_play("#{$soundthemepath}/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/SE/#{voice}.wav") or FileTest.exist?("Audio/SE/#{voice}.mp3") or FileTest.exist?("Audio/SE/#{voice}.ogg") or FileTest.exist?("Audio/SE/#{voice}.mid")
                          Audio.se_play("Audio/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/BGS/#{voice}.wav") or FileTest.exist?("Audio/BGS/#{voice}.mp3") or FileTest.exist?("Audio/BGS/#{voice}.ogg") or FileTest.exist?("Audio/BGS/#{voice}.mid")
                          Audio.bgs_play("Audio/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                        end
                      end
                      # The keyboard related functions                      
                      module Keyboard
                        # @note this function is reserved
                        def GetAsyncKeyState(id)
 return(Win32API.new("user32","GetAsyncKeyState",'i','i').call(id))
end

# Determines if escape has been pressed
#
# @param fromdll [Boolean] use WinAPI instead of EltenAPI
# @return [Boolean] returns true if escape was pressed, otherwise returns false
  def escape(fromdll = false)
    if fromdll == true
    esc = Win32API.new($eltenlib,"KeyState",'i','i').call(0x1B)
    if esc > 0
      sleep(0.05)
      return(true)
    else
      return(false)
    end
  else
        r = $key[0x1B]
                  return r
    end
    end
    
    # Determines if alt has been pressed
#
# @param fromdll [Boolean] use WinAPI instead of EltenAPI
# @return [Boolean] returns true if alt was pressed, otherwise returns false
    def alt(fromdll = false)
      if fromdll == true
    alt = Win32API.new($eltenlib,"KeyState",'i','i').call(0x12)
    if alt > 0
      control = Win32API.new($eltenlib,"KeyState",'i','i').call(0x11)
      if control == 0
      sleep(0.05)
            return(true)
    else
      return(false)
      end
    else
      return(false)
    end
  else
    if $key[0x11] == false
      if $key[0xA4]
        t = Time.now.to_i
        delay
                        if Time.now.to_i <= t+1
        return true
      else
        return false
        end
              else
                return false
        end
          else
      return(false)
      end
    end
    end
    
    # Determines if enter has been pressed
#
# @param fromdll [Boolean] use WinAPI instead of EltenAPI
# @param space [Boolean] determines whether to accept a spacebar press
# @return [Boolean] returns true if enter was pressed, otherwise returns false
    def enter(fromdll = false, space = false)
      if $enter.is_a?(Integer)
        if $enter > 0
        $enter -= 1
        return true
        end
        end
      if fromdll == true
    enter = Win32API.new($eltenlib,"KeyState",'i','i').call(0x0D)
    if enter > 0
      sleep(0.05)
      return(true)
    else
      return(false)
    end
  else
    key_update if $key==nil
      if $key[0x0d] == true
      return true
    else
      return false
      end
  end
    end
    
    # Determines if spacebar has been pressed
#
# @param fromdll [Boolean] use WinAPI instead of EltenAPI
# @return [Boolean] returns true if spacebar was pressed, otherwise returns false
        def space(fromdll=false)
          if fromdll == true
    space = Win32API.new($eltenlib,"KeyState",'i','i').call(0x20)
    if space > 0
      sleep(0.05)
      return(true)
    else
      return(false)
    end
  else
return $key[0x20]
    end
  end
  
  # Updates the keyboard state
       def key_update
     $key = []
     $keyr = []
     if $keyms == nil
     $lkey = 0 if $lkey == nil
     $keyms= []
     for i in 1..255
       $keyms[i] = $advanced_keyms+5
       $keyms[i] = $advanced_ackeyms+5 if i == 0x1b
     end
               end
     for i in 1..255
       if Win32API.new($eltenlib,"KeyState",'i','i').call(i) != 0
         if ($keyms[i] > $advanced_keyms and i != 0x1b) or ($keyms[i] > $advanced_ackeyms)
           $keyms[i] = 0
           $keyms[i] = 50 if $lkey == i
                      $key[i] = true
           $lkey = i
         $keyr[i]=true
           else
           $keyms[i] += 1
           $key[i] = false
           $key[i] = true if i >= 0x10 and i <= 0x12 or i == 0x14
           $keyr[i]=true
         end
       else
         $key[i] = false
         $keyr[i]=false
         $keyms[i] = $advanced_keyms+5
         $keyms[i] = $advanced_ackeyms + 5 if i == 0x1b
                  end
       end
     end
                      
   end
   
   # Plays the sound theme voice in panorama
   #
   # @param voice [String] the voice name
   # @param pos [Float] the position from -1 (left) to 1 (right)
   # @param volume (Integer) a volume from 0 to 100
                           def playpos(voice,pos,volume=100)
                        if $interface_soundthemeactivation != 0
                        volume = (volume.to_f / 100.0 * $volume.to_f)
                                                $soundbuffer = [] if $soundbuffer == nil
                        $soundbufferid = 24 if $soundbufferid == nil
                        id = $soundbufferid
                        $soundbuffer[id] = nil
                        if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.wav")
                          $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/SE/#{voice}.wav")
                          end
                          if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mp3")
                            $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/SE/#{voice}.mp3")
                          end
                          if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.ogg")
                          $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/SE/#{voice}.ogg")
                        end
                        if FileTest.exist?("#{$soundthemepath}/BGM/#{voice}")
                          $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/BGM/#{voice}")
                        end
                        if $soundbuffer[id] != nil
                                                                                                                          $soundbuffer[id].play
                        $soundbuffer[id].pan = pos
                        $soundbuffer[id].volume = volume
                                                $soundbufferid += 1
                                                $soundbufferid = 24 if $soundbufferid > 96
                        return(id)
                      else
                        return false
                        end
                      end
                    end
                    
                    # Updates a window, speech api and keyboard state
     def loop_update
       exit if $exitproc==true
        if $exitupdate==true
       $scene=nil
       speech_stop
       end
       if $ruby == true
       while $windowminimized==true
                  sleep(0.1)
         end
         end
       tr = false
       if FileTest.exists?("temp/agent_tray.tmp")
Graphics.update if $ruby != true
         File.delete("temp/agent_tray.tmp")
tr=true
end
if $agentbug!=true
if FileTest.exists?("temp/agent_errout.tmp")
  if File.size("temp/agent_errout.tmp")>4
    $agentbug=true
    e=read("temp/agent_errout.tmp")
if simplequestion("Wystąpił nieoczekiwany błąd agenta programu Elten. Czy chcesz przesłać raport o tym zdarzeniu? Przesłanie raportu może zdecydowanie ułatwić rozwiązanie problemu.")==1
    bug(false,"Elten Agent Error:\r\n"+e)
        end
speech("Program podejmie teraz próbę powrotu do pracy.")
        s=0
        begin
      File.delete("temp/agent_errout.tmp") if s==0
    rescue Exception
      s=1
      retry
    end
        end
    end
  end
if $agentproc != nil
  x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call($agentproc,x)
x.delete!("\0")
if x != "\003\001"
                                    writefile("temp/agent.tmp","#{$name}\r\n#{$token}\r\n#{$wnd.to_s}")
    agent_start
$agentloaded = true
$agentfails=0 if $agentfails==nil
$agentfails+=1
$agentfaillasttime=0 if $agentfaillasttime==nil
if $agentfaillasttime<Time.now.to_i-5
play("right")
$wnup=0
end
$agentfaillasttime=Time.now.to_i
$wnup = 0 if $wnup == nil
$wnup += 1
$lastrefresh=0 if $lastrefresh==nil
if Time.now.to_i-30>$lastrefresh
  $lastrefresh=Time.now.to_i
  play("list_focus")
$wnup=0
  $mes = 0 if $mes == nil
  $pst = 0 if $pst == nil
  $blg = 0 if $blg == nil
srvproc("active","name=#{$name}\&token=#{$token}")
wntemp = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&get=1")
if wntemp.size > 1
  s = false
  if wntemp[1].to_i > $mes
    if $language != "PL_PL" or $gender != 0
    speech("Otrzymałeś nową wiadomość.") if $loaded == true
  else
    speech("Otrzymałaś nową wiadomość.") if $loaded == true
    end
    s = true
  end
  if wntemp[2].to_i > $pst
    speech("W śledzonym wątku pojawił się nowy wpis.") if $loaded == true
    s = true
  end
  if wntemp[3].to_i > $blg
    speech("Na śledzonym blogu pojawił się nowy wpis.") if $loaded == true
    s = true
  end
  play("new") if s == true
$loaded = true
$mes = wntemp[1].to_i
$pst = wntemp[2].to_i
$blg = wntemp[3].to_i
end
  end
end
end
$procs=[] if $procs==nil  
for o in $procs
            x="\0"*2
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(o,x)
if x != "\003\001"
  $procs.delete(o)
  end
    end
    if $ruby != true
    Graphics.update
    Input.update
  else
    sleep(0.025)
    end
  Keyboard::key_update
  if $ruby == true
  speech_stop if $key[0x11]
    else
    speech_stop if Input.trigger?(Input::CTRL) and $voice!=-1
            
      end
 if $stopmainthread == true
   if Thread::current == $subthreads.last or Thread::current == $mainthread
    Thread::stop
  end
  end
if tr == true
  for i in 0..255
    $key[i]=0
    $keyms[i]=0
  end
      Graphics.update
  Graphics.update
  play("login")
  speech("ELTEN")
  Win32API.new("user32","ShowWindow",'ii','i').call($wnd,1)
  speech_wait
  end
if $key[0x11] and $keyr[0x42] and $keyr[0x4D] and $keyr[0x55] and $name!="" and $name!=nil and $oken!="" and $token!=nil and $scene.is_a?(Scene_Events) == false and $scenes[0].is_a?(Scene_Events) == false
    $scenes.insert(0,Scene_Events.new(2))
  end
if FileTest.exists?("temp/agent_alarm.tmp") and $alarmproc!=true
  $alarmproc=true
  play("dialog_open")
  speech("Alarm!")
    until escape or enter or space
      loop_update
    end
    File.delete("temp/agent_alarm.tmp")
    play("dialog_close")
    loop_update
    $alarmproc=false
  end
  end

# Creates a simple dialog with options yes and no and returns the user's decision
#
# @param text [String] a question to ask
# @return [Numeric] return 0 if user selected no or pressed escape, returns 1 if selected yes.
def simplequestion(text="")
  text.gsub!("jesteś pewien","jesteś pewna") if $language=="PL_PL" and $gender==0
  dialog_open  
  sel = menulr(["Nie","Tak"],true,0,text)
    loop do
        loop_update
        sel.update
        if escape
          loop_update
          dialog_close  
          return(0)
    end
        if enter
      loop_update
      dialog_close
      if sel.commandoptions.size==2      
      return(sel.index)
    else
 if sel.index<=5
   return 0
 elsif sel.index <= 9
   return 1
 else
   return rand(2)
   end
      end
      end
if $keyr[0x10] and $keyr[84] and $keyr[78]
  sel = menulr(["Hmmmm, nie, podziękuję","Coś ty, oszalałeś?","Nie ma mowy","Nigdy w życiu","Pogięło cię? Jasne, że nie","Chyba masz jakieś zwidy jeśli sądzisz, że się zgodzę","W sumie, czemu nie","HMMM, kusi, pomyślmy, no ok, zgoda","Jasne, genialny pomysł","Jestem za","A ty zdecyduj"],true,0,"Możesz się szybciej decydować? "+text)
  end
      end
    end
    
    # Opens a waiting dialog
  def waiting
    f=""
    if FileTest.exist?("#{$soundthemepath}/BGS/waiting.ogg")
                      f="#{$soundthemepath}/BGS/waiting.ogg"
                    else
                      f="Audio/BGS/waiting.ogg"
                      end
          if $waitingvoice == nil
                          $waitingvoice = AudioFile.new(f,2)
                          $waitingvoice.play
                          end
                            $waitingopened = true
end

# Closes a waiting dialog
def waiting_end
    if $waitingvoice != nil
    for i in 1..10
      $waitingvoice.volume-=0.05
      delay(0.03)
      end
      $waitingvoice.close
    $waitingvoice = nil
    end
    $waitingopened = false
  end

      # Opens a dialog
  def dialog_open
            play("dialog_open")
        if FileTest.exist?("#{$soundthemepath}/BGS/dialog_background.ogg")
          if $dialogvoice == nil
                          $dialogvoice = AudioFile.new("#{$soundthemepath}/BGS/dialog_background.ogg",2)
                          $dialogvoice.play
                          end
                          end
  $dialogopened = true
end

# Closes a dialog
def dialog_close
    if $dialogvoice != nil
    $dialogvoice.close
    $dialogvoice = nil
  end
  play("dialog_close")
  $dialogopened=false
  end
  
  # Starts the recording
  #
  # @param file [String] a file you wish to record to
  # @param maxduration [Numeric] maximum duration in seconds
  # @param driver [Numeric] driver id (1 = default)
  # @param device [Numeric] device id (1 = default)
def recording_start(filename="temp/record.wav",maxduration=1800,driver=1,device=1)
  if $recproc!=nil
    writefile("record_stop.tmp","")
    loop_update
    end
$recproc=run("bin/elten_recorder.bin #{driver.to_s} #{device.to_s} #{filename} #{maxduration}",true)
end

# Stops the recording
def recording_stop
  writefile("record_stop.tmp","")
  loop_update
  $recproc=nil
    end
  
                   
include Keyboard
end
end
#Copyright (C) 2014-2016 Dawid Pieper