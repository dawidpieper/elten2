# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module QuickActions
    @@actions = nil
    @@addprocs = []

    class QuickAction
      attr_accessor :label, :key, :show
      attr_reader :action, :params

      def initialize(action, label = "", params = [], key = 0, show = true)
        @label, @action, @params, @key, @show = label, action, params, key, show
      end

      def detail
        l = @label
        if @key != 0
          l += " ("
          l += "CTRL+" if @key.abs > 12
          l += "SHIFT+" if @key < 0
          l += "F" + (@key.abs % 12).to_s
          l += ")"
        end
        return l
      end

      def call
        if @action.is_a?(Symbol)
          call_symbol
        else
          insert_scene(@action.new(*@params)) if !GlobalMenu.opened?
        end
      end

      def gettime
        if Configuration.synctime == 1
          t = srvproc("time", { "int" => 1 }, 1)
          return Time.now if t.to_i < 0
          time = Time.at(t.to_i)
        else
          time = Time.now
        end
        return time
      end

      def call_symbol
        case @action
        when :context
          $opencontextmenu = true
        when :lastspeech
          speak($speech_lasttext)
        when :copylastspeech
          Clipboard.text = $speech_lasttext
          alert(p_("EAPI_Common", "Last spoken text copied to clipboard"), false)
        when :tips
          tps = get_tips || []
          text = ""
          if tps.size == 0
            text = p_("EAPI_Common", "No tips available")
          else
            for i in 1...tps.size
              next if tps[i].size < 2
              t = tps[i] + ""
              t[0..0] = t[0..0].downcase if t[1..1].downcase == t[1..1].downcase
              tps[i] = t
            end
            text = tps.join(",\n")
          end
          alert(text, false)
        when :feed
          if $feedwriting != true
            begin
              $feedwriting = true
              inp = input_text(p_("EAPI_Common", "Message"), 0, "", true, [], [], 300)
              loop_update
              feed(inp) if inp != nil
              $feedwriting = false
            ensure
              $feedwriting = false
            end
          end
        when :alarm
          Scene_Clock.editalarm
          loop_update
        when :tray
          $totray = true
        when :srsapi
          if Configuration.voice == "NVDA"
            Configuration.voice = readconfig("Voice", "Voice", "")
          elsif Win32API.new("bin\\nvdaHelperRemote", "nvdaController_testIfRunning", "", "i").call == 0
            Configuration.voice = "NVDA"
          end
          if Configuration.voice == "NVDA"
            alert(p_("EAPI_Common", "Using NVDA"), false)
          else
            alert(p_("EAPI_Common", "Using a selected SAPI synthesizer"), false)
          end
        when :date
          alert(gettime.strftime("%Y-%m-%d"), false)
        when :time
          alert(gettime.strftime("%H:%M:%S"), false)
        when :volumedown
          Configuration.volume -= 5 if Configuration.volume > 5
          writeconfig("Interface", "MainVolume", Configuration.volume)
          eplay("listbox_focus")
        when :volumeup
          Configuration.volume += 5 if Configuration.volume < 100
          writeconfig("Interface", "MainVolume", Configuration.volume)
          eplay("listbox_focus")
        when :donotdisturb
          if $donotdisturb != true
            $donotdisturb = true
            $agent.write(Marshal.dump({ "func" => "donotdisturb_on" }))
            alert(p_("EAPI_Common", "Do not disturb on"))
          else
            $donotdisturb = false
            $agent.write(Marshal.dump({ "func" => "donotdisturb_off" }))
            alert(p_("EAPI_Common", "Do not disturb off"))
          end
        when :conference_streaming
          if Conference.opened?
            if Conference.streaming?
              Conference.remove_stream
            else
              file = getfile(p_("EAPI_Common", "Select audio file"), Dirs.documents + "\\", false, nil, [".mp3", ".wav", ".ogg", ".mid", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"])
              if file != nil
                Conference.set_stream(file)
              end
            end
          end
        when :conference_setvolumes
          if Conference.opened?
            Scene_Conference.setvolumes
          end
        when :conference_mutemic
          if Conference.opened?
            Conference.muted = !Conference.muted
            if Conference.muted
              speak(p_("EAPI_Common", "Microphone muted"))
            else
              speak(p_("EAPI_Common", "Microphone unmuted"))
            end
          end
        when :conference_pushtotalk
          if Conference.opened?
            Conference.pushtotalk = !Conference.pushtotalk
            LocalConfig["ConferencePushToTalk"] = (Conference.pushtotalk) ? (1) : (0)
          end
        when :conference_diceroll
          Conference.diceroll(6)
        when :conference_dicerollcustom
          Scene_Conference.custom_diceroll
        else
          g = QuickActions.get_proc(action)
          g.call if g != nil
        end
      end
    end

    class << self
      def get
        load_actions if @@actions == nil
        @@actions.dup
      end

      def load_actions
        @@actions = []
        if !FileTest.exists?(Dirs.eltendata + "\\quickactions.dat")
          load_defaults
        else
          d = load_data(Dirs.eltendata + "\\quickactions.dat")
          for ac in d
            if ac[0][0..0] == ":"
              ac[0] = ac[0][1..-1].to_sym
            else
              begin
                ac[0] = Object.const_get(ac[0])
              rescue Exception
                next
              end
            end
            register(*ac)
          end
        end
      rescue Exception
        load_defaults
      end

      def load_defaults
        acs = [
          [Scene_WhatsNew, p_("EAPI_QuickActions", "What is new?"), [], 10],
          [Scene_Contacts, p_("EAPI_QuickActions", "My contacts"), [], 9],
          [Scene_Online, p_("EAPI_QuickActions", "Who is online?"), [], -9],
          [Scene_Messages, p_("EAPI_QuickActions", "Messages"), [], -11],
          [Scene_Forum, p_("EAPI_QuickActions", "Forum")],
          [Scene_Blog, p_("EAPI_QuickActions", "Blogs")],
          [Scene_Conference, p_("EAPI_QuickActions", "Conferences")],
          [Scene_PremiumPackages, p_("EAPI_QuickActions", "Premium packages")]
        ] + predefined_procs(true)
        acs.each { |a|
          register(*a)
        }
      end

      def register_proc(program, ident, label, proc)
        s = program.to_s + "__" + ident.to_s
        @@addprocs.push([program, s.to_sym, label, proc])
      end

      def predefined_procs(defaults = false)
        a = [
          [:tips, p_("EAPI_QuickActions", "Read tips on the current control"), [], 1, false],
          [:context, p_("EAPI_QuickActions", "Open context menu"), [], -10, false],
          [:time, p_("EAPI_QuickActions", "Say time"), [], 8, false],
          [:date, p_("EAPI_QuickActions", "Say date"), [], -8, false],
          [:lastspeech, p_("EAPI_QuickActions", "Speak last text"), [], 11, false],
          [:tray, p_("EAPI_QuickActions", "Minimize Elten to tray"), [], 3, false],
          [:srsapi, p_("EAPI_QuickActions", "Switch voice output between NVDA and Sapi5"), [], -1, false],
          [:volumedown, p_("EAPI_QuickActions", "Volume down"), [], 5, false],
          [:volumeup, p_("EAPI_QuickActions", "Volume up"), [], 6, false],
          [:donotdisturb, p_("EAPI_QuickActions", "Switch \"Do not disturb\" mode"), [], -2, false],
          [:feed, p_("EAPI_QuickActions", "Publish to a feed"), [], 4, false]
        ]
        if defaults != true
          a += [
            [:copylastspeech, p_("EAPI_QuickActions", "Copy last spoken text to clipboard"), [], 0, false],
            [:conference_streaming, p_("EAPI_QuickActions", "Conferences: stream audio file"), [], 0, false],
            [:conference_setvolumes, p_("EAPI_QuickActions", "Conferences: set volumes"), [], 0, false],
            [:conference_mutemic, p_("EAPI_QuickActions", "Conferences: mute microphone"), [], 0, false],
            [:conference_pushtotalk, p_("EAPI_QuickActions", "Conferences: switch push to talk"), [], 0, false],
            [:conference_diceroll, p_("EAPI_QuickActions", "Conferences: roll a 6-sided dice"), [], 0, false],
            [:conference_dicerollcustom, p_("EAPI_QuickActions", "Conferences: roll a custom dice"), [], 0, false],
            [:alarm, p_("EAPI_QuickActions", "Add alarm"), [], 0, false]
          ]
          for ac in @@addprocs
            a.push([ac[1], ac[2]])
          end
        end
        return a
      end

      def register(scene, label = "", params = [], key = 0, show = true)
        @@actions.push(QuickAction.new(scene, label, params, key, show))
      end

      def create(scene, label = "", params = [], key = 0, show = true)
        register(scene, label, params, key, show)
        save_actions
      end

      def delete(index)
        @@actions.delete_at(index)
        save_actions
      end

      def rename(index, label)
        @@actions[index].label = label
        save_actions
      end

      def rekey(index, key)
        @@actions[index].key = key
        save_actions
      end

      def reshow(index, show)
        @@actions[index].show = show
        save_actions
      end

      def up(index)
        @@actions[index - 1], @@actions[index] = @@actions[index], @@actions[index - 1]
        save_actions
      end

      def down(index)
        @@actions[index + 1], @@actions[index] = @@actions[index], @@actions[index + 1]
        save_actions
      end

      def save_actions
        a = generate_struct
        save_data(a, Dirs.eltendata + "\\quickactions.dat")
      end

      def generate_struct
        a = []
        for ac in @@actions
          b = []
          if ac.action.is_a?(Symbol)
            b[0] = ":" + ac.action.to_s
          elsif ac.action.is_a?(Class)
            b[0] = ac.action.name
          else
            next
          end
          b[1] = ac.label.to_s
          b[2] = ac.params
          b[3] = ac.key
          b[4] = ac.show
          a.push(b)
        end
        return a
      end

      def get_proc(pr)
        for a in @@addprocs
          return a[3] if a[1] == pr
        end
        return nil
      end
    end
  end
end
