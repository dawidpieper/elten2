    # A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 



class Scene_Conference
  def main
    if Session.name=="guest"
      alert(_("This section is unavailable for guests"))
      $scene=Scene_Main.new
      return
      end
        Conference.open if !Conference.opened?
        if !Conference.opened?
        $scene=Scene_Main.new
        return
        end
    @form = Form.new([
    st_conference = Static.new(p_("Conference", "Channel space")),
   lst_users = ListBox.new([], p_("Conference", "Channel users"), 0, 0, true),
   edt_chathistory = EditBox.new(p_("Conference", "Chat history"), EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly, "", true),
   edt_chat = EditBox.new(p_("Conference", "Chat message"), 0, "", true),
          chk_muteinput = CheckBox.new(p_("Conference", "Mute microphone"), (Conference.muted)?(1):(0)),
btn_streaming = Button.new(p_("Conference", "Objects and streaming")),
        btn_volumes=Button.new(p_("Conference", "Change volumes")),
        edt_status = EditBox.new(p_("Conference", "Status"), EditBox::Flags::ReadOnly|EditBox::Flags::MultiLine, "", true),
                chk_pushtotalk = CheckBox.new(p_("Conference", "Enable push to talk"), (Conference.pushtotalk)?(1):(0)),
        btn_pushtotalkkeys = Button.new(p_("Conference", "Set push to talk shortcut")),
        btn_save = Button.new(p_("Conference", "Save this conference to a file")),
        btn_channels = Button.new(p_("Conference", "Show channels")),
    btn_close = Button.new(p_("Conference", "Close"))
    ], 0, false, true)
    st_conference.add_tip(p_("Conference", "Use arrows to move in the channel space"))
    btn_save.label=p_("Conference", "Finish saving") if Conference.saving?
            @form.hide(btn_save) if !holds_premiumpackage("audiophile")
        lst_users.bind_context{|menu|
    if lst_users.options.size>0
      user=Conference.channel.users[lst_users.index]
      if user!=nil
      menu.useroption(user.name)
      vol=Conference.volume(user.name)
      s=p_("Conference", "Mute user")
      s=p_("Conference", "Unmute user") if vol.muted==true
      menu.option(s, nil, "m") {
      Conference.setvolume(user.name, vol.volume, !vol.muted)
      }
      menu.option(p_("Conference", "Change user volume")) {
      lst_volume = ListBox.new((0..100).to_a.reverse.map{|v|v.to_s+"%"}, p_("Conference", "User volume"), 100-vol.volume)
      lst_volume.on(:move) {
      Conference.setvolume(user.name, 100-lst_volume.index, vol.muted)
      }
      loop {
      loop_update
      lst_volume.update
      break if enter
      if escape
        Conference.setvolume(user.name, vol.volume, vol.muted)
        break
        end
      }
      }
      menu.option(p_("Conference", "Go to user"), nil, "g") {
      Conference.goto_user(user.id)
      }
      menu.option(p_("Conference", "Whisper"), nil, :space) {
      Conference.whisper(user.id)
      play 'recording_start'
      t=Time.now.to_f
      loop_update while $keyr[0x20]
      Conference.whisper(0)
      play 'recording_stop'
      speak(p_("Conference", "Hold spacebar to whisper to user")) if Time.now.to_f-t<0.25
      }
    end
    end
    }
    @close_hook = Conference.on(:close) {@form.resume}
    @status_hook = Conference.on(:status) {
        status=Conference.status
      txt=""
    txt+=p_("Conference", "Total time")+": "+(status['time']||0).round.to_s+"s\n"
    txt+=p_("Conference", "Current packet loss")+": "+(status['curpacketloss']||0).round.to_s+"%\n"
    txt+=p_("Conference", "Current latency")+": "+((status['latency']||0)*1000).round.to_s+"ms\n"
    txt+=p_("Conference", "Bytes sent")+": "+(status['sendbytes']||0).to_s+"\n"
    txt+=p_("Conference", "Bytes received")+": "+(status['receivedbytes']||0).to_s
    edt_status.settext(txt, false)
      }
    @users_hook = Conference.on(:update) {
            lst_users.options.clear
        for u in Conference.channel.users
      lst_users.options.push(u.name)
      end
    }
    @users_hook.block.call
    @text_hook = Conference.on(:text) {
    edt_chathistory.settext(Conference.texts.map{|c|c[0]+": "+c[2]}.join("\n"), false)
    }
    st_conference.on(:key_left) {Conference.move(-1, 0)}
    st_conference.on(:key_right) {Conference.move(1, 0)}
    st_conference.on(:key_up) {Conference.move(0, -1)}
    st_conference.on(:key_down) {Conference.move(0, 1)}
    edt_chat.on(:select) {
        Conference.send_text(edt_chat.text)
    edt_chat.settext("")
    }
    chk_muteinput.on(:change) {
    Conference.muted=chk_muteinput.value==1
    }
    btn_streaming.bind_context{|menu|context_streaming(menu)}
    btn_streaming.on(:press) {GlobalMenu.show(false)}
    btn_volumes.on(:press) {
    setvolumes
    @form.focus
    }
    btn_close.on(:press) {
    @form.resume
    }
    chk_pushtotalk.on(:change) {
    if chk_pushtotalk.checked==1
      @form.show(btn_pushtotalkkeys)
    else
      @form.hide(btn_pushtotalkkeys)
    end
    Conference.pushtotalk=(chk_pushtotalk.checked==1)
    LocalConfig["ConferencePushToTalk"]=chk_pushtotalk.checked
    }
    chk_pushtotalk.trigger(:change)
    btn_pushtotalkkeys.label=generate_pushtotalkkeyslabel
    btn_pushtotalkkeys.on(:press) {
    pushtotalk_setkeys
    btn_pushtotalkkeys.label=generate_pushtotalkkeyslabel
    @form.focus
    }
    btn_save.on(:press) {
    c=0
    c=selector([p_("Conference", "Save mixed stream to a file"), p_("Conference", "Save separate streams (experimental)"), _("Cancel")], "", 0, 2, 1) if !Conference.saving?
    case c
    when 0
    save
    when 1
      fullsave
      end
    if !Conference.saving?
      btn_save.label=p_("Conference", "Save this conference to a file")
    else
      btn_save.label=p_("Conference", "Finish saving") if Conference.saving?
    end
    }
@form.cancel_button = btn_close
btn_channels.on(:press) {
list_channels
loop_update
@form.focus
}
if Conference.channel.id==0
  list_channels
    end
    @form.wait if Conference.channel.id!=0
            if Conference.opened?
      if Conference.channel.id==0 or confirm(p_("Conference", "Would you like to disconnect?"))==1
        Conference.close
        end
    end
  Conference.remove_hook(@users_hook)
  Conference.remove_hook(@status_hook)
  Conference.remove_hook(@text_hook)
  Conference.remove_hook(@close_hook)
  $scene=Scene_Main.new
end
def channel_summary(ch)
  return ch.name+": "+ch.users.map{|u|u.name}.join(", ")
  end
def list_channels
        @chans=get_channelslist
      lst_channels = ListBox.new(@chans.map{|ch|channel_summary(ch)}, p_("Conference", "Channels"))
  lst_channels.bind_context{|menu|
  if lst_channels.options.size>0
    ch=@chans[lst_channels.index]
    if ch.id!=Conference.channel.id
    menu.option(p_("Conference", "Join"), nil, "j") {
        ps=nil
    ps=input_text(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true) if ch.passworded
    if !ch.passworded || ps!=nil
      if ch.spatialization==0 || load_hrtf
          Conference.join(ch.id, ps)
                    @chans=get_channelslist
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  end
  end
  lst_channels.focus
    }
  end
  menu.option(p_("Conference", "Channel details"), nil, "d") {
  txt=ch.name+"\n"
  txt+=p_("Conference", "Creator")+": "+ch.creator+"\n" if ch.creator.is_a?(String) and ch.creator!=""
  txt+=p_("Conference", "Language")+": "+ch.lang+"\n" if ch.lang!=""
    txt+=p_("Conference", "This channel is password-protected.")+"\n" if ch.passworded
  txt+=p_("Conference", "Channel bitrate")+": "+ch.bitrate.to_s+"kbps\n"
  txt+=p_("Conference", "Channel frame size")+": "+ch.framesize.to_s+"ms\n"
  txt+=p_("Conference", "Channels")+": "+((ch.channels==2)?("Stereo"):("Mono"))+"\n"
  txt+=p_("Conference", "Space Virtualization")+": "+((ch.spatialization==0)?("Panning"):("HRTF"))
  input_text(p_("Conference", "Channel details"), EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly, txt, true)
  }
  end
  if Conference.channel.id!=0
    menu.option(p_("Conference", "Leave"), nil, "l") {
    Conference.leave
    @chans=get_channelslist
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
    }
  end
  menu.option(p_("Conference", "Create channel"), nil, "n") {
  create_channel
  delay(1)
  @chans=get_channelslist
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
  }
  if Session.languages.size>0
         s=p_("Conference", "Show channels in unknown languages")
      s=p_("Conference", "Hide channels in unknown languages") if LocalConfig['ConferenceShowUnknownLanguages']==1
      menu.option(s) {
      l=1
      l=0 if LocalConfig['ConferenceShowUnknownLanguages']==1
      LocalConfig['ConferenceShowUnknownLanguages']=l
@chans=get_channelslist
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
      }
         end
  menu.option(p_("Conference", "Refresh"), nil, "r") {
  @chans=get_channelslist
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
  }
  }
  loop do
    loop_update
    lst_channels.update
    if lst_channels.selected?
      ch=@chans[lst_channels.index]
      return if Conference.channel.id==ch.id
      ps=nil
    ps=input_text(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true) if ch.passworded
    if !ch.passworded || ps!=nil
      if ch.spatialization==0 || load_hrtf
      Conference.join(ch.id, ps)
      delay(1)
      return if Conference.channel.id!=0
      end
      end
      end
    break if escape
    end
  end
  def create_channel
    bitrates=[8, 16, 24, 32, 48, 64, 96, 128, 192, 256, 320]
    framesizes=[2.5, 5.0, 10.0, 20.0, 40.0, 60.0]
    langs = []
      langnames=[]
    lnindex = 0
    for lk in Lists.langs.keys
      l = Lists.langs[lk]
      langnames.push(l["name"] + " (" + l["nativeName"] + ")")
      langs.push(lk)
      lnindex = langs.size - 1 if Configuration.language.downcase[0..1] == lk.downcase[0..1]
    end
    form = Form.new([
    edt_name = EditBox.new(p_("Conference", "Channel name"), 0, "", true),
    lst_lang = ListBox.new(langnames, p_("Conference", "Language"), lnindex, 0, true),
    lst_bitrate = ListBox.new(bitrates.map{|b|b.to_s}, p_("Conference", "Channel bitrate"), bitrates.find_index(64)||0, 0, true),
    lst_framesize = ListBox.new(framesizes.map{|f|f.to_s}, p_("Conference", "Channel frame size"), framesizes.find_index(60.0)||0, 0, true),
    lst_channels = ListBox.new(["Mono", "Stereo"], p_("Conference", "Channels"), 1, 0, true),
    lst_spatialization = ListBox.new(["Panning", "HRTF"], p_("Conference", "Space Virtualization"), 0, 0, true),
    edt_width = EditBox.new(p_("Conference", "Channel width"), EditBox::Flags::Numbers, "15", true),
    edt_height = EditBox.new(p_("Conference", "Channel height"), EditBox::Flags::Numbers, "15", true),
    chk_password = CheckBox.new(p_("Conference", "Set channel password")),
    edt_password = EditBox.new(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true),
    edt_passwordrepeat = EditBox.new(p_("Conference", "Repeat channel password"), EditBox::Flags::Password, "", true),
    btn_create = Button.new(p_("Conference", "Create")),
    btn_cancel = Button.new(p_("Conference", "Cancel"))
    ], 0, false, true)
    if !holds_premiumpackage("audiophile")
    form.hide(edt_width)
    form.hide(edt_height)
    end
    lst_bitrate.on(:move) {
    bitrate=bitrates[lst_bitrate.index]
          for i in 0...framesizes.size
            c=framesizes[i]*bitrates[lst_bitrate.index]/8*1000/1024
        if c>1280 || c<=5
          lst_framesize.disable_item(i)
          else
            lst_framesize.enable_item(i)
            end
      end
          }
    lst_bitrate.trigger(:move)
        form.hide(edt_password)
    form.hide(edt_passwordrepeat)
    chk_password.on(:change) {
    if chk_password.value==0
      form.hide(edt_password)
    form.hide(edt_passwordrepeat)
  else
    form.show(edt_password)
    form.show(edt_passwordrepeat)
      end
    }
    lst_spatialization.on(:move) {
    if lst_spatialization.index==1
      t=Time.now.to_f
      l=load_hrtf
            lst_spatialization.index=0 if l==false
            lst_spatialization.focus if Time.now.to_f-t>3
          end
          if lst_spatialization.index==0
            lst_channels.enable_item(1)
          else
            lst_channels.disable_item(1)
            end
    }
    btn_cancel.on(:press) {form.resume}
    form.cancel_button=btn_cancel
    btn_create.on(:press) {
    suc=true
    if chk_password.value==1 && (edt_password.text!=edt_passwordrepeat.text)
      speak(p_("Conference", "Entered passwords are different."))
      suc=false
      end
    suc=false if edt_name.text==""
    if suc && (edt_height.text.to_i<1 || edt_height.text.to_i<1)
      alert(p_("Conference", "Channel width and height must be at least 1"))
      suc=false
    end
    if suc && (edt_width.text.to_i>225 || edt_height.text.to_i>225)
      alert(p_("Conference", "%{value} is the maximum allowed channel width and height")%{'value'=>"225"})
      suc=false
      end
    if suc
      name=edt_name.text
      bitrate=bitrates[lst_bitrate.index]
      framesize=framesizes[lst_framesize.index]
      public=true
      password=nil
      password=edt_password.text if chk_password.value==1
      spatialization=lst_spatialization.index
      channels=lst_channels.index+1
      lang=langs[lst_lang.index]
      width=edt_width.text.to_i
      height=edt_height.text.to_i
      Conference.create(name, public, bitrate, framesize, password, spatialization, channels, lang, width, height)
      form.resume
      end
    }
    form.wait
  end
  private
  def get_channelslist
    Conference.update_channels
if Conference.channels==[]
    Conference.update_channels
  end
  chans=Conference.channels.dup
ret=[]
  knownlanguages = Session.languages.split(",").map{|lg|lg.upcase}
  for ch in chans
    ret.push(ch) if LocalConfig["ConferenceShowUnknownLanguages"]==1 || knownlanguages.size==0 || knownlanguages.include?(ch.lang[0..1].upcase)
    end
return ret
end
def chanobjects
  objs=Conference.channel.objects.deep_dup
  selt=objs.map{|o|
  if o.x==0||o.y==0
    p_("Conference", "%{name}, everywhere")%{'name'=>o.name}
  else
    p_("Conference", "%{name}, located at %{x}, %{y}")%{'name'=>o.name, 'x'=>o.x.to_s, 'y'=>o.y.to_s}
    end
  }
  sel=ListBox.new(selt, p_("Conference", "Channel objects"))
  sel.bind_context{|menu|
  menu.option(p_("Conference", "Add object"), nil, "n") {
  o=getobject
  if o!=nil
    Conference.object_add(o[0], o[1], o[2])
    delay(2)
     objs=Conference.channel.objects.deep_dup
  selt=objs.map{|o|
  if o.x==0||o.y==0
    p_("Conference", "%{name}, everywhere")%{'name'=>o.name}
  else
    p_("Conference", "%{name}, located at %{x}, %{y}")%{'name'=>o.name, 'x'=>o.x.to_s, 'y'=>o.y.to_s}
    end
  } 
  sel.options=selt
end
sel.focus
  }
  if objs.size>0
    if objs[sel.index].x!=0 && objs[sel.index].y!=0
      menu.option(p_("Conference", "Go to object"), nil, "g") {
      Conference.goto(objs[sel.index].x, objs[sel.index].y)
      }
      end
    menu.option(p_("Conference", "Remove object"), nil, :del) {
      Conference.object_remove(objs[sel.index].id)
      objs.delete_at(sel.index)
      sel.options.delete_at(sel.index)
  }
    end
  }
  loop do
    loop_update
    sel.update
    break if escape
  end
  loop_update
  end
  def getobject
    ob=srvproc("conferences_resources", {'ac'=>'list'})
    objs=[]
    for i in 0...ob[1].to_i
      objs.push({'resid'=>ob[2+i*3].delete("\r\n"), 'name'=>ob[2+i*3+1].delete("\r\n"), 'owner'=>ob[2+i*3+2].delete("\r\n")})
    end
    form=Form.new([
    lst_objects=ListBox.new(objs.map{|o|o['name']}, p_("Conference", "Available objects"), 0, 0, true),
    lst_position = ListBox.new([p_("Conference", "Here"), p_("Conference", "Everywhere")], p_("Conference", "Object position"), 0, 0, true),
    btn_ok = Button.new(p_("Conference", "Place object")),
    btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    refr=false
    lst_objects.bind_context{|menu|
    if objs.find_all{|o|o['owner']==Session.name}.size<10
      if holds_premiumpackage("audiophile")
      menu.option(p_("Conference", "Upload new sound")) {
      file=getfile(p_("Conference", "Select audio file"),Dirs.documents+"\\",false,nil,[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma",".opus",".aac",".aiff",".w64"])
      if file!=nil
        if File.size(file)>16777216
          alert(p_("Conference", "This file is too large"))
          else
        srvproc("conferences_resources", {'ac'=>'add', 'resname'=>File.basename(file, File.extname(file))}, 0, {'data'=>readfile(file)})
        refr=true
        form.resume
        end
      else
        form.focus
      end
      }
    end
    end
    if objs.size>0
      obj=objs[lst_objects.index]
      if obj['owner']==Session.name && !Conference.channel.objects.map{|o|o.resid}.include?(obj['resid'])
        menu.option(p_("Conference", "Delete")) {
        if srvproc("conferences_resources", {'ac'=>'delete', 'resid'=>obj['resid']})[0].to_i<0
        alert(_("Error"))
      else
        alert(p_("Conference", "Object deleted"))
      end
      refr=true
      form.resume
      }
        end
      end
    }
    form.cancel_button=btn_cancel
    btn_cancel.on(:press) {form.resume}
    btn_ok.on(:press) {
    if objs.size>0
    return ["$"+objs[lst_objects.index]['resid'], objs[lst_objects.index]['name'], lst_position.index]
  end
  form.resume
    }
    form.wait
    return getobject if refr
    return nil
  end
  def save
if !Conference.saving?
tm=Time.now
nm=sprintf("Conference_%04d%02d%02d%02d%02d.ogg", tm.year, tm.month, tm.day, tm.hour, tm.min)
            dialog_open
        form=Form.new([
        tr_path = FilesTree.new(p_("Conference", "Destination"),Dirs.user+"\\",true,true,"Music"),
        edt_filename = EditBox.new(p_("Conference", "File name"),0,nm,true),
        btn_save = Button.new(_("Save")),
        btn_cancel = Button.new(_("Cancel"))
        ],0,false,true)
        form.cancel_button=btn_cancel
        btn_cancel.on(:press) {form.resume}
        btn_save.on(:press) {
fl=tr_path.selected+"\\"+edt_filename.text
fl+=".ogg" if File.extname(fl).downcase!=".ogg"
        alert(p_("Conference", "Saving began"))
Conference.begin_save(fl)
        form.resume
        }
form.wait
          dialog_close
else
Conference.end_save
delay(2)
alert(p_("Conference", "Save completed"))
end
end
def fullsave
if !Conference.saving?
tm=Time.now
nm=sprintf("Conference_%04d%02d%02d%02d%02d", tm.year, tm.month, tm.day, tm.hour, tm.min)
            dialog_open
        form=Form.new([
        tr_path = FilesTree.new(p_("Conference", "Destination"),Dirs.user+"\\",true,true,"Music"),
        edt_dirname = EditBox.new(p_("Conference", "Directory name"),0,nm,true),
        btn_save = Button.new(_("Save")),
        btn_cancel = Button.new(_("Cancel"))
        ],0,false,true)
        form.cancel_button=btn_cancel
        btn_cancel.on(:press) {form.resume}
        btn_save.on(:press) {
fl=tr_path.selected+"\\"+edt_dirname.text
        alert(p_("Conference", "Saving began"))
Conference.begin_fullsave(fl)
        form.resume
        }
form.wait
          dialog_close
else
Conference.end_save
delay(2)
alert(p_("Conference", "Save completed"))
end
end
def generate_pushtotalkkeyslabel
  kb=[]
  ks=Conference.pushtotalk_keys
  for k in ks.sort
  case k
  when 0x10
    kb.push("SHIFT")
    when 0x11
      kb.push("CTRL")
      when 0x12
        kb.push("ALT")
      else
        ar=[false]*256
        ar[k]=true
        if (c=getkeychar(ar))!=""
          kb.push(char_dict(c,true))
        else
          kb=[]
          break
          end
  end
end
if kb.size==0
  return p_("Conference", "Set push to talk shortcut")
else
  return p_("Conference", "Push to talk shortcut")+": "+kb.join("+")
  end
end
def pushtotalk_setkeys
  ks=Conference.pushtotalk_keys
  keys=(65..90).to_a+(0x30..0x39).to_a+[0x20, 0xbc, 0xbd, 0xbe, 0xbf]
keymapping=keys.map{|k|kbs=[false]*256;kbs[k]=true;char_dict(getkeychar(kbs), true)}
keys.insert(0, 0)
keymapping.insert(0, p_("Conference", "No key"))
  form=Form.new([
  lst_modifiers = ListBox.new(["SHIFT", "CTRL", "ALT"], p_("Conference", "Modifiers"), 0, ListBox::Flags::MultiSelection, true),
  lst_key = ListBox.new(keymapping, p_("Conference", "Key"), 0, 0, true),
  btn_ok = Button.new(_("Save")),
  btn_cancel = Button.new(_("Cancel"))
  ], 0, false, true)
  form.cancel_button=btn_cancel
  form.accept_button=btn_ok
  lst_modifiers.selected[0]=ks.include?(0x10)
  lst_modifiers.selected[1]=ks.include?(0x11)
  lst_modifiers.selected[2]=ks.include?(0x12)
  for k in ks
    if keys.include?(k)
      lst_key.index=keys.find_index(k)
      break
      end
    end
    btn_cancel.on(:press) {form.resume}
    btn_ok.on(:press) {
    ks=[]
    ks.push(0x10) if lst_modifiers.selected[0]
    ks.push(0x11) if lst_modifiers.selected[1]
    ks.push(0x12) if lst_modifiers.selected[2]
    ks.push(keys[lst_key.index]) if lst_key.index>0
    if ks.size>0
    LocalConfig["ConferencePushToTalkKeys"]=ks
    Conference.pushtotalk_keys=ks
    form.resume
  else
    speak(p_("Conference", "No keys selected"))
    end
    }
  form.wait
end
def setvolumes
  form=Form.new([
  lst_inputvolume = ListBox.new((0..300).to_a.reverse.map{|v|v.to_s+"%"}, p_("Conference", "Input volume"), 300-Conference.input_volume, 0, true),
          lst_outputvolume = ListBox.new((0..100).to_a.reverse.map{|v|v.to_s+"%"}, p_("Conference", "Master volume"), 100-Conference.output_volume, 0, true),
        lst_streamvolume = ListBox.new((0..100).to_a.reverse.map{|v|v.to_s+"%"}, p_("Conference", "Stream volume"), 100-Conference.stream_volume, 0, true),
        btn_close = Button.new(p_("Conference", "Close"))
  ], 0, false, true)
      lst_inputvolume.on(:move) {
    Conference.input_volume=300-lst_inputvolume.index
    }
    lst_outputvolume.on(:move) {
    Conference.output_volume=100-lst_outputvolume.index
    }
    lst_streamvolume.on(:move) {
    Conference.stream_volume=100-lst_streamvolume.index
    }
    btn_close.on(:press) {form.resume}
    form.cancel_button=btn_close
    form.accept_button=btn_close
    form.wait
  end
  def context_streaming(menu)
menu.option(p_("Conference", "Channel objects")) {chanobjects}
if holds_premiumpackage("audiophile")
    if Conference.cardset?
menu.option(p_("Conference", "Remove soundcard stream")) {      Conference.remove_card}
else
menu.option(p_("Conference", "Stream from soundcard")) {
      mics=Bass.microphones
      cardid=-1
     listen=false
form=Form.new([
lst_card = ListBox.new(mics, p_("Conference", "Select soundcard to stream"), 0, 0),
chk_listen = CheckBox.new(p_("Conference", "Turn on the listening")),
btn_cardok = Button.new(p_("Conference", "Stream")),
btn_cardcancel = Button.new(_("Cancel"))
], 0, false, true)
btn_cardcancel.on(:press) {form.resume}
btn_cardok.on(:press) {
cardid=lst_card.index
listen=chk_listen.checked.to_i==1
form.resume
}
form.cancel_button=btn_cardcancel
form.accept_button = btn_cardok
form.wait
if cardid>-1
        Conference.add_card(mics[cardid], listen)
      end
      @form.focus
}
end
end
if Conference.streaming?
menu.option(p_("Conference", "Remove audio stream")) {Conference.remove_stream}
    menu.option(p_("Conference", "Scroll backward"), nil, "[") {Conference.scrollstream(-5)}
    menu.option(p_("Conference", "Scroll forward"), nil, "]") {Conference.scrollstream(5)}
    menu.option(p_("Conference", "Toggle pause"), nil, "p") {Conference.togglestream}
else
menu.option(p_("Conference", "Stream audio file")) {
      file=getfile(p_("Conference", "Select audio file"),Dirs.documents+"\\",false,nil,[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma",".opus",".aac",".aiff",".w64"])
      if file!=nil
        Conference.set_stream(file)
      end
      @form.focus
}
end
end
  end