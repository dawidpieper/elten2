#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module UI
                          def play(voice,volume=100,pitch=100)
                        if $interface_soundthemeactivation != 0
                        volume = (volume.to_f * $volume.to_f / 100.0)
                        volume = 1 if volume < 1
                        volume = 100 if volume > 100
                        volume = volume.to_i
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
                      module Keyboard
                        def GetAsyncKeyState(id)
 return(Win32API.new("user32","GetAsyncKeyState",'i','i').call(id))
end

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
if Input.trigger?(Input::C) and $key[67] == false
  if space == false
    if $key[0x20] == false
      if $key[0x0d] == true
      return true
    else
      return false
      end
    else
      return false
      end
    else
  return true
  end
else
  return false
  end
  end
    end
    
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
if Win32API.new("user32","GetAsyncKeyState",'i','i').call(0x20) != 0 and Input.trigger?(Input::C)
        return true
      else
        return false
        end
    end
    end
       def key_update
     $key = []
     if $keyms == nil
     $lkey = 0 if $lkey == nil
     $keyms= []
     for i in 1..255
       $keyms[i] = $interface_keyms+5
       $keyms[i] = $interface_ackeyms+5 if i == 0x1b
     end
               end
     for i in 1..255
       if Win32API.new($eltenlib,"KeyState",'i','i').call(i) != 0
         if ($keyms[i] > $interface_keyms and i != 0x1b) or ($keyms[i] > $interface_ackeyms)
           $keyms[i] = 0
           $keyms[i] = 50 if $lkey == i
                      $key[i] = true
           $lkey = i
         else
           $keyms[i] += 1
           $key[i] = false
           $key[i] = true if i >= 0x10 and i <= 0x12 or i == 0x14
         end
       else
         $key[i] = false
         $keyms[i] = $interface_keyms+5
         $keyms[i] = $interface_ackeyms + 5 if i == 0x1b
                  end
       end
     end
                      
    end
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
     def loop_update
                     tr = false
       if FileTest.exists?("agent_tray.tmp")
Graphics.update
         File.delete("agent_tray.tmp")
tr=true
end
if $agentbug!=true
if FileTest.exists?("agent_errout.tmp")
  if File.size("agent_errout.tmp")>4
    $agentbug=true
    e=read("agent_errout.tmp")
if simplequestion("Wystąpił nieoczekiwany błąd agenta programu Elten. Czy chcesz przesłać raport o tym zdarzeniu? Przesłanie raportu może zdecydowanie ułatwić rozwiązanie problemu.")==1
    bug(false,"Elten Agent Error:\r\n"+e)
        end
speech("Program podejmie teraz próbę powrotu do pracy.")
        s=0
        begin
      File.delete("agent_errout.tmp") if s==0
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
                                    writefile("agent.tmp","#{$name}\r\n#{$token}\r\n#{$wnd.to_s}")
    $agentproc = run("bin/elten_agent.bin")
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
    speech("Otrzymałeś nową wiadomość.") if $loaded == true
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
            x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(o,x)
x.delete!("\0")
if x != "\003\001"
  $procs.delete(o)
  end
    end
Graphics.update
  Input.update
  Keyboard::key_update
    speech_stop if Input.trigger?(Input::CTRL) and $voice!=-1
Thread::stop if $stopmainthread == true and Thread::current == $mainthread
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
end
def simplequestion(text="")
  dialog_open  
  sel = SelectLR.new(["Nie","Tak"],true,0,text)
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
            return(sel.index)
      end
    end
  end
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

def dialog_close
    if $dialogvoice != nil
    $dialogvoice.close
    $dialogvoice = nil
    end
  play("dialog_close")
  $dialogopened = false
  end

def recording_start(filename="temp/record.wav",maxduration=0,driver=1,device=1)
  if $recproc!=nil
    writefile("record_stop.tmp","")
    loop_update
    end
$recproc=run("bin/elten_recorder.bin #{driver.to_s} #{device.to_s} #{filename} #{maxduration}",true)
end
def recording_stop
  writefile("record_stop.tmp","")
  loop_update
  $recproc=nil
    end
  
                   
include Keyboard
end
end
#Copyright (C) 2014-2016 Dawid Pieper