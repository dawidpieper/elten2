#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Object
  include EltenAPI
  end
begin
  $volume=100
      $mainthread = Thread::current
$stopmainthread         = false
  #main
    # Prepare for transition
  Graphics.freeze
  Graphics.update
  $LOAD_PATH << "."
  # Make scene object (title screen)
  if $toscene != true
    $scene = Scene_Loading.new if $tomain == nil and $updating != true and $downloading != true and $beta_downloading != true
  $scene = Scene_Main.new if $tomain == true
  $scene = Scene_Update.new if $updating == true
  $scene = $scene if $downloading == true
  $scene = Scene_Beta_Downloaded.new if $beta_downloading == true
end
$toscene = false
  # Call main method as long as $scene is effective
  $dialogopened = false
  loop do
  if $scene != nil
    $scene.main
  else
    break
    end
  end
    writefile("temp/agent_exit.tmp","\r\n")
    $agentproc=nil
    srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=opuścił%20dyskusję") if $chat!=false
    play("logout")
  speech_wait
    for o in $procs
Win32API.new("kernel32","TerminateProcess",'ip','i').call(o,"")
    end
  if $playlistbuffer != nil
$t=false
    begin      
      $playlistpaused=true    
      $playlistbuffer.pause if $t==false
          rescue Exception
    $t=true
    retry
    end
    end
  $playlist = [] if $playlist == nil
  if $playlist.size > 0
    $playlistpaused = true
        if FileTest.exists?("#{$eltendata}\\playlist.eps")
      pls = load_data("#{$eltendata}\\playlist.eps")
      if pls != $playlist
        if simplequestion("Twoja playlista została zmieniona. Zapisać zmiany?") == 1
save_data($playlist,"#{$eltendata}\\playlist.eps")
          end
        end
      else
        if simplequestion("Czy chcesz zapisać swoją playlistę?") == 1
          save_data($playlist,"#{$eltendata}\\playlist.eps")
          end
        end
        $playlist=[]
        $playlistbuffer.close if $playlistbuffer==nil
        $playlistbuffer=nil
        else
    if FileTest.exists?("#{$eltendata}\\playlist.eps")
      if simplequestion("Czy chcesz usunąć zapisaną playlistę?") == 1
        File.delete("#{$eltendata}\\playlist.eps")
        end
            end
  end
  deldir("temp",false)
    if $recproc!=nil
    writefile("record_stop.tmp","")
    $recproc=nil
    end
    delay(1)
  # Fade out
  Graphics.transition(120)
  File.delete("temp/agent_exit.tmp") if FileTest.exists?("temp/agent_exit.tmp")
  File.delete("temp/agent_output.tmp") if FileTest.exists?("temp/agent_output.tmp")
  $exit = true
    exit
    rescue Hangup
  Graphics.update
  $toscene = true
  retry
rescue Errno::ENOENT
  # Supplement Errno::ENOENT exception
  # If unable to open file, display message and end
  filename = $!.message.sub("No such file or directory - ", "")
  print("Unable to find file #{filename}.")
  retry
rescue Reset
retry
rescue RuntimeError
  $ruer = 0 if $ruer == nil
  $ruer += 1
  if $ruer <= 10 and $DEBUG != true
    Win32API.new("kernel32","Beep",'ii','i').call(440,100)
    Graphics.update
    retry
  else
    speech("Wystąpił krytyczny błąd. Opis błędu: #{$!.message}")
    speech_wait
    sleep(0.5)
    speech("Program musi zostać zamknięty. Czy chcesz jednak wysłać raport tego błędu do twórców programu?")
    speech_wait
    @sel = menulr(["Nie","Tak"])
    loop do
      loop_update
      @sel.update
      break if enter
    end
    if @sel.index == 1
      sleep(0.15)
      bug
    end
    speech_wait
        fail
  end
rescue SystemExit
  loop_update
  quit if $keyr[0x73]
          play("list_focus") if $exit==nil
  $toscene = true
  retry if $exit == nil
  rescue Exception
  if $consoleused == true
    print $!.message.to_s + "   |   " + $@.to_s if $DEBUG
    speech("Wystąpił błąd podczas przetwarzania polecenia.")
        speech_wait
    $console_used = false
    $tomain = true
    retry
  elsif $updating != true and $beta_downloading != true and $start != nil and $downloading != true
        speech("Wystąpił krytyczny błąd. Opis błędu: #{$!.message}")
    speech_wait
    sleep(0.5)
    speech("Program musi zostać zamknięty. Czy chcesz jednak wysłać raport tego błędu do twórców programu?")
    speech_wait
    if simplequestion == 1
      sleep(0.15)
      bug
    end
sel = menulr(["Skopiuj treść błędu do schowka","Restart","Spróbuj ponownie","Uruchom tryb awaryjny","Przerwij działanie aplikacji"],true,0,"Co chcesz zrobić?")
loop do
  loop_update
  sel.update
  if enter
    if sel.index > 0
    break
  else
    msg = $!.to_s+"\r\n"+$@.to_s
    Win32API.new($eltenlib,"CopyToClipboard",'pi','i').call(msg,msg.size+1)
    speech("Skopiowano")
    end
  end
  end
    case sel.index
    when 1
      $toscene = false
      retry
      when 2
        $toscene = true
        retry
    when 3
      speech("Tryb awaryjny")
      speech_wait
      @sels = ["Wyjście","Zainstaluj program ponownie"]
      @sels += ["Podejmij próbę otwarcia forum","Podejmij próbę otwarcia wiadomości"] if $name != nil and $name != ""
      @sel = menulr(@sels)
      loop do
        loop_update
        @sel.update
        if enter
          break
        end
      end
      case @sel.index
      when 0
              fail
        when 1
        $scene = Scene_Update.new
        $toscene = true
        retry
        when 2
          $scenes.insert(0,$scene) if $scenes != nil
          $scene = Scene_Forum.new
                    $toscene = true
                    retry
          when 3
            $scenes.insert(0,$scene) if $scenes != nil
            $scene = Scene_Messages.new
            $toscene = true      
            retry
      end
        when 4
    fail if $DEBUG == true
  end
  end
  if $updating == true
    retry
  end
  if $beta_downloading == true
    retry
  end
  if $start == nil
    retry
    end
end
#Copyright (C) 2014-2016 Dawid Pieper