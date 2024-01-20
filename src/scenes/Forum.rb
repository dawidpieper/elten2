# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2024 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Forum
  @@lastCache = nil
  @@lastCacheIdent = nil
  @@lastCacheTime = nil

  def initialize(pre = nil, preparam = nil, cat = 0, query = "", tc = nil, tag = nil)
    @pre = pre
    @preparam = preparam
    @lastlist = @cat = cat
    @query = query
    @grpindex ||= []
    @close = false
    @tc = tc
    @tag = tag
  end

  def main
    if Session.name == "guest"
      @noteditable = true
    else
      @noteditable = false
    end
    getcache
    return if $scene != self
    if @pre == nil
      if @preparam.is_a?(Integer)
        return forumsmain(@preparam)
      elsif @preparam.is_a?(String)
        return threadsmain(@preparam)
      else
        groupsmain(@cat)
      end
    else
      if @preparam.is_a?(String) or @preparam == nil or @preparam == -5
        foll = false
        foll = true if @preparam == -5
        @frmindex = 0
        forum = nil
        for thread in @threads
          forum = thread.forum.name if thread.id == @pre
        end
        group = nil
        for tforum in @forums
          group = tforum.group.id if tforum.name == forum
        end
        group = -5 if @preparam == -5
        group = 0 if group == nil
        @grpsetindex = group if group > 0
        @grpindex[0] = 1 if @preparam == -5
        i = 0
        for tforum in @forums
          if (tforum.group.id == group) or (tforum.followed and @preparam == -5)
            @frmindex = i if tforum.name == forum
            i += 1
          end
        end
        @group = group
        threadsmain(forum)
      else
        if @preparam == -3
          @grpindex[0] = @groups.size + 2
          @grpsetindex = @query.id if @query.is_a?(Struct_Forum_Group)
          usequery
        end
        threadsmain(@preparam)
      end
    end
  end

  def makesort(type, cat, sort)
    LocalConfig["ForumSort"] = sort
    if type == 0
      command = @grpsel.options[@grpsel.index]
      @grpindex[type] = @grpsel.index
      groupsload(cat)
      @grpsel.index = @grpsel.options.find_index(command) || 0
      @grpsel.focus
    else
      command = @frmsel.options[@frmsel.index]
      forumsload(cat)
      @frmsel.index = @frmsel.options.find_index(command) || 0
      @frmsel.focus if type == 1
      @grpsetindex = @group
    end
  end

  def sortermenu(type, cat, menu)
    menu.submenu(p_("Forum", "Sort")) { |m|
      m.option(p_("Forum", "Default")) { makesort(type, cat, 0) } if LocalConfig["ForumSort"] != 0
      m.option(p_("Forum", "By name (ascending)")) { makesort(type, cat, 1) } if LocalConfig["ForumSort"] != 1
      m.option(p_("Forum", "By name (descending)")) { makesort(type, cat, -1) } if LocalConfig["ForumSort"] != -1
      m.option(p_("Forum", "By unread posts (ascending)")) { makesort(type, cat, 2) } if LocalConfig["ForumSort"] != 2
      m.option(p_("Forum", "By unread posts (descending)")) { makesort(type, cat, -2) } if LocalConfig["ForumSort"] != -2
    }
  end

  def groupsmain(type = -1)
    type = (@lastlist || 0) if type == -1
    ll = @lastlist
    @lastlist = type
    index = 0
    @cat = type
    groupsload(type, ll)
    loop do
      loop_update
      @grpsel.update
      LocalConfig["ForumColumnGroup"] = @grpsel.column if LocalConfig["ForumColumnGroup"] != @grpsel.column
      return $scene = Scene_Main.new if escape and type == 0
      return groupsmain(0) if (escape or (arrow_left and !$keyr[0x10])) and type != 0
      break if $scene != self
      if (enter or arrow_right and !$keyr[0x10])
        groupopen(@grpsel.index, type, false)
        break
      end
      break if $scene != self
    end
  end

  def groupsload(type, ll = nil)
    if ll == nil
      ll = @lastll
    else
      @lastll = ll
    end
    knownlanguages = (Session.languages || "").split(",").map { |lg| lg.upcase }
    pinned = []
    pinned = LocalConfig["ForumGroupsPinned", []] if holds_premiumpackage("courier")
    case type
    when 0
      @grpindex.delete_at(-1) while @grpindex.size > 1
      return $scene = Scene_Main.new if @groups == nil || @forums == nil || @threads == nil
      @sgroups = []
      spgroups = []
      sgloc = false
      klangs = []
      knownlanguages = Session.languages.split(",").map { |lg| lg.upcase }
      for g in @groups
        if g.role == 1 || g.role == 2
          @sgroups.push(g)
        end
        if !klangs.include?(g.lang[0..1].upcase) and knownlanguages.include?(g.lang[0..1].upcase) and g.recommended
          spgroups.push(g) if !@sgroups.include?(g)
          sgloc = true
          klangs.push(g.lang[0..1].upcase)
        end
      end
      @sgroups += spgroups
      sorts = (0..@groups.map { |g| g.id }.max || 0).to_a.map { 0 }
      for t in @threads
        g = t.forum.group.id
        sorts[g] = t.lastupdate if sorts[g] < t.lastupdate
      end

      @sgroups.sort! { |a, b|
        if LocalConfig["ForumSort"] == 0
          x, y = sorts[a.id], sorts[b.id]
          x = 1.0 / 0.0 if pinned.include?(a.id)
          y = 1.0 / 0.0 if pinned.include?(b.id)
          y <=> x
        else
          groupsorter(a, b)
        end
      }
      @grpheadindex = 3
      grpselt = []
      for i in 0...@sgroups.size
        group = @sgroups[i]
        grpselt.push([group.name, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
        @grpindex[0] = i + @grpheadindex if group.id == @grpsetindex
      end
      forfol = @forums.find_all { |forum| forum.followed }.map { |forum| forum.name }
      flt = flr = flp = 0
      ft = fp = fr = 0
      fmt = fmp = fmr = 0
      for thread in @threads
        if thread.followed
          ft += 1
          fp += thread.posts
          fr += thread.readposts
        end
        if thread.marked
          fmt += 1
          fmp += thread.posts
          fmr += thread.readposts
        end
        if forfol.include?(thread.forum.id)
          flt += 1
          flp += thread.posts
          flr += thread.readposts
        end
      end
      groupsrecommendedcnt = 0
      groupsopencnt = 0
      groupsinvitedcnt = 0
      groupsallcnt = 0
      groupsmoderatedcnt = 0
      @groups.each { |g|
        groupsrecommendedcnt += 1 if g.recommended
        groupsopencnt += 1 if g.open && g.public && !g.recommended && g.posts > 0
        groupsinvitedcnt += 1 if g.role == 5
        groupsallcnt += 1 if g.forums > 0
        groupsmoderatedcnt += 1 if g.role == 2
      }
      ofs = 0
      mygroups = @groups.find_all { |g| g.role == 2 }.map { |g| g.id }
      @threads.each { |t| ofs += 1 if t.offered != 0 && mygroups.include?(t.offered) }
      grpselt = [[np_("Forum", "Followed thread", "Followed threads", ft), nil, ft.to_s, fp.to_s, (fp - fr).to_s], [np_("Forum", "Followed forum", "Followed forums", forfol.size), forfol.size.to_s, flt.to_s, flp.to_s, (flp - flr).to_s], [np_("Forum", "Marked thread", "Marked threads", fmt), nil, fmt.to_s, fmp.to_s, (fmp - fmr).to_s]] + grpselt + [[p_("Forum", "Recently active groups")], [p_("Forum", "Recommended groups (%{count})") % { "count" => groupsrecommendedcnt.to_s }], [p_("Forum", "Open groups (%{count})") % { "count" => groupsopencnt.to_s }], [np_("Forum", "Awaiting group invitation", "Awaiting group invitations (%{count})", groupsinvitedcnt) % { "count" => groupsinvitedcnt.to_s }], [np_("Forum", "Moderated group", "Moderated groups (%{count})", groupsmoderatedcnt) % { "count" => groupsmoderatedcnt.to_s }], [p_("Forum", "All groups (%{count})") % { "count" => groupsallcnt.to_s }], [p_("Forum", "Recently created groups")], [p_("Forum", "Groups popular with my friends")], [p_("Forum", "Threads popular with my friends")], [p_("Forum", "Received mentions")], [np_("Forum", "Thread offered to my group", "Threads offered to my groups (%{count})", ofs) % { "count" => ofs.to_s }], [p_("Forum", "My threads")], [p_("Forum", "Search")]]
      grpselt[0] = [nil] if ft == 0
      grpselt[1] = [nil] if forfol.size == 0
      grpselt[2] = [nil] if fmt == 0
      grpselt[@grpheadindex + @sgroups.size + 3] = [nil] if groupsinvitedcnt == 0
      grpselt[@grpheadindex + @sgroups.size + 4] = [nil] if groupsmoderatedcnt == 0
      grpselt[@grpheadindex + @sgroups.size + 9] = [nil] if !holds_premiumpackage("courier")
      grpselt[@grpheadindex + @sgroups.size + 10] = [nil] if ofs == 0
      grpselh = [nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
      @grpindex[0] = @grpheadindex + @sgroups.size + ll - 1 if ll > 0
    when 1 #Recently active
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
        next if g.hidden
        if (g.public || g.open) && g.posts > 0
          @sgroups.push(g)
        end
      end
      sorts = (0..@groups.map { |g| g.id }.max || 0).to_a.map { 0 }
      for t in @threads
        g = t.forum.group.id
        sorts[g] = t.lastupdate if sorts[g] < t.lastupdate
      end
      @sgroups.sort! { |a, b|
        x, y = sorts[a.id], sorts[b.id]
        y <=> x
      }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 2 #Recommended
      @sgroups = []
      spgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
        if g.recommended
          if Configuration.language[0..1].downcase == g.lang.downcase
            @sgroups.push(g)
          else
            spgroups.push(g)
          end
        end
      end
      @sgroups += spgroups
      @sgroups.sort { |a, b| groupsorter(a, b) } if LocalConfig["ForumSort"] != 0
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name + ": " + group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 3 #Open
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
        next if g.hidden
        if g.open && g.public && !g.recommended && g.posts > 0
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b|
        if @sort == 0
          (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
        else
          groupsorter(a, b)
        end
      }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 4 #Invited
      @sgroups = []
      for g in @groups
        if g.role == 5
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b|
        if LocalConfig["ForumSort"] == 0
          (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
        else
          groupsorter(a, b)
        end
      }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 5 #Moderated
      @sgroups = []
      for g in @groups
        if g.role == 2
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b|
        if LocalConfig["ForumSort"] == 0
          (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
        else
          groupsorter(a, b)
        end
      }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 6 #All
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
        if g.forums > 0
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b|
        if LocalConfig["ForumSort"] == 0
          (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
        else
          groupsorter(a, b)
        end
      }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 7 #Recently created
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
        next if g.hidden
        if g.forums > 0
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b| b.created <=> a.created }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 8 #Popular
      grp = srvproc("forum_popular", { "type" => "groups" })
      @sgroups = []
      if grp[0].to_i == 0
        for l in grp[1..-1]
          g = nil
          @groups.each { |r| g = r if r.id == l.to_i }
          if g != nil
            next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
            next if g.hidden
            @sgroups.push(g) if g.forums > 0
          end
        end
      end
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    end
    if @grpindex[type] == nil and @grpsetindex != nil
      for i in 0...@sgroups.size
        @grpindex[type] = i + @grpheadindex if @sgroups[i].id == @grpsetindex
      end
    end
    @grpsetindex = nil
    @grpsel = TableBox.new(grpselh, grpselt, @grpindex[type], p_("Forum", "Forum"))
    @grpsel.trigger(:move)
    @grpsel.column = LocalConfig["ForumColumnGroup"] if LocalConfig["ForumColumnGroup"] != nil
    @grpsel.bind_context(p_("Forum", "Forum")) { |menu| context_groups(menu, type) }
    @grpsel.focus
    return [@sgroups, @grpheadindex]
  end

  def groupsorter(a, b)
    result = 0
    case LocalConfig["ForumSort"].abs
    when 1
      result = polsorter(a.name, b.name)
    when 2
      result = (a.posts - a.readposts) <=> (b.posts - b.readposts)
    else
      result = 1
    end
    result *= -1 if LocalConfig["ForumSort"] < 0
    return result
  end

  def groupopen(index, type, allThreads = false)
    @grpindex[type] = index
    @group = nil
    if index == @grpheadindex - 3
      return threadsmain(-1)
    elsif index == @grpheadindex - 2
      return forumsmain(-5)
    elsif index == @grpheadindex - 1
      return threadsmain(-10)
    elsif index == @grpheadindex + @sgroups.size
      return groupsmain(1)
    elsif index == @grpheadindex + @sgroups.size + 1
      return groupsmain(2)
    elsif index == @grpheadindex + @sgroups.size + 2
      return groupsmain(3)
    elsif index == @grpheadindex + @sgroups.size + 3
      return groupsmain(4)
    elsif index == @grpheadindex + @sgroups.size + 4
      return groupsmain(5)
    elsif index == @grpheadindex + @sgroups.size + 5
      return groupsmain(6)
    elsif index == @grpheadindex + @sgroups.size + 6
      return groupsmain(7)
    elsif index == @grpheadindex + @sgroups.size + 7
      return groupsmain(8)
    elsif index == @grpheadindex + @sgroups.size + 8
      return threadsmain(-8)
    elsif index == @grpheadindex + @sgroups.size + 9
      return threadsmain(-11)
    elsif index == @grpheadindex + @sgroups.size + 10
      return threadsmain(-12)
    elsif index == @grpheadindex + @sgroups.size + 11
      return threadsmain(-9)
    elsif index == @grpheadindex + @sgroups.size + 12
      @query = searcher_getquery
      if @query != nil
        usequery
        return threadsmain(-3)
      end
    else
      g = @sgroups[index - @grpheadindex]
      groupmotddlg(g, false) if g.hasnewmotd
      if g.role == 1 or g.role == 2 or g.public
        if allThreads
          @query = g
          usequery
          threadsmain(-3)
        else
          forumsmain(g.id) if g.role == 1 or g.role == 2 or g.public
        end
        @grpsel.rows[@grpsel.index][-1] = (g.posts - g.readposts).to_s
      end
    end
  end

  def context_groups(menu, type)
    menu.option(p_("Forum", "Open")) {
      groupopen(@grpsel.index, type)
    }
    if @grpsel.index >= @grpheadindex and @grpsel.index < @grpheadindex + @sgroups.size
      menu.option(p_("Forum", "Show all threads"), nil, :shift_enter) {
        groupopen(@grpsel.index, type, true)
      }
      if holds_premiumpackage("courier")
        pinned = LocalConfig["ForumGroupsPinned", []]
        g = @sgroups[@grpsel.index - @grpheadindex]
        s = p_("Forum", "Pin this group")
        s = p_("Forum", "Unpin this group") if pinned.include?(g.id)
        menu.option(s, nil, "p") {
          if pinned.include?(g.id)
            pinned.delete(g.id)
          else
            pinned.push(g.id)
          end
          LocalConfig["ForumGroupsPinned"] = pinned
          if pinned.include?(g.id)
            alert(p_("Forum", "Group has been pinned"))
          else
            alert(p_("Forum", "Group has been unpinned"))
          end
        }
      end
      menu.option(p_("Forum", "Search"), nil, "f") {
        @query = searcher_getquery(@sgroups[@grpsel.index - @grpheadindex])
        if @query != nil
          usequery
          threadsmain(-3)
        else
          @grpsel.focus
        end
      }
      if @sgroups[@grpsel.index - @grpheadindex].blog != nil && @sgroups[@grpsel.index - @grpheadindex].blog != ""
        menu.option(p_("Forum", "Group blog"), nil, "b") {
          insert_scene(Scene_Blog_Main.new(@sgroups[@grpsel.index - @grpheadindex].blog, 0, Scene_Main.new))
        }
      end
      menu.option(p_("Forum", "Group summary"), nil, "d") {
        g = @sgroups[@grpsel.index - @grpheadindex]
        s = g.name + "\r\n\n"
        s += p_("Forum", "Language") + ": " + g.lang + "\n"
        type = p_("Forum", "Hidden")
        type = p_("Forum", "Public") if g.public
        jointype = ""
        if !g.public
          if !g.open
            jointype = p_("Forum", "closed (only invited users can join)")
          else
            jointype = p_("Forum", "Moderated (everyone can request)")
          end
        else
          if !g.open
            jointype = p_("Forum", "Moderated (everyone can request)")
          else
            jointype = p_("Forum", "open (everyone can join)")
          end
        end
        if g.recommended
          type = p_("Forum", "Recommended")
        end
        s += p_("Forum", "Group type") + ": " + type + "\n"
        s += p_("Forum", "Group join type") + ": " + jointype + "\n"
        s += p_("Forum", "Members") + ": " + g.acmembers.to_s + "\n"
        s += p_("Forum", "Founder") + ": " + g.founder + "\n"
        if g.created > 0
          t = Time.at(g.created)
          s += p_("Forum", "Founded at") + ": " + format_date(t, true) + "\n"
        end
        acs = srvproc("forum_groups", { "ac" => "mostactive", "groupid" => g.id.to_s })
        s += p_("Forum", "The most active members") + ": " + acs[1..-1].map { |x| x.delete("\r\n") }.join(", ") + "\n" if acs.size > 1
        s += "\r\n\n"
        szs = srvproc("forum_groups", { "ac" => "size", "groupid" => g.id.to_s })
        if szs.size >= 4
          s += p_("Forum", "Group size") + "\n"
          for i in 1..4
            if i < 4
              a = szs[i].to_i
            else
              a = szs[1].to_i + szs[2].to_i + szs[3].to_i
            end
            if a > 0
              case i
              when 1
                s += p_("Forum", "Audio posts")
              when 2
                s += p_("Forum", "Attachments")
              when 3
                s += p_("Forum", "Text")
              when 4
                s += p_("Forum", "Overall size")
              end
              s += ": "
              if a >= 1048576
                s += ((a / 1048576.0 * 10.0).round / 10.0).to_s + "MB"
              elsif a < 1048576 and a >= 1024
                s += ((a / 1024.0 * 10.0).round / 10.0).to_s + "kB"
              else
                s += a.to_s + "B"
              end
              s += "\n"
            end
          end
        end
        s += "\n\n" + g.description if g.description != nil && g.description != ""
        input_text(p_("Forum", "Group summary"), EditBox::Flags::ReadOnly, s, true)
        loop_update
      }
      if @sgroups[@grpsel.index - @grpheadindex].hasregulations or @sgroups[@grpsel.index - @grpheadindex].role == 2
        s = p_("Forum", "Group regulations")
        s = p_("Forum", "Edit group regulations") if @sgroups[@grpsel.index - @grpheadindex].role == 2
        menu.option(s) {
          groupregulationsdlg(@sgroups[@grpsel.index - @grpheadindex])
        }
      end
      if (((@sgroups[@grpsel.index - @grpheadindex].role == 1 || (@sgroups[@grpsel.index - @grpheadindex].public && @sgroups[@grpsel.index - @grpheadindex].open)) && @sgroups[@grpsel.index - @grpheadindex].showpostreports > 0) || @sgroups[@grpsel.index - @grpheadindex].role == 2) && @sgroups[@grpsel.index - @grpheadindex].allowpostreporting
        menu.option(p_("Forum", "Show reported posts")) {
          groupreports(@sgroups[@grpsel.index - @grpheadindex])
        }
      end
      if @sgroups[@grpsel.index - @grpheadindex].hasmotd or @sgroups[@grpsel.index - @grpheadindex].role == 2
        s = p_("Forum", "Message of the day")
        s = p_("Forum", "Edit message of the day") if @sgroups[@grpsel.index - @grpheadindex].role == 2
        menu.option(s, nil, "g") {
          groupmotddlg(@sgroups[@grpsel.index - @grpheadindex])
        }
      end
      menu.option(p_("Forum", "Group members"), nil, "m") {
        groupmembers(@sgroups[@grpsel.index - @grpheadindex])
      }
      s = ""
      s = p_("Forum", "Join") if @sgroups[@grpsel.index - @grpheadindex].role == 0 and @sgroups[@grpsel.index - @grpheadindex].open and @sgroups[@grpsel.index - @grpheadindex].public
      s = p_("Forum", "Accept invitation") if @sgroups[@grpsel.index - @grpheadindex].role == 5
      s = p_("Forum", "Ask to be enrolled in this group") if @sgroups[@grpsel.index - @grpheadindex].role == 0 && ((@sgroups[@grpsel.index - @grpheadindex].public && !@sgroups[@grpsel.index - @grpheadindex].open) || (@sgroups[@grpsel.index - @grpheadindex].open && !@sgroups[@grpsel.index - @grpheadindex].public))
      if s != ""
        menu.option(s, nil, "j") {
          if canjoin(@sgroups[@grpsel.index - @grpheadindex])
            if @sgroups[@grpsel.index - @grpheadindex].role == 0 && ((@sgroups[@grpsel.index - @grpheadindex].public && !@sgroups[@grpsel.index - @grpheadindex].open) || (@sgroups[@grpsel.index - @grpheadindex].open && !@sgroups[@grpsel.index - @grpheadindex].public))
              s = p_("Forum", "Do you wish to ask to be enrolled in %{groupname}")
            else
              s = p_("Forum", "Are you sure you want to join %{groupname}?")
            end
            confirm(s % { "groupname" => @sgroups[@grpsel.index - @grpheadindex].name }) {
              g = srvproc("forum_groups", { "ac" => "join", "groupid" => @sgroups[@grpsel.index - @grpheadindex].id.to_s })
              if g[0].to_i == 0
                if @sgroups[@grpsel.index - @grpheadindex].role == 0 && ((@sgroups[@grpsel.index - @grpheadindex].public && !@sgroups[@grpsel.index - @grpheadindex].open) || (@sgroups[@grpsel.index - @grpheadindex].open && !@sgroups[@grpsel.index - @grpheadindex].public))
                  alert(p_("Forum", "Request sent"))
                  @sgroups[@grpsel.index - @grpheadindex].role = 4
                else
                  alert(p_("Forum", "You've just joined the group"))
                  @sgroups[@grpsel.index - @grpheadindex].role = 1
                end
              else
                alert(_("Error"))
              end
            }
          end
          @grpsel.focus
        }
      end
      if @sgroups[@grpsel.index - @grpheadindex].role == 1 or @sgroups[@grpsel.index - @grpheadindex].role == 2 or @sgroups[@grpsel.index - @grpheadindex].public or @sgroups[@grpsel.index - @grpheadindex].open
        menu.option(p_("Forum", "Add this group to quick actions"), nil, "q") {
          QuickActions.create(Scene_Forum, @sgroups[@grpsel.index - @grpheadindex].name + " (#{p_("Forum", "Group")})", [nil, @sgroups[@grpsel.index - @grpheadindex].id])
          alert(p_("Forum", "Group added to quick actions"), false)
        }
      end
      s = ""
      s = p_("Forum", "Leave") if (@sgroups[@grpsel.index - @grpheadindex].role == 1 or @sgroups[@grpsel.index - @grpheadindex].role == 2 or @sgroups[@grpsel.index - @grpheadindex].role == 4) and @sgroups[@grpsel.index - @grpheadindex].founder != Session.name
      s = p_("Forum", "Refuse invitation") if @sgroups[@grpsel.index - @grpheadindex].role == 5
      if s != ""
        menu.option(s, nil, "l") {
          confirm(p_("Forum", "Are you sure you want to leave %{groupname}?") % { "groupname" => @sgroups[@grpsel.index - @grpheadindex].name }) {
            g = srvproc("forum_groups", { "ac" => "leave", "groupid" => @sgroups[@grpsel.index - @grpheadindex].id.to_s })
            if g[0].to_i == 0
              alert(p_("Forum", "You've just left the group"))
              @sgroups[@grpsel.index - @grpheadindex].role = 0
            else
              alert(_("Error"))
            end
          }
          @grpsel.focus
        }
      end
      menu.option(p_("Forum", "Mark this group as read"), nil, "w") {
        if @sgroups[@grpsel.index - @grpheadindex].posts - @sgroups[@grpsel.index - @grpheadindex].readposts < 100 or confirm(p_("Forum", "All posts in this group will be marked as read. Are you sure you want to continue?")) == 1
          if srvproc("forum_markasread", { "groupid" => @sgroups[@grpsel.index - @grpheadindex].id })[0].to_i == 0
            for t in @threads
              t.readposts = t.posts if t.forum.group.id == @sgroups[@grpsel.index - @grpheadindex].id
            end
            for f in @forums
              f.readposts = f.posts if f.group.id == @sgroups[@grpsel.index - @grpheadindex].id
            end
            @sgroups[@grpsel.index - @grpheadindex].readposts = @sgroups[@grpsel.index - @grpheadindex].posts
            @grpsel.rows[@grpsel.index][-1] = "0"
            @grpsel.reload
            alert(p_("Forum", "The group has been marked as read."))
          else
            alert(_("Error"))
          end
        end
      }
      if @sgroups[@grpsel.index - @grpheadindex].founder == Session.name
        menu.option(p_("Forum", "Edit group"), nil, "e") {
          g = @sgroups[@grpsel.index - @grpheadindex]
          $scene = Scene_Forum_GroupSettings.new(g, $scene)
        }
        menu.option(p_("Forum", "Administrative log")) {
          g = @sgroups[@grpsel.index - @grpheadindex]
          grouplog(g)
          @grpsel.focus
        }
      end
      if @sgroups[@grpsel.index - @grpheadindex].forums == 0 and @sgroups[@grpsel.index - @grpheadindex].founder == Session.name
        menu.option(p_("Forum", "Delete group")) {
          confirm(p_("Forum", "Are you sure you want to delete %{groupname}?") % { "groupname" => @sgroups[@grpsel.index - @grpheadindex].name }) {
            fd = srvproc("forum_groups", { "ac" => "delete", "groupid" => @sgroups[@grpsel.index - @grpheadindex].id.to_s })
            if fd[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Forum", "Group has been deleted"))
            end
            getcache
            groupsmain(type)
          }
        }
      end
    end
    if Session.languages != nil && Session.languages.size > 0
      s = p_("Forum", "Show groups in unknown languages")
      s = p_("Forum", "Hide groups in unknown languages") if LocalConfig["ForumShowUnknownLanguages"] == 1
      menu.option(s) {
        l = 1
        l = 0 if LocalConfig["ForumShowUnknownLanguages"] == 1
        LocalConfig["ForumShowUnknownLanguages"] = l
        getcache
        groupsmain
      }
    end
    sortermenu(0, type, menu)
    if Session.name != "guest"
      menu.option(p_("Forum", "New group"), nil, "n") {
        newgroup
      }
    end
    menu.option(_("Refresh"), nil, "r") {
      @grpindex[type] = @grpsel.index
      getcache
      groupsmain
    }
  end

  def groupmotd(group)
    g = srvproc("forum_groups", { "ac" => "motd", "groupid" => group.id })
    if g[0].to_i == 0
      group.hasnewmotd = false
      return g[1..-1].join
    else
      return ""
    end
  end

  def groupmotddlg(group, editable = true)
    motd = groupmotd(group)
    fields = [
      EditBox.new((p_("Forum", "Message of the day of group %{groupname}") % { "groupname" => group.name }), ((group.role == 2) ? (EditBox::Flags::MultiLine) : (EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly)), motd),
      Button.new(_("Save")),
      Button.new(_("Cancel"))
    ]
    fields[1] = nil if group.role != 2 or editable == false
    form = Form.new(fields)
    loop do
      loop_update
      form.update
      break if escape or form.fields[2].pressed?
      if form.fields[1] != nil && form.fields[1].pressed?
        buf = buffer(form.fields[0].text)
        if srvproc("forum_groups", { "ac" => "editmotd", "groupid" => group.id, "buf" => buf })[0].to_i == 0
          group.hasnewmotd = true
          alert(p_("Forum", "Message of the day updated"))
          break
        else
          alert(_("Error"))
        end
      end
    end
  end

  def groupregulationsdlg(group)
    regs = groupregulations(group)
    fields = [
      EditBox.new((p_("Forum", "Regulations of group %{groupname}") % { "groupname" => group.name }), ((group.role == 2) ? (EditBox::Flags::MultiLine) : (EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly)), regs),
      Button.new(_("Save")),
      Button.new(_("Cancel"))
    ]
    fields[1] = nil if group.role != 2
    form = Form.new(fields)
    loop do
      loop_update
      form.update
      break if escape or form.fields[2].pressed?
      if form.fields[1] != nil && form.fields[1].pressed?
        buf = buffer(form.fields[0].text)
        if srvproc("forum_groups", { "ac" => "editregulations", "groupid" => group.id, "buf" => buf })[0].to_i == 0
          alert(p_("Forum", "Regulations updated"))
          break
        else
          alert(_("Error"))
        end
      end
    end
  end

  def groupreports(group)
    reports = []
    selh = [nil, p_("Forum", "Reported by"), p_("Forum", "Thread"), p_("Forum", "Reported at"), p_("Forum", "Status"), p_("Forum", "Comment")]
    sel = TableBox.new(selh, [], 0, p_("Forum", "Reported posts"))
    rfr = Proc.new {
      fr = srvproc("forum_reports", { "groupid" => group.id, "ac" => "list" })
      if fr[0].to_i < 0
        alert(_("Error"))
      else
        reports = []
        report = nil
        c = 0
        for l in fr[2..-1]
          case c
          when 0
            report = Struct_Forum_Report.new
            report.id = l.to_i
          when 1
            report.user = l.delete("\r\n")
          when 2
            report.thread = l.to_i
          when 3
            report.post = l.to_i
          when 4
            if l.delete("\r\n") != "\004END\004"
              report.postvalue += l
              c -= 1
            end
          when 5
            if l.delete("\r\n") != "\004END\004"
              report.content += l
              c -= 1
            end
          when 6
            report.creationtime = Time.at(l.to_i) if l.to_i > 0
          when 7
            report.solved = (l.to_i == 1)
          when 8
            report.status = l.to_i
          when 9
            if l.delete("\r\n") != "\004END\004"
              report.reason += l
              c -= 1
            end
          when 10
            report.solutiontime = Time.at(l.to_i) if l.to_i > 0
          end
          c += 1
          if c > 10
            c = 0
            reports.push(report)
          end
        end
        selt = reports.map { |r|
          st = p_("Forum", "Solved")
          st = p_("Forum", "Unsolved") if !r.solved
          if r.solved
            case r.status
            when 1
              st = p_("Forum", "Rejected")
            when 2
              st = p_("Forum", "Accepted")
            end
            st += " \004CLOSED\004"
          end
          thrname = nil
          thr = @threads.find { |t| t.id == r.thread }
          thrname = thr.name if thr != nil
          [r.content, r.user, thrname, format_date(r.creationtime), st, (r.reason.delete("\r\n") != "") ? (r.reason) : (nil)]
        }
        sel.rows = selt
        sel.reload
      end
    }
    rfr.call
    sel.bind_context { |menu|
      report = reports[sel.index]
      if report != nil
        menu.useroption(report.user)
        menu.option(p_("Forum", "Show reported post")) {
          input_text(p_("Forum", "Post"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, report.postvalue, true)
          loop_update
        }
        menu.option(p_("Forum", "Go to reported post"), nil, "o") {
          thread = @threads.find { |t| t.id == report.thread }
          if thread == nil
            alert(p_("Forum", "The searched thread has been already deleted."))
          else
            insert_scene(Scene_Forum_Thread.new(thread, -13, 0, report.post, nil, Scene_Main.new))
            loop_update
          end
        }
        if group.role == 2 && !report.solved
          menu.option(p_("Forum", "Resolve")) {
            groupreportresolver(group, report)
            rfr.call
            sel.update
          }
        end
      end
      menu.option(p_("Forum", "Refresh"), nil, "r") {
        rfr.call
        sel.focus
      }
    }
    sel.focus
    dialog_open
    loop {
      loop_update
      sel.update
      if enter
        report = reports[sel.index]
        input_text(p_("Forum", "Post"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, report.postvalue, true) if report != nil
        loop_update
      end
      break if escape
    }
    dialog_close
  end

  def groupreportresolver(group, report)
    return if group == nil || report == nil || group.role != 2
    form = Form.new([
      lst_status = ListBox.new([p_("Forum", "Rejected"), p_("Forum", "Accepted")], p_("Forum", "Status")),
      edt_reason = EditBox.new(p_("Forum", "Reason"), EditBox::Flags::MultiLine, "", true),
      btn_resolve = Button.new(p_("Forum", "Resolve")),
      btn_cancel = Button.new(_("Cancel"))
    ])
    form.cancel_button = btn_cancel
    form.accept_button = btn_resolve
    btn_cancel.on(:press) { form.resume }
    btn_resolve.on(:press) {
      fr = srvproc("forum_reports", { "ac" => "resolve", "report" => report.id, "status" => lst_status.index + 1, "buf_reason" => buffer(edt_reason.text) })
      if fr[0].to_i == 0
        confirm(p_("Forum", "Do you want to send information about status of this report to its author?")) {
          subj = report.content[0...400]
          thread = @threads.find { |t| t.id == report.thread }
          if thread != nil
            subj += " (#{thread.name})"
          end
          subj + " "
          subj += "Rejected" if lst_status.index == 0
          subj += "Accepted" if lst_status.index == 1
          insert_scene(Scene_Messages_New.new(report.user, subj, edt_reason.text, Scene_Main.new))
        }
        alert(p_("Forum", "Report resolved"))
        form.resume
      else
        alert(_("Error"))
      end
    }
    form.wait
  end

  def grouplog(group)
    sel = TableBox.new([nil, p_("Forum", "Action"), p_("Forum", "Group"), p_("Forum", "Forum"), p_("Forum", "Thread"), p_("Forum", "New group"), p_("Forum", "New forum"), p_("Forum", "New thread"), p_("Forum", "Old status"), p_("Forum", "New status"), p_("Forum", "Time")], [], 0, p_("Forum", "Log"))
    log = []
    rfr = Proc.new {
      f = srvproc("forum_log", { "ac" => "get", "groupid" => group.id })
      if f[0].to_i == 0
        log.clear
        for i in 0...f[1].to_i
          b = 2 + i * 14
          e = Struct_Forum_LogEntry.new
          e.id = f[b].to_i
          e.user = f[b + 1].delete("\r\n")
          e.action = f[b + 2].delete("\r\n")
          e.time = f[b + 3].to_i
          e.group1 = f[b + 4].to_i
          e.forum1 = f[b + 5].delete("\r\n")
          e.thread1 = f[b + 6].to_i
          e.post1 = f[b + 7].to_i
          e.group2 = f[b + 8].to_i
          e.forum2 = f[b + 9].delete("\r\n")
          e.thread2 = f[b + 10].to_i
          e.post2 = f[b + 11].to_i
          e.oldcontent = f[b + 12].delete("\r\n")
          e.newcontent = f[b + 13].delete("\r\n")
          log.push(e)
        end
        selt = log.map { |e|
          user = e.user
          action = e.action
          case action
          when "forum_threaddelete"
            action = p_("Forum", "Thread deletion")
          when "forum_postdelete"
            action = p_("Forum", "Post deletion")
          when "forum_postedit"
            action = p_("Forum", "Post edit")
          when "forum_threadmove"
            action = p_("Forum", "Thread move")
          when "forum_postmove"
            action = p_("Forum", "Post move")
          when "forum_threadrename"
            action = p_("Forum", "Thread rename")
          when "forum_threadoffer"
            action = p_("Forum", "Thread offer")
          end
          group1 = nil
          forum1 = nil
          thread1 = nil
          group2 = nil
          forum2 = nil
          thread2 = nil
          oldcontent = nil
          newcontent = nil
          if (e.group1 != group.id || e.group2 != group.id)
            g1 = @groups.find { |g| g.id == e.group1 }
            g2 = @groups.find { |g| g.id == e.group2 }
            group1 = g1.name if g1 != nil
            group2 = g2.name if g2 != nil
          end
          if e.forum1 != nil
            f = @forums.find { |f| f.name == e.forum1 }
            forum1 = f.fullname if f != nil
          end
          if e.forum2 != nil
            f = @forums.find { |f| f.name == e.forum2 }
            forum2 = f.fullname if f != nil
          end
          if e.thread1 != nil
            t = @threads.find { |t| t.id == e.thread1 }
            thread1 = t.name if t != nil
          end
          if e.thread2 != nil
            t = @threads.find { |t| t.id == e.thread2 }
            thread2 = t.name if t != nil
          end
          oldcontent = e.oldcontent if e.oldcontent != ""
          newcontent = e.newcontent if e.newcontent != ""
          t = Time.now
          begin
            t = Time.at(e.time)
          rescue Exception
          end
          time = format_date(t)
          [user, action, group1, forum1, thread1, group2, forum2, thread2, oldcontent, newcontent, time]
        }
        sel.rows = selt
        sel.bind_context { |menu|
          menu.option(_("Refresh"), nil, "r") {
            rfr.call
            sel.focus
          }
        }
        sel.reload
      end
    }
    rfr.call
    sel.focus
    loop do
      loop_update
      sel.update
      break if escape
    end
  end

  def groupmembers(group)
    chrfr = false
    sel = ListBox.new([], p_("Forum", "Members"))
    users = []
    roles = []
    inherits = []
    rfr = Proc.new {
      m = srvproc("forum_groups", { "ac" => "members", "groupid" => group.id.to_s, "details" => 1 })
      if m[0].to_i < 0
        alert(_("Error"))
      else
        selt = []
        users = []
        roles = []
        inherits = []
        for i in 0...m[1].to_i
          users.push(m[2 + i * 3].delete("\r\n"))
          roles.push(m[2 + i * 3 + 1].to_i)
          inherits.push(m[2 + i * 3 + 2].to_i == 1)
          t = users.last
          if group.founder == users.last
            t += " (#{p_("Forum", "Administrator")})"
          elsif roles.last == 2
            t += " (#{p_("Forum", "Moderator")})"
          elsif roles.last == 3
            t += " (#{p_("Forum", "Banned")})"
          elsif roles.last == 5
            t += " (#{p_("Forum", "Invited")})"
          elsif roles.last == 4
            t += " (#{p_("Forum", "Waiting for review")})"
          end
          t += ". " + getstatus(users.last)
          selt.push(t)
        end
        sel.options = selt
      end
    }
    rfr.call
    sel.focus
    chpr = Proc.new { |cat|
      r = srvproc("forum_groups", { "ac" => "privileges", "pr" => cat, "user" => users[sel.index], "groupid" => group.id.to_s })
      if r[0].to_i < 0
        alert(_("Error"))
      else
        alert(p_("Forum", "Privileges of this user have been changed."))
      end
      rfr.call
      sel.focus
    }
    chus = Proc.new { |cat|
      r = srvproc("forum_groups", { "ac" => "user", "pr" => cat, "user" => users[sel.index], "groupid" => group.id.to_s })
      if r[0].to_i < 0
        alert(_("Error"))
      else
        alert(p_("Forum", "Privileges of this user have been changed."))
      end
      rfr.call
      sel.focus
    }
    usermenu(users[sel.index]) if enter
    sel.bind_context { |menu|
      if users.size > 0
        menu.useroption(users[sel.index])
        if group.founder == Session.name
          if users[sel.index] != Session.name
            if roles[sel.index] == 1
              menu.option(p_("Forum", "Grant moderation privileges")) {
                if !isbanned(users[sel.index]) || confirm(p_("Forum", "You want to give the role of moderator to a user who is banned globally. Groups with banned moderators are not displayed in most lists. Are you sure you want to continue?")) == 1
                  chpr.call("moderationgrant")
                end
              }
            elsif roles[sel.index] == 2
              menu.option(p_("Forum", "Deny moderation privileges")) { chpr.call("moderationdeny") }
              menu.option(p_("Forum", "Pass administrative privileges")) {
                confirm(p_("Forum", "Are you sure you want to resign your administrative privileges in %{groupname} and pass them to %{user}?") % { "user" => users[sel.index], "groupname" => group.name }) {
                  group.founder = users[sel.index]
                  chpr.call("passadmin")
                }
              }
            end
          end
          if roles[sel.index] == 2 || roles[sel.index] == 3
            s = p_("Forum", "Enable inheritance of this users' role")
            s = p_("Forum", "Disable inheritance of this users' role") if inherits[sel.index]
            menu.option(s) {
              prm = { "ac" => "inheritprivileges", "groupid" => group.id, "user" => users[sel.index] }
              if inherits[sel.index]
                prm["inherit"] = 0
              else
                prm["inherit"] = 1
              end
              st = srvproc("forum_groups", prm)
              if st[0].to_i == 0
                alert(_("Saved"))
                inherits[sel.index] = !inherits[sel.index]
                if users[sel.index] == Session.name
                  chrfr = true
                end
              else
                alert(_("Error"))
              end
            }
          end
        end
        if users[sel.index] != Session.name
          if group.role == 2
            case roles[sel.index]
            when 1
              if group.open && group.public
                menu.option(p_("Forum", "Ban in this group")) {
                  confirm(p_("Forum", "Are you sure you want to ban %{user} in %{groupname}?") % { "user" => users[sel.index], "groupname" => group.name }) { chus.call("ban") }
                }
              else
                menu.option(p_("Forum", "Kick")) {
                  confirm(p_("Forum", "Are you sure you want to kick %{user} out of %{groupname}?") % { "user" => users[sel.index], "groupname" => group.name }) { chus.call("kick") }
                }
              end
            when 3
              menu.option(p_("Forum", "Unban")) {
                confirm(p_("Forum", "Are you sure you want to unban %{user} in %{groupname}?") % { "user" => users[sel.index], "groupname" => group.name }) { chus.call("unban") }
              }
            when 4
              menu.option(p_("Forum", "Accept")) {
                confirm(p_("Forum", "Do you want to accept request of user %{user}") % { "user" => users[sel.index] }) { chus.call("accept") }
              }
              menu.option(p_("Forum", "Refuse")) {
                confirm(p_("Forum", "Do you want to refuse request of user %{user}") % { "user" => users[sel.index] }) { chus.call("refuse") }
              }
            when 5
              menu.option(p_("Forum", "Cancel invitation")) {
                confirm(p_("Forum", "Are you sure you want to cancel invitation of %{user} to %{groupname}?") % { "user" => users[sel.index], "groupname" => group.name }) { chus.call("cancel") }
              }
            end
          end
        end
        if group.role == 2
          if @sgroups[@grpsel.index - @grpheadindex].role == 2
            s = p_("Forum", "Invite")
            s = p_("Forum", "Add user") if @sgroups[@grpsel.index - @grpheadindex].recommended
            menu.option(s, nil, "i") {
              u = input_user(p_("Forum", "User to invite"))
              if u != nil
                r = srvproc("forum_groups", { "ac" => "invite", "groupid" => group.id.to_s, "user" => u })
                case r[0].to_i
                when 0
                  alert(p_("Forum", "The user has been invited"))
                when -1
                  alert(_("Database Error"))
                when -2
                  alert(_("Token expired"))
                when -3
                  alert(_("You haven't permissions to do this"))
                when -4
                  alert(p_("Forum", "This user does not exist"))
                when -5
                  alert(p_("Forum", "This user already belongs to this group"))
                end
              end
              rfr.call
            }
          end
        end
      end
    }
    loop do
      loop_update
      sel.update
      if escape
        loop_update
        @grpsel.focus
        break
      end
      if enter and users.size > 0
        usermenu(users[sel.index])
        loop_update
      end
    end
    if chrfr
      @grpindex[@lastlist || 0] = @grpsel.index
      getcache
      groupsmain
    end
  end

  def groupregulations(group)
    g = srvproc("forum_groups", { "ac" => "regulations", "groupid" => group.id })
    if g[0].to_i == 0
      return g[1..-1].join
    else
      return ""
    end
  end

  def canjoin(group)
    return true if !group.hasregulations
    regs = groupregulations(group)
    fields = [
      EditBox.new(p_("Forum", "Regulations of group %{groupname}") % { "groupname" => group.name }, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, regs),
      Button.new(p_("Forum", "I accept regulations of group %{groupname}") % { "groupname" => group.name }),
      Button.new(p_("Forum", "I decline regulations of group %{groupname}") % { "groupname" => group.name })
    ]
    form = Form.new(fields)
    loop do
      loop_update
      form.update
      if escape or form.fields[2].pressed?
        loop_update
        return false
      end
      if form.fields[1].pressed?
        loop_update
        return true
      end
    end
  end

  def newgroup
    ln = []
    lnindex = 0
    for lk in Lists.langs.keys
      l = Lists.langs[lk]
      ln.push(l["name"] + " (" + l["nativeName"] + ")")
      lnindex = ln.size - 1 if Configuration.language.downcase[0..1] == lk.downcase[0..1]
    end
    fields = [EditBox.new(p_("Forum", "Group name"), 0, "", true), EditBox.new(p_("Forum", "Group description"), EditBox::Flags::MultiLine, "", true), ListBox.new(ln, p_("Forum", "Language"), lnindex), ListBox.new([p_("Forum", "Hidden"), p_("Forum", "Public")], p_("Forum", "Group type")), ListBox.new([p_("Forum", "open (everyone can join)"), p_("Forum", "Moderated (everyone can request)")], p_("Forum", "Group join type")), nil, Button.new(_("Cancel"))]
    form = Form.new(fields)
    loop do
      loop_update
      form.update
      if form.fields[5] == nil and form.fields[0].text != "" and form.fields[1].text != ""
        form.fields[5] = Button.new(p_("Forum", "Create group"))
      elsif form.fields[5] != nil and (form.fields[0].text == "" or form.fields[1].text == "")
        form.fields[5] = nil
      end
      case form.fields[3].index
      when 0
        form.fields[4].options = [p_("Forum", "closed (only invited users can join)"), p_("Forum", "Moderated (everyone can request)")]
      when 1
        form.fields[4].options = [p_("Forum", "Moderated (everyone can request)"), p_("Forum", "open (everyone can join)")]
      end
      if form.fields[5] != nil and form.fields[5].pressed?
        r = srvproc("forum_groups", { "ac" => "create", "groupname" => form.fields[0].text, "bufdescription" => buffer(form.fields[1].text).to_s, "lang" => Lists.langs.keys[form.fields[2].index].to_s, "public" => form.fields[3].index.to_s, "open" => form.fields[4].index.to_s })
        if r[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Forum", "Group has been created"))
        end
        getcache
        return groupsmain(@lastlist)
      end
      break if escape or form.fields[6].pressed?
    end
    loop_update
    @grpsel.focus
  end

  def searcher_getquery(obj = nil)
    form = Form.new([
      edt_query = EditBox.new(p_("Forum", "Search query"), 0, "", true),
      lst_phrasein = ListBox.new([p_("Forum", "Titles"), p_("Forum", "Content"), p_("Forum", "Authors")], p_("Forum", "Search in"), 0, ListBox::Flags::MultiSelection),
      lst_threadin = ListBox.new([p_("Forum", "Joined groups"), p_("Forum", "Recommended groups"), p_("Forum", "Not joined groups")], p_("Forum", "of threads in"), 0, ListBox::Flags::MultiSelection),
      chk_transcriptions = CheckBox.new(p_("Forum", "Include transcriptions of audio posts")),
      btn_search = Button.new(p_("Forum", "Search")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    form.hide(lst_threadin) if obj != nil
    lst_phrasein.selected[0] = true
    lst_threadin.selected[0] = true
    lst_threadin.selected[1] = true
    chk_transcriptions.on(:change) {
      chk_transcriptions.checked = 0 if !requires_premiumpackage("courier")
    }
    form.accept_button = btn_search
    form.cancel_button = btn_cancel
    result = nil
    btn_cancel.on(:press) { form.resume }
    btn_search.on(:press) {
      result = Struct_Forum_SearchQuery.new(edt_query.text)
      result.phrase_in.clear
      result.thread_in.clear
      result.phrase_in.push(:name) if lst_phrasein.selected[0]
      result.phrase_in.push(:content) if lst_phrasein.selected[1]
      result.phrase_in.push(:author) if lst_phrasein.selected[2]
      if obj == nil
        result.thread_in.push(:joined) if lst_threadin.selected[0]
        result.thread_in.push(:recommended) if lst_threadin.selected[1]
        result.thread_in.push(:notjoined) if lst_threadin.selected[2]
      elsif obj.is_a?(Struct_Forum_Group)
        result.groupid = obj.id
      elsif obj.is_a?(Struct_Forum_Forum)
        result.forumid = obj.name
      end
      result.transcriptions = true if chk_transcriptions.checked == 1
      form.resume
    }
    form.wait
    return result
  end

  def forumsmain(group = -1)
    group = @group if group == -1
    group = 0 if group == -1
    @group = group
    forumsload(group)
    loop do
      loop_update
      @frmsel.update
      LocalConfig["ForumColumnForum"] = @frmsel.column if LocalConfig["ForumColumnForum"] != @frmsel.column
      if (arrow_left and !$keyr[0x10]) or escape
        return $scene = Scene_Main.new if @pre == nil && @preparam.is_a?(Integer)
        @frmindex = nil
        @forum = nil
        return groupsmain
      end
      break if $scene != self
      if (enter or (arrow_right and !$keyr[0x10])) and @sforums.size > 0
        @frmindex = @frmsel.index
        return threadsmain(@sforums[@frmsel.index].name)
      end
      break if $scene != self
    end
  end

  def forumsload(group)
    @sforums = []
    if group >= 0
      for f in @forums
        @sforums.push(f) if f.group.id == group
      end
    elsif group == -5
      for f in @forums
        @sforums.push(f) if f.followed
      end
    end
    @sforums.sort! { |a, b| forumsorter(a, b) } if LocalConfig["ForumSort"] != 0
    frmselt = []
    for forum in @sforums
      ftm = [forum.fullname]
      if group == -5
        for g in @groups
          ftm[0] += " (#{g.name}) " if g.id == forum.group.id
        end
      end
      ftm += [forum.threads.to_s, forum.posts.to_s, (forum.posts - forum.readposts).to_s, forum.description]
      ftm[0] += "\004INFNEW{ }\004" if forum.posts - forum.readposts > 0
      ftm[0] += "\004CLOSED\004" if forum.closed
      frmselt.push(ftm)
    end
    @frmindex = 0 if @frmindex == nil
    frmselh = [nil, p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread"), nil]
    @frmsel = TableBox.new(frmselh, frmselt, @frmindex, p_("Forum", "Select forum"))
    @frmsel.trigger(:move)
    @frmsel.column = LocalConfig["ForumColumnForum"] if LocalConfig["ForumColumnForum"] != nil
    @frmsel.bind_context(p_("Forum", "Forum")) { |menu| context_forums(menu) }
    @frmsel.focus
  end

  def forumsorter(a, b)
    result = 0
    case LocalConfig["ForumSort"].abs
    when 1
      result = polsorter(a.fullname, b.fullname)
    when 2
      result = (a.posts - a.readposts) <=> (b.posts - b.readposts)
    else
      result = 1
    end
    result *= -1 if LocalConfig["ForumSort"] < 0
    return result
  end

  def forumtagsedit(forum)
    return if forum.group.role != 2
    tags = forumtags(forum)
    selt = []
    for t in tags
      selt.push(t[1] + ": " + t[2..-1].join(", "))
    end
    sel = ListBox.new(selt, p_("Forum", "Forum tags"), 0, 0, false)
    sel.bind_context { |menu|
      menu.option(p_("Forum", "New tag"), nil, "n") {
        t = forumtageditor
        if t != nil
          if srvproc("forum_tags", { "forum" => forum.id, "ac" => "add", "label" => t[1], "buffer" => buffer(t[2..-1].join(",")) })[0].to_i < 0
            alert(_("Error"))
            return
          end
          tags.push(t)
          sel.options.push(t[1] + ": " + t[2..-1].join(", "))
        end
        sel.focus
      }
      if tags.size > 0
        menu.option(p_("Forum", "Delete tag"), nil, :del) {
          confirm(p_("Forum", "Are you sure you want to delete this tag?")) {
            if srvproc("forum_tags", { "forum" => forum.id, "ac" => "del", "tagid" => tags[sel.index][0] })[0].to_i < 0
              alert(_("Error"))
              return
            end
            tags.delete_at(sel.index)
            sel.options.delete_at(sel.index)
            play "edit_delete"
            sel.say_option
          }
        }
      end
    }
    loop do
      loop_update
      sel.update
      break if escape
    end
  end

  def forumtageditor(tag = [])
    if tag[0] == nil
      tag[0] = -1
      tag[1] = ""
    end
    fields = [
      EditBox.new(p_("Forum", "Tag name"), 0, tag[1], true),
      ListBox.new((tag[2..-1]) || [], p_("Forum", "Possible tag values")),
      Button.new(_("Save")),
      Button.new(_("Cancel"))
    ]
    form = Form.new(fields)
    fields[1].bind_context { |menu|
      menu.option(p_("Forum", "Add tag value"), nil, "n") {
        t = input_text(p_("Forum", "Tag value"), 0, "", true)
        if (/[\,\.\/\;\'\"\\\|\[\]\-\_\=\+]/ =~ t) != nil
          alert(p_("Forum", "Tag values cannot contain punctuation characters"))
          t = nil
        end
        if t != nil
          tag.push(t)
          form.fields[1].options.push(t)
        end
        form.focus
      }
      if tag.size > 2
        menu.option(p_("Forum", "Edit tag value"), nil, "e") {
          t = input_text(p_("Forum", "Tag value"), 0, tag[form.fields[1].index + 2], true)
          if (/[\,\.\/\;\'\"\\\|\[\]\-\_\=\+]/ =~ t) != nil
            alert(p_("Forum", "Tag values cannot contain punctuation characters"))
            t = nil
          end
          if t != nil
            tag[form.fields[1].index + 2] = t
            form.fields[1].options[form.fields[1].index] = t
          end
          form.focus
        }
        menu.option(p_("Forum", "Delete tag value"), nil, :del) {
          play("editbox_delete")
          tag.delete_at(form.fields[1].index + 2)
          form.fields[1].options.delete_at(form.fields[1].index)
          form.fields[1].say_option
        }
      end
    }
    loop do
      loop_update
      form.update
      return nil if escape or form.fields[3].pressed?
      if (enter and $keyr[0x11]) || form.fields[2].pressed?
        if tag.size > 2
          tag[1] = form.fields[0].text
          return tag
        else
          alert(p_("Forum", "Tag must have at least one value"))
        end
      end
    end
  end

  def forumtags(forum)
    tt = srvproc("forum_tags", { "forum" => forum.id, "ac" => "get" })
    if tt[0].to_i < 0
      alert(_("Error"))
      return []
    end
    tags = []
    for i in 0...tt[1].to_i
      id = tt[2 + i * 3].to_i
      label = tt[2 + i * 3 + 1].delete("\r\n")
      taglist = tt[2 + i * 3 + 2].delete("\r\n")
      tags.push([id, label] + taglist.split(","))
    end
    return tags
  end

  def context_forums(menu)
    if @frmsel.options.size > 0
      menu.option(p_("Forum", "Open")) {
        @frmindex = @frmsel.index
        threadsmain(@sforums[@frmsel.index].name)
      }
      s = p_("Forum", "Follow this forum")
      s = p_("Forum", "Unfollow this forum") if @sforums.size > 0 and @sforums[@frmsel.index].followed == true
      menu.option(s, nil, "l") {
        if @sforums[@frmsel.index].group.role == 2 || requires_premiumpackage("courier")
          if @sforums[@frmsel.index].followed == false
            if srvproc("forum_ft", { "add" => "2", "forum" => @sforums[@frmsel.index].name })[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Forum", "Added to followed forums list."))
              @sforums[@frmsel.index].followed = true
            end
          else
            if srvproc("forum_ft", { "remove" => "2", "forum" => @sforums[@frmsel.index].name })[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Forum", "Removed from followed forums list."))
              @sforums[@frmsel.index].followed = false
              if id == -1
                groupsmain(id)
              end
            end
          end
          if @group == -5
            forumsmain(@group)
          end
        end
      }
      menu.option(p_("Forum", "Search"), nil, "f") {
        @query = searcher_getquery(@sforums[@frmsel.index])
        if @query != nil
          usequery
          threadsmain(-3)
        else
          @frmsel.focus
        end
      }
      menu.option(p_("Forum", "Mark this forum as read"), nil, "w") {
        if @sforums[@frmsel.index].posts - @sforums[@frmsel.index].readposts < 100 or confirm(p_("Forum", "All posts on this forum will be marked as read. Are you sure you want to continue?")) == 1
          if srvproc("forum_markasread", { "forum" => @sforums[@frmsel.index].name })[0].to_i == 0
            for t in @threads
              t.readposts = t.posts if t.forum.name == @sforums[@frmsel.index].name
            end
            @sforums[@frmsel.index].readposts = @sforums[@frmsel.index].posts
            @sforums[@frmsel.index].group.readposts = @forums.find_all { |f| f.group == @sforums[@frmsel.index].group }.map { |f| f.readposts }.sum
            @frmsel.rows[@frmsel.index][0].gsub!("\004INFNEW{ }\004", "")
            @frmsel.rows[@frmsel.index][3] = "0"
            @frmsel.reload
            alert(p_("Forum", "The forum has been marked as read."))
          else
            alert(_("Error"))
          end
        end
      }
      menu.option(p_("Forum", "Add this forum to quick actions"), nil, "q") {
        QuickActions.create(Scene_Forum, @sforums[@frmsel.index].fullname + " (#{p_("Forum", "Forum")})", [nil, @sforums[@frmsel.index].name])
        alert(p_("Forum", "Forum added to quick actions"), false)
      }
    end
    groupclass = Struct_Forum_Group.new
    @groups.each { |g| groupclass = g if g.id == @group }
    if groupclass.founder == Session.name or groupclass.role == 2
      menu.submenu(p_("Forum", "Moderation")) { |m|
        m.option(p_("Forum", "New forum"), nil, "n") {
          newforum
          getcache
          forumsmain(@group)
        }
        if @sforums.size > 0
          m.option(p_("Forum", "Edit forum"), nil, "e") {
            form = Form.new([EditBox.new(p_("Forum", "Forum name"), 0, @sforums[@frmsel.index].fullname, true), EditBox.new(p_("Forum", "Forum description"), EditBox::Flags::MultiLine, @sforums[@frmsel.index].description, true), ListBox.new([p_("Forum", "Text forum"), p_("Forum", "Voice forum"), p_("Forum", "Mixed forum")], p_("Forum", "Forum type"), @sforums[@frmsel.index].type), nil, Button.new(_("Cancel"))])
            loop do
              loop_update
              form.update
              if form.fields[3] == nil and form.fields[0].text != ""
                form.fields[3] = Button.new(_("Save"))
              elsif form.fields[3] != nil and form.fields[0].text == ""
                form.fields[3] = nil
              end
              if form.fields[3] != nil and form.fields[3].pressed?
                u = { "ac" => "forumedit", "forum" => @sforums[@frmsel.index].name, "forumname" => form.fields[0].text, "forumtype" => form.fields[2].index }
                if form.fields[1].text != ""
                  b = buffer(form.fields[1].text)
                  u["bufforumdescription"] = b.to_s
                end
                f = srvproc("forum_groups", u)
                if f[0].to_i < 0
                  alert(_("Error"))
                else
                  alert(_("Saved"))
                end
                command = @frmsel.options[@frmsel.index]
                getcache
                forumsload(@group)
                @frmsel.index = @frmsel.options.find_index(command) || 0
                @frmsel.focus
                @grpsetindex = @group
                break
              end
              break if escape or form.fields[4].pressed?
            end
            loop_update
            @frmsel.focus
          }
          s = p_("Forum", "Close forum")
          s = p_("Forum", "Open forum") if @sforums[@frmsel.index].closed
          m.option(s, nil, "k") {
            clo = ((@sforums[@frmsel.index].closed) ? 0 : 1)
            f = srvproc("forum_mod", { "closing" => 2, "close" => clo.to_s, "forum" => @sforums[@frmsel.index].name })
            if f[0].to_i < 0
              alert(_("Error"))
            else
              if @sforums[@frmsel.index].closed
                @sforums[@frmsel.index].closed = false
                @frmsel.rows[@frmsel.index][0].gsub!("\004CLOSED\004", "")
                alert(p_("Forum", "The forum has been opened"))
              else
                @sforums[@frmsel.index].closed = true
                @frmsel.rows[@frmsel.index][0] += "\004CLOSED\004"
                alert(p_("Forum", "The forum has been closed"))
              end
              @frmsel.setcolumn(0)
            end
          }
          m.option(p_("Forum", "Edit forum tags"), nil, "t") {
            forumtagsedit(@sforums[@frmsel.index])
            @frmsel.focus
          }
          m.option(p_("Forum", "Change forum position")) {
            selt = []
            @sforums.each { |f| selt.push(f.fullname) }
            ind = selector(selt + [p_("Forum", "Move to end")], p_("Forum", "Move forum"), 0, -1)
            if ind != -1
              r = srvproc("forum_groups", { "ac" => "forumchangepos", "forum" => @sforums[@frmsel.index].name, "position" => ind.to_s })
              if r[0].to_i < 0
                alert(_("Error"))
              else
                alert(_("Saved"))
              end
              getcache
              forumsmain(@group)
            else
              @frmsel.focus
            end
          }
          if @sforums[@frmsel.index].posts == 0
            m.option(p_("Forum", "Delete forum")) {
              confirm(p_("Forum", "Are you sure you want to delete this forum?")) {
                f = srvproc("forum_groups", { "ac" => "forumdelete", "forum" => @sforums[@frmsel.index].name })
                if f[0].to_i < 0
                  alert(_("Error"))
                else
                  alert(p_("Forum", "The forum has been deleted."))
                end
                getcache
                forumsmain(@group)
              }
            }
          end
        end
      }
    end
    sortermenu(1, @group, menu)
    menu.option(_("Refresh"), nil, "r") {
      getcache
      main
    }
  end

  def newforum
    fields = [EditBox.new(p_("Forum", "Forum name"), 0, "", true), EditBox.new(p_("Forum", "Forum description"), EditBox::Flags::MultiLine, "", true), ListBox.new([p_("Forum", "Text forum"), p_("Forum", "Voice forum"), p_("Forum", "Mixed forum")], p_("Forum", "Forum type")), nil, Button.new(_("Cancel"))]
    form = Form.new(fields)
    loop do
      loop_update
      form.update
      if form.fields[3] == nil and form.fields[0].text != ""
        form.fields[3] = Button.new(p_("Forum", "Create forum"))
      elsif form.fields[3] != nil and form.fields[0].text == ""
        form.fields[3] = nil
      end
      if form.fields[3] != nil and form.fields[3].pressed?
        groupclass = Struct_Forum_Group.new
        @groups.each { |g| groupclass = g if g.id == @group }
        u = { "ac" => "forumcreate", "groupid" => groupclass.id, "forumname" => fields[0].text, "forumtype" => form.fields[2].index }
        if form.fields[1].text != ""
          b = buffer(form.fields[1].text)
          u["bufforumdescription"] = b
        end
        f = srvproc("forum_groups", u)
        if f[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Forum", "The forum has been created"))
        end
        break
      end
      break if escape or form.fields[4].pressed?
    end
  end

  def threadsmain(id)
    @forum = id
    index = @lastthreadindex
    @lastthreadindex = nil
    @forumtype = 0
    for forum in @forums
      @forumtype = forum.type if forum.name == id
    end
    @sthreads = []
    if id == -7
      mnt = srvproc("mentions", { "list" => 1, "details" => 1 })
      @mentions = []
      if mnt[0].to_i == 0
        t = 0
        for m in mnt[1..mnt.size - 1]
          case t
          when 0
            @mentions.push(Struct_Forum_Mention.new(m.to_i))
            t += 1
          when 1
            @mentions.last.author = m.delete("\r\n")
            t += 1
          when 2
            @mentions.last.thread = m.to_i
            t += 1
          when 3
            @mentions.last.post = m.to_i
            t += 1
          when 4
            @mentions.last.message = m.delete("\r\n")
            t += 1
          when 5
            @mentions.last.time = Time.at(m.to_i)
            t = 0
          end
        end
      end
    end
    if id == -8
      @popular = []
      frm = srvproc("forum_popular", { "type" => "threads" })
      if frm[0].to_i == 0
        for t in frm[1..-1]
          @popular.push(t.to_i)
        end
      end
    end
    @sthreads = []
    if id == -11
      mnt = srvproc("mentions", { "list" => 2, "details" => 1 })
      @mentions = []
      if mnt[0].to_i == 0
        t = 0
        for m in mnt[1..mnt.size - 1]
          case t
          when 0
            @mentions.push(Struct_Forum_Mention.new(m.to_i))
            t += 1
          when 1
            @mentions.last.author = m.delete("\r\n")
            t += 1
          when 2
            @mentions.last.thread = m.to_i
            t += 1
          when 3
            @mentions.last.post = m.to_i
            t += 1
          when 4
            @mentions.last.message = m.delete("\r\n")
            t += 1
          when 5
            @mentions.last.time = Time.at(m.to_i)
            t = 0
          end
        end
      end
    end
    rsl = []
    if id == -3
      rsl = []
      for r in @results
        i = r / 100
        rsl[i] = [] if rsl[i] == nil
        rsl[i].push(r)
      end
    end
    @sthreads = @threads.map { |t|
      case id
      when -13
        []
      when -12
        if @groups.find_all { |g| g.role == 2 }.map { |g| g.id }.include?(t.offered)
          t
        else
          nil
        end
      when -11
        r = []
        for mention in @mentions
          if t.id == mention.thread
            th = t.clone
            th.mention = mention
            r.push(th)
          end
        end
        r
      when -10
        if t.marked == true
          t
        else
          nil
        end
      when -9
        if t.author == Session.name
          t
        else
          nil
        end
      when -8
        if @popular.include?(t.id) and t.readposts <= t.posts / 1.1
          t
        else
          nil
        end
      when -7
        r = []
        for mention in @mentions
          if t.id == mention.thread
            th = t.clone
            th.mention = mention
            r.push(th)
          end
        end
        r
      when -6
        folfor = []
        for forum in @forums
          folfor.push(forum.name) if forum.followed == true
        end
        if folfor.include?(t.forum.name) and t.readposts < t.posts
          t
        else
          nil
        end
      when -4
        folfor = []
        for forum in @forums
          folfor.push(forum.name) if forum.followed == true
        end
        if folfor.include?(t.forum.name) and t.readposts == 0
          t
        else
          nil
        end
      when -3
        i = t.id / 100
        if rsl[i] != nil && rsl[i].include?(t.id)
          t
        else
          nil
        end
      when -2
        if t.followed == true and t.readposts < t.posts
          t
        else
          nil
        end
      when -1
        if t.followed == true
          t
        else
          nil
        end
      when 0
        t
      else
        if t.forum.name == id
          t
        else
          nil
        end
      end
    }.compact.flatten
    if id.is_a?(String)
      u = []
      d = []
      @sthreads.each { |t|
        if t.pinned
          u.push(t)
        else
          d.push(t)
        end
      }
      @sthreads = u + d
    end
    if id == -8
      @sthreads.sort! { |a, b| @popular.index(a.id) <=> @popular.index(b.id) }
    end
    if id == -7 or id == -11
      @sthreads.sort! { |a, b| b.mention.time <=> a.mention.time }
    end
    if id == -2 and @sthreads.size == 0
      alert(p_("Forum", "No new posts in followed threads"))
      return $scene = Scene_WhatsNew.new
    end
    if id == -4 and @sthreads.size == 0
      alert(p_("Forum", "No new threads on the followed forums"))
      return $scene = Scene_WhatsNew.new
    end
    if id == -6 and @sthreads.size == 0
      alert(p_("Forum", "No new posts on the followed forums"))
      return $scene = Scene_WhatsNew.new
    end
    if id == -7 and @sthreads.size == 0
      alert(p_("Forum", "No new mentions"))
      return $scene = Scene_WhatsNew.new
    end
    index = @sthreads.size - 1 if index != nil && index >= @sthreads.size
    setindex = nil
    thrselt = @sthreads.map { |thread|
      if setindex == nil
        if id != -11
          setindex = thread if thread.id == @pre
        else
          setindex = thread if @tc != nil && thread.mention.id == @tc.mention.id
        end
      end
      tmp = [thread.name + ""]
      tmp[0] << "\004INFNEW{#{p_("Forum", "New")}: }\004" if thread.readposts < thread.posts and (id != -2 and id != -4 and id != -6 and id != -7)
      tmp[0] << "\004CLOSED\004" if thread.closed
      tmp[0] << "\004PINNED\004" if thread.pinned
      if id == -7 or id == -11
        tmp[0] << " . #{p_("Forum", "Mentioned by")}: #{thread.mention.author} (#{thread.mention.message})"
      end
      if id == -3 or id == -6 or id == -7
        tmp[0] << " (#{thread.forum.fullname}, #{thread.forum.group.name})"
      end
      tmp[1] = thread.author #.lore
      tmp[2] = thread.posts.to_s
      tmp[3] = (thread.posts - thread.readposts).to_s
      tmp
    }
    index = @sthreads.index(setindex) || 0 if index == nil
    if !(@pre == nil && @preparam != nil)
      @pre = nil
      @preparam = nil
    end
    header = p_("Forum", "Select thread")
    header = "" if id == -2 or id == -4 or id == -6 or id == -7
    thrselh = [nil, p_("Forum", "Author"), p_("Forum", "posts"), p_("Forum", "Unread")]
    @thrsel = TableBox.new(thrselh, thrselt, index, header, true, ListBox::Flags::Tagged)
    @thrsel.trigger(:move)
    @thrsel.column = LocalConfig["ForumColumnThread"] if LocalConfig["ForumColumnThread"] != nil
    @thrsel.bind_context(p_("Forum", "Forum")) { |menu| context_threads(menu) }
    if @tag != nil
      @thrsel.tag = @tag
      @tag = nil
    end
    @thrsel.focus
    loop do
      loop_update
      @thrsel.update
      LocalConfig["ForumColumnThread"] = @thrsel.column if LocalConfig["ForumColumnThread"] != @thrsel.column
      if (arrow_left and !$keyr[0x10]) or escape
        return $scene = Scene_Main.new if @pre == nil && @preparam.is_a?(String)
        if id.is_a?(String)
          return forumsmain
        elsif id == -2 or id == -4 or id == -6 or id == -7
          return $scene = Scene_WhatsNew.new
        else
          return groupsmain
        end
      end
      if enter or (arrow_right and !$keyr[0x10]) and @sthreads.size > 0
        threadopen(@thrsel.index)
      end
      break if $scene != self
    end
  end

  def threadopen(index)
    g = @sthreads[index].forum.group
    groupmotddlg(g, false) if g.hasnewmotd
    if @group == -5
      $scene = Scene_Forum_Thread.new(@sthreads[index], -5, @cat, @query, nil, nil, @thrsel.tag)
    else
      if @forum == -7 or @forum == -11
        $scene = Scene_Forum_Thread.new(@sthreads[index], @forum, @cat, @query, @sthreads[@thrsel.index].mention, nil, @thrsel.tag)
      else
        $scene = Scene_Forum_Thread.new(@sthreads[index], @forum, @cat, @query, nil, nil, @thrsel.tag)
      end
    end
  end

  def context_threads(menu)
    group = Struct_Forum_Group.new
    for f in @forums
      group = f.group if f.name == @forum
    end
    if @sthreads.size > 0
      menu.option(p_("Forum", "Open")) {
        threadopen(@thrsel.index)
      }
      s = p_("Forum", "Mark this thread")
      s = p_("Forum", "Unmark this thread") if @sthreads[@thrsel.index].marked == true
      menu.option(s, nil, "h") {
        if requires_premiumpackage("courier")
          m = 0
          m = 1 if @sthreads[@thrsel.index].marked == false
          if srvproc("forum_threadaction", { "ac" => "marking", "mark" => m, "threadid" => @sthreads[@thrsel.index].id })[0].to_i < 0
            alert(_("Error"))
          else
            if m == 0
              alert(p_("Forum", "Thread unmarked"))
            else
              alert(p_("Forum", "Thread marked"))
            end
            @sthreads[@thrsel.index].marked = !@sthreads[@thrsel.index].marked
            if @forum == -10
              threadsmain(@forum)
            end
          end
        end
      }
      s = p_("Forum", "Add to followed threads list")
      s = p_("Forum", "Unfollow this thread") if @sthreads[@thrsel.index].followed == true
      menu.option(s, nil, "l") {
        if @sthreads[@thrsel.index].followed == false
          if srvproc("forum_ft", { "add" => "1", "thread" => @sthreads[@thrsel.index].id })[0].to_i < 0
            alert(_("Error"))
          else
            alert(p_("Forum", "Added to the list of followed threads."))
            @sthreads[@thrsel.index].followed = true
          end
        else
          if srvproc("forum_ft", { "remove" => "1", "thread" => @sthreads[@thrsel.index].id })[0].to_i < 0
            alert(_("Error"))
          else
            alert(p_("Forum", "Removed from followed threads list."))
            @sthreads[@thrsel.index].followed = false
            if @forum == -1
              threadsmain(@forum)
            end
          end
        end
      }
      menu.option(p_("Forum", "Thread statistics"), nil, "d") {
        t = srvproc("forum_threadaction", { "ac" => "stats", "threadid" => @sthreads[@thrsel.index].id })
        s = ""
        if t[0].to_i == 0
          s += p_("Forum", "Followers: %{count_followers}") % { "count_followers" => t[1].to_i } + "\n"
          s += p_("Forum", "All mentions: %{count_mentions}") % { "count_mentions" => t[2].to_i } + "\n"
          s += p_("Forum", "Unique authors: %{count_authors}") % { "count_authors" => t[3].to_i } + "\n"
          s += p_("Forum", "Readers: %{count_readers}") % { "count_readers" => t[4].to_i } + "\n"
          s += p_("Forum", "Users that have read less than 50 percent of posts: %{count_readers}") % { "count_readers" => t[5].to_i } + "\n"
          s += p_("Forum", "Users that have read over 90 percent of posts: %{count_readers}") % { "count_readers" => t[6].to_i } + "\n"
          s += p_("Forum", "Users that have read all posts: %{count_readers}") % { "count_readers" => t[7].to_i } + "\n"
        end
        input_text(p_("Forum", "Thread statistics summary"), EditBox::Flags::ReadOnly, s, true)
      }
    end
    forum = @forum
    @forums.each { |f| forum = f if f.name == @forum }
    if forum.is_a?(String) == false and forum.is_a?(Integer) == false and @noteditable != true and ((group.public == true and group.open == true) or [1, 2].include?(group.role)) and group.role != 3 and forum.closed == false
      menu.option(p_("Forum", "New thread"), nil, "n") {
        newthread
        getcache
        threadsmain(@forum)
      }
    end
    if @sthreads.size > 0
      if (Session.moderator == 1 && @sthreads[@thrsel.index].forum.group.recommended) || @sthreads[@thrsel.index].forum.group.role == 2
        menu.submenu(p_("Forum", "Moderation")) { |m|
          m.option(p_("Forum", "Move thread"), nil, "O") {
            selt = []
            ind = 0
            mforums = []
            for f in @forums
              mforums.push(f) if f.group.role == 2 or (Session.moderator == 1 && f.group.recommended)
            end
            for f in mforums
              selt.push(f.fullname + " (" + f.group.name + ")")
              ind = selt.size - 1 if f.name == @sthreads[@thrsel.index].forum.name
            end
            destination = selector(selt, p_("Forum", "Thread destination"), ind, -1)
            if destination != -1
              if srvproc("forum_mod", { "move" => "1", "threadid" => @sthreads[@thrsel.index].id, "destination" => mforums[destination].name })[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "The thread has been moved."))
                getcache
                @lastthreadindex = @thrsel.index
                threadsmain(@forum)
              end
            end
          }
          m.option(p_("Forum", "Rename"), nil, "e") {
            name = input_text(p_("Forum", "Type a new thread name"), 0, @sthreads[@thrsel.index].name, true)
            if name != nil
              if srvproc("forum_mod", { "rename" => "1", "threadid" => @sthreads[@thrsel.index].id, "threadname" => name })[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "The forum name has been changed."))
                getcache
                @lastthreadindex = @thrsel.index
                threadsmain(@forum)
              end
            end
          }
          m.option(p_("Forum", "Delete thread")) {
            confirm(p_("Forum", "Do you really want to delete thread %{thrname}?") % { "thrname" => @sthreads[@thrsel.index].name }) do
              if srvproc("forum_mod", { "delete" => "1", "threadid" => @sthreads[@thrsel.index].id })[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "This thread has been deleted."))
                getcache
                @lastthreadindex = @thrsel.index
                threadsmain(@forum)
              end
            end
          }
          s = p_("Forum", "Close thread")
          s = p_("Forum", "Open thread") if @sthreads[@thrsel.index].closed and (Session.moderator == 1 && @sthreads[@thrsel.index].forum.group.recommended) || @sthreads[@thrsel.index].forum.group.role == 2
          m.option(s, nil, "k") {
            clo = ((@sthreads[@thrsel.index].closed) ? 0 : 1)
            f = srvproc("forum_mod", { "closing" => "1", "close" => clo.to_s, "threadid" => @sthreads[@thrsel.index].id.to_s })
            if f[0].to_i < 0
              alert(_("Error"))
            else
              if @sthreads[@thrsel.index].closed
                @sthreads[@thrsel.index].closed = false
                @thrsel.rows[@thrsel.index][0].gsub!("\004CLOSED\004", "")
                alert(p_("Forum", "The thread has been opened"))
              else
                @sthreads[@thrsel.index].closed = true
                @thrsel.rows[@thrsel.index][0] += "\004CLOSED\004"
                alert(p_("Forum", "The thread has been closed"))
              end
              @thrsel.setcolumn(0)
            end
          }
          s = p_("Forum", "Pin thread")
          s = p_("Forum", "Unpin thread") if @sthreads[@thrsel.index].pinned and (Session.moderator == 1 && @sthreads[@thrsel.index].forum.group.recommended) || @sthreads[@thrsel.index].forum.group.role == 2
          m.option(s, nil, "p") {
            pin = ((@sthreads[@thrsel.index].pinned) ? 0 : 1)
            f = srvproc("forum_mod", { "pinning" => "1", "pin" => pin.to_s, "threadid" => @sthreads[@thrsel.index].id.to_s })
            if f[0].to_i < 0
              alert(_("Error"))
            else
              if @sthreads[@thrsel.index].pinned
                @sthreads[@thrsel.index].pinned = false
                @thrsel.rows[@thrsel.index][0].gsub!("\004PINNED\004", "")
                alert(p_("Forum", "Thread has been unpinned"))
              else
                @sthreads[@thrsel.index].pinned = true
                @thrsel.rows[@thrsel.index][0] += "\004PINNED\004"
                alert(p_("Forum", "Thread has been pinned"))
              end
              @thrsel.setcolumn(0)
            end
          }
          if @sthreads[@thrsel.index].offered == 0
            m.option(p_("Forum", "Offer this thread to another group"), nil, "o") {
              users = []
              m = srvproc("forum_groups", { "ac" => "members", "groupid" => @sthreads[@thrsel.index].forum.group.id.to_s })
              if m[0].to_i == 0
                for i in 0...m[1].to_i
                  users.push(m[2 + i * 2].delete("\r\n"))
                end
              end
              dgroups = []
              for g in @groups
                dgroups.push(g) if g.role > 0 and users.include?(g.founder) and g.id != @sthreads[@thrsel.index].forum.group.id
              end
              dests = dgroups.map { |g| g.name + " - " + p_("Forum", "Group founded by %{founder}") % { "founder" => g.founder } }
              ind = selector(dests, p_("Forum", "Which group you want to offer this thread to?"), 0, -1)
              if ind >= 0
                dest = dgroups[ind]
                e = srvproc("forum_mod", { "offer" => 1, "threadid" => @sthreads[@thrsel.index].id, "destination" => dest.id })
                if e[0].to_i < 0
                  alert(_("Error"))
                else
                  alert(p_("Forum", "The offer has been created"))
                  @sthreads[@thrsel.index].offered = dest.id
                end
              end
              @thrsel.focus
            }
          else
            m.option(p_("Forum", "Withdraw the offer of this thread"), nil, "o") {
              e = srvproc("forum_mod", { "offer" => 1, "threadid" => @sthreads[@thrsel.index].id, "destination" => 0 })
              if e[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "The offer has been withdrawn."))
                @sthreads[@thrsel.index].offered = 0
              end
              @thrsel.focus
            }
          end
          m.option(p_("Forum", "Mass Actions"), nil, "\\") {
            moderation_mass_threads
          }
        }
      end
      if @sthreads[@thrsel.index].offered > 0
        gr = nil
        suc = false
        for g in @groups
          if g.id == @sthreads[@thrsel.index].offered and g.role == 2
            suc = true
            gr = g
          end
        end
        if suc
          menu.submenu(p_("Forum", "Thread transfer offer to group %{groupname}") % { "groupname" => gr.name }) { |m|
            m.option(p_("Forum", "Accept this offer"), nil, "A") {
              forums = []
              for f in @forums
                forums.push(f) if f.group.id == gr.id
              end
              if forums.size > 0
                ind = selector(forums.map { |f| f.fullname }, p_("Forum", "Select destination forum"), 0, -1)
                if ind >= 0
                  dest = forums[ind]
                  e = srvproc("forum_mod", { "offeraccept" => 1, "threadid" => @sthreads[@thrsel.index].id, "destination" => dest.name })
                  if e[0].to_i < 0
                    alert(_("Error"))
                  else
                    @sthreads[@thrsel.index].offered = 0
                    @sthreads[@thrsel.index].forum = dest
                    alert(p_("Forum", "Offer accepted"))
                  end
                end
              end
              @sthreads.delete_at(@thrsel.index)
              @thrsel.rows.delete_at(@thrsel.index)
              @thrsel.reload
              @thrsel.focus
            }
            m.option(p_("Forum", "Refuse this offer"), nil, "R") {
              f = srvproc("forum_mod", { "offerrefuse" => 1, "threadid" => @sthreads[@thrsel.index].id })
              if f[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "Offer refused"))
                @sthreads[@thrsel.index].offered = 0
              end
              @thrsel.focus
            }
          }
        end
      end
    end
    menu.option(_("Refresh"), nil, "r") {
      @pre = @sthreads[@thrsel.index].id
      getcache
      threadsmain(@forum)
    }
  end

  def moderation_mass_threads
    mthreads = @sthreads.select { |m| (Session.moderator == 1 && m.forum.group.recommended) || m.forum.group.role == 2 }
    index = mthreads.find_index(@sthreads[@thrsel.index]) || 0
    form = Form.new([
      lst_threads = ListBox.new(mthreads.map { |m| m.name }, p_("Forum", "Threads"), index, ListBox::Flags::MultiSelection),
      btn_move = Button.new(p_("Forum", "Move")),
      btn_offer = Button.new(p_("Forum", "Offer")),
      btn_delete = Button.new(p_("Forum", "Delete")),
      btn_cancel = Button.new(_("Cancel"))
    ])
    form.cancel_button = btn_cancel
    btn_cancel.on(:press) {
      form.resume
      @thrsel.focus
    }
    btn_move.on(:press) {
      selected = lst_threads.multiselections.map { |i| mthreads[i] }
      if moderation_mass_threads_proceed(selected, :move)
        form.resume
        getcache
        @lastthreadindex = @thrsel.index
        threadsmain(@forum)
      else
        form.focus
      end
    }
    btn_delete.on(:press) {
      selected = lst_threads.multiselections.map { |i| mthreads[i] }
      if moderation_mass_threads_proceed(selected, :delete)
        form.resume
        getcache
        @lastthreadindex = @thrsel.index
        threadsmain(@forum)
      else
        form.focus
      end
    }
    btn_offer.on(:press) {
      selected = lst_threads.multiselections.map { |i| mthreads[i] }
      if moderation_mass_threads_proceed(selected, :offer)
        form.resume
        getcache
        @lastthreadindex = @thrsel.index
        threadsmain(@forum)
      else
        form.focus
      end
    }

    form.wait
  end

  def moderation_mass_threads_proceed(threads, action)
    if threads.size == 0
      alert(p_("Forum", "No threads selected"))
      return false
    end
    header = ""
    label = ""
    case action
    when :move
      header = np_("Forum", "%{count} thread to move", "%{count} threads to move", threads.size) % { "count" => threads.size }
      label = p_("Forum", "Move")
    when :delete
      header = np_("Forum", "%{count} thread to delete", "%{count} threads to delete", threads.size) % { "count" => threads.size }
      label = p_("Forum", "Delete")
    when :offer
      header = np_("Forum", "%{count} thread to move", "%{count} threads to offer", threads.size) % { "count" => threads.size }
      label = p_("Forum", "Offer")
    end
    form = Form.new([
      lst_threads = ListBox.new(threads.map { |t| t.name }, header),
      btn_proceed = Button.new(label),
      btn_cancel = Button.new(_("Cancel"))
    ])
    ret = false
    form.cancel_button = btn_cancel
    btn_cancel.on(:press) { form.resume }
    btn_proceed.on(:press) {
      case action
      when :move
        selt = []
        ind = 0
        mforums = []
        for f in @forums
          mforums.push(f) if f.group.role == 2 or (Session.moderator == 1 && f.group.recommended)
        end
        for f in mforums
          selt.push(f.fullname + " (" + f.group.name + ")")
          ind = selt.size - 1 if f.name == threads[0].forum.name
        end
        destination = selector(selt, p_("Forum", "Threads destination"), ind, -1)
        if destination != -1
          for thread in threads
            srvproc("forum_mod", { "move" => "1", "threadid" => thread.id, "destination" => mforums[destination].name })
          end
          alert(p_("Forum", "Selected threads have been moved."))
          ret = true
          form.resume
        else
          form.focus
        end
      when :delete
        for thread in threads
          srvproc("forum_mod", { "delete" => "1", "threadid" => thread.id })
        end
        alert(p_("Forum", "Selected threads have been deleted."))
        ret = true
        form.resume
      when :offer
        users = []
        m = srvproc("forum_groups", { "ac" => "members", "groupid" => @sthreads[@thrsel.index].forum.group.id.to_s })
        if m[0].to_i == 0
          for i in 0...m[1].to_i
            users.push(m[2 + i * 2].delete("\r\n"))
          end
        end
        dgroups = []
        for g in @groups
          dgroups.push(g) if g.role > 0 and users.include?(g.founder) and g.id != @sthreads[@thrsel.index].forum.group.id
        end
        dests = dgroups.map { |g| g.name + " - " + p_("Forum", "Group founded by %{founder}") % { "founder" => g.founder } }
        ind = selector(dests, p_("Forum", "Which group you want to offer these threads to?"), 0, -1)
        if ind >= 0
          dest = dgroups[ind]
          for thread in threads
            next if thread.offered != 0
            e = srvproc("forum_mod", { "offer" => 1, "threadid" => thread.id, "destination" => dest.id })
          end
          alert(p_("Forum", "The offer has been created"))
          ret = true
          form.resume
        else
          @thrsel.focus
        end
      end
    }
    form.wait
    return ret
  end

  def newthread
    type = @forumtype
    if type == 2
      type = selector([p_("Forum", "Text post"), p_("Forum", "Audio post")], p_("Forum", "Select first post type"), 0, -1)
      return if type == -1
    end
    fields = []
    thread = text = ""
    rectitlest = recpostst = 0
    forums = []
    forumclasses = []
    forumindex = 0
    for g in @groups
      for f in @forums
        if f.type == @forumtype && !f.closed
          if f.group.id == g.id
            forums.push(f.fullname + " (#{g.name})")
            forumclasses.push(f)
            forumindex = forums.size - 1 if f.name == @forum
          end
        end
      end
    end
    fields = [EditBox.new(p_("Forum", "Thread name"), 0, "", true)]
    if type == 0
      fields[1..6] = [EditBox.new(p_("Forum", "Post content"), EditBox::Flags::MultiLine, "", true), CheckBox.new(p_("Forum", "Use MarkDown in this post")), nil, Button.new(p_("Forum", "Attach a poll")), nil, Button.new(p_("Forum", "Attach a file"))]
      fields[2].on(:change) {
        fields[2].checked = 0 if !requires_premiumpackage("courier")
      }
    else
      fields[1..6] = [OpusRecordButton.new(p_("Forum", "Audio post"), Dirs.temp + "\\audiopost.opus", 96, 48), nil, nil, nil, nil, nil]
    end
    fields += [CheckBox.new(p_("Forum", "Add to followed threads list")), ListBox.new(forums, p_("Forum", "Forum"), forumindex), nil, Button.new(_("Cancel"))]
    form = Form.new(fields)
    form.fields[-3].on(:move) {
      tin = false
      tin = true if form.index == form.fields.size - 3
      f = []
      for t in forumtags(forumclasses[form.fields[-3].index])
        f.push(ListBox.new([p_("Forum", "No tag value")] + t[2..-1], t[1], 0))
      end
      if type == 1
        fields[1].timelimit = forumclasses[form.fields[-3].index].group.audiolimit
      end
      if forumclasses[form.fields[-3].index].group.preventpolls
        form.hide(4)
        form.hide(3)
      else
        form.show(4)
        form.show(3)
      end
      if forumclasses[form.fields[-3].index].group.preventattachments
        form.hide(6)
        form.hide(5)
      else
        form.show(6)
        form.show(5)
      end
      fields[7...-4] = f
      form.index = form.fields.size - 3 if tin
    }
    form.fields[-3].trigger(:move)
    polls = []
    files = []
    loop do
      loop_update
      if type == 0
        if (form.fields[0].text != "" and form.fields[1].text != "")
          form.fields[-2] = Button.new(p_("Forum", "Send"))
        else
          form.fields[-2] = nil
        end
      elsif type == 1
        if form.fields[1].empty?
          form.fields[-2] = nil
        else
          form.fields[-2] = Button.new(p_("Forum", "Send"))
        end
      end
      form.update
      if (enter or space) and form.index == 4 and polls.size < 3
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
            ind = selector(names, p_("Forum", "Poll to attach"), 0, -1)
            if ind == -1
              form.focus
            else
              if polls.include?(ids[ind])
                alert(p_("Forum", "This poll has already been added"))
              else
                polls.push(ids[ind])
                form.fields[3] ||= ListBox.new([], p_("Forum", "Polls"))
                form.fields[3].options.push(names[ind])
                alert(p_("Forum", "Poll has been added"))
              end
            end
          else
            alert(p_("Forum", "You haven't created any polls yet."))
          end
        else
          alert(_("Error"))
        end
        loop_update
      end
      if form.index == 3 and $key[0x2e]
        play("editbox_delete")
        polls.delete_at(form.fields[3].index)
        form.fields[3].options.delete_at(form.fields[3].index)
        form.fields[3].index -= 1 if form.fields[3].index > 0
        if polls.size == 0
          form.fields[3] = nil
          form.index = 4
          form.focus
        else
          form.fields[3].say_option
        end
      end
      if (enter or space) and form.index == 6 and files.size < 3
        l = get_file(p_("Forum", "Select file to attach"), Dirs.documents + "\\")
        if l != "" and l != nil
          if files.include?(l)
            alert(p_("Forum", "This file has been already attached"))
          else
            if File.size(l) > 16777216
              alert(p_("Forum", "This file is too large"))
            else
              files.push(l)
              form.fields[5] ||= ListBox.new([], p_("Forum", "Attachments"))
              form.fields[5].options.push(File.basename(l))
              alert(p_("Forum", "The file has been attached"))
            end
          end
        else
          form.focus
        end
        loop_update
      end
      if form.index == 5 and $key[0x2e]
        play("editbox_delete")
        files.delete_at(form.fields[5].index)
        form.fields[5].options.delete_at(form.fields[5].index)
        form.fields[5].index -= 1 if form.fields[5].index > 0
        if files.size == 0
          form.fields[5] = nil
          form.index = 6
          form.focus
        else
          form.fields[5].say_option
        end
      end
      if type == 0
        if ($key[0x11] and enter) or (form.fields[-2] != nil && form.fields[-2].pressed?)
          play("listbox_select")
          text = form.fields[1].text
          break
        end
      else
        if form.fields[-2] != nil && form.fields[-2].pressed?
          break
        end
      end
      if escape or form.fields[-1].pressed?
        if (!form.fields[1].is_a?(EditBox) && form.fields[1].delete_audio) or (form.fields[1].is_a?(EditBox) && (form.fields[1].text == "" || confirm(p_("Forum", "Are you sure you want to cancel creating this thread?")) == 1))
          loop_update
          return
          break
        end
      end
    end
    return if ![1, 2].include?(forumclasses[form.fields[-3].index].group.role) and !canjoin(forumclasses[form.fields[-3].index].group)
    name = ""
    for f in form.fields[7...-4]
      if f.index > 0
        name += "[" + f.options[f.index] + "] "
      end
    end
    name += form.fields[0].text
    form.fields[0].set_text(name)
    if type == 0
      post = {}
      if text.size < 1024
        post["post"] = text
      else
        post["zs_post"] = zstd_compress(text)
      end
      format = 0
      format = form.fields[2].checked if form.fields[2] != nil
      prm = { "forumname" => forumclasses[form.fields[-3].index].name, "threadname" => form.fields[0].text, "format" => format }
      prm["follow"] = "1" if form.fields[-4].checked == 1
      if polls.size > 0
        pls = ""
        for i in 0...polls.size
          pls += "," if i > 0
          pls += polls[i].to_s
        end
        prm["polls"] = pls
      end
      if files.size > 0
        atts = ""
        for f in files
          atts += send_attachment(f) + ","
        end
        atts.chop! if atts[-1..-1] == ","
        prm["bufatt"] = buffer(atts).to_s
      end
      ft = srvproc("forum_edit", prm, 0, post)
    else
      fl = form.fields[1].get_file
      flp = readfile(fl)
      if flp[0..3] != "OggS"
        alert(_("Error"))
        return $scene = Scene_Main.new
      end
      flp = readfile(fl)
      if flp[0..3] != "OggS"
        alert(_("Error"))
        return $scene = Scene_Main.new
      end
      boundary = ""
      boundary = "----EltBoundary" + rand(36 ** 32).to_s(36) while flp.include?(boundary)
      data = "--" + boundary + "\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{flp}\r\n--#{boundary}--"
      length = data.size
      host = $srv.delete("/")
      prm = { "forumname" => forumclasses[form.fields[-3].index].name, "threadname" => form.fields[0].text, "audio" => 1 }
      prm["follow"] = "1" if form.fields[-4].checked == 1
      ft = srvproc("forum_edit", prm, 0, { "post" => flp })
      form.fields[1].delete_audio(true)
    end
    if ft[0].to_i == 0
      alert(p_("Forum", "Thread has been created."))
    else
      alert(p_("Forum", "Error creating thread!"))
    end
  end

  def getcache
    self.class.getcache
    @groups, @forums, @threads = @@groups, @@forums, @@threads
  end

  def self.getcache
    params = { "useflags" => 1, "zs" => 1, "ident" => "_" }
    params["ident"] = @@lastCacheIdent if @@lastCacheIdent != nil && @@lastCacheTime || 0 > Time.now.to_f - 900
    c = srvproc("forum_struct", params, 1)
    if c[0..0] == "-"
      alert(_("Error"))
      @@groups = []
      @@forums = []
      @@threads = []
      return
    end
    ident = c[3...43]
    if @@lastCacheIdent == ident
      c = @@lastCache
    else
      @@lastCache = c
      @@lastCacheIdent = ident
      @@lastCacheTime = Time.now.to_f
    end
    @@groups = []
    @@forums = []
    @@threads = []
    ch = zstd_decompress(c[45..-1]).split("\r")
    l = 0
    while l < ch.size
      objs = ch[l + 1].to_i
      strobjs = ch[l + 2].to_i
      if ch[l] == "groups"
        self.groupscache(ch[(l + 3)..(l + 3 + objs * strobjs)], objs, strobjs)
      elsif ch[l] == "forums"
        self.forumscache(ch[(l + 3)..(l + 3 + objs * strobjs)], objs, strobjs)
      elsif ch[l] == "threads"
        self.threadscache(ch[(l + 3)..(l + 3 + objs * strobjs)], objs, strobjs)
      end
      l += 3 + objs * strobjs
    end
  rescue Exception
    alert(_("Error"))
    @@groups = []
    @@forums = []
    @@threads = []
  end

  def self.groupscache(c, objs, strobjs)
    @@groups = []
    for i in 0...objs
      for j in 0...strobjs
        line = c[i * strobjs + j]
        case j
        when 0
          @@groups.push(Struct_Forum_Group.new(line.to_i))
        when 1
          @@groups.last.name = line
        when 2
          @@groups.last.founder = line
        when 3
          @@groups.last.description = line.gsub("$", "\r\n")
        when 4
          @@groups.last.lang = line
        when 5
          @@groups.last.recommended = true if (line.to_i & 1) > 0
          @@groups.last.open = true if (line.to_i & 2) > 0
          @@groups.last.public = true if (line.to_i & 4) > 0
        when 6
          @@groups.last.role = line.to_i
        when 7
          @@groups.last.forums = line.to_i
        when 8
          @@groups.last.threads = line.to_i
        when 9
          @@groups.last.posts = line.to_i
        when 10
          @@groups.last.readposts = line.to_i
        when 11
          @@groups.last.acmembers = line.to_i
          @@groups.last.name + ": " + @@groups.last.acmembers.to_s
        when 12
          @@groups.last.created = line.to_i
        when 13
          @@groups.last.hasregulations = line.to_b
        when 14
          @@groups.last.hasmotd = line.to_b
        when 15
          @@groups.last.hasnewmotd = line.to_b
        when 16
          @@groups.last.preventpolls = line.to_b
        when 17
          @@groups.last.preventattachments = line.to_b
        when 18
          @@groups.last.allowpostreporting = line.to_b
        when 19
          @@groups.last.audiolimit = line.to_i
        when 20
          @@groups.last.blog = line
        when 21
          @@groups.last.showpostreports = line.to_i
        when 22
          @@groups.last.parent = line.to_i
        when 23
          @@groups.last.applyglobalbans = line.to_b
        when 24
          @@groups.last.hidden = line.to_b
        end
      end
    end
  end

  def self.forumscache(c, objs, strobjs)
    groupids = {}
    @@groups.each { |g| groupids[g.id] = g }
    @@forums = []
    for i in 0...objs
      for j in 0...strobjs
        line = c[i * strobjs + j]
        case j
        when 0
          @@forums.push(Struct_Forum_Forum.new(line))
        when 1
          @@forums.last.fullname = line
        when 2
          @@forums.last.type = line.to_i
        when 3
          @@forums.last.group = groupids[line.to_i]
        when 4
          @@forums.last.description = line.gsub("$", "\r\n")
        when 5
          @@forums.last.closed = true if (line.to_i & 1) > 0
          @@forums.last.followed = true if (line.to_i & 2) > 0
        when 6
          @@forums.last.threads = line.to_i
        when 7
          @@forums.last.posts = line.to_i
        when 8
          @@forums.last.readposts = line.to_i
        end
      end
    end
  end

  def self.threadscache(c, objs, strobjs)
    forumids = {}
    @@forums.each { |f| forumids[f.id] = f }
    @@threads = []
    for i in 0...objs
      for j in 0...strobjs
        line = c[i * strobjs + j]
        case j
        when 0
          @@threads.push(Struct_Forum_Thread.new(line.to_i))
        when 1
          @@threads.last.name = line
        when 2
          @@threads.last.author = line
        when 3
          @@threads.last.forum = forumids[line]
        when 4
          @@threads.last.posts = line.to_i
        when 5
          @@threads.last.readposts = line.to_i
        when 6
          @@threads.last.pinned = true if (line.to_i & 1) > 0
          @@threads.last.closed = true if (line.to_i & 2) > 0
          @@threads.last.followed = true if (line.to_i & 4) > 0
          @@threads.last.marked = true if (line.to_i & 8) > 0
        when 7
          @@threads.last.lastupdate = line.to_i
        when 8
          @@threads.last.offered = line.to_i
        end
      end
    end
  end

  def getstruct
    getcache
    return { "groups" => @groups, "forums" => @forums, "threads" => @threads }
  end

  def self.getstruct
    self.getcache
    return { "groups" => @@groups, "forums" => @@forums, "threads" => @@threads }
  end

  def usequery
    ids = []
    @results = []
    if @query != "" and @query.is_a?(String)
      sr = srvproc("forum_search", { "query" => @query })
      if sr[0].to_i < 0
        alert(_("Error"))
      else
        t = 0
        for l in sr[2..sr.size - 1]
          if t == 0
            thread = @threads.find { |t| t.id == l }
            @results.push(thread.id) if thread != nil
            t = 1
          else
            t = 0
          end
        end
      end
    elsif @query.is_a?(Struct_Forum_SearchQuery)
      if @query.phrase_in.include?(:content)
        sr = srvproc("forum_search", { "query" => @query.phrase, "transcriptions" => (@query.transcriptions) ? (1) : (0) })
        if sr[0].to_i < 0
          alert(_("Error"))
        else
          t = 0
          if sr.size > 2
            for l in sr[2..sr.size - 1]
              if t == 0
                ids.push(l.to_i)
                t = 1
              else
                t = 0
              end
            end
          end
        end
      end
      if @query.phrase_in.include?(:author)
        sr = srvproc("forum_search", { "query" => @query.phrase, "type" => "author" })
        if sr[0].to_i < 0
          alert(_("Error"))
        else
          t = 0
          if sr.size > 2
            for l in sr[2..sr.size - 1]
              if t == 0
                ids.push(l.to_i)
                t = 1
              else
                t = 0
              end
            end
          end
        end
      end
      phr = @query.phrase.downcase
      @results = @threads.map { |thread|
        suc_th = false
        suc_se = false
        suc_se = true if @query.phrase_in.include?(:name) && (phr == "" || thread.name.downcase.include?(phr))
        suc_se = true if ids.include?(thread.id)
        suc_th = true if @query.thread_in.include?(:joined) && (thread.forum.group.role == 1 || thread.forum.group.role == 2)
        suc_th = true if @query.thread_in.include?(:recommended) && thread.forum.group.recommended
        suc_th = true if @query.thread_in.include?(:notjoined) && (thread.forum.group.role != 1 && thread.forum.group.role != 2)
        suc_th = true if @query.groupid == thread.forum.group.id
        suc_th = true if @query.forumid == thread.forum.name
        if suc_se && suc_th
          thread.id
        else
          nil
        end
      }.compact
    elsif @query.is_a?(Struct_Forum_Group)
      @threads.each { |t| @results.push(t.id) if t.forum.group.id == @query.id }
    else
      @threads.each { |t| @results.push(t.id) }
    end
  end
end

class Scene_Forum_Thread
  def initialize(thread, param = nil, cat = 0, query = "", mention = nil, scene = nil, tag = nil)
    @threadclass = thread
    @param = param
    @cat = cat
    @query = query
    @mention = mention
    @scene = scene
    @tag = tag
    srvproc("mentions", { "notice" => "1", "id" => mention.id }) if mention != nil
  end

  def main
    if @threadclass.is_a?(Integer)
      Scene_Forum.getstruct["threads"].each { |t|
        @threadclass = t if t.id == @threadclass
      }
    end
    @thread = @threadclass.id
    if Session.name == "guest"
      @noteditable = true
    elsif @threadclass.closed
      @noteditable = true
    else
      @noteditable = false
      @noteditable = true if (![1, 2].include?(@threadclass.forum.group.role) and @threadclass.forum.group.open == false) or @threadclass.forum.group.role == 3
    end
    refresh
    return $scene = Scene_Main.new if @form == nil
    loop do
      loop_update
      @form.update
      if @noteditable == false
        case @posttype
        when 0
          textsendupdate
        when 1
          audiosendupdate
        end
      end
      if escape or @form.fields[-1].pressed?
        if @posttype != 0 or (@form.fields[@postscount * 3 + 1] == nil or @form.fields[@postscount * 3 + 1].text == "") or confirm(p_("Forum", "Are you sure you want to cancel creating this post?")) == 1
          r = true
          f = @form.fields[@form.fields.size - 8]
          r = f.delete_audio if @posttype == 1 && f != nil
          if r == true
            speech_stop
            if @scene == nil
              $scene = Scene_Forum.new(@thread, @param, @cat, @query, @threadclass, @tag)
            else
              $scene = @scene
            end
            return
          end
        end
      end
      if enter and @form.index < @postscount * 3 and @form.index % 3 == 1
        pl = @posts[@form.index / 3].polls[@form.fields[@form.index].index]
        voted = false
        voted = true if srvproc("polls", { "voted" => "1", "poll" => pl.to_s })[1].to_i == 1
        selt = [p_("Polls", "Vote"), p_("Polls", "Show results"), p_("Polls", "Show report")]
        selt[0] = nil if voted || isbanned(Session.name) || Session.name == "guest"
        case menuselector(selt)
        when 0
          insert_scene(Scene_Polls_Answer.new(pl.to_i, Scene_Main.new))
        when 1
          insert_scene(Scene_Polls_Results.new(pl.to_i, Scene_Main.new))
        when 2
          insert_scene(Scene_Polls_Report.new(pl.to_i, Scene_Main.new))
        end
        loop_update
        @form.focus
      end
      if enter and @form.index < @postscount * 3 and @form.index % 3 == 2
        fl = @posts[@form.index / 3].attachments[@form.fields[@form.index].index]
        process_attachment(fl)
        @form.focus
        loop_update
      end
      if ((space or enter) and @form.index == @fields.size - 2) and @attachments.size < 3
        l = get_file(p_("Forum", "Select file to attach"), Dirs.documents + "\\")
        if l != "" and l != nil
          if @attachments.include?(l)
            alert(p_("Forum", "This file has been already attached"))
          else
            if File.size(l) > 16777216
              alert(p_("Forum", "This file is too large"))
            else
              @attachments.push(l)
              @form.fields[@form.fields.size - 3] ||= ListBox.new([], p_("Forum", "Attachments"))
              @form.fields[@form.fields.size - 3].options.push(File.basename(l))
              alert(p_("Forum", "The file has been attached"))
            end
          end
        else
          @form.focus
        end
        loop_update
      end
      if @form.index == @form.fields.size - 3 and $key[0x2e]
        play("editbox_delete")
        @attachments.delete_at(@form.fields[@form.fields.size - 3].index)
        @form.fields[@form.fields.size - 3].options.delete_at(@form.fields[@form.fields.size - 3].index)
        @form.fields[@form.fields.size - 3].index -= 1 if @form.fields[@form.fields.size - 3].index > 0
        if @attachments.size == 0
          @form.fields[@form.fields.size - 3] = nil
          @form.index = @form.fields.size - 2
          @form.focus
        else
          @form.fields[@form.fields.size - 3].say_option
        end
      end
      break if $scene != self
    end
  end

  def groupregulations
    g = srvproc("forum_groups", { "ac" => "regulations", "groupid" => @threadclass.forum.group.id })
    if g[0].to_i == 0
      return g[1..-1].join
    else
      return ""
    end
  end

  def canjoin
    return true if !@threadclass.forum.group.hasregulations
    regs = groupregulations
    fields = [
      EditBox.new(p_("Forum", "Regulations of group %{groupname}") % { "groupname" => @threadclass.forum.group.name }, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, regs),
      Button.new(p_("Forum", "I accept regulations of group %{groupname}") % { "groupname" => @threadclass.forum.group.name }),
      Button.new(p_("Forum", "I decline regulations of group %{groupname}") % { "groupname" => @threadclass.forum.group.name })
    ]
    form = Form.new(fields)
    loop do
      loop_update
      form.update
      if escape or form.fields[2].pressed?
        loop_update
        return false
      end
      if form.fields[1].pressed?
        loop_update
        return true
      end
    end
  end

  def refresh
    pretext = ""
    pretext = @textfields[0].text if @textfields != nil
    lastindex = nil
    lastindex = @form.index if @form != nil
    index = -1
    getcache
    tsponsors = srvproc("admins", { "cat" => "sponsors" })
    @sponsors = []
    for i in 1...tsponsors.size
      @sponsors.push(tsponsors[i].delete("\r\n"))
    end
    @fields = []
    return if @posts == nil
    for i in 0...@posts.size
      post = @posts[i]
      index = i * 3 if index == -1 and @param == -3 and @query.is_a?(Struct_Forum_SearchQuery) and post.post.downcase.include?(@query.phrase.downcase) && @query.phrase_in.include?(:content)
      index = i * 3 if index == -1 and @param == -3 and @query.is_a?(Struct_Forum_SearchQuery) and post.transcription.downcase.include?(@query.phrase.downcase) && @query.phrase_in.include?(:content) && @query.transcriptions
      index = i * 3 if index == -1 and @param == -3 and @query.is_a?(Struct_Forum_SearchQuery) and post.author.downcase == @query.phrase.downcase && @query.phrase_in.include?(:author)
      index = i * 3 if @mention != nil and (@param == -7 or @param == -11) and post.id == @mention.post
      index = i * 3 if index == -1 and @param == -13 and @query.is_a?(Numeric) and @query == post.id
      flags = EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly
      flags |= EditBox::Flags::MarkDown if post.format == 1
      flags |= EditBox::Flags::Transcripted if post.transcription.strip != ""
      label = post.authorname
      label += " (#{p_("Forum", "Banned")})" if post.banned
      label += " (#{p_("Forum", "Account archived")})" if post.archived
      @fields += [EditBox.new(label, flags, generate_posttext(post), true), nil, nil]
      if @sponsors.include?(post.author)
        @fields[-3].add_sound("user_sponsor")
      end
      @fields[-1] = ListBox.new(name_attachments(post.attachments), p_("Forum", "Attachments")) if post.attachments.size > 0
      if post.polls.size > 0
        names = []
        for o in post.polls
          pl = srvproc("polls", { "get" => "1", "poll" => o.to_s })
          names.push(pl[2].delete("\r\n")) if pl[0].to_i == 0 and pl.size > 1
        end
        @fields[-2] = ListBox.new(names, p_("Forum", "Polls")) if names.size == post.polls.size
      end
    end

    index = 0 if index == -1
    index = @lastpostindex if @lastpostindex != nil
    index = 0 if index > @fields.size
    @type = @threadclass.forum.type
    @posttype = 0
    @posttype = 1 if @type == 1
    if @type == 2
      sel = ListBox.new([p_("Forum", "Text post"), p_("Forum", "Audio post")], p_("Forum", "Post type"))
      sel.on(:move) { |i|
        if @noteditable == false
          @posttype = sel.index
          @fields[(-1 - @audiofields.size)..-2] = ((@posttype == 0) ? @textfields : @audiofields)
        end
      }
      @fields.push(sel)
    else
      @fields.push(nil)
    end
    @textfields = [EditBox.new(p_("Forum", "Your reply"), EditBox::Flags::MultiLine, pretext, true), nil, nil, nil, nil, nil, Button.new(p_("Forum", "Attach a file"))]
    @textfields[3] = CheckBox.new(p_("Forum", "Use MarkDown in this post"))
    @textfields[3].on(:change) {
      @textfields[3].checked = 0 if !requires_premiumpackage("courier")
    }
    @audiofields = [OpusRecordButton.new(p_("Forum", "Audio post"), Dirs.temp + "\\audiopost.opus", 96, 48, @threadclass.forum.group.audiolimit), nil, nil, nil, nil, nil, nil]
    if @noteditable == false
      case @posttype
      when 0
        @fields += @textfields
      else
        @fields += @audiofields
      end
    else
      @fields += [nil, nil, nil, nil, nil, nil, nil]
    end
    @fields.push(Button.new(p_("Forum", "Return")))
    index = lastindex if lastindex != nil && index < @form.fields.size
    @attachments = []
    @form = Form.new(@fields, index)
    @form.hide(@fields.size - 2) if @threadclass.forum.group.preventattachments
    @form.bind_context(p_("Forum", "Forum")) { |menu| context(menu) }
  end

  def generate_posttext(post)
    add = ""
    i = @posts.find_index(post) || 0
    if post.edited
      add = "\r\n" + p_("Forum", "This post has been edited")
    end
    ppost = post.post
    if post.transcription.strip != ""
      ppost += "\n" + post.transcription + "\n"
    end
    return ppost + ((post.likes > 0) ? (np_("Forum", "%{count} user likes this post", "%{count} users like this post", post.likes) % { "count" => post.likes.to_s } + "\n") : ("")) + ((LocalConfig["ForumHideSignatures"] == 1 && holds_premiumpackage("courier")) ? ("") : (post.signature)) + post.date + add + "\r\n" + (i + 1).to_s + "/" + @posts.size.to_s
  end

  def textsendupdate
    if @form.fields[@postscount * 3 + 1].text == "" and @form.fields[@postscount * 3 + 3] != nil
      @form.fields[@postscount * 3 + 3] = nil
    elsif @form.fields[@postscount * 3 + 1].text != "" and @form.fields[@postscount * 3 + 3] == nil
      @form.fields[@postscount * 3 + 3] = Button.new(p_("Forum", "Send"))
    end
    if (@form.fields[@postscount * 3 + 3] != nil && @form.fields[@postscount * 3 + 3].pressed?) or (enter and $key[0x11] and @form.index == @postscount * 3 + 1)
      return if ![1, 2].include?(@threadclass.forum.group.role) and !canjoin
      post = {}
      text = @form.fields[@postscount * 3 + 1].text
      if text.size < 1024
        post["post"] = text
      else
        post["zs_post"] = zstd_compress(text)
      end
      prm = { "threadid" => @thread.to_s }
      if @attachments.size > 0
        atts = ""
        for f in @attachments
          atts += send_attachment(f) + ","
        end
        atts.chop! if atts[-1..-1] == ","
        prm["bufatt"] = buffer(atts).to_s
      end
      if @form.fields[@postscount * 3 + 4] != nil
        prm["format"] = @form.fields[@postscount * 3 + 4].checked
      end
      st = srvproc("forum_edit", prm, 0, post)
      if st[0].to_i < 0
        alert(_("Error"))
      else
        @form.fields[@postscount * 3 + 1].set_text("")
        alert(p_("Forum", "The post was created."))
      end
      return main
    end
  end

  def audiosendupdate
    if @form.fields[@form.fields.size - 8].empty? && @form.fields[@form.fields.size - 6] != nil
      @form.fields[@form.fields.size - 6] = nil
    elsif !@form.fields[@form.fields.size - 8].empty? && @form.fields[@form.fields.size - 6] == nil
      @form.fields[@form.fields.size - 6] = Button.new(p_("Forum", "Send"))
    end
    if @form.fields[@form.fields.size - 6] != nil && @form.fields[@form.fields.size - 6].pressed?
      return if ![1, 2].include?(@threadclass.forum.group.role) and !canjoin
      f = @form.fields[@form.fields.size - 8]
      file = f.get_file
      fl = readfile(file)
      if fl[0..3] != "OggS"
        alert(_("Error"))
        return $scene = Scene_Main.new
      end
      params = { "threadid" => @thread, "audio" => 1 }
      ft = srvproc("forum_edit", params, 0, { "post" => fl })
      if ft[0].to_i == 0
        f.delete_audio(true)
        alert(p_("Forum", "The post was created."))
        return main
      else
        alert(p_("Forum", "Post creation failure."))
      end
    end
  end

  def context(menu)
    if @form.index < @postscount * 3 && @posts[@form.index / 3] != nil
      menu.useroption(@posts[@form.index / 3].authorname)
    end
    if @threadclass.mention != nil
      menu.submenu(p_("Forum", "Received mention")) { |m|
        m.option(p_("Forum", "Show mention"), nil, "/") {
          input_text(p_("Forum", "Mention by %{user}") % { "user" => @threadclass.mention.author }, EditBox::Flags::ReadOnly, @threadclass.mention.message, true)
        }
        m.option(p_("Forum", "Send reply to mentioner"), nil, "?") {
          if requires_premiumpackage("courier")
            to = @threadclass.mention.author
            subj = "RE: " + @threadclass.mention.message.to_s + " (" + @threadclass.name + ")"
            insert_scene(Scene_Messages_New.new(to, subj, "", Scene_Main.new))
          end
        }
      }
    end
    if @form.index < @postscount * 3 and !@noteditable
      menu.submenu(p_("Forum", "Reply")) { |m|
        m.option(p_("Forum", "Reply"), nil, "n") {
          @form.index = @postscount * 3 + ((@type == 2) ? 0 : 1)
          @form.focus
        }
        if (@type == 0 || @type == 2) and @form.fields[@postscount * 3 + 1].is_a?(EditBox) and !@posts[@form.index / 3].post.include?("\004AUDIO\004")
          m.option(p_("Forum", "Reply with quote"), nil, "d") {
            @form.fields[@postscount * 3 + 1].set_text("\r\n-- (#{@posts[@form.index / 3].authorname}):\r\n#{@posts[@form.index / 3].post}\r\n--\r\n#{@form.fields[@postscount * 3 + 1].text}")
            @form.fields[@postscount * 3 + 1].index = 0
            @form.index = @postscount * 3 + 1
            @form.focus
          }
        end
      }
    end
    if @form.index < @postscount * 3
      post = @posts[@form.index / 3]
      if @threadclass != nil && @threadclass.forum.group.role != 3
        s = p_("Forum", "Like this post")
        s = p_("Forum", "Dislike this post") if post.liked == true
        menu.option(s, nil, "k") {
          ac = { "ac" => "liking", "postid" => post.id, "threadid" => @thread }
          ac["like"] = (post.liked) ? (0) : (1)
          s = srvproc("forum_postaction", ac)
          if s[0].to_i < 0
            alert(_("Error"))
          else
            post.liked = !post.liked
            if post.liked
              alert(p_("Forum", "This post is now liked"))
              post.likes += 1
            else
              post.likes -= 1
              alert(p_("forum", "This post is no longer liked"))
            end
            @form.fields[@form.index / 3 * 3].set_text(generate_posttext(post))
          end
        }
      end
      menu.option(p_("Forum", "Show post likes"), nil, "K") {
        ft = srvproc("forum_postaction", { "ac" => "likes", "postid" => post.id })
        users = []
        if ft[0].to_i == 0
          for i in 0...ft[1].to_i
            user = ft[2 + i].delete("\r\n")
            users.push(user)
          end
        end
        lst = ListBox.new(users, p_("Forum", "Users who like this post"), 0, 0, false)
        loop do
          loop_update
          lst.update
          break if escape
          if (alt or enter) and users.size > 0
            usermenu(users[lst.index])
          end
        end
        @form.focus
      }
      if post.edited && !post.locked
        menu.option(p_("Forum", "Show original post")) {
          ps = srvproc("forum_postaction", { "threadid" => @thread, "postid" => post.id, "ac" => "getorig" })
          if ps[0].to_i == 0
            input_text(p_("Forum", "Original post"), EditBox::Flags::ReadOnly | EditBox::Flags::MultiLine, ps[1..-1].join)
          end
        }
      end
      if @threadclass.forum.group.allowpostreporting
        menu.option(p_("Forum", "Report this post")) {
          postreport(post)
          @form.focus
        }
      end
    end
    menu.submenu(p_("Forum", "Navigation")) { |m|
      m.option(p_("Forum", "Bookmarks"), nil, "b") {
        if requires_premiumpackage("courier")
          showbookmarks
        end
      }
      m.option(p_("Forum", "Go to post"), nil, "j") {
        selt = []
        for i in 0..@posts.size - 1
          selt.push((i + 1).to_s + " / " + @postscount.to_s + ": " + @posts[i].author)
        end
        @form.index = selector(selt, p_("Forum", "Select post"), @form.index / 3, @form.index / 3) * 3
        @form.focus
      }
      m.option(p_("Forum", "Go to post number"), nil, "J") {
        pst = input_text(p_("Forum", "Type post number"), EditBox::Flags::Numbers, (@form.index / 3 + 1).to_s, true)
        if pst != nil and pst.to_i <= @posts.size and pst.to_i > 0
          @form.index = (pst.to_i - 1) * 3
          @form.focus
        end
      }
      if @type != 1
        m.option(p_("Forum", "Search in thread"), nil, "F") {
          search = input_text(p_("Forum", "Enter a phrase to look for"), 0, "", true)
          if search != nil
            selt = []
            sr = []
            ind = -1
            for i in 0..@posts.size - 1
              if @posts[i].post.downcase.include?(search.downcase)
                selt.push((i + 1).to_s + ": " + @posts[i].author)
                sr.push(i)
                ind = selt.size - 1 if i >= @form.index and ind == -1
              end
            end
            ind = 0 if ind == -1
            if selt.size > 0
              ind = selector(selt, p_("Forum", "Select post"), ind, -1)
              @form.index = sr[ind] * 3 if ind != -1
              @form.focus
            else
              alert(p_("Forum", "The entered phrase cannot be found."))
            end
          end
        }
      end
      m.option(p_("Forum", "Go to first post"), nil, ",") {
        @form.index = 0
        @form.focus
      }
      m.option(p_("Forum", "Go to last post"), nil, ".") {
        @form.index = @postscount * 3 - 3
        @form.focus
      }
      if @readposts < @postscount && @readposts >= 0
        m.option(p_("Forum", "Go to first new post"), nil, "u") {
          @form.index = @readposts * 3
          @form.focus
        }
      end
    }
    if @form.index < @postscount * 3 && Session.name != "guest"
      menu.option(p_("Forum", "Mention post"), nil, "w") {
        mention(@thread, @posts[@form.index / 3].id)
      }
    end
    if @form.index < @posts.size * 3
      if @type != 2
        menu.option(p_("Forum", "Listen to the thread")) {
          if Configuration.voice == "NVDA" and @type == 0
            text = ""
            for pst in @posts[@form.index / 3..@posts.size]
              text += pst.author + "\r\n" + pst.post + "\r\n" + pst.date + "\r\n\r\n"
            end
            speech(text)
          else
            cur = @form.index / 3 - 1
            while cur < @posts.size
              loop_update
              if speech_actived == false and Win32API.new($eltenlib, "SapiIsPaused", "", "i").call == 0
                cur += 1
                play("signal")
                pst = @posts[cur]
                speech("#{(cur + 1).to_s}: " + pst.author + ":\r\n" + pst.post) if pst != nil
              end
              if (arrow_right and !$keyr[0x10])
                speech_stop
                cur = @posts.size - 2 if cur > @posts.size - 2
              end
              if (arrow_left and !$keyr[0x10])
                speech_stop
                cur -= 2
                cur = -1 if cur < -1
              end
              if space
                if Win32API.new($eltenlib, "SapiIsPaused", "", "i").call == 0
                  Win32API.new($eltenlib, "SapiSetPaused", "i", "i").call(1)
                else
                  Win32API.new($eltenlib, "SapiSetPaused", "i", "i").call(0)
                end
              end
              if escape
                speech_stop
                break
              end
            end
            loop_update
            @form.focus
          end
        }
      end
    end
    s = p_("Forum", "Mark this thread")
    s = p_("Forum", "Unmark this thread") if @threadclass.marked == true
    menu.option(s, nil, "h") {
      if requires_premiumpackage("courier")
        m = 0
        m = 1 if @threadclass.marked == false
        if srvproc("forum_threadaction", { "ac" => "marking", "mark" => m, "threadid" => @thread })[0].to_i < 0
          alert(_("Error"))
        else
          if m == 0
            alert(p_("Forum", "Thread unmarked"))
          else
            alert(p_("Forum", "Thread marked"))
          end
          @threadclass.marked = !@threadclass.marked
        end
      end
    }
    s = p_("Forum", "Add to followed threads list")
    s = p_("Forum", "Unfollow this thread") if @followed == true
    menu.option(s, nil, "l") {
      if @followed == false
        if srvproc("forum_ft", { "add" => "1", "thread" => @thread })[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Forum", "Added to the list of followed threads."))
          @followed = true
        end
      else
        if srvproc("forum_ft", { "remove" => "1", "thread" => @thread })[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Forum", "Removed from followed threads list."))
          @followed = false
        end
      end
    }
    s = p_("Forum", "Hide signatures")
    s = p_("Forum", "Show signatures") if LocalConfig["ForumHideSignatures"] == 1
    menu.option(s) {
      if requires_premiumpackage("courier")
        if LocalConfig["ForumHideSignatures"] == 0
          LocalConfig["ForumHideSignatures"] = 1
        else
          LocalConfig["ForumHideSignatures"] = 0
        end
        refresh
      end
    }
    if @form.index < @postscount * 3 && (((Session.moderator == 1 && @threadclass.forum.group.recommended) || (@threadclass != nil && @threadclass.forum.group.role == 2)) || (@posts[@form.index / 3].author == Session.name && @threadclass.forum.group.role == 1))
      post = @posts[@form.index / 3]
      menu.submenu(p_("Forum", "Moderation")) { |m|
        if !post.post.include?("\004AUDIO\004")
          if !post.locked
            m.option(p_("Forum", "Edit post"), nil, "e") {
              edit_post(@posts[@form.index / 3])
            }
          end
        end
        if Session.moderator == 1 or @threadclass.forum.group.role == 2
          m.option(p_("Forum", "Move post"), nil, "O") {
            @struct = Scene_Forum.new.getstruct
            @groups = @struct["groups"]
            @forums = @struct["forums"]
            @threads = @struct["threads"]
            groups = []
            for group in @groups
              groups[group.id] = group.name
            end
            forums = {}
            selt = []
            fthreads = []
            hthreads = []
            curr = 0
            for t in @threads
              if t.forum.group.role == 2 or (Session.moderator == 1 and t.forum.group.recommended)
                if t.forum.group.id == @threadclass.forum.group.id
                  hthreads.push(t)
                else
                  fthreads.push(t)
                end
              end
            end
            mthreads = hthreads + fthreads
            for t in mthreads
              selt.push(t.name + " (" + t.forum.fullname + " (" + t.forum.group.name + ")" + ")")
              curr = selt.size - 1 if t.id == @thread
            end
            destination = selector(selt, p_("Forum", "Post destination"), curr, -1)
            if destination != -1
              if srvproc("forum_mod", { "move" => "2", "postid" => @posts[@form.index / 3].id, "destination" => mthreads[destination].id, "threadid" => @thread })[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "The post has been moved."))
                @lastpostindex = @form.index
                main
              end
            end
          }
          s = p_("Forum", "Lock post")
          s = p_("Forum", "Unlock post") if post.locked
          m.option(s) {
            prm = { "postid" => @posts[@form.index / 3].id, "threadid" => @thread, "locking" => 1 }
            if post.locked
              prm["locked"] = 0
            else
              prm["locked"] = 1
            end
            if srvproc("forum_mod", prm)[0].to_i == 0
              post.locked = !post.locked
              if post.locked
                alert(p_("Forum", "Post locked"))
              else
                alert(p_("Forum", "Post unlocked"))
              end
            else
              alert(_("Error"))
            end
          }
          m.option(p_("Forum", "Delete post"), nil, "-") {
            confirm(p_("Forum", "Are you sure you want to delete this post?")) do
              prm = ""
              if @posts.size == 1
                prm = { "threadid" => @thread, "delete" => 1 }
              else
                prm = { "postid" => @posts[@form.index / 3].id, "threadid" => @thread, "delete" => 2 }
              end
              ft = srvproc("forum_mod", prm)
              if ft[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "Are you sure you want to delete this post?"))
                if @posts.size == 1
                  if @scene == nil
                    $scene = Scene_Forum.new(@thread, @param, @cat, @query)
                  else
                    $scene = @scene
                  end
                else
                  @lastpostindex = @form.index
                  main
                end
              end
            end
          }
          m.option(p_("Forum", "Change post position")) {
            sels = []
            for post in @posts
              sels.push((sels.size + 1).to_s + ": " + post.author + ": " + post.date)
            end
            sels.push(p_("Forum", "Move to end"))
            dest = selector(sels, p_("Forum", "Place post above"), @form.index, -1)
            if dest != -1
              if srvproc("forum_mod", { "move" => 3, "source" => @posts[@form.index / 3].id, "destination" => ((dest < @posts.size) ? (@posts[dest].id) : (0)) })[0].to_i == 0
                alert(p_("Forum", "The post has been slided."))
              else
                alert(_("Error"))
              end
              main
            end
          }
        end
        m.option(p_("Forum", "Mass Actions"), nil, "\\") {
          moderation_mass_posts
        }
      }
    end
    menu.option(_("Refresh"), nil, "r") {
      refresh
    }
  end

  def moderation_mass_posts
    form = Form.new([
      lst_posts = ListBox.new(@posts.map { |ps| ps.author + ": " + ps.post[0...5000] }, p_("Forum", "Posts"), @form.index / 3, ListBox::Flags::MultiSelection),
      edt_post = EditBox.new(p_("Forum", "Post content"), EditBox::Flags::ReadOnly, ""),
      btn_move = Button.new(p_("Forum", "Move")),
      btn_delete = Button.new(p_("Forum", "Delete")),
      btn_cancel = Button.new(_("Cancel"))
    ])
    lst_posts.on(:move) { edt_post.set_text(@posts[lst_posts.index].post) }
    lst_posts.trigger(:move)
    form.cancel_button = btn_cancel
    btn_cancel.on(:press) {
      form.resume
      @form.focus
    }
    btn_move.on(:press) {
      selected = lst_posts.multiselections.map { |i| @posts[i] }
      if moderation_mass_posts_proceed(selected, :move)
        form.resume
        @lastpostindex = @form.index
        main
      else
        form.focus
      end
    }
    btn_delete.on(:press) {
      selected = lst_posts.multiselections.map { |i| @posts[i] }
      if moderation_mass_posts_proceed(selected, :delete)
        form.resume
        @lastpostindex = @form.index
        main
      else
        form.focus
      end
    }
    form.wait
  end

  def moderation_mass_posts_proceed(posts, action)
    if posts.size == 0
      alert(p_("Forum", "No posts selected"))
      return false
    end
    header = ""
    label = ""
    case action
    when :move
      header = np_("Forum", "%{count} post to move", "%{count} posts to move", posts.size) % { "count" => posts.size }
      label = p_("Forum", "Move")
    when :delete
      header = np_("Forum", "%{count} post to delete", "%{count} posts to delete", posts.size) % { "count" => posts.size }
      label = p_("Forum", "Delete")
    end
    form = Form.new([
      lst_posts = ListBox.new(posts.map { |ps| ps.author + ": " + ps.post[0...5000] }, header),
      edt_post = EditBox.new(p_("Forum", "Post content"), EditBox::Flags::ReadOnly, ""),
      btn_proceed = Button.new(label),
      btn_cancel = Button.new(_("Cancel"))
    ])
    lst_posts.on(:move) { edt_post.set_text(posts[lst_posts.index].post) }
    lst_posts.trigger(:move)
    ret = false
    form.cancel_button = btn_cancel
    btn_cancel.on(:press) { form.resume }
    btn_proceed.on(:press) {
      case action
      when :move
        @struct = Scene_Forum.new.getstruct
        @groups = @struct["groups"]
        @forums = @struct["forums"]
        @threads = @struct["threads"]
        groups = []
        for group in @groups
          groups[group.id] = group.name
        end
        forums = {}
        selt = []
        fthreads = []
        hthreads = []
        curr = 0
        for t in @threads
          if t.forum.group.role == 2 or (Session.moderator == 1 and t.forum.group.recommended)
            if t.forum.group.id == @threadclass.forum.group.id
              hthreads.push(t)
            else
              fthreads.push(t)
            end
          end
        end
        mthreads = hthreads + fthreads
        for t in mthreads
          selt.push(t.name + " (" + t.forum.fullname + " (" + t.forum.group.name + ")" + ")")
          curr = selt.size - 1 if t.id == @thread
        end
        destination = selector(selt, p_("Forum", "Post destination"), curr, -1)
        if destination != -1
          for post in posts
            srvproc("forum_mod", { "move" => "2", "postid" => post.id, "destination" => mthreads[destination].id, "threadid" => @thread })
          end
          alert(p_("Forum", "The posts have been moved."))
          ret = true
          form.resume
        end
      when :delete
        for post in posts
          prm = { "postid" => post.id, "threadid" => @thread, "delete" => 2 }
          srvproc("forum_mod", prm)
        end
        alert(p_("Forum", "The posts have been deleted."))
        ret = true
        form.resume
      end
    }
    form.wait
    return ret
  end

  def mention(thread, post)
    users = []
    us = srvproc("contacts_addedme", {})
    if us[0].to_i < 0
      alert(_("Error"))
      return
    end
    for u in us[1..us.size - 1]
      users.push(u.delete("\r\n"))
    end
    if users.size == 0
      alert(p_("Forum", "Nobody added you to their contact list."))
      return
    end
    fields = [
      lst_users = ListBox.new(users, p_("Forum", "Users to mention: "), 0, ListBox::Flags::MultiSelection),
      edt_message = EditBox.new(p_("Forum", "Message: "), 0, "", true),
      btn_mentionOK = Button.new(p_("Forum", "Mention")),
      btn_mentionCancel = Button.new(p_("Forum", "Cancel"))
    ]

    form = Form.new(fields)
    form.hide(btn_mentionOK)
    lst_users.on(:multiselection_changed) {
      if lst_users.multiselections.size <= 0
        form.hide(btn_mentionOK)
      else
        form.show(btn_mentionOK)
      end
    }
    btn_mentionOK.on(:press) {
      if lst_users.multiselections.size >= 0
        selections = lst_users.multiselections()
        control = 0
        for i in 0..selections.size - 1
          mt = srvproc("mentions", { "add" => "1", "user" => users[selections[i]], "message" => edt_message.text, "thread" => thread, "post" => post })
          control += mt[0].to_i
        end
        if control < 0
          alert(p_("Forum", "Error"))
        else
          alert(p_("Forum", "The mention has been sent."))
        end
        form.resume
      end
    }
    btn_mentionCancel.on(:press) { form.resume }
    form.accept_button = btn_mentionOK
    form.cancel_button = btn_mentionCancel
    form.wait
  end

  def postreport(post)
    form = Form.new([
      edt_comment = EditBox.new(p_("Forum", "Report comment"), EditBox::Flags::MultiLine, "", true),
      edt_post = EditBox.new(p_("Forum", "Reported post"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, post.author + ":\n" + post.post, true),
      btn_send = Button.new(p_("Forum", "Send post report")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    form.cancel_button = btn_cancel
    form.accept_button = btn_send
    btn_cancel.on(:press) { form.resume }
    btn_send.on(:press) {
      r = srvproc("forum_postaction", { "ac" => "report", "threadid" => @threadclass.id, "postid" => post.id, "buf_comment" => buffer(edt_comment.text) })
      if r[0].to_i < 0
        speak(_("Error"))
      else
        alert(p_("Forum", "Post report has been sent."))
        form.resume
      end
    }
    form.wait
  end

  def edit_post(post)
    dialog_open
    attnames = name_attachments(post.attachments)
    atts = []
    for i in 0...post.attachments.size
      a = post.attachments[i]
      atts.push([a, nil, attnames[i]])
    end
    form = Form.new([EditBox.new(p_("Forum", "edit your post here"), EditBox::Flags::MultiLine, post.post), ListBox.new(atts.map { |a| a[2] }, p_("Forum", "Attachments")), CheckBox.new(p_("Forum", "Use MarkDown in this post")), Button.new(_("Save")), Button.new(_("Cancel"))])
    form.fields[2].checked = post.format
    form.fields[2].on(:change) {
      form.fields[2].checked = post.format if !requires_premiumpackage("courier")
    }
    form.hide(1) if @threadclass.forum.group.preventattachments
    form.fields[1].bind_context { |menu|
      if atts.size < 3
        menu.option(p_("Forum", "Add attachment"), nil, "n") {
          l = get_file(p_("Forum", "Select file to attach"), Dirs.documents + "\\")
          if l != "" && l != nil && !atts.map { |a| a[1] }.include?(l)
            if File.size(l) <= 16777216
              atts.push([nil, l, File.basename(l)])
              form.fields[1].options = atts.map { |a| a[2] }
            else
              alert(p_("Forum", "This file is too large"))
            end
          end
          form.fields[1].focus
        }
      end
      if atts.size > 0
        menu.option(p_("Forum", "Delete attachment"), nil, :del) {
          atts.delete_at(form.fields[1].index)
          play("editbox_delete")
          form.fields[1].options = atts.map { |a| a[2] }
          form.fields[1].say_option
        }
      end
    }
    loop do
      loop_update
      form.update
      if form.fields[0].text.size > 1 and (((enter or space) and form.index == 3) or (enter and $key[0x11] and form.index < 3))
        pst = { "post" => form.fields[0].text }
        attachments = ""
        for a in atts
          if a[0] == nil
            attachments += send_attachment(a[1]) + ","
          else
            attachments += a[0] + ","
          end
        end
        attachments.chop! if attachments[-1..-1] == ","
        bufatt = buffer(attachments).to_s
        fe = srvproc("forum_mod", { "edit" => "1", "postid" => post.id.to_s, "threadid" => @thread.to_s, "bufatt" => bufatt, "format" => form.fields[2].checked }, 0, pst)
        if fe[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Forum", "The post has been modified"))
          @lastpostindex = @form.index
          refresh
          break
        end
      end
      break if escape or ((enter or space) and form.index == 4)
    end
    dialog_close
  end

  def showbookmarks
    loop_update
    bm = srvproc("forum_bookmarks", { "ac" => "list", "threadid" => @thread })
    if bm[0].to_i != 0
      alert_("Error")
      return
    end
    bookmarks = []
    for i in 0...bm[1].to_i
      b = Struct_Forum_Bookmark.new(bm[2 + i * 4].to_i)
      b.description = bm[2 + i * 4 + 1].delete("\r\n")
      b.thread = bm[2 + i * 4 + 2].to_i
      b.post = bm[2 + i * 4 + 3].to_i
      for i in 0...@posts.size
        b.postnum = i if @posts[i].id == b.post
      end
      bookmarks.push(b)
    end
    refr = false
    sel = ListBox.new(bookmarks.map { |b| b.description + " (" + p_("Forum", "Post %{postnumber} by %{author}") % { "postnumber" => b.postnum + 1, "author" => @posts[b.postnum].author } + "): " + @posts[b.postnum].post[0...100] }, p_("Forum", "Bookmarks"), 0, 0, false)
    sel.bind_context { |menu|
      if bookmarks.size > 0
        menu.option(p_("Forum", "Delete bookmark")) {
          deletebookmark(bookmarks[sel.index])
          refr = true
        }
      end
      if @form.index / 3 < @posts.size
        menu.option(p_("Forum", "New bookmark"), nil, "n") {
          newbookmark
          refr = true
        }
      end
    }
    loop do
      loop_update
      sel.update
      if sel.selected?
        @form.index = bookmarks[sel.index].postnum * 3
        @form.focus
        break
      end
      if $key[0x2E] and bookmarks.size > 0
        deletebookmark(bookmarks[sel.index])
        refr = true
      end
      if escape
        loop_update
        @form.focus
        break
      end
      if refr
        refr = false
        loop_update
        return showbookmarks
      end
    end
  end

  def deletebookmark(b)
    if srvproc("forum_bookmarks", { "ac" => "delete", "bookmark" => b.id })[0].to_i == 0
      alert(p_("Forum", "Bookmark deleted"))
    else
      alert(_("Error"))
    end
    loop_update
  end

  def newbookmark
    return if @form.index / 3 >= @posts.size
    description = input_text(p_("Forum", "Bookmark description"), 0, "", true)
    return if description == nil or description == ""
    if srvproc("forum_bookmarks", { "ac" => "create", "description" => description, "thread" => @thread, "post" => @posts[@form.index / 3].id })[0].to_i == 0
      alert(p_("Forum", "Bookmark created"))
    else
      alert(_("Error"))
    end
    loop_update
  end

  def getcache
    c = srvproc("forum_thread", { "thread" => @thread.to_s, "details" => 7, "zs" => 1 }, 1)
    return if c[0...(c.index("\r") || c.size)].to_i < 0
    c = ("0\r\n" + zstd_decompress(c[3..-1])).split("\r\n").map { |a| a + "\r\n" }
    @cache = c
    @cachetime = c[1].to_i
    @postscount = c[2].to_i
    @readposts = c[3].to_i
    @followed = c[4].to_b
    @posts = []
    t = 0
    for l in c[5..-1]
      case t
      when 0
        break if l.to_i == 0
        @posts.push(Struct_Forum_Post.new(l.to_i))
        t += 1
      when 1
        @posts.last.author = l.delete("\r\n").maintext
        @posts.last.authorname = l.delete("\r\n").lore
        t += 1
      when 2
        if l.delete("\r\n") == "\004END\004"
          t += 1
        else
          @posts.last.post += l
        end
      when 3
        @posts.last.date = l.delete("\r\n")
        t += 1
      when 4
        @posts.last.polls = l.delete("\r\n").split(",").map { |a| a.to_i }
        t += 1
      when 5
        @posts.last.attachments = l.delete("\r\n").split(",")
        t += 1
      when 6
        @posts.last.liked = l.to_b
        t += 1
      when 7
        @posts.last.edited = l.to_b
        t += 1
      when 8
        @posts.last.locked = l.to_b
        t += 1
      when 9
        @posts.last.likes = l.to_i
        t += 1
      when 10
        @posts.last.format = l.to_i
        t += 1
      when 11
        if l.delete("\r\n") == "\004END\004"
          t += 1
        else
          @posts.last.transcription += l
        end
      when 12
        @posts.last.banned = l.to_i == 1
        t += 1
      when 13
        @posts.last.archived = l.to_i == 1
        t += 1
      when 14
        if l.delete("\r\n") == "\004END\004"
          t = 0
        else
          @posts.last.signature += l
        end
      end
    end
  end
end

class Struct_Forum_Group
  attr_accessor :id
  attr_accessor :name
  attr_accessor :forums
  attr_accessor :threads
  attr_accessor :posts
  attr_accessor :readposts
  attr_accessor :lang
  attr_accessor :role
  attr_accessor :open
  attr_accessor :public
  attr_accessor :recommended
  attr_accessor :description
  attr_accessor :founder
  attr_accessor :acmembers
  attr_accessor :created
  attr_accessor :hasregulations
  attr_accessor :hasmotd
  attr_accessor :hasnewmotd
  attr_accessor :preventpolls
  attr_accessor :preventattachments
  attr_accessor :allowpostreporting
  attr_accessor :audiolimit
  attr_accessor :blog
  attr_accessor :showpostreports
  attr_accessor :parent
  attr_accessor :applyglobalbans
  attr_accessor :hidden

  def initialize(id = 0)
    @id = id
    @name = ""
    @forums = 0
    @threads = 0
    @posts = 0
    @readposts = 0
    @role = 0
    @open = false
    @public = false
    @recommended = false
    @description = ""
    @founder = ""
    @acmembers = 0
    @created = 0
    @hasregulations = 0
    @hasmotd = false
    @hasnewmotd = false
    @preventpolls = false
    @preventattachments = false
    @allowpostreporting = false
    @audiolimit = 0
    @blog = nil
    @showpostreports = 0
    @parent = 0
    @applyglobalbans = false
    @hidden = false
  end
end

class Struct_Forum_Forum
  attr_accessor :name
  attr_accessor :group
  attr_accessor :fullname
  attr_accessor :threads
  attr_accessor :posts
  attr_accessor :type
  attr_accessor :readposts
  attr_accessor :followed
  attr_accessor :description
  attr_accessor :closed

  def initialize(name = "")
    @name = name
    @group = Struct_Forum_Group.new(0)
    @fullname = ""
    @posts = 0
    @threads = 0
    @type = 0
    @readposts = 0
    @followed = false
    @description = ""
    @closed = false
  end

  def id
    return @name
  end

  def id=(id)
    @name = id
  end
end

class Struct_Forum_Thread
  attr_accessor :id
  attr_accessor :name
  attr_accessor :posts
  attr_accessor :readposts
  attr_accessor :author
  attr_accessor :followed
  attr_accessor :lastupdate
  attr_accessor :forum
  attr_accessor :mention
  attr_accessor :pinned
  attr_accessor :closed
  attr_accessor :marked
  attr_accessor :offered

  def initialize(id = 0, name = "")
    @id = id
    @name = name
    @posts = 0
    @readposts = 0
    @author = ""
    @followed = false
    @lastupdate = 0
    @forum = ""
    @pinned = false
    @closed = false
    @marked = false
    @offered = 0
  end
end

class Struct_Forum_Post
  attr_accessor :id
  attr_accessor :author
  attr_accessor :post
  attr_accessor :authorname
  attr_accessor :signature
  attr_accessor :date
  attr_accessor :attachments
  attr_accessor :polls
  attr_accessor :liked
  attr_accessor :edited
  attr_accessor :locked
  attr_accessor :likes
  attr_accessor :format
  attr_accessor :transcription
  attr_accessor :banned
  attr_accessor :archived

  def initialize(id = 0)
    @id = id
    @author = ""
    @post = ""
    @authorname = ""
    @signature = ""
    @date = ""
    @attachments = []
    @polls = []
    @liked = false
    @edited = false
    @locked = false
    @likes = 0
    @format = 0
    @transcription = ""
    @banned = false
    @archived = false
  end
end

class Struct_Forum_Mention
  attr_accessor :id
  attr_accessor :author
  attr_accessor :thread
  attr_accessor :post
  attr_accessor :message
  attr_accessor :time

  def initialize(id = 0)
    @id = id
    @thread = 0
    @post = 0
    @message = 0
    @author = ""
    @time = Time.at(0)
  end
end

class Struct_Forum_Bookmark
  attr_accessor :id
  attr_accessor :description
  attr_accessor :thread
  attr_accessor :post
  attr_accessor :postnum

  def initialize(id = 0)
    @id = id
    @description = ""
    @thread = 0
    @post = 0
    @postnum = 0
  end
end

class Struct_Forum_SearchQuery
  attr_accessor :phrase, :phrase_in, :thread_in, :groupid, :forumid, :transcriptions

  def initialize(phrase)
    @phrase = phrase
    @thread_in = [:recommended, :joined]
    @phrase_in = [:title, :content]
    @groupid = nil
    @forumid = nil
    @transcriptions = false
  end
end

class Scene_Forum_GroupSettings
  def initialize(group, scene = nil)
    @group = group
    @settings = []
    @scene = scene
  end

  def getconfig
    a = srvproc("forum_group_settings", { "groupid" => @group.id, "ac" => "get" })
    @values = {}
    if a[0].to_i == 0
      @values = JSON.load(a[1])
    end
  end

  def currentconfig(key)
    getconfig if @values == nil
    return @values[key]
  end

  def setcurrentconfig(key, val)
    @values[key] = val.to_s
  end

  def setting_category(cat)
    @settings.push([cat, nil])
    @form.fields[0].options.push(cat)
  end

  def on_load(&func)
    return if @settings.size == 0
    @settings.last[1] = func
  end

  def make_setting(label, type, key, mapping = nil)
    return if @settings.size == 0
    mapping = mapping.map { |x| x.to_s } if mapping != nil
    @settings.last.push([label, type, key, mapping])
  end

  def save_category
    for i in 2...@settings[@category].size
      setting = @settings[@category][i]
      next if setting[1] == :custom
      index = i - 1
      val = @form.fields[index].value
      val = val.to_i if setting[1] == :number or setting[1] == :bool
      val = setting[3][val] if setting[3] != nil
      setcurrentconfig(setting[2], val)
    end
  end

  def show_category(id)
    return if @form == nil or @settings[id] == nil
    save_category if @category != nil
    @category = id
    @form.show_all
    @form.fields[1..-4] = nil
    f = []
    for s in @settings[id][2..-1]
      label, type, key, mapping = s
      field = nil
      case type
      when :text
        field = EditBox.new(label, "", currentconfig(key).to_s, true)
      when :longtext
        field = EditBox.new(label, EditBox::Flags::MultiLine, currentconfig(key).to_s, true)
      when :number
        field = EditBox.new(label, EditBox::Flags::Numbers, currentconfig(key).to_i.to_s, true)
      when :bool
        field = CheckBox.new(label, (currentconfig(key).to_i != 0).to_i)
      when :custom
        field = Button.new(label)
        proc = key
        field.on(:press, 0, true, &proc)
      else
        index = currentconfig(key)
        index = mapping.find_index(index) || 0 if mapping != nil
        field = ListBox.new(type, label, index.to_i)
      end
      @form.fields.insert(-4, field)
    end
    @settings[id][1].call if @settings[id][1] != nil
  end

  def apply_settings
    save_category
    j = {}
    for k in @values.keys
      v = @values[k]
      j[k] = v
    end
    json = JSON.generate(j)
    b = buffer(json)
    srvproc("forum_group_settings", { "ac" => "set", "groupid" => @group.id, "buffer" => b })
  end

  def make_window
    @form = Form.new
    @form.fields[0] = ListBox.new([], p_("Forum", "Category"))
    @form.fields[1] = Button.new(_("Apply"))
    @form.fields[2] = Button.new(_("Save"))
    @form.fields[3] = Button.new(_("Cancel"))
  end

  def load_general
    setting_category(p_("Forum", "General"))
    make_setting(p_("Forum", "Group name"), :text, "name")
    make_setting(p_("Forum", "Group description"), :longtext, "description")
    langs = []
    langsmapping = []
    getconfig if @languages == nil
    for lang in Lists.langs.keys
      l = Lists.langs[lang]
      langsmapping.push(lang)
      langs.push(l["name"] + "(" + l["nativeName"] + ")")
    end
    make_setting(p_("Forum", "Language"), langs, "lang", langsmapping)
    if currentconfig("recommended").to_i == 0
      make_setting(p_("Forum", "Group type"), [p_("Forum", "Hidden"), p_("Forum", "Public")], "public")
      make_setting(p_("Forum", "Group join type"), ["", ""], "open")
      make_setting(p_("Forum", "Change group parent"), :custom, Proc.new {
        groups = Scene_Forum.getstruct["groups"].find_all { |g| (g.role == 2 || g.public || g.open) && g.id != @group.id }
        ind = (groups.find_index(groups.find { |g| g.id == currentconfig("parent").to_i }) || -1) + 1
        dialog_open
        b = selector([p_("Forum", "None")] + groups.map { |g| g.name }, p_("Forum", "Select group parent"), ind, -1)
        if b != -1
          id = 0
          id = groups[b - 1].id if b > 0
          setcurrentconfig("parent", id.to_s)
        end
        dialog_close
      })
      make_setting(p_("Forum", "Prevent globally banned users from posting in this group"), :bool, "applyglobalbans")
    end
    if holds_premiumpackage("scribe")
      make_setting(p_("Forum", "Change group blog"), :custom, Proc.new {
        blogids = []
        blognames = []
        b = srvproc("blog_managed", { "searchname" => Session.name })
        if b[0].to_i > 0
          alert(_("Error"))
        else
          for i in 2...b.size
            if i % 2 == 0
              blogids.push(b[i].delete("\r\n"))
            else
              blognames.push(b[i].delete("\r\n"))
            end
          end
          ls = selector([p_("Forum", "None")] + blognames, p_("Forum", "Select blog"), 0, -1)
          if ls >= 0
            if ls == 0
              setcurrentconfig("blog", "")
            else
              setcurrentconfig("blog", blogids[ls - 1])
            end
          end
        end
      })
    end
    if holds_premiumpackage("audiophile")
      make_setting(p_("Forum", "Create group channel in conferences"), :bool, "conference_channel")
    end
    on_load {
      if currentconfig("recommended").to_i == 0
        @form.fields[4].on(:move) {
          if @form.fields[4].index == 0
            @form.fields[5].options = [p_("Forum", "closed (only invited users can join)"), p_("Forum", "Moderated (everyone can request)")]
          else
            @form.fields[5].options = [p_("Forum", "Moderated (everyone can request)"), p_("Forum", "open (everyone can join)")]
          end
        }
        @form.fields[4].trigger(:move)
      end
    }
  end

  def load_regulations
    setting_category(p_("Forum", "Regulations"))
    make_setting(p_("Forum", "Group regulations"), :longtext, "regulations")
  end

  def load_permissions
    setting_category(p_("Forum", "Permissions"))
    make_setting(p_("Forum", "Prevent users from editing their posts"), :bool, "prevent_editing")
    make_setting(p_("Forum", "Prevent users from attaching polls"), :bool, "prevent_polls")
    make_setting(p_("Forum", "Prevent users from attaching files"), :bool, "prevent_attachments")
    make_setting(p_("Forum", "Hide information about edited posts"), :bool, "hide_editinfo")
    make_setting(p_("Forum", "Hide edit history"), :bool, "hide_edithistory")
    make_setting(p_("Forum", "Allow members to report posts"), :bool, "allow_postreporting")
    make_setting(p_("Forum", "Reports visibility"), [p_("Forum", "Disabled"), p_("Forum", "Show only to report author"), p_("Forum", "Show all accepted reports"), p_("Forum", "Show all reports")], "show_postreports")
    make_setting(p_("Forum", "Duration limit of audio posts in seconds, 0 for no limit"), :number, "audiolimit")
  end

  def main
    make_window
    load_general
    load_regulations
    load_permissions
    @form.focus
    loop do
      loop_update
      @form.update
      show_category(@form.fields[0].index) if @category != @form.fields[0].index
      if @form.fields[-3].pressed?
        apply_settings
        speak(_("Saved"))
      end
      if @form.fields[-2].pressed? or (enter and !@form.fields[@form.index].is_a?(Button) and !(@form.fields[@form.index].is_a?(EditBox) && (@form.fields[@form.index].flags & EditBox::Flags::MultiLine) > 0))
        apply_settings
        alert(_("Saved"))
        if @scene == nil
          $scene = Scene_Main.new
        else
          $scene = @scene
        end
      end
      if escape or @form.fields[-1].pressed?
        if @scene == nil
          $scene = Scene_Main.new
        else
          $scene = @scene
        end
      end
      break if $scene != self
    end
  end
end

class Struct_Forum_Report
  attr_accessor :id, :user, :thread, :post, :postvalue, :content, :creationtime, :solved, :status, :reason, :solutiontime

  def initialize
    @id, @user, @thread, @post, @postvalue, @content, @creationtime, @solved, @status, @reason, @solutiontime = 0, "", 0, 0, "", "", Time.now, false, 0, "", nil
  end
end

class Struct_Forum_LogEntry
  attr_accessor :id, :user, :action, :time, :group1, :forum1, :thread1, :post1, :group2, :forum2, :thread2, :post2, :oldcontent, :newcontent

  def initialize
    @id = 0
    @user = ""
    @action = ""
    @time = 0
    @group1 = 0
    @forum1 = ""
    @thread1 = 0
    @post1 = 0
    @group2 = 0
    @forum2 = ""
    @thread2 = 0
    @post2 = 0
    @oldcontent = ""
    @newcontent = ""
  end
end
