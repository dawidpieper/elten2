# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_VoiceCall
  def initialize(channel=nil, channel_password=nil, users=nil)
    @channel, @channel_password = channel, channel_password
    @invite=users
    @invite=[users] if users.is_a?(String)
    @ringing_voice=nil
    @call_id=0
    end
  def main
    if Session.name=="guest"
      alert(_("This section is unavailable for guests"))
      $scene=Scene_Main.new
      return
      end
        Conference.open(true)
        if !Conference.opened?
        $scene=Scene_Main.new
        return
      end
      if @channel==nil
        @channel_password = rand(36**32).to_s(36)
        chname="VoiceCall_"+Session.name
        @channel = Conference.create(chname, false, 48, 40, @channel_password, 0, 2, nil).to_i
      else
        Conference.join(@channel, @channel_password)
      end
      if @invite.is_a?(Array)
        @invite.each{|user|invite(user)}
        ringing_play
      end
      @starttime=Time.now.to_f
      @began=false
          @form = Form.new([
   lst_users = ListBox.new([], p_("VoiceCall", "Users"), 0, 0, true),
          chk_muteinput = CheckBox.new(p_("VoiceCall", "Mute microphone"), (Conference.muted)?(1):(0)),
          lst_outputvolume = ListBox.new((0..100).to_a.reverse.map{|v|v.to_s+"%"}, p_("VoiceCall", "Master volume"), 100-Conference.output_volume, 0, true),
    @btn_close = Button.new(p_("VoiceCall", "Close"))
    ], 0, false, true)
    @update_timer=FormTimer.new(5, true) {update}
    @form.add_timer(@update_timer)
    lst_users.bind_context{|menu|
    if lst_users.options.size>0
      user=Conference.channel.users[lst_users.index]
      menu.useroption(user.name)
    end
    menu.option(p_("VoiceCall", "Invite"), nil, "n") {
user=input_user(p_("VoiceCall", "User to invite"))
if user!=nil
  if user_exists(user)
    invite(user)
  else
    alert(p_("VoiceCall", "User not found"))
    end
end
@form.focus
    }
}
    @users_hook = Conference.on(:update) {
            lst_users.options.clear
        for u in Conference.channel.users
      lst_users.options.push(u.name)
    end
    ringing_stop if Conference.channel.users.size>1
    }
    @users_hook.block.call
    lst_outputvolume.on(:move) {
    Conference.output_volume=100-lst_outputvolume.index
    }
    chk_muteinput.on(:change) {
    Conference.muted=chk_muteinput.value==1
    }
    @btn_close.on(:press) {
    if Conference.channel.users.size<=1 or confirm(p_("VoiceCall", "Would you like to hang up?"))==1
    @form.resume
    end
    }
@form.cancel_button = @btn_close
    @form.wait
            if Conference.opened?
        Conference.close
      end
      ringing_stop
  Conference.remove_hook(@users_hook)
  $scene=Scene_Main.new
end
def invite(user)
  c=srvproc("calls", {'ac'=>'call', 'channel'=>@channel, 'channel_password'=>@channel_password, 'user'=>user})
  @call_id=c[1].to_i if c[0].to_i==0
end
def update
  if Conference.channel.users.size<=1
        calling=false
        if @call_id!=0
        ac=srvproc("calls", {'ac'=>'status', 'call'=>@call_id})
        if ac[0].to_i==0
          calling=true if ac[1].to_i==1
          @call_id=0 if ac[1].to_i==0
        end
        end
      if !calling
        delay(3)
        @btn_close.press if Conference.channel.users.size<=1
        end
    end
  end
  def ringing_play
            if Configuration.soundthemeactivation==1
              snd=getsound("calling")
              if snd!=nil
                          @callingvoice ||= Bass::Sound.new(nil, 1, true, false, snd)
                                                  @callingvoice.volume=Configuration.volume.to_f/100.0
                          @callingvoice.position=0
                                                    @callingvoice.play
                                                  end
                                                  end
                                                  end
   def ringing_stop
     if @callingvoice!=nil
       @callingvoice.close
       @callingvoice=nil
       end
     end
     end