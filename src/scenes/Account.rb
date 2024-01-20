# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2024 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Account
  def initialize
    @settings = []
  end

  def getconfig
    a = srvproc("account", { "ac" => "get" })
    @values = {}
    if a[0].to_i == 0
      @values = JSON.load(a[1])
    end
  end

  def currentconfig(key)
    getconfig if @values == nil
    return @values[key]
  end

  def setcurrentconfig(key, val)
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

  def make_setting(label, type, key, mapping = nil, multi = false)
    return if @settings.size == 0
    mapping = mapping.map { |x| x.to_s } if mapping != nil
    @settings.last.push([label, type, key, mapping, multi])
  end

  def save_category
    for i in 2...@settings[@category].size
      setting = @settings[@category][i]
      next if setting[1] == :custom
      index = i - 1
      if setting[4] == false || !setting[1].is_a?(Array)
        val = @form.fields[index].value
        val = val.to_i if setting[1] == :number or setting[1] == :bool
        val = setting[3][val] if setting[3] != nil
      else
        vals = []
        for v in @form.fields[index].multiselections
          v = setting[3][v] if setting[3] != nil
          vals.push(v)
        end
        val = vals.join(",")
      end
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
      label, type, key, mapping, multi = s
      field = nil
      case type
      when :text
        field = EditBox.new(label, 0, currentconfig(key), true)
      when :longtext
        field = EditBox.new(label, EditBox::Flags::MultiLine, currentconfig(key), true)
      when :number
        field = EditBox.new(label, EditBox::Flags::Numbers, currentconfig(key), true)
      when :bool
        field = CheckBox.new(label, (currentconfig(key).to_i != 0).to_i)
      when :custom
        field = Button.new(label)
        proc = key
        field.on(:press, 0, true, &proc)
      else
        index = currentconfig(key)
        index = mapping.find_index(index) || 0 if mapping != nil
        flags = 0
        flags |= ListBox::Flags::MultiSelection if multi == true
        field = ListBox.new(type, label, index.to_i, flags)
        if multi == true
          for e in currentconfig(key).to_s.split(",")
            index = e
            index = mapping.find_index(index) || 0 if mapping != nil
            field.selected[index.to_i] = true
          end
        end
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
      Session.fullname = v if k == "fullname"
      Session.gender = v.to_i if k == "gender"
      Session.languages = v if k == "languages"
    end
    json = JSON.generate(j)
    srvproc("account", { "ac" => "set" }, 0, "js" => json)
  end

  def make_window
    @form = Form.new
    @form.fields[0] = ListBox.new([], p_("Account", "Category"))
    @form.fields[1] = Button.new(_("Apply"))
    @form.fields[2] = Button.new(_("Save"))
    @form.fields[3] = Button.new(_("Cancel"))
  end

  def load_profile
    setting_category(p_("Account", "Profile"))
    make_setting(p_("Account", "Full name"), :text, "fullname")
    make_setting(p_("Account", "Gender"), [_("Female"), _("Male")], "gender")
    years = (1900..Time.now.year).to_a
    monthsmapping = (1..12)
    months = [_("January"), _("February"), _("March"), _("April"), _("May"), _("June"), _("July"), _("August"), _("September"), _("October"), _("November"), _("December")]
    days = (1..31).to_a
    make_setting(p_("Account", "Birth date: year"), [p_("Account", "Don't specify")] + years.map { |y| y.to_s }, "birthdateyear", [0] + years)
    make_setting(p_("Account", "Birth date: month"), months, "birthdatemonth", monthsmapping)
    make_setting(p_("Account", "Birth date: day"), days.map { |y| y.to_s }, "birthdateday", days)
    make_setting(p_("Account", "Country"), [""], "LocationCountry")
    make_setting(p_("Account", "State / Province"), [""], "LocationState")
    make_setting(p_("Account", "City"), [""], "LocationCity")
    on_load {
      @form.fields[3].on(:move) {
        if @form.fields[3].index == 0
          @form.hide(4)
          @form.hide(5)
        else
          @form.show(4)
          @form.show(5)
        end
      }
      @form.fields[3].trigger(:move)
      @form.fields[4].on(:move) {
        m = @form.fields[4].index + 1
        if m == 1 or m == 3 or m == 5 or m == 7 or m == 8 or m == 10 or m == 12
          @form.fields[5].enable_item(-1 + 29)
          @form.fields[5].enable_item(-1 + 30)
          @form.fields[5].enable_item(-1 + 31)
        elsif m == 2
          @form.fields[5].disable_item(-1 + 30)
          @form.fields[5].disable_item(-1 + 31)
          if @form.fields[3].index % 4 == 0 && @form.fields[3].index != 100
            @form.fields[5].enable_item(-1 + 29)
          else
            @form.fields[5].disable_item(-1 + 29)
          end
        else
          @form.fields[5].enable_item(-1 + 29)
          @form.fields[5].enable_item(-1 + 30)
          @form.fields[5].disable_item(-1 + 31)
        end
      }
      @form.fields[3].on(:move) { @form.fields[4].trigger(:move) }
      @form.fields[4].trigger(:move)
      location = currentconfig("location")
      location_a = {}
      countries = [""] + Lists.locations.map { |c| location_a = c if c["geonameid"] == location.to_i; c["country"] }.uniq.polsort
      subcountries = []
      cities = []
      ind = [-1, -1, -1]
      @form.fields[6].options = countries
      if ind[0] == -1
        ind[0] = countries.find_index(location_a["country"]) || 0
        @form.fields[6].index = ind[0]
      end
      @form.fields[6].on(:move) {
        subcountries = [""] + Lists.locations.map { |c| (c["country"] == countries[@form.fields[6].index]) ? (c["subcountry"]) : (nil) }.uniq
        subcountries.delete(nil)
        subcountries.polsort!
        @form.fields[7].options = subcountries
        if ind[1] == -1
          ind[1] = subcountries.find_index(location_a["subcountry"]) || 0
          @form.fields[7].index = ind[1]
        else
          @form.fields[7].index = 0
        end
        @form.fields[7].trigger(:move)
      }
      @form.fields[7].on(:move) {
        cities = [""] + Lists.locations.map { |c| (c["country"] == countries[@form.fields[6].index] && c["subcountry"] == subcountries[@form.fields[7].index]) ? (c["name"]) : (nil) }.uniq
        cities.delete(nil)
        cities.polsort!
        @form.fields[8].options = cities
        if ind[2] == -1
          ind[2] = cities.find_index(location_a["name"]) || 0
          @form.fields[8].index = ind[2]
        else
          @form.fields[8].index = 0
        end
        @form.fields[8].trigger(:move)
      }
      @form.fields[8].on(:move) {
        loc = 0
        Lists.locations.each { |l| loc = l["geonameid"] if l["country"] == countries[@form.fields[6].index] and l["subcountry"] == subcountries[@form.fields[7].index] and l["name"] == cities[@form.fields[8].index] }
        setcurrentconfig("location", loc)
      }
      @form.fields[6].trigger(:move)
    }
  end

  def load_visitingcard
    setting_category(p_("Account", "Visiting card"))
    make_setting(p_("Account", "Visiting card"), :longtext, "visitingcard")
  end

  def load_languages
    setting_category(p_("Account", "Languages"))
    langs = []
    langsmapping = []
    for lk in Lists.langs.keys.sort { |a, b| polsorter(Lists.langs[a]["name"], Lists.langs[b]["name"]) }
      langsmapping.push(lk)
      l = Lists.langs[lk]
      langs.push(l["name"] + "( " + l["nativeName"] + ")")
    end
    make_setting(p_("Account", "Languages"), langs, "languages", langsmapping, true)
    make_setting(p_("account", "First language"), [], "mainlanguage", [])
    on_load {
      @form.fields[1].on(:multiselection_changed) {
        mainlangs = []
        mainlangsmapping = []
        langslabel, langstype, langskey, langsmapping, langsmulti = @settings[@category][2]
        index = 0
        l = currentconfig("mainlanguage")
        for e in @form.fields[1].multiselections
          mainlangs.push(langstype[e])
          mainlangsmapping.push(langsmapping[e])
          index = mainlangs.size - 1 if langsmapping[e] == l
        end
        label, type, key, mapping, multi = @settings[@category][3]
        @settings[@category][3] = [label, mainlangs, key, mainlangsmapping, multi]
        @form.fields[2].options = mainlangs
        @form.fields[2].index = index
      }
      @form.fields[1].trigger(:multiselection_changed)
    }
  end

  def load_privacy
    setting_category(p_("Account", "Privacy"))
    make_setting(p_("Account", "Hide my profile for strangers"), :bool, "publicprofile")
    make_setting(p_("Account", "Prevent banned users from writing me private messages"), :bool, "preventbanned")
    make_setting(p_("Account", "Accept incoming voice calls"), [p_("Account", "Never"), p_("Account", "Only from my friends"), p_("Account", "From all users")], "calls")
    make_setting(p_("Account", "Black list"), :custom, Proc.new { insert_scene(Scene_Account_BlackList.new) })
  end

  def load_signs
    setting_category(p_("Account", "Status and signature"))
    make_setting(p_("Account", "Status displayed after your name on all lists of users"), :text, "status")
    make_setting(p_("Account", "Signature placed below all your forum posts"), :text, "signature")
    make_setting(p_("Account", "Greeting read after you log in to Elten"), :text, "greeting")
  end

  def load_whatsnew
    setting_category(p_("Account", "What's new notifications"))
    options = [p_("Account", "Notice and show in what's new"), p_("Account", "Notice only"), p_("Account", "Ignore")]
    cats = [p_("Account", "New messages"), p_("Account", "New posts in followed threads"), p_("Account", "New posts on the followed blogs"), p_("Account", "New comments on your blog"), p_("Account", "New threads on followed forums"), p_("Account", "New posts on followed forums"), p_("Account", "New friends"), p_("Account", "Friends' birthday"), p_("Account", "Mentions"), p_("Account", "Followed blog posts"), p_("Account", "Blog followers"), p_("Account", "Blog mentions"), p_("Account", "Awaiting group invitations")]
    sets = ["wn_messages", "wn_followedthreads", "wn_followedblogs", "wn_blogcomments", "wn_followedforums", "wn_followedforumsthreads", "wn_friends", "wn_birthday", "wn_mentions", "wn_followedblogposts", "wn_blogfollowers", "wn_blogmentions", "wn_groupinvitations"]
    for i in 0...sets.size
      make_setting(cats[i], options, sets[i])
    end
  end

  def load_security
    setting_category(p_("Account", "Account security"))
    make_setting(p_("Account", "Change e-mail"), :custom, Proc.new { insert_scene(Scene_Account_Mail.new) })
    make_setting(p_("Account", "Change password"), :custom, Proc.new { insert_scene(Scene_Account_Password.new) })
    make_setting(p_("Account", "Forgot password"), :custom, Proc.new { insert_scene(Scene_ForgotPassword.new) })
    make_setting(p_("Account", "Manage Two-Factor authentication"), :custom, Proc.new { insert_scene(Scene_Authentication.new) })
    make_setting(p_("Account", "Manage mail events-reporting"), :custom, Proc.new { insert_scene(Scene_Account_MailEvents.new) })
    make_setting(p_("Account", "Manage auto-login tokens"), :custom, Proc.new { insert_scene(Scene_Account_AutoLogins.new) })
    make_setting(p_("Account", "Show last logins"), :custom, Proc.new { insert_scene(Scene_Account_Logins.new) })
  end

  def load_others
    setting_category(p_("Account", "Others"))
    make_setting(p_("Account", "Premium packages"), :custom, Proc.new { insert_scene(Scene_PremiumPackages.new) })
    make_setting(p_("Account", "Archive this account"), :custom, Proc.new { insert_scene(Scene_Account_Archive.new) })
  end

  def main
    make_window
    load_profile
    load_visitingcard
    load_languages
    load_signs
    load_whatsnew
    load_privacy
    load_security
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
        $scene = Scene_Main.new
      end
      if escape or @form.fields[-1].pressed?
        $scene = Scene_Main.new
      end
      break if $scene != self or $restart == true
    end
  end
end

class Scene_Account_Password
  def main
    oldpassword = ""
    password = ""
    repeatpassword = ""
    while oldpassword == ""
      oldpassword = input_text(p_("Account", "Enter your old password."), EditBox::Flags::Password, "", true)
    end
    if oldpassword == nil
      $scene = Scene_Main.new
      return
    end
    while password == ""
      password = input_text(p_("Account", "Enter your new password."), EditBox::Flags::Password, "", true)
    end
    if oldpassword == nil
      $scene = Scene_Main.new
      return
    end
    while repeatpassword == ""
      repeatpassword = input_text(p_("Account", "Repeat new password."), EditBox::Flags::Password, "", true)
    end
    if repeatpassword == nil
      $scene = Scene_Main.new
      return
    end
    if password != repeatpassword
      alert(p_("Account", "Fields: New Password and Repeat New Password have different values."))
      main
    end
    act = srvproc("account_mod", { "changepassword" => "1", "oldpassword" => oldpassword, "password" => password })
    err = act[0].to_i
    case err
    when 0
      alert(p_("Account", "Your password has been changed."))
      $scene = Scene_Main.new
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
    when -2
      alert(_("Token expired"))
      $scene = Scene_Loading.new
    when -6
      alert(p_("Account", "The old password is incorrect."))
      $scene = Scene_Main.new
    end
  end
end

class Scene_Account_Mail
  def main
    password = ""
    mail = ""
    while password == ""
      password = input_text(p_("Account", "Enter your password."), EditBox::Flags::Password, "", true)
    end
    if password == nil
      $scene = Scene_Main.new
      return
    end
    while mail == ""
      mail = input_text(p_("Account", "Enter a new e-mail address."), 0, "", true)
    end
    if mail == nil
      $scene = Scene_Main.new
      return
    end
    act = srvproc("account_mod", { "changemail" => "1", "oldpassword" => password, "mail" => mail })
    err = act[0].to_i
    case err
    when 0
      alert(p_("Account", "E-mail has been changed."))
      $scene = Scene_Main.new
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
    when -2
      alert(_("Token expired"))
      $scene = Scene_Loading.new
    when -6
      alert(p_("Account", "The old password is incorrect."))
      $scene = Scene_Main.new
    when -7
      alert(p_("Account", "Error, you must disable mail events reporting first."))
      speech_wait
      $scene = Scene_Main.new
    end
  end
end

class Scene_Account_AutoLogins
  def main
    al = []
    loop do
      password = input_text(p_("Account", "Enter your password."), EditBox::Flags::Password, "", true)
      if password == nil
        return $scene = Scene_Main.new
        break
      else
        al = srvproc("autologins", { "password" => password })
        if al[0].to_i < 0
          alert(p_("Account", "An error occurred while authenticating the account. You might have provided an  incorrect password."))
        else
          break
        end
      end
    end
    als = []
    t = 0
    for a in al[1..al.size - 1]
      case t
      when 0
        ret = 0
        tim = ""
        tm = Time.at(a.to_i)
        tim = format_date(tm, false, false)
        als.push([tim])
        t += 1
      when 1
        als.last.push(a.delete("\r\n"))
        t += 1
      when 2
        als.last.push(a.delete("\r\n"))
        t = 0
      end
    end
    selh = [p_("Account", "Computer"), p_("Account", "Creation IP Address"), p_("Account", "Generation date")]
    selt = []
    for s in als
      selt.push([s[2], s[1], s[0]])
    end
    @sel = TableBox.new(selh, selt, 0, p_("Account", "Auto log in tokens"), false)
    @sel.bind_context { |menu|
      menu.option(p_("Account", "Log out all sessions"), nil, :del) {
        globallogout
      }
      menu.option(_("Refresh"), nil, "r") {
        main
      }
    }
    loop do
      loop_update
      @sel.update
      break if escape
      break if $scene != self
    end
    $scene = Scene_Main.new
  end

  def globallogout
    confirm(p_("Account", "Are you sure you want to remove all auto log in tokens and log out all sessions?  You will be logged off immediately.")) do
      loop do
        password = input_text(p_("Account", "Enter your password."), EditBox::Flags::Password, "", true)
        if password == nil
          @sel.focus
          return
          break
        else
          lg = srvproc("logout", { "global" => "1", "password" => password })
          if lg[0].to_i < 0
            alert(p_("Account", "An error occurred while authenticating the account. You might have provided an  incorrect password."))
          else
            Session.name = ""
            Session.token = ""
            File.delete(Dirs.eltendata + "\\login.dat") if FileTest.exists?(Dirs.eltendata + "\\login.dat")
            $restart = true
            $scene = Scene_Main.new
            break
            return
          end
        end
      end
    end
  end
end

class Scene_Account_BlackList
  def main
    bt = srvproc("blacklist", { "get" => "1" })
    if bt[0].to_i < 00
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    @blacklist = []
    if bt.size > 1
      for u in bt[1..bt.size - 1]
        @blacklist.push(u.delete("\r\n"))
      end
    end
    @blacklist.polsort!
    selt = @blacklist.map { |u| u + ". " + getstatus(u) }
    header = p_("Account", "Black list")
    @sel = ListBox.new(selt, header, 0, 0, false)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      update
      if $scene != self
        break
      end
    end
  end

  def update
    $scene = Scene_Main.new if escape
    usermenu(@blacklist[@sel.index], false) if enter and @blacklist.size > 0
  end

  def context(menu)
    if @blacklist.size > 0
      menu.useroption(@blacklist[@sel.index])
    end
    menu.option(p_("Account", "Add"), nil, "n") {
      user = input_user(p_("Account", "User you want to add to the blacklist."))
      if user != nil
        confirm(p_("Account", "The users added to your black list cannot send you private messages. Are you sure  you want to continue?")) do
          bl = srvproc("blacklist", { "add" => "1", "user" => user })
          case bl[0].to_i
          when 0
            speech(p_("Account", "User %{user} has been added to your blacklist") % { "user" => user })
            @sel.options.push(user)
            @blacklist.push(user)
          when -1
            alert(_("Database Error"))
          when -2
            alert(_("Token expired"))
            $scene = Scene_Loading.new
            return
          when -3
            alert(p_("Account", "You cannot add an administrator to the black list."))
          when -4
            alert(p_("Account", "This user is already on your black list."))
          when -5
            alert(p_("Account", "The user cannot be found."))
          end
          speech_wait
        end
      end
    }
    if @blacklist.size > 0
      menu.option(_("Delete"), nil, :del) {
        confirm(p_("Account", "Are you sure you want to remove this user from the black list?")) do
          if srvproc("blacklist", { "del" => "1", "user" => @blacklist[@sel.index] })[0].to_i < 0
            alert(_("Error"))
          else
            play("editbox_delete")
            alert(p_("Account", "A user has been removed from the black list."))
          end
          speech_wait
          @blacklist.delete_at(@sel.index)
          @sel.options.delete_at(@sel.index)
          @sel.focus
        end
      }
    end
    menu.option(_("Refresh"), nil, "r") {
      $scene = Scene_Account_BlackList.new
    }
  end
end

class Scene_Account_Logins
  def main
    lg = []
    loop do
      password = input_text(p_("Account", "Enter your password."), EditBox::Flags::Password, "", true)
      if password == nil
        return $scene = Scene_Main.new
        break
      else
        lg = srvproc("lastlogins", { "password" => password })
        if lg[0].to_i < 0
          alert(p_("Account", "An error occurred while authenticating the account. You might have provided an  incorrect password."))
        else
          break
        end
      end
    end
    lgs = []
    t = 0
    for l in lg[1...lg.size]
      case t
      when 0
        ret = 0
        tim = ""
        tm = Time.at(l.to_i)
        tim = format_date(tm, false, false)
        lgs.push([tim])
        t += 1
      when 1
        lgs.last.push(l.delete("\r\n"))
        t = 0
      end
    end
    selh = ["", ""]
    selt = []
    for s in lgs
      selt.push([s[0], s[1]])
    end
    @sel = TableBox.new(selh, selt, 0, p_("Account", "Last logins"), false)
    loop do
      loop_update
      @sel.update
      break if escape
    end
    $scene = Scene_Main.new
  end
end

class Scene_Account_MailEvents
  def main
    @password = input_text(p_("Account", "Enter your password."), EditBox::Flags::Password, "", true) if @password == nil
    return $scene = Scene_Main.new if @password == nil
    vr = srvproc("mailevents", { "password" => @password, "ac" => "check" })
    if vr[0].to_i < 0
      alert(_("Error"))
      return $scene = Scene_Main.new
    end
    chk = vr[1].to_i
    if chk == 0
      confirm(p_("Account", "If you wish, you can configure Elten to report any changes and logins  on your account from new devices to you by E-mail. To do this, you must verify your E-mail address. Do you want to do it now?")) {
        vf = srvproc("mailevents", { "password" => @password, "ac" => "verify" })
        if vf[0].to_i < 0
          alert(_("Error"))
          return $scene = Scene_Main.new
        end
        code = input_text(p_("Account", "The verification code has been sent to you via E-mail. Please type it here."))
        vf = srvproc("mailevents", { "password" => @password, "ac" => "verify", "code" => code })
        if vf[0].to_i < 0
          alert(_("Error"))
          return $scene = Scene_Main.new
        else
          return main
        end
      }
      $scene = Scene_Main.new if $scene == self
    else
      enb = vr[2].to_i
      opt = (enb == 0) ? p_("Account", "Enable mail events reporting") : p_("Account", "Disable mail events reporting")
      h = (enb == 0) ? p_("Account", "Mail events reporting is disabled. If you wish, you can enable it to receive information about changes made on your account and logins from new devices via E-mail") : p_("Account", "Mail events reporting is enabled.")
      @sel = ListBox.new([opt, _("Exit")], h, 0, ListBox::Flags::AnyDir, false)
      loop do
        loop_update
        @sel.update
        if enter
          case @sel.index
          when 0
            e = 0
            e = 1 if enb == 0
            srvproc("mailevents", { "password" => @password, "ac" => "events", "enable" => e.to_s })
            if e == 0
              code = input_text(p_("Account", "The verification code has been sent to you via E-mail. Please type it here."))
              srvproc("mailevents", { "password" => @password, "ac" => "events", "enable" => e.to_s, "code" => code })
            end
            return main
          when 1
            $scene = Scene_Main.new
          end
        end
        break if $scene != self
      end
    end
  end
end

class Scene_Account_Archive
  def main
    notification = p_("Account", "Archiving your account will have the following effects:
* An indication that the account is archived will be placed next to all posts on the forum.
* The account will not be displayed in the users lists.
* The account will be removed from all contact lists.
* Users will not be able to send private messages to this account.
* The profile (including status, visiting card and signature) will be removed from the server
* You will be opted out off all groups you are not moderating or banned in
* You will be opted out of all messages conversations
* All information about threads followed by you, your pinned groups or marked threads will be removed

Attention.
Archiving an account does not mean deleting or hiding associated blogs or notes, this must be done manually before archiving.

The account will be automatically unarchived the next time you log in, but removed data will not be restored..")

    form = Form.new([
      txt_info = EditBox.new(p_("Account", "Information"), EditBox::Flags::ReadOnly, notification),
      btn_continue = Button.new(p_("Account", "Continue")),
      btn_cancel = Button.new(_("Cancel"))
    ])
    btn_cancel.on(:press) { form.resume }
    btn_continue.on(:press) {
      @password = input_text(p_("Account", "Enter your password."), EditBox::Flags::Password, "", true)
      if @password == nil
        form.resume
      else
        confirm(p_("Account", "Are you sure you want to archive this account?")) {
          srvproc("account_mod", { "oldpassword" => @password, "archive" => 1 })
          alert(p_("Account", "Account archived"))
          Session.name = ""
          Session.token = ""
          $scene = Scene_Loading.new
          form.resume
        }
      end
    }
    form.wait
    $scene = Scene_Main.new if $scene == self
  end
end
