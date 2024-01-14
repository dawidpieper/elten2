# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2022 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

module EltenAPI
  module Common
    private

    # EltenAPI common functions
    # Opens the quit menu
    #
    # @param header [String] a message to read, header of the menu
    def quit(header = p_("EAPI_Common", "Exit..."))
      dialog_open
      sel = ListBox.new([_("Cancel"), p_("EAPI_Common", "Hide program in Tray"), _("Exit")], header, 0, ListBox::Flags::AnyDir, false)
      sel.disable_menu
      loop do
        loop_update
        sel.update
        if $key[0x11] and $key[81]
          sel.options = ["Zabieraj mi to okno", "Spadaj z mojego pulpitu", "Mam ciebie dość, zamknij się", "Zejdź mi z oczu"]
          sel.focus
        end
        if escape
          sel.enable_menu
          dialog_close
          break
          $exit = false
          return(false)
        end
        if enter
          sel.enable_menu
          loop_update
          dialog_close
          case sel.index
          when 0
            break
            $exit = false
            return(false)
          when 1
            $exit = false
            tray
            return false
          when 2
            $scene = nil
            break
            $exit = true
            return(true)
            $exit = false
            return false
          when 3
            return quit("W zasadzie, jak mam zejść z oczu osobie niewidomej? Nie rozumiem. Proszę o doprecyzowanie.")
          end
        end
      end
    end

    class Console
      attr_reader :codes

      def initialize
        @b = binding
        @codes = []
        @hooks = []
      end

      def run(code)
        @codes.unshift(code)
        @codes.pop while @codes.size > 50
        return eval(code, @b, "Console")
      end

      def on_str(&h)
        @hooks.push(h) if h != nil
      end

      def puts(t)
        @hooks.each { |h| h.call(t.to_s) }
        return nil
      end
    end

    # Opens a console
    def console
      form = Form.new([
        EditBox.new(p_("EAPI_Common", "Enter the command to execute"), EditBox::Flags::MultiLine, "", true),
        EditBox.new(p_("EAPI_Common", "Output"), EditBox::Flags::ReadOnly, "", true),
        Button.new(p_("EAPI_Common", "Execute"))
      ])
      container = Console.new
      container.on_str { |str| form.fields[1].set_text(form.fields[1].text + "\r\n" + str) }
      form.bind_context { |menu|
        if LocalConfig["ConsoleAutoClearInput"] == 1
          s = p_("EAPI_Common", "Disable auto clear input")
        else
          s = p_("EAPI_Common", "Enable auto clear input")
        end
        menu.option(s, nil, "i") {
          if LocalConfig["ConsoleAutoClearInput"] == 1
            LocalConfig["ConsoleAutoClearInput"] = 0
            alert(p_("EAPI_Common", "Disabled"))
          else
            LocalConfig["ConsoleAutoClearInput"] = 1
            alert(p_("EAPI_Common", "Enabled"))
          end
        }
        if LocalConfig["ConsoleAutoClearOutput"] == 1
          s = p_("EAPI_Common", "Disable auto clear output")
        else
          s = p_("EAPI_Common", "Enable auto clear output")
        end
        menu.option(s, nil, "o") {
          if LocalConfig["ConsoleAutoClearOutput"] == 1
            LocalConfig["ConsoleAutoClearOutput"] = 0
            alert(p_("EAPI_Common", "Disabled"))
          else
            LocalConfig["ConsoleAutoClearOutput"] = 1
            alert(p_("EAPI_Common", "Enabled"))
          end
        }
        #By default, source should be copied to output.
        if LocalConfig["ConsoleDontCopySource"] == 1
          s = p_("EAPI_Common", "Enable source in output")
        else
          s = p_("EAPI_Common", "Disable source in output")
        end
        menu.option(s, nil, "s") {
          if LocalConfig["ConsoleDontCopySource"] == 1
            LocalConfig["ConsoleDontCopySource"] = 0
            alert(p_("EAPI_Common", "Enabled"))
          else
            LocalConfig["ConsoleDontCopySource"] = 1
            alert(p_("EAPI_Common", "Disabled"))
          end
        }
        if container.codes.size > 0
          menu.option(p_("EAPI_Common", "Load last code"), nil, "l") {
            form.fields[0].set_text(container.codes[0])
            form.focus
          }
          menu.submenu(p_("EAPI_Common", "Last codes")) { |m|
            for c in container.codes
              menu.option(c[0...100], c) { |c|
                form.fields[0].set_text(c)
                form.focus
              }
            end
          }
        end
      }
      loop do
        loop_update
        form.update
        if form.fields[2].pressed? or ($keyr[0x11] and enter)
          kom = form.fields[0].text
          if LocalConfig["ConsoleDontCopySource"] == 1
            outKom = ""
          else
            outKom = kom
          end
          if LocalConfig["ConsoleAutoClearOutput"] == 1
            form.fields[1].set_text(outKom)
          else
            form.fields[1].set_text(form.fields[1].text + "\r\n\r\n" + outKom)
          end
          begin
            r = container.run(kom).inspect
          rescue Exception
            plc = ""
            if $@.is_a?(Array)
              for e in $@
                if e != nil
                  plc += e + "\n" if e != nil and e[0..6] != "Section"
                end
              end
              lin = $@[0].split(":")[1].to_i
              plc += kom.delete("\r").split("\n")[lin - 1] || ""
            end
            r = $!.class.to_s + " (" + $!.to_s + ")\n" + plc
          end
          speak(r)
          form.fields[0].set_text("") if LocalConfig["ConsoleAutoClearInput"] == 1
          form.fields[1].set_text(form.fields[1].text + "\r\n#=> " + r, false)
          loop_update
        end
        if escape
          if form.fields[0].text == "" || confirm(p_("EAPI_Common", "Are you sure you want to exit console?")) == 1
            break
          end
        end
      end
    end

    # Opens a menu of a specified user
    #
    # @param user name of the user whose menu you want to open
    # @param submenu [Boolean] specifies if the menu is a submenu
    # @return [String] returns ALT if menu was closed using an alt menu
    def usermenu(user, submenu = false, left = false)
      ui = userinfo(user, true)
      return if ui == -1
      if ui[15] == true
        alert(p_("EAPI_Common", "This account is archived"))
        return
      end
      @incontacts = ui[8].to_b if Session.name != "guest"
      @isbanned = ui[10].to_b
      @hasblog = ui[1]
      @hashonors = (ui[11] > 0)
      @callable = ui[12].to_b
      @feedfollowed = ui[13].to_b
      @monitored = ui[14].to_b
      play("menu_open") if submenu != true
      Menu.menubg_play if submenu != true and (Configuration.bgsounds == 1 && Configuration.soundthemeactivation == 1)
      sel = [p_("EAPI_Common", "Write a private message"), p_("EAPI_Common", "Visiting card"), p_("EAPI_Common", "Open user's blog"), p_("EAPI_Common", "badges of this user")]
      if Session.name != "guest"
        if @incontacts == true
          sel.push(p_("EAPI_Common", "Remove from contacts' list"))
        else
          sel.push(p_("EAPI_Common", "Add to contacts' list"))
        end
        if @feedfollowed == true
          sel.push(p_("EAPI_Common", "Unfollow feed"))
        else
          sel.push(p_("EAPI_Common", "Follow feed"))
        end
      else
        sel.push("")
        sel.push("")
      end
      ringtone = false
      begin
        if FileTest.exists?(Dirs.eltendata + "\\ringtones.json")
          json = JSON.load(readfile(Dirs.eltendata + "\\ringtones.json"))
          ringtone = true if json[user].is_a?(String) && FileTest.exists?(json[user])
        end
      end
      if ringtone
        sel.push(p_("EAPI_Common", "Unset ringtone"))
      else
        sel.push(p_("EAPI_Common", "Set ringtone"))
      end
      sel.push(p_("EAPI_Common", "Call this user"))
      sel.push(p_("EAPI_Common", "Show feed"))
      if @monitored == false
        sel.push(p_("EAPI_Common", "Monitor when this user becomes online"))
      else
        sel.push(p_("EAPI_Common", "Do not monitor this user"))
      end
      if Session.moderator > 0
        if @isbanned == false
          sel.push(p_("EAPI_Common", "Ban"))
        else
          sel.push(p_("EAPI_Common", "Unban"))
        end
      else
        sel.push("")
      end
      if $usermenuextra.is_a?(Hash) and Session.name != "guest"
        for k in $usermenuextra.keys
          sel.push(k)
        end
      end
      if submenu == false
        menu = ListBox.new(sel, "", 0, ListBox::Flags::AnyDir)
      else
        menu = ListBox.new(sel, "")
      end
      menu.disable_item(2) if @hasblog == false
      if Session.name == "guest"
        menu.disable_item(0)
        menu.disable_item(4)
        menu.disable_item(5)
        menu.disable_item(6)
        menu.disable_item(7)
        menu.disable_item(9)
      end
      menu.disable_item(3) if @hashonors == false
      menu.disable_item(7) if @callable == false
      menu.disable_item(10) if Session.moderator == 0
      menu.focus
      loop do
        loop_update
        if enter
          play("menu_close")
          Menu.menubg_close
          case menu.index
          when 0
            insert_scene(Scene_Messages_New.new(user, "", "", Scene_Main.new), true)
            loop_update
            return "ALT"
          when 1
            visitingcard(user)
            return("ALT")
            break
          when 2
            insert_scene(Scene_Blog_List.new(user, Scene_Main.new), true)
            loop_update
            return "ALT"
            break
          when 3
            insert_scene(Scene_Honors.new(user, Scene_Main.new), true)
            loop_update
            return "ALT"
          when 4
            if @incontacts == true
              confirm(p_("EAPI_Common", "Are you sure you want to delete this contact?")) {
                insert_scene(Scene_Contacts_Delete.new(user, Scene_Main.new), true)
              }
            else
              insert_scene(Scene_Contacts_Insert.new(user, Scene_Main.new), true)
            end
            loop_update
            return "ALT"
          when 5
            prm = { "ac" => ((@feedfollowed) ? ("unfollow") : ("follow")), "user" => user }
            if srvproc("feeds", prm)[0].to_i == 0
              if @feedfollowed
                alert(p_("EAPI_Common", "Feed unfollowed"))
              else
                alert(p_("EAPI_Common", "Feed followed"))
              end
              $agent.write(Marshal.dump("func" => "feedreset"))
              Session.feeds_clear
            else
              alert(_("Error"))
            end
            loop_update
            return "ALT"
          when 6
            if ringtone
              set_ringtone(user, nil)
              alert(p_("EAPI_Common", "Ringtone removed"))
            else
              if requires_premiumpackage("audiophile")
                file = get_file(p_("EAPI_Common", "Select ringtone for user %{user}") % { "user" => user }, Dirs.documents + "\\", false, nil, [".mp3", ".wav", ".ogg", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff", ".w64"])
                if file != nil
                  set_ringtone(user, file)
                  alert(p_("EAPI_Common", "Ringtone changed"))
                end
              end
            end
          when 7
            voicecall(nil, nil, [user])
          when 8
            insert_scene(Scene_FeedViewer.new(user))
          when 9
            if @monitored == false
              opts = [p_("EAPI_Common", "Notify me one time when this user becomes online"), p_("EAPI_Common", "Notify me whenever this user becomes online")]
              o = selector(opts, p_("EAPI_Common", "Online monitor"), 0, -1)
              if o >= 0
                ot = srvproc("monitors", { "ac" => "add", "user" => user, "permanent" => o })
                if ot[0].to_i < 0
                  alert(_("Error"))
                else
                  alert(p_("EAPI_Common", "This user is now monitored"))
                end
              end
            else
              ot = srvproc("monitors", { "ac" => "del", "user" => user })
              if ot[0].to_i < 0
                alert(_("Error"))
              else
                alert(p_("EAPI_Common", "This user is no longer monitored"))
              end
            end
          when 10
            if @isbanned == false
              insert_scene(Scene_Ban_Ban.new(user, Scene_Main.new), true)
            else
              insert_scene(Scene_Ban_Unban.new(user, Scene_Main.new), true)
            end
            loop_update
            return "ALT"
          else
            if $usermenuextra.is_a?(Hash)
              a = $usermenuextra.values[menu.index - 11]
              s = a[0].new
              s.userevent(user, *a[1..-1])
              insert_scene(s, true)
              return "ALT"
              break
            end
          end
          break
        end
        if alt
          if submenu != true
            break
          else
            return("ALT")
            break
          end
        end
        if escape
          loop_update
          if submenu == true
            return
            break
          else
            break
          end
        end
        if ((arrow_up and !left and menu.index == 0) or (arrow_left and left)) and submenu == true
          loop_update
          return
          break
        end
        menu.update
      end
      Menu.menubg_close if submenu != true
      play("menu_close") if submenu != true
    end

    # Opens a what's new menu
    #
    # @param quiet [Boolean] if true, no text is read if there's nothing new
    def whatsnew(quiet = false)
      agtemp = srvproc("agent", { "client" => "1" })
      err = agtemp[0]
      messages = agtemp[8].to_i
      posts = agtemp[9].to_i
      blogposts = agtemp[10].to_i
      blogcomments = agtemp[11].to_i
      followedforums = agtemp[12].to_i
      followedforumsposts = agtemp[13].to_i
      friends = agtemp[14].to_i
      birthday = agtemp[15].to_i
      mentions = agtemp[16].to_i
      followedblogposts = agtemp[17].to_i
      blogfollowers = agtemp[18].to_i
      blogmentions = agtemp[19].to_i
      groupinvitations = agtemp[20].to_i
      $nversion = agtemp[2].to_f
      $nbeta = agtemp[3].to_i
      bid = srvproc("bin/buildid", { "branch" => get_updatesbranch, "build_id" => Elten.build_id }, 1).to_i
      if messages <= 0 and posts <= 0 and blogposts <= 0 and blogcomments <= 0 and followedforums <= 0 and followedforumsposts <= 0 and friends <= 0 and birthday <= 0 and mentions <= 0 and followedblogposts <= 0 and blogfollowers <= 0 and blogmentions <= 0 and groupinvitations <= 0 and (Elten.build_id == bid or bid <= 0)
        alert(p_("EAPI_Common", "There is nothing new.")) if quiet != true
      else
        $scene = Scene_WhatsNew.new(true, agtemp, bid)
      end
      speech_wait
    end

    # Creates a debug info
    #
    # @return [String] debug information which can be attached to a bug report etc.
    def createdebuginfo
      di = ""
      di += "*ELTEN | DEBUG INFO*\r\n"
      if $@ != nil
        if $! != nil
          di += $!.to_s + "\r\n" + $@.to_s + "\r\n"
        end
      end
      di += "\r\n[_Computer]\r\n"
      di += "OS version: " + (Win32API.new("kernel32", "GetVersion", "", "i").call >> 16).to_s + "\r\n"
      di += "Elten data path: " + Dirs.eltendata.to_s + "\r\n"
      procid = "\0" * 16384
      Win32API.new("kernel32", "GetEnvironmentVariable", "ppi", "i").call("PROCESSOR_IDENTIFIER", procid, procid.size)
      procid.delete!("\0")
      di += "Processor Identifier: " + procid.to_s + "\r\n"
      procnum = "\0" * 16384
      Win32API.new("kernel32", "GetEnvironmentVariable", "ppi", "i").call("NUMBER_OF_PROCESSORS", procnum, procnum.size)
      procnum.delete!("\0")
      di += "Number of processors: " + procnum.to_s + "\r\n"
      ramt = [0].pack("l")
      Win32API.new("kernel32", "GetPhysicallyInstalledSystemMemory", "p", "i").call(ramt)
      ram = ramt.unpack("l")[0] / 1024
      di += "RAM Memory: " + ram.to_s + "MB\r\n"
      memt = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0].pack("iiiiiiiiii")
      Win32API.new("psapi", "GetProcessMemoryInfo", "ipi", "i").call($process, memt, memt.size)
      di += "Memory usage: " + (memt.unpack("i" * 9)[3] / 1048576).to_s + "MB\r\n"
      di += "Peak memory usage: " + (memt.unpack("i" * 9)[2] / 1048576).to_s + "MB\r\n"
      cusername = "\0" * 16384
      Win32API.new("kernel32", "GetEnvironmentVariable", "ppi", "i").call("USERNAME", cusername, cusername.size)
      cusername.delete!("\0")
      di += "User name: " + cusername.to_s + "\r\n"
      di += "\r\n[_Elten]\r\n"
      di += "User: " + Session.name.to_s + "\r\n"
      di += "Token: " + Session.token.to_s + "\r\n"
      ver = $version.to_s
      ver += "_BETA" if $isbeta == 1
      ver += "_RC" if $isbeta == 2
      ver += $beta.to_s if $isbeta == 1
      di += "Version: " + ver.to_s + "\r\n"
      di += "URL: " + $url.to_s + "\r\n"
      di += "Start time: " + $start.to_s + "\r\n"
      di += "Current time: " + Time.now.to_i.to_s + "\r\n"
      di += "\r\n"
      di += readfile(Dirs.eltendata + "\\elten.ini")
      return di
    end

    # Sends a bug report
    #
    # @param getinfo [Boolean] ask a user to describe the bug
    # @param info [String] predefined information
    # @return [Numeric] return 0 if succeeds, otherwise the return value is an error code
    def bug(getinfo = true, info = "")
      loop_update
      if getinfo == true
        info = prompt(p_("EAPI_Common", "Describe the found error"), p_("EAPI_Common", "Send"))
        if info == ""
          return 1
        end
        info += "\r\n|||\r\n\r\n\r\n\r\n\r\n\r\n"
      end
      di = createdebuginfo
      info += di
      bugtemp = srvproc("bug", {}, 0, { "buginfo" => info })
      err = bugtemp[0].to_i
      if err != 0
        alert(_("Error"))
        r = err
      else
        alert(p_("EAPI_Common", "Sent."))
        r = 0
      end
      speech_wait
      return r
    end

    # Opens a list of contacts allowing user to select one
    #
    # @return [String] returns a selected contact name, if cancelled, the return value is nil
    def selectcontact
      ct = srvproc("contacts", {})
      err = ct[0].to_i
      case err
      when -1
        alert(_("Database Error"))
        $scene = Scene_Main.new
        return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      contact = []
      for i in 1..ct.size - 1
        ct[i].delete!("\r\n")
      end
      for i in 1..ct.size - 1
        contact.push(ct[i]) if ct[i].size > 1
      end
      if contact.size < 1
        speak(p_("EAPI_Common", "Empty list"))
        speech_wait
      end
      selt = []
      for i in 0..contact.size - 1
        selt[i] = contact[i] + ". " + getstatus(contact[i])
      end
      sel = ListBox.new(selt, p_("EAPI_Common", "Select contact"), 0, 0, false)
      loop do
        loop_update
        sel.update if contact.size > 0
        if escape
          loop_update
          $focus = true
          return(nil)
        end
        if enter and contact.size > 0
          loop_update
          $focus = true
          play("listbox_select")
          return(contact[sel.index])
        end
      end
    end

    # Opens a visitingcard of a specified user
    #
    # @param user [String] user whose visitingcard you want to open
    def visitingcard(user = Session.name)
      vc = srvproc("visitingcard", { "searchname" => user })
      pr = srvproc("profile", { "get" => "1", "searchname" => user })
      if vc[0].to_i < 0
        alert(_("Database Error"))
        return -1
      end
      dialog_open
      text = ""
      honor = gethonor(user)
      text += "#{if honor == nil; p_("EAPI_Common", "User"); else; honor; end}: #{user} \r\n"
      text += getstatus(user, false, false)
      text += "\r\n"
      fullname = ""
      gender = -1
      birthdateyear = 0
      birthdatemonth = 0
      birthdateday = 0
      location = ""
      if pr[0].to_i == 0
        fullname = pr[1].delete("\r\n")
        gender = pr[2].delete("\r\n").to_i
        if pr[3].to_i > 1900 and pr[4].to_i > 0 and pr[4].to_i < 13 and pr[5].to_i > 0 and pr[5].to_i < 32
          birthdateyear = pr[3].delete("\r\n")
          birthdatemonth = pr[4].delete("\r\n")
          birthdateday = pr[5].delete("\r\n")
        end
        location = pr[6].delete("\r\n")
        text += fullname + "\r\n"
        text += "#{p_("EAPI_Common", "Gender")}: "
        if gender == 0
          text += "#{_("Female")}\r\n"
        else
          text += "#{_("male")}\r\n"
        end
        if birthdateyear.to_i > 0
          age = Time.now.year - birthdateyear.to_i
          if Time.now.month < birthdatemonth.to_i
            age -= 1
          elsif Time.now.month == birthdatemonth.to_i
            if Time.now.day < birthdateday.to_i
              age -= 1
            end
          end
          age -= 2000 if age > 2000
          text += "#{p_("EAPI_Common", "Age")}: #{age.to_s}\r\n"
        end
        if location != "" and (location.to_i > 0 or Lists.locations.map { |l| l["country"] }.uniq.include?(location))
          text += p_("EAPI_Common", "Location") + ": "
          if location.to_i > 0
            loc = {}
            Lists.locations.each { |l| loc = l if l["geonameid"] == location.to_i }
            text += (loc["name"] || "") + ", " + (loc["country"] || "") if loc != nil
          else
            text += location
          end
          text += "\r\n"
        end
      end
      ui = userinfo(user)
      if ui != -1
        if gender == 0
          text += p_("EAPI_Common_female", "Last seen")
        elsif gender == 1
          text += p_("EAPI_Common_male", "Last seen")
        else
          text += p_("EAPI_Common", "Last seen")
        end
        text += ": " + ui[0] + "\r\n"
        text += p_("EAPI_Common", "User has a blog") + "\r\n" if ui[1] == true
        text += "#{np_("EAPI_Common", "Knows %{count} user", "Knows %{count} users", ui[2]) % { "count" => ui[2].to_s }}\r\n"
        if gender == -1
          text += np_("EAPI_Common", "Known by %{count} user", "Known by %{count} users", ui[3]) % { "count" => ui[3].to_s }
        elsif gender == 0
          text += np_("EAPI_Common_female", "Known by %{count} user", "Known by %{count} users", ui[3]) % { "count" => ui[3].to_s }
        elsif gender == 1
          text += np_("EAPI_Common_male", "Known by %{count} user", "Known by %{count} users", ui[3]) % { "count" => ui[3].to_s }
        end
        text += "\r\n"
        text += "#{p_("EAPI_Common", "Forum posts")}: " + ui[4].to_s + "\r\n"
        text += "#{p_("EAPI_Common", "Polls answered")}: " + ui[7].to_s.delete("\r\n") + "\r\n"
        v = ""
        ui[5].split(" ").each { |e|
          if v == ""
            e = e.delete(".").split("").join(".")
          else
            v += " "
          end
          v += e
        }
        text += "#{p_("EAPI_Common", "Used version")}: " + v + "\r\n"
        text += "#{p_("EAPI_Common", "Registered")}: " + ui[6].to_s.split(" ")[0] + "\r\n" if ui[6] != ""
      end
      if vc[1] != "     " and vc.size != 1
        text += "\r\n\r\n"
        for i in 1..vc.size - 1
          text += vc[i]
        end
      end
      input_text(p_("EAPI_Common", "Visiting card of %{user}:") % { "user" => user }, EditBox::Flags::ReadOnly | EditBox::Flags::MultiLine, text, true)
      $focus = true if $scene.is_a?(Scene_Main) == false
      dialog_close
      return 0
    end

    # Shows user agreement
    #
    # @param omit [Boolean] determines whether to allow user to close the window without accepting
    def license(omit = false)
      @license = licensetext
      @rules = _doc("rules")
      @privacypolicy = _doc("privacypolicy")
      form = Form.new([
        EditBox.new(p_("EAPI_Common", "License agreement"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly | EditBox::Flags::MarkDown, @license, true),
        EditBox.new(p_("EAPI_Common", "Terms and Conditions"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly | EditBox::Flags::MarkDown, @rules, true),
        EditBox.new(p_("EAPI_Common", "Privacy Policy"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly | EditBox::Flags::MarkDown, @privacypolicy, true),
        Button.new(p_("EAPI_Common", "I accept Elten license agreement, Terms and Conditions and Privacy Policy")), Button.new(p_("EAPI_Common", "I do not accept, exit"))
      ])
      loop do
        loop_update
        form.update
        if (enter or space) and form.index == 4
          exit
        end
        if (space or enter) and form.index == 3
          break
        end
        if escape
          if omit == true
            break
          else
            if form.index == 0 or form.index == 1
              form.index += 1
              form.focus
            else
              q = confirm(p_("EAPI_Common", "Do you accept Elten license agreement, terms and conditions and privacy policy?"))
              if q == 0
                exit
              else
                break
              end
            end
          end
        end
      end
    end

    # Opens an audio player
    #
    # @param file [String] a location or URL of a media to play
    # @param label [String] player window caption
    # @param wait [Boolean] close a player after audio is played
    # @param control [Boolean] allow user to control the played audio, by for example scrolling it
    # @param trydownload [Boolean] download a file if the codec doesn't support streaming
    def player(file, label = "", wait = false, control = true, trydownload = false, stream = false)
      if File.extname(file).downcase == ".mid" and FileTest.exists?(Dirs.extras + "\\soundfont.sf2") == false
        if confirm(p_("EAPI_Common", "You are trying to play a midi file. In order to play such files, Elten needs an  external base of instruments. Do you want to download the base from the server  now? It may take several minutes.")) == 1
          alert(p_("EAPI_Common", "Please wait, the soundfont is being downloaded. It may take a while."))
          download_file($url + "extras/soundfont.sf2", Dirs.extras + "\\soundfont.sf2")
          alert(p_("EAPI_Common", "Soundfont downloaded succesfully."))
          Win32API.new("bass", "BASS_SetConfigPtr", "ip", "l").call(0x10403, Dirs.extras + "\\soundfont.sf2")
        else
          return
        end
      end
      if label != ""
        dialog_open if wait == false
        dialog_mute
      end
      snd = Player.new(file, label, true, false)
      delay(0.1)
      loop do
        loop_update
        snd.update if control
        if wait == true
          if snd.sound != nil
            if snd.pause != true
              if snd.sound.position(true) >= snd.sound.length(true) - 1024 and snd.sound.length(true) > 0
                snd.close
                return
                break
              end
            end
          end
        end
        if (enter and !$key[0x10]) or escape or snd.sound == nil
          snd.fade
          snd.close
          dialog_close if label != ""
          break
        end
      end
    end

    # gets a key pressed by user
    #
    # @param keys [Array] a keyboard state
    # @param multi [Boolean] support multikeys
    # @return [String] returns pressed key or keys, if nothing pressed, the return value is an empty string
    # @example read the pressed keys
    #  loop do
    #   speech(getkeychar)
    #   break if escape
    #  end
    def getkeychar(keybd = nil, multi = false)
      @@deadkey ||= nil
      akey = $key
      akey = keybd if keybd != nil
      keybd = $keybd if keybd == nil
      keybd = keybd.map { |k| ((k) ? (255) : (0)) }.pack("C*") if keybd.is_a?(Array)
      akey = akey.unpack("c*").map { |k| k < 0 } if !akey.is_a?(Array)
      ret = ""
      lng = Win32API.new("user32", "GetKeyboardLayout", "i", "l").call(0).to_s(2)[16..31].to_i(2)
      toUnicode = Win32API.new("user32", "ToUnicode", "iippi", "i")
      for i in 32..255
        if akey[i]
          c = "\0" * 16
          a = nil
          a = toUnicode.call(i, 0, keybd, c, c.bytesize / 2)
          if @@deadkey == nil
            a = toUnicode.call(i, 0, keybd, c, c.bytesize / 2)
          end
          bc = c + ""
          if a == -1
            @@deadkey = [i, 0, keybd]
            break
          elsif @@deadkey != nil
            play("signal")
            a = toUnicode.call(@@deadkey[0], @@deadkey[1], @@deadkey[2], c, c.bytesize / 2)
            a = toUnicode.call(i, 0, keybd, c, c.bytesize / 2)
            @@deadkey = nil
          end
          if a > 0
            re = deunicode(c)
            ret = re if re != "" and re[0] >= 32
          end
        end
      end
      $lastkeychar = [ret, Time.now.to_i * 1000000 + Time.now.usec.to_i] if ret != ""
      return ret
    end

    # @note this function is reserved for Elten usage
    def thr1
      tir = Win32API.new("bin\\nvdaHelperRemote", "nvdaController_testIfRunning", "", "i")
      ss = Win32API.new("bin\\nvdaHelperRemote", "nvdaController_cancelSpeech", "", "i")
      loop do
        begin
          sleep(0.1)
          if Configuration.voice != "NVDA"
            if !NVDA.check and tir.call == 0
              ss.call
            end
          end
        rescue Exception
          fail
        end
      end
    end

    # @note this function is reserved for Elten usage
    def thr2
      $subthreads = [] if $subthreads == nil
      loop do
        sleep(0.05)
        if $scenes.size > 0
          if $currentthread != $mainthread
            $subthreads.push($currentthread)
          end
          $currentthread = Thread.new do
            stopct = false
            sc = $scene
            sleep(0.1)
            begin
              if stopct == false
                newsc = $scenes[0]
                $scenes.delete_at(0)
                $scene = newsc
                while $scene != nil and $scene.is_a?(Scene_Main) == false and $exit != true
                  Log.debug("Loading parallel scene: #{$scene.class.to_s}")
                  $scene.main
                end
                $scene = sc
                $scene = Scene_Main.new if $scene.is_a?(Scene_Main) or $scene == nil
                $scene = nil if $exit == true
                $key[0..255] = [false] * 256
                $focus = true if $scene.is_a?(Scene_Main) == false and $scene != nil
                Log.info("Exiting parallel scenes thread")
              end
            rescue Exception
              stopct = true
              $scene = sc
              $scene = Scene_Main.new if $scene.is_a?(Scene_Main) or $scene == nil
              loop_update
              $focus = true if $scene.is_a?(Scene_Main) == false
              Log.error("Parallel scene: #{$!.to_s} #{$@.to_s}")
              retry
            end
            sleep(0.1)
          end
        end
        if $switchthread != nil
          cr = $switchthread
          $switchthread = nil
          cur = $currentthread
          $subthreads.push(cur) if cur != nil
          $subthreads.delete(cr)
          $currentthread = cr
        end
        if $currentthread != $mainthread
          if $currentthread.status == false or $currentthread.status == nil
            if $subthreads.size > 0
              $currentthread = $subthreads.last
              while $subthreads.last.status == false or $subthreads.last.status == nil
                $subthreads.delete_at($subthreads.size - 1)
              end
              $subthreads.delete_at($subthreads.size - 1)
            else
              $currentthread = $mainthread
            end
          end
        end
        sleep(0.1)
      end
    rescue Exception
      retry
    end

    # @note this function is reserved for Elten usage
    def agent_start
      Log.info("Starting Agent")
      #return if $ruby
      $agent = ChildProc.new("bin\\rubyw --jit -Cbin agent.dat\"")
      $agent.write(Marshal.dump({ "func" => "relogin", "name" => Session.name, "token" => Session.token, "hwnd" => $wnd })) if Session.name != "" and Session.name != nil and Session.name != "guest"
      pid = Win32API.new("kernel32", "GetCurrentProcessId", "", "i").call
      $agent.write(Marshal.dump({ "func" => "superpid", "superpid" => pid }))
      @@hrtf_loaded = false
      sleep(0.1)
    end

    @@hrtf_loaded = false

    def load_hrtf(download = true)
      return true if @@hrtf_loaded == true
      hrtfcrc = 4103889778
      loc = Dirs.extras + "\\phonon.dll"
      if FileTest.exists?(loc) && Zlib.crc32(readfile(loc)) == hrtfcrc
        $agent.write(Marshal.dump({ "func" => "steamaudio_load", "file" => loc }))
        @@hrtf_loaded = true
        return true
      elsif download == false
        return false
      else
        if confirm(p_("EAPI_Common", "In order to use HRTF functionality, Elten needs to download Phonon library. Would you like to download it now?")) == 1
          download_file($url + "/extras/phonon.dll", Dirs.extras + "\\phonon.dll", true, false, true)
          return load_hrtf
        else
          return false
        end
      end
      return false
    end

    @@premiumpackages = []

    def update_premiumpackages(packages)
      @@premiumpackages = packages if packages.is_a?(Array)
    end

    def holds_premiumpackage(package)
      return false if Session.name == "" || Session.name == nil || Session.name == "guest"
      return @@premiumpackages.include?(package)
    end

    def requires_premiumpackage(package)
      return true if holds_premiumpackage(package)
      package_name = ""
      case package
      when "courier"
        package_name = p_("EAPI_Common", "Courier")
      when "audiophile"
        package_name = p_("EAPI_Common", "Audiophile")
      when "scribe"
        package_name = p_("EAPI_Common", "Scribe")
      when "director"
        package_name = p_("EAPI_Common", "Director")
      end
      confirm(p_("EAPI_Common", "This feature requires %{package} premium package. Would you like to see the premium packages available?") % { "package" => package_name }) {
        insert_scene(Scene_PremiumPackages.new)
      }
      return false
    end

    # Gets the size of a file or directory
    #
    # @param location [String] a location to a file or directory
    # @param upd [Boolean] window refreshing
    # @return [Numeric] a size in bytes
    def getsize(location, upd = true)
      if File.file?(location)
        sz = File.size(location)
        sz = 0 if sz < 0
        return sz
      end
      return Dir.size(location)
    end

    def createdirifneeded(dir)
      if !FileTest.exists?(dir)
        Log.debug("Dir not exists so creating: #{dir}")
        Win32API.new("kernel32", "CreateDirectoryW", "pp", "i").call(unicode(dir), nil)
      end
    end

    # Deletes a specified directory with all subdirectories
    #
    # @param dir [String] a directory location
    # @param with [Boolean] if false, deletes all subentries of the directory, but does not delete that directory
    def deldir(dir, with = true)
      return if !File.directory?(dir)
      Log.debug("Deleting directory #{dir}")
      dr = Dir.entries(dir)
      dr.delete("..")
      dr.delete(".")
      for t in dr
        f = dir + "/" + t
        if File.directory?(f)
          deldir(f)
        else
          File.delete(f)
        end
      end
      Win32API.new("kernel32", "RemoveDirectoryW", "p", "i").call(unicode(dir)) if with == true
    end

    def copyfile(source, destination, override = true)
      Log.debug("Copying file: (#{source}, #{destination})")
      c = 1
      c = 0 if override
      Win32API.new("kernel32", "CopyFileW", "ppi", "i").call(unicode(source), unicode(destination), c)
    end

    # Copies a directory with all files and subdirectories
    #
    # @param source [String] a location of directory to copy
    # @param destination [String] destination
    def copydir(source, destination, esource = nil, edestination = nil)
      Log.debug("Copying directory (#{source}, #{destination})")
      if esource == nil
        esource = source
        edestination = destination
      end
      loop_update
      Win32API.new("kernel32", "CreateDirectoryW", "pp", "i").call(unicode(destination), nil)
      e = Dir.entries(esource)
      e.delete("..")
      e.delete(".")
      ec = Dir.entries(esource)
      ec.delete(".")
      ec.delete("..")
      for i in 0..ec.size - 1
        if File.directory?(esource + "\\" + ec[i])
          copydir(source + "\\" + e[i], destination + "\\" + e[i], esource + "\\" + ec[i], edestination + "\\" + ec[i])
        else
          begin
            copyfile(source + "\\" + e[i], destination + "\\" + e[i])
          rescue Exception
          end
        end
      end
    end

    def getfileversioninfo(file, verinfo)
      pk = [0].pack("I")
      size = Win32API.new("Api-ms-win-core-version-l1-1-0.dll", "GetFileVersionInfoSizeW", "pp", "i").call(unicode(file), pk)
      return nil if size == 0
      vi = "\0" * size
      Win32API.new("Api-ms-win-core-version-l1-1-0.dll", "GetFileVersionInfoW", "piip", "i").call(unicode(file), 0, size, vi)
      len = [0].pack("I")
      Win32API.new("Api-ms-win-core-version-l1-1-0.dll", "VerQueryValueW", "pppp", "i").call(vi, unicode("\\StringFileInfo\\040904b0\\#{verinfo}"), pk, len)
      str = "\0" * len.unpack("I").first * 2
      Win32API.new("kernel32", "RtlMoveMemory", "pii", "i").call(str, pk.unpack("I").first, len.unpack("I").first * 2)
      return deunicode(str)
    rescue Exception
      return nil
    end

    # @note this function is reserved for Elten usage
    def tray
      if $ruby == true
        alert(_("Function not supported on this platform"))
        return
      end
      $totray = true
    end

    # Gets the main honor of specified user
    #
    # @param user [String] user name
    # @return [String] return a honor, if no honor selected, returns nil
    def gethonor(user)
      hn = srvproc("honors", { "list" => "1", "user" => user, "main" => "1" })
      if hn[0].to_i < 0 or hn[1].to_i == 0
        return nil
      end
      if Configuration.language == "pl-PL"
        return hn[3].delete("\r\n")
      else
        return hn[5].delete("\r\n")
      end
    end

    def decompress(source, destination, msg = "")
      speech(msg)
      waiting {
        executeprocess("bin\\7za x \"#{source}\" -y -o\"#{destination}\"", true)
      }
    end

    def compress(source, destination, msg = p_("EAPI_Common", "Compressing..."))
      speech(msg)
      waiting {
        ext = File.extname(destination).downcase
        cmd = ""
        cmd = "bin\\7za a \"#{destination}\" \"#{source}\" -y"
        executeprocess(cmd, true)
      }
    end

    def process_notification(notif)
      play(notif["sound"]) if notif["sound"] != nil
      speech(notif["alert"]) if notif["alert"] != nil
    end

    def register_activity
      return if Session.name == nil or Session.name == "" or Session.name == "guest" or $agent == nil
      $activitytime = Time.now.to_i
      $activity.keys.each { |k| $activity[k] = $activity[k].round }
      $agent.write(Marshal.dump({ "func" => "activity_register", "activity" => $activity, "config" => Configuration.to_h }))
      $activity.clear
      Log.debug("User activity report generated and sent to server")
    end

    def set_ringtone(user, file)
      json = {}
      begin
        if FileTest.exists?(Eltendata + "\\ringtones.json")
          json = JSON.load(readfile(Dirs.eltendata + "\\ringtones.json"))
        end
      rescue Exception
      end
      if file == nil
        json.delete(user)
      else
        json[user] = file
      end
      writefile(Dirs.eltendata + "\\ringtones.json", JSON.generate(json))
    end

    def plum
      play("feed_update")
      "plum"
    end

    class FeedMessage
      attr_accessor :id, :user, :time, :message, :response, :responses, :liked, :likes

      def initialize(id = 0, user = "", time = 0, message = "", response = 0, responses = 0, liked = false, likes = 0)
        @id, @user, @time, @message, @response, @responses, @liked, @likes = id, user, time, message, response, responses, liked, likes
        @time = 0 if !@time.is_a?(Integer) || @time < 0
      end

      def to_h
        return { "id" => @id, "message" => @message, "time" => @time, "user" => @user, "response" => @response, "responses" => @responses, "liked" => @liked, "likes" => @likes }
      end
    end

    class SoundTheme
      attr_accessor :name, :stamp, :file
      attr_reader :sounds

      def initialize(name, stamp = nil, file = nil)
        @name = name
        @stamp = stamp
        @file = file
        @sounds = {}
      end

      def getsound(name)
        return nil if !name.is_a?(String)
        return @sounds[name.downcase]
      end
    end

    @@defaultsoundtheme = SoundTheme.new("")
    @@soundtheme = nil

    def load_soundtheme(file, loadSounds = true)
      Log.debug("Loading soundtheme: " + file)
      return nil if !FileTest.exists?(file)
      size = File.size(file)
      return nil if size > 64 * 1024 ** 2 || size < 36
      limit = 0
      limit = 32 + 8 + 1 + 256 + 4 if !loadSounds
      io = StringIO.new(readfile(file, limit))
      magic = "EltenSoundThemePackageFileCMPSMC"
      return nil if io.read(32) != magic
      stamp = io.read(8).unpack("Q").first
      sz = io.read(1).unpack("C").first
      st = SoundTheme.new(io.read(sz), stamp, file)
      sz = io.read(4).unpack("I").first
      return nil if size != sz + 32 + 8 + 1 + st.name.size + 4
      if loadSounds
        zio = StringIO.new(Zlib::Inflate.inflate(io.read(sz)))
        while !zio.eof?
          sz = zio.read(1).unpack("C").first
          file = zio.read(sz)
          sz = zio.read(4).unpack("I").first
          content = zio.read(sz)
          st.sounds[file.downcase] = content
        end
      end
      return st
    rescue Exception
      Log.error("Cannot load soundtheme: " + $!.to_s + " " + $@.to_s)
      return nil
    end

    def use_soundtheme(file, default = false)
      if default == false && (file == "" || file == nil)
        @@soundtheme = @@defaultsoundtheme
        return true
      end
      st = load_soundtheme(file)
      if st != nil
        @@soundtheme = st
        @@defaultsoundtheme = st if default
      end
    end

    def getsound(file, default = false)
      if @@soundtheme != nil && !default
        sound = @@soundtheme.getsound(file)
        return sound if sound != nil
      end
      if @@defaultsoundtheme != nil
        sound = @@defaultsoundtheme.getsound(file)
        return sound if sound != nil
      end
      return nil
    end

    def process_attachment(at)
      ati = srvproc("attachments", { "info" => "1", "id" => at })
      if ati[0].to_i < 0
        alert(_("Error"))
        $scene = Scene_Main.new
        return
      end
      id = at
      name = ati[2].delete("\r\n")
      ac = 0
      if [".mp3", ".wav", ".ogg", ".mid", ".mod", ".m4a", ".flac", ".wma", ".opus", ".aac", ".aiff"].include?(File.extname(name).downcase)
        ac = selector([p_("EAPI_Common", "Save"), p_("EAPI_Common", "Play"), _("Cancel")], name, 0, 2, type = 1)
      end
      case ac
      when 0
        loc = get_file(p_("EAPI_Common", "Where do you want to save this file?"), Dirs.user + "\\", true, "Documents")
        if loc != nil
          waiting {
            download_file($url + "attachments/" + id.to_s, loc + "\\" + name)
            speak(p_("EAPI_Common", "The attachment has been downloaded."))
          }
        else
          loop_update
        end
      when 1
        player($url + "attachments/" + id.to_s)
      end
    end

    def feedshow(feed)
      return if feed == nil
      lk = srvproc("feeds", { "ac" => "likes", "message" => feed.id })
      likes = []
      likes = lk[2..-1].map { |l| l.delete("\r\n") } if lk[0].to_i == 0
      form = Form.new([
        edt_message = EditBox.new(p_("EAPI_Common", "Message"), EditBox::Flags::ReadOnly, feed.message, true),
        lst_likes = ListBox.new(likes, p_("EAPI_Common", "Users liking this message")),
        btn_close = Button.new(p_("EAPI_Common", "Close"))
      ], 0, false, true)
      btn_close.on(:press) { form.resume }
      edt_message.bind_context { |menu| menu.useroption(feed.user) }
      lst_likes.bind_context { |menu|
        if likes.size > 0
          menu.useroption(likes[lst_likes.index])
        end
      }
      form.cancel_button = btn_close
      dialog_open
      form.wait
      dialog_close
    end

    def voicecall(channel = nil, channel_password = nil, invite = [])
      invite = [invite] if invite.is_a?(String)
      Conference.open if !Conference.opened?
      return if Session.name == "guest"
      Conference.open if !Conference.opened?
      if !Conference.opened?
        $scene = Scene_Main.new
        return
      end
      if channel == nil
        channel_password = rand(36 ** 32).to_s(36)
        chname = "VoiceCall_" + Session.name
        channel = Conference.create(chname, false, 56, 40, 1, 0, false, true, channel_password, 0, 2, nil).to_i
      else
        Conference.join(channel, channel_password)
      end
      delay(1)
      tm = nil
      tm = 30 if invite.is_a?(Array) && invite.size == 1
      sc = Scene_Conference.new(tm, 1)
      if invite.is_a?(Array)
        invite.each { |user| sc.invite(user) }
        Conference.calling_play if invite.size == 1
      end
      insert_scene(sc)
    end

    def json_load_ext(str)
      Log.debug("JSON Load Ext")
      if $agent != nil
        id = rand(1e16)
        $agids ||= []
        $agids.push(id)
        $agent.write(Marshal.dump({ "func" => "jsonload", "json" => str, "id" => id }))
        t = Time.now.to_f
        while $eresps[id] == nil
          loop_update(false)
        end
        rsp = $eresps[id]
        $eresps.delete(id)
        return nil if rsp == nil
        return secure_wait { Marshal.load(rsp["result"]) }
      end
      return nil
    end

    def process_url(url)
      Log.debug("Opening URL #{url}")
      return if !url.is_a?(String)
      if url[0...8].downcase != "elten://"
        run("explorer \"#{url}\"")
        return true
      end
      bu = url[8..-1]
      q = bu.split("/")
      case q[0]
      when "forum"
        case q[1]
        when "group"
          insert_scene(Scene_Forum.new(nil, q[2].to_i))
        when "forum"
          insert_scene(Scene_Forum.new(nil, q[2]))
        when "thread"
          t = q[3].to_i
          t = nil if q[3] == nil
          insert_scene(Scene_Forum_Thread.new(q[2].to_i, -13, 0, t, nil, Scene_Main.new))
        else
          return false
        end
      when "blog"
      else
        return false
      end
    end
  end

  include Common
end
