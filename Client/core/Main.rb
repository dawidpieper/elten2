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
whatsnew(true)
      return
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