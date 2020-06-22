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
        @currentmenu = @menu
        @menu.open
        loop_update
  end
  def construct(defaults=true)
    @header=""
    @header = p_("MainMenu", "Menu") if defaults
    style=:menu
    style=:menubar if defaults
    @menu = Menu.new("",style)
        for c in $activecontrols||[]
      if !c.menu_enabled?
        return
        end
      if defaults != :defaults && ($interface_contextmenubar==1 || defaults==false)
        c.context(@menu, defaults)
    end
  end
  if defaults==true && !$scene.is_a?(Scene_Main)
    @menu.submenu(p_("MainMenu", "Quick &actions")) {|m|
    QuickActions.get.each {|a|m.quickaction(a.label, a) if a.show}
    }
    end
    if defaults or defaults==:defaults
            @menu.header=@header if $activecontrols.size==0
      @menu.submenu(p_("MainMenu", "&Community")) {|m|
    m.scene(p_("MainMenu", "&Messages"), Scene_Messages)
    m.scene(p_("MainMenu", "&Blogs"), Scene_Blog)
    m.scene(p_("MainMenu", "&Forum"), Scene_Forum)
    m.scene(p_("MainMenu", "&Chat"), Scene_Chat)
    m.scene(p_("MainMenu", "No&tes"), Scene_Notes)
    m.scene(p_("MainMenu", "What's &new?"), Scene_WhatsNew)
    m.scene(p_("MainMenu", "Po&lls"), Scene_Polls)
    @menu.submenu(p_("MainMenu", "&Users")) {|m|
    m.scene(p_("MainMenu", "My &contacts"), Scene_Contacts)
    m.scene(p_("MainMenu", "Users who a&dded me to contacts"), Scene_Users_AddedMeToContacts)
    m.scene(p_("MainMenu", "WHo is &online?"), Scene_Online)
    m.scene(p_("MainMenu", "&badges"), Scene_Honors)
    m.scene(p_("MainMenu", "&Users list"), Scene_Users)
    m.scene(p_("MainMenu", "Ad&mins"), Scene_Admins)
    m.scene(p_("MainMenu", "User searc&h"), Scene_UserSearch)
    m.scene(p_("MainMenu", "Recently &actived users"), Scene_Users_RecentlyActived)
    m.scene(p_("MainMenu", "Recently &registered users"), Scene_Users_RecentlyRegistered)
    }
    if Session.name!=nil&&Session.name!='guest'
      @menu.scene(p_("MainMenu", "Manage my &account"), Scene_Account)
      end
    }
    @menu.submenu(p_("MainMenu", "&Addons")) {|m|
    m.scene(p_("MainMenu", "&Files"), Scene_Files)
    m.scene(p_("MainMenu", "Read to &file"), Scene_SpeechToFile)
    }
    @menu.submenu(p_("MainMenu", "Pro&grams")) {|m|
    list=Programs.list
    for prg in list
      m.scene(prg::MainMenuOption||prg::Name||prg.to_s, prg)
      end
    m.scene(p_("MainMenu", "Programs installation"), Scene_Programs)
    }
    @menu.submenu(p_("MainMenu", "&Tools")) {|m|
    m.scene(p_("MainMenu", "&Settings"), Scene_Settings)
    m.scene(p_("MainMenu", "Soun&dthemes"), Scene_SoundThemes)
    m.scene(p_("MainMenu", "Speed &test"), Scene_SpeedTest)
    m.scene(p_("MainMenu", "Create &Portable version"), Scene_Portable)
    if false
    o=p_("MainMenu", "&Reinstall")
    o=p_("MainMenu", "&Install") if $portable!=0
    m.scene(o, Scene_Update)
    end
    m.scene(p_("MainMenu", "&Log viewer"), Scene_Log)
    m.scene(p_("MainMenu", "&Console"), Scene_Console)
    m.scene(p_("MainMenu", "De&bugging"), Scene_Debug)
    }
    @menu.submenu(p_("MainMenu", "&Help")) {|m|
    m.scene(p_("MainMenu", "&Changelog"), Scene_Changes)
    m.scene(p_("MainMenu", "Program &version"), Scene_Version)
    m.scene(p_("MainMenu", "Sounds &guide"), Scene_Sounds)
   m.scene(p_("MainMenu", "&Read me"), Scene_ReadMe)
   m.scene(p_("MainMenu", "&Shortkeys"), Scene_ShortKeys)
   m.scene(p_("MainMenu", "User &agreement"), Scene_License)
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
    $exit=true
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
              $restart=true
              $scene=Scene_Loading.new
    }
    }
  end
  return true
  end
    def opened?
      @currentmenu!=nil&&@currentmenu.opened?
    end
    def scenes
      construct(:defaults)
      @menu.scenes
    end
    def ctitems
      construct(false)
      @menu.items
    end
      end
      end