#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Main
  def main
    if Thread::current != $mainthread
      t = Thread::current
loop_update
                  t.exit
                  end
            if $preinitialized == false
                                  apps = srvproc("apps","name=#{$name}\&token=#{$token}\&list=1")
        appname = []
    appversion = []
    appdescription = []
    appfile = []
        nb = apps[1].to_i
    l = 2
    for i in 0..nb - 1
      t = 0
      appdescription[i] = ""
      while apps[l] != "\004END\004\n" and apps[l] != nil
        t += 1
      if t > 3
      appdescription[i] += apps[l]
    elsif t == 1
      appfile[i] = apps[l].delete!("\n")
    elsif t == 2
      appname[i] = apps[l].delete!("\n")
    elsif t == 3
      appversion[i] = apps[l].delete!("\n")
    end
    l += 1
    end
    l += 1
  end
  @appname = appname
  @appversion = appversion
  @appdescription = appdescription
  @appfile = appfile
  $app = @appname
  $appstart = []
  for i in 0..@appfile.size - 1
        url = $url + "apps\\inis\\#{@appfile[i]}.ini"
    download(url,$appsdata + "\\inis\\#{@appfile[i]}.ini")
            url = $url + "apps\\#{@appfile[i]}.rb"
    download(url,"apptemp_#{appname[i]}.rb")
        require("./apptemp_#{appname[i]}.rb")
    File.delete("apptemp_#{appname[i]}.rb") if $DEBUG != true
        end
    $appfile = @appfile
  $appversion = @appversion
  $appdescription = @appdescription
    $preinitialized = true
            if FileTest.exists?("#{$eltendata}\\playlist.eps")
      $playlist = load_data("#{$eltendata}\\playlist.eps")
      else
      $playlist = [] if $playlist == nil
      end
            $playlistindex = 0 if $playlistindex == nil
            if (($nbeta > $beta) and $isbeta>0) and $denyupdate != true
      $scene = Scene_Update_Confirmation.new($scene)
      return
    end
            whatsnew(true)
      return
      end
                                    if $thr1.alive? == false
              $thr1 = Thread.new do
                begin
                loop do
                  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x11) > 0 and $speech_wait == true
                    speech_stop
                    $speech_wait = false
                    end
                  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x77) > 0
                    time = ""
                    if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
time = srvproc("time","dateformat=Y-m-d")
else
  time = srvproc("time","dateformat=H:i:s")
  end
speech(time[0])
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x75) > 0 and $volume < 100
  $volume += 5 if $volume < 100
  writeini($configdata + "\\interface.ini","Interface","MainVolume",$volume.to_s)
  play("list_focus")
  sleep(0.1)
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x74) > 0 and $volume > 1
  $volume -= 5 if $volume > 1
  play("list_focus")
  writeini($configdata + "\\interface.ini","Interface","MainVolume",$volume.to_s)
  sleep(0.1)
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x72) > 0
  Audio.bgs_stop
  run("bin\\elten_tray.bin")
  Win32API.new("user32","SetFocus",'i','i').call($wnd)
  Win32API.new("user32","ShowWindow",'ii','i').call($wnd,0)
  Graphics.update  
  Graphics.update
  play("login")
    speech("ELTEN")
    Win32API.new("user32","ShowWindow",'ii','i').call($wnd,1)
end
if $name != "" and $name != nil and $token != nil and $token != ""
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x78) > 0
    if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) <= 0 and $scene.is_a?(Scene_Contacts) == false
    $scenes.insert(0,Scene_Contacts.new)
      elsif $scene.is_a?(Scene_Online) == false and Win32API.new("user32","GetAsyncKeyState",'i','i').call(0x10) > 0
        $scenes.insert(0,Scene_Online.new)
  end
  sleep(0.1)
  end
        if Win32API.new($eltenlib,"KeyState",'i','i').call(0x79) > 0 and $scene.is_a?(Scene_WhatsNew) == false
    $scenes.insert(0,Scene_WhatsNew.new)
    sleep(0.1)
    end
  end
  sleep(0.1)
end
rescue Exception
  print $!.message
  retry
                end
                  end
              end
        if $thr2.alive? == false
          $thr2 = Thread.new do
          loop do
            begin
            if $voice != -1
              sleep(0.01)
            Win32API.new("screenreaderapi","nvdaStopSpeech",'v','i').call
            Win32API.new("screenreaderapi","jfwStopSpeech",'v','i').call
            Win32API.new("screenreaderapi","weStopSpeech",'v','i').call
                      end
              rescue Exception
        fail
      end
      end
          end
          end    
          if $thr3.alive? == false
            $thr3 = Thread.new do
              $playlistlastindex = 0
              position = -1
              loop do
                sleep(0.1)
                if $playlist != nil
              if $playlist.size > 0
                if $playlistindex != nil
if $playlistbuffer == nil
                  volume = 80
                  volume = (volume.to_f / $volume.to_f * 100.0)
                                                                                                                        $playlistbuffer = nil
                                                                            begin
                          $playlistbuffer = AudioFile.new($playlist[$playlistindex])
                        rescue Exception
                          $playlist.delete_at($playlistindex)
                          $playlistindex = 0
                          retry
                        end
                        if $playlistbuffer != nil
                                                                                                                          $playlistbuffer.play
                                                $playlistbuffer.volume = volume
                                              end                                
                                              $playlistlastindex = $playlistindex                                                             
                                              else
                                                                                                                             if $playlistbuffer.position == position
                                                                                                                               if $playlistpaused != true
                                                                                                                                                                                                                                                                   $playlistbuffer = nil 
                                                                 position = -1
                                                                 if $playlistindex == $playlistlastindex
                                                                 $playlistindex += 1
                                              $playlistindex = 0 if $playlistindex >= $playlist.size                                              
                                            end
                                          else
                                            position += 150
                                            end
                                                                                                                                                                                                   elsif position < $playlistbuffer.position
                                                               position = $playlistbuffer.position                                                               
                                                               end
                                                                 end
                             end
              end
              end
            end
                        end
            end
            if $thr4.alive? == false
              $thr4 = Thread.new do
                loop do
                  sc = $scene
                  if $scenes.size > 0
                                        $subthread = Thread.new do
                                          sleep(0.1)
                      $scene = $scenes[0]
                      $scenes.delete_at(0)
                      while $scene != nil
                        $scene.main
                                              end
                      end
                                        $stopmainthread = true
                    $subthread.value
                    $stopmainthread = false
$scene = sc
$focus = true if $scene.is_a?(Scene_Main) == false                    
$scene = Scene_Main.new if $scene.is_a?(Scene_Main)
loop_update
                    $mainthread.wakeup
                                        end
                  end
                end
              end
            if $thr5.alive? == false
                                                $thr5 = Thread.new do
                          loop do
                                                                                    if $token != "" and $token != nil and $name != "" and $name != nil
                              File.delete("agent_output.tmp") if FileTest.exists?("agent_output.tmp")
                              sleep(10)
                              if FileTest.exists?("agent_output.tmp") == false
play("right")
                                writefile("agent.tmp","#{$name}\r\n#{$token}\r\n#{$wnd.to_s}")
    $agentproc = run("bin/elten_agent.bin")
$agentloaded = true
                                end
                              end
                            end
                          end
                          end
      $speech_lasttext = ""
    speech_stop
    $ctrldisable = false
        key_update
        speech("Naciśnij klawisz ALT, aby otworzyć menu")
        ci = 0
plsinfo = false
    loop do
      ci += 1 if ci < 20
if plsinfo == false and $playlist.size > 0
      if speech_actived == false
  plsinfo = true
selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@sel = Select.new(selt,true,$playlistindex,"Playlista")
    end
  end
  loop_update
      @sel.update if @sel != nil
            if alt
        $scene = Scene_MainMenu.new
        end
    if $key[115] == true
            $scene = Scene_Forum.new
    end
    if escape
      quit
end
if Input.press?(Input::F7)
  $scene = Scene_Console.new
end
if Input.repeat?(Input::LEFT) and @sel != nil
  $playlistbuffer.position -= 5000
end
if Input.repeat?(Input::RIGHT) and @sel != nil
  $playlistbuffer.position += 5000
end
if enter and @sel != nil
  delay(0.5)
  $playlistindex = @sel.index
  $playlistlastindex = -1
  $playlistbuffer.pause if $playlistbuffer != nil
end
if space and @sel != nil
  delay(0.5)
    if $playlistpaused == true
    $playlistbuffer.play  if $playlistbuffer != nil
    $playlistpaused = false
  else
    $playlistpaused = true
    $playlistbuffer.pause if $playlistbuffer != nil
    end
  end
if $key[0x2e] and @sel != nil
  $playlist.delete_at(@sel.index)
  if @sel.index == $playlistindex
        $playlistbuffer.pause
    end
  selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@sel = Select.new(selt,true,$playlistindex,"Playlista",true)
if selt.size > 0
speech(@sel.commandoptions[@sel.index])
else
  $playlistbuffer.pause
  $playlistbuffer = nil
  @sel = nil
  speech("Playlista usunięta.")
  end
  end
  break if $scene != self
    end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper