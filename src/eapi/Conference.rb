# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  class Conference
    class Card
      attr_reader :id, :deck

      def initialize(id, deck)
        @id, @deck = id, deck
      end

      def cid
        f = @id[0..0]
        l = @id[1..1]
        if l.to_i < 5
          return ((l.to_i - 1) * 16) + (f.downcase[0] - "a"[0] + 1)
        else
          return 128 + ((l.to_i - 5) * 25) + (f.downcase[0] - "a"[0])
        end
      end

      def self.from_cid(deck, cid)
        return nil if cid == 0 || (cid % 16 == 0 && cid < 128)
        if cid < 128
          l = ((cid / 16) + 1).to_s
          x = cid % 16
          f = " "
          f[0] = "a"[0] - 1 + x
        elsif cid >= 128
          l = (cid - 128) / 25 + 5
          x = (cid - 128) % 25 + 1
          f = " "
          f[0] = "a"[0] - 1 + x
        end
        return self.new(f.to_s + l.to_s, deck)
      end

      def ==(o)
        return false if !o.is_a?(Card)
        return (@id == o.id && @deck == o.deck)
      end

      def colour_name
        case @id[1..1].to_i
        when 1
          return p_("Conference_cards", "hearts")
        when 2
          return p_("Conference_cards", "spades")
        when 3
          return p_("Conference_cards", "clubs")
        when 4
          return p_("Conference_cards", "diamonds")
        when 5
          return p_("Conference_cards", "red")
        when 6
          return p_("Conference_cards", "green")
        when 7
          return p_("Conference_cards", "blue")
        when 8
          return p_("Conference_cards", "yellow")
        else
          return ""
        end
      end

      def card_name
        f = @id.downcase[0] - "a"[0]
        if @id[1..1].to_i <= 4
          case f
          when 0
            return p_("Conference_cards", "two")
          when 1
            return p_("Conference_cards", "three")
          when 2
            return p_("Conference_cards", "four")
          when 3
            return p_("Conference_cards", "five")
          when 4
            return p_("Conference_cards", "six")
          when 5
            return p_("Conference_cards", "seven")
          when 6
            return p_("Conference_cards", "eight")
          when 7
            return p_("Conference_cards", "nine")
          when 8
            return p_("Conference_cards", "ten")
          when 9
            return p_("Conference_cards", "jack")
          when 10
            return p_("Conference_cards", "queen")
          when 11
            return p_("Conference_cards", "king")
          when 12
            return p_("Conference_cards", "ace")
          when 13
            return p_("Conference_cards", "joker")
          end
        elsif @id[1..1].to_i > 4
          if @id[1..1].to_i < 9
            if f == 0
              return "0"
            elsif f < 19
              return ((f + 1) / 2).to_s
            else
              case f
              when 19
                return p_("Conference_cards", "Skip")
              when 20
                return p_("Conference_cards", "Skip")
              when 21
                return p_("Conference_cards", "Draw two")
              when 22
                return p_("Conference_cards", "Draw two")
              when 23
                return p_("Conference_cards", "Reverse")
              when 24
                return p_("Conference_cards", "Reverse")
              end
            end
          elsif @id[1..1].to_i == 9
            case f
            when 0
              return p_("Conference_cards", "Wild")
            when 1
              return p_("Conference_cards", "Wild")
            when 2
              return p_("Conference_cards", "Wild")
            when 3
              return p_("Conference_cards", "Wild")
            when 4
              return p_("Conference_cards", "Wild draw four")
            when 5
              return p_("Conference_cards", "Wild draw four")
            when 6
              return p_("Conference_cards", "Wild draw four")
            when 7
              return p_("Conference_cards", "Wild draw four")
            end
          end
        end
        return ""
      end

      def fullname
        if @id[1..1].to_i < 5
          if @id[0..0] == "n"
            return card_name
          else
            return p_("Conference_cards", "%{card} of %{colour}") % { "card" => card_name, "colour" => colour_name }
          end
        else
          if @id[1..1].to_i == 9
            return card_name
          else
            return p_("Conference_cards", "%{colour} %{card}") % { "card" => card_name, "colour" => colour_name }
          end
        end
      end
    end

    class Channel
      attr_accessor :id, :name, :bitrate, :framesize, :vbr_type, :codec_application, :prediction_disabled, :fec, :public, :users, :passworded, :spatialization, :channels, :lang, :creator, :width, :height, :objects, :administrators, :key_len, :groupid, :waiting_type, :banned, :permanent, :password, :uuid, :motd, :allow_guests, :room_id

      def initialize
        @name = ""
        @framesize = 60
        @bitrate = 64
        @vbr_type = 1
        @codec_application = 0
        @prediction_disabled = false
        @fec = false
        @public = true
        @users = []
        @id = 0
        @passworded = false
        @channels = 2
        @spatialization = 0
        @lang = ""
        @creator = nil
        @width = @height = 15
        @administrators = []
        @key_len = 256
        @groupid = 0
        @waiting_type = 0
        @banned = []
        @permanent = false
      end
    end

    class ChannelObject
      attr_reader :id, :resid, :name, :x, :y

      def initialize(id, resid, name, x = 0, y = 0)
        @id, @resid, @name, @x, @y = id, resid, name, x, y
      end
    end

    class ChannelUser
      attr_accessor :id, :name, :waiting

      def initialize(id, name, waiting = false)
        @id = id
        @name = name
        @waiting = waiting
      end
    end

    class ChannelUserVolume
      attr_accessor :user, :volume, :muted

      def initialize(user, volume, muted)
        @user = user
        @volume = volume
        @muted = muted
      end
    end

    class ConferenceHook
      attr_reader :hook, :block

      def initialize(hook, block)
        @hook = hook
        @block = block
      end
    end

    @@opened = false
    @@volume = 0
    @@input_volume = 0
    @@muted = false
    @@stream_volume = 0
    @@channels = nil
    @@volumes = {}
    @@channel = Channel.new
    @@waiting_channel_id = 0
    @@created = nil
    @@hooks = []
    @@status = {}
    @@streaming = false
    @@cardset = false
    @@texts = []
    @@saving = false
    @@pushtotalk = false
    @@pushtotalk_keys = []
    @@x = 0
    @@y = 0
    @@dir = 0
    @@cardboard = []
    @@cards = nil
    @@decks = nil
    def self.open(ignorePTT = false, nick = nil)
      @@opened = false
      load_hrtf(false)
      params = { "func" => "conference_open" }
      volume = LocalConfig["ConferenceVolume", -1]
      input_volume = LocalConfig["ConferenceInputVolume", -1]
      stream_volume = LocalConfig["ConferenceStreamVolume", -1]
      pushtotalk = LocalConfig["ConferencePushToTalk", -1]
      pushtotalk_keys = LocalConfig["ConferencePushToTalkKeys", []]
      params["volume"] = volume if volume != -1
      params["stream_volume"] = stream_volume if stream_volume != -1
      params["input_volume"] = input_volume if input_volume != -1
      if ignorePTT != true
        params["pushtotalk"] = (pushtotalk == 1) if pushtotalk != -1
        params["pushtotalk_keys"] = pushtotalk_keys.map { |k| k.to_i }.join(",") if pushtotalk_keys != []
      end
      params["nick"] = nick
      $agent.write(Marshal.dump(params))
      t = Time.now.to_f
      while Time.now.to_f - t < 3
        loop_update
        break if @@opened == true
      end
      delay(0.5)
    end
    def self.close
      $agent.write(Marshal.dump({ "func" => "conference_close" }))
    end
    def self.join(id, password = nil)
      if @@opened == false
        self.open
        delay(1)
      else
        return if @@channel.id == id
      end
      $agent.write(Marshal.dump({ "func" => "conference_joinchannel", "channel" => id, "password" => password }))
    end
    def self.leave
      if @@opened == false
        self.open
        delay(1)
      end
      $agent.write(Marshal.dump({ "func" => "conference_leavechannel" }))
    end
    def self.status
      @@status || {}
    end
    def self.pushtotalk
      @@pushtotalk
    end
    def self.pushtotalk=(k)
      $agent.write(Marshal.dump({ "func" => "conference_pushtotalk", "pushtotalk" => (k == true) }))
      @@pushtotalk = (k == true)
    end
    def self.pushtotalk_keys
      @@pushtotalk_keys
    end
    def self.pushtotalk_keys=(k)
      $agent.write(Marshal.dump({ "func" => "conference_pushtotalk", "pushtotalk_keys" => k.map { |b| b.to_s }.join(",") }))
      @@pushtotalk_keys = k
    end
    def self.streaming?
      @@streaming
    end
    def self.cardset?
      @@cardset
    end
    def self.send_text(text)
      $agent.write(Marshal.dump({ "func" => "conference_sendtext", "text" => text }))
    end
    def self.diceroll(cnt = 6)
      $agent.write(Marshal.dump({ "func" => "conference_diceroll", "count" => cnt }))
    end
    def self.cardboard
      @@cardboard
    end
    def self.cards
      @@cards = nil
      $agent.write(Marshal.dump({ "func" => "conference_cards" }))
      t = Time.now.to_f
      loop_update while @@cards == nil && Time.now.to_f - t < 1
      return nil if @@cards == nil
      @@cards.map { |c| Card.from_cid(c["deck"], c["cid"]) }
    end
    def self.cardboard_pick(deck, cid = 0)
      $agent.write(Marshal.dump({ "func" => "conference_pickcard", "deck" => deck, "cid" => cid }))
    end
    def self.cardboard_change(deck, cid)
      $agent.write(Marshal.dump({ "func" => "conference_changecard", "deck" => deck, "cid" => cid }))
    end
    def self.cardboard_place(deck, cid)
      $agent.write(Marshal.dump({ "func" => "conference_placecard", "deck" => deck, "cid" => cid }))
    end
    def self.decks
      @@decks = nil
      $agent.write(Marshal.dump({ "func" => "conference_decks" }))
      t = Time.now.to_f
      loop_update while @@decks == nil && Time.now.to_f - t < 1
      @@decks
    end
    def self.deck_add(type)
      $agent.write(Marshal.dump({ "func" => "conference_adddeck", "type" => type }))
    end
    def self.deck_reset(deck)
      $agent.write(Marshal.dump({ "func" => "conference_resetdeck", "deck" => deck }))
    end
    def self.deck_remove(deck)
      $agent.write(Marshal.dump({ "func" => "conference_removedeck", "deck" => deck }))
    end
    def self.saving?
      @@saving == true
    end
    def self.begin_save(file)
      $agent.write(Marshal.dump({ "func" => "conference_beginsave", "file" => file }))
      @@saving = true
    end
    def self.begin_fullsave(dir)
      $agent.write(Marshal.dump({ "func" => "conference_beginfullsave", "dir" => dir }))
      @@saving = true
    end
    def self.end_save
      $agent.write(Marshal.dump({ "func" => "conference_endsave" }))
      @@saving = false
    end
    def self.set_device(dev)
      $agent.write(Marshal.dump({ "func" => "conference_setdevice", "device" => dev }))
    end
    def self.add_card(card, listen = false)
      @@cardset = true
      $agent.write(Marshal.dump({ "func" => "conference_addcard", "card" => card, "listen" => listen }))
    end
    def self.remove_card
      $agent.write(Marshal.dump({ "func" => "conference_removecard" }))
      @@cardset = false
    end
    def self.object_remove(id)
      $agent.write(Marshal.dump({ "func" => "conference_removeobject", "id" => id }))
    end
    def self.object_add(resid, name, location)
      $agent.write(Marshal.dump({ "func" => "conference_addobject", "resid" => resid, "name" => name, "location" => location }))
    end
    def self.set_stream(file)
      $agent.write(Marshal.dump({ "func" => "conference_setstream", "file" => file }))
    end
    def self.remove_stream
      $agent.write(Marshal.dump({ "func" => "conference_removestream" }))
    end
    def self.scrollstream(pos_plus)
      $agent.write(Marshal.dump({ "func" => "conference_scrollstream", "pos_plus" => pos_plus }))
    end
    def self.togglestream
      $agent.write(Marshal.dump({ "func" => "conference_togglestream" }))
      delay(0.05)
    end
    def self.move(x_plus, y_plus)
      $agent.write(Marshal.dump({ "func" => "conference_move", "x_plus" => x_plus, "y_plus" => y_plus }))
      delay(0.1)
    end
    def self.turn(dir_plus)
      $agent.write(Marshal.dump({ "func" => "conference_turn", "dir_plus" => dir_plus }))
      delay(0.1)
    end
    def self.goto_user(userid)
      $agent.write(Marshal.dump({ "func" => "conference_gotouser", "userid" => userid }))
      delay(0.1)
    end
    def self.kick(userid)
      $agent.write(Marshal.dump({ "func" => "conference_kick", "userid" => userid }))
      delay(0.1)
    end
    def self.accept(userid)
      $agent.write(Marshal.dump({ "func" => "conference_accept", "userid" => userid }))
      delay(0.1)
    end
    def self.ban(username)
      $agent.write(Marshal.dump({ "func" => "conference_ban", "username" => username }))
      delay(1.5)
    end
    def self.unban(username)
      $agent.write(Marshal.dump({ "func" => "conference_unban", "username" => username }))
      delay(1.5)
    end
    def self.admin(username)
      $agent.write(Marshal.dump({ "func" => "conference_admin", "username" => username }))
      delay(1.5)
    end
    def self.goto(x, y)
      $agent.write(Marshal.dump({ "func" => "conference_goto", "x" => x, "y" => y }))
      delay(0.1)
    end
    def self.whisper(userid)
      $agent.write(Marshal.dump({ "func" => "conference_whisper", "userid" => userid }))
    end
    def self.create(name = "", public = true, bitrate = 64, framesize = 60, vbr_type = 1, codec_application = 0, prediction_disabled = false, fec = false, password = nil, spatialization = 0, channels = 2, lang = "", width = 15, height = 15, key_len = 256, waiting_type = 0, permanent = false, motd = "", allow_guests = false)
      if @@opened == false
        self.open
        delay(1)
      end
      @@created = nil
      $agent.write(Marshal.dump({ "func" => "conference_createchannel", "name" => name, "public" => public, "bitrate" => bitrate, "framesize" => framesize, "vbr_type" => vbr_type, "codec_application" => codec_application, "prediction_disabled" => prediction_disabled, "fec" => fec, "password" => password, "spatialization" => spatialization, "channels" => channels, "lang" => lang, "width" => width, "height" => height, "key_len" => key_len, "waiting_type" => waiting_type, "permanent" => permanent, "motd" => motd, "allow_guests" => allow_guests }))
      t = Time.now.to_f
      while Time.now.to_f - t < 8
        loop_update
        break if @@created != nil
      end
      return @@created
    end
    def self.edit(id, name, public, bitrate, framesize, vbr_type, codec_application, prediction_disabled, fec, password, spatialization, channels, lang, width, height, key_len, waiting_type, permanent, motd, allow_guests)
      if @@opened == false
        self.open
        delay(1)
      end
      $agent.write(Marshal.dump({ "func" => "conference_editchannel", "channel" => id, "name" => name, "public" => public, "bitrate" => bitrate, "framesize" => framesize, "vbr_type" => vbr_type, "codec_application" => codec_application, "prediction_disabled" => prediction_disabled, "fec" => fec, "password" => password, "spatialization" => spatialization, "channels" => channels, "lang" => lang, "width" => width, "height" => height, "key_len" => key_len, "waiting_type" => waiting_type, "permanent" => permanent, "motd" => motd, "allow_guests" => allow_guests }))
      delay(1)
    end
    def self.update_channels
      if @@opened == false
        self.open
        delay(1)
      end
      @@channels = nil
      $agent.write(Marshal.dump({ "func" => "conference_listchannels" }))
      t = Time.now.to_f
      while Time.now.to_f - t < 2
        loop_update
        break if @@channels != nil
      end
    end
    def self.muted
      @@muted
    end
    def self.muted=(mt)
      if @@opened == false
        self.open
        delay(1)
      end
      $agent.write(Marshal.dump({ "func" => "conference_setmuted", "muted" => mt == true }))
      delay(0.2)
    end
    def self.input_volume
      @@input_volume
    end
    def self.input_volume=(vol)
      if @@opened == false
        self.open
        delay(1)
      end
      vol = 0 if vol < 0
      $agent.write(Marshal.dump({ "func" => "conference_setinputvolume", "volume" => vol }))
      LocalConfig["ConferenceInputVolume"] = vol
      @@input_volume = vol
    end
    def self.output_volume
      @@volume
    end
    def self.output_volume=(vol)
      if @@opened == false
        self.open
        delay(1)
      end
      vol = 0 if vol < 0
      vol = 100 if vol > 100
      $agent.write(Marshal.dump({ "func" => "conference_setoutputvolume", "volume" => vol }))
      LocalConfig["ConferenceVolume"] = vol
      @@volume = vol
    end
    def self.stream_volume
      @@stream_volume
    end
    def self.stream_volume=(vol)
      if @@opened == false
        self.open
        delay(1)
      end
      vol = 0 if vol < 0
      vol = 100 if vol > 100
      $agent.write(Marshal.dump({ "func" => "conference_setstreamvolume", "volume" => vol }))
      LocalConfig["ConferenceStreamVolume"] = vol
      @@stream_volume = vol
    end
    def self.volume(user)
      v = self.volumes[user]
      v ||= ChannelUserVolume.new(user, 100, false)
      v
    end
    def self.volumes
      return {} if @@volumes == nil
      vls = {}
      for u in @@volumes.keys
        vls[u] = ChannelUserVolume.new(u, @@volumes[u][0], @@volumes[u][1])
      end
      return vls
    end
    def self.setvolume(user, volume, muted)
      if @@opened == false
        self.open
        delay(1)
      end
      $agent.write(Marshal.dump({ "func" => "conference_setvolume", "user" => user, "volume" => volume, "muted" => muted }))
    end
    def self.texts
      return @@texts
    end
    def self.waiting_channel_id
      @@waiting_channel_id
    end
    def self.channels
      channels = []
      if @@channels.is_a?(Array)
        for cha in @@channels
          ch = Channel.new
          ch.id = cha["id"].to_i
          ch.name = cha["name"].to_s
          ch.framesize = cha["framesize"].to_f
          ch.bitrate = cha["bitrate"].to_i
          ch.vbr_type = cha["vbr_type"].to_i
          ch.codec_application = cha["codec_application"].to_i
          ch.prediction_disabled = cha["prediction_disabled"] == true
          ch.fec = cha["fec"] == true
          ch.passworded = true if cha["passworded"] == true
          ch.password = cha["password"]
          ch.lang = cha["lang"]
          ch.channels = cha["channels"]
          ch.spatialization = cha["spatialization"]
          ch.creator = cha["creator"]
          ch.groupid = cha["groupid"].to_i
          for u in cha["users"]
            ch.users.push(ChannelUser.new(u["id"], u["name"]))
          end
          ch.administrators = cha["administrators"] || []
          ch.banned = cha["banned"] || []
          ch.key_len = cha["key_len"]
          ch.waiting_type = cha["waiting_type"] || 0
          ch.width = cha["width"].to_i
          ch.height = cha["height"].to_i
          ch.permanent = (cha["permanent"] == true)
          ch.uuid = cha["uuid"]
          ch.motd = cha["motd"]
          ch.room_id = cha["room_id"]
          ch.allow_guests = cha["allow_guests"]
          channels.push(ch)
        end
      end
      return channels
    end
    def self.opened?
      return @@opened
    end
    def self.channel
      return @@channel
    end
    def self.get_coordinates(userid = nil)
      @@x = 0
      @@y = 0
      @@dir = 0
      return [0, 0, 0] if !self.opened?
      $agent.write(Marshal.dump({ "func" => "conference_getcoordinates", "userid" => userid }))
      t = Time.now.to_f
      loop_update while (@@x == 0 && @@y == 0) && Time.now.to_f - t < 1
      return [@@x, @@y, @@dir]
    end
    def self.calling_play
      $agent.write(Marshal.dump({ "func" => "conference_callingplay" }))
    end
    def self.calling_stop
      $agent.write(Marshal.dump({ "func" => "conference_callingstop" }))
    end
    def self.setopened(data)
      self.setclosed
      @@input_volume = data["input_volume"]
      @@stream_volume = data["stream_volume"]
      @@volume = data["volume"]
      @@pushtotalk = data["pushtotalk"]
      @@pushtotalk_keys = data["pushtotalk_keys"].split(",").map { |k| k.to_i }
      @@opened = true
    end
    def self.setclosed
      trigger(:close)
      @@opened = false
      @@channels = nil
      @@volumes = {}
      @@channel = Channel.new
      @@created = nil
      @@volume = 0
      @@stream_volume = 0
      @@input_volume = 0
      @@streaming = false
      @@cardset = false
      @@texts = []
      @@muted = false
      @@saving = false
      @@pushtotalk = false
      @@pushtotalk_keys = []
      @@x = 0
      @@y = 0
      @@dir = 0
      @@cardboard = []
      @@waiting_channel_id = 0
    end
    def self.setchannel(c)
      params = JSON.load(c)
      if params.is_a?(Hash)
        ch = Channel.new
        ch.id = (params["id"] || 0).to_i
        ch.name = params["name"]
        ch.framesize = (params["framesize"] || 60).to_f
        ch.bitrate = (params["bitrate"] || 0).to_i
        ch.vbr_type = params["vbr_type"].to_i
        ch.codec_application = params["codec_application"].to_i
        ch.prediction_disabled = params["prediction_disabled"] == true
        ch.fec = params["fec"] == true
        ch.public = params["public"] != false
        ch.spatialization = params["spatialization"] || 0
        load_hrtf if ch.spatialization == 1
        ch.password = params["password"]
        ch.channels = params["channels"] || 2
        ch.lang = params["lang"] || ""
        ch.creator = params["creator"]
        ch.groupid = params["groupid"].to_i
        ch.users = []
        if params["users"].is_a?(Array)
          ch.users = params["users"].map { |u| ChannelUser.new(u["id"], u["name"]) }
        end
        if params["waiting_users"].is_a?(Array)
          ch.users += params["waiting_users"].map { |u| ChannelUser.new(u["id"], u["name"], true) }
        end
        ch.width = params["width"]
        ch.height = params["height"]
        ch.objects = params["objects"].map { |o| ChannelObject.new(o["id"], o["resid"], o["name"], o["x"], o["y"]) }
        ch.administrators = params["administrators"] || []
        ch.banned = params["banned"] || []
        ch.key_len = params["key_len"]
        ch.waiting_type = params["waiting_type"] || 0
        ch.permanent = (params["permanent"] == true)
        ch.uuid = params["uuid"]
        ch.motd = params["motd"]
        ch.room_id = params["room_id"]
        ch.allow_guests = params["allow_guests"]
        @@channel = ch
        self.trigger(:update)
      end
    rescue Exception
      Log.error("Conference - Update Channel: #{$!.to_s}, #{$@.to_s}")
    end
    def self.setwaitingchannel(chid)
      @@waiting_channel_id = chid
      self.trigger(:waitingchannel)
    end
    def self.setcreated(id)
      @@created = id
    end
    def self.setchannels(chs)
      @@channels = JSON.load(chs)
    rescue Exception
      Log.error("Conference - Update Channels list: #{$!.to_s}, #{$@.to_s}")
    end
    def self.setstatus(st)
      @@status = JSON.load(st)
      self.trigger(:status)
    rescue Exception
      Log.error("Conference - Update Status: #{$!.to_s}, #{$@.to_s}")
    end
    def self.setvolumes(vls)
      @@volumes = JSON.load(vls)
    rescue Exception
      Log.error("Conference - Update Volumes: #{$!.to_s}, #{$@.to_s}")
    end
    def self.settext(username, userid, text)
      @@texts.push([username, userid, text])
      trigger(:text)
    end
    def self.setdiceroll(username, userid, value, count)
      @@texts.push([username, userid, :diceroll, [value, count]])
      trigger(:text)
    end
    def self.setcards(cards)
      @@cards = JSON.load(cards)
    rescue Exception
    end
    def self.setdecks(decks)
      @@decks = JSON.load(decks)
    rescue Exception
    end
    def self.setcardboard(username, userid, type, deck, cid)
      @@cardboard.push([username, userid, type, deck, cid])
      trigger(:cardboard)
    end
    def self.setcoordinates(x, y, dir)
      @@x, @@y, @@dir = x.to_i, y.to_i, dir.to_i
    end
    def self.setchange(param, value)
      case param
      when "muted"
        @@muted = value
      when "streaming"
        @@streaming = value
      when "pushtotalk"
        @@pushtotalk = value
      end
    end
    def self.on(hook, &block)
      if block != nil
        hk = ConferenceHook.new(hook, block)
        @@hooks.push(hk)
        return hk
      end
    end
    def self.remove_hook(hk)
      @@hooks.delete(hk)
    end
    def self.trigger(hook)
      for hk in @@hooks
        hk.block.call if hk.hook == hook
      end
    end
  end
end
