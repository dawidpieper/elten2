# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Main
  @@acselindex = nil
  @@feed_id = -1
  @@focus = 0
  @@specials = []

  def main
    if @@feed_id == -1
      @@feed_id = LocalConfig["MainFeedId"]
    end
    if Session.name == nil || Session.name == ""
      $scene = Scene_Loading.new
      return
    end
    NVDA.braille("") if NVDA.check
    if $restart == true
      $restart = false
      $scene = Scene_Loading.new
    end
    dialog_close if dialog_opened
    waiting_end if $waitingopened
    $silentstart = false
    if Thread::current != $mainthread
      t = Thread::current
      loop_update
      t.exit
    end
    if $preinitialized != true
      $preinitialized = true
      whatsnew(true)
      return
    end
    $thr1 = Thread.new { thr1 } if $thr1.alive? == false
    $thr2 = Thread.new { thr2 } if $thr2.alive? == false
    if (($nbeta > $beta) and $isbeta == 1) and $denyupdate != true
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
    acsel_load(@@focus == 0)
    feeds_load(@@focus == 1)
    #speak(p_("Main", "Press the alt key to open the menu."))
    loop do
      loop_update
      feeds_load if Session.feeds_updated?
      if @@focus == 0
        @acsel.update
      else
        @feedsel.update
      end
      if $key[0x9]
        @@focus += 1
        @@focus = 0 if @@focus > 1
        case @@focus
        when 0
          @acsel.focus
        when 1
          @feedsel.focus
        end
      end
      if @@focus == 0
        if qacindex != nil && @actions.size > 0
          if $keyr[0x10]
            if qacindex > 0 && arrow_up
              qacup
            end
            if qacindex < @actions.size - 1 and arrow_down
              qacdown
            end
          end
          if @acsel.selected?
            @actions[qacindex].call
          end
        elsif qacindex == nil && @specials.size > 0
          if @acsel.selected?
            @specials[@acsel.index][2].call
          end
        end
      end
      if @@focus == 1
        if @feeds.size > 0
          if @feedsel.selected?
            feedshow(@feeds[@feedsel.index])
            loop_update
          end
          if @feedsel.expanded?
            feed = @feeds[@feedsel.index]
            if feed.responses > 0
              $scene = Scene_FeedViewer.new(feed, nil, false)
            end
          end
        end
      end
      if escape
        quit
      end
      break if $scene != self
    end
    @@acselindex = @acsel.index if @acsel != nil
    @@feed_id = @feeds[@feedsel.index].id if @feeds.size > 0
    LocalConfig["MainFeedId"] = @@feed_id
  end

  def self.register_specialaction(id, name, &proc)
    unregister_specialaction(id)
    @@specials.push([id, name, proc])
  end
  def self.unregister_specialaction(id)
    d = @@specials.find { |s| s[0] == id }
    @@specials.delete(d) if d != nil
  end

  def qacindex
    ind = @acsel.index
    ind -= @specials.size
    return nil if ind < 0
    return ind
  end

  def qacup
    return if qacindex == nil
    times = 1
    index = qacindex - 1
    if !@acselshowhidden
      while index > 0 && @acsel.hidden?(index)
        times += 1
        index -= 1
      end
    end
    times.times { |i| QuickActions.up(qacindex - i) }
    @acsel.index -= times
    acsel_load(false)
    @acsel.say_option
  end

  def qacdown
    return if qacindex == nil
    times = 1
    index = qacindex + 1
    if !@acselshowhidden
      while index < @acsel.options.size - 1 && @acsel.hidden?(index)
        times += 1
        index += 1
      end
    end
    times.times { |i| QuickActions.down(qacindex + i) }
    @acsel.index += times
    acsel_load(false)
    @acsel.say_option
  end

  def acsel_load(fc = true)
    @specials = @@specials
    @acselshowhidden ||= false
    @@acselindex = @acsel.index if @acsel != nil
    @actions = QuickActions.get
    options = @specials.map { |s| s[1] } + @actions.map { |a| a.detail }
    if @acsel == nil
      @acsel = ListBox.new(options, p_("Main", "Quick actions"), @@acselindex)
      @acsel.add_tip(p_("Main", "Use Shift with up/down arrows to move quick actions"))
      @acsel.bind_context { |menu| accontext(menu) }
    else
      @acsel.options = options
      for i in 0...@actions.size
        @acsel.enable_item(@specials.size + i)
      end
    end
    for i in 0...@actions.size
      @acsel.disable_item(@specials.size + i) if @actions[i].show == false && !@acselshowhidden
    end
    @acsel.focus if fc == true
  end

  def accontext(menu)
    if @actions.size > 0 && qacindex != nil && !@acsel.hidden?(@acsel.index)
      menu.option(p_("Main", "Rename"), nil, "e") {
        label = input_text(p_("Main", "Action label"), 0, @actions[qacindex].label, true)

        if label != nil
          QuickActions.rename(qacindex, label)
          acsel_load
        end
      }
      menu.option(p_("Main", "Change hotkey"), nil, "k") {
        s = [p_("Main", "None")]
        k = [0]
        for i in 1..11
          s.push("F" + i.to_s)
          k.push(i)
          s.push("SHIFT+F" + i.to_s)
          k.push(-i)
          s.push("CTRL+F" + i.to_s)
          k.push(i + 12)
          s.push("CTRL+SHIFT+F" + i.to_s)
          k.push(-(i + 12))
        end
        ind = k.find_index(@actions[qacindex].key) || 0
        sel = ListBox.new(s, p_("Main", "Hotkey for action %{label}") % { "label" => @actions[qacindex].label }, ind, 0, false)
        loop {
          loop_update
          sel.update
          break if escape
          if sel.selected?
            key = k[sel.index]
            c = nil
            @actions.each { |a| c = a if a.key == key }
            if c == nil || c == @actions[qacindex] || key == 0
              QuickActions.rekey(qacindex, key)
              acsel_load
              break
            else
              alert(p_("Main", "This hotkey is already used by action %{action}") % { "action" => c.label }, false)
            end
          end
        }
        @acsel.focus
      }
      if qacindex > 0
        menu.option(p_("Main", "Move up")) {
          qacup
        }
      end
      if qacindex < @actions.size - 1
        menu.option(p_("Main", "Move down")) {
          qacdown
        }
      end
      s = p_("Main", "Hide this action")
      s = p_("Main", "Show this action") if @actions[qacindex].show == false
      menu.option(s) {
        QuickActions.reshow(qacindex, !@actions[qacindex].show)
        acsel_load
      }
      menu.option(p_("Main", "Delete"), nil, :del) {
        ac = 0
        if @actions[qacindex].key == 0 || @actions[qacindex].show == false
          ac = confirm(p_("Main", "Are you sure you want to delete this quick action?"))
        else
          ac = selector([_("Cancel"), p_("Main", "Delete"), p_("Main", "Hide this action")], p_("Main", "If you delete this action, you will also delete the keyboard shortcut assigned to it. If you want to keep the keyboard shortcut, you can hide this action. You can show or remove hidden actions at any time."), 0, 0, 1)
        end
        if ac == 1
          QuickActions.delete(qacindex)
          acsel_load(false)
          @acsel.say_option
        elsif ac == 2
          QuickActions.reshow(qacindex, false)
          acsel_load
        end
      }
    end
    s = p_("Main", "Show hidden actions")
    s = p_("Main", "Hide hidden actions") if @acselshowhidden
    menu.option(s, nil, "h") {
      @acselshowhidden = !@acselshowhidden
      acsel_load
    }
    menu.option(p_("Main", "Add"), nil, "n") {
      action_add
    }
    menu.option(p_("Main", "Restore defaults")) {
      confirm(p_("Main", "Are you sure you want to restore default Quick Actions?")) {
        File.delete(Dirs.eltendata + "\\quickactions.dat") if FileTest.exists?(Dirs.eltendata + "\\quickactions.dat")
        QuickActions.load_actions
        acsel_load
        @acsel.focus
      }
    }
  end

  def action_add
    actions = []
    actionlabels = []
    c = QuickActions.predefined_procs
    for a in c
      actions.push(a[0])
      actionlabels.push(a[1])
    end
    g = GlobalMenu.scenes
    for m in g
      actions.push(m[1])
      actionlabels.push(m[0])
    end
    ind = selector(actionlabels, p_("Main", "Select quick action to add"), 0, -1)
    if ind >= 0
      action = actions[ind]
      params = []
      if action.is_a?(Array)
        params = action[1..-1]
        action = action[0]
      end
      QuickActions.create(action, actionlabels[ind], params)
      acsel_load
    else
      @acsel.focus
    end
  end

  def feeds_load(fc = false)
    @@feed_id = @feeds[@feedsel.index].id if @feeds.is_a?(Array) && @feeds.size > 0 && @feedsel != nil
    @feeds = []
    ind = -1
    for f in Session.feeds.keys.sort.reverse
      feed = Session.feeds[f]
      @feeds.push(feed) if feed != nil && feed.message != ""
      ind = @feeds.size - 1 if ind == -1 && @@feed_id > 0 && feed.id <= @@feed_id
    end
    ind = 0 if ind == -1
    selt = @feeds.map { |f|
      str = f.user
      str += "\004LIKED\004" if f.liked
      str += ": " + f.message + " "
      str += "(" + np_("Main", "%{count} user likes it", "%{count} users like it", f.likes) % { "count" => f.likes } + ") " if f.likes > 0
      begin
        str += format_date(Time.at(f.time)) + "#{if f.responses > 0; "\004CONTAINING\004"; else; ""; end}"
      rescue Exception
      end
      str
    }
    if @feedsel == nil
      @feedsel = ListBox.new(selt, p_("Main", "Feed"), ind)
      @feedsel.bind_context { |menu| feeds_context(menu) }
      @feedsel.on(:move) {
        if @feeds.size > 0
          feed = @feeds[@feedsel.index]
          if feed != nil
            $agent.write(Marshal.dump({ "func" => "feedid", "feedid" => feed.id }))
          end
        end
      }
    else
      @feedsel.options = selt
      @feedsel.index = ind
    end
    @feedsel.focus if fc
  end

  def feeds_context(menu)
    if @feeds.size > 0
      feed = @feeds[@feedsel.index]
      menu.useroption(feed.user)
      if feed.responses > 0
        menu.option(p_("Main", "Show responses"), nil, "d") {
          $scene = Scene_FeedViewer.new(feed)
        }
      elsif feed.response > 0
        menu.option(p_("Main", "Show conversation"), nil, "d") {
          $scene = Scene_FeedViewer.new(feed, nil, false)
        }
      end
      if feed.likes > 0
        menu.option(p_("Main", "Show likes"), nil, "K") {
          lk = srvproc("feeds", { "ac" => "likes", "message" => feed.id })
          likes = []
          likes = lk[2..-1].map { |l| l.delete("\r\n") } if lk[0].to_i == 0
          users = likes
          dialog_open
          lst = ListBox.new(users, p_("Main", "Users who like this post"), 0, 0, false)
          loop do
            loop_update
            lst.update
            break if escape
            if (alt or enter) and users.size > 0
              usermenu(users[lst.index])
            end
          end
          dialog_close
        }
      end
      menu.option(p_("Main", "Reply"), nil, "r") {
        users = [feed.user]
        users += feed.message.scan(/\@([a-zA-Z0-9\.\-\_]+)/).map { |r| r[0] }
        todel = []
        for u in users
          todel.push(u) if u.downcase == Session.name.downcase
        end
        for i in 1...users.size
          todel.push(users[i]) if users[0...i].map { |u| u.downcase }.include?(users[i].downcase)
        end
        todel.each { |u| users.delete(u) }
        response = feed.id
        response = feed.response if feed.response > 0
        feed_new(users.uniq, response)
      }
      s = p_("Main", "Like this message")
      s = p_("Main", "Dislike this message") if feed.liked
      menu.option(s, nil, "k") {
        if srvproc("feeds", { "ac" => "liking", "message" => feed.id, "like" => (feed.liked) ? (0) : (1) })[0].to_i < 0
          alert(_("Error"))
        else
          st = (feed.liked) ? (p_("Main", "Message disliked")) : (p_("Main", "Message liked"))
          feed.liked = !feed.liked
          alert(st)
        end
      }
      if feed.user == Session.name
        menu.option(_("Delete"), nil, :del) {
          delete_feed(feed.id)
          play("editbox_delete")
        }
      end
    end
    menu.option(p_("Main", "Publish to a feed"), nil, "n") { feed_new }
  end

  def feed_new(users = [], response = 0)
    text = users.map { |u| "@" + u }.join(" ")
    text << " " if text != ""
    inp = input_text(p_("Main", "Message"), 0, text, true, [], [], 300, true)
    feed(inp, response) if inp != nil
  end

  def feed_id=(f)
    for i in 0...@feeds.size
      @feedsel.index = i if @feeds[i].id >= f
    end
  end

  def self.feed_id=(f)
    @@feed_id = f
    $scene.feed_id = f if $scene.is_a?(Scene_Main)
  end
end
