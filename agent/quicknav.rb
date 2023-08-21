# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2023 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class CustomNavCat
  attr_accessor :name, :available_proc, :onetimer

  def initialize(name = "")
    @name = name
    @available_proc = Proc.new { true }
    @onetimer = true
    @options = []
    @index = 0
  end

  def add_option(s, &b)
    @options.push([s, b])
  end

  def options
    @options.dup
  end

  def delete_option(i)
    @options.delete_at(i)
    @index -= 1 if @index >= @options.size && @index > 0
  end

  def select_option(ch, repeat = true)
    if ch.is_a?(Numeric)
      nc = @index + ch
    elsif ch == :first
      nc = 0
    elsif ch == :last
      nc = @options.size - 1
    else
      nc = 0
    end
    if nc >= @options.size || nc < 0
      play("border")
      select_option(0, false) if repeat
    else
      @index = nc
      play("listbox_move")
      if @options[@index][0].is_a?(String)
        speak(@options[@index][0])
      elsif @options[@index][0].is_a?(Proc)
        speak(@options[@index][0].call)
      end
    end
  end

  def call_option
    option = @options[@index]
    option[1].call if option != nil and option[1] != nil
  end

  def call(ac)
    case ac
    when :up
      select_option(-1)
    when :down
      select_option(1)
    when :say
      select_option(0)
    when :first
      select_option(:first)
    when :last
      select_option(:last)
    when :select
      call_option
    end
  end
end

$nav_cats = ["messages", "feed", "conference"]
$nav_cat = nil

def set_navcat(ch, quiet = false, bg = nil)
  nc = $nav_cats.find_index($nav_cat)
  if nc == nil
    for i in 0...$nav_cats.size
      nc = i
      break if $iicards != nil && $iicards.include?($nav_cats[i])
      return if $nav_cats.size - 1 == i
    end
  end
  nc = (nc + ch) % $nav_cats.size
  $nav_cat = $nav_cats[nc]
  if !isavailable_navcat
    if bg == nc
      play("border")
      return
    else
      bg ||= nc
      ch = 1 if ch == 0
      return set_navcat(ch, quiet, bg)
    end
  end
  return if quiet
  case $nav_cat
  when "messages"
    speak(p_("Messages", "Messages"))
  when "feed"
    speak(p_("FeedViewer", "Feed"))
  when "conference"
    speak(p_("Conference", "Conference"))
  else
    speak($nav_cat.name) if $nav_cat.is_a?(CustomNavCat)
  end
end

def isavailable_navcat
  set_navcat(0, true) if $nav_cat == nil
  if $nav_cat.is_a?(CustomNavCat)
    r = $nav_cat.available_proc.call
    $nav_cats.delete($nav_cat) if $nav_cat.onetimer
    return r
  end
  $iicards.include?($nav_cat) && ($nav_cat != "conference" || $conference != nil)
end

def qnplay(url)
  qnstop
  url = "https://srvapi.elten.link/leg1" + url if url[0..0] == "/"
  $qnaudio = Bass::Sound.new(url, 1, false, false, nil)
  $qnaudio.volume = 0.5
  $qnaudio.play
end

def qnstop
  speech_stop
  if $qnaudio != nil
    $qnaudio.close
    $qnaudio = nil
  end
end

def msgnew(recipient = nil, subject = nil, message = nil, title = nil)
  return if $name == nil || $name == "" || $name == "guest"
  recipient = unicode(recipient) if recipient != nil
  subject = unicode(subject) if subject != nil
  message = unicode(message) if message != nil
  title ||= p_("Messages", "Send a new message")
  $showmessager.call(unicode(title + " - ELTEN"), unicode(p_("Messages", "Recipient")), unicode(p_("Messages", "Subject:")), unicode(p_("Messages", "Message:")), unicode(p_("Messages", "Send")), unicode(_("Cancel")), recipient, subject, message)
  $message_writing = true
  play "signal"
end

def msgcheck
  return if $message_writing == nil
  recipient = "\0" * 256
  subject = "\0" * 1024
  message = "\0" * 65536
  r = $getmessager.call(recipient, recipient.bytesize / 2, subject, subject.bytesize / 2, message, message.bytesize / 2)
  if r == 0
    $message_writing = nil
  elsif r == 1
    recipient = deunicode(recipient)
    subject = deunicode(subject)
    message = deunicode(message)
    recipient = recipient[0...recipient.index("\0") || recipient.size]
    subject = subject[0...subject.index("\0") || subject.size]
    message = message[0...message.index("\0") || message.size]
    buffer(message) { |id|
      if id.is_a?(String) || id.is_a?(Numeric)
        erequest("message_send", "name=#{$name}\&token=#{$token}\&to=#{CGI.escape(recipient)}\&subject=#{CGI.escape(subject)}\&buffer=#{id}") { |d|
          if d.is_a?(String) && d[0..0] == "0"
            play("messages_update")
          else
            msgnew(recipient, subject, message, p_("Messages", "Failed to send message"))
          end
        }
      else
        msgnew(recipient, subject, message, p_("Messages", "Failed to send message"))
      end
    }
    $hidemessager.call
  elsif r == 2
  end
rescue Exception
  log(2, "msgcheck: #{$!.to_s}")
end

def trymessage(dir, notSubj = false)
  return if notSubj && ($message_lastsubject == nil || $message_lastrecipient == nil)
  return if $name == nil || $token == nil || $message_id == 0
  ac = "next"
  ac = "prev" if dir == :prev
  id = $message_id
  if dir == :first
    id = 0
    ac = "next"
  elsif dir == :last
    id = 2 ** 32
    ac = "prev"
  end
  prm = "name=#{$name}\&token=#{$token}\&message=#{id}\&ac=#{ac}"
  prm += "\&notsubj=#{CGI.escape($message_lastsubject)}" + "\&notuser=#{CGI.escape($message_lastrecipient)}" if notSubj
  erequest("messages_quickread", prm) { |d|
    begin
      if d.is_a?(String)
        l = d.split("\r\n")
        if l[0].to_i == 0
          qnstop
          if l[1].to_i == 0
            play("border")
            speech($message_lasttext) if $message_lasttext.is_a?(String)
          else
            play("listbox_focus")
            id = l[1].to_i
            from = l[2]
            to = l[3]
            name = l[4]
            subject = l[5]
            message = ""
            i = 6
            while i < l.size
              break if l[i].delete("\r\n") == "\004END\004"
              message += l[i] + "\n"
              i += 1
            end
            $message_id = id
            $message_lastsubject = subject
            $message_lastrecipient = from
            $message_lastrecipient = to if from == $name || name != ""
            txt = from
            txt = p_("Messages", "To") + " " + to if from == $name && name == ""
            if name != ""
              txt += " " + p_("Messages", "To") + " " + name
            end
            txt += ": " + message
            txt.gsub!(/\004AUDIO\004([^\004]+)\004AUDIO\004/) {
              qnplay($1)
              ""
            }
            $message_lasttext = txt
            speech txt
          end
        end
      end
    rescue Exception
      log(2, "Try message: #{$!.to_s}")
    end
  }
end

def tryfeed(ac)
  return if $name == nil || $token == nil || $feeds == nil
  if $feeds.size == 0
    play("border")
    return
  end
  if $feed_id == 0 || $feed_id == nil
    $feed_id = $feeds.values.sort_by { |f| f.id }.last.id
  end
  feed = nil
  case ac
  when :prev
    feeds = $feeds.values.find_all { |f| f.id < $feed_id && f.message != "" }
    feed = feeds.sort_by { |f| f.id }[-1] if feeds.size > 0
  when :next
    feeds = $feeds.values.find_all { |f| f.id > $feed_id && f.message != "" }
    feed = feeds.sort_by { |f| f.id }[0] if feeds.size > 0
  when :first
    feed = $feeds.values.find_all { |f| f.message != "" }.sort_by { |f| f.id }[0]
  when :last
    feed = $feeds.values.find_all { |f| f.message != "" }.sort_by { |f| f.id }[-1]
  end
  if feed != nil
    $feed_id = feed.id
    ewrite({ "func" => "feedid", "feedid" => feed.id })
    $feed_lasttext = feed.user + ": " + feed.message
    play("listbox_focus")
    speak($feed_lasttext)
  else
    play("border")
    speak(feed_lasttext) if feed_lasttext != nil
  end
end

def feednew(message = nil, title = nil, response = 0)
  return if $name == nil || $name == "" || $name == "guest"
  message = unicode(message) if message != nil
  title ||= p_("Main", "Publish to a feed")
  $showwriter.call(unicode(title + " - ELTEN"), unicode(p_("Main", "Message")), unicode(p_("Messages", "Send")), unicode(_("Cancel")), message, 300)
  $feed_writing = response
  play "signal"
end

def feed_lasttext
  return $feed_lasttext if $feed_id == nil
  feed = $feeds.values.find { |f| f.id == $feed_id }
  return nil if feed == nil
  return feed.user + ": " + feed.message
end

def feedcheck
  return if $feed_writing == nil
  message = "\0" * 65536
  r = $getwriter.call(message, message.bytesize / 2)
  if r == 0
    $feed_writing = nil
  elsif r == 1
    message = deunicode(message)
    message = message[0...message.index("\0") || message.size]
    r = $feed_writing || 0
    buffer(message) { |id|
      if id.is_a?(String) || id.is_a?(Numeric)
        erequest("feeds", "name=#{$name}\&token=#{$token}\&ac=publish\&buffer=#{id}\&response=#{r}") { |d|
          if !d.is_a?(String) || d[0..0] != "0"
            feednew(message, p_("Messages", "Failed to send message"), $feed_writing)
          end
        }
      else
        feednew(message, p_("Messages", "Failed to send message"), $feed_writing)
      end
    }
    $hidewriter.call
  elsif r == 2
  end
rescue Exception
  log(2, "feedcheck: #{$!.to_s}")
end

def conferenceoptions
  opts = [
    [($conference.muted == true) ? (p_("Conference", "Unmute microphone")) : (p_("Conference", "Mute microphone")), Proc.new {
      $conference.muted = !$conference.muted
      if $conference.muted
        speak(p_("Conference", "Microphone muted"))
      else
        speak(p_("Conference", "Microphone unmuted"))
      end
    }],
    [p_("Conference", "Roll a 6-sided dice"), Proc.new {
      $conference.diceroll(6)
    }],
    [p_("Conference", "Roll a custom dice"), Proc.new {
      $conculastdiceroll ||= 6
      cat = CustomNavCat.new(p_("Conference", "Which dice do you want to roll?"))
      cat.available_proc = Proc.new { $conference != nil }
      (1..100).each do |c|
        dic = c
        str = p_("Conference", "%{count}-sided") % { count: dic.to_s }
        cat.add_option(str) {
          $conculastdiceroll = dic
          $conference.diceroll(dic)
        }
      end
      $nav_cats.push(cat)
      $nav_cat = cat
      cat.select_option($conculastdiceroll - 1)
    }]
  ]
  if !$conference.streaming?
    opts.push([p_("Conference", "Stream audio file"), Proc.new {
      openfile([["Audio", "*.wav", "*.ogg", "*.mp3", "*.opus", "*.aac", "*.m4a", "*.flac", "*.aiff"]], p_("Conference", "Select audio file")) { |f|
        $conference.set_stream(f)
      }
    }])
  else
    opts.push([p_("Conference", "Remove audio stream"), Proc.new {
      $conference.remove_stream
    }])
  end
  opts += [
    [($conference.pushtotalk == true) ? (p_("Conference", "Disable push to talk")) : (p_("Conference", "Enable push to talk")), Proc.new {
      $conference.pushtotalk = !$conference.pushtotalk
    }]
  ]
  opts.push([p_("Conference", "Show chat history"), Proc.new {
    cat = CustomNavCat.new(p_("Conference", "Chat"))
    cat.available_proc = Proc.new { $conference != nil }
    chat = $conference.chat.reverse
    for c in chat
      cat.add_option(c.username + ": " + c.message)
    end
    $nav_cats.push(cat)
    $nav_cat = cat
    cat.select_option(0)
  }])
  opts.push([p_("Conference", "Post in chat"), Proc.new { chatnew }])
  for t in $conference.transmitters
    opts.push([t[1].username, Proc.new() { |userid, transmitter|
      addconferenceusermenu(userid, transmitter)
    }, t[0], t[1]])
  end
  opts
end

def addconferenceusermenu(userid, transmitter)
  cat = CustomNavCat.new(transmitter.username)
  cat.available_proc = Proc.new { $conference != nil }
  cat.add_option(Proc.new {
    if $conference.whisper != userid
      p_("Conference", "Whisper")
    else
      p_("Conference", "End whispering")
    end
  }) {
    if $conference.whisper != userid
      $conference.whisper = userid
    else
      $conference.whisper = 0
    end
  }
  cat.add_option(Proc.new {
    if !$conference.is_muted_user(transmitter.username)
      p_("Conference", "Mute user")
    else
      p_("Conference", "Unmute user")
    end
  }) {
    if $conference.toggle_muted_user(transmitter.username)
      play("recording_stop")
    else
      play("recording_start")
    end
  }
  cat.add_option(p_("Conference", "Go to user")) { $conference.goto(userid) }
  $nav_cats.push(cat)
  $nav_cat = cat
  cat.select_option(0)
end

def tryconference(ac)
  $conference_index ||= 0
  opts = conferenceoptions.map { |o| o[0] }
  $conference_index = opts.size - 1 if $conference_index >= opts.size
  case ac
  when :prev
    if $conference_index > 0
      $conference_index -= 1
      play("listbox_focus")
      speak(opts[$conference_index])
    else
      play("border")
      speak(opts[$conference_index])
    end
  when :next
    if $conference_index < opts.size - 1
      $conference_index += 1
      play("listbox_focus")
      speak(opts[$conference_index])
    else
      play("border")
      speak(opts[$conference_index])
    end
  when :first
    $conference_index = 0
    play("listbox_focus")
    speak(opts[$conference_index])
  when :last
    $conference_index = opts.size - 1
    play("listbox_focus")
    speak(opts[$conference_index])
  when :say
    speak(opts[$conference_index])
  end
end

def selectconference
  $conference_index ||= 0
  conopts = conferenceoptions
  opts = conopts.map { |o| o[1] }
  return if opts.size < $conference_index
  opts[$conference_index].call(*conopts[$conference_index][2..-1])
end

def chatnew(message = nil, title = nil, response = 0)
  return if $name == nil || $name == "" || $name == "guest"
  message = unicode(message) if message != nil
  title ||= p_("Conference", "Chat message")
  $showwriter.call(unicode(title + " - ELTEN"), unicode(p_("Main", "Message")), unicode(p_("Messages", "Send")), unicode(_("Cancel")), message, 500)
  $chat_writing = true
  play "signal"
end

def chatcheck
  return if $chat_writing == nil
  message = "\0" * 65536
  r = $getwriter.call(message, message.bytesize / 2)
  if r == 0
    $chat_writing = nil
  elsif r == 1
    message = deunicode(message)
    message = message[0...message.index("\0") || message.size]
    if $conference != nil
      $conference.send_text(message)
    end
    $hidewriter.call
  elsif r == 2
  end
rescue Exception
  log(2, "chatcheck: #{$!.to_s}")
end

def nav(ac)
  set_navcat(0, true) if !isavailable_navcat
  if $nav_cat == "messages"
    case ac
    when :up
      trymessage(:next)
    when :down
      trymessage(:prev)
    when :pageup
      trymessage(:next, true)
    when :pagedown
      trymessage(:prev, true)
    when :last
      trymessage(:last)
    when :first
      trymessage(:first)
    when :say
      speak($message_lasttext) if $message_lasttext.is_a?(String)
    when :reply
      subj = $message_lastsubject
      subj = "RE: " + subj if subj.is_a?(String) && subj[0...4] != "RE: "
      msgnew($message_lastrecipient, subj, nil, p_("Messages", "Reply"))
    end
  elsif $nav_cat == "feed"
    case ac
    when :up
      tryfeed(:next)
    when :down
      tryfeed(:prev)
    when :last
      tryfeed(:last)
    when :first
      tryfeed(:first)
    when :say
      speak(feed_lasttext) if $feed_lasttext != nil
    when :like
      if $feed_id != nil
        feed = $feeds.values.find { |f| f.id == $feed_id }
        if feed != nil
          erequest("feeds", "name=#{$name}\&token=#{$token}\&ac=liking\&message=#{feed.id}\&like=#{(feed.liked) ? (0) : (1)}") { |d|
            if d.is_a?(String) && d[0..0] == "0"
              st = (feed.liked) ? (p_("FeedViewer", "Message disliked")) : (p_("FeedViewer", "Message liked"))
              feed.liked = !feed.liked
              speak(st)
            end
          }
        end
      end
    when :reply
      if $feed_id != nil
        feed = $feeds.values.find { |f| f.id == $feed_id }
        if feed != nil
          users = [feed.user]
          users += feed.message.scan(/\@([a-zA-Z0-9\.\-\_]+)/).map { |r| r[0] }
          todel = []
          for u in users
            todel.push(u) if u.downcase == ($name || "").downcase
          end
          for i in 1...users.size
            todel.push(users[i]) if users[0...i].map { |u| u.downcase }.include?(users[i].downcase)
          end
          todel.each { |u| users.delete(u) }
          u = users.map { |u| "@" + u }.join(" ") + " "
          r = feed.id
          r = feed.response if feed.response != 0
          feednew(u, p_("Main", "Reply"), r)
        end
      end
    end
  elsif $nav_cat == "conference"
    case ac
    when :up
      tryconference(:prev)
    when :down
      tryconference(:next)
    when :last
      tryconference(:first)
    when :first
      tryconference(:last)
    when :say
      tryconference(:say)
    when :select
      selectconference
    end
  elsif $nav_cat.is_a?(CustomNavCat)
    $nav_cat.call(ac)
  end
  case ac
  when :left
    set_navcat(-1)
  when :right
    set_navcat(1)
  when :message
    msgnew
  when :feed
    feednew
  when :stop
    qnstop
  end
end
