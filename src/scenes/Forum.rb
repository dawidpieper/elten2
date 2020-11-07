# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Forum
  def initialize(pre = nil, preparam = nil, cat = 0, query = "", tc = nil)
    @pre = pre
    @preparam = preparam
    @lastlist = @cat = cat
    @query = query
    @grpindex ||= []
    @close = false
    @tc = tc
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
      if enter or (arrow_right and !$keyr[0x10])
        groupopen(@grpsel.index, type)
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
          x = b.lang
          x = "_" if b.lang.downcase == Configuration.language[0..1].downcase
          x += sprintf("%04d", b.id)
          y = a.lang
          y = "_" if a.lang.downcase == Configuration.language[0..1].downcase
          y += sprintf("%04d", a.id)
          x, y = sorts[a.id], sorts[b.id]
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
      forfol = []
      for forum in @forums
        if forum.followed
          forfol.push(forum.name)
        end
      end
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
        groupsopencnt += 1 if g.open && !g.recommended
        groupsinvitedcnt += 1 if g.role == 5
        groupsallcnt += 1 if (g.open || g.public) && g.forums > 0
        groupsmoderatedcnt += 1 if g.role == 2
      }
      grpselt = [[np_("Forum", "Followed thread", "Followed threads", ft), nil, ft.to_s, fp.to_s, (fp - fr).to_s], [np_("Forum", "Followed forum", "Followed forums", forfol.size), forfol.size.to_s, flt.to_s, flp.to_s, (flp - flr).to_s], [np_("Forum", "Marked thread", "Marked threads", fmt), nil, fmt.to_s, fmp.to_s, (fmp - fmr).to_s]] + grpselt + [[p_("Forum", "Recently active groups")], [p_("Forum", "Recommended groups (%{count})") % { "count" => groupsrecommendedcnt.to_s }], [p_("Forum", "Open groups (%{count})") % { "count" => groupsopencnt.to_s }], [np_("Forum", "Waiting invitation", "Waiting invitations (%{count})", groupsinvitedcnt) % { "count" => groupsinvitedcnt.to_s }], [np_("Forum", "Moderated group", "Moderated groups (%{count})", groupsmoderatedcnt) % { "count" => groupsmoderatedcnt.to_s }], [p_("Forum", "All groups (%{count})") % { "count" => groupsallcnt.to_s }], [p_("Forum", "Recently created groups")], [p_("Forum", "Groups popular with my friends")], [p_("Forum", "Threads popular with my friends")], [p_("Forum", "Received mentions")], [p_("Forum", "My threads")], [p_("Forum", "Search")]]
      grpselt[0] = [nil] if ft == 0
      grpselt[1] = [nil] if forfol.size == 0
      grpselt[2] = [nil] if fmt == 0
      grpselt[@grpheadindex + @sgroups.size + 3] = [nil] if groupsinvitedcnt == 0
      grpselt[@grpheadindex + @sgroups.size + 4] = [nil] if groupsmoderatedcnt == 0
      grpselh = [nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
      @grpindex[0] = @grpheadindex + @sgroups.size + ll - 1 if ll > 0
    when 1
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
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
    when 2
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
    when 3
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
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
    when 4
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
    when 5
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
    when 6
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
        if (g.public || g.open) && g.forums > 0
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
    when 7
      @sgroups = []
      for g in @groups
        next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
        if (g.public || g.open) && g.posts > 0
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
    when 8
      grp = srvproc("forum_popular", { "type" => "groups" })
      @sgroups = []
      if grp[0].to_i == 0
        for l in grp[1..-1]
          g = nil
          @groups.each { |r| g = r if r.id == l.to_i }
          if g != nil
            next if LocalConfig["ForumShowUnknownLanguages"] == 0 && knownlanguages.size > 0 && !knownlanguages.include?(g.lang[0..1].upcase)
            @sgroups.push(g) if g.open || g.public
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
    @grpsel = TableBox.new(grpselh, grpselt, @grpindex[type], p_("Forum", "Forum"), true)
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

  def groupopen(index, type)
    @grpindex[type] = index
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
      return threadsmain(-9)
    elsif index == @grpheadindex + @sgroups.size + 11
      @query = input_text(p_("Forum", "Enter a phrase to look for"), 0, "", true)
      loop_update
      if @query != nil
        usequery
        return threadsmain(-3)
      end
    else
      g = @sgroups[index - @grpheadindex]
      groupmotddlg(g, false) if g.hasnewmotd
      if g.role == 1 or g.role == 2 or g.public
        if $keyr[0x10]
          @query = g
          usequery
          return threadsmain(-3)
        else
          return forumsmain(g.id) if g.role == 1 or g.role == 2 or g.public
        end
      end
    end
  end

  def context_groups(menu, type)
    menu.option(p_("Forum", "Open")) {
      groupopen(@grpsel.index, type)
    }
    if @grpsel.index >= @grpheadindex and @grpsel.index < @grpheadindex + @sgroups.size
      menu.option(p_("Forum", "Group summary"), nil, "d") {
        g = @sgroups[@grpsel.index - @grpheadindex]
        s = g.name + "\r\n\r\n"
        s += p_("Forum", "Language") + ": " + g.lang + "\r\n"
        s += p_("Forum", "Members") + ": " + g.acmembers.to_s + "\r\n"
        s += p_("Forum", "Founder") + ": " + g.founder + "\r\n"
        if g.created > 0
          t = Time.at(g.created)
          s += p_("Forum", "Founded at") + ": " + format_date(t, true) + "\r\n"
        end
        acs = srvproc("forum_groups", { "ac" => "mostactive", "groupid" => g.id.to_s })
        s += p_("Forum", "The most active members") + ": " + acs[1..-1].map { |x| x.delete("\r\n") }.join(", ") + "\r\n" if acs.size > 1
        s += "\r\n\r\n"
        szs = srvproc("forum_groups", { "ac" => "size", "groupid" => g.id.to_s })
        if szs.size >= 4
          s += p_("Forum", "Group size") + "\r\n"
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
              s += "\r\n"
            end
          end
        end
        s += "\r\n\r\n" + g.description if g.description != nil && g.description != ""
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
      if @sgroups[@grpsel.index - @grpheadindex].role == 2
        menu.option(p_("Forum", "Invite"), nil, "i") {
          u = input_user(p_("Forum", "User to invite"))
          if u != nil
            r = srvproc("forum_groups", { "ac" => "invite", "groupid" => @sgroups[@grpsel.index - @grpheadindex].id.to_s, "user" => u })
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
          loop_update
          @grpsel.focus
        }
      end
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
              t.readposts = t.posts if t.forum.group.id == @sgroups[@grpsel.index].id
            end
            for f in @forums
              f.readposts = f.posts if f.group.id == @sgroups[@grpsel.index].id
            end
            @sgroups[@grpsel.index - @grpheadindex].readposts = @sgroups[@grpsel.index - @grpheadindex].posts
            @grpsel.rows[@grpsel.index][-1] = "0"
            alert(p_("Forum", "The group has been marked as read."))
          else
            alert(_("Error"))
          end
        end
      }
      if @sgroups[@grpsel.index - @grpheadindex].founder == Session.name
        menu.option(p_("Forum", "Edit group"), nil, "e") {
          g = @sgroups[@grpsel.index - @grpheadindex]
          fields = [EditBox.new(p_("Forum", "Group name"), "", g.name, true), EditBox.new(p_("Forum", "Group description"), EditBox::Flags::MultiLine, g.description, true), ListBox.new([p_("Forum", "Hidden"), p_("Forum", "Public")], p_("Forum", "Group type"), g.public.to_i, 0, true), ListBox.new([p_("Forum", "open (everyone can join)"), p_("Forum", "Moderated (everyone can request)")], p_("Forum", "Group join type"), g.open.to_i, 0, true), nil, Button.new(_("Cancel"))]
          if g.recommended
            fields[2].disable_item(0)
            fields[3].disable_item(0)
          end
          form = Form.new(fields)
          loop do
            loop_update
            form.update
            if form.fields[4] == nil and form.fields[0].text != ""
              form.fields[4] = Button.new(_("Save"))
            elsif form.fields[4] != nil and form.fields[0].text == ""
              form.fields[4] = nil
            end
            case form.fields[2].index
            when 0
              form.fields[3].options = [p_("Forum", "closed (only invited users can join)"), p_("Forum", "Moderated (everyone can request)")]
            when 1
              form.fields[3].options = [p_("Forum", "Moderated (everyone can request)"), p_("Forum", "open (everyone can join)")]
            end
            if form.fields[4] != nil and form.fields[4].pressed?
              r = srvproc("forum_groups", { "ac" => "edit", "groupid" => g.id.to_s, "groupname" => form.fields[0].text, "bufdescription" => buffer(form.fields[1].text).to_s, "public" => form.fields[2].index.to_s, "open" => form.fields[3].index.to_s })
              if r[0].to_i < 0
                alert(_("Error"))
              else
                alert(_("Saved"))
              end
              getcache
              groupsmain(@lastlist)
            end
            break if escape or form.fields[5].pressed?
          end
          loop_update
        }
      end
      if @sgroups[@grpsel.index - @grpheadindex].forums == 0 and @sgroups[@grpsel.index - @grpheadindex].founder == Session.name
        menu.option(p_("Forum", "Delete group")) {
          confirm(p_("Forum", "Are you sure you want to delete %{groupname}?") % { "groupname" => @sgroups[@grpsel.index - @grpheadindex].name }) {
            if srvproc("forum_groups", { "ac" => "delete", "groupid" => @sgroups[@grpsel.index - @grpheadindex].id.to_s })[0].to_i < 0
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
    menu.option(p_("Forum", "New group"), nil, "n") {
      newgroup
    }
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
      return g[1..-1].join("\n")
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

  def groupmembers(group)
    m = srvproc("forum_groups", { "ac" => "members", "groupid" => group.id.to_s })
    if m[0].to_i < 0
      alert(_("Error"))
    else
      selt = []
      users = []
      roles = []
      for i in 0...m[1].to_i
        users.push(m[2 + i * 2].delete("\r\n"))
        roles.push(m[2 + i * 2 + 1].to_i)
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
      sel = ListBox.new(selt, p_("Forum", "Members"), 0)
      usermenu(users[sel.index]) if enter
      sel.bind_context { |menu|
        menu.useroption(users[sel.index])
        m1 = nil
        m2 = nil
        if !((group.founder != Session.name or users[sel.index] == Session.name))
          if roles[sel.index] == 1
            m1 = p_("Forum", "Grant moderation privileges")
          elsif roles[sel.index] == 2
            m1 = p_("Forum", "Deny moderation privileges")
            m2 = p_("Forum", "Pass administrative privileges")
          elsif roles[sel.index] == 3
            m2 = p_("Forum", "Unban")
          elsif roles[sel.index] == 4
            m2 = p_("Forum", "Examine")
          end
        end
        if !((group.founder != Session.name and group.role != 2) or Session.name == users[sel.index])
          if roles[sel.index] == 1
            if group.open && group.public
              m2 = p_("Forum", "Ban in this group")
            else
              m2 = p_("Forum", "Kick")
            end
          elsif roles[sel.index] == 3
            m2 = p_("Forum", "Unban")
          elsif roles[sel.index] == 4
            m2 = p_("Forum", "Examine")
          end
        end
        if m1 != nil
          menu.option(m1) {
            cat = ""
            s = ""
            if roles[sel.index] == 1
              cat = "moderationgrant"
              s = p_("Forum", "Are you sure you want to grant moderation privileges in %{groupname} to user %{user}?")
            else
              cat = "moderationdeny"
              s = p_("Forum", "Are you sure you want to deny %{user}'s moderation privileges?")
            end
            confirm(s % { "user" => users[sel.index], "groupname" => group.name }) {
              r = srvproc("forum_groups", { "ac" => "privileges", "pr" => cat, "user" => users[sel.index], "groupid" => group.id.to_s })
              if r[0].to_i < 0
                alert(_("Error"))
              else
                if roles[sel.index] == 2
                  roles[sel.index] = 1
                  sel.options[sel.index].sub!(p_("Forum", "Moderator"), "")
                else
                  roles[sel.index] = 2
                  sel.options[sel.index].sub!(" ", " (#{p_("Forum", "Moderator")}) ")
                end
                alert(p_("Forum", "Privileges of this user have been changed."))
              end
            }
          }
        end
        if m2 != nil
          menu.option(m2) {
            if roles[sel.index] == 1 or roles[sel.index] == 3 or roles[sel.index] == 4
              cat = ""
              s = ""
              if roles[sel.index] == 1
                if group.open && group.public
                  cat = "ban"
                  s = p_("Forum", "Are you sure you want to ban %{user} in %{groupname}?")
                else
                  cat = "kick"
                  s = p_("Forum", "Are you sure you want to kick %{user} of %{groupname}?")
                end
              elsif roles[sel.index] == 3
                cat = "unban"
                s = p_("Forum", "Are you sure you want to unban %{user} in %{groupname}?")
              elsif roles[sel.index] == 4
                c = selector([p_("Forum", "Accept invitation"), p_("Forum", "Refuse invitation"), _("Cancel")], "", 0, 2, 1)
                case c
                when 0
                  cat = "accept"
                  s = p_("Forum", "Do you want to accept request of user %{user}")
                when 1
                  cat = "refuse"
                  s = p_("Forum", "Do you want to refuse request of user %{user}")
                when 2
                  cat = nil
                end
              end
              if cat != nil
                confirm(s % { "user" => users[sel.index], "groupname" => group.name }) {
                  r = srvproc("forum_groups", { "ac" => "user", "pr" => cat, "user" => users[sel.index], "groupid" => group.id.to_s })
                  if r[0].to_i < 0
                    alert(_("Error"))
                  else
                    if cat == "ban"
                      roles[sel.index] = 3
                    elsif cat == "unban" || cat == "accept"
                      roles[sel.index] = 1
                      sel.options[sel.index].gsub!(p_("Forum", "Banned"), "")
                      sel.options[sel.index].gsub!(p_("Forum", "Waiting for review"), "")
                    elsif cat == "refuse"
                      sel.disable_item(sel.index)
                    end
                    alert(p_("Forum", "Privileges of this user have been changed."))
                  end
                }
              end
            else
              confirm(p_("Forum", "Are you sure you want to resign your administrative privileges in %{groupname} and pass them to %{user}?") % { "user" => users[sel.index], "groupname" => group.name }) {
                r = srvproc("forum_groups", { "ac" => "privileges", "pr" => "passadmin", "user" => users[sel.index], "groupid" => group.id.to_s })
                if r[0].to_i < 0
                  alert(_("Error"))
                else
                  group.founder = users[sel.index]
                  sel.options[sel.index].sub!(" ", " (#{p_("Forum", "Administrator")}) ")
                  for i in 0...users.size
                    sel.options[i].sub!(p_("Forum", "Administrator"), "") if users[i] == Session.name
                  end
                  alert(p_("Forum", "Privileges of this user have been changed."))
                end
              }
            end
          }
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
      end
    end
  end

  def groupregulations(group)
    g = srvproc("forum_groups", { "ac" => "regulations", "groupid" => group.id })
    if g[0].to_i == 0
      return g[1..-1].join("\n")
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
    fields = [EditBox.new(p_("Forum", "Group name"), "", "", true), EditBox.new(p_("Forum", "Group description"), EditBox::Flags::MultiLine, "", true), ListBox.new(ln, p_("Forum", "Language"), lnindex, 0, true), ListBox.new([p_("Forum", "Hidden"), p_("Forum", "Public")], p_("Forum", "Group type"), 0, 0, true), ListBox.new([p_("Forum", "open (everyone can join)"), p_("Forum", "Moderated (everyone can request)")], p_("Forum", "Group join type"), 0, 0, true), nil, Button.new(_("Cancel"))]
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
      ftm += [forum.description, forum.threads.to_s, forum.posts.to_s, (forum.posts - forum.readposts).to_s]
      ftm[0] += "\004INFNEW{ }\004" if forum.posts - forum.readposts > 0
      ftm[0] += "\004CLOSED\004" if forum.closed
      frmselt.push(ftm)
    end
    @frmindex = 0 if @frmindex == nil
    frmselh = [nil, nil, p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    @frmsel = TableBox.new(frmselh, frmselt, @frmindex, p_("Forum", "Select forum"), true)
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
    sel = ListBox.new(selt, p_("Forum", "Forum tags"))
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
            sel.sayoption
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
      ListBox.new((tag[2..-1]) || [], p_("Forum", "Possible tag values"), 0, 0, true),
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
          play("edit_delete")
          tag.delete_at(form.fields[1].index + 2)
          form.fields[1].options.delete_at(form.fields[1].index)
          form.fields[1].sayoption
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
      }
      menu.option(p_("Forum", "Mark this forum as read"), nil, "w") {
        if @sforums[@frmsel.index].posts - @sforums[@frmsel.index].readposts < 100 or confirm(p_("Forum", "All posts on this forum will be marked as read. Are you sure you want to continue?")) == 1
          if srvproc("forum_markasread", { "forum" => @sforums[@frmsel.index].name })[0].to_i == 0
            for t in @threads
              t.readposts = t.posts if t.forum.name == @sforums[@frmsel.index].name
            end
            @sforums[@frmsel.index].readposts = @sforums[@frmsel.index].posts
            @frmsel.rows[@frmsel.index][0].gsub!("\004INFNEW{ }\004", "")
            @frmsel.rows[@frmsel.index][4] = "0"
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
            form = Form.new([EditBox.new(p_("Forum", "Forum name"), "", @sforums[@frmsel.index].fullname, true), EditBox.new(p_("Forum", "Forum description"), EditBox::Flags::MultiLine, @sforums[@frmsel.index].description, true), nil, Button.new(_("Cancel"))])
            loop do
              loop_update
              form.update
              if form.fields[2] == nil and form.fields[0].text != ""
                form.fields[2] = Button.new(_("Save"))
              elsif form.fields[2] != nil and form.fields[0].text == ""
                form.fields[2] = nil
              end
              if form.fields[2] != nil and form.fields[2].pressed?
                u = { "ac" => "forumedit", "forum" => @sforums[@frmsel.index].name, "forumname" => form.fields[0].text }
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
                getcache
                forumsmain(@group)
              end
              break if escape or form.fields[3].pressed?
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
    fields = [EditBox.new(p_("Forum", "Forum name"), "", "", true), EditBox.new(p_("Forum", "Forum description"), EditBox::Flags::MultiLine, "", true), ListBox.new([p_("Forum", "Text forum"), p_("Forum", "Voice forum"), p_("Forum", "Mixed forum")], p_("Forum", "Forum type"), 0, 0, true), nil, Button.new(_("Cancel"))]
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
    index = 0 if index == nil
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
    for t in @threads
      case id
      when -11
        for mention in @mentions
          if t.id == mention.thread
            t.mention = mention
            @sthreads.push(t.clone)
          end
        end
      when -10
        @sthreads.push(t) if t.marked == true
      when -9
        @sthreads.push(t) if t.author == Session.name
      when -8
        @sthreads.push(t) if @popular.include?(t.id) and t.readposts <= t.posts / 1.1
      when -7
        for mention in @mentions
          if t.id == mention.thread
            t.mention = mention
            @sthreads.push(t.clone)
          end
        end
      when -6
        folfor = []
        for forum in @forums
          folfor.push(forum.name) if forum.followed == true
        end
        @sthreads.push(t) if folfor.include?(t.forum.name) and t.readposts < t.posts
      when -4
        folfor = []
        for forum in @forums
          folfor.push(forum.name) if forum.followed == true
        end
        @sthreads.push(t) if folfor.include?(t.forum.name) and t.readposts == 0
      when -3
        @sthreads.push(t) if @results.include?(t.id) and (t.forum.group.recommended or t.forum.group.role == 1 or t.forum.group.role == 2)
      when -2
        @sthreads.push(t) if t.followed == true and t.readposts < t.posts
      when -1
        @sthreads.push(t) if t.followed == true
      when 0
        @sthreads.push(t)
      else
        @sthreads.push(t) if t.forum.name == id
      end
    end
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
    index = @sthreads.size - 1 if index >= @sthreads.size
    thrselt = []
    for i in 0..@sthreads.size - 1
      thread = @sthreads[i]
      if id != -11
        index = i if thread.id == @pre
      else
        index = i if @tc != nil && thread.mention.id == @tc.mention.id
      end
      tmp = [thread.name]
      tmp[0] += "\004INFNEW{#{p_("Forum", "New")}: }\004" if thread.readposts < thread.posts and (id != -2 and id != -4 and id != -6 and id != -7)
      tmp[0] += "\004CLOSED\004" if thread.closed
      tmp[0] += "\004PINNED\004" if thread.pinned
      if id == -7 or id == -11
        tmp[0] += " . #{p_("Forum", "Mentioned by")}: #{thread.mention.author} (#{thread.mention.message})"
      end
      if id == -3 or id == -6 or id == -7
        tmp[0] += " (#{thread.forum.fullname}, #{thread.forum.group.name})"
      end
      tmp += [thread.author.lore, thread.posts.to_s, (thread.posts - thread.readposts).to_s]
      thrselt.push(tmp)
    end
    if !(@pre == nil && @preparam != nil)
      @pre = nil
      @preparam = nil
    end
    header = p_("Forum", "Select thread")
    header = "" if id == -2 or id == -4 or id == -6 or id == -7
    thrselh = [nil, p_("Forum", "Author"), p_("Forum", "posts"), p_("Forum", "Unread")]
    @thrsel = TableBox.new(thrselh, thrselt, index, header, true)
    @thrsel.column = LocalConfig["ForumColumnThread"] if LocalConfig["ForumColumnThread"] != nil
    @thrsel.bind_context(p_("Forum", "Forum")) { |menu| context_threads(menu) }
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
    if @group == -5
      $scene = Scene_Forum_Thread.new(@sthreads[index], -5, @cat, @query)
    else
      if @forum == -7 or @forum == -11
        $scene = Scene_Forum_Thread.new(@sthreads[index], @forum, @cat, @query, @sthreads[@thrsel.index].mention)
      else
        $scene = Scene_Forum_Thread.new(@sthreads[index], @forum, @cat, @query)
      end
    end
  end

  def context_threads(menu)
    group = Struct_Forum_Group.new
    for f in @forums
      group = f.group if f.name == id
    end
    if @sthreads.size > 0
      menu.option(p_("Forum", "Open")) {
        threadopen(@thrsel.index)
      }
      s = p_("Forum", "Mark this thread")
      s = p_("Forum", "Unmark this thread") if @sthreads[@thrsel.index].marked == true
      menu.option(s, nil, "h") {
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
    if forum.is_a?(String) == false and forum.is_a?(Integer) == false and @noteditable != true and ((forum.group.public == true and forum.group.open == true) or [1, 2].include?(forum.group.role)) and forum.group.role != 3 and forum.closed == false
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
          m.option(p_("Forum", "Rename")) {
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
        if f.type == @forumtype
          if f.group.id == g.id
            forums.push(f.fullname + " (#{g.name})")
            forumclasses.push(f)
            forumindex = forums.size - 1 if f.name == @forum
          end
        end
      end
    end
    fields = [EditBox.new(p_("Forum", "Thread name"), "", "", true)]
    if type == 0
      fields[1..6] = [EditBox.new(p_("Forum", "Post"), EditBox::Flags::MultiLine, "", true), nil, nil, Button.new(p_("Forum", "Attach a poll")), nil, Button.new(p_("Forum", "Attach a file"))]
    else
      fields[1..6] = [OpusRecordButton.new(p_("Forum", "Audio post"), Dirs.temp + "\\audiopost.opus", 96, 48), nil, nil, nil, nil, nil]
    end
    fields += [CheckBox.new(p_("Forum", "Add to followed threads list")), ListBox.new(forums, p_("Forum", "Forum"), forumindex, 0, true), nil, Button.new(_("Cancel"))]
    form = Form.new(fields)
    form.fields[-3].on(:move) {
      f = []
      for t in forumtags(forumclasses[form.fields[8].index])
        f.push(ListBox.new([p_("Forum", "No tag value")] + t[2..-1], t[1], 0, 0, true))
      end
      fields[7...-4] = f
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
                form.fields[3] ||= ListBox.new([], p_("Forum", "Polls"), 0, 0, true)
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
        play("edit_delete")
        polls.delete_at(form.fields[3].index)
        form.fields[3].options.delete_at(form.fields[3].index)
        form.fields[3].index -= 1 if form.fields[3].index > 0
        if polls.size == 0
          form.fields[3] = nil
          form.index = 4
          form.focus
        else
          form.fields[3].sayoption
        end
      end
      if (enter or space) and form.index == 6 and files.size < 3
        l = getfile(p_("Forum", "Select file to attach"), Dirs.documents + "\\")
        if l != "" and l != nil
          if files.include?(l)
            alert(p_("Forum", "This file has been already attached"))
          else
            if File.size(l) > 16777216
              alert(p_("Forum", "This file is too large"))
            else
              files.push(l)
              form.fields[5] ||= ListBox.new([], p_("Forum", "Attachments"), 0, 0, true)
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
        play("edit_delete")
        files.delete_at(form.fields[5].index)
        form.fields[5].options.delete_at(form.fields[5].index)
        form.fields[5].index -= 1 if form.fields[5].index > 0
        if files.size == 0
          form.fields[5] = nil
          form.index = 6
          form.focus
        else
          form.fields[5].sayoption
        end
      end
      if type == 0
        if ($key[0x11] and enter) or (form.fields[-2] != nil && form.fields[-2].pressed?)
          play("list_select")
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
    form.fields[0].settext(name)
    if type == 0
      buf = buffer(text).to_s
      prm = { "forumname" => forumclasses[form.fields[-3].index].name, "threadname" => form.fields[0].text, "buffer" => buf }
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
      ft = srvproc("forum_edit", prm)
    else
      fl = form.fields[1].get_file
      waiting
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
      q = "POST /srv/forum_edit.php?name=#{Session.name}\&token=#{Session.token}\&threadname=#{form.fields[0].text.urlenc}\&forumname=#{forumclasses[form.fields[-3].index].name.urlenc}\&audio=1\&follow=#{form.fields[-4].checked.to_s} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: close\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
      a = elconnect(q).delete("\0")
      s = 0
      for i in 0..a.size - 1
        if a[i..i + 3] == "\r\n\r\n"
          s = i + 4
          break
        end
      end
      sn = a[s..a.size - 1]
      a = nil
      bt = sn.split("\r\n")
      ft = bt[1].to_i
      waiting_end
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
    c = srvproc("forum_struct", { "useflags" => 1, "gz" => 1 }, 1)
    if c[0..0] == "-"
      alert(_("Error"))
      @@groups = []
      @@forums = []
      @@threads = []
      return
    end
    @@groups = []
    @@forums = []
    @@threads = []
    ch = Zlib::Inflate.inflate(c[3..-1]).split("\r")
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
    @results = []
    if @query != "" and @query.is_a?(String)
      sr = srvproc("forum_search", { "query" => @query })
      if sr[0].to_i < 0
        alert(_("Error"))
      else
        t = 0
        for l in sr[2..sr.size - 1]
          if t == 0
            @results.push(l.to_i)
            t = 1
          else
            t = 0
          end
        end
      end
    elsif @query.is_a?(Struct_Forum_Group)
      @threads.each { |t| @results.push(t.id) if t.forum.group.id == @query.id }
    else
      @threads.each { |t| @results.push(t.id) }
    end
  end
end

class Scene_Forum_Thread
  def initialize(thread, param = nil, cat = 0, query = "", mention = nil, scene = nil)
    @threadclass = thread
    @param = param
    @cat = cat
    @query = query
    @mention = mention
    @scene = scene
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
              $scene = Scene_Forum.new(@thread, @param, @cat, @query, @threadclass)
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
        selt[0] = nil if voted
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
        nm = name_attachments([fl]).first
        loc = getfile(p_("Forum", "Where to save this file?"), Dirs.user + "\\", true, "Documents")
        if loc != nil and loc != nil
          waiting
          downloadfile($url + "/attachments/" + fl, loc + "\\" + nm, "", _("Saved"))
          waiting_end
        else
          @form.focus
        end
        loop_update
      end
      if ((space or enter) and @form.index == @fields.size - 2) and @attachments.size < 3
        l = getfile(p_("Forum", "Select file to attach"), Dirs.documents + "\\")
        if l != "" and l != nil
          if @attachments.include?(l)
            alert(p_("Forum", "This file has been already attached"))
          else
            if File.size(l) > 16777216
              alert(p_("Forum", "This file is too large"))
            else
              @attachments.push(l)
              @form.fields[@form.fields.size - 3] ||= ListBox.new([], p_("Forum", "Attachments"), 0, 0, true)
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
        play("edit_delete")
        @attachments.delete_at(@form.fields[@form.fields.size - 3].index)
        @form.fields[@form.fields.size - 3].options.delete_at(@form.fields[@form.fields.size - 3].index)
        @form.fields[@form.fields.size - 3].index -= 1 if @form.fields[@form.fields.size - 3].index > 0
        if @attachments.size == 0
          @form.fields[@form.fields.size - 3] = nil
          @form.index = @form.fields.size - 2
          @form.focus
        else
          @form.fields[@form.fields.size - 3].sayoption
        end
      end
      break if $scene != self
    end
  end

  def groupregulations
    g = srvproc("forum_groups", { "ac" => "regulations", "groupid" => @threadclass.forum.group.id })
    if g[0].to_i == 0
      return g[1..-1].join("\n")
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
    lastindex = nil
    lastindex = @form.index if @form != nil
    index = -1
    getcache
    @fields = []
    return if @posts == nil
    for i in 0...@posts.size
      post = @posts[i]
      index = i * 3 if index == -1 and @param == -3 and @query.is_a?(String) and post.post.downcase.include?(@query.downcase)
      index = i * 3 if @mention != nil and (@param == -7 or @param == -11) and post.id == @mention.post
      @fields += [EditBox.new(post.authorname, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, generate_posttext(post), true), nil, nil]
      @fields[-1] = ListBox.new(name_attachments(post.attachments), p_("Forum", "Attachments"), 0, 0, true) if post.attachments.size > 0
      if post.polls.size > 0
        names = []
        for o in post.polls
          pl = srvproc("polls", { "get" => "1", "poll" => o.to_s })
          names.push(pl[2].delete("\r\n")) if pl[0].to_i == 0 and pl.size > 1
        end
        @fields[-2] = ListBox.new(names, p_("Forum", "Polls"), 0, 0, true) if names.size == post.polls.size
      end
    end

    index = 0 if index == -1
    index = @lastpostindex if @lastpostindex != nil
    index = 0 if index > @fields.size
    @type = @threadclass.forum.type
    @posttype = 0
    @posttype = 1 if @type == 1
    if @type == 2
      sel = ListBox.new([p_("Forum", "Text post"), p_("Forum", "Audio post")], p_("Forum", "Post type"), 0, 0, true)
      sel.on(:move) { |i|
        @posttype = sel.index
        @fields[(-1 - @audiofields.size)..-2] = ((@posttype == 0) ? @textfields : @audiofields)
      }
      @fields.push(sel)
    else
      @fields.push(nil)
    end
    @textfields = [EditBox.new(p_("Forum", "Your answer"), EditBox::Flags::MultiLine, "", true), nil, nil, nil, nil, nil, Button.new(p_("Forum", "Attach a file"))]
    @audiofields = [OpusRecordButton.new(p_("Forum", "Audio post"), Dirs.temp + "\\audiopost.opus", 96, 48), nil, nil, nil, nil, nil, nil]
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
    @form.bind_context(p_("Forum", "Forum")) { |menu| context(menu) }
  end

  def generate_posttext(post)
    add = ""
    i = @posts.find_index(post) || 0
    if post.edited
      add = "\r\n" + p_("Forum", "This post has been edited")
    end
    return post.post + ((post.likes > 0) ? (np_("Forum", "%{count} user likes this post", "%{count} users like this post", post.likes) % { "count" => post.likes.to_s } + "\n") : ("")) + ((LocalConfig["ForumHideSignatures"] == 1) ? ("") : (post.signature)) + post.date + add + "\r\n" + (i + 1).to_s + "/" + @posts.size.to_s
  end

  def textsendupdate
    if @form.fields[@postscount * 3 + 1].text == "" and @form.fields[@postscount * 3 + 3] != nil
      @form.fields[@postscount * 3 + 3] = nil
    elsif @form.fields[@postscount * 3 + 1].text != "" and @form.fields[@postscount * 3 + 3] == nil
      @form.fields[@postscount * 3 + 3] = Button.new(p_("Forum", "Send"))
    end
    if (@form.fields[@postscount * 3 + 3] != nil && @form.fields[@postscount * 3 + 3].pressed?) or (enter and $key[0x11] and @form.index == @postscount * 3 + 1)
      return if ![1, 2].include?(@threadclass.forum.group.role) and !canjoin
      buf = buffer(@form.fields[@postscount * 3 + 1].text).to_s
      prm = { "threadid" => @thread.to_s, "buffer" => buf }
      if @attachments.size > 0
        atts = ""
        for f in @attachments
          atts += send_attachment(f) + ","
        end
        atts.chop! if atts[-1..-1] == ","
        prm["bufatt"] = buffer(atts).to_s
      end
      st = srvproc("forum_edit", prm)
      if st[0].to_i < 0
        alert(_("Error"))
      else
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
      waiting
      fl = readfile(file)
      if fl[0..3] != "OggS"
        alert(_("Error"))
        return $scene = Scene_Main.new
      end
      host = $srv
      boundary = ""
      boundary = "----EltBoundary" + rand(36 ** 32).to_s(36) while fl.include?(boundary)
      data = "--" + boundary + "\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
      length = data.size
      q = "POST /srv/forum_edit.php?name=#{Session.name}\&token=#{Session.token}\&threadid=#{@thread.to_s}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: close\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
      a = elconnect(q).delete("\0")
      s = 0
      for i in 0..a.size - 1
        if a[i..i + 3] == "\r\n\r\n"
          s = i + 4
          break
        end
      end
      sn = a[s..a.size - 1]
      ft = sn.split("\r\n")
      waiting_end
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
    if @form.index < @postscount * 3
      menu.useroption(@posts[@form.index / 3].authorname)
    end
    if @threadclass.mention != nil
      menu.submenu(p_("Forum", "Received mention")) { |m|
        m.option(p_("Forum", "Show mention"), nil, "/") {
          input_text(p_("Forum", "Mention by %{user}") % { "user" => @threadclass.mention.author }, EditBox::Flags::ReadOnly, @threadclass.mention.message, true)
        }
        m.option(p_("Forum", "Send reply to mentioner"), nil, "?") {
          to = @threadclass.mention.author
          subj = "RE: " + @threadclass.mention.message.to_s + " (" + @threadclass.name + ")"
          insert_scene(Scene_Messages_New.new(to, subj, "", Scene_Main.new))
        }
      }
    end
    if @form.index < @postscount * 3 and !@threadclass.closed
      menu.submenu(p_("Forum", "Reply")) { |m|
        m.option(p_("Forum", "Reply"), nil, "n") {
          @form.index = @postscount * 3 + ((@type == 2) ? 0 : 1)
          @form.focus
        }
        if @type == 0 and @form.fields[@postscount * 3 + 1].is_a?(EditBox)
          m.option(p_("Forum", "Reply with quote"), nil, "d") {
            @form.fields[@postscount * 3 + 1].settext("\r\n-- (#{@posts[@form.index / 3].authorname}):\r\n#{@posts[@form.index / 3].post}\r\n--\r\n#{@form.fields[@postscount * 3 + 1].text}")
            @form.fields[@postscount * 3 + 1].index = 0
            @form.index = @postscount * 3 + 1
            @form.focus
          }
        end
      }
      post = @posts[@form.index / 3]
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
          @form.fields[@form.index / 3 * 3].settext(generate_posttext(post))
        end
      }
      menu.option(p_("Forum", "Show post likes"), nil, "K") {
        ft = srvproc("forum_postaction", { "ac" => "likes", "postid" => post.id })
        users = []
        if ft[0].to_i == 0
          for i in 0...ft[1].to_i
            user = ft[2 + i].delete("\r\n")
            users.push(user)
          end
        end
        lst = ListBox.new(users, p_("Forum", "Users who like this post"))
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
    end
    menu.submenu(p_("Forum", "Navigation")) { |m|
      m.option(p_("Forum", "Bookmarks"), nil, "b") {
        showbookmarks
      }
      m.option(p_("Forum", "Go to post"), nil, "j") {
        selt = []
        for i in 0..@posts.size - 1
          selt.push((i + 1).to_s + " / " + @postscount.to_s + ": " + @posts[i].author)
        end
        dialog_open
        @form.index = selector(selt, p_("Forum", "Select post"), @form.index / 3, @form.index / 3) * 3
        dialog_close
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
              dialog_open
              ind = selector(selt, p_("Forum", "Select post"), ind, -1)
              @form.index = sr[ind] * 3 if ind != -1
              dialog_close
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
    if @form.index < @postscount * 3
      menu.option(p_("Forum", "Mention post"), nil, "w") {
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
        form = Form.new([ListBox.new(users, p_("Forum", "User to mention")), EditBox.new(p_("Forum", "Message"), "", "", true), Button.new(p_("Forum", "Mention post")), Button.new(_("Cancel"))])
        loop do
          loop_update
          form.update
          if escape or ((enter or space) and form.index == 3)
            loop_update
            @form.focus
            break
          end
          if (enter or space) and form.index == 2
            mt = srvproc("mentions", { "add" => "1", "user" => users[form.fields[0].index], "message" => form.fields[1].text, "thread" => @thread, "post" => @posts[@form.index / 3].id })
            if mt[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Forum", "The mention has been sent."))
              @form.focus
              break
            end
          end
        end
      }
    end
    if @form.index < @posts.size * 3
      if @type != 2
        menu.option(p_("Forum", "Listen to the thread")) {
          if Configuration.voice == -1 and @type == 0
            text = ""
            for pst in @posts[@form.index / 3..@posts.size]
              text += pst.author + "\r\n" + pst.post + "\r\n" + pst.date + "\r\n\r\n"
            end
            speech(text)
          else
            cur = @form.index / 3 - 1
            while cur < @posts.size
              loop_update
              if speech_actived == false and Win32API.new("$eltenlib", "SapiIsPaused", "", "i").call == 0
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
    s = p_("Forum", "Hide signatures")
    s = p_("Forum", "Show signatures") if LocalConfig["ForumHideSignatures"] == 1
    menu.option(s) {
      if LocalConfig["ForumHideSignatures"] == 0
        LocalConfig["ForumHideSignatures"] = 1
      else
        LocalConfig["ForumHideSignatures"] = 0
      end
      refresh
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
    if @form.index < @postscount * 3 && (((Session.moderator == 1 && @threadclass.forum.group.recommended) || (@threadclass != nil && @threadclass.forum.group.role == 2)) || (@posts[@form.index / 3].author == Session.name))
      post = @posts[@form.index / 3]
      menu.submenu(p_("Forum", "Moderation")) { |m|
        if @type == 0
          if !post.locked
            m.option(p_("Forum", "Edit post"), nil, "e") {
              dialog_open
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
          m.option(p_("Forum", "Delete post")) {
            confirm(p_("Forum", "Are you sure you want to delete this post?")) do
              prm = ""
              if @posts.size == 1
                prm = { "threadid" => @thread, "delete" => 1 }
              else
                prm = { "postid" => @posts[@form.index / 3].id, "threadid" => @thread, "delete" => 2 }
              end
              if srvproc("forum_mod", prm)[0].to_i < 0
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
      }
    end
    menu.option(_("Refresh"), nil, "r") {
      refresh
    }
  end

  def edit_post(post)
    attnames = name_attachments(post.attachments)
    atts = []
    for i in 0...post.attachments.size
      a = post.attachments[i]
      atts.push([a, nil, attnames[i]])
    end
    form = Form.new([EditBox.new(p_("Forum", "edit your post here"), EditBox::Flags::MultiLine, post.post), ListBox.new(atts.map { |a| a[2] }, p_("Forum", "Attachments"), 0, 0, true), Button.new(_("Save")), Button.new(_("Cancel"))])
    form.fields[1].bind_context { |menu|
      if atts.size < 3
        menu.option(p_("Forum", "Add attachment"), nil, "n") {
          l = getfile(p_("Forum", "Select file to attach"), Dirs.documents + "\\")
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
          play("edit_delete")
          form.fields[1].options = atts.map { |a| a[2] }
          form.fields[1].sayoption
        }
      end
    }
    loop do
      loop_update
      form.update
      if form.fields[0].text.size > 1 and (((enter or space) and form.index == 2) or (enter and $key[0x11] and form.index < 2))
        buf = buffer(form.fields[0].text)
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
        if srvproc("forum_mod", { "edit" => "1", "postid" => post.id.to_s, "threadid" => @thread.to_s, "buffer" => buf, "bufatt" => bufatt })[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Forum", "The post has been modified"))
          @lastpostindex = @form.index
          refresh
          break
        end
      end
      break if escape or ((enter or space) and form.index == 3)
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
    sel = ListBox.new(bookmarks.map { |b| b.description + " (" + p_("Forum", "Post %{postnumber} by %{author}") % { "postnumber" => b.postnum + 1, "author" => @posts[b.postnum].author } + "): " + @posts[b.postnum].post[0...100] }, p_("Forum", "Bookmarks"))
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
    c = srvproc("forum_thread", { "thread" => @thread.to_s, "details" => 3 })
    return if c[0].to_i < 0
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
