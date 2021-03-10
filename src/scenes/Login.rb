# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Login
  @@skipauto = false

  def initialize(skipauto = false)
    @skipauto = skipauto
    if @@skipauto == true
      @@skipauto = false
      @skipauto = true
    end
  end

  def main
    autologin, name, token, tokenenc = read_logindata
    password = ""
    if autologin.to_i <= 0 or @skipauto == true
      name = ""
      password = ""
      while name == ""
        name = input_text(p_("Login", "Username:"), 0, "", true)
      end
      if name == nil
        $scene = Scene_Loading.new(true)
        return
      end
      password = ""
      while password == ""
        password = input_text(p_("Login", "Password:"), EditBox::Flags::Password, "", true)
      end
      if password == nil
        $scene = Scene_Loading.new
        return
      end
      name = finduser(name) if finduser(name).upcase == name.upcase
    else
      if autologin == 3
        tokenenc = -1 if tokenenc > 0 and token.bytesize <= 130
        suc = false
        while suc == false and tokenenc >= 1
          pin = ""
          pin = input_text(p_("Login", "Enter pin code"), EditBox::Flags::Password, "", true) if tokenenc == 2
          if pin == nil
            @skipauto = true
            return
          end
          t = decrypt(token, pin) if tokenenc > 0
          if t == "" and pin == nil
            @skipauto = true
            return main
          elsif t != ""
            token = t
            break
          end
        end
        if tokenenc == -1
          otoken = token
          if confirm(p_("Login", "Do you want to enable auto-Login-key encryption? When encrypted, the Auto-Login Key will be readable only on this computer, and its copying or exporting will not allow other devices to access your account. Note: If you encrypt your Auto-Login Key, the created portable versions will not be able to automatically log into your account from other devices, even if you copy your settings, and you will be prompted to enter your password. You can create as many auto-login-keys as you wish for all other computers you are using.")) == 0
            tokenenc = 0
          else
            tokenenc = 1
            pin = makepin
            otoken = crypt(token, pin)
            tokenenc = 2 if pin != nil
          end
          write_logindata(autologin, name, otoken, tokenenc)
        end
      end
    end
    ver = $version.to_s
    ver += " BETA" if $isbeta == 1
    ver += " RC" if $isbeta == 2
    b = 0
    b = $beta if $isbeta == 1
    b = $alpha if $isbeta == 2
    password = "" if autologin.to_i == 2
    suc = false
    while suc == false
      if token != ""
        logintemp = srvproc("login", { "login" => "1", "name" => name, "token" => token, "version" => ver.to_s, "beta" => b.to_s, "appid" => $appid, "lang" => Configuration.language, "crp" => cryptmessage(JSON.generate({ "name" => name, "time" => Time.now.to_i })), "output" => 1, "authmethod" => "list" })
      else
        logintemp = srvproc("login", { "login" => "1", "name" => name, "password" => password, "version" => ver.to_s, "beta" => b.to_s, "appid" => $appid, "lang" => Configuration.language, "crp" => cryptmessage(JSON.generate({ "name" => name, "time" => Time.now.to_i })), "output" => 1, "authmethod" => "list" })
      end
      suc = true
      if logintemp[0].to_i == -5
        meth = selector([p_("Login", "Authenticate using SMS"), p_("Login", "Authenticate using backup code"), _("Cancel")], p_("Login", "Two-factor authentication is enabled on this account. Select method to authenticate."), 0, 2, 1)
        if meth == 0
          if token != ""
            logintemp = srvproc("login", { "login" => "1", "name" => name, "token" => token, "version" => ver.to_s, "beta" => b.to_s, "appid" => $appid, "lang" => Configuration.language, "crp" => cryptmessage(JSON.generate({ "name" => name, "time" => Time.now.to_i })), "output" => 1, "authmethod" => "phone" })
          else
            logintemp = srvproc("login", { "login" => "1", "name" => name, "password" => password, "version" => ver.to_s, "beta" => b.to_s, "appid" => $appid, "lang" => Configuration.language, "crp" => cryptmessage(JSON.generate({ "name" => name, "time" => Time.now.to_i })), "output" => 1, "authmethod" => "phone" })
          end
        end
        suc = false
        tries = 0
        if meth == 2
          @@skipauto = true
          return $scene = Scene_Login.new
          break
        end
        if meth == 0
          label = p_("Login", "Enter the code sent to you  by text message to allow this device to login. If you do not have access to the  phone number used, select the password reset option to disable two-factor  authentication.")
        else
          label = p_("Login", "Enter backup code")
        end
        while tries < 3
          code = input_text(label, 0, "", true).delete("\r\n")
          if code == nil
            delete_logindata
            return $scene = Scene_Loading.new
            break
          end
          ath = srvproc("authentication", { "authenticate" => "1", "appid" => $appid, "name" => name, "code" => code })[0].to_i
          if ath < 0
            tries += 1
            if tries >= 3
              alert(p_("Login", "Verification failed."))
              delete_logindata
              return $scene = Scene_Loading.new
              break
            else
              label = p_("Login", "The entered code is wrong, please try again")
            end
          else
            break
          end
        end
      end
    end
    if logintemp.size > 1
      Session.name = logintemp[1].delete("\r\n")
      Session.token = logintemp[2].delete("\r\n")
      Session.moderator = logintemp[3].to_i
      Session.fullname = logintemp[4].delete("\r\n")
      Session.gender = logintemp[5].to_i
      Session.languages = logintemp[6].delete("\r\n")
      Session.greeting = logintemp[7].delete("\r\n")
    end
    case logintemp[0].to_i
    when 0
      if Configuration.autologin == 1 && autologin.to_i != 3
        dialog_open
        if autologin.to_i == 0
          @sel = ListBox.new([_("No"), _("Yes"), p_("Login", "Do not ask again")], p_("Login", "Do you want to enable auto log in for account %{user}?") % { "user" => name }, 0, ListBox::Flags::AnyDir)
        else
          @sel = ListBox.new([_("No"), _("Yes")], p_("Login", "The saved login data uses the old account authentication method in which  susceptibility to hacker attacks has been detected. New, safer automatic login  algorithms have been introduced in Elten 2.2. It is recommended that you convert  the saved information into a new system in order to improve the security of your  account. Do you want to update the saved information now?"), 0, ListBox::Flags::AnyDir)
        end
        loop do
          loop_update
          @sel.update
          if enter
            case @sel.index
            when 0
            when 1
              loop do
                password = input_text(p_("Login", "Password:"), EditBox::Flags::Password, "", true) if password == "" or password == nil
                if password == nil
                  break
                else
                  lt = srvproc("login", { "login" => 2, "name" => name, "password" => password, "computer" => $computer, "appid" => $appid, "crp" => cryptmessage(JSON.generate({ "name" => name, "time" => Time.now.to_i })) })
                  if lt[0].to_i < 0
                    alert(p_("Login", "An error occurred while authenticating the identity. You might have provided an  incorrect password."))
                    password = ""
                  else
                    token = lt[1].delete("\r\n")
                    tokenenc = 0
                    confirm(p_("Login", "Do you want to enable auto-Login-key encryption? When encrypted, the Auto-Login Key will be readable only on this computer, and its copying or exporting will not allow other devices to access your account. Note: If you encrypt your Auto-Login Key, the created portable versions will not be able to automatically log into your account from other devices, even if you copy your settings, and you will be prompted to enter your password. You can create as many auto-login-keys as you wish for all other computers you are using.")) {
                      pin = makepin
                      token = crypt(token, pin)
                      tokenenc = 1
                      tokenenc = 2 if pin != nil
                    }
                    oautologin = autologin
                    autologin = 3
                    write_logindata(autologin, name, token, tokenenc)
                    if oautologin.to_i == 1 or oautologin.to_i == 2
                      alert(p_("Login", "Automatic login will be proceeding until you log out.Automatic login keys can be  managed from the My Account tab in the Community menu."))
                    else
                      alert(p_("Login", "Login data has been updated. Automatic login will be proceeding until you log  out. Automatic login keys can be managed from the My Account tab in the Community  menu."))
                    end
                    speech_wait
                    break
                  end
                end
              end
            when 2
              writeconfig("Login", "EnableAutoLogin", 0)
              load_configuration
              delete_logindata
              alert(p_("Login", "To reenable auto log in feature, proceed to the general settings."))
            end
            break
          end
        end
        dialog_close
      end
      $agent.write(Marshal.dump({ "func" => "relogin", "name" => Session.name, "token" => Session.token, "hwnd" => $wnd }))
      if $speech_wait == true
        $speech_wait = false
        speech_wait
      end
      play("login")
      if Session.greeting == "" or Session.greeting == "\r\n" or Session.greeting == nil or Session.greeting == " "
        speech(p_("Login", "Logged in as: %{user}") % { "user" => name }) if $silentstart != true
      else
        speech(Session.greeting) if $silentstart != true
      end
      delay(0.1)
    when -1
      alert(_("Database Error"))
      Session.token = nil
      speech_wait
      @skipauto = true
      return main
    when -2
      alert(p_("Login", "Invalid login or password.")) if autologin.to_i == 0
      Session.token = nil
      speech_wait
      @skipauto = true
      return main
    when -3
      alert(p_("Login", "Login failure."))
      Session.token = nil
      speech_wait
      @skipauto = true
      return main
    when -4
      alert(p_("Login", "Connection failure."))
      Session.token = nil
      speech_wait
    end
    $speech_wait = true
    $scene = Scene_Loading.new
    $preinitialized = false
    $scene = Scene_Main.new if Session.token != nil
  end

  def makepin
    pin = ""
    while pin == ""
      if confirm(p_("Login", "Do you want to encrypt this key with a custom pin code? You will be prompted for this code everytime you start Elten to unlock your account, but it will not be saved on the server and will be valid only for the auto-login-key stored on this device.")) == 0
        return nil
      else
        p1 = input_text(p_("Login", "Enter pin code"), EditBox::Flags::Password, "", true)
        next if p1 == nil
        p2 = input_text(p_("Login", "Enter pin code again"), EditBox::Flags::Password, "", true)
        next if p2 == nil
        if p1 == p2
          return p1
        else
          alert(p_("Login", "The pin codes entered are different, please try again."))
        end
      end
    end
  end

  Magic = "EltenLoginCredentialsPRVDataFile"

  def write_logindata(autologin, name, token, tokenenc)
    str = [Magic, autologin, name.bytesize, name, token.bytesize, token, tokenenc].pack("a*CIa*Ia*c")
    writefile(Dirs.eltendata + "\\login.dat", str)
  end

  def read_logindata
    return [0, "", "", -1] if !FileTest.exists?(Dirs.eltendata + "\\login.dat")
    str = readfile(Dirs.eltendata + "\\login.dat")
    io = StringIO.new(str)
    return [0, "", "", -1] if io.read(Magic.bytesize) != Magic
    autologin = io.read(1).unpack("C").first
    name = io.read(io.read(4).unpack("I").first)
    token = io.read(io.read(4).unpack("I").first)
    tokenenc = io.read(1).unpack("c").first
    return [autologin, name, token, tokenenc]
  rescue Exception
    return [0, "", "", -1]
  end

  def delete_logindata
    File.delete(Dirs.eltendata + "\\login.dat") if FileTest.exists?(Dirs.eltendata + "\\login.dat")
  rescue Exception
  end
end
