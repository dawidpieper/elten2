# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 



class Scene_Conference
  def main
        Conference.open if !Conference.opened?
    @form = Form.new([
    st_conference = Static.new(p_("Conference", "Channel space")),
    lst_users = ListBox.new([], p_("Conference", "Channel users"), 0, 0, true),
    btn_channels = Button.new(p_("Conference", "Show channels")),
    btn_close = Button.new(p_("Conference", "Close"))
    ], 0, false, true)
    lst_users.bind_context{|menu|
    if lst_users.options.size>0
      user=Conference.channel.users[lst_users.index]
      vol=Conference.volume(user.name)
      s=p_("Conference", "Mute user")
      s=p_("Conference", "Unmute user") if vol.muted==true
      menu.option(s, nil, "m") {
      Conference.setvolume(user.name, vol.volume, !vol.muted)
      }
      end
    }
        @users_hook = Conference.on(:update) {
        play 'signal'
    lst_users.options.clear
        for u in Conference.channel.users
      lst_users.options.push(u.name)
      end
    }
    @users_hook.block.call
    st_conference.on(:key_left) {Conference.move(-1, 0)}
    st_conference.on(:key_right) {Conference.move(1, 0)}
    st_conference.on(:key_up) {Conference.move(0, -1)}
    st_conference.on(:key_down) {Conference.move(0, 1)}
    btn_close.on(:press) {
    @form.resume
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
  $scene=Scene_Main.new
end
def channel_summary(ch)
  return ch.name+": "+ch.users.map{|u|u.name}.join(", ")
  end
def list_channels
  Conference.update_channels
    if Conference.channels==[]
    Conference.update_channels
    end
  @chans=Conference.channels
  lst_channels = ListBox.new(@chans.map{|ch|channel_summary(ch)}, p_("Conference", "Channels"))
  lst_channels.bind_context{|menu|
  if lst_channels.options.size>0
    ch=@chans[lst_channels.index]
    if ch.id!=Conference.channel.id
    menu.option(p_("Conference", "Join"), nil, "j") {
          Conference.join(ch.id)
          Conference.update_channels
    @chans=Conference.channels
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
    }
    end
  end
  if Conference.channel.id!=0
    menu.option(p_("Conference", "Leave"), nil, "l") {
    Conference.leave
    Conference.update_channels
    @chans=Conference.channels
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
    }
  end
  menu.option(p_("Conference", "Create channel"), nil, "n") {
  create_channel
  Conference.update_channels
    @chans=Conference.channels
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
  }
  menu.option(p_("Conference", "Refresh"), nil, "r") {
  Conference.update_channels
    @chans=Conference.channels
  lst_channels.options=@chans.map{|ch|channel_summary(ch)}
  lst_channels.focus
  }
  }
  loop do
    loop_update
    lst_channels.update
    if lst_channels.selected?
      ch=@chans[lst_channels.index]
      Conference.join(ch.id)
      return
      end
    break if escape
    end
  end
  def create_channel
    bitrates=[8, 16, 24, 32, 48, 64, 96, 128, 196, 256, 320]
    framesizes=[2.5, 5.0, 10.0, 20.0, 40.0, 60.0]
    form = Form.new([
    edt_name = EditBox.new(p_("Conference", "Channel name"), 0, "", true),
    lst_bitrate = ListBox.new(bitrates.map{|b|b.to_s}, p_("Conference", "Channel bitrate"), bitrates.find_index(64)||0, 0, true),
    lst_framesize = ListBox.new(framesizes.map{|f|f.to_s}, p_("Conference", "Channel frame size"), framesizes.find_index(60.0)||0, 0, true),
    btn_create = Button.new(p_("Conference", "Create")),
    btn_cancel = Button.new(p_("Conference", "Cancel"))
    ], 0, false, true)
    btn_cancel.on(:press) {form.resume}
    form.cancel_button=btn_cancel
    btn_create.on(:press) {
    if edt_name.text!=""
      name=edt_name.text
      bitrate=bitrates[lst_bitrate.index]
      framesize=framesizes[lst_framesize.index]
      public=true
      password=nil
      Conference.create(name, public, bitrate, framesize, password)
      form.resume
      end
    }
    form.wait
    end
  end