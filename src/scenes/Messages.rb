# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2022 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Messages
  def initialize(wn = 2000)
    $notifications_callback = Proc.new { |notif|
      if notif["cat"] == 1
        play(notif["sound"]) if notif["sound"] != nil
      else
        speech(notif["alert"]) if notif["alert"] != nil
        play(notif["sound"]) if notif["sound"] != nil
      end
    }
    if wn == true or wn == false or wn.is_a?(Integer) or wn.is_a?(String)
      @wn = wn
    elsif wn.is_a?(Array)
      import(wn)
      @imported = true
    end
  end

  def main()
    if Session.name == "guest"
      alert(_("This section is unavailable for guests"))
      $scene = Scene_Main.new
      return
    end
    if @imported != true
      if @wn != true && !@wn.is_a?(String)
        @cat = 0
        load_users
      elsif @wn == true
        @cat = 1
        load_conversations("", "new")
      elsif @wn.is_a?(String)
        if !@wn.include?(":")
          @cat = 1
          load_conversations(@wn)
        else
          @cat = 2
          a = @wn[0...@wn.index(":")]
          b = @wn[@wn.index(":") + 1..-1]
          b = nil if b == ""
          load_messages(a, b)
        end
      end
    else
      case @cat
      when 0
        @sel_users.focus
      when 1
        @sel_conversations.focus
      when 2
        @form_messages.focus
        load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit, true)
      end
      @imported = false
    end
    loop do
      loop_update
      break if $scene != self
      case @cat
      when 0
        update_users
      when 1
        update_conversations
      when 2
        update_messages
      end
    end
    loop_update
  end

  def export
    return [@wn, @cat, @users, @sel_users, @conversations, @conversations_user, @conversations_sp, @sel_conversations, @messages, @messages_subject, @messages_user, @messages_sp, @messages_limit, @sel_messages, @form_messages]
  end

  def import(arr)
    @wn, @cat, @users, @sel_users, @conversations, @conversations_user, @conversations_sp, @sel_conversations, @messages, @messages_subject, @messages_user, @messages_sp, @messages_limit, @sel_messages, @form_messages = arr
  end

  def name_conversation(conv)
    if $conversations == nil or ($conversationstime || 0) < Time.now.to_f - 90
      $conversations = {}
      $conversationstime = Time.now.to_f
      c = srvproc("messages_groups", { "ac" => "name" })
      if c[0].to_i == 0
        for i in 0...c[1].to_i
          $conversations[c[i * 2 + 2].delete("\r\n")] = c[i * 2 + 3].delete("\r\n")
        end
      end
    end
    $conversations[conv] || conv
  end

  def load_users(limit = @users_limit || 20)
    @lastuser = nil
    @lastuser = @users[@sel_users.index] if @users.is_a?(Array) and @sel_users.is_a?(ListBox)
    @users = []
    @users_limit = limit
    msg = srvproc("messages_conversations", { "limit" => @users_limit, "details" => 3 })
    if msg[0].to_i < 0
      alert(_("Error"))
      return $scene = Scene_Main.new
    end
    l = 0
    @users_more = (msg[2].to_i == 1) ? true : false
    for i in 3..msg.size - 1
      line = msg[i].delete("\r\n")
      case l
      when 0
        @users.push(Struct_Messages_User.new(line))
      when 1
        @users[-1].lastuser = line
      when 2
        @users[-1].lastdate = Time.at(line.to_i)
      when 3
        @users[-1].lastsubject = line
      when 4
        @users[-1].read = line.to_i
      when 5
        @users[-1].lastid = line.to_i
      when 6
        @users[-1].muted = (line.to_i == 1)
      when 7
        @users[-1].name = line.delete("\r\n")
      end
      l += 1
      l = 0 if l == 8
    end
    selt = []
    ind = 0
    for u in @users
      user = u.name
      user = u.user if u.name == "" || u.name == nil
      selt.push(user + ":\r\n" + p_("Messages", "Last message") + ": " + u.lastuser + ": " + u.lastsubject + ".\r\n" + format_date(u.lastdate) + "\r\n")
      selt[-1] += "\004INFNEW{#{p_("Messages", "New")}: }\004" if u.read == 0 and u.lastuser != Session.name
      ind = selt.size - 1 if u.user == @lastuser.user if @lastuser != nil
    end
    selt.push(p_("Messages", "Show older")) if @users_more
    @sel_users = ListBox.new(selt, p_("Messages", "Messages"), ind, 0, false)
    @sel_users.bind_context { |menu| context_users(menu) }
  end

  def update_users
    @sel_users.update
    if enter or arrow_right
      if @sel_users.index < @users.size
        if LocalConfig["MessagesDefaultToAllMessages"] == 0
          load_conversations(@users[@sel_users.index].user)
          @cat = 1
        else
          load_messages(@users[@sel_users.index].user, nil)
          @cat = 2
        end
      else
        @sel_users.index -= 1
        ad = 20
        ad = 100 if $keyr[0x10]
        load_users(@users_limit + ad)
        @sel_users.say_option
      end
    end
    $scene = Scene_Main.new if escape
  end

  def context_users(menu)
    if @users.size > 0 and @sel_users.index < @users.size
      menu.option(p_("Messages", "Reply"), nil, "o") {
        $scene = Scene_Messages_New.new(@users[@sel_users.index].user, "", "", export)
      }
      if LocalConfig["MessagesDefaultToAllMessages"] == 0
        menu.option(p_("Messages", "Show all messages"), nil, :shift_enter) {
          load_messages(@users[@sel_users.index].user, nil)
          @cat = 2
        }
      else
        menu.option(p_("Messages", "Show subjects"), nil, :shift_enter) {
          load_conversations(@users[@sel_users.index].user)
          @cat = 1
        }
      end
      menu.option(p_("Messages", "Mark all messages in this conversation as read"), nil, "w") {
        msgtemp = srvproc("message_allread", { "user" => @users[@sel_users.index].user })
        if msgtemp[0].to_i < 0
          alert(_("Error"))
          $scene = Scene_Main.new
        end
        alert(p_("Messages", "All messages in this conversation have been marked as read."))
        speech_wait
        if @wn == true
          $scene = Scene_WhatsNew.new
        else
          main
        end
      }
      menu.submenu(p_("Messages", "Add conversation to quick actions")) { |m|
        m.option(p_("Messages", "Add list of conversations to quick actions"), nil, "q") {
          QuickActions.create(Scene_Messages, p_("Messages", "Conversations with %{user}") % { "user" => @users[@sel_users.index].user }, [@users[@sel_users.index].user])
          alert(p_("Messages", "Conversations added to quick actions"))
        }
        m.option(p_("Messages", "Add all messages in this conversation to quick actions"), nil, "Q") {
          QuickActions.create(Scene_Messages, p_("Messages", "Messages with %{user}") % { "user" => @users[@sel_users.index].user }, [@users[@sel_users.index].user + ":"])
          alert(p_("Messages", "Conversation added to quick actions"))
        }
      }
      if @users[@sel_users.index].muted == false
        menu.submenu(p_("Messages", "Mute this conversation")) { |m|
          ms = [[p_("Messages", "Mute for a quarter"), 900], [p_("Messages", "Mute for an hour"), 3600], [p_("Messages", "Mute for a day"), 86400], [p_("Messages", "Mute for a week"), 86400 * 7], [p_("Messages", "Mute until manually unmuted"), 0]]
          for mt in ms
            m.option(mt[0], mt[1]) { |t|
              mute_conversation(@users[@sel_users.index], t)
            }
          end
        }
      else
        menu.option(p_("Messages", "Unmute this conversation")) {
          mute_conversation(@users[@sel_users.index], false)
        }
      end
      if @users[@sel_users.index].user[0..0] == "["
        menu.option(p_("Messages", "Edit conversation"), nil, "e") {
          edit_conversation(@users[@sel_users.index])
          @sel_users.focus
        }
        menu.option(p_("Messages", "Leave")) {
          confirm(p_("Messages", "Are you sure you want to leave this group?")) {
            srvproc("messages_groups", { "ac" => "leave", "groupid" => @users[@sel_users.index].user })
          }
          load_users
          @sel_users.focus
        }
      else
        menu.option(p_("Messages", "Delete conversations"), nil, :del) {
          deleteuser(@users[@sel_users.index])
        }
      end
    end
    s = p_("Messages", "Set all messages as a default view")
    s = p_("Messages", "Set subjects as a default view") if LocalConfig["MessagesDefaultToAllMessages"] == 1
    menu.option(s) {
      LocalConfig["MessagesDefaultToAllMessages"] = ((LocalConfig["MessagesDefaultToAllMessages"] == 0) ? (1) : (0))
      alert(_("Saved"))
    }
    menu.option(p_("Messages", "Create new conversation"), nil, "t") {
      edit_conversation
      @sel_users.focus
    }
    menu.option(p_("Messages", "Send a new message"), nil, "n") {
      $scene = Scene_Messages_New.new("", "", "", export)
    }
    menu.option(p_("Messages", "Mark all messages as read"), nil, "W") {
      confirm(p_("messages", "Are you sure you want to mark all messages in all conversations as read?")) {
        msgtemp = srvproc("message_allread", {})
        if msgtemp[0].to_i < 0
          alert(_("Error"))
          $scene = Scene_Main.new
        end
        alert(p_("Messages", "All messages have been marked as read."))
        speech_wait
        if @wn == true
          $scene = Scene_WhatsNew.new
        else
          main
        end
      }
    }
    menu.option(p_("Messages", "Search"), nil, "f") {
      load_messages("", "", "search")
      @cat = 2
    }
    menu.option(p_("Messages", "Show flagged messages"), nil, "g") {
      load_messages("", "", "flagged")
      @cat = 2
    }
    menu.option(_("Refresh"), nil, "r") {
      load_users
    }
  end

  def edit_conversation(c = nil)
    banned = isbanned(Session.name)
    cname = ""
    cusers = [Session.name]
    if c != nil
      cname = name_conversation(c.user)
      cs = srvproc("messages_groups", { "ac" => "listusers", "groupid" => c.user })
      cusers = cs[2...2 + cs[1].to_i].map { |u| u.delete("\r\n") } if cs[0].to_i == 0
    end
    cusers.polsort!
    form = Form.new([
      EditBox.new(p_("Messages", "Conversation name"), "", cname, true),
      ListBox.new(cusers, p_("Messages", "Conversation members")),
      Button.new(p_("Messages", "Create")),
      Button.new(_("Cancel"))
    ])
    users = cusers.deep_dup
    form.fields[2] = Button.new(p_("messages", "Modify")) if c != nil
    cre = form.fields[2]
    form.fields[2] = nil
    form.fields[1].bind_context { |menu|
      if !banned
        menu.option(p_("Messages", "Add user"), nil, "n") {
          user = input_user(p_("Messages", "User to add"))
          if user != nil and !users.include?(user)
            users.push(user)
            form.fields[1].options.push(user)
            form.focus
          end
        }
      end
      if users.size > 0 and users[form.fields[1].index] != Session.name and !cusers.include?(users[form.fields[1].index])
        menu.option(p_("Messages", "Delete user from conversation"), nil, :del) {
          play("editbox_delete")
          users.delete_at(form.fields[1].index)
          form.fields[1].options.delete_at(form.fields[1].index)
          form.fields[1].say_option
        }
      end
    }
    loop do
      loop_update
      form.update
      break if form.fields[3].pressed? or escape
      if users.size > 1 and form.fields[0].text.size > 0
        form.fields[2] = cre
      else
        form.fields[2] = nil
      end
      if form.fields[2] != nil and form.fields[2].pressed?
        if c == nil
          prm = { "ac" => "create", "groupname" => form.fields[0].text, "users" => users.join(",") }
        else
          addusers = []
          for u in users
            addusers.push(u) if !cusers.include?(u)
          end
          prm = { "ac" => "edit", "groupid" => c.user, "groupname" => form.fields[0].text, "addusers" => addusers.join(",") }
        end
        r = srvproc("messages_groups", prm)
        if r[0].to_i < 0
          alert(_("Error"))
        else
          if c == nil
            alert(p_("Messages", "Conversation has been created"))
          else
            alert(p_("Messages", "Conversation has been modified"))
          end
        end
        $conversationstime = 0
        speech_wait
        load_users
        break
      end
    end
    loop_update
  end

  def mute_conversation(u, time = false)
    ac = { "groupid" => u.user }
    if !time.is_a?(Integer)
      ac["ac"] = "unmute"
    else
      ac["ac"] = "mute"
      if time > 0
        ac["totime"] = Time.now.to_i + time
      else
        ac["totime"] = 0
      end
    end
    if srvproc("messages_groups", ac)[0].to_i == 0
      if !time.is_a?(Integer)
        u.muted = false
      else
        u.muted = true
      end
      alert(_("Saved"))
    else
      alert(_("Error"))
    end
  end

  def deleteuser(u)
    return if u.user[0..0] == "["
    confirm(p_("Messages", "Are you sure you want to delete all messages with user %{user}") % { "user" => u.user }) do
      if srvproc("messages", { "delete" => 3, "user" => u.user })[0].to_i < 0
        alert(_("Error"))
        return
      end
      alert(p_("Messages", "All conversations with user have been deleted."))
      @sel_users.disable_item(@sel_users.index)
      @sel_users.focus
    end
  end

  def load_conversations(user, sp = nil, limit = @conversations_limit || 20)
    msg = ""
    if sp == nil
      @user = user
      @lastconversation = nil
      @lastconversation = @conversations[@sel_conversations.index] if @conversations.is_a?(Array) and @sel_conversations.is_a?(ListBox)
      @lastconversation_user = user
      @conversations = []
      @conversations_user = user
      @conversations_limit = limit
      msg = srvproc("messages_conversations", { "user" => user, "limit" => @conversations_limit.to_i, "details" => 1 })
    else
      @conversations_sp = sp
      @conversations = []
      msg = srvproc("messages_conversations", { "sp" => sp, "details" => 1 })
    end
    if msg[0].to_i < 0
      alert(_("Error"))
      return $scene = Scene_WhatsNew.new
    end
    if msg[1].to_i == 0 and sp == "new"
      alert(p_("Messages", "There are no new messages"))
      return $scene = Scene_WhatsNew.new
    end
    @conversations_more = (msg[2].to_i == 1) ? true : false
    @conversation_name = msg[4].delete("\r\n")
    l = 0
    for i in 5..msg.size - 1
      line = msg[i].delete("\r\n")
      case l
      when 0
        @conversations.push(Struct_Messages_Conversation.new(line))
      when 1
        @conversations[-1].lastuser = line
      when 2
        @conversations[-1].lastdate = Time.at(line.to_i)
      when 3
        @conversations[-1].read = line.to_i
      when 4
        @conversations[-1].lastid = line.to_i
      end
      l += 1
      l = 0 if l == 5
    end
    selt = []
    ind = 0
    for c in @conversations
      lu = c.lastuser
      lu = @conversation_name if @conversation_name != "" && @conversation_name != nil && lu[0..0] == "["
      lu = name_conversation(lu) if lu[0..0] == "["
      selt.push(((c.subject != "") ? (c.subject) : p_("Messages", "No subject")) + ":\r\n" + ((sp == nil) ? p_("Messages", "Last message") : p_("Messages", "From")) + ": " + lu + ".\r\n" + format_date(c.lastdate) + "\r\n")
      selt[-1] += "\004INFNEW{#{p_("Messages", "New")}: }\004" if c.read == 0 and c.lastuser != Session.name
      ind = selt.size - 1 if c.subject == @lastconversation.subject and user == @lastconversation_user if @lastconversation != nil and @lastconversation_user != nil
    end
    selt.push(p_("Messages", "Show older")) if @conversations_more
    u = user
    u = @conversation_name if @conversation_name != "" && @conversation_name != nil
    @sel_conversations = ListBox.new(selt, ((sp == nil) ? (p_("Messages", "Conversations with %{user}") % { "user" => u }) : ""), ind, 0, false)
    @sel_conversations.bind_context { |menu| context_conversations(menu) }
  end

  def update_conversations
    @sel_conversations.update
    if enter or arrow_right
      if @sel_conversations.index < @conversations.size
        load_messages(@conversations_user || @conversations[@sel_conversations.index].lastuser, @conversations[@sel_conversations.index].subject, @conversations_sp)
        @cat = 2
      else
        @sel_conversations.index -= 1
        load_conversations(@conversations_user, nil, @conversations_limit + 20)
        @sel_conversations.say_option
      end
    end
    if escape or arrow_left or @sel_conversations.options.size == 0
      return $scene = Scene_Main.new if @wn.is_a?(String)
      if @conversations_sp != "new"
        load_users
        loop_update
        @cat = 0
        @sel_conversations = nil
      else
        return $scene = Scene_WhatsNew.new
      end
    end
  end

  def context_conversations(menu)
    if @conversations.size > 0 and @sel_conversations.index < @conversations.size
      menu.option(p_("Messages", "Reply in thread"), nil, "o") {
        $scene = Scene_Messages_New.new(@user, "RE: " + @conversations[@sel_conversations.index].subject, "", export)
      }
      menu.option(p_("Messages", "Delete conversation"), nil, :del) {
        deleteconversation(@conversations[@sel_conversations.index])
      }
    end
    if @conversations_sp != "new"
      menu.option(p_("Messages", "Send a new message in this conversation"), nil, "n") {
        $scene = Scene_Messages_New.new(@user, "", "", export)
      }
    end
    menu.option(_("Refresh"), nil, "r") {
      load_conversations(@user)
    }
  end

  def deleteconversation(c)
    return if @user == nil
    return if @user[0..0] == "["
    confirm(p_("Messages", "Are you sure you want to delete conversation %{conversationname} with user %{user}") % { "conversationname" => c.subject, "user" => @user }) do
      if srvproc("messages", { "delete" => 2, "user" => @user, "subj" => c.subject })[0].to_i < 0
        alert(_("Error"))
        return
      end
      alert(p_("Messages", "The conversation has been deleted."))
      @sel_conversations.disable_item(@sel_conversations.index)
      @sel_conversations.focus
    end
  end

  def load_messages(user, subject, sp = nil, limit = @messages_limit || 50, complete = false)
    @messages = [] if !complete
    @messages_user = user
    @messages_subject = subject
    @messages_sp = sp
    @messages_limit = limit if !complete
    msg = ""
    if sp == "flagged"
      msg = srvproc("messages_conversations", { "sp" => "flagged", "details" => 2 })
    elsif sp == "search"
      term = input_text(p_("Messages", "Enter a phrase to look for"), 0, @lastsearch || "", true)
      if term == nil
        @cat = 0
        return
      end
      @lastsearch = term
      msg = srvproc("messages_conversations", { "sp" => "search", "search" => term, "details" => 3 })
    else
      msg = srvproc("messages_conversations", { "user" => user, "subj" => subject, "ignoresubj" => (subject == nil) ? (1) : (0), "limit" => @messages_limit.to_s, "details" => 3 })
    end
    @messages_wn = 0
    if $agent_msg != nil
      @messages_wn = $agent_msg
    end
    if msg[0].to_i < 0
      alert(_("Error"))
      return $scene = Scene_Main.new
    end
    @messages_more = (msg[2].to_i == 1) ? true : false if !complete
    @messages_name = msg[4].delete("\r\n")
    m = nil
    curids = []
    @messages.each { |m| curids.push(m.id) }
    for mesg in msg[5..-1].join.split("\r\n\004END\004")
      mesg[0..1] = "" if mesg[0..1] == "\r\n"
      next if mesg == ""
      message = mesg.split("\r\n")
      for l in 0..9
        line = message[l]
        case l
        when 0
          m = Struct_Messages_Message.new(line.to_i)
        when 1
          m.sender = line
          m.receiver = ((m.sender == Session.name) ? user : Session.name)
        when 2
          m.subject = line
        when 3
          m.date = Time.at(line.to_i)
        when 4
          m.mread = line.to_i
        when 5
          m.marked = line.to_i
        when 6
          m.attachments = (line || "").split(",")
          m.attachments.delete(nil) if m.attachments.size > 0
          name_attachments(m.attachments, m.attachments_names) if m.attachments.size > 0
        when 7
          m.protected = line.to_i
        when 8
          m.polls = (line || "").split(",").map { |a| a.to_i }
          names = []
          for o in m.polls
            pl = srvproc("polls", { "get" => "1", "poll" => o.to_s })
            names.push(pl[2].delete("\r\n")) if pl[0].to_i == 0 and pl.size > 1
          end
          m.polls_names = names
        when 9
          m.text = message[l..-1].join("\n")
          if !(complete and curids.include?(m.id))
            o = (complete) ? 0 : (@messages.size)
            @messages.insert(o, m)
          end
        end
      end
    end
    selt = []
    for m in @messages
      if !curids.include?(m.id)
        if complete
          play "messages_update"
        end
        m.date = Time.now if m.date == 0
        selt.push(m.sender)
        selt[-1] += "\004ATTACHMENT\004" if m.attachments.size > 0
        selt[-1] += ":\r\n" + ((sp != nil and sp != "new") ? (m.subject + ":\r\n") : "") + m.text.gsub("\004LINE\004", "\r\n").split("")[0...5000].join + ((m.text.size > 5000) ? "... #{p_("Messages", "Open this message to read more")}" : "") + "\r\n" + format_date(m.date) + "\r\n"
        selt[-1] += "\004INFNEW{#{p_("Messages", "New")}: }\004" if m.mread == 0
      end
    end
    selt.push(p_("Messages", "Show older")) if @messages_more and !complete
    if !complete
      u = user
      u = @messages_name if @messages_name != "" && @messages_name != nil
      head = p_("Messages", "Messages in conversation %{subject} with %{user}") % { "subject" => subject || "", "user" => u }
      head = p_("Messages", "Flagged messages") if sp == "flagged"
      head = p_("Messages", "Found items") if sp == "search"
      @sel_messages = ListBox.new(selt, head)
      @sel_messages.bind_context { |menu| context_messages(menu) }
      @form_messages = Form.new([@sel_messages, nil, nil, EditBox.new(p_("Messages", "Your reply"), EditBox::Flags::MultiLine, "", true), nil, Button.new(p_("Messages", "Compose"))], 0, true)
      @form_messages.fields[3..5] = [nil, nil, nil] if msg[3].to_i == 0 or @messages_sp == "flagged" or @messages_sp == "search"
    else
      @sel_messages.options = selt + @sel_messages.options
      @sel_messages.index += selt.size
    end
  end

  def update_messages
    if $agent_msg != nil and @form_messages != nil and @form_messages.index != 3 and @form_messages.index != 4
      mwn = $agent_msg
      load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit, true) if mwn > @messages_wn
      @messages_wn = mwn
    end
    @form_messages.update
    if escape or ((arrow_left and @form_messages.index == 0) and @form_messages.fields[0] == @sel_messages) or (@sel_messages.options.size - @sel_messages.grayed.count(true)) == 0
      if @form_messages.fields[0] == @sel_messages
        if (@form_messages.fields[3] == nil || @form_messages.fields[3].text == "") || confirm(p_("Messages", "Are you sure you want to cancel creating this message?")) == 1
          return $scene = Scene_Main.new if @wn.is_a?(String)
          if @messages_sp != "flagged" and @messages_sp != "search" and @messages_subject != nil
            load_conversations(@messages_user, @messages_sp)
            @cat = 1
            @sel_messages = nil
          else
            load_users
            @cat = 0
          end
          loop_update
        end
      else
        hide_message
      end
    end
    process_attachment(@messages[@sel_messages.index].attachments[@form_messages.fields[1].index]) if enter and @form_messages.index == 1 and @form_messages.fields[1] != nil
    if enter and @form_messages.index == 2 and @form_messages.fields[2] != nil
      pl = @messages[@sel_messages.index].polls[@form_messages.fields[2].index]
      voted = false
      voted = true if srvproc("polls", { "voted" => "1", "poll" => pl.to_s })[1].to_i == 1
      selt = [p_("Polls", "Vote"), p_("Polls", "Show results"), p_("Polls", "Show report")]
      selt[0] = nil if voted || isbanned(Session.name)
      case menuselector(selt)
      when 0
        insert_scene(Scene_Polls_Answer.new(pl.to_i, Scene_Main.new))
      when 1
        insert_scene(Scene_Polls_Results.new(pl.to_i, Scene_Main.new))
      when 2
        insert_scene(Scene_Polls_Report.new(pl.to_i, Scene_Main.new))
      end
      loop_update
      @form_messages.focus
    end
    if (enter or arrow_right) and @sel_messages != nil and @sel_messages.index == @messages.size
      ind = @sel_messages.index
      ad = 50
      ad = 500 if $keyr[0x10]
      load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit + ad)
      @sel_messages.index = ind
      @sel_messages.say_option
    end
    return if @messages.size == 0 or @sel_messages == nil or @messages[@sel_messages.index] == nil
    if @message_display == nil or @message_display[0] != @messages[@sel_messages.index].id
      @message_display = [@messages[@sel_messages.index].id, Time.now]
    elsif @message_display[0] == @messages[@sel_messages.index].id and ((t = Time.now).to_i * 1000000 + t.usec) - (@message_display[1].to_i * 1000000 + @message_display[1].usec) > 3000000 and @messages[@sel_messages.index].receiver == Session.name and @messages[@sel_messages.index].mread == 0
      @messages[@sel_messages.index].mread = Time.now.to_i
      @sel_messages.options[@sel_messages.index].gsub!(/\004INFNEW\{([^\}]+)\}\004/, "")
    end
    if @messages[@sel_messages.index] != nil
      if @sel_messages.index < @messages.size and @messages[@sel_messages.index] != nil and @messages[@sel_messages.index].attachments.size > 0 and (@form_messages.fields[1] == nil or @form_messages.fields[1].options != name_attachments(@messages[@sel_messages.index].attachments, @messages[@sel_messages.index].attachments_names))
        @form_messages.fields[1] = ListBox.new(name_attachments(@messages[@sel_messages.index].attachments, @messages[@sel_messages.index].attachments_names), p_("Messages", "Attachments"))
      elsif @sel_messages.index >= @messages.size or @messages[@sel_messages.index].attachments.size == 0 and @form_messages.fields[1] != nil
        @form_messages.fields[1] = nil
        @form_messages.index = 0 if @form_messages.index == 1
      end
      if @sel_messages.index < @messages.size and @messages[@sel_messages.index] != nil and @messages[@sel_messages.index].polls.size > 0 and (@form_messages.fields[2] == nil or @form_messages.fields[2].options != @messages[@sel_messages.index].polls_names)
        @form_messages.fields[2] = ListBox.new(@messages[@sel_messages.index].polls_names, p_("Messages", "Polls"))
      elsif @sel_messages.index >= @messages.size or @messages[@sel_messages.index].polls.size == 0 and @form_messages.fields[2] != nil
        @form_messages.fields[2] = nil
        @form_messages.index = 0 if @form_messages.index == 2
      end
      deletemessage if $key[0x2e] and @sel_messages.index < @messages.size and @form_messages.index == 0
      if enter or arrow_right and @form_messages.index == 0 and @form_messages.fields[0] == @sel_messages
        if @sel_messages.index < @messages.size
          show_message(@messages[@sel_messages.index])
          loop_update
          return if $scene != self
          @sel_messages.options[@sel_messages.index].gsub!(/\004INFNEW\{([^\}]+)\}\004/, "") if @messages[@sel_messages.index].receiver == Session.name
        end
      end
    end
    if @form_messages.fields[3] != nil
      if @form_messages.fields[3].text == "" and @form_messages.fields[4] != nil
        @form_messages.fields[4] = nil
      elsif @form_messages.fields[3].text != "" and @form_messages.fields[4] == nil
        @form_messages.fields[4] = Button.new(p_("Messages", "Send"))
      end
      if (((enter or space) and @form_messages.index == 4) or ((enter and $key[0x11]) and @form_messages.index == 3)) and @form_messages.fields[3].text != ""
        post = {}
        text = @form_messages.fields[3].text
        if text.size < 1024
          post["text"] = text
        else
          post["zs_text"] = zstd_compress(text)
        end
        msgtemp = srvproc("message_send", { "to" => @messages_user, "subject" => ("RE: " + (@messages_subject || "")) }, 0, post)
        if msgtemp[0].to_i < 0
          alert(p_("Messages", "Failed to send message"))
        else
          @form_messages.index = 3
          @form_messages.fields[3].set_text("")
          alert(p_("Messages", "Message has been sent"))
        end
        load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit, true)
      end
      if (enter or space) and @form_messages.index == 5
        $scene = Scene_Messages_New.new(@messages_user, "RE: " + (@messages_subject || "").sub("RE: ", ""), @form_messages.fields[3], export)
      end
    end
  end

  def context_messages(menu)
    return if @sel_messages == nil
    menu.option(p_("Messages", "Reply"), nil, "o") {
      $scene = Scene_Messages_New.new(@messages_user, "RE: " + (@messages_subject || "").sub("RE: ", ""), @form_messages.fields[3], export)
    }
    if @messages.size > 0 and @sel_messages.index < @messages.size
      menu.option(p_("Messages", "Reply to message sender"), nil, "O") {
        rec = @messages[@sel_messages.index].sender
        rec = @messages[@sel_messages.index].receiver if rec == Session.name
        $scene = Scene_Messages_New.new(rec, "RE: " + @messages[@sel_messages.index].subject.sub("RE: ", ""), "", export)
      }
    end
    if @sel_messages.index < @messages.size and @messages[@sel_messages.index].receiver == Session.name
      s = p_("Messages", "Flag")
      s = p_("Messages", "Remove flag") if @messages[@sel_messages.index].marked == 1
      menu.option(s, nil, "g") {
        if @messages[@sel_messages.index].marked == 0
          if srvproc("messages", { "mark" => "1", "id" => @messages[@sel_messages.index].id })[0].to_i < 0
            alert(_("Error"))
          else
            alert(p_("Messages", "This message has been flagged."))
            @messages[@sel_messages.index].marked = 1
          end
        else
          if srvproc("messages", { "unmark" => "1", "id" => @messages[@sel_messages.index].id })[0].to_i < 0
            alert(_("Error"))
          else
            alert(p_("Messages", "This message is no longer flagged."))
            @messages[@sel_messages.index].marked = 0
          end
        end
        @form_messages.focus
      }
    end
    if @sel_messages.index < @messages.size and @messages[@sel_messages.index].receiver[0..0] != "["
      s = p_("Messages", "Protect")
      s = p_("Messages", "Unprotect") if @messages[@sel_messages.index].protected == 1
      menu.option(s, nil, "c") {
        if @messages[@sel_messages.index].protected == 1 || requires_premiumpackage("courier")
          if @messages[@sel_messages.index].protected == 0
            if srvproc("messages", { "protect" => "1", "id" => @messages[@sel_messages.index].id })[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Messages", "This message has been protected."))
              @messages[@sel_messages.index].protected = 1
            end
          else
            if srvproc("messages", { "unprotect" => "1", "id" => @messages[@sel_messages.index].id })[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Messages", "This message is no longer protected."))
              @messages[@sel_messages.index].protected = 0
            end
          end
          @form_messages.focus
        end
      }
    end
    if @messages.size > 0 and @sel_messages.index < @messages.size and @messages_user[0..0] != "["
      menu.option(_("Delete")) {
        deletemessage
      }
    end
    if @messages_sp != "new"
      menu.option(p_("Messages", "Send a new message in this conversation"), nil, "n") {
        $scene = Scene_Messages_New.new(@messages_user, "", "", export)
      }
    end
    if @messages.size > 0 and @sel_messages.index < @messages.size
      menu.option(p_("Messages", "Forward"), nil, "d") {
        t = "#{@messages[@sel_messages.index].sender}: \r\n" + @messages[@sel_messages.index].text
        $scene = Scene_Messages_New.new("", "FW: " + @messages[@sel_messages.index].subject, t, export)
      }
    end
    menu.option(_("Refresh"), nil, "r") {
      load_messages(@messages_user, @messages_subject)
    }
  end

  def show_message(message)
    dialog_open
    message.mread = 1 if message.receiver == Session.name
    date = format_date(message.date)
    if message.receiver != Session.name
      @form_messages.fields[0] = EditBox.new(message.subject + " #{p_("Messages", "From")}: " + message.sender, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, message.text + "\r\n" + date)
    else
      @form_messages.fields[0] = EditBox.new(message.subject + " #{p_("Messages", "To")}: " + message.receiver, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, message.text + "\r\n" + date)
    end
    @form_messages.fields[0].focus
  end

  def hide_message
    @form_messages.fields[0] = @sel_messages
    @form_messages.index = 0
    @form_messages.focus
    dialog_close
  end

  def deletemessage
    return if @messages_user[0..0] == "["
    confirm(p_("Messages", "Are you sure you want to delete this message?")) do
      if srvproc("messages", { "delete" => "1", "id" => @messages[@sel_messages.index].id.to_s })[0].to_i < 0
        alert(_("Error"))
        return
      end
      alert(p_("Messages", "The message has been deleted."))
      @sel_messages.disable_item(@sel_messages.index)
      @form_messages.focus
    end
  end

  private

  def audiolimit
    if holds_premiumpackage("audiophile")
      return 0
    else
      return 120
    end
  end
end

class Struct_Messages_User
  attr_accessor :user, :read, :lastdate, :lastuser, :lastsubject, :lastid, :muted, :name

  def initialize(user = "")
    @user = user
  end
end

class Struct_Messages_Conversation
  attr_accessor :subject, :read, :lastdate, :lastuser, :lastid

  def initialize(subj = "")
    @subject = subj
  end
end

class Scene_Messages_New
  def initialize(receiver = "", subject = "", text = "", scene = false)
    @receiver = receiver
    @subject = subject
    @text = text
    @scene = scene
  end

  def main
    receiver = @receiver
    subject = @subject
    text = @text
    text = @text.text if @text.is_a?(EditBox)
    @fields = []
    @fields[0] = EditBox.new(p_("Messages", "Recipient"), "", receiver, true)
    @fields[0] = nil if receiver[0..0] == "["
    @fields[1] = EditBox.new(p_("Messages", "Subject:"), "", subject, true)
    @fields[2] = ((@text.is_a?(EditBox)) ? @text : EditBox.new(p_("Messages", "Message:"), EditBox::Flags::MultiLine, text, true)) if !(@text.is_a?(String) and @text.include?("\004AUDIO\004"))
    @fields[3] = OpusRecordButton.new(p_("Messages", "Audio message"), Dirs.temp + "\\audiomessage.opus", bitratelimit, 48, audiolimit) if !(@text.is_a?(String) and @text.include?("\004AUDIO\004"))
    @fields[4] = nil
    @fields[5] = ListBox.new([], p_("Messages", "Attachments"))
    @fields[6] = ListBox.new([], p_("Messages", "Polls"))
    @fields[7] = Button.new(_("Cancel"))
    @fields[8] = nil
    @fields[5].bind_context { |menu|
      if @attachments.size < 3
        menu.option(p_("Messages", "Attach a file"), nil, "n") {
          loc = get_file(p_("Messages", "Select a file to attach"), Dirs.documents + "\\", false)
          if loc != nil
            size = File.size(loc)
            atsize = 4 * 1024 ** 2
            atsize = 32 * 1024 ** 2 if holds_premiumpackage("courier")
            if size > atsize
              alert(p_("Messages", "The file is too large."))
            else
              @attachments.push(loc)
              @fields[5].options.push(File.basename(loc))
              alert(p_("Messages", "File attached."))
            end
          else
            loop_update
          end
        }
      end
      if @attachments.size > 0
        menu.option(p_("Messages", "Delete attachment"), nil, :del) {
          play("editbox_delete")
          @attachments.delete_at(@form.fields[5].index)
          @form.fields[5].options.delete_at(@form.fields[5].index)
          @form.fields[5].index -= 1 if @attachments.size > 0 && @form.fields[5].index >= @attachments.size
          @form.fields[5].say_option
        }
      end
    }
    @fields[6].bind_context { |menu|
      if @polls.size < 3
        menu.option(p_("Messages", "Attach a poll"), nil, "n") {
          if requires_premiumpackage("courier")
            pls = srvproc("polls", { "list" => "1", "byme" => "1" })
            if pls[0].to_i == 0
              if pls[1].to_i > 0
                ids = []
                names = []
                for i in 1...pls.size
                  if i == 1 or pls[i].delete("\r\n") == "\004END\004"
                    ids.push(pls[i + 1].to_i)
                    names.push(pls[i + 2])
                  end
                end
                ind = selector(names, p_("Messages", "Poll to attach"), 0, -1)
                if ind == -1
                  @form.focus
                else
                  if @polls.include?(ids[ind])
                    alert(p_("Messages", "This poll has already been added"))
                  else
                    @polls.push(ids[ind])
                    @fields[6].options.push(names[ind])
                    alert(p_("Messages", "Poll has been added"))
                  end
                end
              else
                alert(p_("Messages", "You haven't created any polls yet."))
              end
            else
              alert(_("Error"))
            end
          end
        }
      end
      if @polls.size > 0
        menu.option(p_("Messages", "Delete poll"), nil, :del) {
          play("editbox_delete")
          @polls.delete_at(@form.fields[6].index)
          @form.fields[6].options.delete_at (@form.fields[6].index)
          @form.fields[6].index -= 1 if @polls.size > 0 && @form.fields[6].index >= @polls.size
          @form.fields[6].say_option
        }
      end
    }
    ind = 0
    ind = 1 if receiver != ""
    ind = 2 if receiver != "" and subject != ""
    @form = Form.new(@fields, ind)
    @attachments = []
    @polls = []
    loop do
      loop_update
      notempt = (@form.fields[2].is_a?(EditBox) && @form.fields[2].text != "") || (@form.fields[3].is_a?(OpusRecordButton) && !@form.fields[3].empty?)
      notempt = true if @form.fields[2] == nil and @form.fields[3] == nil
      if @form.fields[4] == nil && notempt
        @form.fields[4] = Button.new(p_("Messages", "Send"))
        @form.fields[8] = Button.new(p_("Messages", "Send as admin")) if Session.moderator > 0
      elsif @form.fields[4] != nil && !notempt
        @form.fields[4] = nil
        @form.fields[8] = nil if Session.moderator > 0
      end
      if (arrow_up or arrow_down) and @form.index == 0
        s = selectcontact
        if s != nil
          @form.fields[0].set_text(s)
        end
      end
      if @form.fields[3].is_a?(OpusRecordButton)
        if @form.fields[3].empty?
          @form.show(2)
        else
          @form.hide(2)
        end
      end
      @form.update
      if (enter or space) and ((@form.index == 4 or @form.index == 8) or ($key[0x11] == true and enter))
        receiver = @form.fields[0].text if @form.fields[0] != nil
        receiver = @receiver if @form.fields[0] == nil
        receiver.sub!("@elten.me", "")
        receiver = finduser(receiver) if receiver.include?("@") == false and finduser(receiver).upcase == receiver.upcase
        if (user_exists(receiver) == false or @form.index == 8 and (/^[a-zA-Z0-9.\-_\+]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/ =~ receiver) == nil) and @form.fields[0] != nil
          alert(p_("Messages", "The recipient cannot be found."))
        elsif (/^[a-zA-Z0-9.\-_\+]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/ =~ receiver) != nil
          if confirm(p_("Messages", "Do you want to send this message as e-mail?")) == 1
            subject = @form.fields[1].text
            text = @form.fields[2].text if @form.fields[2] != nil
            play("listbox_select")
            break
          end
        else
          subject = @form.fields[1].text
          text = @form.fields[2].text if @form.fields[2] != nil
          text = @text if @form.fields[2] == nil
          play("listbox_select")
          break
        end
      end
      if (escape or ((enter or space) and @form.index == 7)) && (@form.fields[3] == nil || @form.fields[3].delete_audio)
        if (@form.fields[2] == nil || @form.fields[2].text == "") || confirm(p_("Messages", "Are you sure you want to cancel creating this message?")) == 1
          if @scene != false and @scene != true and @scene.is_a?(Integer) == false and @scene.is_a?(Array) == false
            $scene = @scene
          else
            $scene = Scene_Messages.new(@scene)
          end
        end
        loop_update
        return
        break
      end
    end
    @att = ""
    if @attachments.size > 0
      for a in @attachments
        @att += send_attachment(a) + ","
      end
      @att.chop! if @att[-1..-1] == ","
    end
    msgtemp = ""
    prm = { "to" => receiver, "subject" => subject }
    prm["polls"] = @polls.map { |l| l.to_s }.join(",") if @polls.size > 0
    post = {}
    post["attachments"] = @att if @att != "" and @att != nil
    if @form.fields[3] == nil or @form.fields[3].empty?
      tmp = ""
      tmp = "admin_" if @form.index == 7
      msgtemp = ""
      if text.size < 1024
        post["text"] = text
      else
        post["zs_text"] = zstd_compress(text)
      end
      msgtemp = srvproc("message_#{tmp}send", prm, 0, post)
    else
      f = @form.fields[3]
      fl = readfile(f.get_file)
      if fl[0..3] != "OggS"
        alert(_("Error"))
        return $scene = Scene_Main.new
      end
      prm["audio"] = 1
      prm["datasize"] = fl.size
      post["data"] = fl
      msgtemp = srvproc("message_send", prm, 0, post)
      f.delete_audio(true)
      waiting_end
    end
    case msgtemp[0].to_i
    when 0
      alert(p_("Messages", "Message has been sent"))
      if @scene != false and @scene != true and @scene.is_a?(Integer) == false and @scene.is_a?(Array) == false
        $scene = @scene
      else
        @text.set_text("") if @text.is_a?(EditBox)
        $scene = Scene_Messages.new(@scene)
        return
      end
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
    when -2
      alert(_("Token expired"))
      $scene = Scene_Loading.new
      return
    when -3
      alert(_("You haven't permissions to do this"))
    when -4
      alert(p_("Messages", "The recipient cannot be found."))
    end
  end

  private

  def audiolimit
    if holds_premiumpackage("audiophile")
      return 0
    else
      return 120
    end
  end

  def bitratelimit
    if holds_premiumpackage("audiophile")
      return 128
    else
      return 32
    end
  end
end

class Struct_Messages_Message
  attr_accessor :id, :receiver, :sender, :subject, :mread, :marked, :date, :attachments, :text, :attachments_names, :protected, :polls, :polls_names

  def initialize(id = 0)
    @id = id
    @receiver = Session.name
    @sender = Session.name
    @subject = ""
    @mread = 0
    @text = ""
    @attachments = []
    @date = 0
    @marked = 0
    @attachments_names = []
    @protected = 0
    @polls = []
    @polls_names = []
  end
end
