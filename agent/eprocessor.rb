module EProcessor
  class << self
    def srvverify
      t = SecureRandom.alphanumeric(32)
      r = { "time" => Time.now.to_f, "text" => t, "seed" => SecureRandom.alphanumeric(32) }
      enc = $rsa.public_encrypt(JSON.generate(r))
      erequest("verifier", "ac=verify", enc, {}, t) { |resp, d|
        if resp.is_a?(String)
          suc = false
          begin
            dec = $rsa.public_decrypt(resp)
            j = JSON.load(dec)
            suc = true if (j["time"].to_f - Time.now.to_f).abs <= 86400 && t.reverse == j["text"]
          rescue Exception
            log(1, $!.to_s + ": " + $@.to_s)
            log(1, resp)
          end
          ewrite({ "func" => "srvverify", "succeeded" => suc })
        end
      }
    end

    def readurl(data)
      uri = URI.parse(data["url"])
      s = TCPSocket.new(uri.host, uri.port)
      if uri.scheme == "https"
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.alpn_protocols = [DRAFT]
        sock = OpenSSL::SSL::SSLSocket.new(s, ctx)
        sock.sync_close = true
        sock.hostname = uri.host
        sock.connect
      else
        sock = s
      end
      http = HTTP2::Client.new
      http.on(:frame) { |bytes|
        sock.print bytes
        sock.flush
      }
      sockthread = Thread.new {
        while !sock.closed? && !sock.eof?
          dt = sock.read_nonblock(1024)
          http << dt
        end
      }
      stream = http.new_stream
      head = {
        ":scheme" => uri.scheme,
        ":authority" => "#{uri.host}:#{uri.port}",
        ":path" => uri.path,
        "User-Agent" => "Elten #{$version} agent",
        "Connection" => "close"
      }
      head[":method"] = data["method"] || "GET"
      head["content-length"] = data["body"].bytesize if data["body"] != nil
      data["headers"].keys.each { |k| head[k] = data["headers"][k] } if data["headers"].is_a?(Hash)
      stream.headers(head, end_stream: (data["body"] == nil || data["body"] == ""))
      if data["body"] != nil && data["body"] != ""
        until data["body"].empty?
          ch = data["body"].slice!(0...4096)
          stream.data(ch, end_stream: (data["body"].empty?))
        end
      end
      headers = {}
      body = ""
      stream.on(:headers) { |hd| headers = hd.map { |h| h[0] + ": " + h[1] }.join("\n") }
      stream.on(:data) { |ch| body += ch }
      stream.on(:half_close) { stream.close }
      stream.on(:close) {
        http.goaway
        sock.close
        d = { "func" => "readurl" }
        d["id"] = data["id"]
        d["body"] = body
        d["headers"] = headers
        ewrite(d)
      }
    end

    def conference_open(data)
      begin
        $conference.free if $conference != nil
      rescue Exception
      end
      $conference = Conference.new(data["nick"])
      $conference.volume = data["volume"] if data["volume"].is_a?(Integer)
      $conference.input_volume = data["input_volume"] if data["input_volume"].is_a?(Integer)
      $conference.stream_volume = data["stream_volume"] if data["stream_volume"].is_a?(Integer)
      $conference.pushtotalk = data["pushtotalk"] if data["pushtotalk"] != nil
      $conference.pushtotalk_keys = data["pushtotalk_keys"].split(",").map { |k| k.to_i } if data["pushtotalk_keys"].is_a?(String)
      $conference.on_channel { |ch|
        Thread.new {
          dt = { "func" => "conference_channel", "channel" => JSON.generate(ch) }
          ewrite(dt)
        }
      }
      $conference.on_waitingchannel { |chid|
        Thread.new {
          dt = { "func" => "conference_waitingchannel", "chid" => chid }
          ewrite(dt)
        }
      }
      $conference.on_status { |st|
        Thread.new {
          ewrite({ "func" => "conference_status", "status" => JSON.generate(st) })
        }
      }
      $conference.on_volumes { |vl|
        Thread.new {
          dt = { "func" => "conference_volumes", "volumes" => JSON.generate(vl) }
          ewrite(dt)
        }
      }
      $conference.on_streammute { |id, mute|
        Thread.new {
          dt = { "func" => "conference_streammute", "id" => id, "mute" => mute }
          ewrite(dt)
        }
      }
      $conference.on_user { |joined, username|
        Thread.new {
          if joined
            play("conference_userjoin")
          else
            play("conference_userleave")
          end
          speak(username)
          while speech_actived
            speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
            sleep 0.01
          end
        }
      }
      $conference.on_waitinguser { |joined, username|
        Thread.new {
          if joined
            play("conference_userknock")
          else
            play("conference_userleave")
          end
          speak(username)
          while speech_actived
            speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
            sleep 0.01
          end
        }
      }
      $conference.on_speaker { |status, username, userid|
        Thread.new {
          if status == 2
            play("conference_speechrequest")
            speak(username)
          elsif status == 1
            play("conference_speechallow")
            speak(p_("Conference", "Speech allowed"))
          elsif status == 0
            play("conference_speechdeny")
            speak(p_("Conference", "Speech denied"))
          end
          while speech_actived
            speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
            sleep 0.01
          end
        }
      }
      $conference.on_text { |username, userid, message|
        Thread.new {
          speak(username + ": " + message)
          ewrite({ "func" => "conference_text", "username" => username, "userid" => userid, "text" => message })
          play "conference_message"
          while speech_actived
            speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
            sleep 0.01
          end
        }
      }
      $conference.on_diceroll { |username, userid, value, count|
        Thread.new {
          speak(username + ": " + value.to_s)
          ewrite({ "func" => "conference_diceroll", "username" => username, "userid" => userid, "value" => value, "count" => count })
          play "conference_diceroll"
          while speech_actived
            speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
            sleep 0.01
          end
        }
      }
      $conference.on_card { |username, userid, type, deck, cid|
        fullname = ""
        if cid != nil && cid != 0
          if cid < 128
            l = ((cid / 16) + 1).to_s
            x = cid % 16
            f = " "
            f.setbyte(0, "a".getbyte(0) - 1 + x)
          else
            l = (cid - 128) / 25 + 5
            x = (cid - 128) % 25 + 1
            f = " "
            f.setbyte(0, "a".getbyte(0) - 1 + x)
          end
          colourname = ""
          cardname = ""
          case l.to_i
          when 1
            colourname = p_("Conference_cards", "hearts")
          when 2
            colourname = p_("Conference_cards", "spades")
          when 3
            colourname = p_("Conference_cards", "clubs")
          when 4
            colourname = p_("Conference_cards", "diamonds")
          when 5
            colourname = p_("Conference_cards", "red")
          when 6
            colourname = p_("Conference_cards", "green")
          when 7
            colourname = p_("Conference_cards", "blue")
          when 8
            colourname = p_("Conference_cards", "yellow")
          else
            colourname = ""
          end
          if cid < 128
            case f.getbyte(0) - "a".getbyte(0)
            when 0
              cardname = p_("Conference_cards", "two")
            when 1
              cardname = p_("Conference_cards", "three")
            when 2
              cardname = p_("Conference_cards", "four")
            when 3
              cardname = p_("Conference_cards", "five")
            when 4
              cardname = p_("Conference_cards", "six")
            when 5
              cardname = p_("Conference_cards", "seven")
            when 6
              cardname = p_("Conference_cards", "eight")
            when 7
              cardname = p_("Conference_cards", "nine")
            when 8
              cardname = p_("Conference_cards", "ten")
            when 9
              cardname = p_("Conference_cards", "jack")
            when 10
              cardname = p_("Conference_cards", "queen")
            when 11
              cardname = p_("Conference_cards", "king")
            when 12
              cardname = p_("Conference_cards", "ace")
            when 13
              cardname = p_("Conference_cards", "joker")
            end
          elsif cid >= 128
            if l < 9
              if f == "a"
                cardname = "0"
              elsif f.getbyte(0) - "a".getbyte(0) < 19
                cardname = ((f.getbyte(0) - "a".getbyte(0) + 1) / 2).to_s
              else
                case f.getbyte(0) - "a".getbyte(0)
                when 19
                  cardname = p_("Conference_cards", "Skip")
                when 20
                  cardname = p_("Conference_cards", "Skip")
                when 21
                  cardname = p_("Conference_cards", "Draw two")
                when 22
                  cardname = p_("Conference_cards", "Draw two")
                when 23
                  cardname = p_("Conference_cards", "Reverse")
                when 24
                  cardname = p_("Conference_cards", "Reverse")
                end
              end
            elsif l == 9
              if (f.getbyte(0) - "a".getbyte(0)) / 4 == 0
                cardname = p_("Conference_cards", "Wild")
              elsif (f.getbyte(0) - "a".getbyte(0)) / 4 == 1
                cardname = p_("Conference_cards", "Wild draw four")
              end
            end
          end
        end
        if f != nil
          if l.to_i < 5
            if f.downcase == "n"
              fullname = cardname
            else
              fullname = p_("Conference_cards", "%{card} of %{colour}") % { card: cardname, colour: colourname }
            end
          elsif l.to_i >= 5
            if l.to_i == 9
              fullname = cardname
            else
              fullname = p_("Conference_cards", "%{colour} %{card}") % { card: cardname, colour: colourname }
            end
          end
        end
        Thread.new {
          ewrite({ "func" => "conference_card", "username" => username, "userid" => userid, "type" => type, "deck" => deck, "cid" => cid })
          case type
          when "pick"
            play "conference_cardpick"
          when "change"
            play "conference_cardchange"
          when "place"
            play "conference_cardplace"
          when "shuffle"
            play "conference_cardshuffle"
          end
          s = username + " "
          if cid != 0 && cid != nil
            s += fullname
          end
          speak(s)
          while speech_actived
            speech_stop if $getasynckeystate.call(0x11) != 0 and $voice >= 0 and Time.now.to_f - ($speech_lasttime || 0) > 0.1
            sleep 0.01
          end
        }
      }
      $conference.on_change { |param, value|
        Thread.new {
          dt = { "func" => "conference_change", "param" => param, "value" => value }
          ewrite(dt)
        }
      }
      $conference.on_mystreams { |params|
        Thread.new {
          dt = { "func" => "conference_mystreams", "streams" => JSON.generate(params) }
          ewrite(dt)
        }
      }
      $conference.on_streams { |streams|
        Thread.new {
          begin
            dt = { "func" => "conference_streams", "streams" => JSON.generate(streams.values.map { |s| { "id" => s.streamid, "name" => s.name, "userid" => s.userid, "username" => s.username, "x" => s.stream_x, "y" => s.stream_y, "volume" => s.volume } }) }
            ewrite(dt)
          rescue Exception
            log(1, $!.to_s)
          end
        }
      }
      ewrite({ "func" => "conference_open", "userid" => $conference.userid, "volume" => $conference.volume, "input_volume" => $conference.input_volume, "stream_volume" => $conference.stream_volume, "muted" => $conference.muted, "pushtotalk" => $conference.pushtotalk, "pushtotalk_keys" => $conference.pushtotalk_keys.map { |k| k.to_s }.join(",") })
    end

    def conference_getsource(stream, source, mayStream = false)
      source = 0 if mayStream == false && source == nil
      if !stream.is_a?(Numeric)
        s = $conference.sources.find { |s| s.is_a?(Conference::StreamSourceFile) }
        return s if s != nil
        for st in $conference.outstreams
          s = st.sources.find { |s| s.is_a?(Conference::StreamSourceFile) }
          return s if s != nil
        end
        return nil
      elsif source == nil
        return $conference.outstreams[stream]
      elsif stream == -1
        return $conference.sources[source]
      else
        st = $conference.outstreams[stream]
        if st != nil
          return st.sources[source]
        end
      end
    end

    def process(data)
      case data["func"]
      when "srvproc"
        data["reqtime"] = Time.now.to_f
        erequest(data["mod"], data["param"], data["post"], data["headers"], data) { |resp, d|
          if resp.is_a?(ERUploadProgress)
            ewrite({ "func" => "srvproc_uploadprogress", "id" => d["id"], "percent" => resp.percent })
          elsif resp == :error
            log(2, "Request error: #{d["func"]}")
            d["resptime"] = Time.now.to_f
            d["resp"] = "-4"
          elsif resp.is_a?(String)
            d["resp"] = (resp || "").force_encoding("UTF-8")
            d["resptime"] = Time.now.to_f
            ewrite(d)
          end
        }
      when "downloadfile"
        data["reqtime"] = Time.now.to_f
        downloadfile(data["source"], data["destination"], data) { |resp, d|
          if resp.is_a?(ERDownloadProgress)
            ewrite({ "func" => "downloadfile_downloadprogress", "id" => d["id"], "percent" => resp.percent })
          elsif resp == :error
            log(2, "DownloadFile error: #{d["func"]}")
          elsif resp.is_a?(Integer)
            d["size"] = resp
            d["resptime"] = Time.now.to_f
            ewrite(d)
          end
        }
      when "jproc"
        data["reqtime"] = Time.now.to_f
        ejrequest(data["method"], data["path"], data["params"], data) { |resp, d|
          if resp == :error
            log(2, "Request error: #{d["func"]}")
            d["resptime"] = Time.now.to_f
            d["resp"] = nil
          else
            d["resp"] = resp
            d["resptime"] = Time.now.to_f
            ewrite(d)
            play "signal"
          end
        }
      when "srvverify"
        srvverify
      when "readurl"
        readurl(data)
      when "superpid"
        $superpid = data["superpid"] if data["superpid"].is_a?(Integer)
      when "eltsock_create"
        d = data.dup
        $eltsocks ||= []
        $eltsocks.push(EltenSock.new)
        d["sockid"] = $eltsocks.size - 1
        ewrite(d)
      when "eltsock_write"
        d = data.dup
        $eltsocks ||= {}
        if $eltsocks[data["sockid"]] != nil
          $eltsocks[data["sockid"]].write(data["message"])
          d["status"] = 1
          ewrite(d)
        end
      when "eltsock_read"
        d = data.dup
        $eltsocks ||= {}
        if $eltsocks[data["sockid"]] != nil
          d["message"] = $eltsocks[data["sockid"]].read(data["size"])
          ewrite(d)
        end
      when "eltsock_close"
        d = data.dup
        $eltsocks ||= {}
        if $eltsocks[data["sockid"]] != nil
          $eltsocks[data["sockid"]].close
          $eltsocks[data["sockid"]] = nil
          d["status"] = 1
          ewrite(d)
        end
      when "activity_register"
        begin
          erequest("activities", "name=#{$name}\&token=#{$token}\&ac=register\&form=structured", JSON.generate({ "config" => data["config"], "activity" => data["activity"] }), { "Content-Type" => "application/json" }) { |resp|
            log(-1, "Activity registration: #{resp.to_s}") if resp.is_a?(String)
          }
        rescue Exception
        end
      when "donotdisturb_on"
        $donotdisturb = true
      when "donotdisturb_off"
        $donotdisturb = false
      when "alarm_stop"
        $alarmstop = true
      when "relogin"
        $message_id = 0
        $ag_feed = 0
        $ag_feedtime = 0
        $feeds = {}
        $feedstime = 0
        $lastfeeds = nil
        if $conference != nil
          begin
            $conference.free
            $conference = nil
          rescue Exception
          end
          ewrite({ "func" => "conference_close" })
        end
        $name = data["name"]
        $token = data["token"]
        $hwnd = data["hwnd"] if data["hwnd"] != nil
      when "msg_suppress"
        $msg_suppress = true
      when "steamaudio_load"
        log(-1, "Loading SteamAudio library from: " + data["file"])
        log(2, "Failed to load SteamAudio from: " + data["file"]) if SteamAudio.load(data["file"]) == false
        Audio3D.load if SteamAudio.loaded?
      when "conference_turn"
        dir_plus = data["dir_plus"] || 0
        if $conference != nil
          $conference.dir += dir_plus
        end
      when "conference_move"
        x_plus = data["x_plus"] || 0
        y_plus = data["y_plus"] || 0
        if $conference != nil
          dir = $conference.dir
          if dir != 0
            sn = Math::sin(Math::PI / 180 * dir)
            cs = Math::cos(Math::PI / 180 * dir)
            px = x_plus * cs - y_plus * sn
            py = x_plus * sn + y_plus * cs
            x_plus = px.round
            y_plus = py.round
          end
          $conference.x += x_plus
          $conference.y += y_plus
        end
      when "conference_scrollstream"
        pos_plus = data["pos_plus"] || 0
        if $conference != nil
          st = conference_getsource(data["stream"], data["source"])
          st.position += pos_plus if st != nil && st.scrollable?
        end
      when "conference_togglestream"
        if $conference != nil
          st = conference_getsource(data["stream"], data["source"])
          st.toggle if st != nil && st.toggleable?
        end
      when "conference_volumestream"
        if $conference != nil
          st = conference_getsource(data["stream"], data["source"], true)
          st.volume = data["volume"] if st != nil
          $conference.streams_callback
        end
      when "conference_locallymutestream"
        if $conference != nil
          st = $conference.outstreams[data["stream"]]
          st.locally_muted = data["mute"] if st != nil
          $conference.streams_callback
        end
      when "conference_removesource"
        if $conference != nil
          stream = $conference.outstreams[data["stream"]]
          if stream != nil
            stream.remove_source(data["source"])
          else
            $conference.remove_source(data["source"])
          end
          $conference.streams_callback
        end
      when "conference_whisper"
        if $conference != nil
          $conference.whisper = data["userid"]
        end
      when "conference_goto"
        if $conference != nil && data["x"].is_a?(Integer) && data["y"].is_a?(Integer)
          $conference.x = data["x"]
          $conference.y = data["y"]
        end
      when "conference_streamidsetvolume"
        if $conference != nil && data["id"].is_a?(Integer)
          $conference.streamid_setvolume(data["id"], data["volume"], data["mute"])
        end
      when "conference_kick"
        if $conference != nil && data["userid"].is_a?(Integer)
          $conference.kick(data["userid"])
        end
      when "conference_accept"
        if $conference != nil && data["userid"].is_a?(Integer)
          $conference.accept(data["userid"])
        end
      when "conference_ban"
        if $conference != nil && data["username"].is_a?(String)
          $conference.ban(data["username"])
        end
      when "conference_unban"
        if $conference != nil && data["username"].is_a?(String)
          $conference.unban(data["username"])
        end
      when "conference_admin"
        if $conference != nil && data["username"].is_a?(String)
          $conference.admin(data["username"])
        end
      when "conference_supervise"
        if $conference != nil && data["userid"].is_a?(Integer)
          $conference.supervise(data["userid"])
        end
      when "conference_unsupervise"
        if $conference != nil && data["userid"].is_a?(Integer)
          $conference.unsupervise(data["userid"])
        end
      when "conference_follow"
        if $conference != nil && data["channel"].is_a?(Integer)
          $conference.follow(data["channel"])
        end
      when "conference_unfollow"
        if $conference != nil && data["channel"].is_a?(Integer)
          $conference.unfollow(data["channel"])
        end
      when "conference_speechrequest"
        if $conference != nil
          $conference.speech_request
        end
      when "conference_speechrefrain"
        if $conference != nil
          $conference.speech_refrain
        end
      when "conference_speechallow"
        if $conference != nil && data["userid"] != nil
          $conference.speech_allow(data["userid"], data["replace"])
        end
      when "conference_speechdeny"
        if $conference != nil && data["userid"] != nil
          $conference.speech_deny(data["userid"])
        end
      when "conference_gotouser"
        if $conference != nil
          $conference.goto(data["userid"].to_i)
        end
      when "conference_open"
        conference_open(data)
      when "conference_close"
        if $conference != nil
          begin
            $conference.free
          rescue Exception
          end
          $conference = nil
        end
        ewrite({ "func" => "conference_close" })
      when "conference_addcard"
        cardid = -1
        mics = Bass.microphones
        for i in 1...mics.size
          if mics[i] == data["card"]
            cardid = i
            break
          end
        end
        if cardid > -1
          $conference.addg_card(cardid, data["listen"] == true) if $conference != nil
        end
      when "conference_pushtotalk"
        $conference.pushtotalk = data["pushtotalk"] if $conference != nil and data["pushtotalk"] != nil
        $conference.pushtotalk_keys = data["pushtotalk_keys"].split(",").map { |k| k.to_i } if $conference != nil and data["pushtotalk_keys"].is_a?(String)
      when "conference_removecard"
        $conference.remove_card if $conference != nil
      when "conference_setstream"
        $conference.set_stream(data["file"]) if $conference != nil
      when "conference_removestream"
        $conference.remove_stream if $conference != nil
      when "conference_setshoutcast"
        $conference.shoutcast_start(data["server"], data["pass"], data["name"] || nil, data["pub"] || false, data["bitrate"] || 128) if $conference != nil
      when "conference_removeshoutcast"
        $conference.shoutcast_stop if $conference != nil
      when "conference_setmuted"
        $conference.muted = data["muted"] if $conference != nil
      when "conference_setinputvolume"
        $conference.input_volume = data["volume"] if $conference != nil
      when "conference_setoutputvolume"
        $conference.volume = data["volume"] if $conference != nil
      when "conference_setstreamvolume"
        $conference.stream_volume = data["volume"] if $conference != nil
      when "conference_setvolume"
        if $conference != nil
          $conference.setvolume(data["user"], data["volume"], data["muted"], data["streams_muted"])
        end
      when "conference_beginsave"
        $conference.begin_save(data["file"]) if data["file"].is_a?(String) and $conference != nil
      when "conference_beginfullsave"
        $conference.begin_fullsave(data["dir"]) if data["dir"].is_a?(String) and $conference != nil
      when "conference_endsave"
        $conference.end_save if $conference != nil
      when "conference_addobject"
        if $conference != nil
          x = 0
          y = 0
          if data["location"] == 0
            x = $conference.x
            y = $conference.y
          end
          $conference.object_add(data["resid"], data["name"], x, y)
        end
      when "conference_removeobject"
        $conference.object_remove(data["id"]) if $conference != nil
      when "conference_addstream"
        if $conference != nil
          x = data["x"] || -1
          y = data["y"] || -1
          stream = nil
          if data["source"] == "file"
            stream = $conference.stream_add_file(data["file"], data["name"], x, y)
          elsif data["source"] == "card"
            stream = $conference.stream_add_card(data["cardid"], data["name"], x, y)
          end
          if stream != nil && data["mute"] == true
            stream.locally_muted = true
            $conference.streams_callback
          end
        end
      when "conference_addsource"
        if $conference != nil
          stream = $conference.outstreams[data["stream"]]
          if stream != nil
            if data["source"] == "file"
              stream.add_file(data["file"])
            elsif data["source"] == "card"
              stream.add_card(data["cardid"])
            end
          else
            if data["source"] == "file"
              $conference.add_file(data["file"])
            elsif data["source"] == "card"
              $conference.add_card(data["cardid"])
            end
          end
          $conference.streams_callback
        end
      when "conference_removestreamex"
        $conference.stream_remove(data["id"]) if $conference != nil
      when "conference_removesource"
        if $conference != nil
          stream = $conference.outstreams[data["stream"]]
          stream.remove_source(data["source"]) if stream != nil
        end
      when "conference_sendtext"
        if $conference != nil
          $conference.send_text(data["text"])
        end
      when "conference_diceroll"
        if $conference != nil
          $conference.diceroll((data["count"] || 6).to_i)
        end
      when "conference_decks"
        if $conference != nil
          decks = $conference.decks
          ewrite({ "func" => "conference_decks", "decks" => JSON.generate(decks) }) if decks != nil
        end
      when "conference_adddeck"
        if $conference != nil
          $conference.deck_add(data["type"])
        end
      when "conference_resetdeck"
        if $conference != nil
          $conference.deck_reset(data["deck"])
        end
      when "conference_removedeck"
        if $conference != nil
          $conference.deck_remove(data["deck"])
        end
      when "conference_cards"
        if $conference != nil
          cards = $conference.cards
          ewrite({ "func" => "conference_cards", "cards" => JSON.generate(cards) }) if cards != nil
        end
      when "conference_pickcard"
        if $conference != nil
          $conference.card_pick(data["deck"], data["cid"])
        end
      when "conference_changecard"
        if $conference != nil
          $conference.card_change(data["deck"], data["cid"])
        end
      when "conference_placecard"
        if $conference != nil
          $conference.card_place(data["deck"], data["cid"])
        end
      when "conference_listchannels"
        chans = []
        if $conference != nil
          for ch in $conference.list_channels
            chans.push(ch)
          end
        end
        ewrite({ "func" => "conference_listchannels", "channels" => JSON.generate(chans) })
      when "conference_createchannel"
        if $conference != nil
          id = nil
          id = $conference.create_channel(data) if $conference != nil
          ewrite({ "func" => "conference_createchannel", "channel" => id })
        end
      when "conference_editchannel"
        if $conference != nil
          $conference.edit_channel(data["channel"], data) if $conference != nil && data["channel"].is_a?(Integer)
        end
      when "conference_leavechannel"
        if $conference != nil
          $conference.leave_channel
        end
      when "conference_joinchannel"
        if $conference != nil
          $conference.join_channel(data["channel"], data["password"]) if $conference != nil
        end
      when "conference_setdevice"
        if $conference != nil
          $conference.set_device(data["device"])
        end
      when "conference_getcoordinates"
        if $conference != nil
          if data["userid"] == nil
            ewrite({ "func" => "conference_getcoordinates", "x" => $conference.x, "y" => $conference.y, "dir" => $conference.dir })
          else
            coords = $conference.coordinates(data["userid"])
            ewrite({ "func" => "conference_getcoordinates", "x" => coords[0], "y" => coords[1] })
          end
        end
      when "conference_callingplay"
        $conference.calling_play if $conference != nil
      when "conference_callingstop"
        $conference.calling_stop if $conference != nil
      when "conference_vsts"
        if $conference != nil
          vsts = $conference.vsts(data["userid"] || 0)
          ret = []
          for i in 0...vsts.size
            v = vsts[i]
            r = { "index" => i, "name" => v.name, "uniqueid" => v.unique_id, "version" => v.version, "file" => v.file, "bypass" => v.bypass, "showneditor" => v.editor_shown?, "haseditor" => v.editor?, "program" => v.program, "programs" => v.programs }
            params = []
            for m in v.parameters
              params.push({ "name" => m.name, "unit" => m.unit, "display" => m.display, "default" => m.default, "value" => m.value })
            end
            r["parameters"] = params
            ret.push(r)
          end
          ewrite({ "func" => "conference_vsts", "vsts" => JSON.generate(ret) })
        end
      when "conference_addvst"
        if $conference != nil
          $conference.vst_add(data["file"], data["userid"] || 0)
        end
      when "conference_removevst"
        if $conference != nil
          $conference.vst_remove(data["index"], data["userid"] || 0)
        end
      when "conference_movevst"
        if $conference != nil
          $conference.vst_move(data["index"], data["pos"], data["userid"] || 0)
        end
      when "conference_bypassvst"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"]]
          if vst != nil
            vst.bypass = data["bypass"]
          end
        end
      when "conference_setvstprogram"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"]]
          if vst != nil
            vst.program = data["program"]
          end
        end
      when "conference_setvstparam"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"].to_i]
          if vst != nil
            param = vst.parameters[data["parameter"].to_i]
            if param != nil
              param.value = data["value"]
            end
          end
        end
      when "conference_showvsteditor"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"].to_i]
          vst.editor_show if vst != nil
        end
      when "conference_hidevsteditor"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"].to_i]
          vst.editor_hide if vst != nil
        end
      when "conference_exportvstpreset"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"].to_i]
          if vst != nil
            ewrite({ "func" => "conference_exportvstpreset", "vstpreset" => Base64.strict_encode64(vst.export(:preset)) })
          end
        end
      when "conference_exportvstbank"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"].to_i]
          if vst != nil
            ewrite({ "func" => "conference_exportvstbank", "vstbank" => Base64.strict_encode64(vst.export(:bank)) })
          end
        end
      when "conference_importvstpreset"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"].to_i]
          if vst != nil
            vst.import(:preset, Base64.strict_decode64(data["vstpreset"]))
          end
        end
      when "conference_importvstbank"
        if $conference != nil
          vst = $conference.vsts(data["userid"] || 0)[data["index"].to_i]
          if vst != nil
            vst.import(:bank, Base64.strict_decode64(data["vstbank"]))
          end
        end
      when "audio3d_new"
        if $audio3ds[data["id"]] == nil
          a = Audio3D.new
          a.file = data["file"]
          $audio3ds[data["id"]] = a
        end
      when "audio3d_play"
        a = $audio3ds[data["id"]]
        a.play if a != nil
      when "audio3d_stop"
        a = $audio3ds[data["id"]]
        a.stop if a != nil
      when "audio3d_volume"
        a = $audio3ds[data["id"]]
        a.volume = data["volume"] if data["volume"].is_a?(Numeric) && a != nil
      when "audio3d_move"
        a = $audio3ds[data["id"]]
        if a != nil
          a.x = data["x"] if data["x"].is_a?(Numeric)
          a.y = data["y"] if data["y"].is_a?(Numeric)
          a.z = data["z"] if data["z"].is_a?(Numeric)
        end
      when "audio3d_setbilinear"
        a = $audio3ds[data["id"]]
        if a != nil
          a.bilinear = data["bilinear"]
        end
      when "audio3d_free"
        a = $audio3ds[data["id"]]
        if a != nil
          a.free
          $audio3ds.delete(data["id"])
        end
      when "feedid"
        $feed_id = data["feedid"]
      when "feedreset"
        $ag_feed = 0
        $ag_feedtime = 0
        $feeds = {}
        $feedstime = 0
        $lastfeeds = nil
      when "recording"
        $recording = data["recording"] == true
      when "zstd_compress"
        c = Zstd.compress(data["data"], data["level"] || 3)
        ewrite({ "func" => "zstd_compress", "id" => data["id"], "data" => c })
      when "zstd_decompress"
        d = Zstd.decompress(data["data"])
        ewrite({ "func" => "zstd_decompress", "id" => data["id"], "data" => d })
      end
    end
  end
end
