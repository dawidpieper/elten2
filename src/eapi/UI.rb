# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module UI
    @@altdowntime = 0

    private

    # User interface related functions
    # Plays a soundtheme sound
    #
    # @param voice [String] a voice name
    # @param volume [Numeric] the volume
    # @param pitch [Numeric] the pitch
    # @example
    #  play("listbox_focus",80,100)
    def eplay(voice, volume = 100, pitch = 100, pan = 50)
      if Configuration.soundthemeactivation != 0 or FileTest.exists?(voice)
        b = nil
        if volume >= 0
          volume = (volume.to_f * Configuration.volume.to_f / 100.0)
          volume = 100 if volume > 100
          volume = 1 if volume < 1
          volume = volume.to_i
        else
          volume = volume * -1
          volume = 100 if volume > 100
        end
        sound = nil
        sound = getsound(voice)
        sound = readfile(sound) if sound == nil && FileTest.exists?(sound)
        if sound != nil
          stream = Bass::BASS_StreamCreateFile.call(1, sound, 0, 0, sound.bytesize, 0, 262144)
          Bass::BASS_ChannelSetAttribute.call(stream, 2, [volume.to_f / 100.0 * 0.5].pack("f").unpack("I")[0])
          if Configuration.usepan == 1
            Bass::BASS_ChannelSetAttribute.call(stream, 3, [pan.to_f / 50.0 - 1.0].pack("f").unpack("I")[0])
          end
          Bass::BASS_ChannelPlay.call(stream, 0)
        end
      end
    end

    def play(*arg)
      eplay(*arg)
    end

    # The keyboard related functions
    # Determines if escape has been pressed
    #
    # @return [Boolean] returns true if escape was pressed, otherwise returns false
    def escape
      return $key[0x1B]
    end

    # Determines if alt has been pressed
    #
    # @return [Boolean] returns true if alt was pressed, otherwise returns false
    def alt
      if (@@altdowntime || 0) < Time.now.to_f - 1
        @@altdown ||= false
        @@altdowntime = Time.now.to_f
        return false
      end
      @@altdown = true if $keypr[0x12]
      @@altdown = false if $keyr[0x11]
      l = $keyu[0x12] && @@altdown
      @@altdowntime = 0 if l
      return l
    end

    # Determines if enter has been pressed
    #
    # @return [Boolean] returns true if enter was pressed, otherwise returns false
    def enter
      if $enter.is_a?(Integer)
        if $enter > 0
          $enter -= 1
          $key[0xD] = true
        end
      end
      key_update if $key == nil
      return $key[0xD]
    end

    # Determines if spacebar has been pressed
    #
    # @return [Boolean] returns true if spacebar was pressed, otherwise returns false
    def space
      return $key[0x20]
    end

    def arrow_left(repeat = false)
      if repeat
        return $keyr[0x25]
      else
        return $key[0x25]
      end
    end

    def arrow_up(repeat = false)
      if repeat
        return $keyr[0x26]
      else
        return $key[0x26]
      end
    end

    def arrow_right(repeat = false)
      if repeat
        return $keyr[0x27]
      else
        return $key[0x27]
      end
    end

    def arrow_down(repeat = false)
      if repeat
        return $keyr[0x28]
      else
        return $key[0x28]
      end
    end

    # Updates the keyboard state
    def key_update
      if $nextkey != nil and $nextkeyr != nil and $nextkeypr != nil
        $key, $keyr, $keypr = $nextkey, $nextkeyr, $nextkeypr
        $nextkey, $nextkeyr, $nextkeypr = nil, nil, nil
        return
      end
      lkey = $key
      $key = Array.new(256)
      $keyu = Array.new(256)
      $keyr ||= Array.new(256)
      $keypr = []
      $keybd = "\0" * 256
      Win32API.new("user32", "GetKeyboardState", "p", "i").call($keybd)
      bd = $keybd.unpack("c" * 256)
      k = "\0" * 256
      Win32API.new($eltenlib, "getkeys", "p", "i").call(k)
      d = k.unpack("c" * 256)
      tokeys = []
      if NVDA.check
        g = NVDA.getgestures
        for k in g
          k = k.downcase
          if k == "kb(laptop):nvda+a" or k == "kb(desktop):nvda+downarrow"
            tokeys.push(0x2D, 0x28)
          elsif k == "kb(laptop):nvda+l" or k == "kb(desktop):nvda+uparrow"
            tokeys.push(0x2D, 0x26)
          end
        end
      end
      if $setkeys.is_a?(Array)
        tokeys += $setkeys
        $setkeys = nil
      end
      for i in 0..255
        if ((d[i] & 1) > 0 or tokeys.include?(i)) and (lkey == nil or i < 32 or lkey[i] == false)
          $key[i] = true
          $keypr[i] = true if (d[i] & 4) == 0
        else
          $key[i] = false
          $keypr[i] = false
        end
        if (d[i] & 2 > 0)
          $keyu[i] = true
        else
          $keyu[i] = false
        end
        if bd[i] < 0 or tokeys.include?(i)
          $keyr[i] = true
        elsif $key[i] and i < 32
          bd[i] = -128
        else
          $keyr[i] = false
        end
      end
      $key[0x12] = true if $keyr[0x12]
      $key[0x10] = true if $keyr[0x10]
      $key[0x11] = true if $keyr[0x11]
      $keybd = bd.pack("c" * 256)
    end

    def keycode(l)
      if !l.is_a?(Symbol)
        return([0, false]) if l.chrsize > 1
        return([(l.upcase)[0], l != l.downcase]) if (/\w|\d/ =~ l)
      end
      if l.to_s.size == 1
        k = l.to_s
        return([(k.upcase)[0], k != k.downcase]) if (/\w|\d/ =~ k)
      end
      shf = false
      if (s = l.to_s).size > 5 && s[0..5].downcase == "shift_"
        l = s[6..-1].to_sym
        shf = true
      end
      mappings = {
        :esc => 0x1b,
        :space => 0x20,
        :ins => 0x2d,
        :del => 0x2e,
        :enter => 0xd,
        ";" => 0xba,
        ";" => -0xba,
        "=" => 0xbb,
        "+" => -0xbb,
        "," => 0xbc,
        "<" => -0xbc,
        "-" => 0xbd,
        "_" => -0xbd,
        "." => 0xbe,
        ">" => -0xbe,
        "/" => 0xbf,
        "?" => -0xbf,
        "[" => 0xdb,
        "{" => -0xdb,
        "\\" => 0xdc,
        "|" => -0xdc,
        "]" => 0xdd,
        "}" => -0xdd
      }
      if mappings[l] != nil
        return([mappings[l].abs, mappings[l] < 0 || shf])
      end
      return ([0, false])
    end

    def keyprocs
      if $ruby != true or $windowminimized != true
        if $keypr[0x11]
          speech_stop(false)
          $speech_wait = false
        end
        if !GlobalMenu.opened? && alt
          GlobalMenu.show
        end
        if !GlobalMenu.opened? && $key[0x5D]
          GlobalMenu.show(false)
        elsif $opencontextmenu == true && !GlobalMenu.opened?
          suc = false
          ($activecontrols || []).each { |ac|
            suc = true if ac.hascontext
          }
          if suc
            $opencontextmenu = false
            GlobalMenu.show(false)
          else
            $opencontextmenucounter += 1
            $opencontextmenu = false if $opencontextmenucounter >= 10
          end
        elsif $opencontextmenu = 0
          $opencontextmenucounter = 0
        end
        if $key[0x7B]
          confirm("Do you want to restart Elten?") { $reset = true }
        end
        ac = QuickActions.get
        for i in 1..11
          k = 0x6F + i
          if $key[k]
            l = i
            l *= -1 if $keyr[0x10]
            for a in ac
              a.call if a.key == l
            end
          end
        end
      end
      if !$keyr[0x12] && ($key.include?(true))
        if $key.include?(true)
          t = GlobalMenu.ctitems
          for m in t
            l = m[3]
            k, shift = keycode(l)
            if $key[k] && $keyr[0x10] == shift && ($keyr[0x11] || l.is_a?(Symbol)) && m[1].is_a?(Proc)
              m[1].call(m[2])
              loop_update(false)
            end
          end
        end
      end
    end

    class CallWindow
      attr_reader :id, :caller, :channel, :password

      def initialize(id, caller, channel, password)
        @id, @caller, @channel, @password = id, caller, channel, password
        @form = Form.new([
          @st_caller = Static.new(p_("EAPI_UI", "%{user} is calling you") % { "user" => @caller }),
          @btn_answer = Button.new(p_("EAPI_UI", "Answer")),
          @btn_reject = Button.new(p_("EAPI_UI", "Reject"))
        ])
      end

      def update
        @form.update
        cancel if @btn_reject.pressed?
        if @btn_answer.pressed?
          cancel
          insert_scene(Scene_VoiceCall.new(@channel, @password))
        end
      end

      def cancel
        srvproc("calls", { "ac" => "cancel", "call" => @id })
      end
    end

    # Updates a window, speech api and keyboard state
    @@call = nil

    def loop_update(checkControls = true, responseCalls = true)
      if $reset == true
        if Thread::current != $mainthread
          exit
        else
          raise(Reset, "")
        end
      end
      exit if $exitproc == true
      if $exitupdate == true || $exitreinstall == true
        $scene = nil
        speech_stop
      end
      if $ruby == true
        while $windowminimized == true
          sleep(0.1)
        end
      end
      tr = false
      if $trayreturn == true
        Log.info("Restored from tray")
        tr = true
      end
      if $agent != nil and (av = $agent.avail) > 0
        str = $agent.read(av)
        m = []
        index = 0
        while index < str.size
          o = str[index...index + 4]
          index += 4
          size = o.unpack("I").first
          str += $agent.read while str.size < index + size
          z = str[index...index + size]
          index += size
          m.push(Zlib::Inflate.inflate(z))
        end
        for e in m
          ind = 0
          d = {}
          while ind < e.size
            ksize, vsize = e[ind...ind + 8].unpack("II")
            ind += 8
            type = e[ind..ind]
            ind += 1
            k = e[ind...ind + ksize]
            ind += ksize
            v = e[ind...ind + vsize]
            ind += vsize
            v = v.to_i if type == "I"
            v = v.to_f if type == "F"
            v = false if type == "B" && v == "false"
            v = true if type == "B" && v == "true"
            d[k] = v
          end
          if d["func"] == "notif"
            if $notifications_callback != nil
              $notifications_callback.call(d)
            else
              process_notification(d)
            end
          elsif d["func"] == "srvproc"
            $agids.delete(d["id"])
            $eresps[d["id"]] = d
          elsif d["func"] == "downloadfile"
            $agids.delete(d["id"])
            $eresps[d["id"]] = d
          elsif d["func"] == "srvproc_uploadprogress"
            $eprogresses[d["id"]] = d["percent"]
          elsif d["func"] == "downloadfile_downloadprogress"
            $eprogresses[d["id"]] = d["percent"]
          elsif d["func"] == "readurl"
            $agids.delete(d["id"])
            $eresps[d["id"]] = d
          elsif d["func"] == "jproc"
            $agids.delete(d["id"])
            $jresps[d["id"]] = d
          elsif d["func"] == "eltsock_create"
            $eltsocks_create ||= {}
            $eltsocks_create[d["id"]] = d
          elsif d["func"] == "eltsock_write"
            $eltsocks_write ||= {}
            $eltsocks_write[d["id"]] = d
          elsif d["func"] == "eltsock_read"
            $eltsocks_read ||= {}
            $eltsocks_read[d["id"]] = d
          elsif d["func"] == "eltsock_close"
            $eltsocks_close ||= {}
            $eltsocks_close[d["id"]] = d
          elsif d["func"] == "tray"
            $trayreturn = true
          elsif d["func"] == "alarm"
            Log.info("Alarm" + ((d["description"] != nil) ? d["description"] : ""))
            $agalarm = true
            $agalarmdescription = d["description"]
          elsif d["func"] == "msg"
            $agent_msg = d["msgs"].to_i
          elsif d["func"] == "srvverify"
            $srvverify = d["succeeded"]
          elsif d["func"] == "error"
            e = d["msg"] + "\r\n" + d["loc"]
            Log.error("Agent: #{e}")
            if confirm(p_("EAPI_UI", "An unexpected error of Elten agent occurred. Do you want to report this event? It  may definitely help us solve the problem.")) == 1
              bug(false, "Elten Agent Error:\r\n" + e)
            end
            print e if $DEBUG
            alert(p_("EAPI_UI", "The program is trying to recover from the frozen state."))
          elsif d["func"] == "log"
            Log.add(d["level"], d["msg"], Time.at(d["time"]))
          elsif d["func"] == "conference_open"
            Conference.setopened(d)
          elsif d["func"] == "conference_close"
            Conference.setclosed
          elsif d["func"] == "conference_channel"
            Conference.setchannel(d["channel"]) if d["channel"] != nil
          elsif d["func"] == "conference_volumes"
            Conference.setvolumes(d["volumes"]) if d["volumes"] != nil
          elsif d["func"] == "conference_createchannel"
            Conference.setcreated(d["channel"])
          elsif d["func"] == "conference_listchannels"
            Conference.setchannels(d["channels"])
          elsif d["func"] == "conference_status"
            Conference.setstatus(d["status"])
          elsif d["func"] == "conference_text"
            Conference.settext(d["username"], d["userid"], d["text"])
          elsif d["func"] == "sig"
            play "right"
            if $scene.class.ancestors.include?(Program) and d["appid"] == $scene.class::AppID
              $scene.signaled(d["sender"], JSON.load(d["packet"]))
            end
          elsif d["func"] == "call_start"
            @@call = CallWindow.new(d["call_id"], d["caller"], d["channel"], d["password"]) if @@call == nil || @@call.id != d["call_id"]
          elsif d["func"] == "call_stop"
            @@call = nil
            $focus = true
          elsif d["func"] == "premiumpackages"
            update_premiumpackages(d["premiumpackages"].split(","))
          else
            Log.warning("Agent unknown data: #{e}")
            play "right"
          end
        end
      end
      $agentupst = 0 if $agentupst == nil
      $agentupst += 1
      suc = true
      suc = false if $agentthr != nil and ($agentthr.status != false and $agentthr.status != nil)
      if $agentupst > 200 and suc == true
        $agentthr = Thread.new do
          $agentupst = 0
          if $agent != nil
            x = "\0" * 4
            Win32API.new("kernel32", "GetExitCodeProcess", "ip", "i").call($agent.pid, x)
            if x[0..1] != "\003\001"
              Log.warning("Agent expected to be loaded")
              agent_start
              $agentloaded = true
              $agentfails = 0 if $agentfails == nil
              $agentfails += 1
              $agentfaillasttime = 0 if $agentfaillasttime == nil
              eplay("right")
              $agentfaillasttime = Time.now.to_i
            end
          end
        end
      end
      $activitytime ||= Time.now.to_i
      $activity ||= {}
      $activity[$scene.class.name] ||= 0
      $activity[$scene.class.name] += 1.0 / Graphics.frame_rate
      register_activity if Time.now.to_i - $activitytime > 3600 and Configuration.registeractivity == 1
      Graphics.update
      Input.update
      key_update
      if $totray == true
        $totray = false
        Audio.bgs_stop
        if readconfig("Interface", "HideWindow", 0) == 0
          Win32API.new("user32", "ShowWindow", "ii", "i").call($wnd, 0)
          $trayreturn = true
        else
          Win32API.new("user32", "ShowWindow", "ii", "i").call($wnd, 6)
        end
      end
      if Thread::current != $currentthread
        l = "main"
        l = $subthreads.size if Thread::current != $mainthread
        Log.info("Pausing thread #{l}")
        sc = $scene
        sleep(0.1) while $currentthread != Thread::current
        Log.info("Thread resumed #{l}")
        $scene = sc
      end
      if tr == true
        $trayreturn = false
        $key = [0] * 256
        $keyms = [0] * 256
        delay(0.5)
        Win32API.new("user32", "ShowWindow", "ii", "i").call($wnd, 5)
        eplay("login")
        speak("ELTEN")
      end
      if $agalarm == true and $alarmproc != true
        $alarmproc = true
        eplay("dialog_open")
        al = p_("EAPI_UI", "Alarm")
        al = $agalarmdescription if $agalarmdescription != nil
        alert(al)
        t = Time.now.to_f
        until escape or enter or space
          loop_update
          if Time.now.to_f - t > 5
            speak(al)
            t = Time.now.to_f
          end
        end
        $agalarm = false
        $agent.write(Marshal.dump({ "func" => "alarm_stop" }))
        eplay("dialog_close")
        loop_update
        $alarmproc = false
      end
      if @@call != nil
        @@call.update
        for i in 1..255
          $key[i] = false
          $keyr[i] = false
          $keyu[i] = false
          $keypr[i] = false
        end
        $focus = false
      end
      keyprocs
      if checkControls
        $activecontrols ||= []
        $lastactivecontrols ||= []
        for c in $lastactivecontrols
          c.blur if !$activecontrols.include?(c)
        end
        $lastactivecontrols = $activecontrols.dup
        $activecontrols.clear
      end
    rescue Reset => r
      if $reset == true
        $reset = false
        fail Reset
      end
    rescue Hangup
    rescue Interrupt
    end

    def get_tips
      tips = []
      if $activecontrols != nil
        $activecontrols.each { |ac|
          t = ac.get_tips
          tips += t if t.is_a?(Array)
        }
      end
      return tips
    end

    def keys_copyvalues
      $nextkey = $key
      $nextkeyr = $keyr
      $nextkeypr = $keypr
    end

    # Creates a simple dialog with options yes and no and returns the user's decision
    #
    # @param text [String] a question to ask
    # @return [Numeric] return 0 if user selected no or pressed escape, returns 1 if selected yes.
    def confirm(text = "")
      text.gsub!("jesteś pewien", "jesteś pewna") if Configuration.language == "pl-PL" and Session.gender == 0
      dialog_open
      sel = ListBox.new([_("No"), _("Yes")], text, 0, ListBox::Flags::AnyDir)
      loop do
        loop_update
        sel.update
        if escape
          loop_update
          dialog_close
          return(0)
        end
        if enter
          loop_update
          dialog_close
          if sel.options.size == 2
            yield if sel.index == 1 and block_given?
            return(sel.index)
          else
            if sel.index <= 5
              return 0
            elsif sel.index <= 9
              yield
              return 1
            else
              return rand(2)
            end
          end
        end
        if $keyr[0x10] and $keyr[84] and $keyr[78]
          sel = ListBox.new(["Hmmmm, nie, podziękuję", "Coś ty, oszalałeś?", "Nie ma mowy", "Nigdy w życiu", "Pogięło cię? Jasne, że nie", "Chyba masz jakieś zwidy jeśli sądzisz, że się zgodzę", "W sumie, czemu nie", "HMMM, kusi, pomyślmy, no ok, zgoda", "Jasne, genialny pomysł", "Jestem za", "A ty zdecyduj"], "Możesz się szybciej decydować? " + text, 0, ListBox::Flags::AnyDir)
        end
      end
    end

    def prompt(header = "", confirmation = "Ok", cancellation = _("Cancel"))
      form = Form.new([EditBox.new(header, EditBox::Flags::MultiLine), Button.new(confirmation), Button.new(cancellation)])
      snd = form.fields[1]
      dialog_open
      loop do
        loop_update
        if form.fields[0].text == "" and form.fields[1] != nil
          form.fields[1] = nil
        elsif form.fields[0].text != "" and form.fields[1] == nil
          form.fields[1] = snd
        end
        form.update
        if (((enter or space) and form.index == 1) or (enter and $key[0x11] and form.index == 0)) and form.fields[0].text != ""
          dialog_close
          return form.fields[0].text.gsub("\004LINE\004", "\r\n")
          break
        end
        if ((enter or space) and form.index == 2) or escape
          dialog_close
          return ""
          break
        end
      end
    end

    @@waitingvoice = nil
    @@waitingopened = false

    def waiting_opened
      @@waitingopened
    end

    # Opens a waiting dialog
    def waiting
      snd = getsound("waiting")
      waiting_end if @@waitingvoice != nil
      if snd != nil
        @@waitingvoice = Bass::Sound.new(nil, 1, true, false, snd)
        @@waitingvoice.volume = Configuration.volume.to_f / 150.0
        @@waitingvoice.play
      end
      @@waitingopened = true
    end

    # Closes a waiting dialog
    def waiting_end
      if @@waitingvoice != nil
        @@waitingvoice.close
        @@waitingvoice = nil
      end
      @@waitingopened = false
    end

    @@dialogvoice = nil
    @@dialogopened = false

    def dialog_opened
      return @@dialogopened
    end

    def dialog_mute
      @@dialogvoice.volume = 0 if @@dialogvoice != nil
    end

    # Opens a dialog
    def dialog_open
      eplay("dialog_open")
      dialog_close if @@dialogvoice != nil
      if Configuration.bgsounds == 1 && Configuration.soundthemeactivation == 1
        snd = getsound("dialog_background")
        if snd != nil
          @@dialogvoice = Bass::Sound.new(nil, 0, true, false, snd)
          @@dialogvoice.volume = Configuration.volume.to_f / 100.0
          @@dialogvoice.position = 0
          @@dialogvoice.play
        end
      end
      @@dialogopened = true
    end

    # Closes a dialog
    def dialog_close
      if @@dialogvoice != nil
        @@dialogvoice.close
        @@dialogvoice = nil
      end
      eplay("dialog_close")
      NVDA.braille("") if NVDA.check
      @@dialogopened = false
    end
  end

  include UI
end
