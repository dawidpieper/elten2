#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module GlobalMenu
  class <<self
  def show(defaults=true)
    return if opened?
        return if construct(defaults)==false
        loop_update
        return if @menu.size==0
        @menu.open
        loop_update
  end
  def construct(defaults=true)
    @header=""
    @header = p_("MainMenu", "Menu") if defaults
    style=:menu
    style=:menubar if defaults
    @menu = Menu.new("",style)
    for c in $activecontrols
      if !c.menu_enabled?
        return
        end
      c.context(@menu, defaults)
      end
    if defaults
            @menu.header=@header if $activecontrols.size==0
      @menu.submenu(p_("MainMenu", "&Community")) {|m|
    m.option(p_("MainMenu", "&Messages")) {
    makescene Scene_Messages.new
    }
    m.option(p_("MainMenu", "&Blogs")) {
    makescene Scene_Blog.new
    }
    m.option(p_("MainMenu", "&Forum")) {
    makescene Scene_Forum.new
    }
    m.option(p_("MainMenu", "&Chat")) {
    makescene Scene_Chat.new
    }
    m.option(p_("MainMenu", "No&tes")) {
    makescene Scene_Notes.new
    }
    m.option(p_("MainMenu", "What's &new?")) {
    whatsnew
    }
    m.option(p_("MainMenu", "Po&lls")) {
    makescene Scene_Polls.new
    }
    @menu.submenu(p_("MainMenu", "&Users")) {|m|
    m.option(p_("MainMenu", "My &contacts")) {
    makescene Scene_Contacts.new
    }
    m.option(p_("MainMenu", "Users who a&dded me to contacts")) {
    makescene Scene_Users_AddedMeToContacts.new
    }
    m.option(p_("MainMenu", "WHo is &online?")) {
    makescene Scene_Online.new
    }
    m.option(p_("MainMenu", "My &badges")) {
    makescene Scene_Honors.new
    }
    m.option(p_("MainMenu", "&Users list")) {
    makescene Scene_Users.new
    }
    m.option(p_("MainMenu", "Ad&mins")) {
    makescene Scene_Admins.new
    }
    m.option(p_("MainMenu", "User searc&h")) {
    makescene Scene_UserSearch.new
    }
    m.option(p_("MainMenu", "Recently &actived users")) {
    makescene Scene_Users_RecentlyActived.new
    }
    m.option(p_("MainMenu", "Recently &registered users")) {
    makescene Scene_Users_RecentlyRegistered.new
    }
    }
    if $name!=nil&&$name!='guest'
      @menu.submenu(p_("MainMenu", "My &account")) {|m|
      m.option(p_("MainMenu", "Edit &profile")) {
      makescene Scene_Account_Profile.new
      }
      m.option(p_("MainMenu", "My &welcome message")) {
      makescene Scene_Account_Greeting.new
      }
      m.option(p_("MainMenu", "My &badges")) {
      makescene Scene_Honors.new($name)
      }
      m.option(p_("MainMenu", "What's &new configuration")) {
      makescene Scene_Account_WhatsNew.new
      }
      m.option(p_("MainMenu", "Black l&ist")) {
      makescene Scene_Account_BlackList.new
      }
      m.option(p_("MainMenu", "Auto &log in tokens")) {
      makescene Scene_Account_AutoLogins.new
      }
      m.option(p_("MainMenu", "Last logins")) {
      makescene Scene_Account_Logins.new
      }
      m.option(p_("MainMenu", "Change passw&ord")) {
      makescene Scene_Account_Password.new
      }
      m.option(p_("MainMenu", "Change e-&mail")) {
      makescene Scene_Account_Mail.new
      }
      m.option(p_("MainMenu", "Two-factor a&uthentication settings")) {
      makescene  Scene_Authentication.new
      }
      m.option(p_("MainMenu", "Mail events reporting")) {
      makescene Scene_Account_MailEvents.new
      }
      }
      end
    }
    @menu.submenu(p_("MainMenu", "&Addons")) {|m|
    m.option(p_("MainMenu", "&Files")) {
    makescene Scene_Files.new
    }
    m.option(p_("MainMenu", "Read to &file")) {
    makescene Scene_SpeechToFile.new
    }
    m.option(p_("MainMenu", "&YouTube")) {
    makescene Scene_Youtube.new
    }
    }
    @menu.submenu(p_("MainMenu", "Pro&grams")) {|m|
    list=Programs.list
    for prg in list
      m.option(prg::MainMenuOption||prg::Name||prg.to_s, prg) {|prg|
      makescene prg.new
      }
      end
    m.option(p_("MainMenu", "Programs installation")) {
    makescene Scene_Programs.new
    }
    }
    @menu.submenu(p_("MainMenu", "&Tools")) {|m|
    m.option(p_("MainMenu", "&Settings")) {
    $scene=Scene_Settings.new
    }
        m.option(p_("MainMenu", "Soun&dthemes")) {
    makescene  Scene_SoundThemes.new
    }
    m.option(p_("MainMenu", "Speed &test")) {
    makescene Scene_SpeedTest.new
    }
    m.option(p_("MainMenu", "Create &Portable version")) {
    makescene Scene_Portable.new
    }
    o=p_("MainMenu", "&Reinstall")
    o=p_("MainMenu", "&Install") if $portable!=0
    m.option(o) {
    makescene Scene_Update.new
    }
    m.option(p_("MainMenu", "&Log viewer")) {
    makescene Scene_Log.new
    }
    m.option(p_("MainMenu", "&Console")) {
    makescene  Scene_Console.new
    }
    m.option(p_("MainMenu", "De&bugging")) {
    makescene Scene_Debug.new
    }
    }
    @menu.submenu(p_("MainMenu", "&Help")) {|m|
    m.option(p_("MainMenu", "&Changelog")) {
    makescene  Scene_Changes.new
    }
    m.option(p_("MainMenu", "Program &version")) {
    makescene Scene_Version.new
    }
    m.option(p_("MainMenu", "Sounds &guide")) {
    makescene Scene_Sounds.new
    }
   m.option(p_("MainMenu", "&Read me")) {
   makescene  Scene_ReadMe.new
   }
   m.option(p_("MainMenu", "&Shortkeys")) {
   makescene  Scene_ShortKeys.new
   }
   m.option(p_("MainMenu", "User &agreement")) {
   makescene  Scene_License.new
   }
    }
    @menu.submenu(p_("MainMenu", "&Quit")) {|m|
    m.option(p_("MainMenu", "Hide in &tray")) {
    tray
    }
    m.option(p_("MainMenu", "&Logout")) {
    autologin=readconfig("Login","AutoLogin",0)
if autologin==3
  srvproc("logout",{"autologin"=>"1", "computer"=>$computer})
end
if autologin.to_i>0
  writeconfig("Login","AutoLogin",-1)
  writeconfig("Login","Name",nil)
  writeconfig("Login","Token",nil)
  writeconfig("Login","TokenEncrypted",nil)
  end
                        play("logout")
            $restart=true
            $scene=Scene_Loading.new
    }
    m.option(p_("MainMenu", "E&xit")) {
    $scene=nil
    }
    m.option(p_("MainMenu", "&Restart")) {
                                  play("logout")
              $restart=true
              $scene=Scene_Loading.new
    }
    m.option(p_("MainMenu", "Restart in de&bug mode")) {
                    play("logout")
              $DEBUG=true
              $scene=Scene_Loading.new
    }
    }
  end
  return true
  end
  def makescene(scene)
    if $scene.is_a?(Scene_Main)
      $scene=scene
    else
      $scenes.insert(0,scene)
      end
    end
    def opened?
      @menu!=nil&&@menu.opened?
      end
      end
      end