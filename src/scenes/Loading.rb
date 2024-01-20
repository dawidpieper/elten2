# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2024 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Loading
  def initialize(skiplogin = false)
    @skiplogin = skiplogin
  end

  @@firstinit = true

  def main
    $mainmenuextra = {}
    $usermenuextra = {}
    $eresps = {}
    $eprogresses = {}
    $jresps = {}
    $restart = false
    Configuration.volume = 50
    $preinitialized = false
    $eltenlib = "./bin\\eltenvc"
    begin
      h = Win32API.new($eltenlib, "hook", "", "i").call
    rescue Exception
      print "Failed to load Elten library.
Please try to reinstal the software.
If the problem occurs, please contact Elten support"
      $exit = true
      $immediateexit = true
      exit
    end
    if h != 0
      print("Failed to setup Window Hook")
      exit
    end
    Log.info("Window hook registered")
    $scenes = []
    Configuration.volume = 50
    $instance = Win32API.new("kernel32", "GetModuleHandle", "i", "i").call(0)
    $process = Win32API.new("kernel32", "GetCurrentProcess", "", "i").call
    $path = "\0" * 1024
    Win32API.new("kernel32", "GetModuleFileName", "ipi", "i").call($instance, $path, $path.size)
    $path.delete!("\0")
    Log.info("Exec path: #{$path}")
    if $wnd == nil
      $wnd = Win32API.new("user32", "FindWindow", "pp", "i").call("RGSS Player", nil)

      cwnd = Win32API.new("user32", "GetActiveWindow", "", "i").call
      if cwnd != $wnd
        ccwnd = Win32API.new("user32", "GetForegroundWindow", "", "i").call
        if ccwnd == $wnd
          $wnd = ccwnd
        elsif cwnd == $wnd
          $wnd = cwnd
        elsif ccwnd == cwnd
          $wnd = cwnd
        end
      end
    end
    Log.debug("HWND: #{$wnd.to_s}")
    Win32API.new($eltenlib, "showTray", "i", "i").call($wnd)
    Log.info("Tray icon created")
    $computer = "\0" * 128
    siz = [$computer.size].pack("i")
    Win32API.new("kernel32", "GetComputerName", "pp", "i").call($computer, siz)
    $computer.delete!("\0")
    Log.info("Computer: #{$computer}")
    if defined?(Sprite) != nil
      $sprite = Sprite.new
      $sprite.bitmap = Bitmap.new("elten.jpg") if FileTest.exists?("elten.jpg")
      Graphics.freeze
      Graphics.transition(0)
    end
    Session.name = ""
    Session.token = ""
    $url = "https://srvapi.elten.link/leg1/"
    $srv = "srvapi.elten.link"
    Graphics.frame_rate = 60 if $ruby != true
    Dirs.apps = Dirs.eltendata + "\\apps"
    Dirs.extras = Dirs.eltendata + "\\extras"
    Dirs.soundthemes = Dirs.eltendata + "\\soundthemes"
    Dirs.temp = Dirs.tmp + "\\elten"
    createdirifneeded(Dirs.eltendata)
    createdirifneeded(Dirs.extras)
    createdirifneeded(Dirs.soundthemes)
    createdirifneeded(Dirs.apps)
    createdirifneeded(Dirs.temp)
    #upd
    deldir(Dirs.eltendata + "\\apps\\inis") if FileTest.exists?(Dirs.eltendata + "\\apps\\inis")
    deldir(Dirs.eltendata + "\\bin") if FileTest.exists?(Dirs.eltendata + "\\bin")
    if FileTest.exists?(Dirs.eltendata + "\\config")
      v = {
        "Advanced" => [["KeyUpdateTime"], ["RefreshTime"], ["SyncTime"], ["AgentRefreshTime"]],
        "Interface" => [["ListType"], ["SoundThemeActivation"], ["TypingEcho"], ["HideWindow"], ["MainVolume"], ["SayTimePeriod", "Clock"], ["SayTimeType", "Clock"], ["LineWrapping"], ["SoundCard", "SoundCard"], ["Microphone", "SoundCard"]],
        "Language" => [["Language", "Interface"]],
        "Login" => [["AutoLogin"], ["Name"], ["Token"], ["TokenEncrypted"]],
        "Sapi" => [["Voice", "Voice"], ["Rate", "Voice"], ["Volume", "Voice"]],
        "SoundTheme" => [["Path", "Interface", "SoundTheme"]]
      }
      begin
        for k in v.keys
          for o in v[k]
            o[1] = k if o[1] == nil
            o[2] = o[0] if o[2] == nil
            val = readini(Dirs.eltendata + "\\config\\" + (k + "") + ".ini", k + "", o[0], "")
            writeconfig(o[1] + "", o[2] + "", val) if val != ""
          end
        end
      rescue Exception
        Log.error("UPD: #{$!.to_s} #{$@.to_s}")
      end

      copyfile(Dirs.eltendata + "\\config\\appid.dat", Dirs.eltendata + "\\appid.dat") if !FileTest.exists?(Dirs.eltendata + "\\appid.dat")
      deldir(Dirs.eltendata + "\\config")
    end
    begin
      deldir(Dirs.eltendata + "\\lng")
      if FileTest.exists?(Dirs.soundthemes + "\\inis")
        d = Dir.entries(Dirs.soundthemes + "\\inis")
        for f in d
          next if !f.include?(".ini")
          name = readini(Dirs.soundthemes + "\\inis\\" + f, "SoundTheme", "Name", "")
          path = readini(Dirs.soundthemes + "\\inis\\" + f, "SoundTheme", "Path", "")
          writefile(Dirs.soundthemes + "\\" + path + "\\__name.txt", name)
        end
      end
    rescue Exception
    end
    begin
      File.delete(Dirs.extras + "\\youtube-dl.exe") if FileTest.exists?(Dirs.extras + "\\youtube-dl.exe")
      deldir(Dirs.extras + "\\Calibre Portable") if FileTest.exists?(Dirs.extras + "\\Calibre Portable")
    rescue Exception
    end
    if !FileTest.exists?(Dirs.eltendata + "\\login.dat")
      autologin = readconfig("Login", "AutoLogin", -2)
      if autologin.to_i != -2
        name = readconfig("Login", "Name", "")
        token = readconfig("Login", "Token", "")
        tokenenc = readconfig("Login", "TokenEncrypted", -2)
        token = Base64.strict_decode64(token) if tokenenc > 0
        Scene_Login.new.write_logindata(autologin, name, token, tokenenc)
        writeconfig("Login", "Name", nil)
        writeconfig("Login", "Token", nil)
        writeconfig("Login", "TokenEncrypted", nil)
      end
      writeconfig("Login", "AutoLogin", nil)
    end
    #endupd
    if FileTest.exists?(Dirs.eltendata + "\\appid.dat")
      $appid = readfile(Dirs.eltendata + "\\appid.dat")
    else
      Log.info("Generating new AppID")
      $appid = ""
      chars = ("A".."Z").to_a + ("a".."z").to_a + ("0".."9").to_a
      64.times do
        $appid << chars[rand(chars.length - 1)]
      end
      writefile(Dirs.eltendata + "\\appid.dat", $appid)
    end
    use_soundtheme("Data/Audio.elsnd", true)
    Log.info("Loading locales")
    loadlocaledata("Data/locale.dat")
    load_configuration
    Log.info("Initializing Bass")
    Bass.init($wnd)
    if Configuration.usefx == -1
      Configuration.usefx = Bass.test.to_i
      writeconfig("Advanced", "UseFX", Configuration.usefx)
    end
    Log.info("Initializing NVDA Support")
    NVDA.init
    loop_update while !NVDA.waiting?
    if $agentloaded != true
      agent_start
      $agentloaded = true
    else
      $agent.write(Marshal.dump("func" => "relogin", "name" => nil, "token" => nil))
    end
    Log.info("Connecting to Elten server")
    if srvproc("init", {})[0].to_i < 0
      Log.warning("Failed to connect")
      $neterror = true
    else
      Log.info("Connection established")
      $neterror = false
    end
    Win32API.new("bass", "BASS_SetConfigPtr", "ip", "l").call(0x10403, Dirs.extras + "\\soundfont.sf2") if FileTest.exists?(Dirs.extras + "\\soundfont.sf2")
    $beta = Elten.beta
    $alpha = Elten.alpha
    $version = Elten.version
    $isbeta = Elten.isbeta
    startmessage = "ELTEN: " + $version.to_s.delete(".").split("").join(".")
    startmessage += " BETA #{$beta.to_s}" if $isbeta == 1
    startmessage += " RC #{$alpha.to_s}" if $isbeta == 2
    $start = Time.now.to_i
    $thr1 = Thread.new { thr1 } if $thr1 == nil
    $thr2 = Thread.new { thr2 } if $thr2 == nil
    if FileTest.exists?("Data/langs.dat")
      Lists.langs = Marshal.load(Zlib::Inflate.inflate(readfile("Data/langs.dat")))
    else
      Lists.langs = {}
    end
    Lists.locations = []
    begin
      Lists.locations = Marshal.load(zstd_decompress(readfile("Data/locations.dat")))
    rescue Exception
    end
    if !FileTest.exists?("Data/locale.dat")
      mod = "\0" * 1024
      Win32API.new("kernel32", "GetModuleFileName", "ipi", "i").call(0, mod, mod.size)
      ind = (0...mod.size).find_all { |c| mod[c..c] == "\\" or mod[c..c] == "/" }.last
      fol = mod[0...ind]
      Win32API.new("kernel32", "SetCurrentDirectory", "p", "i").call(fol)
    end
    if Configuration.language == ""
      lcid = Win32API.new("kernel32", "GetUserDefaultLCID", "", "i").call
      Configuration.language = "\0" * 5
      Win32API.new("kernel32", "GetLocaleInfo", "iipi", "i").call(lcid, 92, Configuration.language, Configuration.language.size)
      writeconfig("Interface", "Language", Configuration.language)
    end
    setlocale(Configuration.language)
    if (Configuration.voice == "?" or Configuration.voice == "") && Win32API.new("bin\\nvdaHelperRemote", "nvdaController_testIfRunning", "", "i").call == 0
      v = Configuration.voice
      Configuration.voice = "NVDA"
    end
    if $silentstart == nil
      $silentstart = true if $commandline.include?("/silentstart")
    end
    oldfiles = ["ffmpeg.exe", "avcodec58.dll", "avdevice58.dll", "avformat58.dll", "openal32.dll", "rar.exe"]
    btn = 0
    loop {
      suc = true
      dr = Dir.entries("bin")
      for d in dr
        suc = false if oldfiles.include?(d.downcase)
      end
      break if suc
      btn = 0
      begin
        mb = Win32API.new("user32", "MessageBoxW", "lppl", "i")
        caption = "Previous installation detected"
        text = "Elten detected files created by old installation, beta 59 or earlier.\r\nPlease remove the program and reinstall it again to delete those files.\r\nIf you don't want to remove your configuration, you can just delete Elten directory in \"Program files\"."
        btn = mb.call($wnd, unicode(text), unicode(caption), 2 | 0x10)
      rescue Exception
      end
      if btn == 3
        $immediateexit = true
        $exit = true
        exit
      elsif btn == 5
        break
      end
    }
    if @@firstinit == true
      @@firstinit = false
    else
      delay(1)
    end
    v = 42
    if Win32API.new("bin\\nvdaHelperRemote", "nvdaController_testIfRunning", "", "i").call == 0 && (!NVDA.check || NVDA.getversion != v)
      if !NVDA.check
        str = p_("Loading", "Elten detected that you are using NVDA. To support some features of this screenreader, it is necessary to install Elten addon. Do you want to do it now?")
      elsif NVDA.getversion != v
        str = p_("Loading", "New version of NVDA Elten addon is available. The version you're using is no longer supported in this Elten release and may cause some errors. Do you want to update it now?")
      end
      if FileTest.exists?(Dirs.appdata + "\\nvda")
        suc = false
        confirm(str) {
          suc = true
          path = $path[0...$path.size - ($path.reverse.index("\\"))]
          Win32API.new("bin\\nvdaHelperRemote.dll", "nvdaControllerInternal_installAddonPackageFromPath", "p", "i").call(unicode(path + "\\data\\elten.nvda-addon"))
          NVDA.destroy
          t = Time.now.to_f
          waiting {
            loop_update while Time.now.to_f - t < 30 and Win32API.new("bin\\nvdaHelperRemote.dll", "nvdaController_testIfRunning", "", "i").call == 0
            delay(1)
            loop_update while Time.now.to_f - t < 30 and Win32API.new("bin\\nvdaHelperRemote.dll", "nvdaController_testIfRunning", "", "i").call != 0
            loop_update while Time.now.to_f - t < 30 and FileTest.exists?(Dirs.temp + "\\nvda.pipe")
            NVDA.init
            delay(1)
          }
        }
      end
    end
    Log.info("NVDA Version: " + NVDA.getnvdaversion.to_s) if NVDA.check
    10.times {
      Log.info("Veryfying server key...")
      $srvverify = nil
      $agent.write(Marshal.dump("func" => "srvverify"))
      while $srvverify == nil
        loop_update
      end
      if $srvverify == true
        break
      else
        loop_update
      end
    }
    if $srvverify == true
      Log.info("Server successfully verified")
    else
      Log.warning("Server not verified")
      if confirm(p_("Loading", "Warning! Elten failed to verify server encryption key. It is possible that you are not connecting to Elten server but to one prepared by hackers. It is also possible that Elten Server key has changed. Any details should be provided on Elten Website Forum. If no information about key change was provided, it is very likely that you are vulnerable to hacker attack. In this cause any data that you will provide, including password, can be stolen. Are you sure you want to proceed with this connection? Select No to exit Elten.")) == 0
        $exit = true
        $scene = nil
        exit
      end
    end
    $srvverify = nil
    alert(startmessage) if $silentstart != true
    $speech_wait = true if $silentstart != true
    if Configuration.checkupdates == 1
      bid = srvproc("bin/buildid", { "branch" => get_updatesbranch, "build_id" => Elten.build_id }, 1).to_i
      if Elten.build_id != bid and bid > 0 and $denyupdate != true
        Log.info("New update available (BuildID: #{bid.to_s})")
        if $portable != 1
          $scene = Scene_Update_Confirmation.new
          return
        else
          alert(p_("Loading", "A new version of the program is available."))
        end
      end
    end
    if $neterror == true
      if (download($url, "testtemp") == 0 and FileTest.exists?("testtemp"))
        File.delete("testtemp") if FileTest.exists?("testtemp")
        $neterror = false
      else
        alert(_("Error"))
        $offline = true
        delay(3)
        speech_wait
      end
    end
    if !FileTest.exists?(Dirs.eltendata + "\\license_agreed.dat")
      $exit = true
      license
      $exit = nil
      writefile(Dirs.eltendata + "\\license_agreed.dat", "\001")
    elsif readfile(Dirs.eltendata + "\\license_agreed.dat", 1) == "\001"
      $exit = true
      license
      $exit = nil
      insert_scene(Scene_Documentation.new("migration24"))
      writefile(Dirs.eltendata + "\\license_agreed.dat", "\002")
    end
    if FileTest.exists?(Dirs.eltendata + "\\update.last")
      l = Zlib::Inflate.inflate(readfile(Dirs.eltendata + "\\update.last")).split(" ")
      lversion, lbeta, lalpha, lisbeta = l[0].to_f, l[1].to_i, l[2].to_i, l[3].to_i
      if lversion <= 2.52
        delay(1)
        infotext = p_("Loading", "Attention!
Since the release of version 2.5.2.1, new restrictions have been introduced for globally banned users.
By default, they are prevented from speaking in any groups and writing to other people.

To allow banned people to speak in a group, change this option from the group's settings, General tab.
Similarly, to allow these users to write private messages to you, you must allow this from within your account settings, Privacy tab.

Also, all groups moderated by banned users have been removed from most public lists.

At the same time, three changes have since been made to the premium packages at the request of users:
First of all, premium features are now visible in menus.
It has also been made possible to buy premium packages for a period of one month.
Other billing currencies have also been added.")
        form = Form.new([
          edt_info = EditBox.new(p_("Loading", "Information about important changes"), EditBox::Flags::MarkDown | EditBox::Flags::ReadOnly | EditBox::Flags::MultiLine, infotext, true),
          btn_close = Button.new(_("Close"))
        ], 0, false, true)
        btn_close.on(:press) { form.resume }
        form.cancel_button = btn_close
        form.wait
      end
      Log.info("Update completed from version #{lversion.to_s}")
      File.delete(Dirs.eltendata + "\\update.last")
    end
    Programs.load_all
    QuickActions.load_actions
    if FileTest.exists?(Dirs.eltendata + "\\login.dat") and $offline != true and @skiplogin == false
      Log.info("Processing with autologin")
      $scene = Scene_Login.new
      return
    end
    @cw = ListBox.new([p_("Loading", "Log in"), p_("Loading", "Register"), p_("Loading", "Password reset"), p_("Loading", "Use guest account"), p_("Loading", "Settings"), p_("Loading", "Reinstall"), _("Exit")], "", 0, 0, false)
    loop do
      loop_update
      @cw.update
      update
      if $scene != self
        break
      end
    end
  end

  def update
    if enter
      case @cw.index
      when 0
        $scene = Scene_Login.new
      when 1
        $scene = Scene_Registration.new
      when 2
        $scene = Scene_ForgotPassword.new
      when 3
        Session.name = "guest"
        Session.token = "guest"
        Session.moderator = 0
        $scene = Scene_Main.new
      when 4
        $scene = Scene_Settings.new
      when 5
        $scene = Scene_Update.new
      when 6
        $scene = nil
      end
    end
  end
end
