#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Main
  def main
        $silentstart=false
    if Thread::current != $mainthread
      t = Thread::current
loop_update
                  t.exit
                  end
            if $preinitialized == false
              if $app == nil
                if FileTest.exists?($configdata+"\\apps.dat")==false
      save_data([],$configdata+"\\apps.dat")
    end
    @installed=load_data($configdata+"\\apps.dat")
                $app = []
    for a in @installed
            url = $url + "apps/inis/#{a.ini}"
    download(url,$appsdata + "\\inis\\#{a.ini}")
                        file=readini($appsdata + "\\inis\\#{a.ini}","App","File","")
                        cls=readini($appsdata + "\\inis\\#{a.ini}","App","Class","")
if cls != "" and file != ""
  url = $url + "apps/#{file}"
    download(url,"temp/#{file}.rb")
    require("temp/#{file}")
    eval(cls+".init")
  end
        end
    $appfile = @appfile
  $appversion = @appversion
  $appdescription = @appdescription
end
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
            $thr1=Thread.new{thr1} if $thr1.alive? == false
                                    $thr2=Thread.new{thr2} if $thr2.alive? == false
                                    $thr3=Thread.new{thr3} if $thr3.alive? == false
                                    $thr4=Thread.new{thr4} if $thr4.alive? == false
                                    $thr5=Thread.new{thr5} if $thr5.alive? == false
                                                              if (($nbeta > $beta) and $isbeta==1) and $denyupdate != true
                            if $portable != 1
      $scene = Scene_Update_Confirmation.new($scene)
      return
    else
      speech("Dostępna jest nowa wersja beta programu.")
      speech_wait
      end
    end                                                                                                              
              $speech_lasttext = ""
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
    if $key[115] == true and $key[0x10] == false
            $scene = Scene_Forum.new
    end
    if escape
      quit
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
end
if space and @sel != nil
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
        $playlistlastindex=-1
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