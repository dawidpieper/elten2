#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

    class Scene_Forum
  @@forumgrpselcol ||= 0
  @@forumfrmselcol ||= 0
  @@forumthrselcol ||= 0
@@sort=0
  
  def initialize(pre = nil, preparam = nil, cat = 0, query = "")
    @pre = pre
    @preparam = preparam
    @lastlist = @cat = cat
    @query = query
    @grpindex ||= []
    @close=false
  end
  
  def main
    if $name == "guest"
      @noteditable = true
    else
      @noteditable = false
    end
    getcache
    return if $scene != self
    if @pre == nil
      groupsmain(@cat)
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
          @grpindex[0] = 3 + @groups.find_index(@query) if @query.is_a?(Struct_Forum_Group)
          usequery
        end
        threadsmain(@preparam)
      end
    end
  end
  
  def makesort(type,cat, sort)
@@sort=sort
if type==0
command=@grpsel.commandoptions[@grpsel.index]
@grpindex[type] = @grpsel.index
      groupsload(cat)
@grpsel.index=@grpsel.commandoptions.find_index(command)||0
@grpsel.focus
else
command=@frmsel.commandoptions[@frmsel.index]
forumsload(cat)
@frmsel.index=@frmsel.commandoptions.find_index(command)||0
@frmsel.focus if type==1
@grpsetindex=@group
end
end

def sortermenu(type, cat, menu)
menu.submenu(p_("Forum", "Sort")) {|m|
m.option(p_("Forum", "Default")) {makesort(type,cat,0)} if @@sort!=0
m.option(p_("Forum", "By name (ascending)")) {makesort(type,cat,1)} if @@sort!=1
m.option(p_("Forum", "By name (descending)")) {makesort(type,cat,-1)} if @@sort!=-1
m.option(p_("Forum", "By unread posts (ascending)")) {makesort(type,cat,2)} if @@sort!=2
m.option(p_("Forum", "By unread posts (descending)")) {makesort(type,cat,-2)} if @@sort!=-2
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
      @@forumgrpselcol = @grpsel.column
      return $scene=Scene_Main.new if escape and type==0
      return groupsmain(0) if (escape or (arrow_left and !$keyr[0x10])) and type!=0
      break if $scene!=self
      if enter or (arrow_right and !$keyr[0x10])
        groupopen(@grpsel.index, type)
break
      end
      break if $scene!=self
    end
  end
  
  def groupsload(type, ll=nil)
    if ll==nil
      ll=@lastll
    else
      @lastll=ll
      end
    case type
    when 0
      @grpindex.delete_at(-1) while @grpindex.size > 1
      return $scene = Scene_Main.new if @groups == nil || @forums == nil || @threads == nil
      @sgroups = []
      spgroups = []
      sgloc = false
      for g in @groups
        if g.role == 1 || g.role == 2
          @sgroups.push(g)
        end
        if sgloc == false and g.lang.downcase == $language[0..1].downcase and g.recommended
          spgroups.push(g) if !@sgroups.include?(g)
          sgloc = true if g.id != 1
        end
      end
      @sgroups += spgroups
      @sgroups.sort! { |a, b|
      if @@sort==0
        x = b.lang
        x = "_" if b.lang.downcase == $language[0..1].downcase
        x += sprintf("%04d", b.id)
        y = a.lang
        y = "_" if a.lang.downcase == $language[0..1].downcase
        y += sprintf("%04d", a.id)
        y <=> x
      else
        groupsorter(a,b)
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
      fmt=fmp=fmr=0
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
        groupsallcnt += 1 if g.open || g.public
        groupsmoderatedcnt += 1 if g.role == 2
      }
      grpselt = [[p_("Forum", "Followed threads"), nil, ft.to_s, fp.to_s, (fp - fr).to_s], [p_("Forum", "Followed forums"), forfol.size.to_s, flt.to_s, flp.to_s, (flp - flr).to_s],[p_("Forum", "Marked threads"), nil, fmt.to_s, fmp.to_s, (fmp - fmr).to_s]] + grpselt + [[p_("Forum", "Recommended groups") + " (#{groupsrecommendedcnt.to_s})"], [p_("Forum", "Open groups") + " (#{groupsopencnt.to_s})"], [p_("Forum", "Invitations") + " (#{groupsinvitedcnt.to_s})"], [p_("Forum", "Moderated groups") + " (#{groupsmoderatedcnt.to_s})"], [p_("Forum", "All groups") + " (#{groupsallcnt.to_s})"], [p_("Forum", "Recently created groups")], [p_("Forum", "Groups popular with my friends")], [p_("Forum", "Threads popular with my friends")], [p_("Forum", "My threads")], [p_("Forum", "Search")]]
      grpselt[0] = [nil] if ft==0
      grpselt[1] = [nil] if forfol.size==0
      grpselt[2] = [nil] if fmt==0
      grpselt[@grpheadindex + @sgroups.size + 2] = [nil] if groupsinvitedcnt == 0
      grpselt[@grpheadindex + @sgroups.size + 3] = [nil] if groupsmoderatedcnt == 0
      grpselh = [nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
      @grpindex[0] = @grpheadindex + @sgroups.size + ll - 1 if ll > 0
    when 1
      @sgroups = []
      spgroups = []
      for g in @groups
        if g.recommended
          if $language[0..1].downcase == g.lang.downcase
            @sgroups.push(g)
          else
            spgroups.push(g)
          end
        end
      end
      @sgroups += spgroups
      @sgroups.sort {|a,b| groupsorter(a,b)} if @@sort!=0
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name + ": " + group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 2
      @sgroups = []
      for g in @groups
        if g.open && g.public && !g.recommended && g.posts > 0
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b|
      if @sort==0
        (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
      else
        groupsorter(a,b)
      end
      }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 3
      @sgroups = []
      for g in @groups
        if g.role == 5
          @sgroups.push(g)
        end
      end
      @sgroups.sort! {|a,b|
      if @@sort==0
      (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
    else
      groupsorter(a,b)
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
        if g.role == 2
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b|
      if @@sort==0
        (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
      else
        groupsorter(a,b)
        end
        }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 5
      @sgroups = []
      for g in @groups
        if (g.public || g.open) && g.forums > 0
          @sgroups.push(g)
        end
      end
      @sgroups.sort! { |a, b|
      if @@sort==0
      (b.posts * b.acmembers ** 2) <=> (a.posts * a.acmembers ** 2)
    else
      groupsorter(a,b)
      end
      }
      @grpheadindex = 0
      grpselt = []
      for group in @sgroups
        grpselt.push([group.name, group.founder, group.description, group.forums.to_s, group.threads.to_s, group.posts.to_s, (group.posts - group.readposts).to_s])
      end
      grpselh = [nil, p_("Forum", "Administrator"), nil, p_("Forum", "Forums"), p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    when 6
      @sgroups = []
      for g in @groups
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
    when 7
      grp = srvproc("forum_popular", { "type" => "groups" })
      @sgroups = []
      if grp[0].to_i == 0
        for l in grp[1..-1]
          g = nil
          @groups.each { |r| g = r if r.id == l.to_i }
          @sgroups.push(g) if g.open || g.public if g != nil
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
    @grpsel = TableSelect.new(grpselh, grpselt, @grpindex[type], p_("Forum", "Forum"), true)
    @grpsel.column = @@forumgrpselcol if @@forumgrpselcol != nil
    @grpsel.bind_context(p_("Forum", "Forum")) { |menu| context_groups(menu, type) }
    @grpsel.focus
    return [@sgroups, @grpheadindex]
  end
  
  def groupsorter(a,b)
    result=0
    case @@sort.abs
    when 1
      result=polsorter(a.name,b.name)
      when 2
        result=(a.posts-a.readposts)<=>(b.posts-b.readposts)
  else
    result=1
  end
result*=-1 if @@sort<0
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
      return threadsmain(-8)
    elsif index == @grpheadindex + @sgroups.size + 8
      return threadsmain(-9)
    elsif index == @grpheadindex + @sgroups.size + 9
      @query = input_text(p_("Forum", "Enter a phrase to look for"), "ACCEPTESCAPE")
      loop_update
      if @query != "\004ESCAPE\004"
        usequery
        return threadsmain(-3)
      end
    else
      g = @sgroups[index - @grpheadindex]
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
      menu.option(p_("Forum", "Group summary")) {
        g = @sgroups[@grpsel.index - @grpheadindex]
        s = g.name + "\r\n\r\n"
        s += p_("Forum", "Language") + ": " + g.lang + "\r\n"
        s += p_("Forum", "Members") + ": " + g.acmembers.to_s + "\r\n"
        s += p_("Forum", "Founder") + ": " + g.founder + "\r\n"
        if g.created > 0
          t = Time.at(g.created)
          s += p_("Forum", "Founded at") + ": " + sprintf("%04d-%02d-%02d", t.year, t.month, t.day) + "\r\n"
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
        input_text(p_("Forum", "Group summary"), "READONLY|ACCEPTESCAPE", s)
        loop_update
      }
      menu.option(p_("Forum", "Group members")) {
        groupmembers(@sgroups[@grpsel.index - @grpheadindex])
      }
      if @sgroups[@grpsel.index - @grpheadindex].role == 2
        menu.option(p_("Forum", "Invite")) {
          u = input_text(p_("Forum", "Type user to invite"), "ACCEPTESCAPE")
          if u != "\004ESCAPE\004"
            u = finduser(u) if u.downcase == finduser(u).downcase
            if user_exist(u) == false
              alert(p_("Forum", "This user does not exist"))
            else
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
        menu.option(s) {
          if @sgroups[@grpsel.index - @grpheadindex].role == 0 && ((@sgroups[@grpsel.index - @grpheadindex].public && !@sgroups[@grpsel.index - @grpheadindex].open) || (@sgroups[@grpsel.index - @grpheadindex].open && !@sgroups[@grpsel.index - @grpheadindex].public))
            s = p_("Forum", "Do you wish to ask to be enrolled in %{groupname}")
          else
            s = p_("Forum", "Are you sure you want to join %{groupname}?")
          end
          confirm(s%{ "groupname" => @sgroups[@grpsel.index - @grpheadindex].name }) {
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
          @grpsel.focus
        }
      end
      s = ""
      s = p_("Forum", "Leave") if (@sgroups[@grpsel.index - @grpheadindex].role == 1 or @sgroups[@grpsel.index - @grpheadindex].role == 2 or @sgroups[@grpsel.index - @grpheadindex].role == 4) and @sgroups[@grpsel.index - @grpheadindex].founder != $name
      s = p_("Forum", "Refuse invitation") if @sgroups[@grpsel.index - @grpheadindex].role == 5
      if s != ""
        menu.option(s) {
          confirm(p_("Forum", "Are you sure you want to leave %{groupname}?")%{ "groupname" => @sgroups[@grpsel.index - @grpheadindex].name }) {
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
      if @sgroups[@grpsel.index - @grpheadindex].founder == $name
        menu.option(p_("Forum", "Edit group")) {
          g = @sgroups[@grpsel.index - @grpheadindex]
          fields = [Edit.new(p_("Forum", "Group name"), "", g.name, true), Edit.new(p_("Forum", "Group description"), "multiline", g.description, true), Select.new([p_("Forum", "Hidden"), p_("Forum", "Public")], true, g.public.to_i, p_("Forum", "Group type"), true), Select.new([p_("Forum", "open (everyone can join)"), p_("Forum", "Moderated (everyone can request)")], true, g.open.to_i, p_("Forum", "Group join type"), true), nil, Button.new(_("Cancel"))]
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
              form.fields[3].commandoptions = [p_("Forum", "closed (only invited users can join)"), p_("Forum", "Moderated (everyone can request)")]
            when 1
              form.fields[3].commandoptions = [p_("Forum", "Moderated (everyone can request)"), p_("Forum", "open (everyone can join)")]
            end
            if form.fields[4] != nil and form.fields[4].pressed?
              r = srvproc("forum_groups", { "ac" => "edit", "groupid" => g.id.to_s, "groupname" => form.fields[0].text, "bufdescription" => buffer(form.fields[1].text).to_s, "public" => form.fields[2].index.to_s, "open" => form.fields[3].index.to_s })
              if r[0].to_i < 0
                alert(_("Error"))
              else
                alert(_("Saved"))
              end
              getcache
              return groupsmain(@lastlist)
            end
            break if escape or form.fields[5].pressed?
          end
          loop_update
        }
      end
      if @sgroups[@grpsel.index - @grpheadindex].forums == 0 and @sgroups[@grpsel.index - @grpheadindex].founder == $name
        menu.option(p_("Forum", "Delete group")) {
          confirm(p_("Forum", "Are you sure you want to delete %{groupname}?")%{ "groupname" => @sgroups[@grpsel.index - @grpheadindex].name }) {
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
    sortermenu(0, type, menu)
    menu.option(p_("Forum", "New group")) {
      newgroup
    }
    menu.option(_("Refresh")) {
      @grpindex[type] = @grpsel.index
      getcache
      groupsmain
    }
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
      sel = Select.new(selt, true, 0, p_("Forum", "Members"))
      usermenu(users[sel.index]) if enter
      sel.bind_context { |menu|
        menu.useroption(users[sel.index])
        m1 = nil
        m2 = nil
        if !((group.founder != $name or users[sel.index] == $name))
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
        if !((group.founder != $name and group.role != 2) or $name == users[sel.index])
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
            s=""
            if roles[sel.index] == 1
              cat = "moderationgrant"
              s=p_("Forum", "Are you sure you want to grant moderation privileges in %{groupname} to user %{user}?")
            else
              cat = "moderationdeny"
              s=p_("Forum", "Are you sure you want to deny %{user}'s moderation privileges?")
            end
            confirm(s%{ "user" => users[sel.index], "groupname" => group.name }) {
              r = srvproc("forum_groups", { "ac" => "privileges", "pr" => cat, "user" => users[sel.index], "groupid" => group.id.to_s })
              if r[0].to_i < 0
                alert(_("Error"))
              else
                if roles[sel.index] == 2
                  roles[sel.index] = 1
                  sel.commandoptions[sel.index].sub!(p_("Forum", "Moderator"), "")
                else
                  roles[sel.index] = 2
                  sel.commandoptions[sel.index].sub!(" ", " (#{p_("Forum", "Moderator")}) ")
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
              s=""
              if roles[sel.index] == 1
                if group.open && group.public
                  cat = "ban"
                  s=p_("Forum", "Are you sure you want to ban %{user} in %{groupname}?")
                else
                  cat = "kick"
                  s=p_("Forum", "Are you sure you want to kick %{user} of %{groupname}?")
                end
              elsif roles[sel.index] == 3
                cat = "unban"
                s=p_("Forum", "Are you sure you want to unban %{user} in %{groupname}?")
              elsif roles[sel.index] == 4
                c = selector([p_("Forum", "Accept invitation"), p_("Forum", "Refuse invitation"), _("Cancel")], "", 0, 2, 1)
                case c
                when 0
                  cat = "accept"
                  s=p_("Forum", "Do you want to accept request of user %{user}")
                when 1
                  cat = "refuse"
                  s=p_("Forum", "Do you want to refuse request of user %{user}")
                when 2
                  cat = nil
                end
              end
              if cat != nil
                confirm(s%{ "user" => users[sel.index], "groupname" => group.name }) {
                  r = srvproc("forum_groups", { "ac" => "user", "pr" => cat, "user" => users[sel.index], "groupid" => group.id.to_s })
                  if r[0].to_i < 0
                    alert(_("Error"))
                  else
                    if cat == "ban"
                      roles[sel.index] = 3
                    elsif cat == "unban" || cat == "accept"
                      roles[sel.index] = 1
                      sel.commandoptions[sel.index].gsub!(p_("Forum", "Banned"), "")
                      sel.commandoptions[sel.index].gsub!(p_("Forum", "Waiting for review"), "")
                    elsif cat == "refuse"
                      sel.disable_item(sel.index)
                    end
                    alert(p_("Forum", "Privileges of this user have been changed."))
                  end
                }
              end
            else
              confirm(p_("Forum", "Are you sure you want to resign your administrative privileges in %{groupname} and pass them to %{user}?")%{ "user" => users[sel.index], "groupname" => group.name }) {
                r = srvproc("forum_groups", { "ac" => "privileges", "pr" => "passadmin", "user" => users[sel.index], "groupid" => group.id.to_s })
                if r[0].to_i < 0
                  alert(_("Error"))
                else
                  group.founder = users[sel.index]
                  sel.commandoptions[sel.index].sub!(" ", " (#{p_("Forum", "Administrator")}) ")
                  for i in 0...users.size
                    sel.commandoptions[i].sub!(p_("Forum", "Administrator"), "") if users[i] == $name
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

  def newgroup
    ln = []
    lnindex = 0
    for lk in $langs.keys
      l = $langs[lk]
      ln.push(l["name"] + " (" + l["nativeName"] + ")")
      lnindex = ln.size - 1 if $language.downcase[0..1] == lk.downcase[0..1]
    end
    fields = [Edit.new(p_("Forum", "Group name"), "", "", true), Edit.new(p_("Forum", "Group description"), "multiline", "", true), Select.new(ln, true, lnindex, p_("Forum", "Language"), true), Select.new([p_("Forum", "Hidden"), p_("Forum", "Public")], true, 0, p_("Forum", "Group type"), true), Select.new([p_("Forum", "open (everyone can join)"), p_("Forum", "Moderated (everyone can request)")], true, 0, p_("Forum", "Group join type"), true), nil, Button.new(_("Cancel"))]
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
        form.fields[4].commandoptions = [p_("Forum", "closed (only invited users can join)"), p_("Forum", "Moderated (everyone can request)")]
      when 1
        form.fields[4].commandoptions = [p_("Forum", "Moderated (everyone can request)"), p_("Forum", "open (everyone can join)")]
      end
      if form.fields[5] != nil and form.fields[5].pressed?
        r = srvproc("forum_groups", { "ac" => "create", "groupname" => form.fields[0].text, "bufdescription" => buffer(form.fields[1].text).to_s, "lang" => $langs.keys[form.fields[2].index].to_s, "public" => form.fields[3].index.to_s, "open" => form.fields[4].index.to_s })
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
      @@forumfrmselcol = @frmsel.column
      if (arrow_left and !$keyr[0x10]) or escape
        @frmindex = nil
        return groupsmain
      end
      break if $scene!=self
      if (enter or (arrow_right and !$keyr[0x10])) and @sforums.size > 0
        @frmindex = @frmsel.index
        return threadsmain(@sforums[@frmsel.index].name)
      end
      break if $scene!=self
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
          @sforums.sort! {|a,b| forumsorter(a,b)} if @@sort!=0
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
      frmselt.push(ftm)
    end
    @frmindex = 0 if @frmindex == nil
    frmselh = [nil, nil, p_("Forum", "Threads"), p_("Forum", "posts"), p_("Forum", "Unread")]
    @frmsel = TableSelect.new(frmselh, frmselt, @frmindex, p_("Forum", "Select forum"), true)
    @frmsel.column = @@forumfrmselcol if @@forumfrmselcol != nil
          @frmsel.bind_context(p_("Forum", "Forum")) { |menu| context_forums(menu) }
    @frmsel.focus
    end
  
    def forumsorter(a,b)
    result=0
    case @@sort.abs
    when 1
      result=polsorter(a.fullname,b.fullname)
      when 2
        result=(a.posts-a.readposts)<=>(b.posts-b.readposts)
  else
    result=1
  end
result*=-1 if @@sort<0
return result
end

  def context_forums(menu)
    if @frmsel.commandoptions.size > 0
      menu.option(p_("Forum", "Open")) {
        @frmindex = @frmsel.index
        threadsmain(@sforums[@frmsel.index].name)
      }
      s = p_("Forum", "Follow this forum")
      s = p_("Forum", "Unfollow this forum") if @sforums.size > 0 and @sforums[@frmsel.index].followed == true
      menu.option(s) {
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
      menu.option(p_("Forum", "Mark this forum as read")) {
        if @sforums[@frmsel.index].posts - @sforums[@frmsel.index].readposts < 100 or confirm(p_("Forum", " All posts on this forum will be marked as read. Are you sure you want to continue?")) == 1
          if srvproc("forum_markasread", { "forum" => @sforums[@frmsel.index].name })[0].to_i == 0
            for t in @threads
              t.readposts = t.posts if t.forum.name == @sforums[@frmsel.index].name
            end
            @sforums[@frmsel.index].readposts = @sforums[@frmsel.index].posts
            @frmsel.commandoptions[@frmsel.index].gsub!("\004NEW\004", "")
            @frmsel.commandoptions[@frmsel.index].gsub!(/#{p_("Forum", "Unread")}\: (\d+)/, "#{p_("Forum", "Unread")}: 0")
            alert(p_("Forum", "The forum has been marked as read."))
          else
            alert(_("Error"))
          end
        end
      }
    end
    groupclass = Struct_Forum_Group.new
    @groups.each { |g| groupclass = g if g.id == @group }
    if groupclass.founder == $name or groupclass.role == 2
      menu.option(p_("Forum", "New forum")) {
        newforum
        getcache
        forumsmain(@group)
      }
      if @sforums.size > 0
        menu.option(p_("Forum", "Edit forum")) {
          form = Form.new([Edit.new(p_("Forum", "Forum name"), "", @sforums[@frmsel.index].fullname, true), Edit.new(p_("Forum", "Forum description"), "multiline", @sforums[@frmsel.index].description, true), nil, Button.new(_("Cancel"))])
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
        menu.option(p_("Forum", "Change forum position")) {
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
          menu.option(p_("Forum", "Delete forum")) {
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
    end
    sortermenu(1, @group, menu)
    menu.option(_("Refresh")) {
      getcache
      main
    }
  end

  def newforum
    fields = [Edit.new(p_("Forum", "Forum name"), "", "", true), Edit.new(p_("Forum", "Forum description"), "multiline", "", true), Select.new([p_("Forum", "Text forum"), p_("Forum", "Voice forum")], true, 0, p_("Forum", "Forum type"), true), nil, Button.new(_("Cancel"))]
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
        u = "ac=forumcreate\&groupid=#{groupclass.id.to_s}\&forumname=#{fields[0].text.urlenc}\&forumtype=#{form.fields[2].index.to_s}"
        if form.fields[1].text != ""
          b = buffer(form.fields[1].text)
          u += "\&bufforumdescription=#{b.to_s}"
        end
        f = srvproc("forum_groups", "name=#{$name}\&token=#{$token}\&#{u}")
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
      mnt = srvproc("mentions", { "list" => "1" })
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
    for t in @threads
      case id
              when -10
        @sthreads.push(t) if t.marked == true
      when -9
        @sthreads.push(t) if t.author == $name
              when -8
        @sthreads.push(t) if @popular.include?(t.id) and t.readposts <= t.posts / 1.1
      when -7
        for mention in @mentions
          if t.id == mention.thread
            t.mention = mention
            @sthreads.push(t)
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
      index = i if thread.id == @pre
      tmp = [thread.name]
      tmp[0] += "\004INFNEW{#{p_("Forum", "New")}: }\004" if thread.readposts < thread.posts and (id != -2 and id != -4 and id != -6 and id != -7)
      tmp[0] += "\004CLOSED\004" if thread.closed
      tmp[0] += "\004PINNED\004" if thread.pinned
      if id == -7
        tmp[0] += " . #{p_("Forum", "Montioned by")}: #{thread.mention.author} (#{thread.mention.message})"
      end
      if id == -3 or id == -6 or id == -7
        tmp[0] += " (#{thread.forum.fullname}, #{thread.forum.group.name})"
      end
      tmp += [thread.author.lore, thread.posts.to_s, (thread.posts - thread.readposts).to_s]
      thrselt.push(tmp)
    end
    @pre = nil
    @preparam = nil
    header = p_("Forum", "Select thread")
    header = "" if id == -2 or id == -4 or id == -6 or id == -7
    thrselh = [nil, p_("Forum", "Author"), p_("Forum", "posts"), p_("Forum", "Unread")]
    @thrsel = TableSelect.new(thrselh, thrselt, index, header, true)
    @thrsel.column = @@forumthrselcol if @@forumthrselcol != nil
          @thrsel.bind_context(p_("Forum", "Forum")) { |menu| context_threads(menu) }
    @thrsel.focus
    loop do
      loop_update
      @thrsel.update
      @@forumthrselcol = @thrsel.column
      if (arrow_left and !$keyr[0x10]) or escape
        if id.is_a?(String)
          return forumsmain
        elsif id == -2 or id == -4 or id == -6 or id == -7
          return $scene = Scene_WhatsNew.new
        else
          return groupsmain
        end
      end
      break if $scene!=self
      if enter or (arrow_right and !$keyr[0x10]) and @sthreads.size > 0
threadopen(@thrsel.index)
      end
      break if $scene!=self
    end
  end

  def threadopen(index)
            if @group == -5
          $scene = Scene_Forum_Thread.new(@sthreads[index], -5, @cat, @query)
        else
          if @forum == -7
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
      s = p_("Forum", "Unmark this thread") if @sthreads[@thrsel.index].marked== true
      menu.option(s) {
      m=0
      m=1 if @sthreads[@thrsel.index].marked== false
          if srvproc("forum_threadaction", { "ac"=>"marking", "mark" => m, "threadid" => @sthreads[@thrsel.index].id })[0].to_i < 0
            alert(_("Error"))
          else
            if m==0
            alert(p_("Forum", "Thread unmarked"))
          else
            alert(p_("Forum", "Thread marked"))
            end
            @sthreads[@thrsel.index].marked = !@sthreads[@thrsel.index].marked
          end
      }
            s = p_("Forum", "Add to followed threads list")
      s = p_("Forum", "Unfollow this thread") if @sthreads[@thrsel.index].followed == true
      menu.option(s) {
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
      menu.option(p_("Forum", "Thread statistics")) {
      t=srvproc("forum_threadaction", {'ac'=>'stats', 'threadid'=>@sthreads[@thrsel.index].id})
      s=""
      if t[0].to_i==0
        s+=p_("Forum", "Followers: %{count_followers}")%{'count_followers'=>t[1].to_i}+"\n"
        s+=p_("Forum", "All mentions: %{count_mentions}")%{'count_mentions'=>t[2].to_i}+"\n"
        s+=p_("Forum", "Unique authors: %{count_authors}")%{'count_authors'=>t[3].to_i}+"\n"
        s+=p_("Forum", "Readers: %{count_readers}")%{'count_readers'=>t[4].to_i}+"\n"
        s+=p_("Forum", "Users that have read less than 50 percent of posts: %{count_readers}")%{'count_readers'=>t[5].to_i}+"\n"
        s+=p_("Forum", "Users that have read over 90 percent of posts: %{count_readers}")%{'count_readers'=>t[6].to_i}+"\n"
        s+=p_("Forum", "Users that have read all posts: %{count_readers}")%{'count_readers'=>t[7].to_i}+"\n"
      end
      input_text(p_("Forum", "Thread statistics summary"), "ACCEPTESCAPE|READONLY", s)
      }
    end
    forum=@forum
    @forums.each {|f| forum=f if f.name==@forum}
    if forum.is_a?(String)==false and forum.is_a?(Integer)==false and @noteditable!=true and ((forum.group.public==true and forum.group.open==true) or [1,2].include?(forum.group.role)) and forum.group.role!=3
      menu.option(p_("Forum", "New thread")) {
        newthread
        getcache
        threadsmain(@forum)
      }
    end
    if @sthreads.size > 0
      if ($rang_moderator == 1 && @sthreads[@thrsel.index].forum.group.recommended) || @sthreads[@thrsel.index].forum.group.role == 2
        menu.submenu(p_("Forum", "Moderation")) {|m|
        m.option(p_("Forum", "Move thread")) {
          selt = []
          ind = 0
          mforums = []
          for f in @forums
            mforums.push(f) if f.group.role == 2 or ($rang_moderator == 1 && f.group.recommended)
          end
          for f in mforums
            selt.push(f.fullname + " (" + f.group.name + ")")
            ind = selt.size-1 if f.name == @sthreads[@thrsel.index].forum.name
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
          name = input_text(p_("Forum", "Type a new thread name"), "ACCEPTESCAPE", @sthreads[@thrsel.index].name)
          if name != "\004ESCAPE\004"
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
          confirm(p_("Forum", "Do you really want to delete thread %{thrname}?")%{ "thrname" => @sthreads[@thrsel.index].name }) do
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
        s = p_("Forum", "Open thread") if @sthreads[@thrsel.index].closed and ($rang_moderator == 1 && @sthreads[@thrsel.index].forum.group.recommended) || @sthreads[@thrsel.index].forum.group.role == 2
        m.option(s) {
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
        s = p_("Forum", "Unpin thread") if @sthreads[@thrsel.index].pinned and ($rang_moderator == 1 && @sthreads[@thrsel.index].forum.group.recommended) || @sthreads[@thrsel.index].forum.group.role == 2
        m.option(s) {
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
        }
      end
    end
    menu.option(_("Refresh")) {
      @pre = @sthreads[@thrsel.index].id
      getcache
      threadsmain(@forum)
    }
  end

  def newthread
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
    if @forumtype == 0
      fields = [Edit.new(p_("Forum", "Thread's title"), "", "", true), Edit.new(p_("Forum", "Post"), "MULTILINE", "", true), nil, nil, Button.new(p_("Forum", "Attach a poll")), nil, Button.new(p_("Forum", "Attach a file"))]
      fields[11] = Edit.new(p_("Forum", "Nick:"), "", "", true) if $rang_moderator == 1 or $rang_developer == 1
    else
      fields = [Edit.new(p_("Forum", "Thread's title"), "", "", true), Button.new(p_("Forum", "Record a post")), nil]
    end
    fields[7..10] = [CheckBox.new(p_("Forum", "Add to followed threads list")), Select.new(forums, true, forumindex, p_("Forum", "Forum")), nil, Button.new(_("Cancel"))]
    form = Form.new(fields)
    polls = []
    files = []
    loop do
      loop_update
      if @forumtype == 0 and (form.fields[0].text != "" and form.fields[1].text != "")
        form.fields[9] = Button.new(p_("Forum", "Send"))
      elsif @forumtype == 0
        form.fields[9] = nil
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
                form.fields[3] ||= Select.new([], true, 0, p_("Forum", "Polls"), true)
                form.fields[3].commandoptions.push(names[ind])
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
        form.fields[3].commandoptions.delete_at(form.fields[3].index)
        form.fields[3].index -= 1 if form.fields[3].index > 0
        if polls.size == 0
          form.fields[3] = nil
          form.index = 4
          form.focus
        else
          speech(form.fields[3].commandoptions[form.fields[3].index])
        end
      end
      if (enter or space) and form.index == 6 and files.size < 3
        l = getfile(p_("Forum", "Select file to attach"), getdirectory(5) + "\\")
        if l != "" and l != nil
          if files.include?(l)
            alert(p_("Forum", "This file has been already attached"))
          else
            if File.size(l) > 16777216
              alert(p_("Forum", "This file is too large"))
            else
              files.push(l)
              form.fields[5] ||= Select.new([], true, 0, p_("Forum", "Attachments"), true)
              form.fields[5].commandoptions.push(File.basename(l))
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
        form.fields[5].commandoptions.delete_at(form.fields[5].index)
        form.fields[5].index -= 1 if form.fields[5].index > 0
        if files.size == 0
          form.fields[5] = nil
          form.index = 6
          form.focus
        else
          speech(form.fields[5].commandoptions[form.fields[5].index])
        end
      end
      if @forumtype == 0
        if ($key[0x11] == true or form.index == 9) and enter
          play("list_select")
          thread = form.fields[0].text_str
          text = form.fields[1].text_str
          break
        end
      else
        if (enter or space) and form.index == 1
          if recpostst == 0 or recpostst == 2
            @r = Recorder.start($tempdir + "/audiothreadpost.opus", 96)
            play("recording_start")
            form.fields[1] = Button.new(p_("Forum", "Stop recording"))
            recpostst = 1
            form.fields[2] = nil
          elsif recpostst == 1
            @r.stop
            play("recording_stop")
            recpostst = 2
            form.fields[1] = Button.new(p_("Forum", "Record a post once again"))
            form.fields[2] = Button.new(p_("Forum", "Play post"))
            fields[9] = Button.new(p_("Forum", "Send"))
          end
        end
        player($tempdir + "/audiothreadpost.opus", "", true) if (enter or space) and form.index == 2 and recpostst == 2
        if (enter or space) and form.index == 9
          if recpostst == 1
            play("recording_stop")
            @r.stop
          end
          break
        end
      end
      if escape or (((form.index == 10)) and enter)
        @r.stop if @rectitlest == 1 or @recpostst == 1
        loop_update
        return
        break
      end
    end
    if @forumtype == 0
      buf = buffer(text).to_s
      prm = { "forumname" => forumclasses[form.fields[8].index].name, "threadname" => thread, "buffer" => buf }
      if form.fields[11] != nil
        prm["uselore"] = "1"
        prm["lore"] = form.fields[11].text_str
      end
      prm["follow"] = "1" if form.fields[7].checked == 1
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
      waiting
      flp = readfile($tempdir + "/audiothreadpost.opus")
      if flp[0..3] != "OggS"
        alert(_("Error"))
        return $scene = Scene_Main.new
      end
      boundary = ""
      boundary = "----EltBoundary" + rand(36 ** 32).to_s(36) while flp.include?(boundary)
      data = "--" + boundary + "\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{flp}\r\n--#{boundary}--"
      length = data.size
      host = $srv.delete("/")
      q = "POST /srv/forum_edit.php?name=#{$name}\&token=#{$token}\&threadname=#{form.fields[0].text_str.urlenc}\&forumname=#{forumclasses[form.fields[8].index].name.urlenc}\&audio=1\&follow=#{form.fields[7].checked.to_s} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
      a = connect(host, 80, q).delete("\0")
      for i in 0..a.size - 1
        if a[i..i + 3] == "\r\n\r\n"
          s = i + 4
          break
        end
      end
      if s == nil
        alert(_("Error"))
        return
      end
      sn = a[s..a.size - 1]
      a = nil
      bt = sn.split("\r\n")
      ft = bt[1].to_i
      waiting_end
    end
    if ft[0].to_i == 0
      alert(p_("Forum", "Thread has been created."))
    else
      alert(p_("Forum", "Error creating thread!"))
    end
  end

  def getcache
    c = srvproc("forum_struct", "name=#{$name}\&token=#{$token}", 1).split("\r\n")
    if c[0].to_i < 0
      alert(_("Error"))
      @groups = []
      @forums = []
      @threads = []
      $scene = Scene_Main.new
      return
    end
    l = 1
    while l < c.size
      objs = c[l + 1].to_i
      strobjs = c[l + 2].to_i
      if c[l] == "groups"
        groupscache(c[(l + 3)..(l + 3 + objs * strobjs)], objs, strobjs)
      elsif c[l] == "forums"
        forumscache(c[(l + 3)..(l + 3 + objs * strobjs)], objs, strobjs)
      elsif c[l] == "threads"
        threadscache(c[(l + 3)..(l + 3 + objs * strobjs)], objs, strobjs)
      end
      l += 3 + objs * strobjs
    end
  end

  def groupscache(c, objs, strobjs)
    @groups = []
    for i in 0...objs
      for j in 0...strobjs
        line = c[i * strobjs + j]
        case j
        when 0
          @groups.push(Struct_Forum_Group.new(line.to_i))
        when 1
          @groups.last.name = line
        when 2
          @groups.last.founder = line
        when 3
          @groups.last.description = line.gsub("$", "\r\n")
        when 4
          @groups.last.lang = line
        when 5
          @groups.last.recommended = true if line.to_i == 1
        when 6
          @groups.last.open = true if line.to_i == 1
        when 7
          @groups.last.public = true if line.to_i == 1
        when 8
          @groups.last.role = line.to_i
        when 9
          @groups.last.forums = line.to_i
        when 10
          @groups.last.threads = line.to_i
        when 11
          @groups.last.posts = line.to_i
        when 12
          @groups.last.readposts = line.to_i
        when 13
          @groups.last.acmembers = line.to_i
          @groups.last.name + ": " + @groups.last.acmembers.to_s
        when 14
          @groups.last.created = line.to_i
        end
      end
    end
  end

  def forumscache(c, objs, strobjs)
    groupids = {}
    @groups.each { |g| groupids[g.id] = g }
    @forums = []
    for i in 0...objs
      for j in 0...strobjs
        line = c[i * strobjs + j]
        case j
        when 0
          @forums.push(Struct_Forum_Forum.new(line))
        when 1
          @forums.last.fullname = line
        when 2
          @forums.last.type = line.to_i
        when 3
          @forums.last.group = groupids[line.to_i]
        when 4
          @forums.last.description = line.gsub("$", "\r\n")
        when 5
          @forums.last.followed = true if line.to_i > 0
        when 6
          @forums.last.threads = line.to_i
        when 7
          @forums.last.posts = line.to_i
        when 8
          @forums.last.readposts = line.to_i
        end
      end
    end
  end

  def threadscache(c, objs, strobjs)
    forumids = {}
    @forums.each { |f| forumids[f.id] = f }
    @threads = []
    for i in 0...objs
      for j in 0...strobjs
        line = c[i * strobjs + j]
        case j
        when 0
          @threads.push(Struct_Forum_Thread.new(line.to_i))
        when 1
          @threads.last.name = line
        when 2
          @threads.last.author = line
        when 3
          @threads.last.forum = forumids[line]
        when 4
          @threads.last.followed = true if line.to_i > 0
        when 5
          @threads.last.posts = line.to_i
        when 6
          @threads.last.readposts = line.to_i
        when 7
          @threads.last.pinned = true if line.to_i > 0
        when 8
          @threads.last.closed = true if line.to_i > 0
          when 9
            @threads.last.marked = true if line.to_i > 0
        end
      end
    end
  end

  def getstruct
    getcache
    return { "groups" => @groups, "forums" => @forums, "threads" => @threads }
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
  def initialize(thread, param = nil, cat = 0, query = "", mention = nil)
    @threadclass = thread
    @param = param
    @cat = cat
    @query = query
    @mention = mention
    @thread = @threadclass.id
    srvproc("mentions", { "notice" => "1", "id" => mention.id }) if mention != nil
  end

  def main
    if $name == "guest"
      @noteditable = true
    elsif @threadclass.closed
      @noteditable = true
    else
      @noteditable = false
      @noteditable = true if (![1, 2].include?(@threadclass.forum.group.role) and @threadclass.forum.group.open == false) or @threadclass.forum.group.role == 3
    end
refresh
    loop do
      loop_update
      @form.update
      navupdate
      if @noteditable == false
        case @type
        when 0
          textsendupdate
        when 1
          audiosendupdate
        end
      end
      if escape or @form.fields[-1].pressed?
        speech_stop
        $scene = Scene_Forum.new(@thread, @param, @cat, @query)
        return
      end
      if enter and @form.index < @postscount * 3 and @form.index % 3 == 1
        pl = @posts[@form.index / 3].polls[@form.fields[@form.index].index]
        voted = false
        voted = true if srvproc("polls", { "voted" => "1", "poll" => pl.to_s })[1].to_i == 1
        selt = [p_("Polls", "Vote"), p_("Polls", "Show results")]
        selt[0] = nil if voted
        case menuselector(selt)
        when 0
          insert_scene(Scene_Polls_Answer.new(pl.to_i, Scene_Main.new))
        when 1
          insert_scene(Scene_Polls_Results.new(pl.to_i, Scene_Main.new))
        end
        loop_update
        @form.focus
      end
      if enter and @form.index < @postscount * 3 and @form.index % 3 == 2
        fl = @posts[@form.index / 3].attachments[@form.fields[@form.index].index]
        nm = name_attachments([fl]).first
        loc = getfile(p_("Forum", "Where to save this file?"), getdirectory(40) + "\\", true, "Documents")
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
        l = getfile(p_("Forum", "Select file to attach"), getdirectory(5) + "\\")
        if l != "" and l != nil
          if @attachments.include?(l)
            alert(p_("Forum", "This file has been already attached"))
          else
            if File.size(l) > 16777216
              alert(p_("Forum", "This file is too large"))
            else
              @attachments.push(l)
              @form.fields[@form.fields.size - 3] ||= Select.new([], true, 0, p_("Forum", "Attachments"), true)
              @form.fields[@form.fields.size - 3].commandoptions.push(File.basename(l))
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
        @form.fields[@form.fields.size - 3].commandoptions.delete_at(@form.fields[@form.fields.size - 3].index)
        @form.fields[@form.fields.size - 3].index -= 1 if @form.fields[@form.fields.size - 3].index > 0
        if @attachments.size == 0
          @form.fields[@form.fields.size - 3] = nil
          @form.index = @form.fields.size - 2
          @form.focus
        else
          speech(@form.fields[@form.fields.size - 3].commandoptions[@form.fields[@form.fields.size - 3].index])
        end
      end
      break if $scene != self
    end
  end
  
  def refresh
    lastindex=nil
    lastindex=@form.index if @form!=nil
    index=-1
    getcache
    @fields = []
    return if @posts == nil
    for i in 0..@posts.size - 1
      post = @posts[i]
      index = i * 3 if index == -1 and @param == -3 and @query.is_a?(String) and post.post.downcase.include?(@query.downcase)
      index = i * 3 if @mention != nil and @param == -7 and post.id == @mention.post
      @fields += [Edit.new(post.authorname, "MULTILINE|READONLY", post.post + post.signature + post.date + "\r\n" + (i + 1).to_s + "/" + @posts.size.to_s, true), nil, nil]
      @fields[-1] = Select.new(name_attachments(post.attachments), true, 0, p_("Forum", "Attachments"), true) if post.attachments.size > 0
      if post.polls.size > 0
        names = []
        for o in post.polls
          pl = srvproc("polls", { "get" => "1", "poll" => o.to_s })
          names.push(pl[2].delete("\r\n")) if pl[0].to_i == 0 and pl.size > 1
        end
        @fields[-2] = Select.new(names, true, 0, p_("Forum", "Polls"), true) if names.size == post.polls.size
      end
    end
    index = 0 if index == -1
    index = @lastpostindex if @lastpostindex != nil
    index = 0 if index > @fields.size
    @type = 0
    @type = 1 if @posts.size > 0 and @posts[0].post.include?("\004AUDIO\004")
    if @noteditable == false
      case @type
      when 0
        @fields += [Edit.new(p_("Forum", "Your answer"), "MULTILINE", "", true), nil, nil, nil, nil, nil, Button.new(p_("Forum", "Attach a file"))]
      else
        @fields += [Button.new(p_("Forum", "Record a new post")), nil, nil, nil, nil, nil, nil]
      end
    else
      @fields += [nil, nil, nil, nil, nil, nil, nil]
    end
    @fields.push(Button.new(p_("Forum", "Return")))
    index=lastindex if lastindex!=nil && index<@form.fields.size
    @attachments = []
    @form = Form.new(@fields, index)
    @form.bind_context(p_("Forum", "Forum")) {|menu|context(menu)}
    end

  def navupdate
    if $key[0x11] and !$key[0x12]
      if $key[0xbc]
        @form.index = 0
        @form.focus
      elsif $key[0xbe]
        @form.index = @postscount * 3 - 3
        @form.focus
      elsif $key[0x44] and @type == 0 and @form.index < @postscount * 3 and @noteditable == false
        @form.fields[@postscount * 3].settext("\r\n--Cytat (#{@posts[@form.index / 3].authorname}):\r\n#{@posts[@form.index / 3].post}\r\n--Koniec cytatu\r\n#{@form.fields[@postscount * 3].text_str}")
        @form.fields[@postscount * 3].index = 0
        @form.index = @postscount * 3
        @form.focus
      elsif $key[0x4A]
        selt = []
        for i in 0..@posts.size - 1
          selt.push((i + 1).to_s + " / " + @postscount.to_s + ": " + @posts[i].author)
        end
        dialog_open
        @form.index = selector(selt, p_("Forum", "Select post"), @form.index / 3, @form.index / 3) * 3
        dialog_close
        @form.focus
      elsif $key[0x4e] and @noteditable == false
        @form.index = @postscount * 3
        @form.focus
      elsif $key[0x55] and @readposts < @postscount
        @form.index = @readposts * 3
        @form.focus
      elsif $key[77]
        showbookmarks
      end
    end
  end

  def textsendupdate
    if @form.fields[@postscount * 3].text == "" and @form.fields[@postscount * 3 + 2] != nil
      @form.fields[@postscount * 3 + 2] = nil
    elsif @form.fields[@postscount * 3].text != "" and @form.fields[@postscount * 3 + 2] == nil
      @form.fields[@postscount * 3 + 2] = Button.new(p_("Forum", "Send"))
    end
    if ((enter or space) and @form.index == @postscount * 3 + 2) or (enter and $key[0x11] and @form.index == @postscount * 3)
      buf = buffer(@form.fields[@postscount * 3].text_str).to_s
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
    @recording = 0 if @recording == nil
    if (enter or space) and @form.index == @form.fields.size - 8
      if @recording == 0 or @recording == 2
        @recording = 1
        @r = Recorder.start($tempdir + "/audiopost.opus", 96)
        play("recording_start")
        @form.fields[@form.fields.size - 8] = Button.new(p_("Forum", "Stop recording"))
        @form.fields[@form.fields.size - 7] = nil
      elsif @recording == 1
        @r.stop
        play("recording_stop")
        @form.fields[@form.fields.size - 8] = Button.new(p_("Forum", "Record a post once again"))
        @form.fields[@form.fields.size - 7] = Button.new(p_("Forum", "Play"))
        @form.fields[@form.fields.size - 6] = Button.new(p_("Forum", "Send"))
        @recording = 2
      end
    end
    player($tempdir + "/audiopost.opus", "", true) if (enter or space) and @form.index == @form.fields.size - 7
    if (enter or space) and @form.index == @form.fields.size - 6 and @recording == 2
      if @recording == 1
        play("recording_stop")
        @r.stop
      end
      waiting
      speak(p_("Forum", "Preparing..."))
      data = ""
      fl = readfile($tempdir + "/audiopost.opus")
      if fl[0..3] != "OggS"
        alert(_("Error"))
        return $scene = Scene_Main.new
      end
      host = $srv
      boundary = ""
      boundary = "----EltBoundary" + rand(36 ** 32).to_s(36) while fl.include?(boundary)
      data = "--" + boundary + "\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
      length = data.size
      q = "POST /srv/forum_edit.php?name=#{$name}\&token=#{$token}\&threadid=#{@thread.to_s}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
      a = connect(host, 80, q).delete("\0")
      for i in 0..a.size - 1
        if a[i..i + 3] == "\r\n\r\n"
          s = i + 4
          break
        end
      end
      return alert(_("Error")) if s == nil
      sn = a[s..a.size - 1]
      ft = sn.split("\r\n")
      waiting_end
      if ft[0].to_i == 0
        alert(p_("Forum", "The post was created."))
      else
        alert(p_("Forum", "Post creation failure."))
      end
      return main
    end
  end

  def context(menu)
    if @form.index < @postscount * 3
      menu.useroption(@posts[@form.index / 3].authorname)
    end
    if @form.index < @postscount * 3
      menu.submenu(p_("Forum", "Reply")) { |m|
        m.option(p_("Forum", "Reply")) {
          @form.index = @postscount * 3
          @form.focus
        }
        m.option(p_("Forum", "Reply with quote")) {
          @form.fields[@postscount * 3].settext("\r\n--Cytat (#{@posts[@form.index / 3].authorname}):\r\n#{@posts[@form.index / 3].post}\r\n--Koniec cytatu\r\n#{@form.fields[@postscount * 3].text_str}")
          @form.fields[@postscount * 3].index = 0
          @form.index = @postscount * 3
          @form.focus
        }
      }
    end
    menu.submenu(p_("Forum", "Navigation")) { |m|
    m.option(p_("Forum", "Bookmarks")) {
    showbookmarks
    }
      m.option(p_("Forum", "Go to post")) {
        selt = []
        for i in 0..@posts.size - 1
          selt.push((i + 1).to_s + " / " + @postscount.to_s + ": " + @posts[i].author)
        end
        dialog_open
        @form.index = selector(selt, p_("Forum", "Select post"), @form.index / 3, @form.index / 3) * 3
        dialog_close
        @form.focus
      }
      if @type != 1
        m.option(p_("Forum", "Search in thread")) {
          search = input_text(p_("Forum", "Enter a phrase to look for"), "ACCEPTESCAPE")
          if search != "\004ESCAPE\004"
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
      m.option(p_("Forum", "Go to first post")) {
        @form.index = 0
        @form.focus
      }
      m.option(p_("Forum", "Go to last post")) {
        @form.index = @postscount * 3 - 3
        @form.focus
      }
      if @readposts < @postscount
        m.option(p_("Forum", "Go to first new post")) {
          @form.index = @readposts * 3
          @form.focus
        }
      end
    }
    if @form.index < @postscount * 3
      menu.option(p_("Forum", "Mention post")) {
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
        form = Form.new([Select.new(users, true, 0, "Użytkownik"), Edit.new(p_("Forum", "Message"), "", "", true), Button.new(p_("Forum", "Mention post")), Button.new(_("Cancel"))])
        loop do
          loop_update
          form.update
          if escape or ((enter or space) and form.index == 3)
            loop_update
            @form.focus
            break
          end
          if (enter or space) and form.index == 2
            mt = srvproc("mentions", { "add" => "1", "user" => users[form.fields[0].index], "message" => form.fields[1].text_str, "thread" => @thread, "post" => @posts[@form.index / 3].id })
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
      menu.option(p_("Forum", "Listen to the thread")) {
        if $voice == -1 and @type == 0
          text = ""
          for pst in @posts[@form.index / 3..@posts.size]
            text += pst.author + "\r\n" + pst.post + "\r\n" + pst.date + "\r\n\r\n"
          end
          speech(text)
        else
          cur = @form.index / 3 - 1
          while cur < @posts.size
            loop_update
            if speech_actived == false and Win32API.new("bin\\screenreaderapi", "sapiIsPaused", "", "i").call == 0
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
              if Win32API.new("bin\\screenreaderapi", "sapiIsPaused", "", "i").call == 0
                Win32API.new("bin\\screenreaderapi", "sapiSetPaused", "i", "i").call(1)
              else
                Win32API.new("bin\\screenreaderapi", "sapiSetPaused", "i", "i").call(0)
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
    s = p_("Forum", "Add to followed threads list")
    s = p_("Forum", "Unfollow this thread") if @followed == true
    menu.option(s) {
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
    if @form.index < @postscount * 3 && ((($rang_moderator == 1 && @threadclass.forum.group.recommended) || (@threadclass != nil && @threadclass.forum.group.role == 2)) || (@posts[@form.index / 3].author == $name))
      menu.submenu(p_("Forum", "Moderation")) { |m|
        if @type != 1
          m.option(p_("Forum", "Edit post")) {
            dialog_open
            form = Form.new([Edit.new(p_("Forum", "edit your post here"), "MULTILINE", @posts[@form.index / 3].post), Button.new(_("Save")), Button.new(_("Cancel"))])
            loop do
              loop_update
              form.update
              if form.fields[0].text_str.size > 1 and (((enter or space) and form.index == 1) or (enter and $key[0x11] and form.index < 2))
                buf = buffer(form.fields[0].text_str)
                if srvproc("forum_mod", { "edit" => "1", "postid" => @posts[@form.index / 3].id.to_s, "threadid" => @thread.to_s, "buffer" => buf })[0].to_i < 0
                  alert(_("Error"))
                else
                  alert(p_("Forum", "The post has been modified"))
                  @lastpostindex = @form.index
                  refresh
                  break
                end
              end
              break if escape or ((enter or space) and form.index == 2)
            end
            dialog_close
          }
        end
        if $rang_moderator == 1 or @threadclass.forum.group.role == 2
          m.option(p_("Forum", "Move post")) {
            @struct = Scene_Forum.new.getstruct
            @groups = @struct["groups"]
            @forums = @struct["forums"]
            @threads = @struct["threads"]
            groups = []
            for group in @groups
              groups[group.id] = group.name
            end
            forums = {}
            forum @sgroups = {}
            selt = []
            mthreads = []
            curr = 0
            for t in @threads
              mthreads.push(t) if t.forum.group.role == 2 or ($rang_moderator == 1 and t.forum.group.recommended)
            end
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
          m.option(p_("Forum", "Delete post")) {
            confirm(p_("Forum", "Are you sure you want to delete this post?")) do
              prm = ""
              if @posts.size == 1
                prm = "name=#{$name}\&token=#{$token}\&threadid=#{@thread}\&delete=1"
              else
                prm = "name=#{$name}\&token=#{$token}\&postid=#{@posts[@form.index / 3].id}\&threadid=#{@thread}\&delete=2"
              end
              if srvproc("forum_mod", prm)[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("Forum", "This post has been deleted."))
                if @posts.size == 1
                  $scene = Scene_Forum.new(@thread, @param, @cat, @query)
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
              if srvproc("forum_mod", "name=#{$name}\&token=#{$token}\&move=3\&source=#{@posts[@form.index / 3].id.to_s}\&destination=#{if dest < @posts.size; @posts[dest].id.to_s; else; 0.to_s; end}")[0].to_i == 0
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
        menu.option(_("Refresh")) {
      refresh
    }
  end
  
  def showbookmarks
    loop_update
    bm=srvproc("forum_bookmarks", {'ac'=>'list', 'threadid'=>@thread})
    if bm[0].to_i!=0
      alert_("Error")
      return
      end
bookmarks=[]
    for i in 0...bm[1].to_i
      b=Struct_Forum_Bookmark.new(bm[2+i*4].to_i)
      b.description=bm[2+i*4+1].delete("\r\n")
      b.thread=bm[2+i*4+2].to_i
      b.post=bm[2+i*4+3].to_i
      for i in 0...@posts.size
        b.postnum=i if @posts[i].id==b.post
      end
      bookmarks.push(b)
    end
    refr=false
    sel=Select.new(bookmarks.map{|b| b.description+" ("+p_("Forum", "Post %{postnumber} by %{author}")%{'postnumber'=>b.postnum+1, 'author'=>@posts[b.postnum].author}+"): "+@posts[b.postnum].post[0...100]}, true, 0, p_("Forum", "Bookmarks"))
    sel.bind_context{|menu|
    if bookmarks.size>0
    menu.option(p_("Forum", "Delete bookmark")) {
    deletebookmark(bookmarks[sel.index])
    refr=true
    }
    end
    if @form.index/3<@posts.size
    menu.option(p_("Forum", "New bookmark")) {
    newbookmark
    refr=true
    }
    end
    }
    loop do
      loop_update
      sel.update
      if sel.selected?
        @form.index=bookmarks[sel.index].postnum*3
        @form.focus
        break
        end
      if $key[0x2E] and bookmarks.size>0
        deletebookmark(bookmarks[sel.index])
    refr=true
  end
  if escape
    loop_update
    @form.focus
    break
  end
  if refr
    refr=false
    loop_update
    return showbookmarks
    end
      end
    end
    
    def deletebookmark(b)
      if srvproc("forum_bookmarks", {'ac'=>'delete', 'bookmark'=>b.id})[0].to_i==0
        alert(p_("Forum", "Bookmark deleted"))
      else
        alert(_("Error"))
      end
      loop_update
      end
      
      def newbookmark
        return if @form.index/3>=@posts.size
        description=input_text(p_("Forum", "Bookmark description"), "ACCEPTESCAPE")
        return if description=="\004ESCAPE\004" or description==""
        if srvproc("forum_bookmarks", {'ac'=>'create', 'description'=>description, 'thread'=>@thread, 'post'=>@posts[@form.index/3].id})[0].to_i==0
          alert(p_("Forum", "Bookmark created"))
        else
          alert(_("Error"))
        end
        loop_update
        end

  def getcache
    c = srvproc("forum_thread", { "thread" => @thread.to_s, "atts" => "1" })
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
    @marked=false
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

  def initialize(id = 0)
    @id = id
    @author = ""
    @post = ""
    @authorname = ""
    @signature = ""
    @date = ""
    @attachments = []
    @polls = []
  end
end

class Struct_Forum_Mention
  attr_accessor :id
  attr_accessor :author
  attr_accessor :thread
  attr_accessor :post
  attr_accessor :message

  def initialize(id = 0)
    @id = id
    @thread = 0
    @post = 0
    @message = 0
    @author = ""
  end
end

class Struct_Forum_Bookmark
  attr_accessor :id
  attr_accessor :description
  attr_accessor :thread
  attr_accessor :post
  attr_accessor :postnum
  def initialize(id=0)
    @id=id
    @description=""
    @thread=0
    @post=0
    @postnum=0
    end
  end