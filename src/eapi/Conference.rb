# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  class Conference
    class Channel
      attr_accessor :id, :name, :bitrate, :framesize, :public, :users, :passworded, :spatialization, :channels, :lang, :creator, :width, :height, :objects

      def initialize
        @name = ""
        @framesize = 60
        @bitrate = 64
        @public = true
        @users = []
        @id = 0
        @passworded = false
        @channels = 2
        @lang = ""
        @creator = nil
        @width = @height = 15
      end
    end

    class ChannelObject
      attr_reader :id, :resid, :name, :x, :y

      def initialize(id, resid, name, x = 0, y = 0)
        @id, @resid, @name, @x, @y = id, resid, name, x, y
      end
    end

    class ChannelUser
      attr_accessor :id, :name

      def initialize(id, name)
        @id = id
        @name = name
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
    @@created = nil
    @@hooks = []
    @@status = {}
    @@streaming = false
    @@cardset = false
    @@texts = []
    @@saving = false
    @@pushtotalk = false
    @@pushtotalk_keys = []
    def self.open(ignorePTT = false)
      @@opened = false
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
      $agent.write(Marshal.dump(params))
      t = Time.now.to_f
      while Time.now.to_f - t < 3
        loop_update
        break if @@opened == true
      end
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
      @@streaming = true
      $agent.write(Marshal.dump({ "func" => "conference_setstream", "file" => file }))
    end
    def self.remove_stream
      $agent.write(Marshal.dump({ "func" => "conference_removestream" }))
      @@streaming = false
    end
    def self.scrollstream(pos_plus)
      $agent.write(Marshal.dump({ "func" => "conference_scrollstream", "pos_plus" => pos_plus }))
    end
    def self.togglestream
      $agent.write(Marshal.dump({ "func" => "conference_togglestream" }))
      sleep(0.05)
    end
    def self.move(x_plus, y_plus)
      $agent.write(Marshal.dump({ "func" => "conference_move", "x_plus" => x_plus, "y_plus" => y_plus }))
      sleep(0.1)
    end
    def self.goto_user(userid)
      $agent.write(Marshal.dump({ "func" => "conference_gotouser", "userid" => userid }))
      sleep(0.1)
    end
    def self.goto(x, y)
      $agent.write(Marshal.dump({ "func" => "conference_goto", "x" => x, "y" => y }))
      sleep(0.1)
    end
    def self.whisper(userid)
      $agent.write(Marshal.dump({ "func" => "conference_whisper", "userid" => userid }))
    end
    def self.create(name = "", public = true, bitrate = 64, framesize = 60, password = nil, spatialization = 0, channels = 2, lang = "", width = 15, height = 15)
      if @@opened == false
        self.open
        delay(1)
      end
      @@created = nil
      $agent.write(Marshal.dump({ "func" => "conference_createchannel", "name" => name, "public" => public, "bitrate" => bitrate, "framesize" => framesize, "password" => password, "spatialization" => spatialization, "channels" => channels, "lang" => lang, "width" => width, "height" => height }))
      t = Time.now.to_f
      while Time.now.to_f - t < 8
        loop_update
        break if @@created != nil
      end
      return @@created
    end
    def self.update_channels
      if @@opened == false
        self.open
        delay(1)
      end
      @@channels = nil
      $agent.write(Marshal.dump({ "func" => "conference_listchannels" }))
      t = Time.now.to_f
      while Time.now.to_f - t < 1
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
      @@muted = (mt == true)
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
    def self.channels
      channels = []
      if @@channels.is_a?(Array)
        for cha in @@channels
          ch = Channel.new
          ch.id = cha["id"].to_i
          ch.name = cha["name"].to_s
          ch.framesize = cha["framesize"].to_f
          ch.bitrate = cha["bitrate"].to_i
          ch.passworded = true if cha["passworded"] == true
          ch.lang = cha["lang"]
          ch.channels = cha["channels"]
          ch.spatialization = cha["spatialization"]
          ch.creator = cha["creator"]
          for u in cha["users"]
            ch.users.push(ChannelUser.new(u["id"], u["name"]))
          end
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
    end
    def self.setchannel(c)
      params = JSON.load(c)
      if params.is_a?(Hash)
        ch = Channel.new
        ch.id = (params["id"] || 0).to_i
        ch.name = params["name"]
        ch.framesize = (params["framesize"] || 60).to_f
        ch.bitrate = (params["bitrate"] || 0).to_i
        ch.public = params["public"] != false
        ch.spatialization = params["spatialization"] || 0
        ch.channels = params["channels"] || 2
        ch.lang = params["lang"] || ""
        ch.creator = params["creator"]
        ch.users = []
        if params["users"].is_a?(Array)
          ch.users = params["users"].map { |u| ChannelUser.new(u["id"], u["name"]) }
        end
        ch.width = params["width"]
        ch.height = params["height"]
        ch.objects = params["objects"].map { |o| ChannelObject.new(o["id"], o["resid"], o["name"], o["x"], o["y"]) }
        @@channel = ch
        self.trigger(:update)
      end
    rescue Exception
      Log.error("Conference - Update Channel: #{$!.to_s}, #{$@.to_s}")
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
