class Scene_FeedViewer
  def initialize(n, scene = nil, first = true)
    @ind = -1
    @n = n
    @scene = scene
    @first = first
  end

  def main
    l = nil
    if @n.is_a?(String)
      l = srvproc("feeds", { "ac" => "show", "user" => @n, "details" => 2 })
    elsif @n.is_a?(FeedMessage)
      if @n.responses > 0
        l = srvproc("feeds", { "ac" => "showresponses", "id" => @n.id, "details" => 2 })
      elsif @n.response > 0
        l = srvproc("feeds", { "ac" => "showresponses", "id" => @n.response, "details" => 2 })
      end
    end
    if l == nil || l[0].to_i != 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    l = l.map { |s| s.delete("\r\n") }
    @feeds = []
    c = 0
    feed = nil
    for i in 2...l.size
      case c
      when 0
        feed = FeedMessage.new(l[i].to_i)
      when 1
        feed.user = l[i]
      when 2
        feed.time = l[i].to_i
      when 3
        if l[i] != "\004END\004"
          feed.message += "\n" if feed.message != ""
          feed.message += l[i]
          c -= 1
        end
      when 4
        feed.response = l[i].to_i
      when 5
        feed.responses = l[i].to_i
      when 6
        feed.likes = l[i].to_i
      when 7
        feed.liked = (l[i].to_i == 1)
        @feeds.push(feed)
        c = -1
      end
      c += 1
    end
    selt = @feeds.map { |f|
      str = f.user
      str += "\004LIKED\004" if f.liked
      str += ": " + f.message + " "
      str += "(" + np_("FeedViewer", "%{count} user likes it", "%{count} users like it", f.likes) % { "count" => f.likes } + ") " if f.likes > 0
      begin
        str += format_date(Time.at(f.time)) + "#{if f.responses > 0; "\004CONTAINING\004"; else; ""; end}"
      rescue Exception
      end
      str
    }
    ind = 0
    ind = selt.size - 1 if selt.size > 0 && @n.is_a?(FeedMessage)
    ind = @ind if @ind != -1
    @sel = ListBox.new(selt, p_("FeedViewer", "Feed"), ind, 0, false)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      break if escape or (@first != true && @sel.collapsed?)
      break if $scene != self
      if @sel.expanded? && @feeds.size > 0 && @feeds[@sel.index].responses > 0
        feed = @feeds[@sel.index]
        $scene = Scene_FeedViewer.new(feed, $scene, false)
      end
      if @sel.selected? and @feeds.size > 0
        feedshow(@feeds[@sel.index])
        loop_update
      end
    end
    @ind = @sel.index
    if $scene == self
      if @scene != nil
        $scene = @scene
      else
        $scene = Scene_Main.new
      end
    end
  end

  def context(menu)
    if @feeds.size > 0
      feed = @feeds[@sel.index]
      menu.useroption(feed.user)
      if feed.responses > 0
        menu.option(p_("FeedViewer", "Show responses"), nil, "d") {
          $scene = Scene_FeedViewer.new(feed, $scene, false)
        }
      elsif feed.response > 0
        menu.option(p_("FeedViewer", "Show conversation"), nil, "d") {
          $scene = Scene_FeedViewer.new(feed, $scene, false)
        }
      end
      if feed.likes > 0
        menu.option(p_("FeedViewer", "Show likes"), nil, "K") {
          lk = srvproc("feeds", { "ac" => "likes", "message" => feed.id })
          likes = []
          likes = lk[2..-1].map { |l| l.delete("\r\n") } if lk[0].to_i == 0
          users = likes
          dialog_open
          lst = ListBox.new(users, p_("FeedViewer", "Users who like this post"), 0, 0, false)
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
      menu.option(p_("FeedViewer", "Reply"), nil, "r") {
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
      s = p_("FeedViewer", "Like this message")
      s = p_("FeedViewer", "Dislike this message") if feed.liked
      menu.option(s, nil, "k") {
        if srvproc("feeds", { "ac" => "liking", "message" => feed.id, "like" => (feed.liked) ? (0) : (1) })[0].to_i < 0
          alert(_("Error"))
        else
          st = (feed.liked) ? (p_("FeedViewer", "Message disliked")) : (p_("FeedViewer", "Message liked"))
          feed.liked = !feed.liked
          alert(st)
        end
      }
      if feed.user == Session.name
        menu.option(_("Delete"), nil, :del) {
          delete_feed(feed.id)
          play("editbox_delete")
          @sel.disable_item(@sel.index)
        }
      end
    end
    menu.option(p_("FeedViewer", "Publish to a feed"), nil, "n") { feed_new }
  end

  def feed_new(users = [], response = 0)
    text = users.map { |u| "@" + u }.join(" ")
    text << " " if text != ""
    inp = input_text(p_("FeedViewer", "Message"), 0, text, true, [], [], 300, true)
    feed(inp, response) if inp != nil
  end
end
