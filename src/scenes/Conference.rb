# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2023 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Conference
  @@lastdiceindex = 5

  def initialize(timeout = nil, prefocus = 0)
    @timeout = timeout
    @prefocus = prefocus
  end

  def main
    nick = nil
    if Session.name == "guest"
      nick = input_text(p_("Conference", "Type your nickname"), 0, "", true)
      if nick == nil
        $scene = Scene_Main.new
        return
      end
    end
    Conference.open(false, nick) if !Conference.opened?
    if !Conference.opened?
      $scene = Scene_Main.new
      return
    end
    if @timeout != nil
      @timeoutthr = Thread.new(@timeout) { |tm|
        sleep(tm)
        sleep(3)
        Conference.close if Conference.opened? && Conference.channel.users.size <= 1
      }
      @timeout = nil
    end
    @status = ""
    @form = Form.new([
      st_conference = Static.new(p_("Conference", "Channel space")),
      lst_users = ListBox.new([], p_("Conference", "Channel users")),
      edt_chathistory = EditBox.new(p_("Conference", "Chat history"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, "", true),
      edt_chat = EditBox.new(p_("Conference", "Chat message"), 0, "", true),
      btn_options = Button.new(p_("Conference", "More options")),
      btn_close = Button.new(p_("Conference", "Close"))
    ], @prefocus || 0, false, true)
    @prefocus = nil
    st_conference.add_tip(p_("Conference", "Use arrows to move in the channel space"))
    st_conference.add_tip(p_("Conference", "Use shift with left/right arrows to rotate"))
    lst_users.bind_context { |menu|
      if lst_users.options.size > 0
        user = Conference.channel.users[lst_users.index]
        if user != nil
          if user.waiting == false
            menu.useroption(user.name)
            if Conference.channel.conference_mode == 1
              if Conference.channel.administrators.include?(Session.name)
                if !Conference.channel.administrators.include?(user.name)
                  if user.speech_allowed
                    menu.option(p_("Conference", "Deny speech to this user"), nil, "-") {
                      Conference.speech_deny(user.id)
                      play("conference_speechdeny")
                    }
                  else
                    menu.option(p_("Conference", "Allow speech to this user"), nil, "+") {
                      Conference.speech_allow(user.id)
                      play("conference_speechallow")
                    }
                    menu.option(p_("Conference", "Allow speech to this user only"), nil, "=") {
                      Conference.speech_allow(user.id, true)
                      play("conference_speechdeny")
                      play("conference_speechallow")
                    }
                  end
                  menu.option(p_("Conference", "Deny speech to all users"), nil, "_") {
                    for u in Conference.channel.users
                      if !Conference.channel.administrators.include?(u.name)
                        Conference.speech_deny(u.id)
                      end
                    end
                    play("conference_speechdeny")
                  }
                end
              end
            end
            vol = Conference.volume(user.name)
            s = p_("Conference", "Mute user")
            s = p_("Conference", "Unmute user") if vol.muted == true
            menu.option(s, nil, "m") {
              Conference.setvolume(user.name, vol.volume, !vol.muted, vol.streams_muted)
              if !vol.muted
                speak(p_("Conference", "User muted"))
              else
                speak(p_("Conference", "User unmuted"))
              end
            }
            s = p_("Conference", "Mute user's streams")
            s = p_("Conference", "Unmute user's streams") if vol.streams_muted == true
            menu.option(s, nil, "w") {
              Conference.setvolume(user.name, vol.volume, vol.muted, !vol.streams_muted)
              if !vol.streams_muted
                speak(p_("Conference", "User's streams muted"))
              else
                speak(p_("Conference", "User's streams unmuted"))
              end
            }
            menu.option(p_("Conference", "Change user volume")) {
              lst_volume = ListBox.new((0..300).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "User volume"), 300 - vol.volume, 0, false)
              lst_volume.on(:move) {
                Conference.setvolume(user.name, 300 - lst_volume.index, vol.muted, vol.streams_muted)
              }
              loop {
                loop_update
                lst_volume.update
                break if enter
                if escape
                  Conference.setvolume(user.name, vol.volume, vol.muted, vol.streams_muted)
                  break
                end
              }
            }
            menu.option(p_("Conference", "VST chain"), nil, "t") {
              if requires_premiumpackage("director")
                insert_scene(Scene_Conference_VSTS.new(user.id))
              end
            }
            menu.option(p_("Conference", "Go to user"), nil, "g") {
              Conference.goto_user(user.id)
            }
            menu.option(p_("Conference", "Read current position"), nil, "q") { speak((Conference.get_coordinates(user.id)[0..1]).map { |c| c.to_s }[0..1].join(", ")) }
            menu.option(p_("Conference", "Whisper"), nil, :space) {
              Conference.whisper(user.id)
              t = Time.now.to_f
              loop_update while $keyr[0x20]
              Conference.whisper(0)
              speak(p_("Conference", "Hold spacebar to whisper to user")) if Time.now.to_f - t < 0.25
            }
          else
            if Conference.channel.administrators.include?(Session.name)
              menu.option(p_("Conference", "Accept")) {
                Conference.accept(user.id)
              }
            end
          end
          if Conference.channel.administrators.include?(Session.name)
            menu.option(p_("Conference", "Kick")) {
              Conference.kick(user.id)
            }
          end
          if Conference.channel.administrators.include?(Session.name)
            if user.supervisor == nil || user.supervisor == 0
              menu.option(p_("Conference", "Take over this user's stream")) {
                if requires_premiumpackage("director") && user.name != Session.name
                  Conference.supervise(user.id)
                end
              }
            else
              menu.option(p_("Conference", "Abandon this user's stream")) {
                Conference.unsupervise(user.id)
              }
            end
          end
        end
      end
      menu.option(p_("Conference", "Invite"), nil, "n") {
        timeout_break
        user = input_user(p_("Conference", "User to invite"))
        if user != nil
          if user_exists(user)
            invite(user)
          else
            alert(p_("Conference", "User not found"))
          end
        end
        @form.focus
      }
      menu.submenu(p_("Conference", "Conference")) { |menu| context(menu) }
    }
    @close_hook = Conference.on(:close) { @form.resume }
    @status_hook = Conference.on(:status) {
      status = Conference.status
      txt = ""
      txt += p_("Conference", "Total time") + ": " + (status["time"] || 0).round.to_s + "s\n"
      txt += p_("Conference", "Current packet loss") + ": " + (status["curpacketloss"] || 0).round.to_s + "%\n"
      txt += p_("Conference", "Current latency") + ": " + ((status["latency"] || 0) * 1000).round.to_s + "ms\n"
      txt += p_("Conference", "Bytes sent") + ": " + (status["sendbytes"] || 0).to_s + "\n"
      txt += p_("Conference", "Bytes received") + ": " + (status["receivedbytes"] || 0).to_s
      @status = txt
    }
    @waitingchannel_hook = Conference.on(:waitingchannel) {
      if Conference.waiting_channel_id != 0
        @lastwaitingchannel = Conference.waiting_channel_id
        alert(p_("Conference", "Please wait, you will be accepted soon."))
      elsif @lastwaitingchannel != Conference.waiting_channel_id
        @lastwaitingchannel = Conference.waiting_channel_id
        play("conference_userknock")
      end
    }
    @users_hook = Conference.on(:update) {
      lastuser = nil
      lastuser = @lastusers[lst_users.index] if @lastusers.is_a?(Array)
      timeout_break if Conference.channel.users.size > 1
      lst_users.options.clear
      ind = nil
      for u in Conference.channel.users
        s = u.name
        if u.supervisor != nil && u.supervisor != ""
          su = Conference.channel.users.find { |us| us.id == u.supervisor }
          supervisor = ""
          supervisor = su.name if su != nil
          s += " (" + p_("Conference", "Stream taken over by %{supervisor}") % { "supervisor" => supervisor } + ")"
        end
        s += "\004NEW\004" if u.waiting
        s += "\004FUTURE\004" if u.speech_requested
        lst_users.options.push(s)
        ind = lst_users.options.size - 1 if u.name == lastuser
      end
      lst_users.index = ind if ind != nil
      @lastusers = Conference.channel.users.map { |u| u.name }
      motd = Conference.channel.motd || ""
      if motd != ""
        motdh = sha1(motd).unpack("H*").first
        motds = {}
        motdsfile = Dirs.eltendata + "\\conferences_motds.json"
        if FileTest.exists?(motdsfile)
          begin
            m = JSON.load(readfile(motdsfile))
            motds = m if m.is_a?(Hash)
          rescue Exception
          end
        end
        if motds[Conference.channel.uuid] != motdh
          motds[Conference.channel.uuid] = motdh
          begin
            writefile(motdsfile, JSON.generate(motds))
          rescue Exception
          end
          form = Form.new([
            edt_motd = EditBox.new(p_("Conference", "Message of the day"), EditBox::Flags::ReadOnly | EditBox::Flags::MultiLine, motd, true),
            btn_ok = Button.new(p_("Conference", "OK"))
          ], 0, false, true)
          form.cancel_button = btn_ok
          btn_ok.on(:press) { form.resume }
          form.wait
        end
      end
    }
    @users_hook.block.call
    @text_hook = Conference.on(:text) {
      edt_chathistory.set_text(Conference.texts.map { |c|
        if c[2].is_a?(String)
          c[0] + ": " + c[2]
        else
          params = c[3]
          case c[2]
          when :diceroll
            np_("Conference", "%{user} has rolled %{value} dot on a %{count}-sided dice", "%{user} has rolled %{value} dots on a %{count}-sided dice", params[0].to_i) % { "user" => c[0], "value" => params[0].to_s, "count" => params[1].to_s }
          end
        end
      }.join("\n"), false)
    }
    @text_hook.block.call
    @refresh_cardboard = false
    @cardboard_hook = Conference.on(:cardboard) { @refresh_cardboard = true }
    st_conference.on(:key_left) {
      if !$keyr[0x10]
        Conference.move(-1, 0)
      else
        Conference.turn(-45)
      end
    }
    st_conference.on(:key_right) {
      if !$keyr[0x10]
        Conference.move(1, 0)
      else
        Conference.turn(45)
      end
    }
    st_conference.on(:key_up) { Conference.move(0, -1) }
    st_conference.on(:key_down) { Conference.move(0, 1) }
    st_conference.bind_context { |menu|
      menu.option(p_("Conference", "Read current position"), nil, :q) { speak(Conference.get_coordinates.map { |c| c.to_s }.join(", ")) }
      menu.option(p_("Conference", "Read channel size"), nil, :e) { speak([Conference.channel.width, Conference.channel.height].map { |c| c.to_s }.join(", ")) }
      menu.submenu(p_("Conference", "Conference")) { |menu| context(menu) }
    }
    edt_chat.on(:select) {
      Conference.send_text(edt_chat.text)
      edt_chat.set_text("")
    }
    btn_close.on(:press) {
      @form.resume
    }
    @form.cancel_button = btn_close
    btn_options.bind_context { |menu| context(menu) }
    btn_options.on(:press) { $opencontextmenu = true }
    btn_close.bind_context { |menu| context(menu) }
    edt_chathistory.bind_context { |menu| context(menu) }
    edt_chat.bind_context { |menu| context(menu) }
    if Conference.channel.id == 0
      list_channels
    end
    @form.wait if Conference.channel.id != 0
    if Conference.opened?
      if (Conference.channel.id == 0 and Conference.waiting_channel_id == 0) or confirm(p_("Conference", "Would you like to disconnect?")) == 1
        Conference.close
      end
    end
    Conference.remove_hook(@waitingchannel_hook)
    Conference.remove_hook(@users_hook)
    Conference.remove_hook(@status_hook)
    Conference.remove_hook(@text_hook)
    Conference.remove_hook(@close_hook)
    Conference.remove_hook(@cardboard_hook)
    timeout_break
    $scene = Scene_Main.new
  end

  def invite(user)
    c = srvproc("calls", { "ac" => "call", "channel" => Conference.channel.id, "channel_password" => Conference.channel.password, "user" => user })
    @call_id = c[1].to_i if c[0].to_i == 0
  end

  def channel_summary(ch)
    sname, susers = ch.name, ch.users.map { |u| u.name }.join(", ")
    sname += " \004CLOSED\004" if ch.passworded
    sname += " \004RESTRICTED\004" if ch.waiting_type > 0
    return sname, susers
  end

  def list_channels(user = nil)
    setuser = nil
    timeout_break
    @chans = get_channelslist
    channels = []
    lst_channels = TableBox.new(["", ""], [], 0, p_("Conference", "Channels"))
    locha = Proc.new { |chans|
      knownlanguages = Session.languages.split(",").map { |lg| lg.upcase }
      channels = chans.find_all { |c|
        if LocalConfig["ConferenceShowUnknownLanguages"] == 1 || knownlanguages.size == 0 || knownlanguages.include?(c.lang[0..1].upcase)
          if user == nil
            c.users.size > 0 || (c.groupid != nil && c.groupid != 0) || c.creator == Session.name
          else
            c.creator == user
          end
        else
          false
        end
      }
      selt = channels.map { |ch| channel_summary(ch) }
      lst_channels.rows = selt
      lst_channels.reload
    }
    locha.call(@chans)
    lst_channels.focus
    lst_channels.bind_context { |menu|
      if channels.size > 0
        ch = channels[lst_channels.index]
        if ch.id != Conference.channel.id
          menu.option(p_("Conference", "Join"), nil, "j") {
            ps = nil
            if ch.passworded
              ps = input_text(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true)
              loop_update
            end
            if ps != nil || !ch.passworded
              if !ch.passworded || ps != nil
                if ch.spatialization == 0 || load_hrtf
                  Conference.join(ch.id, ps)
                  @chans = get_channelslist
                  locha.call(@chans)
                end
              end
            end
            lst_channels.focus
          }
        end
        if ch.passworded == false
          if ch.followed == false
            menu.option(p_("Conference", "Follow"), nil, "l") {
              Conference.follow(ch.id)
              speak(p_("Conference", "Channel followed"))
              @chans = get_channelslist
              locha.call(@chans)
            }
          else
            menu.option(p_("Conference", "Unfollow"), nil, "l") {
              Conference.unfollow(ch.id)
              speak(p_("Conference", "Channel unfollowed"))
              @chans = get_channelslist
              locha.call(@chans)
            }
          end
        end
        menu.option(p_("Conference", "Channel details"), nil, "d") {
          txt = ch.name + "\n"
          txt += p_("Conference", "Creator") + ": " + ch.creator + "\n" if ch.creator.is_a?(String) and ch.creator != ""
          txt += p_("Conference", "Administrators") + ": " + ch.administrators.join(", ") + "\n" if ch.administrators.is_a?(Array) and ch.administrators.size > 0
          txt += p_("Conference", "Language") + ": " + ch.lang + "\n" if ch.lang != ""
          txt += p_("Conference", "Followers count: ") + ": " + ch.followers_count.to_s + "\n"
          txt += p_("Conference", "This channel is password-protected.") + "\n" if ch.passworded
          txt += p_("Conference", "A waiting room is enabled on this channel.") + "\n" if ch.waiting_type > 0
          if ch.room_id != nil
            txt += p_("Conference", "Room id") + ": #{ch.room_id}\n"
            txt += p_("Conference", "URL for joining using Web Browser") + ":\n#{ch.join_url}\n\n" if ch.join_url != nil
          end
          txt += p_("Conference", "Channel bitrate") + ": " + ch.bitrate.to_s + "kbps\n"
          txt += p_("Conference", "Channel frame size") + ": " + ch.framesize.to_s + "ms\n"
          txt += p_("Conference", "Channels") + ": " + ((ch.channels == 2) ? ("Stereo") : ("Mono")) + "\n"
          txt += p_("Conference", "Space Virtualization") + ": "
          case ch.spatialization
          when 0
            txt += "Panning"
          when 1
            txt += "HRTF"
          when 2
            txt += p_("Conference", "Round table")
          end
          input_text(p_("Conference", "Channel details"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, txt, true)
        }
        if ch.administrators.include?(Session.name)
          menu.option(p_("Conference", "Edit channel"), nil, "e") {
            edit_channel(ch, @chans)
            delay(1)
            @chans = get_channelslist
            locha.call(@chans)
            lst_channels.focus
          }
        end
      end
      if Conference.channel.id != 0
        menu.option(p_("Conference", "Leave"), nil, "J") {
          Conference.leave
          @chans = get_channelslist
          locha.call(@chans)
          lst_channels.focus
        }
      end
      menu.option(p_("Conference", "Create channel"), nil, "n") {
        edit_channel(nil, @chans)
        delay(1)
        @chans = get_channelslist
        locha.call(@chans)
        lst_channels.focus
      }
      if Session.languages.size > 0
        s = p_("Conference", "Show channels in unknown languages")
        s = p_("Conference", "Hide channels in unknown languages") if LocalConfig["ConferenceShowUnknownLanguages"] == 1
        menu.option(s) {
          l = 1
          l = 0 if LocalConfig["ConferenceShowUnknownLanguages"] == 1
          LocalConfig["ConferenceShowUnknownLanguages"] = l
          @chans = get_channelslist
          locha.call(@chans)
          lst_channels.focus
        }
      end
      menu.option(p_("Conference", "Show private channels"), nil, "p") {
        knownlanguages = Session.languages.split(",").map { |lg| lg.upcase }
        users = @chans.find_all { |ch| LocalConfig["ConferenceShowUnknownLanguages"] == 1 || knownlanguages.size == 0 || knownlanguages.include?(ch.lang[0..1].upcase) }.map { |c| c.creator }.find_all { |u| u != nil }.uniq.polsort
        ind = selector(users, p_("Conference", "Select user"), 0, -1)
        if ind >= 0
          user = users[ind]
          setuser = user
        end
      }
      menu.option(p_("Conference", "Refresh"), nil, "r") {
        @chans = get_channelslist
        locha.call(@chans)
        lst_channels.focus
      }
    }
    loop do
      loop_update
      lst_channels.update
      if lst_channels.selected?
        ch = channels[lst_channels.index]
        return if Conference.channel.id == ch.id
        ps = nil
        ps = input_text(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true) if ch.passworded
        loop_update if ch.passworded
        if !ch.passworded || ps != nil
          if ch.spatialization == 0 || load_hrtf
            Conference.join(ch.id, ps)
            delay(1)
            return if Conference.channel.id != 0
          end
        end
      end
      if setuser != nil
        return list_channels(user)
      end
      if escape
        if user == nil
          break
        else
          return list_channels
        end
      end
    end
  end

  def edit_channel(channel = nil, chans = nil)
    timeout_break
    chans = get_channelslist if chans == nil
    if channel == nil
      channel = Conference::Channel.new
      channel.lang = Configuration.language.downcase[0..1]
    end
    bitrates = (6..510).to_a
    framesizes = [2.5, 5.0, 10.0, 20.0, 40.0, 60.0, 80.0, 100.0, 120.0]
    presets = [
      [p_("Conference", "Audiophile"), 384, 20, 2, 1, 1, 0, 0],
      [p_("Conference", "High quality"), 160, 40, 2, 1, 1, 0, 0],
      [p_("Conference", "Standard quality"), 80, 40, 2, 1, 0, 0, 1],
      [p_("Conference", "Standard quality with surround sound"), 96, 40, 1, 1, 0, 1, 1],
      [p_("Conference", "Standard quality with round table"), 96, 40, 1, 1, 0, 2, 1],
      [p_("Conference", "Quality for mobile or limited connections"), 56, 60, 2, 1, 0, 0, 1],
      [p_("Conference", "Quality for mobile or limited connections with surround sound"), 64, 60, 1, 1, 0, 1, 1],
      [p_("Conference", "Quality for mobile or limited connections with round table"), 64, 60, 1, 1, 0, 2, 1],
      [p_("Conference", "Low quality"), 28, 60, 1, 2, 0, 0, 1]
    ]
    prindex = presets.size
    for preset in presets
      if channel.bitrate == preset[1] and channel.framesize == preset[2] and channel.channels == preset[3] and channel.vbr_type == preset[4] and channel.codec_application == preset[5] and channel.spatialization == preset[6] and ((channel.fec) ? (1) : (0)) == preset[7] and channel.prediction_disabled == false
        prindex = presets.find_index(preset)
      end
    end
    prindex = 2 if prindex == presets.size && channel.id == 0
    langs = []
    langnames = []
    lnindex = 0
    for lk in Lists.langs.keys
      l = Lists.langs[lk]
      if (channel.groupid == 0 || channel.groupid == nil) || channel.lang.downcase[0..1] == lk.downcase[0..1]
        langnames.push(l["name"] + " (" + l["nativeName"] + ")")
        langs.push(lk)
        lnindex = langs.size - 1 if channel.lang.downcase[0..1] == lk.downcase[0..1]
      end
    end
    nameflags = 0
    nameflags |= EditBox::Flags::ReadOnly if channel.groupid != 0 && channel.groupid != nil
    kl = 0
    case channel.key_len
    when 192
      kl = 1
    when 128
      kl = 2
    when 0
      kl = 3
    end
    form = Form.new([
      edt_name = EditBox.new(p_("Conference", "Channel name"), nameflags, channel.name, true),
      lst_lang = ListBox.new(langnames, p_("Conference", "Language"), lnindex),
      edt_motd = EditBox.new(p_("Conference", "Message of the Day"), EditBox::Flags::MultiLine, channel.motd || "", true),
      lst_preset = ListBox.new(presets.map { |r| r[0] } + [p_("Conference", "Custom")], p_("Conference", "Quality preset"), prindex),
      lst_bitrate = ListBox.new(bitrates.map { |b| b.to_s + "kbps" }, p_("Conference", "Channel bitrate"), bitrates.find_index(channel.bitrate) || 0),
      lst_framesize = ListBox.new(framesizes.map { |f| s = f.to_s; s = f.to_i.to_s if f.to_i == f; s += "ms" }, p_("Conference", "Channel frame size"), framesizes.find_index(channel.framesize) || 0),
      lst_vbrtype = ListBox.new([p_("Conference", "Constant"), p_("Conference", "Variable"), p_("Conference", "Constrained variable")], p_("Conference", "Bitrate type"), channel.vbr_type),
      lst_application = ListBox.new(["VoIP", "Audio"], p_("Conference", "Codec application"), channel.codec_application),
      chk_fec = CheckBox.new(p_("Conference", "Enable forward error correction"), (channel.fec == true) ? (1) : (0)),
      chk_predictiondisabled = CheckBox.new(p_("Conference", "Disable encoding prediction"), (channel.prediction_disabled == true) ? (1) : (0)),
      lst_channels = ListBox.new(["Mono", "Stereo"], p_("Conference", "Channels"), channel.channels - 1),
      lst_spatialization = ListBox.new(["Panning", "HRTF", p_("Conference", "Round table")], p_("Conference", "Space Virtualization"), channel.spatialization),
      chk_conference = CheckBox.new(p_("Conference", "Enable conference mode (only channel administrators and allowed users can speak)"), (channel.conference_mode > 0) ? (1) : (0)),
      chk_waiting = CheckBox.new(p_("Conference", "Enable waiting room"), (channel.waiting_type > 0) ? (1) : (0)),
      chk_allowguests = CheckBox.new(p_("Conference", "Allow guests to join this channel"), (channel.allow_guests) ? (1) : (0)),
      chk_hidden = CheckBox.new(p_("Conference", "Make this channel hidden"), (channel.public) ? (0) : (1)),
      chk_permanent = CheckBox.new(p_("Conference", "Store as permanent channel"), (channel.permanent) ? (1) : (0)),
      edt_width = EditBox.new(p_("Conference", "Channel width"), EditBox::Flags::Numbers, channel.width.to_s, true),
      edt_height = EditBox.new(p_("Conference", "Channel height"), EditBox::Flags::Numbers, channel.height.to_s, true),
      edt_password = EditBox.new(p_("Conference", "Channel password (leave this field blank to set a channel without a password)"), 0, channel.password || "", true),
      lst_encryption = ListBox.new(["AES 256 CTR", "AES 192 CTR", "AES 128 CTR", p_("Conference", "None")], p_("Conference", "Channel encryption"), kl),
      btn_create = Button.new(p_("Conference", "Create")),
      btn_cancel = Button.new(p_("Conference", "Cancel"))
    ], 0, false, true)
    chk_permanent.on(:change) {
      if !holds_premiumpackage("director") && !requires_premiumpackage("audiophile")
        chk_permanent.checked = (channel.permanent) ? (1) : (0)
      end
    }

    chk_conference.on(:change) {
      if !requires_premiumpackage("director")
        chk_conference.checked = (channel.conference_mode > 0) ? (1) : (0)
      end
    }
    edt_width.on(:change) {
      if !requires_premiumpackage("director")
        edt_width.set_text(channel.width.to_s)
      end
    }
    edt_height.on(:change) {
      if !requires_premiumpackage("director")
        edt_height.set_text(channel.height.to_s)
      end
    }
    chk_hidden.on(:change) {
      if !requires_premiumpackage("director")
        chk_hidden.checked = (channel.public) ? (0) : (1)
      end
    }

    edt_width.select_all
    edt_height.select_all
    edt_name.select_all
    edt_motd.select_all
    if channel.id != 0
      btn_create.label = p_("Conference", "Edit")
    end
    if channel.conference_mode == 0
      form.hide(chk_conference)
    end
    form.hide(chk_hidden) if (channel.groupid != 0 && channel.groupid != nil)
    form.hide(chk_permanent) if (channel.groupid != 0 && channel.groupid != nil) || (channel.permanent == false && (chans.find_all { |c| c.creator == Session.name && c.permanent == true }.size >= 3))
    lst_preset.on(:move) {
      if presets.size > lst_preset.index
        preset = presets[lst_preset.index]
        lst_bitrate.index = bitrates.find_index(preset[1])
        lst_bitrate.trigger(:move)
        lst_framesize.index = framesizes.find_index(preset[2])
        lst_channels.index = preset[3] - 1
        lst_spatialization.index = preset[6]
        lst_application.index = preset[5]
        lst_vbrtype.index = preset[4]
        chk_fec.checked = preset[7]
        chk_predictiondisabled.checked = 0
        lst_bitrate.trigger(:move)
        lst_spatialization.trigger(:move)
        form.hide(lst_bitrate)
        form.hide(lst_framesize)
        form.hide(lst_vbrtype)
        form.hide(lst_application)
        form.hide(lst_channels)
        form.hide(lst_spatialization)
        form.hide(chk_fec)
        form.hide(chk_predictiondisabled)
      else
        form.show(lst_bitrate)
        form.show(lst_framesize)
        form.show(lst_vbrtype)
        form.show(lst_application)
        form.show(lst_channels)
        form.show(lst_spatialization)
        form.show(chk_fec)
        form.show(chk_predictiondisabled)
      end
    }
    lst_preset.trigger(:move)
    lst_bitrate.on(:move) {
      bitrate = bitrates[lst_bitrate.index]
      for i in 0...framesizes.size
        c = framesizes[i] * bitrates[lst_bitrate.index] / 8 * 1000 / 1024
        if c > 1280 || c <= 5
          lst_framesize.disable_item(i)
        else
          lst_framesize.enable_item(i)
        end
      end
    }
    lst_bitrate.trigger(:move)
    lst_spatialization.on(:move) {
      if lst_spatialization.index == 0
        lst_channels.enable_item(1)
      else
        lst_channels.disable_item(1)
      end
    }
    btn_cancel.on(:press) { form.resume }
    form.accept_button = btn_create
    form.cancel_button = btn_cancel
    btn_create.on(:press) {
      suc = true
      suc = false if edt_name.text == ""
      if suc && (edt_height.text.to_i < 1 || edt_height.text.to_i < 1)
        alert(p_("Conference", "Channel width and height must be at least 1"))
        suc = false
      end
      if suc && (edt_width.text.to_i > 225 || edt_height.text.to_i > 225)
        alert(p_("Conference", "%{value} is the maximum allowed channel width and height") % { "value" => "225" })
        suc = false
      end
      if suc
        if lst_spatialization.index >= 1
          t = Time.now.to_f
          l = load_hrtf
          suc = false if l == false
        end
      end
      if suc
        name = edt_name.text
        motd = edt_motd.text
        bitrate = bitrates[lst_bitrate.index]
        framesize = framesizes[lst_framesize.index]
        vbr_type = lst_vbrtype.index
        codec_application = lst_application.index
        prediction_disabled = chk_predictiondisabled.checked == 1
        fec = chk_fec.checked == 1
        public = chk_hidden.checked == 0
        password = nil
        password = edt_password.text if edt_password.text != ""
        spatialization = lst_spatialization.index
        channels = lst_channels.index + 1
        lang = ""
        if langs.size > 0
          lang = langs[lst_lang.index]
        end
        width = edt_width.text.to_i
        height = edt_height.text.to_i
        waiting_type = chk_waiting.checked
        conference_mode = chk_conference.checked
        allow_guests = chk_allowguests.checked == 1
        permanent = (chk_permanent.checked == 1)
        key_len = 256
        case lst_encryption.index
        when 1
          key_len = 192
        when 2
          key_len = 128
        when 3
          key_len = 0
        end
        if channel.id == 0
          Conference.create(name, public, bitrate, framesize, vbr_type, codec_application, prediction_disabled, fec, password, spatialization, channels, lang, width, height, key_len, waiting_type, permanent, motd, allow_guests, conference_mode)
        else
          Conference.edit(channel.id, name, public, bitrate, framesize, vbr_type, codec_application, prediction_disabled, fec, password, spatialization, channels, lang, width, height, key_len, waiting_type, permanent, motd, allow_guests, conference_mode)
        end
        form.resume
      end
    }
    form.wait
  end

  private

  def get_channelslist
    Conference.update_channels
    if Conference.channels == []
      Conference.update_channels
    end
    chans = Conference.channels.dup
    ret = chans.sort { |a, b|
      s = b.users.size <=> a.users.size
      s = a.id <=> b.id if s == 0
      s
    }
    return ret
  end

  def chanobjects
    objs = Conference.channel.objects.deep_dup
    selt = objs.map { |o|
      if o.x == 0 || o.y == 0
        p_("Conference", "%{name}, everywhere") % { "name" => o.name }
      else
        p_("Conference", "%{name}, located at %{x}, %{y}") % { "name" => o.name, "x" => o.x.to_s, "y" => o.y.to_s }
      end
    }
    sel = ListBox.new(selt, p_("Conference", "Channel scenery"), 0, 0, false)
    sel.bind_context { |menu|
      menu.option(p_("Conference", "Add object"), nil, "n") {
        o = getobject
        if o != nil
          Conference.object_add(o[0], o[1], o[2])
          delay(2)
          objs = Conference.channel.objects.deep_dup
          selt = objs.map { |o|
            if o.x == 0 || o.y == 0
              p_("Conference", "%{name}, everywhere") % { "name" => o.name }
            else
              p_("Conference", "%{name}, located at %{x}, %{y}") % { "name" => o.name, "x" => o.x.to_s, "y" => o.y.to_s }
            end
          }
          sel.options = selt
        end
        sel.focus
      }
      if objs.size > 0
        if objs[sel.index].x != 0 && objs[sel.index].y != 0
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
    ob = srvproc("conferences_resources", { "ac" => "list" })
    objs = []
    for i in 0...ob[1].to_i
      objs.push({ "resid" => ob[2 + i * 3].delete("\r\n"), "name" => ob[2 + i * 3 + 1].delete("\r\n"), "owner" => ob[2 + i * 3 + 2].delete("\r\n") })
    end
    form = Form.new([
      lst_objects = ListBox.new(objs.map { |o| o["name"] }, p_("Conference", "Available objects")),
      lst_position = ListBox.new([p_("Conference", "Here"), p_("Conference", "Everywhere")], p_("Conference", "Object position")),
      btn_ok = Button.new(p_("Conference", "Place object")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    refr = false
    lst_objects.bind_context { |menu|
      if objs.find_all { |o| o["owner"] == Session.name }.size < 10
        menu.option(p_("Conference", "Upload new sound")) {
          if requires_premiumpackage("director")
            file = get_file(p_("Conference", "Select audio file"), Dirs.documents + "\\", false, nil, [".mp3", ".wav", ".ogg", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"])
            if file != nil
              if File.size(file) > 16777216
                alert(p_("Conference", "This file is too large"))
              else
                srvproc("conferences_resources", { "ac" => "add", "resname" => File.basename(file, File.extname(file)) }, 0, { "data" => readfile(file) })
                refr = true
                form.resume
              end
            else
              form.focus
            end
          end
        }
      end
      if objs.size > 0
        obj = objs[lst_objects.index]
        if obj["owner"] == Session.name && !Conference.channel.objects.map { |o| o.resid }.include?(obj["resid"])
          menu.option(p_("Conference", "Delete")) {
            if srvproc("conferences_resources", { "ac" => "delete", "resid" => obj["resid"] })[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Conference", "Object deleted"))
            end
            refr = true
            form.resume
          }
        end
      end
    }
    form.cancel_button = btn_cancel
    btn_cancel.on(:press) { form.resume }
    btn_ok.on(:press) {
      if objs.size > 0
        return ["$" + objs[lst_objects.index]["resid"], objs[lst_objects.index]["name"], lst_position.index]
      end
      form.resume
    }
    form.wait
    return getobject if refr
    return nil
  end

  def save
    if !Conference.saving?
      tm = Time.now
      nm = sprintf("Conference_%04d%02d%02d%02d%02d.ogg", tm.year, tm.month, tm.day, tm.hour, tm.min)
      dialog_open
      form = Form.new([
        tr_path = FilesTree.new(p_("Conference", "Destination"), Dirs.user + "\\", true, true, "Music"),
        edt_filename = EditBox.new(p_("Conference", "File name"), 0, nm, true),
        btn_save = Button.new(_("Save")),
        btn_cancel = Button.new(_("Cancel"))
      ], 0, false, true)
      form.cancel_button = btn_cancel
      btn_cancel.on(:press) { form.resume }
      btn_save.on(:press) {
        fl = tr_path.selected + "\\" + edt_filename.text
        fl += ".ogg" if File.extname(fl).downcase != ".ogg"
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
      tm = Time.now
      nm = sprintf("Conference_%04d%02d%02d%02d%02d", tm.year, tm.month, tm.day, tm.hour, tm.min)
      dialog_open
      form = Form.new([
        tr_path = FilesTree.new(p_("Conference", "Destination"), Dirs.user + "\\", true, true, "Music"),
        edt_dirname = EditBox.new(p_("Conference", "Directory name"), 0, nm, true),
        btn_save = Button.new(_("Save")),
        btn_cancel = Button.new(_("Cancel"))
      ], 0, false, true)
      form.cancel_button = btn_cancel
      btn_cancel.on(:press) { form.resume }
      btn_save.on(:press) {
        fl = tr_path.selected + "\\" + edt_dirname.text
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
    kb = []
    ks = Conference.pushtotalk_keys
    for k in ks.sort
      case k
      when 0x10
        kb.push("SHIFT")
      when 0x11
        kb.push("CTRL")
      when 0x12
        kb.push("ALT")
      when 0xA0
        kb.push("SHIFT (" + p_("Conference", "Left") + ")")
      when 0xA2
        kb.push("CTRL (" + p_("Conference", "Left") + ")")
      when 0xA4
        kb.push("ALT (" + p_("Conference", "Left") + ")")
      when 0xA1
        kb.push("SHIFT (" + p_("Conference", "Right") + ")")
      when 0xA3
        kb.push("CTRL (" + p_("Conference", "Right") + ")")
      when 0xA5
        kb.push("ALT (" + p_("Conference", "Right") + ")")
      else
        ar = [false] * 256
        ar[k] = true
        if (c = getkeychar(ar)) != ""
          kb.push(char_dict(c, true))
        else
          kb = []
          break
        end
      end
    end
    if kb.size == 0
      return p_("Conference", "Set push to talk shortcut")
    else
      return p_("Conference", "Push to talk shortcut") + ": " + kb.join("+")
    end
  end

  def pushtotalk_setkeys
    timeout_break
    ks = Conference.pushtotalk_keys
    keys = (65..90).to_a + (0x30..0x39).to_a + [0x20, 0xbc, 0xbd, 0xbe, 0xbf]
    keymapping = keys.map { |k| kbs = [false] * 256; kbs[k] = true; char_dict(getkeychar(kbs), true) }
    adds = {
      0x13 => p_("Conference", "Pause key")
    }
    adds.each { |k| keys.push(k[0]); keymapping.push(k[1]) }
    keys.insert(0, 0)
    keymapping.insert(0, p_("Conference", "No key"))
    mds = ["SHIFT", "CTRL", "ALT"]
    form = Form.new([
      lst_modifiers = ListBox.new(mds.map { |m| m + " (" + p_("Conference", "Any") + ")" } + mds.map { |m| m + " (" + p_("Conference", "Left") + ")" } + mds.map { |m| m + " (" + p_("Conference", "Right") + ")" }, p_("Conference", "Modifiers"), 0, ListBox::Flags::MultiSelection),
      lst_key = ListBox.new(keymapping, p_("Conference", "Key")),
      btn_ok = Button.new(_("Save")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    form.cancel_button = btn_cancel
    form.accept_button = btn_ok
    lst_modifiers.selected[0] = ks.include?(0x10)
    lst_modifiers.selected[1] = ks.include?(0x11)
    lst_modifiers.selected[2] = ks.include?(0x12)
    lst_modifiers.selected[3] = ks.include?(0x10)
    lst_modifiers.selected[4] = ks.include?(0xA2)
    lst_modifiers.selected[5] = ks.include?(0xA4)
    lst_modifiers.selected[6] = ks.include?(0x1a)
    lst_modifiers.selected[7] = ks.include?(0xA3)
    lst_modifiers.selected[8] = ks.include?(0xA5)
    for k in ks
      if keys.include?(k)
        lst_key.index = keys.find_index(k)
        break
      end
    end
    btn_cancel.on(:press) { form.resume }
    btn_ok.on(:press) {
      ks = []
      ks.push(0x10) if lst_modifiers.selected[0]
      ks.push(0x11) if lst_modifiers.selected[1]
      ks.push(0x12) if lst_modifiers.selected[2]
      ks.push(0xA0) if lst_modifiers.selected[3]
      ks.push(0xA2) if lst_modifiers.selected[4]
      ks.push(0xA4) if lst_modifiers.selected[5]
      ks.push(0xA1) if lst_modifiers.selected[6]
      ks.push(0xA3) if lst_modifiers.selected[7]
      ks.push(0xA5) if lst_modifiers.selected[8]
      ks.push(keys[lst_key.index]) if lst_key.index > 0
      if ks.size > 0
        LocalConfig["ConferencePushToTalkKeys"] = ks
        Conference.pushtotalk_keys = ks
        form.resume
      else
        speak(p_("Conference", "No keys selected"))
      end
    }
    form.wait
  end

  def setvolumes
    timeout_break
    self.class.setvolumes
  end

  def self.setvolumes
    dialog_open
    form = Form.new([
      lst_inputvolume = ListBox.new((0..300).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "Input volume"), 300 - Conference.input_volume),
      lst_outputvolume = ListBox.new((0..100).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "Master volume"), 100 - Conference.output_volume),
      lst_streamvolume = ListBox.new((0..100).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "Stream volume"), 100 - Conference.stream_volume),
      btn_close = Button.new(p_("Conference", "Close"))
    ], 0, false, true)
    lst_inputvolume.on(:move) {
      Conference.input_volume = 300 - lst_inputvolume.index
    }
    lst_outputvolume.on(:move) {
      Conference.output_volume = 100 - lst_outputvolume.index
    }
    lst_streamvolume.on(:move) {
      Conference.stream_volume = 100 - lst_streamvolume.index
    }
    btn_close.on(:press) { form.resume }
    form.cancel_button = btn_close
    form.accept_button = btn_close
    form.wait
    dialog_close
  end

  def showstatus
    timeout_break
    st = @status
    edt = EditBox.new(p_("Conference", "Status"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, st)
    edt.focus
    loop do
      loop_update
      edt.update
      break if escape
      if @status != st
        st = @status
        edt.set_text(st, false)
      end
    end
    @form.focus
  end

  def context_streaming(menu)
    menu.option(p_("Conference", "Channel scenery"), nil, "o") { chanobjects }
    cardset = false
    cardset = true if Conference.mystreams.sources.find { |s| !s.scrollable } != nil
    for s in Conference.mystreams.streams
      cardset = true if s.sources.find { |s| !s.scrollable } != nil
    end
    if cardset
      menu.option(p_("Conference", "Remove soundcard stream")) {
        td = []
        for i in 0...Conference.mystreams.sources.size
          td.push(i) if !Conference.mystreams.sources[i].scrollable
        end
        td.reverse.each { |q| Conference.removesource(-1, q) }
        td = []
        for i in 0...Conference.mystreams.streams.size
          td.push(i) if Conference.mystreams.streams[i].sources.find { |s| !s.scrollable } != nil
        end
        td.reverse.each { |q| Conference.stream_remove(q) }
      }
    else
      menu.option(p_("Conference", "Stream from soundcard")) {
        mics = Bass.microphones
        cardid = -1
        listen = false
        form = Form.new([
          lst_card = ListBox.new(mics.map { |m| o = ""; o = " (" + p_("Conference", "Loopback device") + ")" if m.loopback?; m.name + o }, p_("Conference", "Select soundcard to stream")),
          chk_listen = CheckBox.new(p_("Conference", "Turn on the listening"), 1),
          btn_cardok = Button.new(p_("Conference", "Stream")),
          btn_cardcancel = Button.new(_("Cancel"))
        ], 0, false, true)
        for i in 0...mics.size
          lst_card.disable_item(i) if mics[i].disabled?
        end
        btn_cardcancel.on(:press) { form.resume }
        btn_cardok.on(:press) {
          cardid = lst_card.index
          listen = chk_listen.checked.to_i == 1
          form.resume
        }
        form.cancel_button = btn_cardcancel
        form.accept_button = btn_cardok
        form.wait
        if cardid > -1
          Conference.stream_add_card(cardid, mics[cardid].name, 0, 0, !listen)
        end
        @form.focus
      }
    end
    streaming = false
    streaming = true if Conference.mystreams.sources.find { |s| s.scrollable } != nil
    for s in Conference.mystreams.streams
      streaming = true if s.sources.find { |s| s.scrollable } != nil
    end
    if streaming
      menu.option(p_("Conference", "Remove audio stream"), nil, "i") {
        td = []
        for i in 0...Conference.mystreams.sources.size
          td.push(i) if Conference.mystreams.sources[i].scrollable
        end
        td.reverse.each { |q| Conference.removesource(-1, q) }
        td = []
        for i in 0...Conference.mystreams.streams.size
          td.push(i) if Conference.mystreams.streams[i].sources.find { |s| s.scrollable } != nil
        end
        td.reverse.each { |q| Conference.stream_remove(q) }
      }
      menu.option(p_("Conference", "Scroll backward"), nil, "[") { Conference.scrollstream(-5) }
      menu.option(p_("Conference", "Scroll forward"), nil, "]") { Conference.scrollstream(5) }
      menu.option(p_("Conference", "Toggle pause"), nil, "p") { Conference.togglestream }
    else
      menu.option(p_("Conference", "Stream audio file"), nil, "i") {
        formats = [".mp3", ".wav", ".ogg", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"]
        formats += [".avi", ".mp4", ".mov", ".mkv"] if holds_premiumpackage("audiophile")
        file = get_file(p_("Conference", "Select audio file"), Dirs.documents + "\\", false, nil, formats)
        if file != nil
          Conference.stream_add_file(file, File.basename(file, File.extname(file)), 0, 0)
        end
        @form.focus
      }
    end
    if Conference.shoutcast?
      menu.option(p_("Conference", "Remove shoutcast stream")) {
        if requires_premiumpackage("director")
          Conference.remove_shoutcast
        end
      }
    else
      menu.option(p_("Conference", "Stream this conference to a shoutcast server")) {
        if requires_premiumpackage("director")
          bitrates = [96, 128, 192, 256, 320]
          form = Form.new([
            lst_type = ListBox.new(["Shoutcast V2", "Shoutcast V1", "Icecast"], p_("Conference", "Server type")),
            edt_host = EditBox.new(p_("Conference", "Server"), 0, "", true),
            edt_port = EditBox.new(p_("Conference", "Port"), EditBox::Flags::Numbers, "8000", true),
            edt_streamid = EditBox.new(p_("Conference", "Stream ID"), EditBox::Flags::Numbers, "1", true),
            edt_username = EditBox.new(p_("Conference", "Username (empty for no user)"), 0, "", true),
            edt_password = EditBox.new(p_("Conference", "Password"), EditBox::Flags::Password, "", true),
            edt_name = EditBox.new(p_("Conference", "Stream name"), 0, "", true),
            lst_bitrate = ListBox.new(bitrates.map { |b| b.to_s + "kbps" }, p_("Conference", "Stream bitrate"), 1),
            chk_pub = CheckBox.new(p_("Conference", "Make this stream public")),
            btn_start = Button.new(p_("Conference", "Start")),
            btn_cancel = Button.new(_("Cancel"))
          ], 0, false, true)
          btn_cancel.on(:press) { form.resume }
          form.cancel_button = btn_cancel
          lst_type.on(:move) {
            case lst_type.index
            when 0
              form.show(edt_username)
              form.show(edt_password)
              form.show(edt_streamid)
            when 1
              form.hide(edt_username)
              form.show(edt_password)
              form.hide(edt_streamid)
            when 2
              form.show(edt_username)
              form.show(edt_password)
              form.show(edt_streamid)
            end
          }
          btn_start.on(:press) {
            server = edt_host.text + ":" + edt_port.text
            case lst_type.index
            when 0
              server += "," + edt_streamid.text
            when 2
              server += "/" + edt_streamid.text
            end
            pass = ""
            if (lst_type.index == 0 || lst_type.index == 2) && edt_username.text != ""
              pass = edt_username.text + ":"
            end
            pass += edt_password.text
            name = edt_name.text
            name = nil if name == ""
            bitrate = bitrates[lst_bitrate.index]
            pub = (chk_pub.checked == 1)
            Conference.set_shoutcast(server, pass, name, pub, bitrate)
            form.resume
          }
          form.wait
          @form.focus
        end
      }
    end
    menu.option(p_("Conference", "My streams"), nil, "I") { mystreams }
    menu.option(p_("Conference", "Channel streams"), nil, "N") { streams }
  end

  def context(menu)
    if Conference.channel.conference_mode == 1
      allowed = false
      requested = false
      for u in Conference.channel.users
        if u.id == Conference.userid
          allowed = true if u.speech_allowed
          requested = true if u.speech_requested
        end
      end
      if !Conference.channel.administrators.include?(Session.name)
        if !allowed
          if !requested
            menu.option(p_("Conference", "Request speech"), nil, "=") {
              Conference.speech_request
              play("conference_speechrequest")
            }
          else
            menu.option(p_("Conference", "Refrain speech"), nil, "-") {
              Conference.speech_refrain
              play("conference_speechdeny")
            }
          end
        end
      end
    end
    menu.submenu(p_("Conference", "Streaming")) { |m| context_streaming(m) }
    s = p_("Conference", "Mute microphone")
    s = p_("Conference", "Unmute microphone") if Conference.muted
    menu.option(s, nil, "M") {
      Conference.muted = !Conference.muted
      if Conference.muted
        speak(p_("Conference", "Microphone muted"))
      else
        speak(p_("Conference", "Microphone unmuted"))
      end
    }
    menu.option(p_("Conference", "Change volumes"), nil, "u") {
      setvolumes
    }
    if Conference.saving?
      menu.option(p_("Conference", "Finish saving"), nil, "s") {
        save
      }
    else
      menu.submenu(p_("Conference", "Save this conference to a file")) { |m|
        m.option(p_("Conference", "Save mixed stream to a file"), nil, "s") {
          save
        }
        m.option(p_("Conference", "Save separate streams (experimental)"), nil, "S") {
          if requires_premiumpackage("audiophile")
            fullsave
          end
        }
      }
    end
    menu.submenu(p_("Conference", "Push to talk")) { |m|
      if Conference.pushtotalk_keys != []
        s = p_("Conference", "Enable push to talk")
        s = p_("Conference", "Disable push to talk") if Conference.pushtotalk
        m.option(s, nil, "k") {
          Conference.pushtotalk = !Conference.pushtotalk
          LocalConfig["ConferencePushToTalk"] = (Conference.pushtotalk) ? (1) : (0)
        }
      end
      s = generate_pushtotalkkeyslabel
      m.option(s) {
        pushtotalk_setkeys
        @form.focus
      }
    }
    menu.option(p_("Conference", "VST chain"), nil, "T") {
      if requires_premiumpackage("audiophile")
        insert_scene(Scene_Conference_VSTS.new)
      end
    }
    menu.submenu(p_("Conference", "Miscellaneous")) { |m|
      m.option(p_("Conference", "Roll a 6-sided dice"), nil, "d") { Conference.diceroll }
      m.option(p_("Conference", "Roll a custom dice"), nil, "D") {
        self.class.custom_diceroll
      }
      m.option(p_("Conference", "Cardboard"), nil, "b") { decks }
    }
    menu.option(p_("Conference", "Show status")) { showstatus }
    menu.option(p_("Conference", "Change output soundcard")) {
      if requires_premiumpackage("director")
        cards = [p_("Conference", "Use Elten soundcard")] + Bass.soundcards[2..-1].map { |c| c.name }
        cardid = -1
        form = Form.new([
          lst_card = ListBox.new(cards, p_("Conference", "Select soundcard")),
          btn_cardok = Button.new(p_("Conference", "Select")),
          btn_cardcancel = Button.new(_("Cancel"))
        ], 0, false, true)
        btn_cardcancel.on(:press) { form.resume }
        btn_cardok.on(:press) {
          cardid = lst_card.index
          form.resume
        }
        form.cancel_button = btn_cardcancel
        form.accept_button = btn_cardok
        form.wait
        if cardid > -1
          card = nil
          card = cards[cardid] if cardid > 0
          Conference.set_device(card)
        end
        @form.focus
      end
    }
    if Conference.channel.id != 0
      menu.submenu(p_("Conference", "Channel")) { |m|
        if Conference.channel.groupid == 0 || Conference.channel.groupid == nil
          m.option(p_("Conference", "Show banned users")) {
            showbanned
            @form.focus
          }
        end
        m.option(p_("Conference", "Show channel administrators")) {
          showadministrators
          @form.focus
        }
        if Conference.channel.administrators.include?(Session.name)
          if Conference.channel.groupid == 0 || Conference.channel.groupid == nil
            m.option(p_("Conference", "Show channel whitelist"), nil, "l") {
              showwhitelist
              @form.focus
            }
          end
          m.option(p_("Conference", "Edit channel"), nil, "e") {
            edit_channel(Conference.channel, nil)
          }
        end
      }
    end
    menu.option(p_("Conference", "Show channels"), nil, "h") {
      list_channels
      loop_update
      @form.focus
    }
  end

  def decktypedict(d)
    case d
    when "full"
      return p_("Conference", "Full deck")
    when "half"
      return p_("Conference", "Two colours")
    when "small"
      return p_("Conference", "Small deck")
    when "halfsmall"
      return p_("Conference", "Two colours of a small deck")
    when "nojoker"
      return p_("Conference", "No jokers")
    when "uno"
      return p_("Conference", "UNO")
    else
      return ""
    end
  end

  def decks
    form = Form.new([
      lst_decks = ListBox.new([], p_("Conference", "Decks")),
      lst_cards = ListBox.new([], p_("Conference", "My cards")),
      lst_placed = ListBox.new([], p_("Conference", "Placed cards")),
      btn_close = Button.new(_("Close"))
    ], 0, false, true)
    cards = []
    decks = []
    placed = []
    refr = Proc.new {
      decks = Conference.decks || []
      lst_decks.options = decks.map { |d| (decks.index(d) + 1).to_s + ": " + decktypedict(d["type"]) }
      cards = Conference.cards || []
      lst_cards.options = cards.map { |c| c.fullname }
      placed = []
      for d in decks
        placed += d["placed"].map { |c| Conference::Card.from_cid(d["id"], c["cid"]) }
      end
      lst_placed.options = placed.map { |c| c.fullname }
    }
    refr.call
    lst_decks.bind_context { |menu|
      if decks.size > 0
        menu.option(p_("Conference", "Pick a card"), nil, "p") {
          Conference.cardboard_pick(decks[lst_decks.index]["id"])
        }
        menu.option(p_("Conference", "Shuffle"), nil, "l") {
          confirm(p_("Conference", "Are you sure you want to shuffle this deck? All placed cards will be returned to this deck.")) {
            Conference.deck_reset(decks[lst_decks.index]["id"])
            delay(0.2)
            refr.call
          }
        }
        menu.option(p_("Conference", "Deck history"), nil, "h") { deckhistory(decks[lst_decks.index]) }
        menu.option(p_("Conference", "Delete a deck"), nil, :del) {
          confirm(p_("Conference", "Are you sure you want to delete this deck?")) {
            Conference.deck_remove(decks[lst_decks.index]["id"])
            delay(0.2)
            refr.call
          }
        }
      end
      if decks.size < 4
        menu.option(p_("Conference", "Add new deck"), nil, "n") {
          decktypes = ["full", "small", "half", "halfsmall", "nojoker", "uno"]
          decknames = decktypes.map { |d| decktypedict(d) }
          s = selector(decknames, p_("Conference", "Deck type"), 0, -1)
          Conference.deck_add(decktypes[s]) if s >= 0
          delay(0.2)
          refr.call
        }
      end
      menu.option(_("Refresh"), nil, "r") { refr.call }
    }
    lst_cards.bind_context { |menu|
      if cards.size > 0
        card = cards[lst_cards.index]
        menu.option(p_("Conference", "Place a card"), nil, :enter) {
          Conference.cardboard_place(card.deck, card.cid)
        }
        menu.option(p_("Conference", "Replace a card"), nil, :shift_enter) {
          Conference.cardboard_change(card.deck, card.cid)
        }
      end
      menu.option(_("Refresh"), nil, "r") { refr.call }
    }
    lst_placed.bind_context { |menu|
      if placed.size > 0
        card = placed[lst_placed.index]
        menu.option(p_("Conference", "Pick a card"), nil, "p") {
          Conference.cardboard_pick(card.deck, card.cid)
        }
      end
      menu.option(_("Refresh"), nil, "r") { refr.call }
    }
    clo = false
    btn_close.on(:press) { clo = true }
    form.cancel_button = btn_close
    loop do
      loop_update
      form.update
      break if clo
      if @refresh_cardboard == true
        @refresh_cardboard = false
        refr.call
      end
    end
  end

  def deckhistory(deck)
    history = deck["history"].map { |h|
      s = h["username"] + " "
      case h["action"].downcase
      when "pick"
        s += p_("Conference", "Picked a card")
      when "change"
        s += p_("Conference", "Replaced a card")
      when "shuffle"
        s += p_("Conference", "Shuffled a deck")
      when "place"
        s += p_("Conference", "Placed %{cardname}") % { "cardname" => Conference::Card.from_cid(deck["id"], h["cid"]).fullname }
      end
      s
    }
    selector(history, p_("Conference", "Deck history"), 0, -1)
  end

  def showbanned
    banned = []
    lst_banned = ListBox.new([], p_("Conference", "Banned users"))
    refr = Proc.new {
      banned = Conference.channel.banned
      lst_banned.options = banned
    }
    refr.call
    lst_banned.bind_context { |menu|
      if banned.size > 0
        menu.useroption(banned[lst_banned.index])
        menu.option(p_("Conference", "Unban"), nil, :del) {
          Conference.unban(banned[lst_banned.index])
          refr.call
          lst_banned.focus
        }
      end
      if Conference.channel.administrators.include?(Session.name) && (Conference.channel.groupid == 0 || Conference.channel.groupid == nil)
        menu.option(p_("Conference", "Ban user"), nil, "n") {
          user = input_user(p_("Conference", "User to ban"))
          if user != nil
            if user_exists(user)
              Conference.ban(user)
              refr.call
              lst_banned.focus
            end
          end
        }
      end
      menu.option(_("Refresh"), nil, "r") {
        refr.call
        lst_banned.focus
      }
    }
    dialog_open
    lst_banned.focus
    loop do
      loop_update
      lst_banned.update
      break if escape
    end
    dialog_close
  end

  def showadministrators
    administrators = []
    lst_administrators = ListBox.new([], p_("Conference", "administrators"))
    refr = Proc.new {
      administrators = Conference.channel.administrators
      lst_administrators.options = administrators
    }
    refr.call
    lst_administrators.bind_context { |menu|
      if administrators.size > 0
        menu.useroption(administrators[lst_administrators.index])
      end
      if Conference.channel.administrators.include?(Session.name)
        if Conference.channel.groupid == 0 || Conference.channel.groupid == nil
          menu.option(p_("Conference", "Add administrator"), nil, "n") {
            user = input_user(p_("Conference", "User to grant administration privileges to"))
            if user != nil
              if user_exists(user)
                Conference.admin(user)
                refr.call
                lst_administrators.focus
              end
            end
          }
          if administrators.size > 0 && Conference.channel.creator == Session.name && administrators[lst_administrators.index] != Session.name
            menu.option(p_("Conference", "Delete"), nil, :del) {
              Conference.unadmin(administrators[lst_administrators.index])
              refr.call
              lst_administrators.focus
              play("editbox_delete")
            }
          end
        end
      end
      menu.option(_("Refresh"), nil, "r") {
        refr.call
        lst_administrators.focus
      }
    }
    dialog_open
    lst_administrators.focus
    loop do
      loop_update
      lst_administrators.update
      break if escape
    end
    dialog_close
  end

  def showwhitelist
    whitelist = []
    lst_whitelist = ListBox.new([], p_("Conference", "Channel whitelist"))
    refr = Proc.new {
      whitelist = Conference.channel.whitelist
      lst_whitelist.options = whitelist
    }
    refr.call
    lst_whitelist.bind_context { |menu|
      if whitelist.size > 0
        menu.useroption(whitelist[lst_whitelist.index])
      end
      if Conference.channel.administrators.include?(Session.name)
        if Conference.channel.groupid == 0 || Conference.channel.groupid == nil
          menu.option(p_("Conference", "Add to whitelist"), nil, "n") {
            user = input_user(p_("Conference", "User to add to channel whitelist"))
            if user != nil
              if user_exists(user)
                Conference.whitelist(user)
                refr.call
                lst_whitelist.focus
              end
            end
          }
          if whitelist.size > 0
            menu.option(p_("Conference", "Delete"), nil, :del) {
              Conference.whiteunlist(whitelist[lst_whitelist.index])
              refr.call
              lst_whitelist.focus
              play("editbox_delete")
            }
          end
        end
      end
      menu.option(_("Refresh"), nil, "r") {
        refr.call
        lst_whitelist.focus
      }
    }
    dialog_open
    lst_whitelist.focus
    loop do
      loop_update
      lst_whitelist.update
      break if escape
    end
    dialog_close
  end

  def timeout_break
    if @timeoutthr != nil
      @timeoutthr.exit
      @timeoutthr = nil
    end
  end

  def self.custom_diceroll
    d = selector((1..100).to_a.map { |d| p_("Conference", "%{count}-sided") % { "count" => d.to_s } }, p_("Conference", "Which dice do you want to roll?"), @@lastdiceindex, -1, 1)
    @@lastdiceindex = d if d >= 0
    Conference.diceroll(d + 1) if d >= 0
  end

  def streams
    self.class.streams
    @form.focus
  end

  def streams
    strs = []
    sel = TableBox.new([nil, p_("Conference", "User"), p_("Conference", "Location")], [], 0, p_("Conference", "Channel streams"))
    rfr = Proc.new {
      strs = Conference.streams
      selt = strs.map { |s|
        loc = "x: #{s["x"]}, y: #{s["y"]}"
        if s["x"] == -1
          loc = p_("Conference", "Everywhere")
        elsif s["x"] == 0
          loc = p_("Conference", "Right next to me")
        end
        [s["name"], s["username"], loc]
      }
      sel.rows = selt
      sel.reload
    }
    rfr.call
    sel.bind_context { |menu|
      if sel.options.size > 0
        muted = false
        muted = true if Conference.streamid_mutes[strs[sel.index]["id"]] == true
        s = p_("Conference", "Mute stream")
        s = p_("Conference", "Unmute stream") if muted
        menu.option(s, nil, "m") {
          Conference.streamid_setvolume(strs[sel.index]["id"], strs[sel.index]["volume"], !muted)
          if muted
            alert(p_("Conference", "Stream unmuted"))
          else
            alert(p_("Conference", "Stream muted"))
          end
        }
        menu.option(p_("Conference", "Change volume"), nil, "u") {
          muted = false
          muted = true if Conference.streamid_mutes[strs[sel.index]["id"]] == true
          dialog_open
          lst_volume = ListBox.new((0..100).to_a.map { |s| s.to_s }, p_("Conference", "Stream volume"), strs[sel.index]["volume"], 0, false)
          lst_volume.on(:move) { Conference.streamid_setvolume(strs[sel.index]["id"], lst_volume.index, muted) }
          loop do
            loop_update
            lst_volume.update
            if lst_volume.selected?
              strs[sel.index]["volume"] = lst_volume.index
              break
            end
            if escape
              Conference.streamid_setvolume(strs[sel.index]["id"], strs[sel.index]["volume"], muted)
              break
            end
          end
          dialog_close
        }
        if strs[sel.index]["x"] > 0
          menu.option(p_("Conference", "Go to stream"), nil, "g") {
            Conference.goto(strs[sel.index]["x"], strs[sel.index]["y"])
          }
        end
      end
      menu.option(_("Refresh"), nil, "r") {
        rfr.call
        sel.focus
      }
    }
    sel.focus
    loop {
      loop_update
      sel.update
      break if escape
    }
  end

  def mystreams
    self.class.mystreams
    @form.focus
  end

  def self.mystreams
    sel = TableBox.new([nil, p_("Conference", "Location")], [], 0, p_("Conference", "My streams"))
    rfr = Proc.new {
      selt = [[p_("Conference", "Master mix"), nil]] + Conference.mystreams.streams.map { |s|
        loc = "x: #{s.x}, y: #{s.y}"
        if s.x == -1
          loc = p_("Conference", "Everywhere")
        elsif s.x == 0
          loc = p_("Conference", "Right next to me")
        end
        [s.name, loc]
      }
      sel.rows = selt
      sel.reload
    }
    sel.bind_context { |menu|
      stream = nil
      sources = []
      sid = -1
      if sel.index == 0
        sources = Conference.mystreams.sources
      else
        stream = Conference.mystreams.streams[sel.index - 1]
        sources = stream.sources if stream != nil
        sid = sel.index - 1
      end
      menu.option(p_("Conference", "Show sources"), nil, :enter) {
        sources(sid)
        rfr.call
        sel.focus
      }
      if sid >= 0
        s = p_("Conference", "Locally mute")
        s = p_("Conference", "Locally unmute") if stream.locally_muted
        menu.option(s, nil, "m") {
          Conference.locallymutestream(sid, !stream.locally_muted)
          stream.locally_muted = !stream.locally_muted
          if !stream.locally_muted
            alert(p_("Conference", "Locally unmuted"))
          else
            alert(p_("Conference", "Locally muted"))
          end
        }
        menu.option(p_("Conference", "Change volume"), nil, "u") {
          dialog_open
          lst_volume = ListBox.new((0..100).to_a.map { |s| s.to_s }, p_("Conference", "Stream volume"), stream.volume, 0, false)
          lst_volume.on(:move) { Conference.volumestream(lst_volume.index, sid, nil) }
          loop do
            loop_update
            lst_volume.update
            if lst_volume.selected?
              stream.volume = lst_volume.index
              break
            end
            if escape
              Conference.volumestream(stream.volume, sid)
              break
            end
          end
          dialog_close
        }
      end
      if sources.find { |s| s.toggleable } != nil
        menu.option(p_("Conference", "Toggle stream"), nil, "p") {
          for i in 0...sources.size
            Conference.togglestream(sid, i) if sources[i].toggleable
          end
        }
      end
      if sources.find { |s| s.scrollable } != nil
        menu.option(p_("Conference", "Scroll backward"), nil, "[") {
          for i in 0...sources.size
            Conference.scrollstream(-5, sid, i) if sources[i].toggleable
          end
        }
        menu.option(p_("Conference", "Scroll forward"), nil, "]") {
          for i in 0...sources.size
            Conference.scrollstream(5, sid, i) if sources[i].toggleable
          end
        }
      end
      if sid >= 0
        menu.option(p_("Conference", "Remove stream"), nil, :del) {
          Conference.stream_remove(sid)
          play("editbox_delete")
          delay(0.5)
          rfr.call
          sel.focus
        }
      end
      menu.option(p_("Conference", "New file stream"), nil, "f") {
        form = Form.new([
          tr_file = FilesTree.new(p_("Conference", "File"), Dirs.documents + "\\", false, true, nil, [".mp3", ".wav", ".ogg", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"]),
          lst_location = ListBox.new([p_("Conference", "Right next to me"), p_("Conference", "Here"), p_("Conference", "Everywhere")], p_("Conference", "Location")),
          btn_place = Button.new(p_("Conference", "Place")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        btn_place.on(:press) {
          if File.file?(tr_file.selected(true))
            file = tr_file.selected(true)
            name = File.basename(file, File.extname(file))
            x, y = 0, 0
            case lst_location.index
            when 0
              x, y = 0, 0
            when 1
              x, y = Conference.get_coordinates[0..1]
            when 2
              x, y = -1, -1
            end
            Conference.stream_add_file(file, name, x, y)
            delay(1)
            form.resume
          end
        }
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        form.accept_button = btn_place
        form.wait
        rfr.call
        sel.focus
      }
      menu.option(p_("Conference", "New Internet stream"), nil, "u") {
        form = Form.new([
          edt_url = EditBox.new(p_("Conference", "Stream URL"), 0, "", true),
          lst_location = ListBox.new([p_("Conference", "Right next to me"), p_("Conference", "Here"), p_("Conference", "Everywhere")], p_("Conference", "Location")),
          btn_place = Button.new(p_("Conference", "Place")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        btn_place.on(:press) {
          if edt_url.text != ""
            url = edt_url.text
            url = "http://" + url if !url.include?(":")
            name = url
            x, y = 0, 0
            case lst_location.index
            when 0
              x, y = 0, 0
            when 1
              x, y = Conference.get_coordinates[0..1]
            when 2
              x, y = -1, -1
            end
            Conference.stream_add_url(url, name, x, y)
            delay(1)
            form.resume
          end
        }
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        form.accept_button = btn_place
        form.wait
        rfr.call
        sel.focus
      }
      menu.option(p_("Conference", "New soundcard stream"), nil, "c") {
        mics = Bass.microphones
        cardid = -1
        listen = false
        form = Form.new([
          lst_card = ListBox.new(mics.map { |m| o = ""; o = " (" + p_("Conference", "Loopback device") + ")" if m.loopback?; m.name + o }, p_("Conference", "Select soundcard to stream")),
          chk_listen = CheckBox.new(p_("Conference", "Turn on the listening"), 1),
          lst_location = ListBox.new([p_("Conference", "Right next to me"), p_("Conference", "Here"), p_("Conference", "Everywhere")], p_("Conference", "Location")),
          btn_place = Button.new(p_("Conference", "Place")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        for i in 0...mics.size
          lst_card.disable_item(i) if mics[i].disabled?
        end
        btn_place.on(:press) {
          cardid = lst_card.index
          listen = chk_listen.checked.to_i == 1
          name = lst_card.options[lst_card.index]
          x, y = 0, 0
          case lst_location.index
          when 0
            x, y = -1, -1
          when 1
            x, y = Conference.get_coordinates[0..1]
          when 2
            x, y = 0, 0
          end
          Conference.stream_add_card(cardid, name, x, y, !listen)
          form.resume
        }
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        form.accept_button = btn_place
        form.wait
        delay(1)
        rfr.call
        sel.focus
      }
    }
    rfr.call
    sel.focus
    loop {
      loop_update
      sel.update
      break if escape
    }
  end
  def self.sources(sid)
    stream = nil
    stream = Conference.mystreams.streams[sid] if sid >= 0
    sname = p_("Conference", "Master mix")
    sname = stream.name if stream != nil
    sel = ListBox.new([], p_("Conference", "Sources of %{name}") % { "name" => sname })
    rfr = Proc.new {
      stream = nil
      stream = Conference.mystreams.streams[sid] if sid >= 0
      sources = Conference.mystreams.sources
      sources = stream.sources if stream != nil
      sel.options = sources.map { |s| s.name }
    }
    sel.bind_context { |menu|
      stream = nil
      stream = Conference.mystreams.streams[sid] if sid >= 0
      sources = Conference.mystreams.sources
      sources = stream.sources if stream != nil
      if sel.options.size > 0
        source = sources[sel.index]
        oid = sel.index
        menu.option(p_("Conference", "Change volume"), nil, "u") {
          dialog_open
          lst_volume = ListBox.new((0..100).to_a.map { |s| s.to_s }, p_("Conference", "Source volume"), source.volume, 0, false)
          lst_volume.on(:move) { Conference.volumestream(lst_volume.index, sid, oid) }
          loop do
            loop_update
            lst_volume.update
            if lst_volume.selected?
              source.volume = lst_volume.index
              break
            end
            if escape
              Conference.volumestream(source.volume, sid, oid)
              break
            end
          end
          dialog_close
        }
        if source.toggleable
          menu.option(p_("Conference", "Toggle stream"), nil, "p") {
            Conference.togglestream(sid, oid)
          }
        end
        if source.scrollable
          menu.option(p_("Conference", "Scroll backward"), nil, "[") {
            Conference.scrollstream(-5, sid, oid)
          }
          menu.option(p_("Conference", "Scroll forward"), nil, "]") {
            Conference.scrollstream(5, sid, oid)
          }
        end
        menu.option(p_("Conference", "Remove source"), nil, :del) {
          Conference.removesource(sid, oid)
          play("editbox_delete")
          delay(0.5)
          rfr.call
          sel.focus
        }
      end
      menu.option(p_("Conference", "Add file"), nil, "f") {
        form = Form.new([
          tr_file = FilesTree.new(p_("Conference", "File"), Dirs.documents + "\\", false, true, nil, [".mp3", ".wav", ".ogg", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"]),
          btn_place = Button.new(p_("Conference", "Place")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        btn_place.on(:press) {
          if File.file?(tr_file.selected(true))
            file = tr_file.selected(true)
            Conference.source_add_file(sid, file)
            delay(1)
            form.resume
          end
        }
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        form.accept_button = btn_place
        form.wait
        rfr.call
        sel.focus
      }
      menu.option(p_("Conference", "Add Internet stream"), nil, "f") {
        form = Form.new([
          edt_url = EditBox.new(p_("Conference", "Stream URL"), 0, "", true),
          btn_place = Button.new(p_("Conference", "Place")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        btn_place.on(:press) {
          if edt_url.text != ""
            url = edt_url.text
            url = "http://" + url if !url.include?(":")
            Conference.source_add_url(sid, url)
            delay(1)
            form.resume
          end
        }
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        form.accept_button = btn_place
        form.wait
        rfr.call
        sel.focus
      }
      menu.option(p_("Conference", "Add soundcard"), nil, "c") {
        mics = Bass.microphones
        cardid = -1
        listen = false
        form = Form.new([
          lst_card = ListBox.new(mics.map { |m| o = ""; o = " (" + p_("Conference", "Loopback device") + ")" if m.loopback?; m.name + o }, p_("Conference", "Select soundcard to stream")),
          btn_place = Button.new(p_("Conference", "Place")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        for i in 0...mics.size
          lst_card.disable_item(i) if mics[i].disabled?
        end
        btn_place.on(:press) {
          cardid = lst_card.index
          Conference.source_add_card(sid, cardid)
          form.resume
        }
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        form.accept_button = btn_place
        form.wait
        delay(1)
        rfr.call
        sel.focus
      }
    }
    rfr.call
    sel.focus
    loop {
      loop_update
      sel.update
      break if escape
    }
  end
end

class Scene_Conference_VSTS
  def initialize(userid = 0)
    @userid = userid
  end

  def main
    @sel = TableBox.new([p_("Conference", "Name"), p_("Conference", "State"), p_("Conference", "File")], [], 0, p_("Conference", "VST Plugins"))
    @sel.bind_context { |menu| context(menu) }
    refresh
    @sel.focus
    loop do
      loop_update
      @sel.update
      break if escape
    end
    $scene = Scene_Main.new
  end

  def params(vst)
    return if vst == nil
    index = vst["index"]
    sel = TableBox.new([p_("Conference", "Name"), p_("Conference", "Unit"), p_("Conference", "Display"), p_("Conference", "Value")], [], 0, p_("Conference", "VST parameters"))
    sel.add_tip(p_("Conference", "Use left/right arrows to adjust values"))
    rld = Proc.new {
      refresh
      vst = @vsts[index]
    }
    rfr = Proc.new {
      selt = []
      if vst != nil
        for param in vst["parameters"]
          selt.push([param["name"], param["unit"], param["display"], param["value"].to_s])
        end
      end
      sel.rows = selt
      sel.reload
    }
    rfr.call
    sel.focus
    sel.bind_context { |menu|
      if vst["parameters"].size > 0
        parameter = vst["parameters"][sel.index]
        menu.option(p_("Conference", "Edit parameter"), nil, "e") {
          prm = input_text(p_("Conference", "Parameter value"), 0, parameter["value"].to_s, true)
          if prm != nil
            pr = prm.to_f
            Conference.vst_setparam(index, sel.index, pr, @userid)
            rld.call
            rfr.call
          end
        }
        menu.option(p_("Conference", "Set to default"), nil, "d") {
          Conference.vst_setparam(index, sel.index, parameter["default"].to_f, @userid)
          rld.call
          rfr.call
        }
      end
    }
    loop do
      loop_update
      sel.update
      if !$keyr[0x10] && ((arrow_left or arrow_right) and vst != nil)
        if vst["parameters"].size > 0
          parameter = vst["parameters"][sel.index]
          pr = pro = parameter["value"]
          ds = parameter["display"]
          ch = 0
          if arrow_left
            ch = -0.01
          else
            ch = 0.01
          end
          pr += ch
          pr = 0 if pr < 0 and pro > 0
          pr = 1 if pr > 1 and pro < 1
          Conference.vst_setparam(index, sel.index, pr, @userid)
          ppr = pr
          prm = parameter
          rld.call
          prm = vst["parameters"][sel.index] if vst != nil
          i = 0
          while (pr >= 0 && pr <= 1) && prm["display"] == ds
            i += 1
            pr += ch
            if i > 3
              if ch < 0
                pr = (pr * 10).floor / 10.0
              else
                pr = (pr * 10).ceil / 10.0
              end
            end
            Conference.vst_setparam(index, sel.index, pr, @userid)
            rld.call
            break if vst == nil
            prm = vst["parameters"][sel.index]
            break if prm == nil
          end
          Conference.vst_setparam(index, sel.index, ppr, @userid) if prm == nil || prm["display"] == ds
          rld.call
          rfr.call
          if sel.rows[sel.index].is_a?(Array)
            speak(sel.rows[sel.index][2])
          end
        end
      end
      break if escape
    end
  end

  def refresh
    @vsts = Conference.vsts(@userid)
    selt = []
    if @vsts != nil
      for v in @vsts
        selt.push([v["name"], v["bypass"] ? (p_("Conference", "Disabled")) : p_("Conference", "Enabled"), v["file"]])
      end
    end
    @sel.rows = selt
    @sel.reload
  end

  def context(menu)
    return if @vsts == nil
    if @vsts.size > 0
      vst = @vsts[@sel.index]
      menu.option(p_("Conference", "Show parameters"), nil, "e") {
        params(vst)
        @sel.focus
      }
      s = p_("Conference", "Enable")
      s = p_("Conference", "Disable") if vst["bypass"] == false
      menu.option(s, nil, :space) {
        Conference.vst_setbypass(@sel.index, !vst["bypass"], @userid)
        if !vst["bypass"]
          play("recording_stop")
        else
          play("recording_start")
        end
        refresh
      }
      if vst["haseditor"] == true
        s = p_("Conference", "Show editor")
        s = p_("Conference", "Hide editor") if vst["showneditor"] == true
        menu.option(s) {
          if vst["showneditor"] == true
            Conference.vst_hideeditor(@sel.index, @userid)
          else
            Conference.vst_showeditor(@sel.index, @userid)
            delay(0.5)
          end
          refresh
        }
      end
      if vst["programs"].size > 1
        menu.option(p_("Conference", "Change program"), nil, "g") {
          g = selector(vst["programs"], p_("Conference", "Select program"), vst["program"], -1)
          if g != -1
            Conference.vst_setprogram(@sel.index, g, @userid)
            refresh
          end
          @sel.focus
        }
      end
      if @sel.index > 0
        menu.option(p_("Conference", "Move up")) {
          Conference.vst_move(@sel.index, @sel.index - 1, @userid)
          refresh
          @sel.say_option
        }
      end
      if @sel.index < @sel.options.size - 1
        menu.option(p_("Conference", "Move down")) {
          Conference.vst_move(@sel.index, @sel.index + 1, @userid)
          refresh
          @sel.say_option
        }
      end
      menu.option(p_("Conference", "Remove VST"), nil, :del) {
        Conference.vst_remove(@sel.index, @userid)
        refresh
        play("editbox_delete")
      }
      menu.option(p_("Conference", "Export"), nil, "s") {
        export
        @sel.focus
      }
      menu.option(p_("Conference", "Import"), nil, "o") {
        import
        refresh
        @sel.focus
      }
      menu.option(p_("Conference", "Save current chain"), nil, "S") {
        name = input_text(p_("Conference", "Name for this chain"), 0, "", true)
        if name != nil
          t = readfile(Dirs.eltendata + "\\vstchains.dat")
          t += [name.size].pack("I")
          t += name
          t += [@vsts.size].pack("I")
          for i in 0...@vsts.size
            v = @vsts[i]
            t += [v["file"].size].pack("I")
            t += v["file"]
            bank = Conference.vst_export_bank(i, @userid)
            t += [bank.size].pack("I")
            t += bank
          end
          writefile(Dirs.eltendata + "\\vstchains.dat", t)
          alert(_("Saved"))
        end
      }
    end
    menu.option(p_("Conference", "Add VST"), nil, "n") {
      file = get_file(p_("Conference", "Select VST version 2 file to be loaded"), "", false, nil, [".dll"])
      if file != nil
        Conference.vst_add(file, @userid)
        refresh
      end
    }
    menu.option(p_("Conference", "Saved VST chains"), nil, "O") {
      savedchains
      refresh
      @sel.focus
    }
    menu.option(_("Refresh"), nil, "r") { refresh }
  end

  def export
    form = Form.new([
      tr_path = FilesTree.new(p_("Conference", "Destination"), Dirs.user + "\\", true, true, "Documents"),
      edt_filename = EditBox.new(p_("Conference", "File name"), 0, "#{File.basename(@vsts[@sel.index]["file"], File.extname(@vsts[@sel.index]["file"]))}.fxp", true),
      lst_exporttype = ListBox.new([p_("Conference", "Export current preset"), p_("Conference", "Export full bank")], p_("Conference", "Export type")),
      btn_export = Button.new(p_("Conference", "Export")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    lst_exporttype.on(:move) {
      format = ".fxp"
      format = ".fxb" if lst_exporttype.index == 1
      if edt_filename.value.downcase[-4..-1] != format
        f = File.basename(edt_filename.text, File.extname(edt_filename.text)) + format
        edt_filename.set_text(f)
      end
    }
    form.cancel_button = btn_cancel
    btn_cancel.on(:press) { form.resume }
    btn_export.on(:press) {
      content = nil
      case lst_exporttype.index
      when 0
        hd = ["CcnK", 0, "FPCh", 1, @vsts[@sel.index]["uniqueid"], @vsts[@sel.index]["version"], @vsts[@sel.index]["parameters"].size, @vsts[@sel.index]["programs"][@vsts[@sel.index]["program"]][0...28], 0]
        f = Conference.vst_export_preset(@sel.index, @userid)
        hd[8] = f.bytesize
        hd[1] = f.bytesize + 52
        h = hd.pack("a4Na4NNNNa28N")
        content = h + f
      when 1
        hd = ["CcnK", 0, "FBCh", 1, @vsts[@sel.index]["uniqueid"], @vsts[@sel.index]["version"], @vsts[@sel.index]["programs"].size, 0, "\0" * 124, 0]
        f = Conference.vst_export_preset(@sel.index, @userid)
        hd[9] = f.bytesize
        hd[1] = f.bytesize + 152
        h = hd.pack("a4Na4NNNNNa124N")
        f = Conference.vst_export_bank(@sel.index, @userid)
        content = h + f
      end
      if content != nil
        file = tr_path.selected + "\\" + edt_filename.text
        writefile(file, content)
        alert(_("Saved"))
        form.resume
      end
    }
    form.wait
  end

  def import
    file = get_file(p_("Conference", "Select preset or bank file"), Dirs.documents + "\\", false, nil, [".fxp", ".fxb"])
    if file != nil
      content = readfile(file)
      if content != "" && content != nil
        format = File.extname(file).downcase
        return if content.size < 12
        magic, size, chunk = content.unpack("a4Na4")
        return if magic != "CcnK"
        return if size != content.size - 8 && size != 0
        case chunk
        when "FPCh"
          return if content.size < 60
          h = content[0...60]
          f = content[60..-1]
          hd = h.unpack("a4Na4NNNNa28N")
          return if hd[3] != 1
          return if hd[4] != @vsts[@sel.index]["uniqueid"]
          Conference.vst_import_preset(@sel.index, f, @userid)
        when "FBCh"
          return if content.size < 160
          h = content[0...160]
          f = content[160..-1]
          hd = h.unpack("a4Na4NNNNNa124N")
          return if hd[3] != 1
          return if hd[4] != @vsts[@sel.index]["uniqueid"]
          Conference.vst_import_bank(@sel.index, f, @userid)
        when "FxCk"
          return if content.size < 56
          h = content[0...56]
          f = content[56..-1]
          hd = h.unpack("a4Na4NNNNa28N")
          return if hd[3] != 1
          return if hd[4] != @vsts[@sel.index]["uniqueid"]
          params = f.unpack("g*")
          for i in 0...params.size
            break if i >= @vsts[@sel.index]["parameters"].size
            Conference.vst_setparam(@sel.index, i, params[i], @userid)
          end
        else
          return
        end
        alert(_("Saved"))
      end
    end
  end

  def savedchains
    chains = []
    if FileTest.exists?(Dirs.eltendata + "\\vstchains.dat")
      io = StringIO.new(readfile(Dirs.eltendata + "\\vstchains.dat"))
      until io.eof?
        sz = io.read(4).unpack("I").first
        name = io.read(sz)
        vsz = io.read(4).unpack("I").first
        vsts = []
        for i in 0...vsz
          sz = io.read(4).unpack("I").first
          file = io.read(sz)
          sz = io.read(4).unpack("I").first
          bank = nil
          bank = io.read(sz) if sz > 0
          vsts.push([file, bank])
        end
        chains.push([name, vsts])
      end
    end
    save = Proc.new {
      wr = ""
      for c in chains
        wr += [c[0].size].pack("I")
        wr += c[0]
        wr += [c[1].size].pack("I")
        for v in c[1]
          wr += [v[0].size].pack("I")
          wr += v[0]
          wr += [v[1].to_s.size].pack("I")
          wr += v[1] if v[1] != nil
        end
      end
    }
    sel = ListBox.new([], p_("Conference", "Saved chains"))
    rfr = Proc.new {
      sel.options = chains.map { |c| c[0] }
    }
    sel.bind_context { |menu|
      if chains.size > 0
        menu.option(_("Delete"), nil, :del) {
          confirm(p_("Conference", "Are you sure you want to delete saved chain of name %{name}?") % { "name" => chains[sel.index][0] })
          chains.delete_at(sel.index)
          save.call
          rfr.call
          play("editbox_delete")
        }
        menu.option(p_("Conference", "Rename chain"), nil, "e") {
          name = input_text(p_("Conference", "Chain name"), 0, chains[sel.index][0], true)
          if name != nil
            chains[sel.index][0] = name
            save.call
          end
          sel.focus
        }
      end
    }
    rfr.call
    sel.focus
    loop do
      loop_update
      sel.update
      if sel.selected? && chains.size > 0
        chain = chains[sel.index]
        confirm(p_("Conference", "Are you sure you want to apply chain of name %{name}?") % { "name" => chain[0] }) {
          while @vsts.size > 0
            Conference.vst_remove(0, @userid)
            refresh
          end
          for v in chain[1]
            Conference.vst_add(v[0], @userid)
            refresh
            if v[1] != nil
              Conference.vst_import_bank(@vsts.size - 1, v[1], @userid)
              refresh
            end
          end
          alert(p_("Conference", "Chain imported"))
        }
      end
      break if escape
    end
  end
end
