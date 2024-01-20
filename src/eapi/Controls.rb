# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2024 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module Controls
    private

    # Controls and forms related class

    def keyevents
      k = []
      ks = {
        65 => "a", 66 => "b", 67 => "c", 68 => "d", 69 => "e", 70 => "f", 71 => "g", 72 => "h", 73 => "i", 74 => "j",
        75 => "k", 76 => "l", 77 => "m", 78 => "n", 79 => "o", 80 => "p", 81 => "q", 82 => "r", 83 => "s", 84 => "t",
        85 => "u", 86 => "v", 87 => "w", 88 => "x", 89 => "y", 90 => "z",
        48 => "0", 49 => "1", 50 => "2", 51 => "3", 52 => "4", 53 => "5", 54 => "6", 55 => "7", 56 => "8", 57 => "9",
        32 => "space",
        8 => "backspace", 9 => "tab", 13 => "enter",
        0x10 => "shift", 0x11 => "control", 0x12 => "alt", 0x1B => "escape",
        0x21 => "pageup", 0x22 => "pagedown", 0x23 => "end", 0x24 => "home", 0x2D => "insert", 0x2E => "delete",
        0xBC => "comma", 0xBD => "minus", 0xBE => "period",
        0x25 => "left", 0x26 => "up", 0x27 => "right", 0x28 => "down"
      }
      for e in ks.keys
        k.push([("key_" + ks[e]).to_sym, ks[e].to_sym]) if $key[e]
        k.push([("keyr_" + ks[e]).to_sym, ks[e].to_sym]) if $keyr[e]
        k.push([("keyup_" + ks[e]).to_sym, ks[e].to_sym]) if $keyu[e]
      end
      return k
    end

    class FormBase
      attr_accessor :header

      def params
        @params ||= {}
        @params
      end

      def on(event, time = 0, getparams = false, &block)
        @events ||= []
        @events.push([event, time, 0, getparams, block])
      end

      def trigger(event, *params)
        return if @events == nil
        @events.each { |e|
          if e[0] == event and e[2] <= Time.now.to_f - e[1]
            e[2] = Time.now.to_f
            a = *params
            a ||= []
            a.insert(0, params) if e[3] == true
            e[4].call(a)
          end
        }
      end

      def wait
        if @updated == true || @quiet == true
          @playmarker = false
          play("form_marker")
          focus
        end
        @wait = true
        while @wait == true
          loop_update
          self.update
        end
      end

      def resume
        @wait = false
        loop_update
      end

      def disable_menu
        @disable_menu = true
      end

      def enable_menu
        @disable_menu = false
      end

      def menu_enabled?
        @disable_menu != true
      end

      def disable_contextinglobal
        @disable_contextinglobal = true
      end

      def enable_contextinglobal
        @disable_contextinglobal = false
      end

      def contextinglobal_enabled?
        @disable_contextinglobal != true
      end

      def bind_context(h = "", &b)
        @contexts ||= []
        @contexts.push([b, h])
      end

      def hascontext
        return false if @contexts == nil
        return @contexts.size > 0
      end

      def context(menu, submenu = true)
        return if submenu && @disable_contextinglobal == true
        @contexts ||= []
        @contexts.each { |c|
          s = c[1]
          s = @header if s == "" and @header.is_a?(String)
          if s == ""
            s = _("Context menu")
          else
            s += " (" + _("Context menu") + ")"
          end
          if submenu
            menu.submenu(s) { |m|
              c[0].call(m)
            }
          else
            c[0].call(menu)
          end
        }
      end

      def update(*arg)
        keyevents.each { |a| trigger(a[0]) if !key_processed(a[1]) }
        $activecontrols.push(self) if $activecontrols.is_a?(Array)
      end

      def focus(index = nil, count = nil)
      end

      def blur
      end

      def key_processed(k)
        return false
      end

      def add_tip(tip)
        @customtips ||= []
        @customtips.push(tip)
      end

      def get_tips
        tps = []
        if @customtips != nil
          tps = @customtips
        end
        ti = tips
        if ti != nil
          tps += ti
        end
        return tps
      end

      def tips
        return []
      end
    end

    class FormTimer
      attr_reader :time, :repeat, :starttime

      def initialize(time, repeat = false, autostart = true, &action)
        @time, @repeat = time, repeat
        @starttime = nil
        @completed = false
        @action = action
        start if autostart
      end

      def start
        @starttime = Time.now.to_f
        @completed = false
      end

      def stop
        @starttime = nil
      end

      def update
        return if @starttime == nil || @completed == true
        if Time.now.to_f - @starttime >= @time
          @action.call if @completed == false && @action != nil
          @completed = true
          @starttime = nil
          start if repeat
        end
      end
    end

    # A form
    class Form < FormBase
      # @return   [Numeric] a form index
      attr_reader :index
      # @return [Array] an array of form fields
      attr_accessor :fields
      attr_accessor :cancel_button, :accept_button
      # Creates a form
      #
      # @param fields [Array] an array of form fields
      # @param index [Numeric] the initial index
      def initialize(fields = [], index = 0, silent = false, quiet = false)
        @fields = fields
        @index = index
        @silent = silent
        @hidden = []
        if @fields[@index].is_a?(Array)
          if @fields[@index][0] == 0
            @fields[@index] = EditBox.new(@fields[@index][1], @fields[@index][2], @fields[@index][3], false, @fields[@index][4])
          end
        end
        if @fields[@index] != nil && quiet == false
          @fields[@index].trigger(:before_focus)
          @fields[@index].focus(@index, @fields.size)
          @fields[@index].trigger(:focus)
        end
        @timers = []
        @playmarker = false
        @playmarker = true if @silent == false
        @updated = false
        @quiet = quiet
        loop_update
      end

      # Updates a form
      def update
        @updated = true
        if @playmarker == true
          @playmarker = false
          play("form_marker")
        end
        super
        if $focus == true
          focus
          $focus = false
        end
        @index -= 1 while (@fields[@index] == nil or @hidden[@index] == true) and @index > 0
        @index += 1 while (@fields[@index] == nil or @hidden[@index] == true) and @index < @fields.size - 1
        oldindex = @index
        if $key[0x09] == true
          speech_stop
          if $key[0x10] == false and @fields[@index].subindex == @fields[@index].maxsubindex
            ind = @index
            @index += 1
            while (@fields[@index] == nil or @hidden[@index] == true) and @index < @fields.size
              @index += 1
            end
            if @index >= @fields.size
              if Configuration.roundupforms == 0
                @index = ind
                trigger(:border, @index)
                play("border", 100, 100, @index.to_f / (@fields.size - 1).to_f * 100.0)
              else
                @index = 0
                while (@fields[@index] == nil or @hidden[@index] == true) and @index < @fields.size
                  @index += 1
                end
              end
            end
          elsif $key[0x10] and @fields[@index].subindex == 0
            ind = @index
            @index -= 1
            while @fields[@index] == nil or @hidden[@index] == true
              @index -= 1
            end
            if @index < 0
              if Configuration.roundupforms == 0
                @index = ind
                trigger(:border, @index)
                play("border", 100, 100, @index.to_f / (@fields.size - 1).to_f * 100.0)
              else
                @index = @fields.size - 1
                while @fields[@index] == nil or @hidden[@index] == true
                  @index -= 1
                end
                @index = ind if @index < 0
              end
            end
          end
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
              @fields[@index] = EditBox.new(@fields[@index][1], @fields[@index][2], @fields[@index][3], false, @fields[@index][4])
            end
          end
          @fields[oldindex].trigger(:blur)
          @fields[oldindex].blur
          @fields[@index].trigger(:before_focus)
          @fields[@index].focus(@index, @fields.size)
          @fields[@index].trigger(:focus)
          trigger(:move, @index)
        else
          @fields[@index].update
        end
        if escape && @cancel_button.is_a?(Button)
          @cancel_button.press
        end
        if @fields[@index] != nil && @accept_button != nil && !@fields[@index].is_a?(Button)
          f = @fields[@index]
          if enter and (!f.key_processed(:enter) || $keyr[0x10])
            @accept_button.press
          end
        end
        @timers.each { |timer| timer.update }
      end

      def add_timer(timer, start = true)
        @timers.push(timer) if timer.is_a?(FormTimer)
      end

      def delete_timer(timer)
        @timers.delete(timer)
      end

      def append(field)
        @fields.push(field)
        return field
      end

      def insert(index, field)
        @fields.insert(index, field)
      end

      def insert_before(sfield, field)
        f = @fields.index(sfield) || -1
        @fields.insert(f, field)
      end

      def insert_after(sfield, field)
        f = @fields.index(sfield) || -2
        @fields.insert(f + 1, field)
      end

      def index=(ind)
        ind = @fields.find_index(ind) if ind.is_a?(FormBase)
        return if !ind.is_a?(Integer)
        if @fields[@index].is_a?(FormBase)
          @fields[@index].blur
          @fields[@index].trigger(:blur)
        end
        @index = ind
        if @fields[@index].is_a?(FormBase)
          @fields[@index].blur
          @fields[@index].trigger(:blur)
        end
      end

      def show_all
        @hidden = []
      end

      def hide(index)
        index = @fields.find_index(index) if index.is_a?(FormBase)
        return if !index.is_a?(Integer)
        @hidden[index] = true
      end

      def show(index)
        index = @fields.find_index(index) if index.is_a?(FormBase)
        return if !index.is_a?(Integer)
        @hidden[index] = false
      end

      def focus(index = nil, count = nil)
        if @fields[@index] != nil
          @fields[@index].trigger(:before_focus)
          @fields[@index].focus(@index, @fields.size)
          @fields[@index].trigger(:focus)
        end
      end

      def key_processed(k)
        if k == :tab
          return true
        elsif @fields[@index] != nil
          return @fields[@index].key_processed(k)
        else
          return false
        end
      end
    end

    # Reads a text from user and returns it
    #
    # @param header [String] a window caption
    # @param type [String] the window type
    #  @see Edit
    # @param text [String] an initial text
    def input_text(header = "", flags = 0, text = "", escapable = false, permitted_characters = [], denied_characters = [], max_length = 0, moveToEnd = false, selectAll = false)
      if flags.is_a?(String)
        Log.warning("String flags are no longer supported: " + Kernel.caller.join(" "))
        flags = 0
      end
      ro = (flags & EditBox::Flags::ReadOnly) > 0
      ro = (flags & EditBox::Flags::ReadOnly) > 0
      ml = (flags & EditBox::Flags::MultiLine) > 0
      ae = escapable
      dialog_open
      inp = EditBox.new(header, flags, text, false)
      inp.max_length = max_length if max_length > 0
      if moveToEnd
        inp.index = inp.check = text.size
      end
      permitted_characters.each { |c| inp.permitted_characters.push(c) }
      denied_characters.each { |c| inp.denied_characters.push(c) }
      inp.select_all if selectAll
      inp.focus
      loop do
        loop_update
        inp.update
        rtmp = false
        rtmp = true if ml == false or $key[0x11] == true
        break if enter and rtmp == true
        if (ro == true or (type.is_a?(Numeric) and (type & EditBox::Flags::ReadOnly) > 0)) and (escape or alt or enter)
          r = ""
          r = nil if alt
          r = nil if $key[0x09] == true and $key[0x10] == false
          r = nil if $key[0x09] == true and $key[0x10] == true
          r = nil if escape
          dialog_close
          return r
          break
        end
        if escape and ae == true
          dialog_close
          return nil
          break
        end
      end
      r = inp.text
      dialog_close
      loop_update
      return r
    end

    def input_user(header = "", escapable = true)
      edt = EditBox.new(header, 0, "", true)
      edt.add_tip(p_("EAPI_Form", "Press up or down arrow to select contact"))
      edt.bind_context { |menu|
        menu.option(p_("EAPI_Form", "Select contact")) {
          s = selectcontact
          edt.set_text(s) if s != nil && s != ""
          edt.focus
        }
      }
      edt.focus
      loop do
        loop_update
        edt.update
        return nil if escape and escapable
        if arrow_up || arrow_down
          s = selectcontact
          edt.set_text(s) if s != nil && s != ""
          edt.focus
        end
        if enter
          usr = edt.text
          usr = finduser(usr) if usr.downcase == finduser(usr).downcase
          if user_exists(usr)
            return usr
          else
            alert(p_("EAPI_Form", "User does not exist"))
          end
        end
      end
    end

    class FormField < FormBase
      def focus(index = nil, count = nil)
      end

      def subindex
        return 0
      end

      def maxsubindex
        return 0
      end

      def update(*arg)
        super
        if $focus == true
          $focus = false
          focus
        end
      end
    end

    class EditBox < FormField
      @@customactions = []
      @@lastedits = []
      attr_accessor :index
      attr_accessor :flags
      attr_reader :origtext
      attr_accessor :silent
      attr_accessor :audiotext
      attr_accessor :check
      attr_accessor :max_length
      attr_accessor :header
      attr_accessor :audiostream
      attr_reader :permitted_characters, :denied_characters

      def initialize(header = "", type = 0, text = "", quiet = true, init = false, silent = false, max_length = -1)
        if type.is_a?(String)
          Log.warning("Text flags are no longer supported: " + Kernel.caller.join(" "))
        end
        @header = header
        @flags = 0
        @flags = type if type.is_a?(Integer)
        @silent = silent
        @max_length = max_length
        set_text(text)
        @origtext = text
        @index = @check = 0
        @sounds = []
        @redo = []
        @undo = []
        @formats = []
        @@lastedits.push(self) if (@flags & Flags::MultiLine) > 0 && (@flags & Flags::ReadOnly) == 0
        @@lastedits.delete_at(0) while @@lastedits.size > 20
        @permitted_characters = []
        @denied_characters = []
        focus if quiet == false
      end

      def update
        super
        focus if @audioplayer == nil and @audiotext != "" and @audiotext != nil
        if @selected == true
          play("editbox_textselected")
          @selected = false
        end
        oldindex = @index
        oldtext = @text if @audioplayer != nil and escape
        if @audioplayer != nil and escape
          blur
        elsif @audioplayer != nil and @audioplayed == false
          if Configuration.voice == "NVDA" or !speech_actived
            if Configuration.autoplay == 0 || (Configuration.autoplay == 1 && (@flags & Flags::Transcripted) == 0)
              Programs.emit_event(:player_play)
              @audioplayer.play
              @audioplayed = true
            end
          end
        end
        if @audioplayer != nil && @audioplayer.pause == false && @audioplayer.completed == false
          @audioplayer.update
          return
        elsif @audioplayer != nil && $key[0x20]
          @audioplayer.play
          return
        end
        navupdate
        editupdate
        ctrlupdate
        if oldindex != @index or oldtext != @text
          NVDA.braille(@text, @index, false, 0, nil, @index) if NVDA.check
        end
        esay
      end

      def editupdate
        return readupdate if (@flags & Flags::ReadOnly) != 0
        if (c = getkeychar) != "" and (c.to_i.to_s == c or (@flags & Flags::Numbers) == 0) and (@flags & Flags::ReadOnly) == 0
          speech_stop if Configuration.typingecho > 0 and !(Configuration.voice == "NVDA" and NVDA.check)
          einsert(c)
          if ((wordendings = " ,./;'\\\[\]-=<>?:\"|\{\}_+`!@\#$%^&*()_+").include?(c)) and ((Configuration.typingecho == 1 or Configuration.typingecho == 2))
            s = @text[(@index > 50 ? @index - 50 : 0)...@index]
            w = (s[(0...s.length).find_all { |i| wordendings.include?(s[i..i]) or s[i..i] == "\n" }.sort[-2] || 0..(s.size - 1)])
            if (w =~ /([a-zA-Z0-9ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]+)/) != nil
              espeech(w)
              play("editbox_space") if c == " "
            else
              espeech(c) if @interface_typingecho != 1
            end
          elsif Configuration.typingecho == 0 or Configuration.typingecho == 2
            espeech(c)
          end
        elsif c != ""
          play("border") if c != " "
        end
        if enter
          speech_stop
          if (@flags & Flags::MultiLine) > 0 and $key[0x11] == false and (@flags & Flags::ReadOnly) == 0
            einsert("\n")
            play("editbox_endofline")
          elsif ((@flags & Flags::MultiLine) == 0 or $key[0x11]) and (@flags & Flags::ReadOnly) == 0
            play("listbox_select")
            trigger(:select, @index)
          end
        end
        if $key[0x2e] and (@index < @text.size or @check < @text.size) and (@flags & Flags::ReadOnly) == 0
          play("editbox_delete")
          c = [@index, @check].sort
          c[0] = char_borders(c[0])[0]
          c[1] = char_borders(c[1])[1]
          edelete(c[0], c[1])
          espeech(@text[@index..@index + 1].split("")[0])
        end
        if $key[0x08] and (@index > 0 or @check > 0) and (@flags & Flags::ReadOnly) == 0
          if $keyr[0x11] && @index == @check && @index > 0
            from = @index - 1
            to = @index - 1
            from -= 1 while from > 0 && (@text[from..from] == "\n" || @text[from..from] == " ")
            from -= 1 while @text[from - 1..from - 1] != " " && @text[from - 1..from - 1] != "\n" && from > 0
            if from <= to
              espeech(@text[from..to])
              edelete(from, to)
              play("editbox_delete")
            end
          else
            play("editbox_delete")
            c = []
            if @index != @check
              c = [@index, @check].sort
              c[0] = char_borders(c[0])[0]
              c[1] = char_borders(c[1])[1]
            else
              oind = ind = @index - 1
              ind = char_borders(ind)[0]
              c = [ind, oind]
            end
            espeech(@text[c[0]..c[1]].split("")[0])
            edelete(c[0], c[1])
          end
        end
      end

      def readupdate
        if enter
          url = nil
          @elements.each { |e| url = e.param[1] if (e.from <= @index and e.to >= @index) and (e.type == Element::Link || e.type == Element::Frame) }
          @elements.each { |e| url = e.param[1] if (e.from >= line_beginning and e.to <= line_ending) and (e.type == Element::Link || e.type == Element::Frame) } if url == nil
          if url != nil
            speak(p_("EAPI_Form", "Opening a link..."))
            process_url(url)
            loop_update
          end
        end
        if $keyr[0x10] && $keyr[0x11]
          if getkeychar == "c"
            copy
          elsif getkeychar == "x"
            cut
          elsif getkeychar == "v"
            paste
          end
        end
        e = nil
        if $key[72]
          e = find_element(Element::Header, nil, $keyr[0x10], @index)
        elsif $key[0x31..0x36].include?(true)
          k = 1
          (1..6).each { |i| k = i if $key[0x30 + i] }
          e = find_element(Element::Header, k, $keyr[0x10], @index)
        elsif $key[75]
          e = find_element([Element::Link, Element::Frame], nil, $keyr[0x10], @index)
        elsif $key[73]
          e = find_element(Element::ListItem, nil, $keyr[0x10], @index)
        end
        if e != nil
          @index = e.from
          espeech(@text[e.from..e.to])
        elsif getkeychar != ""
          play("border")
        end
      end

      def navupdate
        @vindex = $key[0x10] ? @check : @index
        prvindex = @vindex
        last = @vindex
        @ch = false
        if arrow_right
          @vindex = char_borders(@vindex)[1]
          if @vindex >= @text.size
            if Configuration.soundthemeactivation == 1
              play("border")
            else
              espeech(p_("EAPI_Form", "End of line"))
            end
          elsif @vindex == @text.size - 1
            @vindex = @text.size
            if Configuration.soundthemeactivation == 1
              play("editbox_endofline")
            else
              espeech(p_("EAPI_Form", "End of line"))
            end
          else
            if $key[0x11] == false
              ind = char_borders(@vindex)[1] + 1
              oi = ind
              e = char_borders(ind)[1]
              espeech(@text[oi..e])
              @vindex = oi
            else
              @vindex = ((@vindex + ($key[0x10] ? ((@vindex >= (@text.size - 1)) ? 1 : 2) : 1)...(@vindex < @text.size - 100 ? @vindex + 100 : @text.length)).find_all { |i| @text[i..i] == " " or @text[i..i] == "\n" }.sort[0] || @text.size - 1)
              @vindex += ($key[0x10] ? ((@vindex >= @text.size - 1) ? 0 : -1) : 1)
              (@vindex == @text.size) ? play("editbox_endofline") : espeech(@text[($key[0x10] ? ((0..@vindex).find_all { |i| @text[i..i] == " " or @text[i..i] == "\n" }.sort.last || 0) : @vindex)..(@vindex + 1..@text.length).find_all { |i| @text[i..i] == " " or @text[i..i] == "\n" }.sort[0] || @text.size - 1])
            end
          end
        elsif arrow_left
          if @vindex <= 0
            if Configuration.soundthemeactivation == 1
              play("border")
            else
              if @text.size > 0
                c = char_borders(0)
                espeech(@text[c[0]..c[1]])
              else
                espeech(p_("EAPI_Form", "End of line"))
              end
            end
          else
            if $key[0x11] == false
              ind = @vindex - 1
              ind = char_borders(ind)[0]
              espeech(@text[ind..@vindex - 1])
              @vindex = ind
            else
              @vindex = @index = (char_borders(char_borders(@index)[0] - 1)[1]) if @index > 0 && char_borders(@index)[0] > 0 && @index == @check && $keyr[0x10]
              @vindex = ((((@vindex > 100) ? (@vindex - 100) : 0)...@vindex - 1).find_all { |i| @text[i..i] == " " or @text[i..i] == "\n" }.sort.last || -1) + 1
              espeech(@text[@vindex..(@vindex + 1...@text.length).find_all { |i| @text[i..i] == " " or @text[i..i] == "\n" }.sort[0] || @text.size - 1])
            end
          end
        elsif arrow_up and !$keyr[0x2d]
          b = line_beginning
          e = line_ending
          if b == 0
            play("border")
            espeech(e > 0 ? (@text[0..e - 1]) : "")
          else
            l = @vindex - b
            em = line_ending(b - 1)
            bm = line_beginning(b - 1)
            l = em - bm if em - bm < l
            l = 0 if e - b <= 1
            l = line_ending(bm - 1) - bm - 1 if $keyr[0x10]
            @vindex = bm + l
            espeech(em > 0 ? (@text[bm..em - 1]) : "")
          end
        elsif arrow_down and !$keyr[0x2D]
          b = line_beginning
          e = line_ending
          if e == @text.size
            play("border")
            espeech(@text[b..e - 1])
          else
            l = @vindex - b
            ep = line_ending(e + 1)
            bp = line_beginning(e + 1)
            l = ep - bp if ep - bp < l
            l = 0 if e - b <= 1
            l = line_ending(@vindex + 1) - bp if $keyr[0x10]
            @vindex = bp + l
            espeech(@text[bp..ep - 1])
          end
        end
        if $key[0x24] && !$keyr[0x5B] && !$keyr[0x5C]
          @index = char_borders(char_borders(@index)[0] - 1)[0] if @index == @check && @index > 0 && char_borders(@index)[0] > 0 && $keyr[0x10]
          @ch = @vindex = $key[0x11] ? 0 : line_beginning
          espeech($key[0x11] ? @text[line_beginning..line_ending] : @text[@vindex..@text.size - 1].split("")[0]) if @vindex < @text.size
        elsif $key[0x23] && !$keyr[0x5B] && !$keyr[0x5C]
          if !$keyr[0x10]
            @ch = @vindex = $key[0x11] ? (@text.size) : line_ending
            espeech($key[0x11] ? @text[line_beginning..line_ending] : (((t = @text[line_ending..line_ending]) == "") ? "\n" : t))
          else
            @ch = @vindex = ($key[0x11] ? (@text.size) : line_ending(@vindex + 1)) - 1
            espeech($key[0x11] ? @text[line_beginning..line_ending] : (((t = @text[line_ending..line_ending]) == "") ? "\n" : t))
          end
        end
        if $key[0x21] && !$keyr[0x5B] && !$keyr[0x5C]
          if line_beginning == 0
            play("border")
            espeech(@text[0..line_ending - 1])
          else
            lines = get_lines
            curline = curlineind = 0
            for i in 0..lines.size - 1
              l = lines[i]
              if l <= @vindex
                curline = l
                curlineind = i
              end
            end
            inlineindex = @vindex - curline
            if curlineind < 15
              @vindex = inlineindex
            else
              inlineindex = lines[curlineind - 14] - lines[curlineind - 15] if inlineindex > lines[curlineind - 14] - lines[curlineind - 15]
              @vindex = lines[curlineind - 15] + inlineindex
            end
            espeech(@text[line_beginning..line_ending - 1])
          end
        elsif $key[0x22] && !$keyr[0x5B] && !$keyr[0x5C]
          if line_ending == @text.size
            play("border")
            espeech(@text[line_beginning..line_ending - 1])
          else
            lines = get_lines
            curline = curlineind = 0
            for i in 0..lines.size - 1
              l = lines[i]
              if l <= @vindex
                curline = l
                curlineind = i
              end
            end
            inlineindex = @vindex - curline
            if curlineind > lines.size - 17
              @vindex = lines[-1] + inlineindex
              @vindex = @text.size if @vindex > @text.size
            else
              inlineindex = lines[curlineind + 16] - lines[curlineind + 15] if inlineindex > lines[curlineind + 16] - lines[curlineind + 15]
              @vindex = lines[curlineind + 15] + inlineindex
            end
            espeech(@text[line_beginning..line_ending - 1])
          end
        end
        lastcheck = get_check(true)
        checked = false
        if $key[0x10] == false and (@index != @vindex or @ch != false)
          checked = true if @check != @index
          @check = @index = @vindex
        elsif ($key[0x10] == true and @check != @vindex) or ($key[0x11] and $key[65] and !$key[0x12])
          checked = true
          if $key[0x11] and $key[65] and !$key[0x12]
            @index = 0
            @check = @text.size
          else
            @check = @vindex
          end
        end
        if (lastcheck != "" || checked) && lastcheck != get_check
          if @index != @check
            chk = get_check
            if chk.include?(lastcheck)
              play("editbox_textselected")
              if chk[0...lastcheck.size] == lastcheck
                chk[0...lastcheck.size] = ""
              elsif chk[-1 * lastcheck.size..-1] == lastcheck
                chk[-1 * lastcheck.size..-1] = ""
              end
            elsif lastcheck.include?(chk)
              play("editbox_textunselected")
              if lastcheck[0...chk.size] == chk
                chk = lastcheck[chk.size..-1]
              elsif lastcheck[-1 * chk.size..-1] == chk
                chk = lastcheck[0...-chk.size]
              end
            else
              play("editbox_textselected")
            end
            @tosay = chk
          end
        end
        if last != @vindex
          for e in @elements
            if last < e.from || last > e.to
              if @vindex >= e.from && @vindex <= e.to
                d = e.description
                @tosay = d + ": " + @tosay
              end
            end
          end
        end
        esay
      end

      def ctrlupdate
        read_text(@index) if @index < @text.size and ((($keyr[0x2d] and arrow_down))) and (@audiotext == nil or @index > 0)
        espeech(@text[line_beginning..line_ending]) if $keyr[0x2d] and arrow_up
        esay
      end

      def clear_sounds
        @sounds.clear
      end

      def add_sound(snd)
        @sounds.push(snd)
      end

      def select_all
        return if @text.size == 0
        @index = 0
        @check = @text.size
        @selected = true
      end

      def setformatting(type, params = nil)
        c = [@index, @check].sort
        from = char_borders(c[0])[0]
        to = char_borders(c[1])[1]
        if to > from
          s = false
          for e in @elements
            next if e.type != type
            s = true if e.from >= from && e.from <= to
            s = true if e.to >= from && e.to <= to
            s = true if e.from < from && e.to > to
          end
          if s == true
            del = []
            ins = []
            for e in @elements
              next if e.type != type
              if e.from >= from && e.to <= to
                del.push(e)
              elsif e.from < from && e.to > from
                if e.to < to
                  e.to = from - 1
                else
                  el = Element.new(to + 1, e.to, type)
                  del.push(e)
                  ins.push(el)
                  e.to = from - 1
                end
              elsif e.from < to && e.to > to
                if e.from > from
                  e.from = to + 1
                else
                  el = Element.new(e.from, from - 1, type)
                  ins.push(el)
                  e.from = to + 1
                end
              end
            end
            del.each { |e| @elements.delete(e) }
            ins.each { |el| @elements.push(el) }
            play("editbox_delete")
          else
            el = Element.new(from, to, type)
            @elements.push(el)
            play("editbox_bigletter")
          end
        else
          if @formats.include?(type)
            @formats.delete(type)
            play("editbox_delete")
          else
            @formats.push(type)
            espeech(Element.description(type))
          end
        end
      end

      def context(menu, submenu = false)
        c = Proc.new { |menu|
          if (@flags & Flags::Formattable) > 0
            menu.submenu(p_("EAPI_Form", "Format")) { |m|
              m.option(p_("EAPI_Form", "Bold"), nil, "b") {
                if requires_premiumpackage("scribe")
                  setformatting(Element::Bold)
                end
              }
              m.option(p_("EAPI_Form", "Italic"), nil, "i") {
                if requires_premiumpackage("scribe")
                  setformatting(Element::Italic)
                end
              }
              m.option(p_("EAPI_Form", "Underline"), nil, "u") {
                if requires_premiumpackage("scribe")
                  setformatting(Element::Underline)
                end
              }
              m.submenu(p_("EAPI_Form", "Heading")) { |n|
                for i in 1..6
                  n.option(p_("EAPI_Form", "Heading level %{level}") % { "level" => i }, i, i.to_s) { |level|
                    if requires_premiumpackage("scribe")
                      a = line_beginning(@vindex, true)
                      b = line_ending(@vindex, true)
                      del = []
                      s = false
                      for e in @elements
                        if e.type == Element::Header && ((e.from >= a && e.from <= b) || (e.to >= a && e.to <= b))
                          s = true if e.param == level
                          del.push(e)
                        end
                      end
                      del.each { |e| @elements.delete(e) }
                      if s == false
                        el = Element.new(a, b, Element::Header, level)
                        @elements.push(el)
                        play("editbox_bigletter")
                      elsif s == true
                        play("editbox_delete")
                      end
                    end
                  }
                end
              }
            }
            menu.submenu(p_("EAPI_Form", "Insert")) { |m|
              m.option(p_("EAPI_Form", "Link")) {
                if requires_premiumpackage("scribe")
                  form = Form.new([
                    EditBox.new(p_("EAPI_Form", "URL"), 0, "", true),
                    EditBox.new(p_("EAPI_Form", "Label"), 0, "", true),
                    Button.new(p_("EAPI_Form", "Add")),
                    Button.new(_("Cancel"))
                  ])
                  loop do
                    loop_update
                    form.update
                    break if escape or form.fields[3].pressed?
                    if form.fields[2].pressed?
                      url = form.fields[0].text
                      label = form.fields[1].text
                      ind = @index
                      einsert(label)
                      el = Element.new(ind, ind + label.size - 1, Element::Link, url)
                      @elements.push(el)
                      break
                    end
                  end
                  loop_update
                  speak(@text[line_beginning..line_ending])
                end
              }
            }
          end
          menu.option(p_("EAPI_Form", "Read from cursor"), nil, "A") {
            read_text(@index) if @index < @text.size
          }
          menu.option(p_("EAPI_Form", "Read line"), nil, "L") {
            espeech(@text[line_beginning..line_ending])
          }
          menu.option(p_("EAPI_Form", "Copy"), nil, "c") {
            copy
          }
          if (@flags & Flags::ReadOnly) == 0
            menu.option(p_("EAPI_Form", "Cut"), nil, "x") {
              cut
            }
            menu.option(p_("EAPI_Form", "Paste"), nil, "v") {
              paste
            }
            menu.option(p_("EAPI_Form", "Undo"), nil, "z") {
              eundo
            }
            menu.option(p_("EAPI_Form", "Redo"), nil, "y") {
              eredo
            }
            menu.option(p_("EAPI_Form", "Spell check"), nil, "S") {
              if requires_premiumpackage("scribe")
                espellcheck
              end
            }
            menu.submenu(p_("EAPI_Form", "Load last text")) { |m|
              for e in @@lastedits
                next if e == self
                t = (e.header + ": " + e.text)[0...200]
                m.option(t, e) { |e|
                  @@lastedits.push(self.deep_dup) if @text != ""
                  set_text(e.text)
                }
              end
            }
          end
          menu.option(p_("EAPI_Form", "Find"), nil, "f") {
            search
          }
          menu.option(p_("EAPI_Form", "Quick translation"), nil, "t") {
            if requires_premiumpackage("scribe")
              espeech(translatetext(0, Configuration.language, get_check_or_all))
            end
          }
          menu.option(p_("EAPI_Form", "Translate"), nil, "T") {
            if requires_premiumpackage("scribe")
              translator(get_check_or_all)
            end
          }
          for a in @@customactions
            menu.option(a[0]) {
              a[1].call(self)
            }
          end
        }
        s = @header + " - " + p_("EAPI_Form", "Edit box") + " (" + _("Context menu") + ")"
        s = p_("EAPI_Form", "Edit") if submenu == false
        menu.submenu(s) { |m| c.call(m) }
        super(menu, submenu)
      end

      def espellcheck
        sclangs = spellchecklanguages
        return if sclangs.size == 0
        langs = []
        langnames = []
        lnindex = 0
        for lk in Lists.langs.keys
          next if !sclangs.map { |l| l[0..1].downcase }.include?(lk[0..1].downcase)
          langs.push(lk)
          l = Lists.langs[lk]
          langnames.push(l["name"] + " (" + l["nativeName"] + ")")
          lnindex = langs.size - 1 if lk[0..1].downcase == Configuration.language[0..1].downcase
        end
        splt = @text + ""
        form = Form.new([
          lst_languages = ListBox.new(langnames, p_("EAPI_Form", "Language"), lnindex),
          btn_replace = Button.new(p_("EAPI_Form", "Replace")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        errors = []
        lst_languages.on(:move) {
          form.fields[1...-2] = nil
          errors = spellcheck(langs[lst_languages.index], @text)
          for error in errors
            phr = splt[error.index...(error.index + error.length)]
            frgb = -1
            frge = 0
            pfrgb = error.index - 60
            pfrgb = 0 if pfrgb < 0
            pfrge = error.index + error.length + 60
            pfrge = splt.size - 1 if pfrge >= splt.size
            for i in pfrgb..pfrge
              if i < error.index && frgb == -1
                frgb = i if splt[i - 1..i - 1] == " " || i == 0
              elsif i > error.index + error.length
                frge = i if splt[i + 1..i + 1] == " " || i + 1 == splt.size
              end
            end
            frg = splt[frgb..frge] || ""
            letphr = "(" + phr.split("").join(", ") + ")"
            options = []
            for sug in error.suggestions
              letsug = "(" + sug.split("").join(", ") + ")"
              opt = sug + " " + letsug
              options.push(opt)
            end
            label = phr + " " + letphr + ": " + frg
            lst = ListBox.new([p_("EAPI_Form", "Ignore")] + options + [p_("EAPI_Form", "Use custom text")], label)
            edt = EditBox.new(label, 0, phr)
            lst.on(:move) {
              for i in 0...errors.size
                l = form.fields[1 + i * 2]
                e = form.fields[1 + i * 2 + 1]
                if l.index < l.options.size - 1
                  form.hide(e)
                else
                  form.show(e)
                end
              end
            }
            form.insert_before(btn_replace, lst)
            form.insert_before(btn_replace, edt)
            form.hide(edt)
          end
        }
        lst_languages.trigger(:move)
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        btn_replace.on(:press) {
          chindex = 0
          repls = 0
          for i in 0...errors.size
            if form.fields[1 + i * 2].index > 0
              corr = ""
              if form.fields[1 + i * 2].index < form.fields[1 + i * 2].options.size - 1
                corr = errors[i].suggestions[form.fields[1 + i * 2].index - 1]
              else
                corr = form.fields[1 + i * 2 + 1].text
              end
              csize = corr.size
              splt[(errors[i].index + chindex)...(errors[i].index + errors[i].length + chindex)] = corr
              chindex += csize - errors[i].length
              repls += 1
            end
          end
          set_text(splt)
          alert(np_("EAPI_Form", "%{count} word replaced", "%{count} words replaced", repls) % { "count" => repls.to_s })
          form.resume
        }
        form.accept_button = btn_replace
        form.wait
        focus
        loop_update
      end

      def copy
        Clipboard.text = get_check.gsub("\n", "\r\n")
        alert(p_("EAPI_Form", "copied"), false)
      end

      def cut
        Clipboard.text = get_check.gsub("\n", "\r\n")
        c = [@index, @check].sort
        edelete(c[0], c[1])
        alert(p_("EAPI_Form", "Cut out"), false)
      end

      def paste
        einsert(Clipboard.text.delete("\r"))
        alert(p_("EAPI_Form", "pasted"), false)
      end

      def eundo
        return if @undo.size == 0
        u = @undo.last
        @undo.delete_at(@undo.size - 1)
        u[0] == 1 ? edelete(u[1], u[1] + u[2].size, false) : einsert(u[2], u[1], false)
        @redo.push(u)
        alert(p_("EAPI_Form", "undone"), false)
      end

      def eredo
        return if @redo.size == 0
        r = @redo.last
        @redo.delete_at(@redo.size - 1)
        r[0] == 2 ? edelete(r[1], r[1] + r[2].size, false) : einsert(r[2], r[1], false)
        @undo.push(r)
        alert(p_("EAPI_Form", "Repeated"), false)
      end

      def search
        search = input_text(p_("EAPI_Form", "Enter a phrase to look for"), 0, @lastsearch || "", true, [], [], 0, false, true)
        if search != nil
          @lastsearch = search
          ind = @index < @text.size - 1 ? @text[@index + 1..@text.size - 1].downcase.index(search.downcase) : 0
          ind += @index + 1 if ind != nil
          ind = @text[0..@index].downcase.index(search.downcase) if ind == nil
          if ind == nil
            alert(p_("EAPI_Form", "No match found."), false)
          else
            @index = ind
            read_text(@index)
          end
        end
      end

      def line_beginning(index = @vindex, absolute = false)
        return 0 if index == 0
        return 0 if @text.size == 0
        l = ((((index > 3000 ? index - 3000 : 0)...index).find_all { |i| @text[i..i] == "\n" }[-1]) || -1) + 1
        r = ((index...(index < @text.size - 3000 ? @index + 3000 : @text.size)).find_all { |i| @text[i..i] == "\n" }[0]) || @text.size
        ls = get_vlines(l, r, absolute)
        ind = l
        for n in ls
          ind = n if n <= index
        end
        return ind
      end

      def line_ending(index = @vindex, absolute = false)
        return 0 if @text.size == 0
        l = ((((index > 3000 ? index - 3000 : 0)...index).find_all { |i| @text[i..i] == "\n" }[-1]) || -1) + 1
        r = ((index...(index < @text.size - 3000 ? @index + 3000 : @text.size)).find_all { |i| @text[i..i] == "\n" }[0]) || @text.size
        ls = get_vlines(l, r, absolute)
        ln = 0
        for i in 0...ls.size - 1
          ln = i if ls[i] <= index
        end
        ind = ls[ln + 1] - 1
        return ind
      end

      def char_borders(ind)
        left, right = ind, ind
        right += 1 while right < @text.size - 1 && (@text[right] || 0) >= 0xC0
        left -= 1 while left > 0 && (@text[left - 1] || 0) >= 0xC0
        return [left, right]
      end

      def get_vlines(l, r, absolute = false)
        return [l, r + 1] if r - l < 120 or (@flags & Flags::MultiLine) == 0 or (@flags & Flags::DisableLineWrapping) > 0 or Configuration.linewrapping == 0 or absolute == true
        ls = [l]
        for c in l...r
          if @text[c..c] == " " and c - ls[-1] > 120 and c != r - 1
            for oc in c..r
              if @text[oc..oc] != " "
                ls.push(oc)
                break if oc >= r
                break
              end
            end
          end
        end
        ls.delete_at(-1) if ls[-1] >= r
        ls.push(r + 1) if ls[-1] != r + 1
        return ls
      end

      def get_lines
        ns = (0...@text.size).find_all { |c| @text[c..c] == "\n" }
        ns.push(@text.size - 1)
        lines = []
        for i in 0..ns.size - 1
          prior = -1
          prior = ns[i - 1] if i > 0
          lines += get_vlines(prior + 1, ns[i])
          lines.delete_at(-1)
        end
        return lines
      end

      def get_check(checkOnly = false)
        return @text if @index == @check && !checkOnly
        return "" if @index == @check && checkOnly
        st = [@index, @check].sort
        from = st[0]
        to = st[1]
        to = char_borders(to)[1]
        return @text[from..to]
      end

      def get_check_or_all
        c = get_check
        c = @text if c.split("").size <= 2
        return c
      end

      def einsert(text, index = @index, toundo = true)
        if @denied_characters.size > 0 && @denied_characters.include?(text.split(""))
          play("border")
          return
        end
        if @permitted_characters.size > 0
          for c in text.split("")
            if !@permitted_characters.include?(c)
              play("border")
              return
            end
          end
        end
        c = [@index, @check].sort
        from = char_borders(c[0])[0]
        to = char_borders(c[1])[1]
        edelete(from, to) if from < to && @text[from..to].chrsize > 1
        index -= 1 while index > @text.size
        text.delete!("\n") if (@flags & Flags::ReadOnly) != 0
        if (@flags & EditBox::Flags::Numbers) > 0
          text = text.to_i.to_s
          text = "" if text != "0" and text.to_i == 0
        end
        if @max_length >= 0 and @text.chrsize + text.chrsize > @max_length
          play("border")
          return
        end
        @undo.push([1, index, text]) if toundo == true
        @undo.delete_at(0) if @undo.size > 100
        @redo = [] if toundo == true
        applied = []
        for e in @elements
          i = @formats.find_index(e.type)
          if e.from <= @index && e.to >= @index && (text != "\n" || i != nil)
            play "signal"
            e.to += text.size
            applied[i] = true if i != nil
          elsif i != nil && applied[i] != true && e.to == @index - 1
            play "right"
            e.to += text.size
            applied[i] = true if i != nil
          elsif e.from > @index
            e.from += text.size
            e.to += text.size
          end
        end
        for i in 0...@formats.size
          if applied[i] != true
            e = Element.new(@index, @index, @formats[i])
            @elements.push(e)
          end
        end
        @text.insert(index, text)
        @index += text.size
        NVDA.braille(text, @index, true, 1, index, @index)
        @check = @index
        trigger(:insert, index, text)
        trigger(:change)
      end

      def edelete(from, to, toundo = true)
        @check = @index = from if @index > from
        @undo.push([2, from, @text[from..to]]) if toundo == true
        @redo = [] if toundo == true
        @undo.delete_at(0) if @undo.size > 100
        del = []
        for e in @elements
          if e.from <= from && e.to > to
            e.to -= (to - from + 1)
          elsif e.from >= from && e.to > to
            e.from += (to - from + 1)
          elsif e.from >= from && e.to <= to
            del.push(e)
          end
        end
        del.each { |e| @elements.delete(e) }
        c = (@text[from..to] || "").chrsize
        if c < 20
          c.times {
            NVDA.braille("", @index, true, -1, from, @index)
          }
        end
        begin
          @text[from..to] = ""
        rescue Exception
        end
        trigger(:delete, from, to)
        trigger(:change)
        @check = @index
      end

      def espeech(text)
        @tosay = text
      end

      def esay
        if @tosay != "" and @tosay != nil
          if (@flags & Flags::Password) == 0
            speech_stop
            speech(@tosay)
          else
            play("editbox_passwordchar")
          end
          @tosay = ""
        end
      end

      def audio?
        return @isaudio == true
      end

      def set_text(text, reset = true)
        @isaudio = false
        @text = text.delete("\r").gsub("\004LINE\004", "\n").gsub(/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/) do
          dialog_mute
          @isaudio = true
          @audiotext = $1
          ""
        end
        @text.gsub!(/\004ATTACH\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004ATTACH\004/, "")
        @text.chop! while @text[@text.size - 1..@text.size - 1] == "\n"
        @elements = []
        if (@flags & Flags::MarkDown) != 0
          @text.gsub!(/(^http(s?)\:\/\/([^\n]+)$)/) { "[#{$1}](#{$1})" }
          md_proceed
        elsif (@flags & Flags::HTML) != 0
          html_proceed
        else
          @text.indices(/http(s?)\:\/\/([^\"\<\>\: \n]+)/).each { |ind| @elements.push(Element.new(ind, ind + (@text[ind..-1].index(/[ \n]/) || @text.size) - 1, Element::Link, [0, @text[ind...ind + (@text[ind..-1].index(/[ \n]/) || @text.size - ind)]])) } if (@flags & Flags::ReadOnly) > 0
        end
        @index = 0 if reset == true
        @index = @text.size if @index > @text.size
      end

      alias settext set_text

      def md_proceed
        @elements = []
        ind = 0
        @text.gsub!(/(\[[^\]]+\])(\[[^\]]+\])/) do
          a = $1
          b = $2
          if ((/^[\t ]*#{Regexp.escape($2)}\:[\t ]*([^\n]+\n?)/) =~ @text) != nil
            a + "(#{$1})"
          else
            a + b
          end
        end
        @text.gsub!(/(^[\t ]*(\[[^\]]+\])\:[ %t]*([^\n]+)$)/) do
          if @text.indices($3).size > 1
            ""
          else
            $1
          end
        end
        @text.gsub!(/\[\:(\d+)\]/) { "[" + $1 + "]" }
        ind = 0
        while (m = @text[ind..-1].match(/(^[ \t]*([\#]+)[ \t]*([^\n]*)$)|(^([^\n]+)\n[ \t]*([\=\-]+)$)|(\[([^\]]+)\]\(([^[ \)]]+)([ ]*)((\"[^\"]*\")?)\))|(^([*-])([^\n]+)$)/)) != nil
          b = ind + m.begin(0)
          e = ind + m.end(0)
          if m.values_at(1)[0] != nil
            cnt = @text[b..e - 2].strip
            level = 0
            level = cnt.count("#")
            while " \t\#=-".include?(@text[b..b])
              @text[b..b] = ""
              e -= 1
            end
            @elements.push(Element.new(b, e - 1, Element::Header, level))
          elsif m.values_at(4)[0] != nil
            @text[m.begin(6)..m.end(6)] = ""
            e -= (m.values_at(6)[0].size + 1)
            level = 1
            level = 2 if m.values_at(6)[0..0] == "-"
            @elements.push(Element.new(b, e, Element::Header, level))
          elsif m.values_at(7)[0] != nil
            label = m.values_at(8)[0]
            url = m.values_at(9)[0]
            @text[b..e - 1] = label
            e = b + label.size
            @elements.push(Element.new(b, e - 1, Element::Link, [0, url]))
          elsif m.values_at(13) != nil
            @elements.push(Element.new(b, e, Element::ListItem))
          end
          ind = b + 1
        end
      end

      def html_proceed
        @markups = []
        suc = true
        index = 0
        while suc
          suc = false
          @text.sub!(/(\<[^\>]+\>)/) {
            phrase = $1
            d = @text.index(phrase)
            index = @text.index(phrase)
            opening = (phrase[1..1] != "/")
            sp = phrase.index(" ") || -1
            b = 1
            b = 2 if !opening
            tag = phrase[b...sp]
            attributes = {}
            if opening
              if sp != -1
                t = phrase[sp..-2]

                rx = /([a-zA-Z0-9]+)\=(([^ ^\>^\"^\']+)|("(\\.|[^"\\])*")|(\'[^\']+\'))/
                re = t.scan(rx)

                for e in re
                  k = e[0]
                  v = e[1]
                  v = v[1...-1] if v[0..0] == "'" || v[0..0] == "\""
                  v.gsub("\\\\", "\\")
                  attributes[k] = v
                end
              end
              @markups.push([index, tag, attributes]) if tag != "br"
            else
              mk = nil
              for m in @markups.reverse
                if m[1] == tag
                  mk = m
                  break
                end
              end
              if mk != nil
                @markups.delete(mk)
                @elements.push(Element.new(mk[0], index - 1, Element::HTML, [tag, mk[2]]))
              end
            end
            suc = true
            if opening && (tag == "br" || tag == "p")
              "\n"
            else
              ""
            end
          }
        end
        for k in HTML_PreCodes.keys
          while @text.include?(k)
            index = @text.index(k)
            v = HTML_PreCodes[k]
            @text.sub!(k, v)
            r = k.size - v.size
            for e in @elements
              e.from -= r if e.from > index
              e.to -= r if e.to > index
            end
          end
        end
        while (/(\&\#(\d+)\;)/ =~ @text) != nil
          k = $1
          index = @text.index(k)
          v = code_to_char($2.to_i)
          @text.sub!(k, v)
          r = k.size - v.size
          for e in @elements
            e.from -= r if e.from > index
            e.to -= r if e.to > index
          end
        end
        for i in 0...@elements.size
          e = @elements[i]
          if e.ignore?
            siz = e.to - e.from + 1
            @text[e.from..e.to] = ""
            for j in i + 1...@elements.size
              if @elements[j].from >= e.from
                @elements[j].from -= siz
              end
              if @elements[j].to >= e.from
                @elements[j].to -= siz
              end
            end
          end
        end
        for e in @elements.dup
          @elements.delete(e) if e.ignore?
        end
        for i in 0...@elements.size
          e = @elements[i]
          if e.type == Element::Frame
            siz = e.to - e.from + 1
            @text[e.from..e.to] = e.param[0]
            siz -= e.param[0].size
            e.to = e.from + e.param[0].size - 1
            for j in i + 1...@elements.size
              if @elements[j].from >= e.from
                @elements[j].from -= siz
              end
              if @elements[j].to >= e.from
                @elements[j].to -= siz
              end
            end
          end
        end
      end

      def find_element(type = 0, flags = nil, revdir = false, index = @index)
        e = Element.new(@text.size, -1, 0)
        for el in @elements
          e = el if (((!type.is_a?(Array) && el.type == type) || (type.is_a?(Array) && type.include?(el.type))) and (flags == nil or el.param == flags)) and (((revdir == false and el.from > index and el.from < e.from) or (revdir == true and el.to < index and el.to > e.to)))
        end
        return nil if e.type == 0
        return e
      end

      def finalize
        text_str
      end

      def text_str
        Log.warning("Method EditBox::text_str is deprecated and will be removed soon. Use EditBox::text or EditBox::text_html instead. Callback: " + Kernel.caller.join("   "))
        return @text.gsub("\n", "\004LINE\004")
      end

      def text
        return @text.gsub("\n", "\r\n")
      end

      def text_html
        r = ""
        objs = {}
        for e in @elements
          objs[e.from] ||= []
          objs[e.from].push(e.html_open)
          t = e.to
          t += 1 if @text[t..t] != "\n"
          objs[t] ||= []
          objs[t].insert(0, e.html_close)
        end
        l = 0
        for k in objs.keys.sort
          o = objs[k]
          r += html_encode(@text[l...k])
          for b in o
            r += b
          end
          l = k
        end
        r += html_encode(@text[l..-1] || "")
        return r
      end

      def value
        text
      end

      def focus(index = nil, count = nil, spk = true)
        pos = 50
        pos = index.to_f / (count - 1).to_f * 100.0 if index != nil and count != nil && count != 0
        if !audio?
          play("editbox_marker", 100, 100, pos) if spk && Configuration.controlspresentation != 2
        else
          play("editbox_audiomarker", 100, 100, pos) if spk && Configuration.controlspresentation != 2
        end
        if spk && @sounds != nil
          for snd in @sounds
            play(snd, 100, 100, pos)
          end
        end
        tp = p_("EAPI_Form", "Edit box")
        tp = p_("EAPI_Form", "Text") if (@flags & Flags::ReadOnly) > 0
        tp = p_("EAPI_Form", "Media") if @audiotext != nil
        tph = tp + ": "
        tph = "" if Configuration.controlspresentation == 1
        head = @header.to_s + "... " + tph
        NVDA.braille(@header.to_s + "\n" + @text, @header.to_s.size + 2 + @index - 1, false, 0, nil, @header.to_s.size + 2 + @index - 1) if NVDA.check
        if @audiotext != nil
          @audioplayer = Player.new(@audiotext, @header, false, true, nil, true) if @audioplayer == nil
          @audioplayed = false
        elsif @audiostream != nil
          @audioplayer = Player.new(nil, @header, false, true, @audiostream, true) if @audioplayer == nil
          @audioplayed = false
        end
        if audio? && (Configuration.autoplay == 0 || (Configuration.autoplay != 0 && (@flags & Flags::Transcripted) == 0))
          speak(head)
          return
        end
        #return speak(head + ((@audiotext!=nil)?"\004AUDIO\004#{@audiotext}\004AUDIO\004":"") + text.gsub("\n"," "),1,false) if @audiotext!=nil and @audiotext!="" and spk
        read_text(0, head) if spk
      end

      def audio?
        return @audiotext != nil || @audiostream != nil || @audioplayer != nil
      end

      def blur
        if @audioplayer != nil && !@audioplayer.pause
          @audioplayer.stop
        end
      end

      def audio_url
        @audiotext
      end

      def audio_url=(u)
        @audiotext = u
      end

      def read_text(index = 0, head = "")
        return speak(head) if @text == "" and head != "" and head != nil
        return if @text == ""

        ch = ["!", "?", ".", ","]

        breaks = [index] + (index + 1...@text.size - 1).find_all { |i| @text[i - 1..i - 1] == "\n" || (i > 1 && @text[i - 1..i - 1] == " " && ch.include?(@text[i - 2..i - 2])) } + [@text.size]
        commands = []
        for i in 1...breaks.size
          pos = breaks[i - 1]
          frg = @text[breaks[i - 1]...breaks[i]] || ""
          frg = head + "\n" + (frg || "") if head != nil && head != "" && i == 1
          cmd = SpeechCommands::CustomCommand.new(pos) { |pos| @index = pos if pos != 0 }
          commands.push(cmd)
          commands.push(frg)
        end
        cmd = SpeechCommands::CustomCommand.new { @index = @text.size }
        commands.push(cmd)

        seq = SpeechSequence.new(commands)
        seq.run
      end

      class Flags
        MultiLine = 1
        ReadOnly = 2
        Password = 4
        Numbers = 8
        DisableLineWrapping = 16
        MarkDown = 32
        HTML = 64
        Formattable = 128
        Transcripted = 256
      end

      class Element
        attr_accessor :from, :to, :type, :param
        Header = 1
        Link = 2
        List = 3
        ListItem = 4
        Quote = 5
        Bold = 11
        Italic = 12
        Underline = 13
        Frame = 14
        HTML = 99

        def initialize(from = 0, to = 0, type = 0, param = nil)
          @from, @to, @type, @param = from, to, type, param
          try_html if @type == HTML
        end

        def try_html
          return if !@param.is_a?(Array) || @param.size < 2
          tag = @param[0]
          if tag.size == 2 && tag[0..0] == "h" && tag[1..1].to_i > 0
            @type = Header
            @param = tag[1..1].to_i
            return
          end
          case tag
          when "b"
            @type = Bold
            @param = ""
          when "i"
            @type = Italic
            @param = ""
          when "u"
            @type = Underline
            @param = ""
          when "a"
            @type = Link
            @param = [0, @param[1]["href"]]
          when "ul"
            @type = List
            @param = 0
          when "ol"
            @type = Link
            @param = 1
          when "li"
            @type = ListItem
          when "iframe"
            @type = Frame
            src = @param[1]["src"]
            title = @param[1]["title"] || src
            @param = [title, src]
          end
        end

        def description
          self.class.description(@type, @param)
        end

        def html_open
          case @type
          when Bold
            return "<b>"
          when Italic
            return "<i>"
          when Underline
            return "<u>"
          when Header
            return "<h#{@param}>"
          when Link
            return "<a href=\"#{@param[1]}\">"
          when List
            return (@param == 0) ? ("<ul>") : ("<ol>")
          when ListItem
            return "<li>"
          when HTML
            s = "<#{@param[0]}"
            if @param[1].size > 0
              for k in @param[1].keys
                s += " " + k + "\"" + @param[1][k] + "\""
              end
            end
            s += ">"
            return s
          else
            return ""
          end
        end

        def html_close
          case @type
          when Bold
            return "</b>"
          when Italic
            return "</i>"
          when Underline
            return "</u>"
          when Header
            return "</h#{@param}>"
          when Link
            return "</a>"
          when List
            return (@param == 0) ? ("</ul>") : ("</ol>")
          when ListItem
            return "</li>"
          when HTML
            return "</#{@param[0]}>"
          else
            return ""
          end
        end

        def ignore?
          excl = ["script", "audio", "source"]
          return @type == HTML && excl.include?(@param[0])
        end

        def self.description(t, param = nil)
          case t
          when Bold
            return p_("EAPI_Form", "Bold")
          when Italic
            return p_("EAPI_Form", "Italic")
          when Underline
            return p_("EAPI_Form", "Underline")
          when Header
            return p_("EAPI_Form", "Heading level %{level}") % { "level" => param }
          when Link
            return p_("EAPI_Form", "Link")
          when List
            return p_("EAPI_Form", "List")
          when ListItem
            return p_("EAPI_Form", "List item")
          when Frame
            return p_("EAPI_Form", "Frame")
          else
            return ""
          end
        end
      end

      def key_processed(k)
        return false if k == :enter && ($keyr[0x11] || (@flags & Flags::MultiLine) == 0)
        return true
      end

      def self.add_customaction(name, cls, &b)
        @@customactions.push([name, b, cls]) if b != nil
      end
      def self.unregister_class(cls)
        for a in @@customactions.dup
          @@customactions.delete(a) if a[2] == cls
        end
      end

      def hascontext
        return true
      end

      def tips
        tips = []
        if (@flags & Flags::HTML) > 0 || (@flags & Flags::MarkDown) > 0
          tips.push(p_("EAPI_Form", "Use h or numbers from 1 to 6 to navigate to the next header"))
          tips.push(p_("EAPI_Form", "Use k to navigate to the next link"))
          tips.push(p_("EAPI_Form", "Use i to navigate to the next list item"))
          tips.push(p_("EAPI_Form", "Use the above shortcuts with shift to navigate to the previous items"))
        end
        return tips
      end
    end

    # A listbox class
    class ListBox < FormField
      # @return [Numeric] a listbox index
      attr_accessor :index
      # @return [Array] listbox options
      attr_reader :options
      attr_reader :grayed
      attr_reader :selected
      attr_accessor :silent
      attr_accessor :header
      attr_accessor :autosayoption
      attr_accessor :limit
      # Creates a listbox
      #
      class Flags
        MultiSelection = 1
        LeftRight = 2
        Silent = 4
        AnyDir = 8
        Circular = 16
        HotKeys = 32
        Tagged = 64
      end

      #
      # @param options [Array] an options list
      # @param header [String] a listbox caption
      # @param index [Numeric] an initial index
      # @param flags [Int] combination of flags
      # @param quiet [Boolean] don't read a caption at creation
      def initialize(options, header = "", index = 0, flags = 0, quiet = true)
        $lastkeychar = nil
        @border = true
        @border = false if Configuration.listtype == 1 or (flags & Flags::Circular) > 0
        @lr = ((flags & Flags::LeftRight) > 0)
        @multi = ((flags & Flags::MultiSelection) > 0)
        @silent = ((flags & Flags::Silent) > 0)
        @anydir = ((flags & Flags::AnyDir) > 0)
        @hk = ((flags & Flags::HotKeys) > 0)
        @tagged = ((flags & Flags::Tagged) > 0)
        @limit = -1
        options = options.deep_dup
        index = 0 if index == nil
        index = 0 if index >= options.size
        index += options.size if index < 0
        self.index = index
        self.options = (options)
        @selected = []
        for i in 0..@options.size - 1
          @grayed[i] = false if @grayed[i] != true
          @selected[i] = false
        end
        header = "" if header == nil
        @header = header
        @autosayoption = true
        focus if quiet == false
      end

      def options=(opts)
        if @options == nil
          @options = []
        else
          @options.clear
        end
        @grayed ||= []
        @hotkeys ||= {}
        @hotkeys.clear
        for i in 0..opts.size - 1
          gray = false
          if opts[i] != nil
            ind = nil
            if @hk
              ind = opts[i].to_s.index("\&")
              @hotkeys[opts[i].to_s[ind + 1..ind + 1].upcase[0]] = i if ind != nil && ind < opts[i].to_s.size - 1
            end
            opt = opts[i]
            opt = opt + "" if opt.is_a?(String)
            opt.delete!("&") if opt.is_a?(String) && ind != nil
          else
            opt = ""
            gray = true
          end
          @options.push(opt)
          @grayed[@options.size - 1] = true if gray
        end
      end

      def value
        self.index
      end

      # Update the listbox
      def update
        super
        if $keyr[0x11] && !$keyr[0x10]
          if arrow_up
            speak((@index + 1).to_s)
          elsif arrow_down
            speak(@options.size.to_s)
          end
        end
        oldindex = self.index
        options = @options
        if ((@lr and arrow_left) or (!@lr and arrow_up) or (@anydir and (arrow_left or arrow_up))) and !$keyr[0x10] and !$keyr[0x2D] and !$keyr[0x11]
          @run = true
          self.index -= 1
          while hidden?(self.index) == true && self.index >= 0
            self.index -= 1
          end
          if self.index < 0
            oldindex = -1 if @border == false
            if @border == false
              self.index = @options.size - 1
              while hidden?(self.index) == true
                self.index -= 1
              end
            else
              self.index = 0
              while hidden?(self.index) == true
                self.index += 1
              end
            end
          end
        elsif ((@lr and arrow_right) or (!@lr and arrow_down) or (@anydir and (arrow_right or arrow_down))) and !$keyr[0x10] and !$keyr[0x2D] and !$keyr[0x11]
          @run = true
          self.index += 1
          while hidden?(self.index) == true
            self.index += 1
          end
          if self.index >= options.size
            if @border == false
              oldindex = -1
              self.index = 0
              while hidden?(self.index) == true
                self.index += 1
              end
            else
              self.index = options.size - 1
              while hidden?(self.index) == true
                self.index -= 1
              end
            end
          end
        end
        lspeak(@options[@index].to_s) if $keyr[0x2D] and arrow_up
        if $keyr[0x10] and (arrow_up or arrow_down) and @tagged
          tgs = tags
          ind = (tgs.index(@tag) || -1) + 1
          if arrow_up
            ind -= 1
          elsif arrow_down
            ind += 1
          end
          ind = ind % (tgs.size + 1)
          if ind == 0
            self.tag = nil
            speak(p_("EAPI_Form", "All tags"))
          else
            self.tag = tgs[ind - 1]
            self.index += 1 while hidden?(self.index) and self.index < options.size - 1
            self.index -= 1 while hidden?(self.index) and self.index > 0
            o = options[self.index].to_s.gsub(/\[#{Regexp.escape(@tag)}\]/i, "")
            speak(@tag + ": " + o)
          end
        end
        if $key[0x23] == true && !$keyr[0x5B] && !$keyr[0x5C]
          @run = true
          self.index = options.size - 1
          while hidden?(self.index) == true
            self.index -= 1
          end
        end
        if $key[0x24] == true && !$keyr[0x5B] && !$keyr[0x5C]
          @run = true
          self.index = 0
          while hidden?(self.index) == true
            self.index += 1
          end
        end
        if $key[0x21] == true and @lr == false && !$keyr[0x5B] && !$keyr[0x5C]
          if self.index > 14
            for i in 1..15
              self.index -= 1
              while hidden?(self.index) == true and self.index > 15 - i
                self.index -= 1
              end
            end
          else
            self.index = 0
          end
          @run = true
          while hidden?(self.index) == true
            self.index += 1
          end
        end
        if $key[0x22] == true and @lr == false && !$keyr[0x5B] && !$keyr[0x5C]
          if self.index < (options.size - 15)
            for i in 1..15
              self.index += 1
              while hidden?(self.index) == true and self.index < @options.size - i
                self.index += 1
              end
            end
          else
            self.index = options.size - 1
          end
          @run = true
          while hidden?(self.index) == true and self.index < @options.size
            self.index += 1
          end
        end
        suc = false
        k = getkeychar
        if k != "" and k != " "
          k = @lastkey + k if @lastkey != nil and @lastkeytime > Time.now.to_f - 0.25 and k != @lastkey and @lr == false
          @lastkeytime = Time.now.to_f
          @lastkey = k
          i = k.upcase[0]
          if @hotkeys[i] == nil and @hotkeys.size <= @options.size / 2
            @run = true
            j = self.index
            l = k.chrsize == 1 ? 1 : 0
            m = false
            adr = 1
            kup = k.upcase
            adr = -1 if $keyr[0x10] && kup != kup.downcase
            j += adr * l
            loop do
              if j >= options.size || j <= -1
                if !m
                  j = ($keyr[0x10]) ? (options.size - 1) : (0)
                  m = true
                else
                  break
                end
              end
              if options[j] != nil && !hidden?(j) && options[j].to_s[0...kup.size].upcase == kup
                self.index = j
                break
              end
              j += adr
              break if j == self.index
            end
          elsif @hotkeys[i] != nil and !hidden?(@hotkeys[i])
            @index = @hotkeys[i]
            $enter = 2
          end
        end
        if enter
          play("listbox_select") if @silent == false
          trigger(:select, self.index)
        end
        if collapsed?
          trigger(:collapse, self.index)
        end
        if expanded?
          trigger(:expand, self.index)
          trigger(:selectexpand, self.index)
        end
        self.index = 0 if self.index >= options.size
        if self.index == -1
          while hidden?(self.index) == true
            self.index += 1
          end
        end
        if self.index >= @options.size
          while hidden?(self.index) == true
            self.index -= 1
          end
        end
        if @run == true
          speech_stop
          o = options[self.index].to_s
          for k in @hotkeys.keys
            ss = k if @hotkeys[k] == self.index
          end
          o += " (" + ASCII(ss) + ")" if ss.is_a?(Integer)
          o += "\r\n\r\n(#{p_("EAPI_Common", "Ticked")})" if @selected[self.index] == true
          o += "\r\n\r\n(#{p_("EAPI_Common", "Unticked")})" if @selected[self.index] == false && @multi == true
          o ||= ""
          o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
            o = ("\004NEW\004" + " " + ((Configuration.soundthemeactivation == 1) ? "" : $1 + " ") + o).gsub(/\004INFNEW\{([^\}]+)\}\004/, "")
          }
          o = o.gsub(/\[#{Regexp.escape(@tag)}\]/i, "") if @tag != nil
          lspeak(o) if !hidden?(self.index) && self.index >= 0 && @autosayoption != false
          play("listbox_statechecked", 100, 100, self.index.to_f / (options.size - 1).to_f * 100.0) if @selected[self.index] == true
          focus(nil, nil, @header, false)
        end
        k = k.to_s if k.is_a?(Integer)
        if oldindex != self.index
          self.index = 0 if options.size == 1 or options[self.index] == nil
          play("listbox_focus", 100, 100, self.index.to_f / (options.size - 1).to_f * 100.0) if @silent == false
          trigger(:move, self.index)
          @run = false
        elsif oldindex == self.index and @run == true and (k.chrsize <= 1 or (@options[self.index] != nil and @options[self.index][0...k.size].upcase != k.upcase))
          play("border", 100, 100, self.index.to_f / (options.size - 1).to_f * 100.0) if @silent == false
          trigger(:border, self.index)
          @run = false
        end
        if space and @multi == true
          trigger(:multiselection_beforechanged)
          if @selected[@index] == false
            if @limit <= 0 || @selected.count(true) < @limit
              @selected[@index] = true
              trigger(:multiselection_selected, @index)
              trigger(:multiselection_changed)
              play("listbox_statechecked", 100, 100, self.index.to_f / (options.size - 1).to_f * 100.0)
              alert(p_("EAPI_Form", "Checked"), false)
            else
              play("border")
              alert(np_("EAPI_Form", "You can heck only %{count} item", "You can check only %{count} items", @limit) % { "count" => @limit })
            end
          else
            @selected[@index] = false
            trigger(:multiselection_unselected, @index)
            trigger(:multiselection_changed)
            play("listbox_stateunchecked", 100, 100, self.index.to_f / (options.size - 1).to_f * 100.0)
            alert(p_("EAPI_Form", "Unchecked"), false)
          end
        end
      end

      def say_option
        lspeak(@options[self.index].to_s) if @options[self.index].is_a?(String) && !hidden?(self.index)
      end

      alias sayoption say_option

      def lpos
        pos = 50
        pos = self.index.to_f / (self.options.size - 1).to_f * 100.0 if self.options.size > 1
        return pos
      end

      def lspeak(text)
        speak(text, 1, true, nil, true, lpos)
      end

      def foplay(voice)
        eplay(voice, 100, 100, lpos)
      end

      def focus(index = nil, count = nil, header = @header, spk = true)
        pos = 50
        pos = index.to_f / (count - 1).to_f * 100.0 if index != nil and count != nil && count != 0
        if spk && Configuration.controlspresentation != 2
          if @multi == false
            play("listbox_marker", 100, 100, pos) if @silent == false
          else
            play("listbox_multimarker", 100, 100, pos)
          end
        end
        while hidden?(self.index) == true
          self.index += 1
        end
        if self.index > @options.size - 1
          while hidden?(self.index) == true
            self.index -= 1
          end
        end
        options = @options
        sp = ""
        if @header != nil and @header != ""
          sp = header
          sp += " (#{p_("EAPI_Form", "Multiselection list")})" if @multi == true and Configuration.controlspresentation != 1
          sp += ": " if !" .:?!,".include?(sp[-1..-1])
          sp += " " if sp[-1..-1] != " "
        end
        if options.size > 0
          o = options[self.index].to_s.delete("&")
          o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
            o = ("\004NEW\004" + " " + ((Configuration.soundthemeactivation == 1) ? "" : $1 + " ") + o).gsub(/\004INFNEW\{([^\}]+)\}\004/, "")
          }
          o += "\r\n\r\n(#{p_("EAPI_Common", "Checked")})" if @selected[self.index] == true
          o += "\r\n\r\n(#{p_("EAPI_Common", "Unchecked")})" if @selected[self.index] == false && @multi == true
          sp += o if !hidden?(self.index) && self.index >= 0
          ss = false
          for k in @hotkeys.keys
            ss = k if @hotkeys[k] == self.index
          end
          sp += " (" + ASCII(ss) + ")" if ss.is_a?(Integer)
        end
        sp += p_("EAPI_Form", "Empty list") if @options.size == 0
        lspeak(sp) if spk
        NVDA.braille(sp) if NVDA.check
      end

      # Hides a specified item
      #
      # @param id [Numeric] the id of an item to hide
      def disable_item(id)
        @grayed[id] = true
        options = @options
        while hidden?(self.index) == true
          self.index += 1
        end
        if self.index >= options.size
          oldindex = -1 if @border == false
          self.index = options.size - 1
          while hidden?(self.index) == true
            self.index -= 1
          end
          self.index = 0 if @border == false
        end
      end

      def enable_item(id)
        @grayed[id] = false
      end

      def hidden?(id)
        return false if id < 0 || id >= @options.size
        r = @grayed[id] == true
        r = true if @tag != nil and !@options[id].downcase.include?("[" + @tag_downcase + "]")
        return r
      end

      def tags
        tgs = []
        @options.each { |t|
          tgs += t.to_s.scan(/\[([^[\[\]]]+)\]/).map { |x| x[0].downcase }
        }
        tgs.delete(nil)
        return tgs.uniq
      end

      def tag=(t)
        @tag = t
        if t == nil
          @tag_downcase = t
        else
          @tag_downcase = t.downcase
        end
      end

      def tag
        @tag
      end

      def multiselections
        ar = []
        for i in 0...@options.size
          ar.push(i) if @selected[i]
        end
        return ar
      end

      def selected?
        return (enter && @options.size > 0 && self.index >= 0 && !hidden?(self.index))
      end

      def expanded?
        return !$keyr[0x10] && ((@lr && arrow_down) || (!@lr && arrow_right))
      end

      def collapsed?
        return !$keyr[0x10] && ((@lr && arrow_up) || (!@lr && arrow_left))
      end

      def key_processed(k)
        if (@lr == false and (k == :up || k == :down))
          return true
        elsif (@lr == true and (k == :left || k == :right))
          return true
        elsif k.to_s.size == 1
          return true
        elsif k == :home || k == :end || k == :pageup || k == :pagedown
          return true
        elsif @multi == true and k == :space
          return true
        else
          return false
        end
      end

      def tips
        tps = []
        if @multi
          tps.push(p_("EAPI_Form", "Use space to select or unselect items"))
        end
        if @tagged
          tps.push(p_("EAPI_Form", "Use shift with up/down arrows to filter content by tags"))
        end
        tps.push(p_("EAPI_Form", "Press CTRL + up arrow to read item index"))
        tps.push(p_("EAPI_Form", "Press CTRL + down arrow to read count of items"))
        return tps
      end
    end

    # A button class
    class Button < FormField
      # @return [String] the label of a button
      attr_accessor :label

      # Creates a button
      #
      # @param label [String] a button label
      def initialize(label = "")
        @label = label
        @pressed = false
      end

      # Updates a button
      def update
        super
        speech(@label) if $keyr[0x2D] and arrow_up
        @pressed = (enter || space)
        trigger(:press) if @pressed
      end

      def focus(index = nil, count = nil)
        pos = 50
        pos = index.to_f / (count - 1).to_f * 100.0 if index != nil and count != nil && count != 0
        play("button_marker", 100, 100, pos) if Configuration.controlspresentation != 2
        tph = "... " + p_("EAPI_Form", "Button")
        tph = "" if Configuration.controlspresentation == 1
        speak(@label + tph)
        NVDA.braille(@label) if NVDA.check
      end

      def pressed?
        pr = @pressed
        @pressed = false
        return pr
      end

      def press
        @pressed = true
        trigger(:press)
      end

      def key_processed(k)
        if k == :space || k == :enter
          return true
        else
          return false
        end
      end
    end

    # A checkbox class
    class CheckBox < FormField
      # @return [String] a checkbox label
      attr_accessor :label
      # @return [Numeric] 0 if non-checked, 1 if checked
      attr_accessor :checked

      # Creates a checkbox
      #
      # @param checked [Numeric] specifies the default state of a checkbox (0 - not checked, 1 - checked)
      # @param label [String] a checkbox label
      def initialize(label = "", checked = 0)
        @label = label
        @checked = checked.to_i
      end

      # Updates a checkbox
      def update
        super
        focus(nil, nil, true, false) if $keyr[0x2D] and arrow_up
        if space
          if @checked == 1
            @checked = 0
            alert(p_("EAPI_Form", "unchecked"), false)
          else
            @checked = 1
            alert(p_("EAPI_Form", "Checked"), false)
          end
          focus(nil, nil, false)
          trigger(:change)
        end
      end

      def value
        return @checked.to_i
      end

      def focus(index = nil, count = nil, spk = true, snd = true)
        pos = 50
        pos = index.to_f / (count - 1).to_f * 100.0 if index != nil and count != nil && count != 0
        play("checkbox_marker", 100, 100, pos) if spk and snd && Configuration.controlspresentation != 2
        text = @label + " ... "
        if Configuration.controlspresentation != 1
          text += p_("EAPI_Form", "Tickbox") + " "
        end
        if @checked == 0
          text += p_("EAPI_Form", "unticked")
        else
          text += p_("EAPI_Form", "ticked")
        end
        speech(text) if spk
        NVDA.braille(text)
      end

      def key_processed(k)
        if k == :space
          return true
        else
          return false
        end
      end
    end

    # Creates a files tree
    class FilesTree < FormField
      # @param header [String] a window caption
      attr_accessor :header
      # @return [String] selected file name
      attr_accessor :file
      attr_reader :cpath
      # @return [Array] file extensions to show
      attr_accessor :exts

      # Creates a files tree
      # @param header [String] a window caption
      # @param path [String] an initial path
      # @param hidefiles [Boolean] hide files
      # @param quiet [Boolean] don't write the caption at creation
      # @param file [String] a file to focus
      # @param exts [Array] an array of file extensions to show
      def initialize(header = "", path = "", hidefiles = false, quiet = true, file = nil, exts = nil, specialvoices = true)
        $filestrees ||= {}
        path += "\\" if path[-1..-1] != "\\" and path != ""
        @id = path + "/" + (file || "") + ":" + (exts.join("") || "") + ":::" + header
        @hidefiles = hidefiles
        @header = header
        @specialvoices = specialvoices
        @exts = exts
        @editmenus = []
        @filemenus = []
        @createmenus = []
        @menus = []
        if $filestrees[@id] != nil
          f = $filestrees[@id]
          @file = f[1]
          @path = f[0]
          #@file=nil if !FileTest.exists?(@path+"/"+@file)
        else
          @path = path
          @file = ""
          @file = file if file != nil
        end
        focus if quiet == false
      end

      # Updates a files tree
      def update(init = false)
        super
        if @sel == nil or @refresh == true
          if @path == ""
            buf = "\0" * 1024
            len = Win32API.new("kernel32", "GetLogicalDriveStrings", ["L", "P"], "L").call(buf.length, buf)
            @disks = buf.split("\0")
            for i in 0..@disks.size - 1
              @disks[i].chop! if @disks[i][-1..-1] == "\\"
            end
            @adds = [p_("EAPI_Form", "Desktop"), p_("EAPI_Form", "Documents"), p_("EAPI_Form", "Music")]
            @addfiles = [Dirs.desktop, Dirs.documents, Dirs.music]
            ind = @disks.find_index(@file)
            ind = 0 if ind == nil
            h = ""
            h = @header if init == true
            @sel = ListBox.new(@disks + @adds, h, ind, 0, false)
            @sel.on(:move) { |arg| trigger(:move, arg) }
            @sel.silent = true if @specialvoices
            @files = @disks + @addfiles
          else
            fls = Dir.entries(@path).polsort
            fls.delete("..")
            fls.delete(".")
            if @hidefiles == true
              for i in 0..fls.size - 1
                fls[i] = nil if File.file?(@path + fls[i])
              end
              fls.delete(nil)
            end
            if @exts != nil
              for i in 0..fls.size - 1
                if File.file?(@path + fls[i])
                  s = false
                  for e in @exts
                    s = true if File.extname(@path + fls[i]).downcase == e.downcase
                  end
                  fls[i] = nil if s == false
                end
              end
              fls.delete(nil)
            end
            dirs = []
            for i in 0..fls.size - 1
              if File.directory?(@path + fls[i])
                dirs.push(fls[i])
                fls[i] = nil
              end
            end
            fls.delete(nil)
            fls = dirs + fls
            ind = 0
            ind = @sel.index if @sel != nil
            ind -= 1 if ind > fls.size - 1
            ind = fls.find_index(@file, ind)
            h = ""
            h = @header if init == true
            @sel = ListBox.new(fls, h, ind)
            @sel.on(:move) { |arg| trigger(:move, arg) }
            @sel.silent = true if @specialvoices
            @sel.focus if @refresh != true
            @files = fls
            @refresh = false
          end
        end
        @sel.update
        @file = @files[@sel.index]
        @file = "" if @sel.options.size == 0
        if cfile != nil
          if @file != @lastfile and @specialvoices
            @lastfile = @file
            if filetype == 0
              play("file_dir", 100, 100, @sel.lpos)
            elsif filetype == 1
              play("file_audio", 100, 100, @sel.lpos)
            elsif filetype == 2
              play("file_text", 100, 100, @sel.lpos)
            elsif filetype == 3
              play("file_archive", 100, 100, @sel.lpos)
            elsif filetype == 4
              play("file_document", 100, 100, @sel.lpos)
            end
          end
        end
        if $key[0x10] == false
          if (arrow_right or @go == true) and File.directory?(cfile(true))
            @lastfile = nil
            @go = false
            s = true
            begin
              Dir.entries(cfile(true)) if s == true
            rescue Exception
              s = false
              retry
            end
            if s == true
              if @path != ""
                @path = cfile(true) + "\\"
              else
                @path = cfile(true) + "\\"
              end
              @file = ""
              @sel = nil
            end
          end
          if arrow_left and @path.size > 0
            t = @path.split("\\")
            @file = t.last
            t[t.size - 1] = ""
            @path = t.join("\\")
            @sel = nil
          end
        end
        $filestrees[@id] = [@path, @file]
      end

      def bind_editmenu(&m)
        @editmenus.push(m)
      end

      def bind_filesmenu(&m)
        @filemenus.push(m)
      end

      def bind_createmenu(&m)
        @createmenus.push(m)
      end

      def bind_menu(&m)
        @menus.push(m)
      end

      def context(menu, submenu = false)
        filepr = Proc.new { |menu|
          @filemenus.each { |f| f.call(menu) }
          menu.option(p_("EAPI_Form", "Rename")) {
            rename
          }
          menu.option(_("Delete"), nil, :del) {
            fdelete
          }
        }
        editpr = Proc.new { |menu|
          menu.option(p_("EAPI_Form", "Copy"), nil, "c") {
            copy
          }
          menu.option(p_("EAPI_Form", "Paste"), nil, "v") {
            paste
          }
          @editmenus.each { |f| f.call(menu) }
        }
        createpr = Proc.new { |menu|
          menu.option(p_("EAPI_Form", "New folder"), nil, "n") {
            name = ""
            while name == ""
              name = input_text(p_("EAPI_Form", "Folder name"), 0, "", true)
            end
            if name != nil
              Win32API.new("kernel32", "CreateDirectoryW", "pp", "i").call(unicode(self.path + name), nil)
              alert(p_("EAPI_Form", "The folder has been created."))
            end
            refresh
          }
          @createmenus.each { |f| f.call(menu) }
        }
        if submenu == false
          s = p_("EAPI_Form", "File")
          menu.submenu(s) { |m| filepr.call(m) }
          s = p_("EAPI_Form", "Edit")
          menu.submenu(s) { |m| editpr.call(m) }
          s = p_("EAPI_Form", "Create")
          menu.submenu(s) { |m| createpr.call(m) }
        else
          s = @header + " - " + p_("EAPI_Form", "Files Tree") + " (" + _("Context menu") + ")"
          menu.submenu(s) { |m|
            filepr.call(m)
            editpr.call(m)
            createpr.call(m)
          }
        end
        @menus.each { |m| m.call(menu) }
        super(menu, submenu)
      end

      def filetype
        return 0 if File.directory?(cfile(true))
        ext = File.extname(selected).downcase
        if ext == ".mp3" or ext == ".ogg" or ext == ".wav" or ext == ".mid" or ext == ".wma" or ext == ".flac" or ext == ".aac" or ext == ".opus" or ext == ".m4a" or ext == ".mov" or ext == ".mp4" or ext == ".avi" or ext == ".mts" or ext == ".aiff" or ext == ".m4v" or ext == ".mkv" or ext == ".vob" or ext == ".m2ts" or ext == ".w64"
          return 1
        elsif ext == ".txt"
          return 2
        elsif ext == ".rar" or ext == ".zip" or ext == ".7z"
          return 3
        elsif ext == ".doc" or ext == ".rtf" or ext == ".htm" or ext == ".html" or ext == ".docx" or ext == ".pdf" or ext == ".epub"
          return 4
        elsif ext == ".eapi"
          return 5
        else
          return -1
        end
      end

      # An opened path
      # @return [String] an opened path
      def path(c = false)
        return @path if c == false
        return @path
      end

      # Opens a specified path
      #
      # @param pt [String] a path to open
      def path=(pt)
        @path = pt
        @sel = nil
      end

      # Opens the focused path
      def go
        @go = true
        update
      end

      # Gets the current file
      # @return [String] current file
      def cfile(fulllocation = false)
        return "" if @file == nil
        tmp = @path + @file
        tmp.gsub!("/", "\\")
        if fulllocation == false
          return tmp.split("\\").last
        else
          return tmp
        end
      end

      # Refreshes the tree
      def refresh
        @refresh = true
      end

      # Returns the path to the selected file or directory
      #
      # @param c [Boolean] use diacretics shortening
      # @return [String] the absolute path to a focused file or directory
      def selected(c = false)
        return "" if @file == nil
        r = ""
        if c == false
          r = @path + @file
        else
          if cfile != nil
            r = @path + cfile
          else
            return ""
          end
        end
        return r
      end

      def focus(index = nil, count = nil)
        if @sel == nil
          loop_update
          update(true)
        else
          hin = ""
          hin = @header + ": \r\n" if @header != ""
          hin += @file
          speech(hin)
          NVDA.braille(hin) if NVDA.check
        end
      end

      def paste
        files = Clipboard.files
        return if files.size == 0
        waiting {
          for file in files
            src = file
            dst = @path + File.basename(file)
            if File.directory?(file)
              copydir(src, dst)
            else
              copyfile(src, dst)
            end
          end
        }
        alert(p_("EAPI_Form", "Pasted"), false)
        refresh
      end

      def copy
        Clipboard.files = [selected]
        alert(p_("EAPI_Form", "Copied"), false)
      end

      def rename
        name = ""
        while name == ""
          name = input_text(p_("EAPI_Form", "New file name"), 0, self.file, true)
        end
        if name != nil
          Win32API.new("kernel32", "MoveFileW", "pp", "i").call(unicode(self.selected), unicode(self.path + name))
          alert(p_("EAPI_Form", "The file name has been changed."))
        end
        refresh
      end

      def fdelete
        afile = self.selected
        confirm(p_("EAPI_Form", "Do you really want to delete %{filename}?") % { "filename" => self.file }) {
          if File.directory?(afile)
            deldir(afile)
          else
            File.delete(afile)
          end
          refresh
          alert(p_("EAPI_Form", "Deleted"))
        }
      end

      def key_processed(k)
        if @sel != nil
          return @sel.key_processed(k)
        else
          return false
        end
      end

      def hascontext
        return true
      end
    end

    class Static < FormField
      attr_accessor :label

      def initialize(label = "")
        @label = label
      end

      def focus(index = nil, count = nil)
        speak(@label)
        NVDA.braille(@label) if NVDA.check
      end
    end

    class Tree < FormField
      attr_reader :sel
      attr_accessor :options
      attr_accessor :index
      attr_accessor :options
      attr_reader :opfocused

      def initialize(options, data = 0, header = "", quiet = false, lr = false, silent = false)
        index = 0
        @options = options
        @header = header
        @silent = silent
        @lr = lr
        @way = []
        @sel = createselect([], 0, true)
        focus
      end

      def update
        super
        @opfocused = false
        if @sel.selected? or @sel.expanded?
          o = @options.deep_dup
          for l in @way
            o = o[l][1..o[l].size - 1]
          end
          if o[@sel.index].is_a?(Array)
            @way.push(@sel.index)
            @sel = createselect(@way)
            return
          elsif enter
            @opfocused = true
          end
        end
        if @way.size > 0 and (@lr != 2 and @sel.collapsed?) or (arrow_up and sel.index == 0)
          ind = @way.last
          @way.delete_at(@way.size - 1)
          @sel = createselect(@way, ind)
          return
        end
        @sel.update
        @index = getwayindex(@way + [@sel.index]) - 1
      end

      def createselect(way = [], selindex = 0, quiet = false)
        opt = getelements(way)
        lr = @lr
        if lr == 2
          if way.size == 0
            lr = true
          else
            lr = false
          end
        end
        flags = 0
        flags ||= ListBox::Flags::LeftRight if lr
        flags ||= ListBox::Flags::Silent if @silent
        s = ListBox.new(opt, @header, selindex, flags)
        speak(s.options[s.index], 1, true, nil, true, s.lpos) if quiet != true
        return s
      end

      def searchway(way = [], tway = [], index = 0)
        return [index, tway] if way == tway
        t = @options.deep_dup
        for l in tway
          t = (t[l] == nil) ? nil : (t[l][1..t[l].size - 1])
        end
        return [index, tway] if t.is_a?(Array) == false
        for i in 0..t.size - 1
          x = searchway(way, tway + [i], index + 1)
          if x[1] == way
            return x
            break
          else
            index = x[0]
          end
        end
        return [index, tway]
      end

      def getwayindex(index)
        return searchway(index)[0]
      end

      def getelements(way = [])
        sou = @options.deep_dup
        for l in way
          sou = sou[l][1..sou[l].size - 1]
        end
        ret = sou
        for i in 0..ret.size - 1
          while ret[i].is_a?(Array)
            ret[i] = ret[i][0]
          end
        end
        return ret
      end

      def focus(index = nil, count = nil)
        @sel.focus(index, count)
      end
    end

    # Creates a dialog with a listbox and returns the option selected by user
    #
    # @param options [Array] an array of option
    # @param header [String] a window caption
    # @param index [Numeric] an initial index
    # @param escapeindex [Numeric] a value to return when pressed the escape key, if nil, the escape is not supported
    # @param type [Numeric] if 1, the listbox is horizontal
    # @return [Numeric] the index of a selected option
    def selector(options, header = "", index = 0, escapeindex = nil, type = 0, border = true, cancelkey = nil)
      dialog_open
      dis = []
      for i in 0..options.size - 1
        if options[i] == nil
          dis.push(i)
          options[i] = ""
        end
      end
      flags = 0
      flags = ListBox::Flags::AnyDir if type == 1
      lsel = ListBox.new(options, header, index, flags)
      for d in dis
        lsel.disable_item(d)
      end
      lsel.focus
      @cancel = false
      if cancelkey != nil
        begin
          s = ("key_" + cancelkey.to_s).to_sym
          lsel.on(s) { @cancel = true }
        rescue Exception
        end
      end
      loop do
        loop_update
        lsel.update
        if enter
          dialog_close
          return lsel.index
          break
        end
        if (escape or @cancel == true) and escapeindex != nil
          dialog_close
          loop_update
          return escapeindex
          break
        end
      end
    end

    def menuselector(options)
      dis = []
      for i in 0..options.size - 1
        if options[i] == nil
          dis.push(i)
          options[i] = ""
        end
      end
      lsel = ""
      play("menu_open")
      Menu.menubg_play if Configuration.bgsounds == 1 && Configuration.soundthemeactivation == 1
      lsel = ListBox.new(options, "", 0, ListBox::Flags::AnyDir)
      for d in dis
        lsel.disable_item(d)
      end
      lsel.update
      lsel.focus
      ret = -1
      loop do
        loop_update
        lsel.update
        if enter
          ret = lsel.index
          break
        end
        if alt or escape
          ret = -1
          break
        end
      end
      Menu.menubg_close
      play("menu_close")
      loop_update
      return ret
    end

    # An alias to ListBox.new with lr set to 1
    def menulr(options, border = true, index = 0, header = "", quiet = false)
      flags = ListBox::Flags::LeftRight
      return ListBox.new(options, header, index, flags, quiet)
    end

    # Opens a file selection window and returns a path to file selected by user
    #
    # @param header [String] a window caption
    # @param path [String] an initial path
    # @param save [Boolean] hides a files, presents only directories
    # @param file [String] a file to focus
    # @return [String] an absolute path to a selected file or directory
    def get_file(header = "", path = "", save = false, file = nil, exts = nil)
      dialog_open
      loop_update
      ft = FilesTree.new(header, path, save, true, nil, exts)
      ft.file = file if file != nil
      ft.focus
      loop do
        loop_update
        ft.update
        if escape
          dialog_close
          loop_update
          return nil
          break
        end
        if enter
          dialog_close
          f = ft.path + ft.file
          f.chop! if f[f.size - 1] == "\\"
          if save == false and File.file?(ft.selected(true))
            loop_update
            return f
            break
          end
          if save == true
            if File.directory?(f)
              loop_update
              return f
              break
            else
              d = f.split("\\")
              d[d.size - 1] = ""
              f = d.join("\\")
              loop_update
              return f
              break
            end
          end
        end
        if space
          pt = ft.path
          ftp = input_text(p_("EAPI_Form", "Choose a path"), 0, ft.path, true)
          ft.path = ftp if ftp != nil and File.directory?(ftp)
        end
      end
    rescue Exception
      return nil
    end

    alias get_file_dlg get_file
    alias getfile get_file

    class TableBox < FormField
      attr_accessor :columns, :rows
      attr_reader :sel
      attr_accessor :header
      attr_reader :column

      def initialize(columns = [], rows = [], index = 0, header = "", quiet = true, flags = 0)
        @columns, @rows = columns, rows
        @flags = flags
        @column = 0
        @header = header
        @sel = ListBox.new(format_rows(@column), header, index, @flags, quiet)
        @sel.on(:move) { |arg| trigger(:move, arg) }
      end

      def autosayoption
        @sel.autosayoption
      end

      def autosayoption=(a)
        @sel.autosayoption = a
      end

      def tag
        @sel.tag
      end

      def tag=(t)
        @sel.tag = t
      end

      def options
        @sel.options
      end

      def say_option
        @sel.say_option
      end

      alias sayoption say_option

      def format_rows(col = 0)
        opts = []
        for r in @rows
          if r == nil or r.count(nil) == r.size
            o = nil
          else
            o = ""
            o = r[col].to_s if r[col] != nil
            for c in 0...@columns.size
              if c != col && r[c] != nil
                o += ((c == 0) ? ":" : ((o[-1..-1] != ":" && o[-1..-1] != ".") ? "," : "")) + " "
                o += (@columns[c] || "") + ": " + r[c].to_s
              end
            end
          end
          opts.push(o)
        end
        return opts
      end

      def index
        return @sel.index
      end

      def index=(ind)
        @sel.index = (ind)
      end

      def column=(c)
        setcolumn(c)
      end

      def setcolumn(c)
        @sel.options = format_rows(c)
        @column = c
      end

      def reload
        @sel.options = format_rows(@column)
      end

      def update
        super
        if $keyr[0x10] && @rows.size > 0
          if arrow_right
            c = @column
            setcolumn((@column + 1) % (@columns.size))
            setcolumn((@column + 1) % (@columns.size)) while (@rows[index][@column] == nil || @rows[index][@column] == "") and c != @column
            speak((@rows[@sel.index][@column] || "") + " (" + (@columns[@column] || "") + ")", 1, true, nil, true, @sel.lpos)
          elsif arrow_left
            c = @column
            setcolumn((@column - 1) % (@columns.size))
            setcolumn((@column - 1) % (@columns.size)) while (@rows[index][@column] == nil || @rows[index][@column] == "") and c != @column
            speak((@rows[@sel.index][@column] || "") + " (" + (@columns[@column] || "") + ")", 1, true, nil, true, @sel.lpos)
          end
        end
        @sel.update
      end

      def focus(index = nil, count = nil)
        @sel.focus(index, count)
      end

      def selected?
        @sel.selected?
      end

      def collapsed?
        @sel.collapsed?
      end

      def expanded?
        @sel.expanded?
      end

      def lpos
        @sel.lpos
      end

      def foplay(voice)
        eplay(voice, 100, 100, lpos)
      end

      def key_processed(k)
        if $keyr[0x10] && (k == :left || k == :right)
          return true
        else
          return @sel.key_processed(k)
        end
      end

      def tips
        tips = []
        tips.push(p_("EAPI_Form", "Use SHIFT with left/right arrows to select the column you want to navigate by"))
        return tips
      end
    end

    class Player < FormField
      attr_reader :sound
      attr_reader :pause
      attr_accessor :label

      def initialize(file, label = "", autoplay = true, quiet = true, stream = nil, lazy = false)
        Programs.emit_event(:player_init)
        file = $url + file[1..-1] if file != nil && FileTest.exists?(file) == false && file[0..0] == "/"
        @label = label
        focus if quiet == false
        @file = file
        @stream = stream
        @sound = nil
        if file.is_a?(Bass::Sound)
          @sound = file
          @file = @sound.file
        elsif !lazy
          get_sound
        end
        if autoplay == true and @sound != nil
          @pause = false
          play
        else
          @pause = true
        end
      end

      def setsound(file)
        @sound = Bass::Sound.new(file, 1)
        @basefrequency = @sound.frequency
        @file = file
        @sound.volume = 0.8
      rescue Exception
        @sound = nil
        @file = nil
        alert(p_("EAPI_Common", "This file cannot be played."))
      end

      def setstream(stream)
        @sound = Bass::Sound.new(nil, 1, false, false, stream)
        @basefrequency = @sound.frequency
        @file = nil
        @sound.volume = 0.8
      rescue Exception
        @sound = nil
        @file = nil
        alert(p_("EAPI_Common", "This file cannot be played."))
      end

      def get_sound
        return @sound if @sound != nil
        if @file.is_a?(String)
          setsound(@file)
        elsif @file == nil
          setstream(@stream)
        end
        return @sound
      end

      def update
        super
        return if @sound != nil && @sound.closed
        if $keyr[0x10] == false && $keyr[0x11] == false
          if get_sound != nil
            if $key[0x21]
              chapters = get_sound.chapters
              ch = chapters.sort { |a, b| b.time <=> a.time }.find { |c| c.time < get_sound.position - 5 }
              if ch != nil
                get_sound.position = ch.time
                speak(ch.name)
              end
            elsif $key[0x22]
              chapters = get_sound.chapters
              ch = chapters.sort { |a, b| a.time <=> b.time }.find { |c| c.time > get_sound.position }
              if ch != nil
                get_sound.position = ch.time
                speak(ch.name)
              end
            elsif $key[0x24]
              get_sound.position = 0
            elsif $key[0x23]
              get_sound.position = get_sound.length - 1
            end
          end
          if arrow_right
            get_sound.position += 5
          end
          if arrow_left
            get_sound.position -= 5
          end
          if arrow_up(true)
            pl = 0.01
            pl = 0.1 if get_sound.volume >= 1
            get_sound.volume += pl
            get_sound.volume = 10 if get_sound.volume > 10
          end
          if arrow_down(true)
            pl = 0.01
            pl = 0.1 if get_sound.volume >= 1.1
            get_sound.volume -= pl
            get_sound.volume = 0.05 if get_sound.volume < 0.05
          end
        elsif $keyr[0x11] == true and $keyr[0x10] == false
          if arrow_up(true)
            get_sound.tempo += 2
            get_sound.tempo = 100 if get_sound.tempo > 100
            eplay("listbox_focus") if get_sound.tempo == 0
          end
          if arrow_down(true)
            get_sound.tempo -= 2
            get_sound.tempo = -50 if get_sound.tempo < -50
            eplay("listbox_focus") if get_sound.tempo == 0
          end
        elsif $keyr[0x10] == true and $keyr[0x11] == false
          if arrow_right(true)
            get_sound.pan += 0.02
            get_sound.pan = 1 if get_sound.pan > 1
            eplay("listbox_focus") if get_sound.pan == 0
          end
          if arrow_left(true)
            get_sound.pan -= 0.02
            get_sound.pan = -1 if get_sound.pan < -1
            eplay("listbox_focus") if get_sound.pan == 0
          end
          if arrow_up(true)
            get_sound.frequency += @basefrequency.to_f / 500.0 * 2.0
            get_sound.frequency = @basefrequency * 2 if get_sound.frequency > @basefrequency * 2
            eplay("listbox_focus") if get_sound.frequency == get_sound.basefrequency
          end
          if arrow_down(true)
            get_sound.frequency -= @basefrequency.to_f / 500.0 * 2.0
            get_sound.frequency = @basefrequency / 2 if get_sound.frequency < @basefrequency / 2
            eplay("listbox_focus") if get_sound.frequency == get_sound.basefrequency
          end
        end
        if $key[0x08] == true
          reset = 10
          get_sound.volume = 0.8
          get_sound.pan = 0
          get_sound.tempo = 0
          get_sound.frequency = @basefrequency
        end
      end

      def getposition(pos, len)
        form = Form.new([
          lst_hour = ListBox.new([], p_("EAPI_Form", "Hour")),
          lst_min = ListBox.new((0..59).to_a.map { |t| t.to_s }, p_("EAPI_Form", "Minute")),
          lst_sec = ListBox.new((0..59).to_a.map { |t| t.to_s }, p_("EAPI_Form", "Second")),
          btn_ok = Button.new(p_("EAPI_Form", "Jump")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        hours = len / 3600
        (0..hours).each { |h| lst_hour.options.push(h.to_s) }
        lst_hour.on(:move) {
          t = (len - lst_hour.index * 3600) / 60
          for i in 0..59
            if t <= i
              lst_min.disable_item(i)
            else
              lst_min.enable_item(i)
            end
          end
          lst_min.trigger(:move, lst_min.index)
        }
        lst_min.on(:move) {
          t = (len - lst_hour.index * 3600 - lst_min.index * 60)
          for i in 0..59
            if t <= i
              lst_sec.disable_item(i)
            else
              lst_sec.enable_item(i)
            end
          end
        }
        lst_hour.trigger(:move, lst_hour.index)
        lst_hour.index = (pos / 3600).to_i
        lst_min.index = ((pos / 60) % 60).to_i
        lst_sec.index = (pos % 60).to_i
        btn_cancel.on(:press) { form.resume }
        btn_ok.on(:press) {
          t = lst_sec.index + lst_min.index * 60 + lst_hour.index * 3600
          form.resume
          return t
        }
        form.cancel_button = btn_cancel
        form.accept_button = btn_ok
        form.wait
        return nil
      end

      def savefile
        tf = @file.gsub("\\", "/")
        fs = tf.split("/")
        nm = fs.last.split("?")[0]
        nm = @label.delete("\r\n\\/:!@\#*?<>\'\"|+=`") if @label != "" and @label != nil
        nm += ".opus"
        encoders = []
        for e in MediaEncoders.list
          encoders.push(e) if e::Type == :audio
        end
        formats = []
        for e in encoders
          f = e::Name + " (" + e::Extension + ")"
          if e::Extension.downcase == ".opus" && is_opus?
            f += " (" + p_("EAPI_Form", "Copy original stream") + ")"
          end
          formats.push(f)
        end
        dialog_open
        form = Form.new([
          tr_path = FilesTree.new(p_("EAPI_Form", "Destination"), Dirs.user + "\\", true, true, "Music"),
          lst_format = ListBox.new(formats, p_("EAPI_Form", "File format")),
          edt_filename = EditBox.new(p_("EAPI_Form", "File name"), 0, nm, true),
          btn_save = Button.new(_("Save")),
          btn_cancel = Button.new(_("Cancel"))
        ])
        form.cancel_button = btn_cancel
        lst_format.on(:move) {
          eext = encoders[lst_format.index]::Extension
          fl = edt_filename.text
          ext = File.extname(fl)
          fb = (fl.reverse.sub(ext.reverse, "")).reverse
          edt_filename.set_text(fb + eext)
        }
        edt_filename.on(:change) {
          ext = File.extname(edt_filename.text)
          for i in 0...encoders.size
            if encoders[i]::Extension.downcase == ext.downcase
              lst_format.index = i
              break
            end
          end
        }
        btn_cancel.on(:press) { form.resume }
        btn_save.on(:press) {
          encoder = encoders[lst_format.index]
          pth = tr_path.selected + "\\" + edt_filename.text
          r = true
          waiting {
            if encoder::Extension.downcase == ".opus" && is_opus?
              r = download_file(@file, pth)
            else
              encoder.encode_file(@file, pth)
            end
          }
          alert(_("Saved")) if r
          form.resume
        }
        form.wait
        dialog_close
      end

      def is_opus?
        if @file.include?("https://elten-net.eu/srv/audio")
          return true
        elsif @file.include?("https://s.elten-net.eu/") && @file[-4..-4] != "."
          return true
        elsif @file.include?("https://srvapi.elten.link/leg1/audio")
          return true
        elsif @file.include?("https://s.elten.link/") && @file[-4..-4] != "."
          return true
        else
          return false
        end
      end

      def position
        return 0 if get_sound == nil
        return get_sound.position
      end

      def duration
        return 0 if get_sound == nil
        return get_sound.length
      end

      def play
        @pause = false
        Programs.emit_event(:player_play)
        get_sound.play if get_sound != nil
      end

      def stop
        Programs.emit_event(:player_stop)
        get_sound.stop if get_sound != nil
        @pause = true
      end

      def paused?
        @pause == true
      end

      def completed
        return true if get_sound == nil
        get_sound.position(true) >= get_sound.length(true) - 1024 and get_sound.length(true) > 0
      end

      def fade
        return if get_sound == nil
        for i in 1..20
          loop_update
          get_sound.volume -= 0.05
          if get_sound.volume <= 0.05
            get_sound.volume = 0
            loop_update
            break
          end
        end
      end

      def close
        Programs.emit_event(:player_close)
        get_sound.close if get_sound != nil
      end

      def context(menu, submenu = false)
        if get_sound != nil && !get_sound.closed
          menu.option(p_("EAPI_Form", "Play/pause"), nil, :space) {
            if get_sound != nil
              if @pause != true
                Programs.emit_event(:player_pause)
                get_sound.pause
                @pause = true
              else
                Programs.emit_event(:player_play)
                get_sound.play
                @pause = false
              end
            end
          }
          menu.option(p_("EAPI_Form", "Get sound position"), nil, :p) {
            if get_sound != nil
              d = 0
              begin
                d = get_sound.position.to_i
              rescue Exception
              end
              h = d / 3600
              m = (d - d / 3600 * 3600) / 60
              s = d - d / 60 * 60
              speak(sprintf("%0#{(h.to_s.size <= 2) ? 2 : d.to_s.size}d:%02d:%02d", h, m, s))
            end
          }
          menu.option(p_("EAPI_Form", "Get sound duration"), nil, :d) {
            if get_sound != nil
              d = (get_sound.length || 0).to_i
              h = d / 3600
              m = (d - d / 3600 * 3600) / 60
              s = d - d / 60 * 60
              speak(sprintf("%0#{(h.to_s.size <= 2) ? 2 : d.to_s.size}d:%02d:%02d", h, m, s))
            end
          }
          menu.option(p_("EAPI_Form", "Track info"), nil, :i) {
            if get_sound != nil
              ai = get_sound.audioinfo
              fields = [
                [p_("EAPI_Form", "Title"), ai.title],
                [p_("EAPI_Form", "Artist"), ai.artist],
                [p_("EAPI_Form", "Album"), ai.album],
                [p_("EAPI_Form", "Track number"), ai.track_number],
                [p_("EAPI_Form", "Copyright"), ai.copyright]
              ]
              for a in fields.deep_dup
                fields.delete(a) if a[1] == nil || a[1] == ""
              end
              sel = TableBox.new(["", ""], fields, 0, "", false)
              loop do
                loop_update
                sel.update
                break if escape
              end
            end
          }
          if get_sound != nil && get_sound.chapters.size > 0
            menu.option(p_("EAPI_Form", "Show chapters"), nil, :c) {
              chapters = get_sound.chapters
              sel = ListBox.new(chapters.map { |c| c.name }, p_("EAPI_Form", "Chapters"), 0, 0, false)
              eplay("dialog_open")
              loop do
                loop_update
                sel.update
                ch = chapters[sel.index]
                if ch != nil
                  if enter
                    get_sound.position = ch.time if get_sound != nil
                    play
                    if get_sound.position < ch.time
                      speak(p_("EAPI_Form", "This chapter has not been buffered yet"))
                    end
                  elsif space
                    speak(ch.time)
                  end
                end
                break if escape
              end
              eplay("dialog_close")
            }
          end
          menu.option(p_("EAPI_Form", "Jump to position"), nil, :j) {
            get_sound.pause
            dpos = getposition(get_sound.position, get_sound.length)
            dpos = get_sound.position if get_sound != nil && dpos == nil
            dpos = dpos.to_i
            dpos = get_sound.length if get_sound != nil && dpos > get_sound.length
            get_sound.play if get_sound != nil
            get_sound.position = dpos if get_sound != nil
            loop_update
          }
          if @file != nil && (@file.include?("http:") || @file.include?("https:"))
            menu.option(p_("EAPI_Form", "Save file"), nil, "s") {
              savefile
            }
          end
        end
      end

      def focus(index = nil, count = nil)
        speak(@label) if @label != ""
      end

      def tips
        tips = []
        tips.push(p_("EAPI_Form", "Use spacebar to toggle pause"))
        tips.push(p_("EAPI_Form", "Use left/right arrows to slide"))
        tips.push(p_("EAPI_Form", "Use up/down arrows to change playback volume"))
        tips.push(p_("EAPI_Form", "Use SHIFT with left/right arrows to change panning"))
        tips.push(p_("EAPI_Form", "Use SHIFT with up/down arrows to change pitch"))
        tips.push(p_("EAPI_Form", "Use CTRL with up/down arrows to change tempo"))
        tips.push(p_("EAPI_Form", "Use backspace to return to the default settings"))
        tips.push(p_("EAPI_Form", "Use home or end to move to the beginning or ending of a track"))
        tips.push(p_("EAPI_Form", "Use page up or page down to navigate to the previous or next chapter"))
        return tips
      end
    end

    class Menu
      attr_accessor :header
      @@menubg = nil

      def initialize(header = "", type = :default, &block)
        @lasttime = 0
        @type = type
        @options = []
        @header = header
        @closed = true
        @on_close = []
        @on_open = []
        @on_action = []
        @instance = 0
        if block_given?
          @caller = $scene
          if block.arity <= 0
            @instance = 1
            instance_eval(&block)
          else
            block.call(self)
          end
        end
      end

      def option(opt, v = nil, key = "", &block)
        @options.push([opt, block, v, key])
      end

      def scene(opt, scene, *args)
        @options.push([opt, :scene, [scene] + args])
      end

      def quickaction(opt, action)
        @options.push([opt, :quickaction, action])
      end

      def customoption(opt, &block)
        @options.push([opt, :custom, block])
      end

      def useroption(user)
        @options.push([user, :user, user])
      end

      def submenu(opt, &block)
        @options.push(opt)
        if block_given?
          if block.arity <= 0
            @instance = 1
            instance_eval(&block)
          else
            block.call(self)
          end
        end
        @options.push(nil)
      end

      def size
        @options.size
      end

      def on_close(&block)
        @on_close.push(block)
      end

      def on_open(&block)
        @on_open.push(block)
      end

      def on_action(&block)
        @on_action.push(block)
      end

      def open
        @closed = false
        if @on_open.size == 0
          if @type == (:menubar) || @type == (:menu)
            play "menu_open"
            if Configuration.bgsounds == 1 && Configuration.soundthemeactivation == 1
              self.class.menubg_play
            end
          end
          show(0)
        else
          @on_open.each { |c| c.call }
        end
      end

      def show(index = 0)
        h = ""
        h = @header if index == 0 and @type != :menubar or @first == nil
        @first = true
        opts = []
        acs = []
        s = 0
        inds = []
        depth = 0
        for i in 0...index
          depth += 1 if @options[i].is_a?(String)
          depth -= 1 if @options[i] == nil
        end
        for i in index...@options.size
          c = @options[i]
          if s == 0
            break if c == nil
            inds.push(nil)
            o = c
            o = c[0] if c.is_a?(Array)
            if c.is_a?(Array) and c[3] != "" and c[3] != nil
              k = (c[3].is_a?(Symbol)) ? (c[3].to_s) : (char_dict(c[3]))
              k = "SHIFT+" + k.to_s if k.to_s.downcase != k
              o += (c[3].is_a?(Symbol)) ? (" " + k.gsub("_", "+")) : (" (CTRL+" + k.to_s + ")")
            end
            opts.push(o)
            acs.push(c)
          end
          if c.is_a?(String)
            inds[-1] ||= i
            s += 1
          elsif c == nil
            s -= 1
          end
        end
        return if opts.size == 0
        flags = ListBox::Flags::Silent | ListBox::Flags::HotKeys
        flags |= ListBox::Flags::LeftRight if (@type == :menubar) && index == 0
        sel = ListBox.new(opts, h, 0, flags, false)
        sel.on(:border) { play("border", 100, 100, sel.lpos) }
        sel.on(:move) {
          opt = acs[sel.index]
          if opt[1] == :user or opt[1] == :custom or opt.is_a?(String)
            play("listbox_itemsubmenu", 100, 100, sel.lpos)
          else
            play("listbox_focus", 100, 100, sel.lpos)
          end
        }
        sel.on(:select) {
          opt = acs[sel.index]
          if opt[1] != :user and opt[1] != :custom and !opt.is_a?(String)
            play("listbox_select", 100, 100, sel.lpos)
          end
        }
        @lasttime = Time.now.to_f
        loop {
          loop_update
          @lasttime = Time.now.to_f
          return if depth == 1 and @type == :menubar and sel.index == 0 and arrow_up
          sel.update if !@closing
          return -1 if arrow_left and @type == :menubar and depth == 1
          return 1 if arrow_right and @type == :menubar and depth > 0 and (acs[sel.index].is_a?(Array) and (acs[sel.index][1] != :user and acs[sel.index][1] != :custom))
          if ((escape and depth == 0) or (alt and (@type == :menubar or @type == :menu)))
            if @on_close.size == 0
              close
            else
              @on_close.each { |c| c.call }
            end
          end
          break if @closing
          return if ((escape or (sel.collapsed? and (depth > 1 or (depth == 1 and @type != :menubar)))) and index > 0) and depth > 0
          if sel.expanded? or sel.selected?
            opt = acs[sel.index]
            if opt[1] == :user
              play("listbox_treeexpand", 100, 100, sel.lpos)
              u = usermenu(opt[2], true, true)
              if u == "ALT"
                close
              else
                play("listbox_treecollapse", 100, 100, sel.lpos)
                sel.focus
              end
            elsif opt[1] == :custom
              play("listbox_treeexpand", 100, 100, sel.lpos)
              u = opt[2].call
              if u == true
                close
              else
                play("listbox_treecollapse", 100, 100, sel.lpos)
                sel.trigger(:move, sel.index)
                sel.focus
              end
            elsif opt.is_a?(String)
              play("listbox_treeexpand", 100, 100, sel.lpos)
              a = show(inds[sel.index] + 1)
              if a == nil
                sel.header = "" if @type == :menubar
                play("listbox_treecollapse", 100, 100, sel.lpos) if !@closing
                sel.focus if !@closing
                loop_update
              else
                return a if depth > 0
                sel.index = (sel.index + a) % acs.size
                $enter = 2 if acs[sel.index].is_a?(String)
              end
            elsif sel.selected?
              close if @type != :returning and opt[1] != :user
              loop_update(false)
              if opt[1] == :scene
                @on_action.each { |c| c.call }
                insert_scene(opt[2][0].new(*opt[2][1..-1]), true)
              elsif opt[1] == :quickaction
                @on_action.each { |c| c.call }
                opt[2].call
              else
                @on_action.each { |c| c.call }
                if opt[2] != nil or @instance == 0
                  opt[1].call(opt[2])
                else
                  @caller.instance_eval(&opt[1])
                end
              end
            end
          end
        }
      end

      def close
        if @type == :menubar || @type == :menu
          play("menu_close")
          self.class.menubg_close
        end
        @closing = true
        @closed = true
      end

      def opened?
        close if @lasttime - Time.now.to_f > 5
        !@closed
      end

      def scenes
        sc = []
        @options.each { |o|
          sc.push([o[0].delete("&"), o[2]]) if o.is_a?(Array) && o[1] == :scene
        }
        return sc
      end

      def items
        it = []
        @options.each { |o|
          if o.is_a?(Array) && o[1].is_a?(Proc)
            it.push(o)
          end
        }
        return it
      end

      def self.menubg_close
        if @@menubg != nil
          @@menubg.close
          @@menubg = nil
        end
      end
      def self.menubg_play
        self.menubg_close if @@menubg != nil
        snd = getsound("menu_background")
        if snd != nil
          @@menubg = Bass::Sound.new(nil, 1, true, false, snd)
          @@menubg.volume = Configuration.volume / 100.0
          @@menubg.play
        end
      end
    end

    class Timer
      attr_accessor :offset, :repeat

      def initialize(offset, repeat = false, dstart = true, &block)
        @scene = $scene
        @offset, @repeat = offset, repeat
        @block = block
        start if dstart
      end

      def reset
        @used = false
      end

      def start
        return if @used == true and @repeat == true
        @stopped = false
        @h = Thread.new {
          loop {
            o = @offset
            o = rand * (o.end - o.begin) + o.begin if @offset.is_a?(Range)
            sleep(o)
            begin
              @block.call
            rescue Exception
              p $!
              p $@
            end
            if @repeat == false
              @used = true
              break
            end
          }
        }
      end

      def stop
        @stopped = true
        @h.kill if @h != nil
        @h = nil
      end
    end

    class MapObject
      attr_accessor :x, :y
      attr_accessor :range, :sound, :sound_range, :move_type, :move_delay

      def initialize(x, y, scene = nil, &block)
        @scene = $scene if scene == nil
        @x, @y = x, y
        @move_type = :fixed
        @move_delay = 0.5
        @laststep = 0
        @range = 0
        @sound_range = 5
        if block_given?
          if block.arity <= 0
            instance_eval(&block)
          else
            block.call(self)
          end
        end
      end

      def on(event, time = 0, &block)
        @events ||= []
        @events.push([event, time, 0, block])
      end

      def trigger(event, *params)
        return if @events == nil
        @events.each { |e|
          if e[0] == event and e[2] <= Time.now.to_f - e[1]
            e[2] = Time.now.to_f
            e[3].call
          end
        }
      end

      def path(x, y, ox, oy, walls, width, height)
        return [[x, y]] if x == ox && y == oy
        mat = []
        for i in 0...width
          mat[i] = []
          for j in 0...height
            s = true
            s = false if walls.include?([i, j])
            mat[i][j] = s
          end
        end
        b = bfs(mat, x, y, ox, oy)
        b = [[x, y]] if b == nil
        return b
      end

      def play(sound, x = nil, y = nil)
        x, y = @px, @py if x == nil || y == nil
        return if x == nil || y == nil
        d = Math::sqrt((@x - x) ** 2 + (@y - y) ** 2)
        dx = (@x - x) / @sound_range.to_f
        dy = (@y - y) / @sound_range.to_f
        s = Bass::Sound.new(sound)
        s.pan = dx
        #s.frequency=@sound_handle.basefrequency*(1.0-dy.abs*0.2)
        s.volume = (@sound_range - d.to_f) / @sound_range
        s.play
        Thread.new {
          sleep(s.length)
          s.close
        }
      end

      def update(x, y, walls, width, height)
        d = Math::sqrt((@x - x) ** 2 + (@y - y) ** 2)
        @px, @py = x, y
        if @laststep + @move_delay < Time.now.to_f
          @laststep = Time.now.to_f
          mx, my = @x, @y
          case @move_type
          when :follow
            mx, my = path(@x, @y, x, y, walls, width, height)[0]
          when :random
            5.times {
              mx = rand(3) - 1
              my = rand(3) - 1
              walls.each { |w| break if w[0] != mx && w[1] != my }
            }
          end
          suc = true
          walls.each { |w| suc = false if w[0] == mx && w[1] == my }
          @x, @y = mx, my if suc
        end
        if @sound != nil
          if @sound_handle == nil
            @sound_handle = Bass::Sound.new(@sound, 0, true)
          end
          if d <= @sound_range
            dx = (@x - x) / @sound_range.to_f
            dy = (@y - y) / @sound_range.to_f
            @sound_handle.pan = dx
            @sound_handle.frequency = @sound_handle.basefrequency * (1.0 - dy.abs * 0.2)
            v = (@sound_range - d.to_f) / @sound_range / 2.0
            v += 0.5 if dy >= 0
            @sound_handle.volume = v
            @sound_handle.play
          else
            @sound_handle.pause
          end
        end
        if d < @range
          keyevents.each { |a| trigger(a[0]) }
          trigger(:range)
        end
        trigger(:touch) if x == @x && y == @y
      end

      def dispose
        @sound_handle.close if @sound_handle != nil
        @sound_handle = nil
      end
    end

    class Map
      attr_reader :width, :height, :direction, :objects
      attr_accessor :x, :y
      attr_accessor :move_sound, :border_sound, :wall_sound, :move_delay, :direction_sound, :direction_delay

      def initialize(width, height, &block)
        @scene = $scene
        @width, @height = width, height
        @direction = [0, 0]
        @actions = []
        @objects = []
        @walls = []
        @move_sound = "list_focus"
        @x = 0
        @y = 0
        @move_delay = 0.2
        @direction_delay = false
        @timers = []
        if block_given?
          if block.arity <= 0
            instance_eval(&block)
          else
            block.call(self)
          end
        end
      end

      def wall(x1, y1, x2 = nil, y2 = nil)
        x2, y2 = x1, y1 if x2 == nil || y2 == nil
        x1, x2 = x2, x1 if x1 > x2
        y1, y2 = y2, y1 if y1 > y2
        x, y = x1, y1
        loop do
          @walls.push([x, y])
          break if x >= x2 && y >= y2
          x += 1 if x2 > x1
          y += 1 if y2 > y1
        end
      end

      def action(x, y, &block)
        @actions.push([x, y, block])
      end

      def object(x, y, &block)
        @objects.push(MapObject.new(x, y, @scene, &block))
      end

      def delete_object(o)
        o.dispose
        @objects.delete(o)
      end

      def timer(offset, repeat = false, &block)
        t = Timer.new(offset, repeat, false, &block)
        @timers.push(t)
        t
      end

      def distance(x, y)
        return Math::sqrt((@x - x) ** 2 + (@y - y) ** 2)
      end

      def random_position(d = 0)
        x, y = nil, nil
        while x == nil || y == nil || distance(x, y) < d
          x, y = rand(@width), rand(@height)
        end
        return [x, y]
      end

      def empty?(x, y)
        return !@walls.include?([x, y])
      end

      def directs?(x, y)
        d = [0, 0]
        d[0] = -1 if x < @x
        d[0] = 1 if x > @x
        d[1] = -1 if y < @y
        d[1] = 1 if y > @y
        return d == @direction || d == [0, 0]
      end

      def go(x, y)
        if x < 0 || x >= @width || y < 0 || y >= @height
          trigger(:border)
          play(@border_sound) if @border_sound != nil
        else
          ld = @direction
          d = [0, 0]
          d[0] = -1 if x < @x
          d[0] = 1 if x > @x
          d[1] = -1 if y < @y
          d[1] = 1 if y > @y
          if @direction != d
            @direction = d
            play(@direction_sound) if @direction_sound != nil
            return if @direction_delay
          end
          for w in @walls
            if w[0] == x && w[1] == y
              play(@wall_sound) if @wall_sound != nil
              trigger(:wall)
              return
            end
          end
          play(@move_sound) if @move_sound != nil
          @x, @y = x, y
          for ac in @actions
            ac[2].call if ac[0] == x and ac[1] == y
          end
          trigger(:move)
        end
      end

      def on(event, time = 0, &block)
        @events ||= []
        @events.push([event, time, 0, block])
      end

      def trigger(event, *params)
        return if @events == nil
        @events.each { |e|
          if e[0] == event and e[2] <= Time.now.to_f - e[1]
            e[2] = Time.now.to_f
            @scene.instance_eval(&e[3])
          end
        }
      end

      def show(x = nil, y = nil)
        @x = x if x != nil
        @y = y if y != nil
        @disposed = false
        @timers.each { |t| t.start }
        laststep = 0
        loop do
          loop_update
          keyevents.each { |a| trigger(a[0]) }
          if (laststep + @move_delay) < Time.now.to_f
            if arrow_down(true)
              laststep = Time.now.to_f
              go(@x, @y - 1)
            end
            if arrow_up(true)
              laststep = Time.now.to_f
              go(@x, @y + 1)
            end
            if arrow_left(true)
              laststep = Time.now.to_f
              go(@x - 1, @y)
            end
            if arrow_right(true)
              laststep = Time.now.to_f
              go(@x + 1, @y)
            end
          end
          @objects.each { |o| o.update(@x, @y, @walls, @width, @height) } if !@disposed
          break if @disposed
        end
      end

      def dispose
        @objects.each { |o| o.dispose }
        @timers.each { |t| t.stop }
        @disposed = true
      end
    end

    class OpusRecordButton < Button
      attr_accessor :label, :timelimit
      attr_reader :file

      def initialize(label, filename, max_bitrate = 320, bitrate = 64, timelimit = 0)
        super(label)
        @file = nil
        @filename = filename
        @tags = nil
        @max_bitrate = max_bitrate
        @bitrate = bitrate
        @bitrate = @max_bitrate if @bitrate > @max_bitrate
        @timelimit = timelimit
        @framesize = 60
        @framesize = 40 if @bitrate > 40
        @framesize = 20 if @bitrate > 80
        @application = 2048
        @application = 2049 if @bitrate >= 64
        @usevbr = 1
        @recorder = nil
        @status = 0
        @current_filename = @filename
        @form = Form.new([
          @btn_record = Button.new(p_("EAPI_Form", "record")),
          @btn_pause = Button.new(p_("EAPI_Form", "Pause recording")),
          @btn_stop = Button.new(p_("EAPI_Form", "Stop recording")),
          @btn_usefile = Button.new(p_("EAPI_Form", "Use existing file")),
          @btn_encoder = Button.new(p_("EAPI_Form", "Opus encoder settings")),
          @btn_tags = Button.new(p_("Conference", "Edit metadata and chapters")),
          @btn_play = Button.new(p_("EAPI_Form", "Play")),
          @btn_encodeplay = Button.new(p_("EAPI_Form", "Encode and play")),
          @btn_delete = Button.new(p_("EAPI_Form", "Delete recording")),
          @btn_select = Button.new(p_("EAPI_Form", "Ready"))
        ], 0, false, true)
        @form.hide(@btn_pause)
        @form.hide(@btn_stop)
        @form.hide(@btn_tags)
        @form.hide(@btn_play)
        @form.hide(@btn_encodeplay)
        @form.hide(@btn_delete)
        @btn_record.on(:press) {
          if @status == 0 or confirm(p_("EAPI_Form", "Are you sure you want to delete the previous recording and create a new one?")) == 1
            @current_filename = @filename
            play("recording_start")
            @status = 1
            @recorder = OpusRecorder.start(@filename, @bitrate, @framesize, @application, @usevbr, @timelimit)
            @form.hide(@btn_record)
            @form.hide(@btn_usefile)
            @form.hide(@btn_tags)
            @form.hide(@btn_play)
            @form.hide(@btn_encoder)
            @form.hide(@btn_encodeplay)
            @form.hide(@btn_delete)
            @form.show(@btn_pause)
            @form.show(@btn_stop)
            if @timelimit > 5
              @form.add_timer(@recinfotimer = FormTimer.new(@timelimit - 5) {
                play("recording_nearlimit")
              })
            end
            if @timelimit > 0
              @form.add_timer(@recstoptimer = FormTimer.new(@timelimit) {
                @btn_stop.press
              })
            end
          end
        }
        @btn_stop.on(:press) {
          @recorder.stop
          @form.delete_timer(@recinfotimer) if @recinfotimer != nil
          @form.delete_timer(@recstoptimer) if @recstoptimer != nil
          play("recording_stop")
          @recorder = nil
          @status = 2
          @form.show(@btn_record)
          @form.show(@btn_tags) if holds_premiumpackage("audiophile")
          @form.show(@btn_play)
          @form.hide(@btn_encodeplay)
          @form.hide(@btn_pause)
          @form.hide(@btn_stop)
          @form.show(@btn_encoder)
          @form.show(@btn_usefile)
          @form.show(@btn_delete)
          @btn_record.label = p_("EAPI_Form", "Record again")
          @btn_pause.label = p_("EAPI_Form", "Pause recording")
          @form.index = 0
          @form.focus
        }
        @btn_usefile.on(:press) {
          if @status == 0 or confirm(p_("EAPI_Form", "Are you sure you want to delete the previous recording and create a new one?")) == 1
            file = get_file_dlg(p_("EAPI_Form", "Select audio file"), Dirs.documents + "\\", false, nil, [".mp3", ".wav", ".ogg", ".mid", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"])
            if file != nil
              set_source(file)
              alert(p_("EAPI_Form", "File selected"))
            end
          end
          loop_update
        }
        @btn_tags.on(:press) {
          edit_tags
          @form.focus
        }
        @btn_play.on(:press) {
          player(@current_filename, p_("EAPI_Form", "Recording preview"))
          @form.focus
        }
        @btn_encodeplay.on(:press) {
          get_file
          @form.index = @btn_play
          @btn_play.press
        }
        @btn_pause.on(:press) {
          if @recorder.paused
            @btn_pause.label = p_("EAPI_Form", "Pause recording")
            @recorder.resume
            play("recording_start")
          else
            @btn_pause.label = p_("EAPI_Form", "Resume recording")
            @recorder.pause
            play("recording_stop")
          end
        }
        @btn_encoder.on(:press) {
          if @status == 0 or @current_filename != @filename or confirm(p_("EAPI_Form", "The encoder settings will not apply to the current record. Are you sure you want to continue?")) == 1
            show_encodersettings
            @form.focus
          end
        }
        @btn_delete.on(:press) {
          delete_audio
          @form.index = 0
          @form.focus
        }
        @btn_select.on(:press) {
          @btn_stop.press if @recorder != nil
          @form.resume
        }
        @form.cancel_button = @btn_select
      end

      def delete_audio(force = false)
        return true if @status == 0
        if @filename != @current_filename or force or confirm(p_("EAPI_Form", "Are you sure you want to delete recorded audio?")) == 1
          @btn_stop.press if @recorder != nil
          File.delete(@filename) if FileTest.exists?(@filename)
          @form.hide(@btn_delete)
          @form.hide(@btn_tags)
          @form.hide(@btn_play)
          @status = 0
          return true
        else
          return false
        end
      end

      def update
        super
        if @pressed
          show
          focus
        end
      end

      def show_encodersettings
        profiles = [
          [p_("EAPI_Form", "Low"), 24, 60, 0],
          [p_("EAPI_Form", "Lower"), 32, 60, 0],
          [p_("EAPI_Form", "Standard"), 48, 40, 0],
          [p_("EAPI_Form", "Higher"), 64, 40, 1],
          [p_("EAPI_Form", "High"), 96, 20, 1],
          [p_("EAPI_Form", "Max"), @max_bitrate, ((@max_bitrate > 80) ? 20 : 40), 1]
        ]
        for pr in profiles
          profiles.delete(pr) if pr[1] > @max_bitrate
        end
        appind = @application == 2048 ? 0 : 1
        form = Form.new([
          lst_profile = ListBox.new(profiles.map { |pr| pr[0] } + [p_("EAPI_Form", "Custom")], p_("EAPI_Form", "Quality")),
          lst_bitrate = ListBox.new(bitrates_available.map { |b| b.to_s + " kbps" }, p_("EAPI_Form", "Bitrate"), bitrates_available.find_index(@bitrate) || 0),
          lst_framesize = ListBox.new(framesizes_available.map { |f| f.to_s + " ms" }, p_("EAPI_Form", "Frame size"), framesizes_available.find_index(@framesize) || 0),
          lst_application = ListBox.new([p_("EAPI_Form", "Speech profile"), p_("EAPI_Form", "Music profile")], p_("EAPI_Form", "Encoder profile"), appind),
          chk_usevbr = CheckBox.new(p_("EAPI_Form", "Use variable bitrate"), @usevbr),
          btn_save = Button.new(_("Save")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        lst_profile.on(:move) {
          if lst_profile.index < profiles.size
            pr = profiles[lst_profile.index]
            lst_bitrate.index = bitrates_available.find_index(pr[1]) || 0
            lst_framesize.index = framesizes_available.find_index(pr[2]) || 0
            lst_application.index = 0
            chk_usevbr.checked = 1
            form.hide(lst_bitrate)
            form.hide(lst_framesize)
            form.hide(lst_application)
            form.hide(chk_usevbr)
          else
            form.show(lst_bitrate)
            form.show(lst_framesize)
            form.show(lst_application)
            form.show(chk_usevbr)
          end
        }
        suc = false
        for i in 0...profiles.size
          pr = profiles[i]
          bitrate = bitrates_available[lst_bitrate.index]
          framesize = framesizes_available[lst_framesize.index]
          if bitrate == pr[1] && framesize == pr[2] && lst_application.index == 0 && chk_usevbr.checked == 1
            lst_profile.index = i
            lst_profile.trigger(:move, lst_profile.index)
            suc = true
          end
        end
        if suc == false
          lst_profile.index = profiles.size
          lst_profile.trigger(:move, lst_profile.index)
        end
        btn_cancel.on(:press) { form.resume }
        btn_save.on(:press) {
          @bitrate = bitrates_available[lst_bitrate.index]
          @framesize = framesizes_available[lst_framesize.index]
          @application = lst_application.index == 0 ? 2048 : 2049
          @usevbr = chk_usevbr.checked
          form.resume
        }
        form.cancel_button = btn_cancel
        form.accept_button = btn_save
        form.wait
      end

      def framesizes_available
        [2.5, 5, 10, 20, 40, 60, 80, 100, 120]
      end

      def bitrates_available
        all = [8, 16, 24, 32, 48, 64, 80, 96, 128, 160, 196, 256, 320]
        m = []
        for b in all
          m.push(b) if b <= @max_bitrate
        end
        return m
      end

      def get_tags(default = true)
        if @tags == nil
          return nil if default == false
          snd = Bass::Sound.new(@current_filename)
          ai = snd.audioinfo
          tgs = ai.like_ogg
          snd.close
          return tgs
        else
          return @tags
        end
      end

      def edit_tags
        tgs = get_tags.deep_dup
        editable_tags = ["TITLE", "ARTIST", "ALBUM", "TRACKNUMBER", "COPYRIGHT"]
        form = Form.new([
          lst_tags = ListBox.new([], p_("EAPI_Form", "Tags")),
          edt_value = EditBox.new(p_("EAPI_Form", "Tag value")),
          lst_chapters = ListBox.new([], p_("EAPI_Form", "Chapters")),
          btn_save = Button.new(_("Save")),
          btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        tbld = Proc.new {
          mapper = {
            "TITLE" => p_("EAPI_Form", "Title"),
            "ARTIST" => p_("EAPI_Form", "Artist"),
            "ALBUM" => p_("EAPI_Form", "Album"),
            "TRACKNUMBER" => p_("EAPI_Form", "Track number"),
            "COPYRIGHT" => p_("EAPI_Form", "Copyright")
          }
          opts = []
          for k in editable_tags
            v = mapper[k] || k
            opts.push("#{v}: #{tgs[k] || ""}")
          end
          lst_tags.options = opts
          opts = []
          for i in 0..999
            next if tgs["CHAPTER#{sprintf("%03d", i)}"] == nil
            time = tgs["CHAPTER#{sprintf("%03d", i)}"]
            name = tgs["CHAPTER#{sprintf("%03d", i)}NAME"] || ""
            opts.push(name + ": " + time)
          end
          lst_chapters.options = opts
        }
        getchaps = Proc.new {
          chaps = []
          for i in 0..999
            next if tgs["CHAPTER#{sprintf("%03d", i)}"] == nil
            time = tgs["CHAPTER#{sprintf("%03d", i)}"]
            name = tgs["CHAPTER#{sprintf("%03d", i)}NAME"] || ""
            chaps.push([time, name])
            tgs.delete("CHAPTER#{sprintf("%03d", i)}")
            tgs.delete("CHAPTER#{sprintf("%03d", i)}NAME")
          end
          chaps
        }
        setchaps = Proc.new { |chaps|
          chaps = chaps.sort_by { |c| c[0] }
          for i in 0...chaps.size
            tgs["CHAPTER#{sprintf("%03d", i)}"] = chaps[i][0]
            tgs["CHAPTER#{sprintf("%03d", i)}NAME"] = chaps[i][1] || ""
          end
          tbld.call
        }
        addchap = Proc.new { |time, name|
          chaps = [[time, name]] + getchaps.call
          setchaps.call(chaps)
        }
        delchap = Proc.new { |index|
          chaps = getchaps.call
          chaps.delete_at(index)
          setchaps.call(chaps)
        }
        editchap = Proc.new { |index|
          chaps = getchaps.call
          chap = ["00:00:00", ""]
          chap = chaps[index] if index.is_a?(Numeric) && index >= 0 && index < chaps.size
          index = chaps.size if !index.is_a?(Numeric) || index < 0 || index > chaps.size
          frm = Form.new([
            fedt_name = EditBox.new(p_("EAPI_Form", "Chapter name"), 0, chap[1]),
            fedt_time = EditBox.new(p_("EAPI_Form", "Chapter time (hh:mm:ss.uuu)"), 0, chap[0]),
            fbtn_save = Button.new(_("Save")),
            fbtn_cancel = Button.new(_("Cancel"))
          ], 0, false, true)
          fbtn_save.on(:press) {
            if (/^\d\d\:[0-5]\d\:[0-5]\d(\.\d\d\d)?$/ =~ fedt_time.text) != nil
              fedt_time.settext(fedt_time.text + ".000") if !fedt_time.text.include?(".")
              chaps[index] = [fedt_time.text, fedt_name.text]
              setchaps.call(chaps)
              frm.resume
            else
              speak(p_("EAPI_Form", "Wrong time format, the proper format is two hours digits, colon, two minutes digits, colon, two seconds digits and, optionally, three milliseconds digits preceeded by dot"))
            end
          }
          fbtn_cancel.on(:press) { frm.resume }
          frm.cancel_button = fbtn_cancel
          frm.accept_button = fbtn_save
          frm.wait
          lst_chapters.focus
        }
        lst_tags.on(:move) {
          edt_value.set_text(tgs[editable_tags[lst_tags.index]])
        }
        edt_value.on(:change) {
          tgs[editable_tags[lst_tags.index]] = edt_value.text
          tbld.call
        }
        lst_chapters.bind_context { |menu|
          menu.option(p_("EAPI_Form", "Add new chapter manually"), nil, "n") { editchap.call(-1) }
          menu.option(p_("EAPI_Form", "Add chapters with playback"), nil, "N") {
            frm = Form.new([
              fpl = Player.new(@current_filename, p_("EAPI_Form", "Chapters editor, use context menu to add chapters"), true, true),
              fbtn_close = Button.new(_("Close"))
            ], 0, false, true)
            frm.bind_context { |menu|
              menu.option(p_("EAPI_Form", "Add chapter here"), nil, :n) {
                paused = fpl.paused?
                if !paused
                  fpl.stop
                end
                name = input_text(p_("EAPI_Form", "Chapter name"), 0, "", true)
                time = fpl.position
                time = sprintf("%02d:%02d:%02d.%03d", time / 3600, (time / 60) % 60, time % 60, time - time.to_i)
                if !paused
                  fpl.play
                end
                if name != nil
                  chaps = getchaps.call
                  chaps.push([time, name])
                  setchaps.call(chaps)
                end
              }
            }
            fbtn_close.on(:focus) { fpl.stop }
            fpl.on(:focus) { fpl.play }
            fbtn_close.on(:press) { frm.resume }
            frm.cancel_button = fbtn_close
            frm.accept_button = fbtn_close
            frm.wait
            fpl.close
            lst_chapters.focus
          }
          if lst_chapters.options.size > 0
            menu.option(p_("EAPI_Form", "Edit chapter"), nil, "e") { editchap.call(lst_chapters.index) }
            menu.option(_("Delete"), nil, :del) { delchap.call(lst_chapters.index) }
          end
        }
        tbld.call
        lst_tags.trigger(:move)
        btn_save.on(:press) {
          @tags = tgs
          alert(_("Saved"))
          form.resume
        }
        btn_cancel.on(:press) { form.resume }
        form.cancel_button = btn_cancel
        form.wait
      end

      def show
        @form.index = 0
        @form.wait
      end

      def empty?
        @status == 0
      end

      def set_source(file)
        @btn_stop.press if @recorder != nil
        @status = 2
        @current_filename = file
        @form.show(@btn_tags) if holds_premiumpackage("audiophile")
        @form.show(@btn_play)
        if file[0..4] == "http:" or file[0..5] == "https:"
          @form.hide(@btn_encodeplay)
        else
          @form.show(@btn_encodeplay)
        end
        @form.show(@btn_delete)
      end

      def get_file(force = false)
        @last_tags ||= nil
        return nil if @status != 2
        if @current_filename[0..4] == "http:" || @current_filename[0..5] == "https:"
          if force
            tmp = rand(36 ** 16).to_s(36)
            file = Dirs.temp + "\\" + tmp
            download_file(@current_filename, file)
            @current_filename = @filename = file
          else
            return nil
          end
        end
        if @filename != @current_filename
          waiting {
            OpusRecorder.encode_file(@current_filename, @filename, @bitrate, @framesize, @application, @usevbr, @timelimit, get_tags(false))
          }
          @current_filename = @filename
          @last_tags = get_tags
          @form.hide(@btn_encodeplay)
        elsif @last_tags != get_tags
          @tempname = @filename + "_edtags.opus"
          c = OpusRecorder.copy_file(@filename, @tempname, get_tags)
          if c > 0
            @last_tags = get_tags
            File.delete(@filename)
            Win32API.new("kernel32", "MoveFileW", "PP", "i").call(unicode(@tempname), unicode(@filename))
          end
        end
        return @filename
      end
    end

    class DateButton < Button
      attr_reader :year, :month, :day, :hour, :min, :sec

      def initialize(label, minyear = 1900, maxyear = 2100, includehour = false)
        @year, @month, @day, @hour, @min, @sec = 0, 0, 0, 0, 0, 0
        @dlabel = label
        genlabel
        super(@label)
        @minyear = minyear
        @maxyear = maxyear
        @includehour = includehour
        @years = (@minyear..@maxyear).to_a.map { |y| y.to_s }
        @months = [p_("EAPI_Form", "January"), p_("EAPI_Form", "February"), p_("EAPI_Form", "March"), p_("EAPI_Form", "April"), p_("EAPI_Form", "May"), p_("EAPI_Form", "June"), p_("EAPI_Form", "July"), p_("EAPI_Form", "August"), p_("EAPI_Form", "September"), p_("EAPI_Form", "October"), p_("EAPI_Form", "November"), p_("EAPI_Form", "December")]
        @days = (1..31).to_a.map { |d| d.to_s }
        @hours = (0..23).to_a.map { |h| sprintf("%02d", h) }
        @mins = (0..59).to_a.map { |m| sprintf("%02d", m) }
        @secs = (0..59).to_a.map { |s| sprintf("%02d", s) }
        @form = Form.new([
          @sel_year = ListBox.new([p_("EAPI_Form", "Not selected")] + @years, p_("EAPI_Form", "Year")),
          @sel_month = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Month")),
          @sel_day = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Day")),
          @sel_hour = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Hour")),
          @sel_min = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Minute")),
          @sel_sec = ListBox.new([p_("EAPI_Form", "Not selected")], p_("EAPI_Form", "Second")),
          @btn_select = Button.new(p_("EAPI_Form", "Ready")),
          @btn_cancel = Button.new(_("Cancel"))
        ], 0, false, true)
        if @includehour == false
          @form.hide(@sel_hour)
          @form.hide(@sel_min)
          @form.hide(@sel_sec)
        end
        @form.cancel_button = @btn_cancel
        @form.accept_button = @btn_select
        @btn_cancel.on(:press) { @form.resume }
        @btn_select.on(:press) {
          if @sel_year.index == 0
            @year = 0
          else
            @year = @sel_year.index + @minyear - 1
          end
          @month = @sel_month.index
          @day = @sel_day.index
          if @year == 0 || @month == 0 || @day == 0
            @year = 0
            @month = 0
            @day = 0
          end
          if @includehour == true
            @hour = @sel_hour.index - 1
            @min = @sel_min.index - 1
            @sec = @sel_sec.index - 1
            if @hour == -1 || @min == -1 || @sec == -1
              @year = 0
              @month = 0
              @day = 0
              @hour = -1
              @min = -1
              @sec = -1
            end
          end
          @form.resume
        }
        @sel_year.on(:move) {
          if @sel_year.index == 0
            @sel_month.options = [p_("EAPI_Form", "Not selected")]
          else
            @sel_month.options = [p_("EAPI_Form", "Not selected")] + @months
          end
          @sel_month.index -= 1 while @sel_month.index >= @sel_month.options.size
          @sel_month.trigger(:move, @sel_month.index)
        }
        @sel_month.on(:move) {
          if @sel_month.index == 0
            @sel_day.options = [p_("EAPI_Form", "Not selected")]
          else
            days = 31
            days = 30 if [4, 6, 9, 11].include?(@sel_month.index)
            if @sel_month.index == 2
              if (@sel_year.index + @minyear - 1) % 4 == 0 && (((@minyear + @sel_year.index - 1) % 100) != 0 || ((@minyear + @sel_year.index - 1) % 400) == 0)
                days = 29
              else
                days = 28
              end
            end
            @sel_day.options = [p_("EAPI_Form", "Not selected")] + @days[0...days]
          end
          @sel_day.index -= 1 while @sel_day.index >= @sel_day.options.size
          @sel_day.trigger(:move, @sel_day.index)
        }
        @sel_day.on(:move) {
          if @sel_day.index == 0
            @sel_hour.options = [p_("EAPI_Form", "Not selected")]
          else
            @sel_hour.options = [p_("EAPI_Form", "Not selected")] + @hours
          end
          @sel_hour.index -= 1 while @sel_hour.index >= @sel_hour.options.size
          @sel_hour.trigger(:move, @sel_hour.index)
        }
        @sel_hour.on(:move) {
          if @sel_hour.index == 0
            @sel_min.options = [p_("EAPI_Form", "Not selected")]
          else
            @sel_min.options = [p_("EAPI_Form", "Not selected")] + @mins
          end
          @sel_min.index -= 1 while @sel_min.index >= @sel_min.options.size
          @sel_min.trigger(:move, @sel_min.index)
        }
        @sel_min.on(:move) {
          if @sel_min.index == 0
            @sel_sec.options = [p_("EAPI_Form", "Not selected")]
          else
            @sel_sec.options = [p_("EAPI_Form", "Not selected")] + @mins
          end
          @sel_sec.index -= 1 while @sel_sec.index >= @sel_sec.options.size
          @sel_sec.trigger(:move, @sel_sec.index)
        }
      end

      def genlabel
        @label = @dlabel + ": "
        if @year == 0
          @label += p_("EAPI_Form", "Not selected")
        else
          if @includehour == false
            @label += sprintf("%04d-%02d-%02d", @year, @month, @day)
          else
            @label += sprintf("%04d-%02d-%02d, %02d:%02d:%02d", @year, @month, @day, @hour, @min, @sec)
          end
        end
      end

      def focus(*arg)
        genlabel
        super(*arg)
      end

      def update
        super
        if @pressed
          show
          focus
        end
      end

      def show
        @form.index = 0
        @form.wait
      end

      def setdate(year, month, day, hour, min, sec)
        @year, @month, @day, @hour, @min, @sec = year, month, day, hour, min, sec
        genlabel
        @sel_year.index = @year - @minyear + 1
        @sel_year.trigger(:move, @sel_year.index)
        @sel_month.index = @month
        @sel_month.trigger(:move, @sel_month.index)
        @sel_day.index = @day
        @sel_day.trigger(:move, @sel_day.index)
        @sel_hour.index = @hour + 1
        @sel_min.index = @min + 1
        @sel_sec.index = @sec + 1
      end
    end
  end

  include Controls
end
