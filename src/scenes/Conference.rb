# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Conference
  @@lastdiceindex = 5

  def main
    if Session.name == "guest"
      alert(_("This section is unavailable for guests"))
      $scene = Scene_Main.new
      return
    end
    Conference.open if !Conference.opened?
    if !Conference.opened?
      $scene = Scene_Main.new
      return
    end
    @status = ""
    @form = Form.new([
      st_conference = Static.new(p_("Conference", "Channel space")),
      lst_users = ListBox.new([], p_("Conference", "Channel users"), 0, 0, true),
      edt_chathistory = EditBox.new(p_("Conference", "Chat history"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, "", true),
      edt_chat = EditBox.new(p_("Conference", "Chat message"), 0, "", true),
      btn_options = Button.new(p_("Conference", "More options")),
      btn_close = Button.new(p_("Conference", "Close"))
    ], 0, false, true)
    st_conference.add_tip(p_("Conference", "Use arrows to move in the channel space"))
    lst_users.bind_context { |menu|
      if lst_users.options.size > 0
        user = Conference.channel.users[lst_users.index]
        if user != nil
          menu.useroption(user.name)
          vol = Conference.volume(user.name)
          s = p_("Conference", "Mute user")
          s = p_("Conference", "Unmute user") if vol.muted == true
          menu.option(s, nil, "m") {
            Conference.setvolume(user.name, vol.volume, !vol.muted)
          }
          menu.option(p_("Conference", "Change user volume")) {
            lst_volume = ListBox.new((0..100).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "User volume"), 100 - vol.volume)
            lst_volume.on(:move) {
              Conference.setvolume(user.name, 100 - lst_volume.index, vol.muted)
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
          menu.option(p_("Conference", "Read current position"), nil, "q") { speak(Conference.get_coordinates(user.id).map { |c| c.to_s }.join(", ")) }
          menu.option(p_("Conference", "Whisper"), nil, :space) {
            Conference.whisper(user.id)
            t = Time.now.to_f
            loop_update while $keyr[0x20]
            Conference.whisper(0)
            speak(p_("Conference", "Hold spacebar to whisper to user")) if Time.now.to_f - t < 0.25
          }
          if Conference.channel.administrators.include?(Session.name)
            menu.option(p_("Conference", "Kick")) {
              Conference.kick(user.id)
            }
          end
        end
      end
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
    @users_hook = Conference.on(:update) {
      lst_users.options.clear
      for u in Conference.channel.users
        lst_users.options.push(u.name)
      end
    }
    @users_hook.block.call
    @text_hook = Conference.on(:text) {
      edt_chathistory.settext(Conference.texts.map { |c|
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
    st_conference.on(:key_left) { Conference.move(-1, 0) }
    st_conference.on(:key_right) { Conference.move(1, 0) }
    st_conference.on(:key_up) { Conference.move(0, -1) }
    st_conference.on(:key_down) { Conference.move(0, 1) }
    st_conference.bind_context { |menu|
      menu.option(p_("Conference", "Read current position"), nil, :q) { speak(Conference.get_coordinates.map { |c| c.to_s }.join(", ")) }
      menu.option(p_("Conference", "Read channel size"), nil, :e) { speak([Conference.channel.width, Conference.channel.height].map { |c| c.to_s }.join(", ")) }
      menu.submenu(p_("Conference", "Conference")) { |menu| context(menu) }
    }
    edt_chat.on(:select) {
      Conference.send_text(edt_chat.text)
      edt_chat.settext("")
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
      if Conference.channel.id == 0 or confirm(p_("Conference", "Would you like to disconnect?")) == 1
        Conference.close
      end
    end
    Conference.remove_hook(@users_hook)
    Conference.remove_hook(@status_hook)
    Conference.remove_hook(@text_hook)
    Conference.remove_hook(@close_hook)
    Conference.remove_hook(@cardboard_hook)
    $scene = Scene_Main.new
  end

  def channel_summary(ch)
    s = ch.name + ": " + ch.users.map { |u| u.name }.join(", ")
    s += " \004CLOSED\004" if ch.passworded
    return s
  end

  def list_channels
    @chans = get_channelslist
    lst_channels = ListBox.new(@chans.map { |ch| channel_summary(ch) }, p_("Conference", "Channels"))
    lst_channels.bind_context { |menu|
      if lst_channels.options.size > 0
        ch = @chans[lst_channels.index]
        if ch.id != Conference.channel.id
          menu.option(p_("Conference", "Join"), nil, "j") {
            ps = nil
            ps = input_text(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true) if ch.passworded
            if !ch.passworded || ps != nil
              if ch.spatialization == 0 || load_hrtf
                Conference.join(ch.id, ps)
                @chans = get_channelslist
                lst_channels.options = @chans.map { |ch| channel_summary(ch) }
              end
            end
            lst_channels.focus
          }
        end
        menu.option(p_("Conference", "Channel details"), nil, "d") {
          txt = ch.name + "\n"
          txt += p_("Conference", "Creator") + ": " + ch.creator + "\n" if ch.creator.is_a?(String) and ch.creator != ""
          txt += p_("Conference", "Language") + ": " + ch.lang + "\n" if ch.lang != ""
          txt += p_("Conference", "This channel is password-protected.") + "\n" if ch.passworded
          txt += p_("Conference", "Channel bitrate") + ": " + ch.bitrate.to_s + "kbps\n"
          txt += p_("Conference", "Channel frame size") + ": " + ch.framesize.to_s + "ms\n"
          txt += p_("Conference", "Channels") + ": " + ((ch.channels == 2) ? ("Stereo") : ("Mono")) + "\n"
          txt += p_("Conference", "Space Virtualization") + ": " + ((ch.spatialization == 0) ? ("Panning") : ("HRTF"))
          input_text(p_("Conference", "Channel details"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, txt, true)
        }
        if ch.administrators.include?(Session.name)
          menu.option(p_("Conference", "Edit channel"), nil, "e") {
            edit_channel(ch)
            delay(1)
            @chans = get_channelslist
            lst_channels.options = @chans.map { |ch| channel_summary(ch) }
            lst_channels.focus
          }
        end
      end
      if Conference.channel.id != 0
        menu.option(p_("Conference", "Leave"), nil, "l") {
          Conference.leave
          @chans = get_channelslist
          lst_channels.options = @chans.map { |ch| channel_summary(ch) }
          lst_channels.focus
        }
      end
      menu.option(p_("Conference", "Create channel"), nil, "n") {
        edit_channel
        delay(1)
        @chans = get_channelslist
        lst_channels.options = @chans.map { |ch| channel_summary(ch) }
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
          lst_channels.options = @chans.map { |ch| channel_summary(ch) }
          lst_channels.focus
        }
      end
      menu.option(p_("Conference", "Refresh"), nil, "r") {
        @chans = get_channelslist
        lst_channels.options = @chans.map { |ch| channel_summary(ch) }
        lst_channels.focus
      }
    }
    loop do
      loop_update
      lst_channels.update
      if lst_channels.selected?
        ch = @chans[lst_channels.index]
        return if Conference.channel.id == ch.id
        ps = nil
        ps = input_text(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true) if ch.passworded
        if !ch.passworded || ps != nil
          if ch.spatialization == 0 || load_hrtf
            Conference.join(ch.id, ps)
            delay(1)
            return if Conference.channel.id != 0
          end
        end
      end
      break if escape
    end
  end

  def edit_channel(channel = nil)
    if channel == nil
      channel = Conference::Channel.new
      channel.lang = Configuration.language.downcase[0..1]
    end
    bitrates = [8, 16, 24, 32, 48, 64, 96, 128, 192, 256, 320, 412, 510]
    framesizes = [2.5, 5.0, 10.0, 20.0, 40.0, 60.0, 80.0, 100.0, 120.0]
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
    form = Form.new([
      edt_name = EditBox.new(p_("Conference", "Channel name"), nameflags, channel.name, true),
      lst_lang = ListBox.new(langnames, p_("Conference", "Language"), lnindex, 0, true),
      lst_bitrate = ListBox.new(bitrates.map { |b| b.to_s }, p_("Conference", "Channel bitrate"), bitrates.find_index(channel.bitrate) || 0, 0, true),
      lst_framesize = ListBox.new(framesizes.map { |f| f.to_s }, p_("Conference", "Channel frame size"), framesizes.find_index(channel.framesize) || 0, 0, true),
      lst_channels = ListBox.new(["Mono", "Stereo"], p_("Conference", "Channels"), channel.channels - 1, 0, true),
      lst_spatialization = ListBox.new(["Panning", "HRTF"], p_("Conference", "Space Virtualization"), channel.spatialization, 0, true),
      edt_width = EditBox.new(p_("Conference", "Channel width"), EditBox::Flags::Numbers, channel.width.to_s, true),
      edt_height = EditBox.new(p_("Conference", "Channel height"), EditBox::Flags::Numbers, channel.height.to_s, true),
      chk_password = CheckBox.new(p_("Conference", "Set channel password")),
      edt_password = EditBox.new(p_("Conference", "Channel password"), EditBox::Flags::Password, "", true),
      edt_passwordrepeat = EditBox.new(p_("Conference", "Repeat channel password"), EditBox::Flags::Password, "", true),
      btn_create = Button.new(p_("Conference", "Create")),
      btn_cancel = Button.new(p_("Conference", "Cancel"))
    ], 0, false, true)
    if channel.id != 0
      btn_create.label = p_("Conference", "Edit")
      form.hide(chk_password)
      form.hide(edt_password)
      form.hide(edt_passwordrepeat)
    end
    if !holds_premiumpackage("audiophile")
      form.hide(edt_width)
      form.hide(edt_height)
    end
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
    form.hide(edt_password)
    form.hide(edt_passwordrepeat)
    chk_password.on(:change) {
      if chk_password.value == 0
        form.hide(edt_password)
        form.hide(edt_passwordrepeat)
      else
        form.show(edt_password)
        form.show(edt_passwordrepeat)
      end
    }
    lst_spatialization.on(:move) {
      if lst_spatialization.index == 1
        t = Time.now.to_f
        l = load_hrtf
        lst_spatialization.index = 0 if l == false
        lst_spatialization.focus if Time.now.to_f - t > 3
      end
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
      if chk_password.value == 1 && (edt_password.text != edt_passwordrepeat.text)
        speak(p_("Conference", "Entered passwords are different."))
        suc = false
      end
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
        name = edt_name.text
        bitrate = bitrates[lst_bitrate.index]
        framesize = framesizes[lst_framesize.index]
        public = true
        password = nil
        password = edt_password.text if chk_password.value == 1
        spatialization = lst_spatialization.index
        channels = lst_channels.index + 1
        lang = ""
        if langs.size > 0
          lang = langs[lst_lang.index]
        end
        width = edt_width.text.to_i
        height = edt_height.text.to_i
        if channel.id == 0
          Conference.create(name, public, bitrate, framesize, password, spatialization, channels, lang, width, height)
        else
          Conference.edit(channel.id, name, public, bitrate, framesize, password, spatialization, channels, lang, width, height, channel.key_len)
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
    ret = []
    knownlanguages = Session.languages.split(",").map { |lg| lg.upcase }
    for ch in chans
      ret.push(ch) if LocalConfig["ConferenceShowUnknownLanguages"] == 1 || knownlanguages.size == 0 || knownlanguages.include?(ch.lang[0..1].upcase)
    end
    ret.sort! { |a, b|
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
    sel = ListBox.new(selt, p_("Conference", "Channel objects"))
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
      lst_objects = ListBox.new(objs.map { |o| o["name"] }, p_("Conference", "Available objects"), 0, 0, true),
      lst_position = ListBox.new([p_("Conference", "Here"), p_("Conference", "Everywhere")], p_("Conference", "Object position"), 0, 0, true),
      btn_ok = Button.new(p_("Conference", "Place object")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    refr = false
    lst_objects.bind_context { |menu|
      if objs.find_all { |o| o["owner"] == Session.name }.size < 10
        if holds_premiumpackage("audiophile")
          menu.option(p_("Conference", "Upload new sound")) {
            file = getfile(p_("Conference", "Select audio file"), Dirs.documents + "\\", false, nil, [".mp3", ".wav", ".ogg", ".mid", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"])
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
          }
        end
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
    ks = Conference.pushtotalk_keys
    keys = (65..90).to_a + (0x30..0x39).to_a + [0x20, 0xbc, 0xbd, 0xbe, 0xbf]
    keymapping = keys.map { |k| kbs = [false] * 256; kbs[k] = true; char_dict(getkeychar(kbs), true) }
    keys.insert(0, 0)
    keymapping.insert(0, p_("Conference", "No key"))
    form = Form.new([
      lst_modifiers = ListBox.new(["SHIFT", "CTRL", "ALT"], p_("Conference", "Modifiers"), 0, ListBox::Flags::MultiSelection, true),
      lst_key = ListBox.new(keymapping, p_("Conference", "Key"), 0, 0, true),
      btn_ok = Button.new(_("Save")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    form.cancel_button = btn_cancel
    form.accept_button = btn_ok
    lst_modifiers.selected[0] = ks.include?(0x10)
    lst_modifiers.selected[1] = ks.include?(0x11)
    lst_modifiers.selected[2] = ks.include?(0x12)
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
    self.class.setvolumes
  end

  def self.setvolumes
    dialog_open
    form = Form.new([
      lst_inputvolume = ListBox.new((0..300).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "Input volume"), 300 - Conference.input_volume, 0, true),
      lst_outputvolume = ListBox.new((0..100).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "Master volume"), 100 - Conference.output_volume, 0, true),
      lst_streamvolume = ListBox.new((0..100).to_a.reverse.map { |v| v.to_s + "%" }, p_("Conference", "Stream volume"), 100 - Conference.stream_volume, 0, true),
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
    st = @status
    edt = EditBox.new(p_("Conference", "Status"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, st)
    edt.focus
    loop do
      loop_update
      edt.update
      break if escape
      if @status != st
        st = @status
        edt.settext(st, false)
      end
    end
    @form.focus
  end

  def context_streaming(menu)
    menu.option(p_("Conference", "Channel objects"), nil, "o") { chanobjects }
    if holds_premiumpackage("audiophile")
      if Conference.cardset?
        menu.option(p_("Conference", "Remove soundcard stream")) { Conference.remove_card }
      else
        menu.option(p_("Conference", "Stream from soundcard")) {
          mics = Bass.microphones
          cardid = -1
          listen = false
          form = Form.new([
            lst_card = ListBox.new(mics, p_("Conference", "Select soundcard to stream"), 0, 0),
            chk_listen = CheckBox.new(p_("Conference", "Turn on the listening")),
            btn_cardok = Button.new(p_("Conference", "Stream")),
            btn_cardcancel = Button.new(_("Cancel"))
          ], 0, false, true)
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
            Conference.add_card(mics[cardid], listen)
          end
          @form.focus
        }
      end
    end
    if Conference.streaming?
      menu.option(p_("Conference", "Remove audio stream"), nil, "i") { Conference.remove_stream }
      menu.option(p_("Conference", "Scroll backward"), nil, "[") { Conference.scrollstream(-5) }
      menu.option(p_("Conference", "Scroll forward"), nil, "]") { Conference.scrollstream(5) }
      menu.option(p_("Conference", "Toggle pause"), nil, "p") { Conference.togglestream }
    else
      menu.option(p_("Conference", "Stream audio file"), nil, "i") {
        file = getfile(p_("Conference", "Select audio file"), Dirs.documents + "\\", false, nil, [".mp3", ".wav", ".ogg", ".mid", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"])
        if file != nil
          Conference.set_stream(file)
        end
        @form.focus
      }
    end
  end

  def context(menu)
    menu.submenu(p_("Conference", "Streaming")) { |m| context_streaming(m) }
    s = p_("Conference", "Mute microphone")
    s = p_("Conference", "Unmute microphone") if Conference.muted
    menu.option(s, nil, "M") {
      Conference.muted = !Conference.muted
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
        if holds_premiumpackage("audiophile")
          m.option(p_("Conference", "Save separate streams (experimental)"), nil, "S") {
            fullsave
          }
        end
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
    menu.submenu(p_("Conference", "Miscellaneous")) { |m|
      m.option(p_("Conference", "Roll a 6-sided dice"), nil, "d") { Conference.diceroll }
      m.option(p_("Conference", "Roll a custom dice"), nil, "D") {
        d = selector((1..100).to_a.map { |d| p_("Conference", "%{count}-sided") % { "count" => d.to_s } }, p_("Conference", "Which dice do you want to roll?"), @@lastdiceindex, -1, 1)
        @@lastdiceindex = d if d >= 0
        Conference.diceroll(d + 1) if d >= 0
      }
      m.option(p_("Conference", "Cardboard"), nil, "b") { decks }
    }
    menu.option(p_("Conference", "Show status")) { showstatus }
    if holds_premiumpackage("audiophile")
      menu.option(p_("Conference", "Change output soundcard")) {
        cards = [p_("Conference", "Use Elten soundcard")] + Bass.soundcards[2..-1]
        cardid = -1
        form = Form.new([
          lst_card = ListBox.new(cards, p_("Conference", "Select soundcard"), 0, 0),
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
      }
    end
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
          m.option(p_("Conference", "Edit channel")) {
            edit_channel(Conference.channel)
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
      lst_decks = ListBox.new([], p_("Conference", "Decks"), 0, 0, true),
      lst_cards = ListBox.new([], p_("Conference", "My cards"), 0, 0, true),
      lst_placed = ListBox.new([], p_("Conference", "Placed cards"), 0, 0, true),
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
    lst_banned = ListBox.new([], p_("Conference", "Banned users"), 0, 0, true)
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
    lst_administrators = ListBox.new([], p_("Conference", "administrators"), 0, 0, true)
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
end
