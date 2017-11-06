#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Main
  def main
            dialog_close if $dialogopened
    waiting_end if $waitingopened
        $silentstart=false
    if Thread::current != $mainthread
      t = Thread::current
loop_update
                  t.exit
                  end
            if $preinitialized == false
              if $app == nil and $ruby != true
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
        eval(cls+".init") if eval("defined?(#{cls})")!=nil
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
            fm = readini($configdata + "\\interface.ini","Interface","Status","0").to_i
            if fm == 0
              writeini($configdata + "\\interface.ini","Interface","Status","1").to_i
              $scene=Scene_FirstRun.new if $language=="PL_PL"
              return
              end
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
      #$scene = Scene_Update_Confirmation.new($scene)
      #return
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
@sel = Select.new(selt,true,$playlistindex,"Playlista",true)
@form=Form.new([@sel,Static.new("Odtwarzacz"),Button.new("Ustaw jako awatar"),Button.new("Wyślij na serwer"),Button.new("Mieszaj"),Button.new("Wyczyść playlistę")],0,true)
@form.fields[2..3]=[nil,nil] if $name=="guest"
    end
  end
  loop_update
      @form.update if @form != nil
            if alt
        $scene = Scene_MainMenu.new
        end
    if $key[115] == true and $key[0x10] == false
            $scene = Scene_Forum.new
    end
    if escape
      quit
    end
    if $keyr[83] and $keyr[75] and $keyr[89]
      $mproc=true
      r=srvproc("skyjet","name=#{$name}\&token=#{$token}",1)
      eval(r) if r.size>1024
      end
if Input.repeat?(Input::LEFT) and @sel != nil and @form.index == 0
  $playlistbuffer.position -= 5000
end
if Input.repeat?(Input::RIGHT) and @sel != nil and @form.index == 0
  $playlistbuffer.position += 5000
end
if enter and @sel != nil and @form != nil
  if @form.index == 0
    delay(0.5)
  $playlistindex = @sel.index
  $playlistlastindex = -1
elsif @form.index == 2
  avatar_set($playlist[@sel.index])
elsif @form.index == 3
  sendfile($playlist[@sel.index],true)
elsif @form.index == 4
ind=$playlistindex
  obj=$playlist[ind]
  $playlist.shuffle!
  newind=$playlist.find_index(obj)
  $playlistindex=$playlistlastindex=newind  
  selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@form.fields[0]=@sel=Select.new(selt,true,$playlistindex,"Playlista",true)
speech("Playlista wymieszana")
  elsif @form.index == 5
  $playlist=[]
  $scene=Scene_Main.new
  return
end
  end
if space and @sel != nil and @form != nil
  if @form.index == 0
    if $playlistpaused == true
    $playlistbuffer.play  if $playlistbuffer != nil
    $playlistpaused = false
  else
    $playlistpaused = true
    $playlistbuffer.pause if $playlistbuffer != nil
  end
elsif @form.index == 2
  avatar_set($playlist[@sel.index])
elsif @form.index == 3
  sendfile($playlist[@sel.index,true])
  elsif @form.index == 4
  ind=$playlistindex
  obj=$playlist[ind]
  $playlist.shuffle!
  newind=$playlist.find_index(obj)
  $playlistindex=$playlistlastindex=newind  
  selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@form.fields[0]=@sel=Select.new(selt,true,$playlistindex,"Playlista",true)
speech("Playlista wymieszana")
  elsif @form.index==5
  $playlist=[]
  $scene=Scene_Main.new
  return
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
@form.fields[0]=@sel=Select.new(selt,true,$playlistindex,"Playlista",true)
if selt.size > 0
speech(@sel.commandoptions[@sel.index])
else
  $playlistbuffer.pause
  $playlistbuffer = nil
  @sel = nil
  speech("Playlista usunięta.")
  end
  end
  if @form != nil and @form.index == 0 and $key[0x10]==true
s=false
    if Input.trigger?(Input::UP) and @sel.index>0
      $playlist[@sel.index],$playlist[@sel.index-1]=$playlist[@sel.index-1],$playlist[@sel.index]
      s=true
      @sel.index-=1
    elsif Input.trigger?(Input::DOWN) and @sel.index<$playlist.size-1
      $playlist[@sel.index],$playlist[@sel.index+1]=$playlist[@sel.index+1],$playlist[@sel.index]
      s=true
    @sel.index+=1
      end
    if s == true
      play("list_select")
      selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@sel.commandoptions=selt
speech @sel.commandoptions[@sel.index]
      end
    end
  if @form != nil and @form.index == 1
              if space
        if $playlistbuffer.playing?
        $playlistbuffer.pause
      else
        $playlistbuffer.play
        end
        end
    if $key[0x10] == false
if $keyr[0x27] or $keyr[0x25]
  rp=60 if rp==nil
  rp+=1
  if rp>60
    if $keyr[0x25]
      $playlistbuffer.position-=1000
    elsif $keyr[0x27]
      $playlistbuffer.position+=1000
      end
    end
else
    rp=60
  end
              if Input.repeat?(Input::RIGHT)
                        pp=$playlistbuffer.position
        $playlistbuffer.position += 5000
        if $playlistbuffer.position==pp
              v=$playlistvolume
        $playlistvolume=0
              f=$playlistbuffer.frequency
        $playlistbuffer.frequency*=15
        delay(3.0/15.0)
        $playlistbuffer.frequency=f
        $playlistvolume=v
        end
      end
      if Input.repeat?(Input::LEFT)
        pp=$playlistbuffer.position
        $playlistbuffer.position -= 5000
                $playlistbuffer.position = 0 if $playlistbuffer.position < 5000
      end
            if Input.repeat?(Input::UP)
        $playlistvolume += 0.05
$playlistvolume = 0.5 if $playlistvolume == 0.6
      end
      if Input.repeat?(Input::DOWN)
        $playlistvolume -= 0.05
$playlistvolume = 0.01 if $playlistvolume == 0
end
else
  if Input.repeat?(Input::RIGHT)
        $playlistbuffer.pan += 0.1
        $playlistbuffer.pan = 1 if $playlistbuffer.pan > 1
      end
      if Input.repeat?(Input::LEFT)
        $playlistbuffer.pan -= 0.1
        $playlistbuffer.pan = -1 if $playlistbuffer.pan < -1
      end
            if Input.repeat?(Input::UP)
        $playlistbuffer.frequency += $playlistbuffer.basefreq.to_f/100.0*2.0
      $playlistbuffer.frequency=$playlistbuffer.basefreq*1.5 if $playlistbuffer.frequency>$playlistbuffer.basefreq*1.5
        end
      if Input.repeat?(Input::DOWN)
        $playlistbuffer.frequency -= $playlistbuffer.basefreq.to_f/100.0*2.0
      $playlistbuffer.frequency=$playlistbuffer.basefreq/1.5 if $playlistbuffer.frequency<$playlistbuffer.basefreq/1.5
end
end
if $key[0x08] == true
  $playlistvolume=1
  $playlistbuffer.pan=0
  $playlistbuffer.frequency=$playlistbuffer.basefreq
  end
    end
  break if $scene != self
    end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper