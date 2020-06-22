#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Main
  @@acselindex=nil
  def main
    NVDA.braille("") if NVDA.check
    if $restart==true
      $restart=false
      $scene=Scene_Loading.new
      end
            dialog_close if $dialogopened
    waiting_end if $waitingopened
        $silentstart=false
    if Thread::current != $mainthread
      t = Thread::current
loop_update
                  t.exit
                end
                if $preinitialized!=true
                              $preinitialized = true
            if FileTest.exists?("#{Dirs.eltendata}\\playlist.eps")
      $playlist = load_data("#{Dirs.eltendata}\\playlist.eps")
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
                                                                                                                                      if (($nbeta > $beta) and $isbeta==1) and $denyupdate != true
                            if $portable != 1
      #$scene = Scene_Update_Confirmation.new($scene)
      #return
    else
      alert(p_("Main", "A new beta version of the program is available."))
            end
    end                                                                                                              
              $speech_lasttext = ""
        $ctrldisable = false
        key_update
        ci = 0
plsinfo = false
      ci += 1 if ci < 20
if plsinfo == false and $playlist.size > 0
      if speech_actived == false
  plsinfo = true
selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@sel = ListBox.new(selt,p_("Main", "Playlist"),$playlistindex,0,true)
@form=Form.new([@sel,Static.new(p_("Main", "Player")),Button.new(p_("Main", "Shuffle")),Button.new(p_("Main", "Delete the playlist"))],0,true)
@form.fields[2..3]=[nil,nil] if Session.name=="guest"
    end
  end
  if @form==nil
acsel_load
    end
  #speak(p_("Main", "Press the alt key to open the menu."))
  loop do
  loop_update
      if @form != nil
        @form.update
      else
        @acsel.update
        if $key[0x2e]
          confirm(p_("Main", "Are you sure you want to delete this quick action?")) {
          QuickActions.delete(@acsel.index)
  acsel_load
          }
        end
        if $keyr[0x10]
          if @acsel.index>0 && arrow_up
    QuickActions.up(@acsel.index)
    @acsel.index-=1
    acsel_load
  end
  if @acsel.index<@actions.size-1 and arrow_down
    QuickActions.down(@acsel.index)
    @acsel.index+=1
    acsel_load
    end
          end
        if @acsel.selected?
          @actions[@acsel.index].call
          end
        end
                $scene = Scene_Forum.new if $key[115] == true and $key[0x10] == false
        if escape
      quit
    end
if arrow_left and @sel != nil and @form.index == 0
  $playlistbuffer.position -= 5
end
if arrow_right and @sel != nil and @form.index == 0
  $playlistbuffer.position += 5
end
if (space or enter) and @sel != nil and @form != nil
  if @form.index == 0 and enter
    delay(0.5)
  $playlistindex = @sel.index
  $playlistlastindex = -1
elsif @form.index == 2
ind=$playlistindex
  obj=$playlist[ind]
  $playlist.shuffle!
  newind=$playlist.find_index(obj)||0
  $playlistindex=$playlistlastindex=newind  
  selt = []
for i in 0..$playlist.size - 1
  selt.push(File.basename($playlist[i]))
end
@form.fields[0]=@sel=ListBox.new(selt,p_("Main", "Playlist"),$playlistindex,0,true)
alert(p_("Main", "Playlist shuffled"))
  elsif @form.index == 3
  $playlist=[]
  $scene=Scene_Main.new
  return
end
  end
if space and @sel != nil and @form != nil and @form.index==0
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
@form.fields[0]=@sel=ListBox.new(selt,p_("Main", "Playlist"),$playlistindex,0,true)
if selt.size > 0
@sel.sayoption
else
  $playlistbuffer.pause
  $playlistbuffer = nil
  @sel = nil
  alert(p_("Main", "Playlist removed."))
  end
  end
  if @form != nil and @form.index == 0 and $key[0x10]==true
s=false
    if arrow_up and @sel.index>0
      $playlist[@sel.index],$playlist[@sel.index-1]=$playlist[@sel.index-1],$playlist[@sel.index]
      s=true
      @sel.index-=1
    elsif arrow_down and @sel.index<$playlist.size-1
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
@sel.options=selt
@sel.sayoption
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
      $playlistbuffer.position-=1
    elsif $keyr[0x27]
      $playlistbuffer.position+=1
      end
    end
else
    rp=60
  end
              if arrow_right
                        pp=$playlistbuffer.position
        $playlistbuffer.position += 5
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
      if arrow_left
        pp=$playlistbuffer.position
        $playlistbuffer.position -= 5
                $playlistbuffer.position = 0 if $playlistbuffer.position < 5
      end
            if arrow_up
        $playlistvolume += 0.05
$playlistvolume = 0.5 if $playlistvolume == 0.6
      end
      if arrow_down
        $playlistvolume -= 0.05
$playlistvolume = 0.01 if $playlistvolume == 0
end
else
  if arrow_right
        $playlistbuffer.pan += 0.1
        $playlistbuffer.pan = 1 if $playlistbuffer.pan > 1
      end
      if arrow_left
        $playlistbuffer.pan -= 0.1
        $playlistbuffer.pan = -1 if $playlistbuffer.pan < -1
      end
            if arrow_up
        $playlistbuffer.frequency += $playlistbuffer.basefreq.to_f/100.0*2.0
      $playlistbuffer.frequency=$playlistbuffer.basefreq*1.5 if $playlistbuffer.frequency>$playlistbuffer.basefreq*1.5
        end
      if arrow_down
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
@@acselindex=@acsel.index if @acsel!=nil
end
def acsel_load
  @acselshowhidden||=false
  @@acselindex=@acsel.index if @acsel!=nil
      @actions = QuickActions.get
    @acsel = ListBox.new(@actions.map{|a|a.detail}, p_("Main", "Quick actions"), @@acselindex, 0, true)
    for i in 0...@actions.size
      @acsel.disable_item(i) if @actions[i].show==false && !@acselshowhidden
      end
    @acsel.prevent_indexspeaking=true
    @acsel.bind_context{|menu| accontext(menu)}
    @acsel.focus
    end
def accontext(menu)
  if @actions.size>0 && @acsel.index>=0 && !@acsel.ishidden(@acsel.index)
  menu.option(p_("Main", "Rename"), nil, "e") {
  label= input_text(p_("Main", "Action label"), 0, @actions[@acsel.index].label, true)

  if label!=nil
    QuickActions.rename(@acsel.index, label)
  acsel_load
  end
  }
  menu.option(p_("Main", "Change hotkey"), nil, "k") {
  s=[p_("Main", "None")]
  k=[0]
  for i in 1..11
    if i!=4
    s.push("F"+i.to_s)
    k.push(i)
    end
    s.push("SHIFT+F"+i.to_s)
    k.push(-i)
  end
  ind=k.find_index(@actions[@acsel.index].key)||0
  sel = ListBox.new(s, p_("Main", "Hotkey for action %{label}")%{'label'=>@actions[@acsel.index].label}, ind)
  loop {
  loop_update
  sel.update
  break if escape
  if sel.selected?
  key=k[sel.index]
  c=nil
@actions.each{|a| c=a if a.key==key }
if c==nil || c==@actions[@acsel.index] || key==0
  QuickActions.rekey(@acsel.index, key)
  acsel_load
  break
else
  alert(p_("Main", "This hotkey is already used by action %{action}")%{'action'=>c.label}, false)
  end
end
}
  @acsel.focus
  }
  if @acsel.index>0
    menu.option(p_("Main", "Move up")) {
    QuickActions.up(@acsel.index)
    acsel_load
    }
  end
  if @acsel.index<@actions.size-1
    menu.option(p_("Main", "Move down")) {
    QuickActions.down(@acsel.index)
    acsel_load
    }
  end
  s=p_("Main", "Hide this action")
  s=p_("Main", "Show this action") if @actions[@acsel.index].show==false
  menu.option(s) {
  QuickActions.reshow(@acsel.index, !@actions[@acsel.index].show)
    acsel_load
  }
  menu.option(p_("Main", "Delete")) {
  QuickActions.delete(@acsel.index)
  acsel_load
  }
end
s=p_("Main", "Show hidden actions")
s=p_("Main", "Hide hidden actions") if @acselshowhidden
menu.option(s, nil, "h") {
@acselshowhidden=!@acselshowhidden
acsel_load
}
  menu.option(p_("Main", "Add"), nil, "n") {
  action_add
  }
end
def action_add
  actions=[]
  actionlabels=[]
    c=QuickActions.predefined_procs
  for a in c
    actions.push(a[0])
    actionlabels.push(a[1])
  end
    g=GlobalMenu.scenes
  for m in g
    actions.push(m[1])
    actionlabels.push(m[0])
  end
  ind=selector(actionlabels, p_("Main", "Select quick action to add"), 0, -1)
  if ind>=0
    QuickActions.create(actions[ind], actionlabels[ind])
    acsel_load
  else
  @acsel.focus
  end
  end
end