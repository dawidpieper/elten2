# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2023 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Blog
  def initialize(index = 0)
    index = 0 if index == 6
    @index = index
  end

  def main
    @sel = ListBox.new([p_("Blog", "Managed blogs"), p_("Blog", "Recently updated blogs"), p_("Blog", "Frequently updated blogs"), p_("Blog", "Frequently commented blogs"), p_("Blog", "Followed blogs"), p_("Blog", "Blogs popular with my friends"), p_("Blog", "Open external wordpress blog"), p_("Blog", "Followed blog posts"), p_("Blog", "Received mentions"), p_("Blog", "Blogs library")], p_("Blog", "Blogs"), @index)
    if Session.name == "guest"
      @sel.disable_item(0)
      @sel.index = 1
      @sel.disable_item(4)
      @sel.disable_item(5)
      @sel.disable_item(7)
      @sel.disable_item(8)
      @sel.disable_item(9)
    end
    @sel.focus
    loop do
      loop_update
      @sel.update
      update
      break if $scene != self
    end
  end

  def update
    if escape
      $scene = Scene_Main.new
    end
    if enter or arrow_right
      case @sel.index
      when 0
        $bloglistindex = 0
        $scene = Scene_Blog_List.new(Session.name)
      when 1
        $bloglistindex = 0
        $scene = Scene_Blog_List.new
      when 2
        $bloglistindex = 0
        $scene = Scene_Blog_List.new(1)
      when 3
        $bloglistindex = 0
        $scene = Scene_Blog_List.new(2)
      when 4
        $bloglistindex = 0
        $scene = Scene_Blog_List.new(3)
      when 5
        $bloglistindex = 0
        $scene = Scene_Blog_List.new(4)
      when 6
        u = input_text(p_("Blog", "Type blog address"), 0, "", true)
        if u != nil
          u.gsub!(/http(s?)\:\/\//, "")
          u.delete!("/")
          r = "[*" + u + "]"
          $bloglistindex = 0
          $scene = Scene_Blog_List.new(5, self, r)
        end
      when 7
        if requires_premiumpackage("courier")
          $scene = Scene_Blog_Posts.new(Session.name, "FOLLOWED")
        end
      when 8
        if requires_premiumpackage("courier")
          $scene = Scene_Blog_Posts.new(Session.name, "MENTIONED")
        end
      when 9
        $bloglistindex = 0
        $scene = Scene_Blog_List.new(8, nil, :library)
      end
    end
  end
end

class Scene_Blog_Main
  def initialize(owner = Session.name, categoryselindex = 0, scene = nil, check = false)
    @owner = owner
    @categoryselindex = categoryselindex
    @postselindex = 0
    @isowner = (blogowners(owner) || "").include?(Session.name)
    @check = check
    $blogreturnscene = scene
  end

  def main
    if @check == true
      blogtemp = srvproc("blog_exist", { "searchname" => @owner })
      err = blogtemp[0].to_i
      if err < 0
        alert(_("Error"))
        $scene = Scene_Main.new
        return
      end
      exist = blogtemp[1].to_i
      if exist == 0
        if @owner == Session.name
          $scene = Scene_Blog_Create.new
        else
          alert(p_("Blog", "The blog cannot be found."))
          $scene = $blogreturnscene
          $scene = Scene_Main.new if $scene == nil
        end
        return
      end
    end
    blogtemp = srvproc("blog_categories", { "searchname" => @owner, "details" => 1 })
    err = blogtemp[0].to_i
    if err < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    for i in 0...blogtemp.size
      blogtemp[i].delete!("\r\n")
    end
    @blogname = blogname = blogtemp[1]
    @categories = []
    l = 3
    for i in 0...blogtemp[2].to_i
      c = Struct_Blog_Category.new
      c.id = blogtemp[l].to_i
      l += 1
      c.name = blogtemp[l]
      l += 1
      c.parent = blogtemp[l].to_i
      l += 1
      c.posts = blogtemp[l].to_i
      l += 1
      c.url = blogtemp[l]
      l += 1
      @categories.push(c) if @isowner or c.posts > 0
    end
    sel = [[p_("Blog", "All posts"), nil]] + @categories.map { |c| [c.name, c.posts.to_s] }
    @sel = TableBox.new([nil, p_("Blog", "Posts")], sel, @categoryselindex, blogname, false)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      update
      break if $scene != self
    end
  end

  def update
    if escape or (arrow_left and !$keyr[0x10])
      $scene = $blogreturnscene
      $scene = Scene_Main.new if $scene == nil
    end
    if enter or (arrow_right and !$keyr[0x10])
      bopen
    end
  end

  def bopen
    c = 0
    c = @categories[@sel.index - 1].id if @sel.index > 0
    $scene = Scene_Blog_Posts.new(@owner, c, @sel.index)
  end

  def categorynew
    name = ""
    name = input_text(p_("Blog", "Category name"), 0, "", true) while name == ""
    if name != nil
      blogtemp = srvproc("blog_categories_mod", { "add" => "1", "categoryname" => name, "searchname" => @owner })
      err = blogtemp[0].to_i
      if err < 0
        alert(_("Error"))
      else
        alert(p_("Blog", "The category has been created."))
        @sel.rows.push([name, "0"])
        @sel.reload
        c = Struct_Blog_Category.new
        c.name = name
        c.id = blogtemp[1].to_i
        @categories.push(c)
      end
      speech_wait
    end
    @sel.focus
  end

  def categoryrename
    name = ""
    name = input_text(p_("Blog", "Category name"), 0, @categories[@sel.index - 1].name, true) while name == ""
    if name != nil
      blogtemp = srvproc("blog_categories_mod", { "rename" => "1", "categoryid" => @categories[@sel.index - 1].id, "categoryname" => name, "searchname" => @owner })
      err = blogtemp[0].to_i
      if err < 0
        alert(_("Error"))
      else
        alert(p_("Blog", "The category has been renamed."))
        @sel.rows[@sel.index][0] = name
        @sel.reload
        @categories[@sel.index - 1].name = name
      end
      speech_wait
    end
    @sel.focus
  end

  def categorydelete
    confirm(p_("Blog", "Are you sure you want to delete this category?")) {
      bt = srvproc("blog_categories_mod", { "categoryid" => @categories[@sel.index - 1].id, "del" => 1, "searchname" => @owner })
      if bt[0].to_i < 0
        alert(_("Error"))
      else
        alert(p_("Blog", "Category deleted"))
        @categories.delete_at(@sel.index - 1)
        @sel.rows.delete_at(@sel.index)
        @sel.reload
        @sel.focus
      end
    }
  end

  def context(menu)
    menu.option(p_("Blog", "Select")) {
      bopen
    }
    if @isowner and @sel.index > 0
      menu.option(p_("Blog", "Rename"), nil, "e") {
        categoryrename
      }
      menu.option(_("Delete"), nil, :del) {
        categorydelete
      }
    end
    if @sel.index > 0
      menu.option(p_("Blog", "Copy category URL")) {
        Clipboard.text = @categories[@sel.index - 1].url
        alert(p_("Blog", "Category URL copied to clipboard"))
      }
    end
    if @isowner
      menu.option(p_("Blog", "New category"), nil, "n") {
        categorynew
      }
    end
  end
end

class Scene_Blog_Create
  def initialize(shared = false, scene = nil)
    @shared = shared
    @scene = scene
    @scene = Scene_Blog.new if @scene == nil
  end

  def main
    if @shared == false
      if confirm(p_("Blog", "You do not have any blog. Do you want to create one?")) == 0
        $scene = @scene
        return
      end
    end
    name = input_text(p_("Blog", "Type a blog name"), 0, "", true)
    if name == nil
      $scene = @scene
      return
    end
    alert(p_("Blog", "Please wait..."))
    speech_wait
    bp = { "blogname" => name }
    bp["shared"] = "1" if @shared == true
    $blogownerstime = 0
    blogtemp = srvproc("blog_create", bp)
    err = blogtemp[0].to_i
    if err < 0
      alert(_("Error"))
      $scene = @scene
      return
    end
    alert(p_("Blog", "The blog has been created."))
    speech_wait
    $scene = Scene_Blog_Options.new(blogtemp[1].delete("\r\n"), @scene)
  end
end

class Scene_Blog_Posts
  SORT_POSTS_BY_BLOG = 0
  SORT_POSTS_BY_DATE = 1

  def initialize(owner, id, categoryselindex = 0, postselindex = 0, search = nil, page = 0)
    @owner = owner
    @id = id
    @categoryselindex = categoryselindex
    @postselindex = postselindex
    @search = search
    @topage = page
    @isowner = (@id.is_a?(Integer) && (blogowners(owner) || "").include?(Session.name))
  end

  def main
    @mentions = []
    if @id == "MENTIONED" or @id == "NEWMENTIONED"
      prm = { "ac" => "list" }
      prm["list"] = "all" if @id == "MENTIONED"
      mnts = srvproc("blog_mentions", prm)
      if mnts[0].to_i == 0
        for i in 0...mnts[1].to_i
          mention = Struct_Blog_Mention.new
          mention.id = mnts[2 + i * 6].to_i
          mention.blog = mnts[2 + i * 6 + 1].delete("\r\n")
          mention.postid = mnts[2 + i * 6 + 2].to_i
          mention.author = mnts[2 + i * 6 + 3].delete("\r\n")
          mention.time = mnts[2 + i * 6 + 4].to_i
          mention.message = mnts[2 + i * 6 + 5].delete("\r\n")
          @mentions.push(mention)
        end
      end
    end
    id = @id
    id = 0 if @id == -1
    @page = 1
    @post = []
    @sel = TableBox.new(["", p_("Blog", "Author"), p_("Blog", "Comments")], [], 0, "")
    if @topage == 0
      load_posts(@page)
    else
      for i in 1..@topage
        load_posts(i)
      end
      @page = @topage
    end
    if @post.size == 0 and @id == "NEW"
      alert(p_("Blog", "No new comments on your blog."))
      $scene = Scene_WhatsNew.new
      return
    elsif @post.size == 0 and @id == "NEWFOLLOWED"
      alert(p_("Blog", "No new comments to followed blog posts."))
      $scene = Scene_WhatsNew.new
      return
    elsif @post.size == 0 and @id == "NEWFOLLOWEDBLOGS"
      alert(p_("Blog", "No new posts on followed blogs."))
      $scene = Scene_WhatsNew.new
      return
    elsif @post.size == 0 and @id == "NEWMENTIONED"
      alert(p_("Blog", "No new blog mentions."))
      $scene = Scene_WhatsNew.new
      return
    end
    @sel.index = @postselindex
    @sel.focus
    @sel.on(:move) { play("file_audio", 50, 50, @sel.lpos) if @post[@sel.index] != nil && @post[@sel.index].audio }
    @sel.trigger(:move)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      update
      break if $scene != self
    end
  end

  def update
    if escape or (arrow_left and !$keyr[0x10])
      if @id != -1
        if @id == "NEW" or @id == "NEWFOLLOWED" or @id == "NEWFOLLOWEDBLOGS"
          $scene = Scene_WhatsNew.new
        elsif @id == "FOLLOWED"
          $scene = Scene_Blog.new(7)
        elsif @id == "MENTIONED"
          $scene = Scene_Blog.new(8)
        else
          $scene = Scene_Blog_Main.new(@owner, @categoryselindex, $blogreturnscene)
        end
      else
        $scene = Scene_Blog_List.new
      end
    end
    if enter or (arrow_right and !$keyr[0x10])
      bopen
    end
  end

  def load_posts(page)
    id = @id
    id = 0 if @id == -1
    @owner = Session.name if id.to_i.to_s != id.to_s
    prm = { "searchname" => @owner, "categoryid" => id, "details" => 3, "paginate" => 1, "page" => page }
    prm["search"] = @search if @search != nil
    blogtemp = srvproc("blog_posts", prm)
    err = blogtemp[0].to_i
    if err < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    for i in 0..blogtemp.size - 1
      blogtemp[i].delete!("\r\n")
    end
    l = 3
    post = nil
    @post = [] if @id == "NEWFOLLOWEDBLOGS"
    for i in 0...blogtemp[1].to_i
      post = Struct_Blog_Post.new(blogtemp[l].to_i)
      l += 1
      post.name = blogtemp[l].delete("\r\n")
      l += 1
      post.unread = true if blogtemp[l].to_i > 0
      l += 1
      post.owner = blogtemp[l].delete("\r\n")
      l += 1
      post.audio = true if blogtemp[l].to_i > 0
      l += 1
      post.date = blogtemp[l].to_i
      l += 1
      post.url = blogtemp[l].delete("\r\n")
      l += 1
      post.author = blogtemp[l].delete("\r\n")
      l += 1
      post.comments = blogtemp[l].to_i
      l += 1
      post.followed = blogtemp[l].to_b
      if @id == "MENTIONED" or @id == "NEWMENTIONED"
        for mention in @mentions
          if mention.blog == post.owner && mention.postid == post.id
            post.mention = mention
            @post.push(post.clone)
          end
        end
      else
        @post.push(post)
      end
      l += 1
    end
    if @id == "NEWFOLLOWEDBLOGS" and LocalConfig["BlogPostsSortBy"] == SORT_POSTS_BY_DATE
      @post = @post.sort_by { |p| p.date * -1 }
    end
    @sel.rows = @post.map { |s|
      tmp = ""
      tmp += s.name
      if s.mention != nil
        tmp += " . #{p_("Blog", "Mentioned by")}: #{s.mention.author} (#{s.mention.message})"
      end
      tmp += "\004FUTURE\004" if s.date > Time.now.to_i
      tmp += "\004INFNEW{#{p_("Blog", "New")}}\004" if s.unread
      [tmp,
       s.author,
       s.comments.to_s]
    }
    if blogtemp[2].to_i > 0
      @sel.rows.push([p_("Blog", "Load more"), nil, nil])
    end
    @sel.setcolumn(@sel.column)
  end

  def bopen
    if @sel.index < @post.size
      $scene = Scene_Blog_Read.new(@post[@sel.index], @id, @categoryselindex, @sel.index, nil, @page, @search)
    else
      @page += 1
      load_posts(@page)
      @sel.say_option
    end
  end

  def postdelete
    confirm(p_("Blog", "Are you sure you want to delete this post?")) {
      bt = srvproc("blog_posts_mod", { "postid" => @post[@sel.index].id, "del" => "1", "searchname" => @owner })
      if bt[0].to_i < 0
        alert(_("Error"))
      else
        alert(p_("Blog", "Post deleted"))
        @post.delete_at(@sel.index)
        @sel.rows.delete_at(@sel.index)
        @sel.reload
      end
      speech_wait
      @sel.focus
    }
  end

  def context(menu)
    menu.option(p_("Blog", "Select")) {
      bopen
    }
    if @post.size > 0 && @sel.index < @post.size
      if @isowner
        menu.option(p_("Blog", "Edit"), nil, "e") {
          $scene = Scene_Blog_PostEditor.new(@owner, @post[@sel.index].id, @id, @categoryselindex, @sel.index)
        }
        menu.option(p_("Blog", "Move to another blog")) {
          $scene = Scene_Blog_Post_Move.new(@owner, @id, @post[@sel.index].id, @categoryselindex, @sel.index)
        }
        menu.option(_("Delete"), nil, :del) {
          postdelete
        }
      end
      if @id == "NEWFOLLOWEDBLOGS"
        if LocalConfig["BlogPostsSortBy"] == SORT_POSTS_BY_BLOG
          opt = p_("Blog", "Sort posts by date")
        else
          opt = p_("Blog", "Sort posts by blog")
        end
        menu.option(opt) {
          if LocalConfig["BlogPostsSortBy"] == SORT_POSTS_BY_BLOG
            LocalConfig["BlogPostsSortBy"] = SORT_POSTS_BY_DATE
            info = p_("Blog", "Posts sorted by date.")
          else
            LocalConfig["BlogPostsSortBy"] = SORT_POSTS_BY_BLOG
            info = p_("Blog", "Posts sorted by blog.")
          end
          load_posts(@page)
          alert(info)
        }
      end # if @id=="NEWFOLLOWEDBLOGS"
      menu.option(p_("Blog", "Mention post"), nil, "w") {
        users = []
        us = srvproc("contacts_addedme", {})
        if us[0].to_i < 0
          alert(_("Error"))
          next
        end
        for u in us[1..us.size - 1]
          users.push(u.delete("\r\n"))
        end
        if users.size == 0
          alert(p_("Blog", "Nobody added you to their contact list."))
          next
        end
        form = Form.new([ListBox.new(users, p_("Blog", "User to mention")), EditBox.new(p_("Blog", "Message"), 0, "", true), Button.new(p_("Blog", "Mention post")), Button.new(_("Cancel"))])
        loop do
          loop_update
          form.update
          if escape or ((enter or space) and form.index == 3)
            loop_update
            @sel.focus
            break
          end
          if (enter or space) and form.index == 2
            mt = srvproc("blog_mentions", { "ac" => "send", "user" => users[form.fields[0].index], "message" => form.fields[1].text, "blog" => @post[@sel.index].owner, "postid" => @post[@sel.index].id })
            if mt[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Blog", "The mention has been sent."))
              @sel.focus
              break
            end
          end
        end
      }
      opt = ""
      if @post[@sel.index].followed == false
        opt = p_("Blog", "Follow this post")
      else
        opt = p_("Blog", "Unfollow this post")
      end
      menu.option(opt, nil, "l") {
        if requires_premiumpackage("courier")
          prm = { "searchname" => @post[@sel.index].owner, "postid" => @post[@sel.index].id }
          if @post[@sel.index].followed == false
            prm["add"] = 1
          else
            prm["remove"] = 1
          end
          if srvproc("blog_fp", prm)[0].to_i == 0
            if @post[@sel.index].followed == false
              @post[@sel.index].followed = true
              alert(p_("Blog", "Post followed"))
            else
              @post[@sel.index].followed = false
              alert(p_("Blog", "Post unfollowed"))
            end
          else
            alert(_("Error"))
          end
        end
      }
      menu.option(p_("Blog", "Copy post URL")) {
        Clipboard.text = @post[@sel.index].url
        alert(p_("Blog", "Post URL copied to clipboard"))
      }
    end
    if @isowner and @id != "NEW" and @id != "FOLLOWED" and @id != "NEWFOLLOWED"
      menu.option(p_("Blog", "New post"), nil, "n") {
        $scene = Scene_Blog_PostEditor.new(@owner, 0, @id, @categoryselindex)
      }
    end
  end
end

class Scene_Blog_Read
  def initialize(post, category, categoryselindex = 0, postselindex = 0, scene = nil, page = 0, search = nil)
    @post = post
    @category = category
    @categoryselindex = categoryselindex
    @postselindex = postselindex
    @scene = scene
    @page = page
    @search = search
    @isowner = (blogowners(post.owner) || "").include?(Session.name)
  end

  def main
    blogtemp = srvproc("blog_read", { "categoryid" => @category, "postid" => @post.id, "searchname" => @post.owner, "details" => 8, "html" => 1 })
    blogtemp.each { |l| l.delete!("\r\n") }
    err = blogtemp[0].to_i
    if err < 0
      alert(_("Error"))
      $scene = Scene_Blog_Main.new(@post.owner)
      return
    end
    if @post.mention != nil
      srvproc("blog_mentions", { "ac" => "read", "mention" => @post.mention.id })
    end
    for i in 0..blogtemp.size - 1
      blogtemp[i].delete!("\r\n")
    end
    lines = blogtemp[1].to_i
    @knownposts = blogtemp[2].to_i
    @comments = blogtemp[3].to_i
    @iseltenblog = blogtemp[4].to_i.to_b
    @comments = 0 if @iseltenblog == false
    l = 5
    text = ""
    @posts = []
    for i in 0..lines - 1
      t = 0
      @posts[i] = Struct_Blog_Post.new
      loop do
        t += 1
        if t > 7
          @posts[i].text += blogtemp[l].to_s + "\r\n"
        elsif t == 7
          if blogtemp[l].delete("\r\n") != "\004END\004"
            @posts[i].excerpt += blogtemp[l].to_s + "\r\n"
            t -= 1
          end
        elsif t == 1
          @posts[i].id = blogtemp[l].to_i
        elsif t == 2
          @posts[i].iseltenuser = blogtemp[l].to_b
        elsif t == 3
          @posts[i].author = blogtemp[l]
        elsif t == 4
          @posts[i].date = blogtemp[l].to_i
        elsif t == 5
          @posts[i].moddate = blogtemp[l].to_i
        elsif t == 6
          @posts[i].audio_url = blogtemp[l]
        end
        l += 1
        break if (t > 7 and blogtemp[l] == "\004END\004") or l >= blogtemp.size or blogtemp[l] == "\004潤\n" or blogtemp[l] == nil
      end
      l += 1
    end
    @postcur = 0
    @fields = []
    fdate = ""
    for i in 0..@posts.size - 1
      @fields[(i == 0 ? i : (i + 2))] = EditBox.new(@posts[i].author, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly | EditBox::Flags::HTML, format(@posts[i]), true)
      if i == 0
        date = Time.now
        begin
          date = Time.at(@posts[0].date)
        rescue Exception
        end
        fdate = format_date(date)
      end
    end
    @fields[1] = nil
    @fields[2] = nil
    if @posts[0] != nil
      if @fields[0].text.sub(fdate, "").delete(" \r\n") != "" && @posts[0].audio_url != ""
        @fields[2] = EditBox.new(@posts[0].author, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly | EditBox::Flags::HTML, "", true)
        @fields[2].audio_url = @posts[0].audio_url
      elsif @posts[0].audio_url != ""
        @fields[0].audio_url = @posts[0].audio_url
      end
      @medias = nil
      if @posts.size > 0 and MediaFinders.possible_media?(@posts[0].text)
        @fields[1] = Button.new(p_("Blog", "Show attached media"))
        @fields[1].on(:press) {
          @medias = MediaFinders.get_media(@posts[0].text)
          if @medias.size > 0
            @fields[1] = ListBox.new(@medias.map { |m| m.title }, p_("Blog", "Media"))
          else
            @fields[1] = nil
            @medias = nil
          end
          @form.focus
          loop_update
        }
      end
    else
      if @scene == nil
        $scene = Scene_Blog_Posts.new(@post.owner, @category, @categoryselindex, @postselindex, @search, @page)
      else
        $scene = @scene
      end
    end
    if Session.name != "guest"
      @fields.push(EditBox.new(p_("Blog", "Your comment"), EditBox::Flags::MultiLine, "", true))
    else
      @fields.push(nil)
    end
    @fields.push(nil)
    if @isowner
      @fields.push(Button.new(p_("Blog", "Edit your post")))
    else
      @fields.push(nil)
    end
    @fields.push(Button.new(p_("Blog", "Return")))
    @form = Form.new(@fields)
    if @comments == 0
      @form.fields[-3] = nil
      @form.fields[-4] = nil
    end
    @form.bind_context(p_("Blog", "Blogs")) { |menu| context(menu) }
    loop do
      loop_update
      @form.update
      update
      if @form.fields[@form.fields.size - 4] != nil and @form.fields[@form.fields.size - 4].text != "" and @form.fields[@form.fields.size - 3] == nil
        @form.fields[@form.fields.size - 3] = Button.new(p_("Blog", "Send"))
      elsif @form.fields[@form.fields.size - 4] != nil and @form.fields[@form.fields.size - 4].text == "" and @form.fields[@form.fields.size - 3] != nil
        @form.fields[@form.fields.size - 3] = nil
      end
      break if $scene != self
    end
  end

  def update
    if enter and @form.index == 1 and @medias != nil
      @medias[@form.fields[1].index].proceed
      speech_wait
      loop_update
      @form.fields[@form.index].focus
    end
    if ((enter or space) and @form.index == @form.fields.size - 3) or (enter and $key[0x11] and @form.index == @form.fields.size - 4)
      @form.fields[@form.fields.size - 4]
      txt = @form.fields[@form.fields.size - 4].text
      if txt.size == 0 or txt == "\r\n"
        alert(_("Error"))
        return
      end
      buf = buffer(txt)
      bt = srvproc("blog_posts_comment", { "searchname" => @post.owner, "categoryid" => @category.to_s, "postid" => @post.id.to_s, "buffer" => buf.to_s })
      case bt[0].to_i
      when 0
        alert(p_("Blog", "The comment has been added."))
        main
        return
      when -1
        alert(_("Database Error"))
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
    end
    if (enter or space) and @form.index == @form.fields.size - 2
      @form.fields[0]
      txt = @form.fields[0].text
      $scene = Scene_Blog_PostEditor.new(@post.owner, @post.id, @category, @categoryselindex, @postselindex)
    end
    if escape or ((enter or space) and @form.index == @form.fields.size - 1)
      if @scene == nil
        $scene = Scene_Blog_Posts.new(@post.owner, @category, @categoryselindex, @postselindex, @search, @page)
      else
        $scene = @scene
      end
    end
  end

  def format(post)
    date = Time.now
    begin
      date = Time.at(post.date)
    rescue Exception
    end
    text = post.text
    if text.delete(" \r\n") == "" && post.audio_url != ""
      post.audio_url
      text = "\004AUDIO\004#{post.audio_url}\004AUDIO\004"
    end
    text + "\n\n" + format_date(date)
  end

  def context(menu)
    ind = -1
    if @form.index < @posts.size + 2 && (@form.index != 1 || @posts.size != 1)
      ind = @form.index - 2
      ind = 0 if ind < 0
      pst = @posts[ind]
      if @iseltenblog && pst.iseltenuser
        menu.useroption(pst.author)
      end
    end
    if @post.mention != nil
      menu.submenu(p_("Blog", "Received mention")) { |m|
        m.option(p_("Blog", "Show mention"), nil, "/") {
          input_text(p_("Blog", "Mention by %{user}") % { "user" => @post.mention.author }, EditBox::Flags::ReadOnly, @post.mention.message, true)
        }
        m.option(p_("Blog", "Send reply to mentioner"), nil, "?") {
          to = @post.mention.author
          subj = "RE: " + @post.mention.message.to_s + " (" + @post.name + ")"
          insert_scene(Scene_Messages_New.new(to, subj, "", Scene_Main.new))
        }
      }
    end
    if @iseltenblog
      opt = ""
      if @post.followed == false
        opt = p_("Blog", "Follow this post")
      else
        opt = p_("Blog", "Unfollow this post")
      end
      menu.option(opt, nil, "l") {
        if requires_premiumpackage("courier")
          prm = { "searchname" => @post.owner, "postid" => @post.id }
          if @post.followed == false
            prm["add"] = 1
          else
            prm["remove"] = 1
          end
          if srvproc("blog_fp", prm)[0].to_i == 0
            if @post.followed == false
              @post.followed = true
              alert(p_("Blog", "Post followed"))
            else
              @post.followed = false
              alert(p_("Blog", "Post unfollowed"))
            end
          else
            alert(_("Error"))
          end
        end
      }
    end
    menu.submenu(p_("Blog", "Navigation")) { |m|
      m.option(p_("Blog", "Go to post"), nil, ",") {
        @form.index = @postcur = 0
        @form.focus
      }
      m.option(p_("Blog", "Go to last comment"), nil, ".") {
        @form.index = @postcur = @form.fields.size - 5
        @form.focus
      }
      if @knownposts < @posts.size
        m.option(p_("Blog", "Go to first unread comment"), nil, "u") {
          @form.index = @postcur = @knownposts + 2
          @form.focus
        }
      end
    }
    if @comments != 0
      menu.option(p_("Blog", "Write a comment"), nil, "n") {
        @form.index = @postcur = @form.fields.size - 4
        @form.focus
      }
    end
    if ind > 0 and @isowner
      menu.option(p_("Blog", "Delete this comment")) {
        confirm(p_("Blog", "Are you sure you want to delete this comment?")) {
          srvproc("blog_posts_mod", { "delcomment" => "1", "searchname" => @post.owner, "postid" => @post.id, "commentnumber" => (ind).to_s })
          main
        }
      }
    end
  end
end

class Scene_Blog_List
  def initialize(type = 0, scene = nil, blog = nil)
    @type = type
    @scene = scene
    @blog = blog
  end

  def main
    @sel = TableBox.new([nil, nil, p_("Blog", "Author"), p_("Blog", "Posts"), p_("Blog", "Comments"), p_("Blog", "Last post")], [], 0, p_("Blog", "Blogs list"))
    @sel.bind_context { |menu| context(menu) }
    refresh
    @sel.index = $bloglistindex || 0
    @sel.index = 0 if @sel.index >= @sel.options.size
    @sel.focus
    $bloglistindex = 0
    loop do
      loop_update
      @sel.update
      update
      break if $scene != self
    end
  end

  def update
    if escape or (!$keyr[0x10] && arrow_left)
      if @scene == nil
        t = 0
        t = @type + 1 if @type.is_a?(Integer)
        $scene = Scene_Blog.new(t)
      else
        $scene = @scene
      end
    end
    if (enter or arrow_right) && !$keyr[0x10] and @blogs.size > 0
      $bloglistindex = @sel.index
      $scene = Scene_Blog_Main.new(@blogs[@sel.index].id, 0, $scene)
    end
  end

  def blogfollowers
    $bloglistindex = @sel.index
    $scene = Scene_Blog_Followers.new(@blogs[@sel.index].id, $scene)
  end

  def blogcoworkers
    owners = blogowners(@blogs[@sel.index].id)
    selt = owners
    sel = ListBox.new(selt, p_("Blog", "Coworkers"), 0, 0, false)
    sel.bind_context { |menu|
      menu.useroption(owners[sel.index])
      if blogowners(@blogs[@sel.index].id)[0] == Session.name and @blogs[@sel.index].id[0..0] == "["
        menu.option(p_("Blog", "Add coworker"), nil, "n") {
          cow = input_user(p_("Blog", "What user you want to add to this blog?"))
          if cow != nil
            srvproc("blog_coworkers", { "searchname" => @blogs[@sel.index].id, "ac" => "add", "user" => cow })
            $blogownerstime = 0
            owners = blogowners(@blogs[@sel.index].id)
            sel.options = selt = owners
            sel.focus
          end
        }
        if sel.index > 0
          menu.option(p_("Blog", "Delete coworker"), nil, :del) {
            confirm(p_("Blog", "Are you sure you want to release this coworker?")) {
              srvproc("blog_coworkers", { "searchname" => @blogs[@sel.index].id, "ac" => "release", "user" => owners[sel.index] })
              $blogownerstime = 0
              owners = blogowners(@blogs[@sel.index].id)
              sel.options = selt = owners
              sel.focus
            }
          }
        end
      end
    }
    loop do
      loop_update
      sel.update
      break if escape or arrow_left
    end
    @sel.focus
    loop_update
  end

  def blogdelete
    confirm(p_("Blog", "Are you sure you want to delete blog %{name}?") % { "name" => @blogs[@sel.index].name }) {
      confirm(p_("Blog", "All posts written on this blog will be lost. Are you sure you want to continue?")) {
        b = srvproc("blog_delete", { "searchname" => @blogs[@sel.index].id })
        alert(p_("Blog", "Blog deleted"))
        return main
      }
    }
  end

  def refresh
    @blogs = []
    sel = []
    if @blog == :library
      bt = srvproc("blog_library", { "ac" => "list" })
      return if bt[0].to_i != 0
      for i in 0...bt[1].to_i
        frg = bt[2 + i * 7...2 + (i + 1) * 7]
        b = Struct_Blog_Blog.new
        b.id = frg[0].delete("\r\n")
        b.library_user = frg[1].delete("\r\n")
        b.lang = frg[2].delete("\r\n")
        b.name = frg[3].delete("\r\n")
        b.description = frg[4].delete("\r\n") + "\n" + frg[5].delete("\r\n")
        b.url = frg[6].delete("\r\n")
        b.followed = false
        b.library = true
        b.owners = []
        b.elten = false
        b.lastpost = 0
        b.cnt_posts = 0
        b.cnt_comments = 0
        @blogs.push(b)
        sel.push([b.name, b.description, b.id[2..-2], nil, nil, nil])
      end
    elsif @blog.is_a?(String)
      bt = srvproc("blog_details", { "blog" => @blog })
      return if bt[0].to_i != 0
      b = Struct_Blog_Blog.new
      b.id = @blog
      b.name = bt[1].delete("\r\n")
      b.cnt_posts = 0
      b.cnt_comments = 0
      b.url = bt[3].delete("\r\n")
      b.lastpost = 0
      b.description = bt[2].delete("\r\n")
      b.followed = false
      b.lang = ""
      b.owners = []
      b.elten = false
      b.library = true if bt[4].to_i == 1
      @blogs.push(b)
      sel.push([b.name, b.description, @blog[2..-2], nil, nil, nil])
    else
      prm = { "details" => 2 }
      if @type.is_a?(String)
        prm["user"] = @type
      else
        prm["orderby"] = @type
      end
      blogtemp = srvproc("blog_list", prm)
      if blogtemp[0].to_i < 0
        alert(_("Error"))
        $scene = Scene_Blog.new
        return
      end
      knownlanguages = Session.languages.split(",").map { |lg| lg.upcase }
      rows = 9
      items = blogtemp[1].to_i
      if @scene != nil && items == 0
        alert(p_("Blog", "No blogs found"))
        $scene = @scene
        return
      end
      for i in 0...items
        l = i * rows + 2
        b = Struct_Blog_Blog.new
        b.id = blogtemp[l].delete("\r\n")
        b.name = blogtemp[l + 1].delete("\r\n")
        b.cnt_posts = blogtemp[l + 2].to_i
        b.cnt_comments = blogtemp[l + 3].to_i
        b.url = blogtemp[l + 4].delete("\r\n")
        b.lastpost = blogtemp[l + 5].to_i
        b.description = blogtemp[l + 6].delete("\r\n")
        b.followed = blogtemp[l + 7].to_i.to_b
        b.lang = blogtemp[l + 8].delete("\r\n")
        b.elten = true
        @blogs.push(b) if LocalConfig["BlogShowUnknownLanguages", 1] == 1 || knownlanguages.size == 0 || knownlanguages.include?(b.lang[0..1].upcase) || (@type.is_a?(String) || @type == 3)
      end
      for b in @blogs
        bo = blogowners(b.id)
        bo = [bo] if bo.is_a?(String)
        b.owners = bo
        o = b.owners.join(", ")
        tm = Time.at(b.lastpost)
        date = format_date(tm, false, true)
        sel.push([b.name, b.description, o, b.cnt_posts.to_s, b.cnt_comments.to_s, date])
      end
    end
    @sel.rows = sel
    @sel.reload
  end

  def addlib(blog)
    langs = []
    langsmapping = []
    lnindex = 0
    for lk in Lists.langs.keys.sort { |a, b| polsorter(Lists.langs[a]["name"], Lists.langs[b]["name"]) }
      langsmapping.push(lk)
      l = Lists.langs[lk]
      langs.push(l["name"] + "( " + l["nativeName"] + ")")
      lnindex = langs.size - 1 if lk[0..1].downcase == Configuration.language[0..1].downcase
    end
    form = Form.new([
      edt_description = EditBox.new(p_("Blog", "Blog description"), 0, "", true),
      lst_lang = ListBox.new(langs, p_("Blog", "Blog language"), lnindex),
      btn_add = Button.new(p_("Blog", "Add")),
      btn_cancel = Button.new(_("Cancel"))
    ], 0, false, true)
    btn_cancel.on(:press) { form.resume }
    btn_add.on(:press) {
      langid = lst_lang.index
      if langid >= 0
        l = langsmapping[langid]
        b = srvproc("blog_library", { "ac" => "add", "lang" => l, "buf_description" => buffer(edt_description.text), "blog" => blog.id })
        if b[0].to_i == 0
          alert(p_("Blog", "Blog added to library"))
          blog.library = true
        else
          alert(_("Error"))
        end
      end
      form.resume
    }
    form.wait
  end

  def context(menu)
    if @blogs.size > 0
      b = @blogs[@sel.index].owners
      blog = @blogs[@sel.index]
      if blog.elten
        b.each { |u| menu.useroption(u) }
      end
      menu.option(p_("Blog", "Open")) {
        $bloglistindex = @sel.index
        $scene = Scene_Blog_Main.new(@blogs[@sel.index].id, 0, $scene)
      }
      menu.option(p_("Blog", "Show all posts"), nil, :shift_enter) {
        $bloglistindex = @sel.index
        $scene = Scene_Blog_Posts.new(@blogs[@sel.index].id, -1, 0, 0)
      }
      menu.option(p_("Blog", "Search"), nil, "f") {
        phrase = input_text(p_("Blog", "Enter text to search"), 0, "", true)
        if phrase != nil
          $bloglistindex = @sel.index
          $scene = Scene_Blog_Posts.new(@blogs[@sel.index].id, -1, 0, 0, phrase)
        end
      }
      if blog.elten
        if b.include?(Session.name)
          menu.option(p_("Blog", "Blog options"), nil, "e") {
            $scene = Scene_Blog_Options.new(@blogs[@sel.index].id, $scene)
          }
          menu.option(p_("Blog", "Followers")) {
            blogfollowers
          }
          menu.option(p_("Blog", "Coworkers")) {
            blogcoworkers
          }
          if b[0] != Session.name && b != Session.name
            menu.option(p_("Blog", "Leave")) {
              confirm(p_("Blog", "Are you sure you want to stop co-creating this blog?")) {
                if srvproc("blog_coworkers", { "searchname" => @blogs[@sel.index].id, "ac" => "leave" })[0].to_i == 0
                  alert(p_("Blog", "Blog left"))
                else
                  alert(_("Error"))
                end
                $scene = Scene_Blog_List.new(@type, @scene)
              }
            }
          end
          menu.option(p_("Blog", "Recategorize")) {
            $bloglistindex = @sel.index
            $scene = Scene_Blog_Recategorize.new(@blogs[@sel.index].id, $scene)
          }
          if b[0] == Session.name
            menu.option(p_("Blog", "Delete this blog")) {
              blogdelete
            }
          end
        end
        isf = @blogs[@sel.index].followed
        s = ""
        if isf == true
          s = p_("Blog", "Remove from the followed blogs")
        else
          s = p_("Blog", "Add to followed blogs")
        end
        menu.option(s, nil, "l") {
          if isf == false
            err = srvproc("blog_fb", { "add" => "1", "searchname" => @blogs[@sel.index].id })[0].to_i
            if err != 0
              alert(_("Error"))
            else
              @blogs[@sel.index].followed = true
              confirm(p_("Blog", "This blog has been added to followed blogs. Do you want to mark all the posts published so far on it as read so that you don't see them in \"What's New\"?")) do
                srvproc("blog_markasread", { "user" => @blogs[@sel.index].id })
                if srvproc("blog_markasread", { "user" => @blogs[@sel.index].id })[0].to_i == 0
                  alert(p_("Blog", "The blog has been marked as read."))
                else
                  alert(_("Error"))
                end
              end
            end
          else
            err = srvproc("blog_fb", { "remove" => "1", "searchname" => @blogs[@sel.index].id })[0].to_i
            if err != 0
              alert(_("Error"))
            else
              alert(p_("Blog", "Removed from the followed blogs."))
              @blogs[@sel.index].followed = false
            end
          end
        }
      end
      if !blog.library
        menu.option(p_("Blog", "Add to Elten library")) {
          addlib(blog)
          @sel.focus
        }
      elsif blog.library && (blog.library_user == Session.name)
        menu.option(p_("Blog", "Delete from Elten library")) {
          confirm(p_("Blog", "Are you sure you want to delete this blog from Elten library?")) {
            srvproc("blog_library", { "ac" => "delete", "blog" => blog.id })
          }
          refresh
          @sel.focus
        }
      end
      menu.option(p_("Blog", "Add this blog to quick actions"), nil, "q") {
        QuickActions.create(Scene_Blog_Main, @blogs[@sel.index].name + " (#{p_("Blog", "Blog")})", [@blogs[@sel.index].id])
        alert(p_("Blog", "Blog added to quick actions"), false)
      }
      menu.option(p_("Blog", "Copy blog URL")) {
        Clipboard.text = @blogs[@sel.index].url
        alert(p_("Blog", "Blog URL copied to clipboard"))
      }
      if blog.elten
        menu.option(p_("Blog", "Mark the blog as read"), nil, "w") {
          confirm(p_("Blog", "All posts on this blog will be marked as read. Do you want to continue?")) do
            srvproc("blog_markasread", { "user" => @blogs[@sel.index].id })
            if srvproc("blog_markasread", { "user" => @blogs[@sel.index].id })[0].to_i == 0
              alert(p_("Blog", "The blog has been marked as read."))
            else
              alert(_("Error"))
            end
          end
        }
      end
    end
    menu.option(p_("Blog", "Create new blog"), nil, "n") {
      b = srvproc("blog_managed", { "searchname" => Session.name })
      can = true
      if b[0].to_i > 0
        alert(_("Error"))
        $scene = Scene_Main.new
        can = false
      else
        can = false if b[1].to_i > 0 && !requires_premiumpackage("scribe")
      end
      if can == true
        $bloglistindex = @sel.index
        $scene = Scene_Blog_Create.new(true, $scene)
      else
        alert(p_("Blog", "You cannot create more blogs"))
      end
    }
    if !@type.is_a?(String)
      if Session.languages.size > 0
        s = p_("Blog", "Show blogs in unknown languages")
        s = p_("Blog", "Hide blogs in unknown languages") if LocalConfig["BlogShowUnknownLanguages", 1] == 1
        menu.option(s) {
          l = 1
          l = 0 if LocalConfig["BlogShowUnknownLanguages", 1] == 1
          LocalConfig["BlogShowUnknownLanguages"] = l
          refresh
          @sel.focus
        }
      end
    end
    menu.option(_("Refresh"), nil, "r") {
      refresh
      @sel.focus
    }
  end
end

class Scene_Blog_Profile
  def initialize(scene = nil)
    @scene = scene
  end

  def main
    bp = srvproc("blog_profile", { "ac" => "get" })
    if bp[0].to_i < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    profile = JSON.load(bp[1])
    @form = Form.new([
      EditBox.new(p_("Blog", "Wordpress user login"), EditBox::Flags::ReadOnly, profile["user_login"], true),
      Button.new(p_("Blog", "Set new Wordpress password")),
      EditBox.new(p_("Blog", "First name"), 0, profile["first_name"], true),
      EditBox.new(p_("Blog", "Last name"), 0, profile["last_name"], true),
      EditBox.new(p_("Blog", "Nick"), 0, profile["nickname"], true),
      EditBox.new(p_("Blog", "Display name"), 0, profile["display_name"], true),
      EditBox.new(p_("Blog", "User description"), EditBox::Flags::MultiLine, profile["description"], true),
      Button.new(_("Save")),
      Button.new(_("Cancel"))
    ])
    loop do
      loop_update
      @form.update
      break if escape or @form.fields[8].pressed?
      if @form.fields[7].pressed?
        j = {}
        j["first_name"] = @form.fields[2].text
        j["last_name"] = @form.fields[3].text
        j["nickname"] = @form.fields[4].text
        j["display_name"] = @form.fields[5].text
        j["description"] = @form.fields[6].text
        if j["display_name"] != ""
          buf = buffer(JSON.generate(j))
          if srvproc("blog_profile", { "ac" => "set", "buffer" => buf })[0].to_i < 0
            alert(_("Error"))
          else
            alert(_("Saved"))
            speech_wait
            break
          end
        end
      end
      if @form.fields[1].pressed?
        ps = input_text(p_("Blog", "Your Elten Password"), EditBox::Flags::Password, "", true)
        if ps != nil
          nps = ""
          rps = ""
          m = nil
          suc = false
          until suc
            t = p_("Blog", "New Wordpress password")
            t = m + "\r\n" + t if m != nil
            nps = input_text(p_("Blog", t), EditBox::Flags::Password, "", true)
            rps = input_text(p_("Blog", "Repeat new Wordpress password"), EditBox::Flags::Password, "", true) if nps != nil
            break if nps == nil or rps == nil
            if rps == nps
              if rps.size < 6
                m = p_("Blog", "Wordpress password must be at least 6 characters long.")
              else
                suc = true
              end
            else
              m = p_("Blog", "Entered passwords are different.")
            end
          end
          if nps != nil and rps != nil
            if srvproc("blog_profile", { "ac" => "changepassword", "eltenpassword" => ps, "wppassword" => rps })[0].to_i < 0
              alert(_("Error"))
            else
              alert(_("Saved"))
            end
            speech_wait
          end
        end
        @form.focus
      end
    end
    if @scene == nil
      $scene = Scene_Main.new
    else
      $scene = @scene
    end
  end
end

class Scene_Blog_Recategorize
  def initialize(searchname, scene = nil)
    @searchname = searchname
    @scene = scene
    @scene ||= Scene_Blog.new
  end

  def main
    blogtemp = srvproc("blog_categories", { "searchname" => @searchname })
    err = blogtemp[0].to_i
    if err < 0
      alert(_("Error"))
      $scene = @scene
      return
    end
    lines = blogtemp[1].to_i
    l = 2
    for i in 0..blogtemp.size - 1
      blogtemp[i].delete!("\r\n")
    end
    categoryids = []
    categorynames = []
    for i in 0..lines - 1
      categoryids[i] = blogtemp[l].to_i
      l += 1
      categorynames[i] = blogtemp[l]
      l += 1
    end
    blogtemp = srvproc("blog_posts", { "searchname" => @searchname, "categoryid" => "0", "assignnew" => "1", "listcategories" => "1", "reverse" => "1" })
    err = blogtemp[0].to_i
    if err < 0
      alert(_("Error"))
      $scene = @scene
      return
    end
    for i in 0..blogtemp.size - 1
      blogtemp[i].delete!("\r\n")
    end
    lines = blogtemp[1].to_i
    l = 2
    @postname = []
    @postid = []
    @postmaxid = 0
    @postnew = []
    @postcategories = []
    for i in 0..lines - 1
      @postid[i] = blogtemp[l].to_i
      @postmaxid = blogtemp[l].to_i if blogtemp[l].to_i > @postmaxid
      l += 1
      @postname[i] = blogtemp[l]
      l += 1
      @postnew[i] = blogtemp[l].to_i
      if @postnew[i] > 0
        @postname[i] += "\004INFNEW{#{p_("Blog", "New")}}\004"
      end
      l += 1
      @postcategories[i] = []
      blogtemp[l] ||= ""
      for c in blogtemp[l].split(",")
        @postcategories[i].push(c.to_i)
      end
      l += 1
    end
    @fields = []
    for i in 0..@postid.size - 1
      f = ListBox.new(categorynames, @postname[i], 0, ListBox::Flags::MultiSelection)
      for c in @postcategories[i]
        ind = categoryids.find_index(c)
        f.selected[ind] = true if ind != nil
      end
      @fields.push(f)
    end
    @fields += [Button.new(_("Save")), Button.new(_("Cancel"))]
    @form = Form.new(@fields)
    loop do
      loop_update
      @form.update
      break if escape or ((space or enter) and @form.index == @form.fields.size - 1)
      if (space or enter) and (@form.index == @form.fields.size - 2 or $key[0x11])
        ou = ""
        for i in 0..@postid.size - 1
          ch = []
          for j in 0..@form.fields[i].selected.size - 1
            ch.push(categoryids[j]) if @form.fields[i].selected[j] == true
          end
          ou += @postid[i].to_s + ":" + ch.join(",") + "|" if ch.size > 0
        end
        buf = buffer(ou)
        bt = srvproc("blog_posts_mod", { "recategorize" => "1", "buffer" => buf, "searchname" => @searchname })
        if bt[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Blog", "Recategorized"))
        end
        speech_wait
        break
      end
    end
    $scene = @scene
  end
end

class Scene_Blog_Post_Move
  def initialize(owner, category, post, categoryselindex = 0, postselindex = 0)
    @owner = owner
    @category = category
    @post = post
    @categoryselindex = categoryselindex
    @postselindex = postselindex
  end

  def main
    @blogids = []
    @blognames = []
    b = srvproc("blog_managed", { "searchname" => Session.name })
    if b[0].to_i > 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    for i in 2...b.size
      if i % 2 == 0
        @blogids.push(b[i].delete("\r\n"))
      else
        @blognames.push(b[i].delete("\r\n"))
      end
    end
    @form = Form.new([ListBox.new(@blognames, p_("Blog", "Post destination"), @blogids.index(@owner) || 0), ListBox.new([p_("Blog", "Move this post and all comments"), p_("Blog", "Move only this post, delete all comments"), p_("Blog", "Copy this post and all comments")], p_("Blog", "Move type")), Button.new(p_("Blog", "Move")), Button.new(_("Cancel"))])
    loop do
      loop_update
      @form.update
      if @form.fields[2].pressed?
        bl = srvproc("blog_move", { "searchname" => @owner, "postid" => @post.to_s, "destination" => @blogids[@form.fields[0].index], "movetype" => @form.fields[1].index.to_s })
        if bl[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Blog", "The post has been moved."))
        end
        speech_wait
        break
      end
      break if escape or @form.fields[3].pressed?
    end
    $scene = Scene_Blog_Posts.new(@owner, @category, @categoryselindex, @postselindex)
  end
end

class Scene_Blog_Options
  def initialize(blog = nil, scene = nil)
    blog = Session.name if blog == nil
    @blog = blog
    bt = srvproc("blog_domains", { "ac" => "getblogdomain", "searchname" => @blog })
    @domain = ""
    @domain = (bt[1] || "").delete("\r\n") if bt[0].to_i == 0
    @settings = []
    @scene = scene
  end

  def getconfig
    a = srvproc("blog_options", { "searchname" => @blog, "ac" => "get" })
    @values = {}
    @languages = {}
    @timezones = {}
    if a[0].to_i == 0
      @values = JSON.load(a[1])
      @languages = JSON.load(a[2])
      @timezones = JSON.load(a[3])
    end
  end

  def currentconfig(key)
    getconfig if @values == nil
    return @values[key]
  end

  def setcurrentconfig(key, val)
    @changed = true if @values[key] != val.to_s
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
    srvproc("blog_options", { "ac" => "set", "searchname" => @blog, "buffer" => b })
    @changed = false
  end

  def make_window
    @form = Form.new
    @form.fields[0] = ListBox.new([], p_("Blog", "Category"))
    @form.fields[1] = Button.new(_("Apply"))
    @form.fields[2] = Button.new(_("Save"))
    @form.fields[3] = Button.new(_("Cancel"))
  end

  def load_general
    setting_category(p_("Blog", "General"))
    make_setting(p_("Blog", "Blog name"), :text, "blogname")
    make_setting(p_("Blog", "Blog description"), :text, "blogdescription")
    langs = []
    langsmapping = []
    getconfig if @languages == nil
    for lang in @languages.keys
      l = @languages[lang]
      langsmapping.push(lang)
      langs.push(l["english_name"] + "(" + l["native_name"] + ")")
    end
    make_setting(p_("Blog", "Language"), langs, "WPLANG", langsmapping)
    make_setting(p_("Blog", "Mark this blog as public. Blogs that are not marked public request search engines such as Google not to show them in search results (some search engines may not respect this setting)"), :bool, "blog_public")
  end

  def load_comments
    setting_category(p_("Blog", "Comments"))
    make_setting(p_("Blog", "Comments can be written"), [p_("Blog", "By all visitors"), p_("Blog", "By all visitors, but I must commit first comment of the specific person"), p_("Blog", "By all visitors, but I must commit all of them"), p_("Blog", "By Elten users only")], "^commentingtype")
    make_setting(p_("Blog", "Disable commenting of older posts"), :bool, "close_comments_old_posts")
    make_setting(p_("Blog", "Days after commenting of a post will be disabled"), :number, "close_comments_days_old")
    make_setting(p_("Blog", "Allow comments threading"), :bool, "thread_comments")
    make_setting(p_("Blog", "Max comments thread depth"), :number, "thread_comments_depth")
    make_setting(p_("Blog", "Order comments on the website"), [p_("Blog", "Ascending"), p_("Blog", "Descending")], "order_comments", ["asc", "desc"])
    make_setting(p_("Blog", "Split comments on the website into pages"), :bool, "page_comments")
    make_setting(p_("Blog", "Comments per page"), :number, "comments_per_page")
    make_setting(p_("Blog", "Firstly display"), [p_("Blog", "Newest comments"), p_("Blog", "Oldest comments")], "default_comments_page", ["newest", "oldest"])
    make_setting(p_("Blog", "Pending comments"), :custom, Proc.new { insert_scene(Scene_Blog_Comments.new(@blog)) })
    on_load {
      if currentconfig("comment_registration").to_i == 1
        @form.fields[1].index = 3
      elsif currentconfig("comment_moderation").to_i == 1
        @form.fields[1].index = 2
      elsif currentconfig("comment_whitelist").to_i == 1
        @form.fields[1].index = 1
      end
      @form.fields[1].on(:move) {
        case @form.fields[1].index
        when 0
          setcurrentconfig("comment_whitelist", 0)
          setcurrentconfig("comment_moderation", 0)
          setcurrentconfig("comment_registration", 0)
        when 1
          setcurrentconfig("comment_whitelist", 1)
          setcurrentconfig("comment_moderation", 0)
          setcurrentconfig("comment_registration", 0)
        when 2
          setcurrentconfig("comment_whitelist", 0)
          setcurrentconfig("comment_moderation", 1)
          setcurrentconfig("comment_registration", 0)
        when 3
          setcurrentconfig("comment_whitelist", 0)
          setcurrentconfig("comment_moderation", 0)
          setcurrentconfig("comment_registration", 1)
        end
      }
      @form.fields[2].on(:change) {
        if @form.fields[2].checked.to_i == 1
          @form.show(3)
        else
          @form.hide(3)
        end
      }
      @form.fields[2].trigger(:change)
      @form.fields[4].on(:change) {
        if @form.fields[4].checked.to_i == 1
          @form.show(5)
        else
          @form.hide(5)
        end
      }
      @form.fields[4].trigger(:change)
      @form.fields[7].on(:change) {
        if @form.fields[7].checked.to_i == 1
          @form.show(8)
          @form.show(9)
        else
          @form.hide(8)
          @form.hide(9)
        end
      }
      @form.fields[7].trigger(:change)
    }
  end

  def load_posts
    setting_category(p_("Blog", "Posts"))
    make_setting(p_("Blog", "Posts displayed per page on the website"), :number, "posts_per_page")
    make_setting(p_("Blog", "Use emoticons"), :bool, "use_smilies")
    links = [p_("Blog", "Simple (https://example.com/?p=123)"), p_("Blog", "Full date and post name (https://example.com/2020/01/01/example-post)"), p_("Blog", "Month and post name (https://example.com/2020/01/example-post)"), p_("Blog", "Just a post id (https://example.com/posts/123/)"), p_("Blog", "Just a post name (https://example.com/example-post/)")]
    linksmapping = ["", "/%year%/%monthnum%/%day%/%postname%/", "/%year%/%monthnum%/%postname%/", "/post/%post_id%", "/%postname%/"]
    if !linksmapping.include?(currentconfig("permalink_structure"))
      linksmapping.push(currentconfig("permalink_structure"))
      links.push(p_("Blog", "Custom"))
    end
    make_setting(p_("Blog", "Links format"), links, "permalink_structure", linksmapping)
    make_setting(p_("Blog", "Posts in RSS"), :number, "posts_per_rss")
    make_setting(p_("Blog", "Use excerpts in RSS"), :bool, "rss_use_excerpt")
  end

  def load_date
    setting_category(p_("blog", "Date and time"))
    datesmapping = ["j F Y", "Y-m-d", "m/d/Y", "d/m/Y", "F j, Y", "d.m.Y"]
    dates = [p_("Blog", "31 January 2020"), "2020-01-31", "01/31/2020", "31/01/2020", p_("Blog", "January 31, 2020"), "31.01.2020"]
    make_setting(p_("Blog", "Date format"), dates, "date_format", datesmapping)
    timesmapping = ["H:i", "g:i A", "H:i:s", "g:i:s A"]
    times = ["14:54", "02:54 PM", "14:54:34", "02:54:34 PM"]
    make_setting(p_("Blog", "Time format"), times, "time_format", timesmapping)
    timezones = []
    timezonesmapping = []
    getconfig if @timezones == nil
    for k in @timezones.keys
      timezones.push(@timezones[k])
      timezonesmapping.push(k)
    end
    timezones.push("UTC")
    timezonesmapping.push("UTC")
    if currentconfig("timezone_string") == ""
      timezones.push(p_("Blog", "Custom"))
      timezonesmapping.push("")
    end
    make_setting(p_("Blog", "Timezone city"), timezones, "timezone_string", timezonesmapping)
    days = [p_("Blog", "Sunday"), p_("Blog", "Monday"), p_("Blog", "Tuesday"), p_("Blog", "Wednesday"), p_("Blog", "Thursday"), p_("Blog", "Friday"), p_("Blog", "Saturday")]
    make_setting(p_("Blog", "First day of the week"), days, "start_of_week")
  end

  def load_others
    setting_category(p_("Blog", "Others"))
    if holds_premiumpackage("scribe")
      blogs = get_blogs
      b = [p_("Blog", "Do not set")]
      bm = [""]
      for bl in blogs
        if bl.url != "https://" + @domain + "/"
          b.push(bl.name + " (" + bl.url + ")")
          bm.push(bl.url)
        end
      end
      u = currentconfig("blog_redirect")
      if !bm.include?(u)
        b.push(u)
        bm.push(u)
      end
      make_setting(p_("Blog", "If you want to redirect all browsers visiting this blog to another site, select it here"), b, "blog_redirect", bm)
    end
    make_setting(p_("Blog", "My Wordpress account"), :custom, Proc.new { insert_scene(Scene_Blog_Profile.new) })
    make_setting(p_("Blog", "Open Wordpress admin panel in my browser"), :custom, Proc.new {
      bt = srvproc("blog_domains", { "ac" => "getblogdomain", "searchname" => @blog })
      if bt[0].to_i < 0
        alert(_("Error"))
        return $scene = Scene_Main.new
      else
        d = "https://" + bt[1] + "/wp-admin"
        process_url(d)
      end
    })
    make_setting(p_("Blog", "Manage tags"), :custom, Proc.new { insert_scene(Scene_Blog_Tags.new(@blog)) })
    make_setting(p_("Blog", "Manage blog domain"), :custom, Proc.new {
      c = false
      if @changed
        confirm(p_("Blog", "Blog settings have been changed. If you continue to domain change, mades you changed will be lost. Do you want to continue anyway? If you want to store new settings, select No and then Apply them before proceeding with domain change.")) { c = true }
      else
        c = true
      end
      $scene = Scene_Blog_Domain.new(@blog, @scene) if c
    })
  end

  def get_blogs
    prm = { "details" => 2, "user" => Session.name }
    blogtemp = srvproc("blog_list", prm)
    blogs = []
    rows = 9
    items = blogtemp[1].to_i
    for i in 0...items
      l = i * rows + 2
      b = Struct_Blog_Blog.new
      b.id = blogtemp[l].delete("\r\n")
      b.name = blogtemp[l + 1].delete("\r\n")
      b.cnt_posts = blogtemp[l + 2].to_i
      b.cnt_comments = blogtemp[l + 3].to_i
      b.url = blogtemp[l + 4].delete("\r\n")
      b.lastpost = blogtemp[l + 5].to_i
      b.description = blogtemp[l + 6].delete("\r\n")
      b.followed = blogtemp[l + 7].to_i.to_b
      b.lang = blogtemp[l + 8].delete("\r\n")
      blogs.push(b)
    end
    return blogs
  end

  def main
    @changed = false
    make_window
    load_general
    load_comments
    load_posts
    load_date
    load_others
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

class Struct_Blog_Blog
  attr_accessor :id, :name, :description, :cnt_posts, :cnt_comments, :url, :lastpost, :followed, :lang, :owners, :elten, :library, :library_user

  def initialize
    @id = ""
    @name = ""
    @description = ""
    @cnt_posts = 0
    @cnt_comments = 0
    @url = ""
    @lastpost = 0
    @followed = false
    @lang = ""
    @owners = []
    @elten = false
    @library = false
    @library_user = nil
  end
end

class Struct_Blog_Post
  attr_accessor :owner
  attr_accessor :id
  attr_accessor :name
  attr_accessor :unread
  attr_accessor :audio
  attr_accessor :audio_url
  attr_accessor :excerpt
  attr_accessor :author
  attr_accessor :text
  attr_accessor :date
  attr_accessor :moddate
  attr_accessor :url
  attr_accessor :comments
  attr_accessor :followed
  attr_accessor :mention
  attr_accessor :iseltenuser

  def initialize(id = 0)
    @id = id
    @audio = false
    @unread = false
    @name = ""
    @owner = Session.name
    @author = ""
    @text = ""
    @date = 0
    @moddate = 0
    @iseltenuser = false
    @audio_url = ""
    @excerpt = ""
    @url = ""
    @comments = 0
    @followed = false
  end
end

class Scene_Blog_Tags
  def initialize(owner, scene = nil)
    @owner = owner
    @scene = scene
  end

  def main
    bt = srvproc("blog_tags", { "searchname" => @owner, "ac" => "get" })
    if bt[0].to_i < 0
      alert(_("Error"))
      return $scene = Scene_Main.new
    end
    @tags = []
    for i in 0...bt[1].to_i
      @tags.push(Struct_Blog_Tag.new(bt[2 + 2 * i].to_i))
      @tags.last.name = bt[2 + i * 2 + 1].delete("\r\n")
    end
    @sel = ListBox.new(@tags.map { |t| t.name }, p_("Blog", "Tags"), 0, 0, false)
    @sel.bind_context { |menu|
      menu.option(p_("Blog", "New tag"), nil, "n") {
        tagname = input_text(p_("Blog", "Tag name"), 0, "", true)
        if tagname != nil
          bt = srvproc("blog_tags", { "searchname" => @owner, "ac" => "add", "tagname" => tagname })
          if bt[0].to_i < 0
            alert(_("Error"))
          else
            @tags.push(Struct_Blog_Tag.new(bt[1].to_i))
            @tags.last.name = tagname
            @sel.options.push(tagname)
            @sel.focus
          end
        end
      }
      if @tags.size > 0
        menu.option(p_("Blog", "Delete tag"), nil, :del) {
          bt = srvproc("blog_tags", { "searchname" => @owner, "ac" => "delete", "tagid" => @tags[@sel.index].id })
          if bt[0].to_i < 0
            alert(_("error"))
          else
            @tags.delete_at(@sel.index)
            @sel.options.delete_at(@sel.index)
            play("editbox_delete")
            @sel.say_option
          end
        }
      end
    }
    loop do
      loop_update
      @sel.update
      break if escape
    end
    if @scene != nil
      $scene = @scene
    else
      $scene = Scene_Main.new
    end
  end
end

class Struct_Blog_Tag
  attr_accessor :id, :name

  def initialize(id = 0)
    @id = id
    @name = ""
  end
end

class Scene_Blog_PostEditor
  def initialize(owner, post = 0, category = 0, categoryselindex = 0, postselindex = 0)
    @owner = owner
    @post = post
    @category = category
    @categoryselindex = categoryselindex
    @postselindex = postselindex
  end

  def main
    resetdate = false
    bt = srvproc("blog_categories", { "searchname" => @owner })
    if bt[0].to_i < 0
      alert(_("Error"))
      speech_wait
      return $scene = Scene_Main.new
    end
    @categories = []
    for i in 0...bt[1].to_i
      c = Struct_Blog_Category.new
      c.id = bt[2 + i * 2].to_i
      c.name = bt[2 + i * 2 + 1].delete("\r\n")
      @categories.push(c)
    end
    bt = srvproc("blog_tags", { "searchname" => @owner, "ac" => "get" })
    if bt[0].to_i < 0
      alert(_("Error"))
      speech_wait
      return $scene = Scene_Main.new
    end
    @tags = []
    for i in 0...bt[1].to_i
      t = Struct_Blog_Tag.new
      t.id = bt[2 + i * 2].to_i
      t.name = bt[2 + i * 2 + 1].delete("\r\n")
      @tags.push(t)
    end
    @fields = [
      edt_title = EditBox.new(p_("Blog", "Post title"), "", "", true),
      lst_editor = ListBox.new([p_("Blog", "Formattable editor"), p_("Blog", "Source Editor (HTML and Wordpress Shortcodes)")], p_("Blog", "Editor")),
      edt_post = EditBox.new(p_("Blog", "Post"), EditBox::Flags::MultiLine | EditBox::Flags::HTML | EditBox::Flags::Formattable, "", true),
      btn_audio = OpusRecordButton.new(p_("Blog", "Audio content"), Dirs.temp + "\\audioblogpost.opus", 128),
      lst_categories = ListBox.new(@categories.map { |c| c.name }, p_("Blog", "Post categories"), 0, ListBox::Flags::MultiSelection),
      lst_tags = ListBox.new([], p_("Blog", "Post tags")),
      lst_visibility = ListBox.new([p_("Blog", "Show to everyone"), p_("Blog", "Show to Elten users only")], p_("Blog", "Visibility")),
      edt_excerpt = EditBox.new(p_("Blog", "Excerpt"), EditBox::Flags::MultiLine, "", true),
      chk_schedule = CheckBox.new(p_("Blog", "Schedule this post to be published in the future")),
      btn_scheduledate = DateButton.new(p_("Blog", "Publication date"), Time.now.year, Time.now.year + 3, true),
      chk_comments = CheckBox.new(p_("Blog", "Allow users to comment this post"), 1),
      btn_send = Button.new(p_("Blog", "Send")),
      btn_cancel = Button.new(_("Cancel"))
    ]
    @tagids = []
    lst_tags.bind_context { |menu|
      menu.option(p_("Blog", "Add existing tag to this post"), nil, "e") {
        dialog_open
        tag = selecttag
        dialog_close
        for t in @tags
          if tag != nil and t.name.downcase == tag.name.downcase
            tagid = t.id
            break
          end
        end
        if tag != nil and tagid > 0
          @tagids.push(tagid)
          lst_tags.options.push(tag.name)
          lst_tags.focus
        end
      }
      menu.option(p_("Blog", "Add tag to this post"), nil, "n") {
        tagname = input_text(p_("Blog", "Tag to add"), 0, "", true)
        if tagname != nil
          tagid = -1
          for t in @tags
            if t.name.downcase == tagname.downcase
              tagid = t.id
              break
            end
          end
          if tagid == -1 and confirm(p_("Blog", "This tag does not exist, do you want to create it now?")) == 1
            bt = srvproc("blog_tags", { "searchname" => @owner, "ac" => "add", "tagname" => tagname })
            tagid = bt[1].to_i if bt[0].to_i == 0
          end
          if tagid > 0
            @tagids.push(tagid)
            lst_tags.options.push(tagname)
            lst_tags.focus
          end
        end
      }
      if @tagids.size > 0
        menu.option(p_("Blog", "Remove tag from this post"), nil, :del) {
          @tagids.delete_at(lst_tags.index)
          lst_tags.options.delete_at(lst_tags.index)
          play("editbox_delete")
          lst_tags.say_option
        }
      end
    }
    changed = false
    edt_post.on(:delete) { changed = true }
    edt_post.on(:insert) { changed = true }
    for i in 0...@categories.size
      lst_categories.selected[i] = true if @categories[i].id == @category
    end
    if @post > 0
      bt = srvproc("blog_post_details", { "searchname" => @owner, "postid" => @post, "details" => 1 })
      if bt[0].to_i < 0
        alert(_("Error"))
        speech_wait
        return $scene = Scene_Main.new
      end
      title = bt[1].delete("\r\n")
      privacy = bt[2].to_i
      comments = bt[3].to_i
      cats = bt[4].delete("\r\n").split(",").map { |x| x.to_i }
      tags = bt[5].delete("\r\n").split(",").map { |x| x.to_i }
      time = bt[6].to_i
      if time.to_i > Time.now.to_i + 60
        resetdate = true
        chk_schedule.checked = 1
        tim = Time.at(time.to_i)
        btn_scheduledate.setdate(tim.year, tim.month, tim.day, tim.hour, tim.min, tim.sec)
      end
      l = 11
      post = ""
      while bt[l].delete("\r\n") != "\004END\004" && l < bt.size
        post += bt[l]
        l += 1
      end
      l += 1
      excerpt = ""
      while bt[l].delete("\r\n") != "\004END\004" && l < bt.size
        excerpt += bt[l]
        l += 1
      end
      post.gsub!(/\[audio[^\]]*src\=(([^\" ]+)|(\"[^\"]+\"))[^\]]*\]\[\/audio\]/) {
        ph = $1
        ph[0..0] = "" if ph[0..0] == "\""
        ph.chop! if ph[-1..-1] == "\""
        if ph.include?("https://s.elten-net.eu") && ph[-4..-1].downcase == ".mp3"
          ph[-4..-1] = ".opus"
        elsif ph.include?("https://s.elten.link") && ph[-4..-1].downcase == ".mp3"
          ph[-4..-1] = ".opus"
        end
        btn_audio.set_source(ph)
        ""
      }
      edt_title.set_text(title)
      edt_post.set_text(post)
      edt_excerpt.set_text(excerpt)
      chk_comments.checked = comments
      lst_visibility.index = privacy
      for i in 0...@categories.size
        lst_categories.selected[i] = (cats.include?(@categories[i].id))
      end
      for tagid in tags
        for tag in @tags
          if tag.id == tagid
            @tagids.push(tagid)
            lst_tags.options.push(tag.name)
          end
        end
      end
    end
    @lasteditor = 0
    lst_editor.on(:move) {
      if @lasteditor == 0
        text = edt_post.text_html
      else
        text = edt_post.text
      end
      flags = EditBox::Flags::MultiLine
      if lst_editor.index == 0
        flags |= EditBox::Flags::HTML | EditBox::Flags::Formattable
      end
      edt_post.flags = flags
      edt_post.set_text(text)
      @lasteditor = lst_editor.index
    }
    @form = Form.new(@fields)
    @form.hide(btn_scheduledate) if chk_schedule.checked == 0
    @form.hide(chk_schedule) if chk_schedule.checked == 0 && !holds_premiumpackage("scribe")
    chk_schedule.on(:change) {
      if chk_schedule.checked == 1
        @form.show(btn_scheduledate)
      else
        @form.hide(btn_scheduledate)
      end
    }
    loop do
      loop_update
      #if btn_audio.empty?
      #@form.show(lst_editor)
      #@form.show(edt_post)
      #else
      #@form.hide(lst_editor)
      #@form.hide(edt_post)
      #end
      @form.update
      if escape or btn_cancel.pressed?
        if !changed or confirm(p_("Blog", "Are you sure you want to cancel creating this post?")) == 1
          break if btn_audio.delete_audio == true
        end
      end
      if btn_send.pressed? || ($key[0x11] && enter)
        date = 0
        suc = true
        if chk_schedule.checked == 1
          if btn_scheduledate.year == 0
            alert(p_("Blog", "Publication date not set"))
          else
            tim = Time.local(btn_scheduledate.year, btn_scheduledate.month, btn_scheduledate.day, btn_scheduledate.hour, btn_scheduledate.min, btn_scheduledate.sec)
            if tim.to_i <= Time.now.to_i
              alert(p_("Blog", "Selected publication date that is in the past"))
              suc = false
            else
              date = tim.to_i
            end
          end
        end
        case lst_editor.index
        when 0
          text = edt_post.text_html
        when 1
          text = edt_post.text
        end
        cats = []
        for i in 0...@categories.size
          cats.push(@categories[i].id) if lst_categories.selected[i] == true
        end
        if suc
          params = { "type" => "source", "categoryid" => cats.join(","), "tags" => @tagids.join(","), "postname" => edt_title.text, "privacy" => lst_visibility.index, "comments" => chk_comments.checked, "searchname" => @owner }
          params["date"] = date if date != 0
          params["date"] = Time.now.to_i if params["date"] == nil && resetdate
          if @post > 0
            params["postid"] = @post
            params["edit"] = 1
          else
            params["add"] = 1
          end
          params["buffer_excerpt"] = buffer(edt_excerpt.text) if edt_excerpt.text != "" || @post > 0
          audio = btn_audio.get_file(true)
          if audio == nil
            if changed
              buf = buffer(text)
              params["buffer"] = buf
            end
            bt = srvproc("blog_posts_mod", params)
          else
            if text.delete("\r\n ") != ""
              buf = buffer(text)
              params["buffer"] = buf
            end
            alert(p_("Blog", "Please wait..."))
            fl = readfile(audio)
            if fl[0..3] != "OggS"
              alert(_("Error"))
              return $scene = Scene_Main.new
            end
            params["audio"] = 1
            bt = srvproc("blog_posts_mod", params, 0, { "post" => fl })
          end
          if bt[0].to_i < 0
            alert(_("Error"))
          else
            alert(p_("Blog", "The post has been added."))
            btn_audio.delete_audio(true)
            break
          end
        end
      end
    end
    $scene = Scene_Blog_Posts.new(@owner, @category, @categoryselindex, @postselindex)
  end

  def selecttag
    if @tags.size < 1
      alert(p_("Blog", "There are currently no tags created, please add a new one."))
      return nil
    end
    sel = ListBox.new(@tags.map { |t| t.name }, p_("Blog", "Select tag"), 0, 0, false)
    loop do
      loop_update
      sel.update if @tags.size > 0
      if escape
        loop_update
        return(nil)
      end
      if enter and @tags.size > 0
        loop_update
        play("listbox_select")
        return(@tags[sel.index])
      end
    end
  end
end

class Struct_Blog_Category
  attr_accessor :id
  attr_accessor :posts
  attr_accessor :url
  attr_accessor :name
  attr_accessor :parent

  def initialize
    @id = 0
    @name = ""
    @parent = 0
    @url = ""
    @posts = 0
  end
end

class Scene_Blog_Comments
  def initialize(blog = nil, status = "hold", scene = nil)
    @blog = blog
    @blog = Session.name if blog == nil
    @status = status
    @scene = scene
  end

  def main
    @comments = []
    @sel = TableBox.new([nil, p_("Blog", "Post"), p_("Blog", "Comment")], [], 0, p_("Blog", "Comments"))
    @sel.bind_context { |menu| context(menu) }
    refresh
    @sel.focus
    loop do
      loop_update
      @sel.update
      break if escape
    end
    if @scene == nil
      $scene = Scene_Main.new
    else
      $scene = @scene
    end
  end

  def context(menu)
    if @comments.size > 0
      menu.option(p_("Blog", "Approve"), nil, "r") {
        assign(@comments[@sel.index], "approve")
      }
      if @status != "spam"
        menu.option(p_("Blog", "Assign as spam"), nil, "m") {
          assign(@comments[@sel.index], "spam")
        }
      end
      menu.option(p_("Blog", "Delete"), nil, :del) {
        confirm(p_("Blog", "Are you sure you want to delete this comment?")) {
          deletecomment(@comments[@sel.index])
        }
      }
    end
    menu.submenu(p_("Blog", "Show")) { |m|
      if @status != "hold"
        m.option(p_("Blog", "Pending comments")) {
          @status = "hold"
          refresh
          @sel.focus
        }
      end
      if @status != "spam"
        m.option(p_("Blog", "Comments assigned as spam")) {
          @status = "spam"
          refresh
          @sel.focus
        }
      end
    }
  end

  def assign(comment, status)
    srvproc("blog_comments", { "ac" => "assign", "type" => status, "comment" => comment.id, "searchname" => @blog })
    refresh
    @sel.say_option
  end

  def deletecomment(comment)
    srvproc("blog_comments", { "ac" => "delete", "comment" => comment.id, "searchname" => @blog })
    refresh
    play("editbox_delete")
    @sel.say_option
  end

  def refresh
    ct = srvproc("blog_comments", { "ac" => "list", "type" => @status, "searchname" => @blog })
    if ct[0].to_i == 0
      @comments.clear
      cnt = ct[1].to_i
      t = 0
      for l in 2...ct.size
        case t
        when 0
          @comments.push(Struct_Blog_Comment.new)
          @comments.last.id = ct[l].to_i
          t += 1
        when 1
          @comments.last.author = ct[l].delete("\r\n")
          t += 1
        when 2
          @comments.last.postname = ct[l].delete("\r\n")
          t += 1
        when 3
          x = ct[l].delete("\r\n")
          if x == "\004END\004"
            t = 0
          else
            @comments.last.content += ct[l].delete("\r\n") + "\r\n"
          end
        end
      end
      @sel.rows = nil
      r = []
      for c in @comments
        r.push([c.author, c.postname, c.content])
      end
      @sel.rows = r
      @sel.reload
    end
  end
end

class Struct_Blog_Comment
  attr_accessor :id, :postname, :author, :content

  def initialize
    @id = 0
    @postname = ""
    @author = ""
    @content = ""
  end
end

class Scene_Blog_Followers
  def initialize(owner = Session.name, scene = nil)
    @owner = owner
    @scene = scene
  end

  def main
    if @owner != nil
      b = srvproc("blog_followers", { "list" => "blog", "details" => 1, "searchname" => @owner })
    else
      b = srvproc("blog_followers", { "list" => "new", "details" => 1 })
    end
    if b[0].to_i == 0
      users = []
      blogs = []
      blognames = []
      for i in 0...b[1].to_i
        blogs.push(b[2 + i * 3].delete("\r\n"))
        blognames.push(b[2 + i * 3 + 1].delete("\r\n"))
        users.push(b[2 + i * 3 + 2].delete("\r\n"))
      end
      if users.size == 0
        alert(p_("Blog", "This blog is not followed by any user"))
      else
        rows = []
        for i in 0...b[1].to_i
          rows.push([users[i], blognames[i]])
        end
        head = p_("Blog", "Followers")
        head = "" if @owner == nil
        @sel = TableBox.new([nil, p_("Blog", "Blog")], rows, 0, head, false)
        @sel.bind_context { |menu|
          if blogs.size > 0
            menu.useroption(users[@sel.index])
            menu.option(p_("Blog", "Open blog")) { insert_scene(Scene_Blog_Main.new(blogs[@sel.index], 0, Scene_Main.new)) }
          end
        }
        loop do
          loop_update
          @sel.update
          usermenu(users[@sel.index]) if enter and users.size > 0
          break if escape or arrow_left or $scene != self
        end
      end
    else
      alert(_("Error"))
    end
    $scene = @scene
    $scene = Scene_Main.new if $scene == nil
  end
end

class Struct_Blog_Mention
  attr_accessor :id, :blog, :postid, :author, :message, :time
end

class Scene_Blog_Domain
  def initialize(blog = nil, scene = nil)
    blog = Session.name if blog == nil
    @blog = blog
    @scene = scene
  end

  def main
    bt = srvproc("blog_domains", { "ac" => "getblogdomain", "searchname" => @blog })
    if bt[0].to_i < 0
      alert(_("Error"))
      return $scene = Scene_Main.new
    end
    @trname = bt[2].delete("\r\n")
    @form = Form.new ([
      @txt_olddomain = EditBox.new(p_("Blog", "Current blog domain"), EditBox::Flags::ReadOnly, bt[1].delete("\r\n"), true),
      @btn_change = Button.new(p_("Blog", "Change")),
      nil, nil, nil, nil, nil,
      @btn_cancel = Button.new(_("Cancel"))
    ])
    @btn_change.on(:press) { changer }
    @done = false
    loop do
      loop_update
      @form.update
      break if escape or @btn_cancel.pressed? or @done
    end
    if @scene == nil
      $scene = Scene_Main.new
    else
      $scene = @scene
    end
  end

  def changer
    @lst_domaintype = @form.fields[2] = ListBox.new([
      p_("Blog", "Personal Elten blog domain (%{username}.elten.blog)") % { "username" => Session.name },
      p_("Blog", "Shared Elten blog domain (selectedname.s.elten.blog)"),
      p_("Blog", "External domain")
    ], p_("Blog", "Domain type"))
    @lst_domaintype.disable_item(2) if !holds_premiumpackage("scribe")
    @txt_domaininstructions = @form.fields[3] = EditBox.new(p_("Blog", "Buying your own domain"), EditBox::Flags::ReadOnly, p_("Blog", "To continue, you should point your domain to Elten Blogging server.\nYou can buy your own domain from domain providers, such as ovh.com, domain.com, godaddy.com or bluehost.com."), true)
    @edt_domain = @form.fields[4] = EditBox.new("", 0, "", true)
    @txt_fulldomain = @form.fields[5] = EditBox.new(p_("Blog", "Final new blog address"), EditBox::Flags::ReadOnly, "", true)
    @btn_next = @form.fields[6] = Button.new(p_("Blog", "Proceed with domain change"))
    @edt_domain.on(:change) {
      case @lst_domaintype.index
      when 0
        @txt_fulldomain.set_text((@trname + ".elten.blog").downcase)
      when 1
        @txt_fulldomain.set_text((@edt_domain.text + ".s.elten.blog").downcase)
      when 2
        @txt_fulldomain.set_text((@edt_domain.text).downcase)
      end
    }
    @lst_domaintype.on(:move) {
      case @lst_domaintype.index
      when 0
        @form.hide(@edt_domain)
        @form.hide(@txt_domaininstructions)
      when 1
        @form.show(@edt_domain)
        @form.hide(@txt_domaininstructions)
        @edt_domain.header = p_("Blog", "Domain prefix (prefix.s.elten.blog)")
      when 2
        @form.show(@edt_domain)
        @form.show(@txt_domaininstructions)
        @edt_domain.header = p_("Blog", "Domain (like example.com)")
      end
      @edt_domain.trigger(:change)
    }
    @lst_domaintype.trigger(:move)
    @btn_next.on(:press) { @done = changeproceed }
    @form.hide(@btn_change)
    @form.index = @lst_domaintype
    @form.focus
  end

  def changevalidate
    if @txt_fulldomain.text == @txt_olddomain.text
      alert(p_("Blog", "The new domain is the same as a previous one"))
      return false
    end
    if @lst_domaintype.index == 0 && srvproc("blog_exist", { "searchname" => Session.name })[1].to_i == 1
      alert(p_("Blog", "You already have one blog associated with your Elten profile. Please change its type and then proceed."))
      return false
    end
    if @lst_domaintype.index == 1 && @edt_domain.text.include?(".")
      alert(p_("Blog", "Only first level subdomains are allowed"))
      return false
    end
    if @lst_domaintype.index == 1 && @edt_domain.text.size < 3
      alert(p_("Blog", "Blog subdomain must be at least 3 characters long"))
      return false
    end
    dom = @txt_fulldomain.text
    if (/[^a-z0-9\.\-]/ =~ dom) != nil
      alert(p_("Blog", "The entered domain contains invalid characters"))
      return false
    end
    if dom[0..0] == "." || dom[0..0] == "-" || dom.include?("-.") || dom.include?(".-") || dom[-1..-1] == "." || dom[-1..-1] == "-" || !dom.include?(".") || dom.split(".").last.size < 2 || dom == "elten.blog"
      alert(p_("Blog", "The entered domain is not valid"))
      return false
    end
  end

  def changeproceed
    return false if changevalidate == false
    return false if confirm(p_("Blog", "Warning! If you change your blog URL, some links may stop working. If you directly linked posts or other resources on your blog, they would no longer be available at previous URLs. In such case you will be required to fix them manually. Are you sure you want to continue?")) == 0
    dom = @txt_fulldomain.text
    d = ".elten.blog"
    if dom[-1 * d.size..-1] != d
      if externalchangecheck(dom) == false
        @form.focus
        return false
      end
    end
    s = srvproc("blog_domains", { "ac" => "change", "blog" => @blog, "domain" => dom })
    if s[0].to_i < 0
      alert(_("Error"))
      return false
    else
      alert(p_("Blog", "Blog domain changed"))
      return true
    end
  end

  def externalchangecheck(domain)
    dt = srvproc("blog_domains", { "ac" => "propers" })
    return false if dt[0].to_i < 0
    host = dt[1].delete("\r\n")
    ip = dt[2].delete("\r\n")
    text = p_("Blog", "You should now configure your purchased domain to redirect to Elten blogging server. Below are the necessary details. If you have any problems, please feel free to ask questions in the forum.
      
      Wherever possible, we recommend that you use the CNAME record, as it does not need to be edited if the IP address of the server hosting your blog changes. Your blog's IP address may change, for example, due to a Elten Blogging Server migration. By configuring your domain's CNAME record, you don't need to do anything else.
      To do this, please point your cname record to destination \"%{host}.\"
      
      Unfortunately, many domain registrars do not support the CNAME record for top-level domains, so you may want to use the A record instead.
      In such a case, please point the A record to IP address:
%{ip}
.

Please note that redirecting your domain is not aliasing and setting aliases or HTTP 301/ 3xx redirections will not work.

You can get detailed description from your domain provider, for example at:
https://support.us.ovhcloud.com/hc/en-us/articles/115001994890-Getting-Familiar-with-DNS

Once completed, please continue.") % { "ip" => ip, "host" => host }
    form = Form.new([
      txt = EditBox.new(p_("Blog", "Setting the domain"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, text, true),
      btn_next = Button.new(p_("Blog", "Ready, take me next")),
      btn_cancel = Button.new(_("Cancel"))
    ])
    r = true
    btn_cancel.on(:press) {
      r = false
      form.resume
    }
    form.cancel_button = btn_cancel
    btn_next.on(:press) {
      ch = srvproc("blog_domains", { "ac" => "check", "domain" => domain })
      if ch[1].to_i == 0
        alert(p_("Blog", "Your domain is not pointing to Elten Blogs, please try again or wait a while to refresh DNS. It may take up to 24 hours to perform full DNS update."))
      elsif ch[1].to_i == 1
        alert(p_("Blog", "Your domain is pointing to Elten blogs, but www prefix is not. Please fix it."))
      else
        return true
      end
    }
    form.wait
    return r
  end
end
