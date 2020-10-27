# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

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
    if $activecontrols!=nil
        for c in $activecontrols||[]
      if !c.menu_enabled?
        return
        end
      if defaults != :defaults && (Configuration.contextmenubar==1 || defaults==false)
        c.context(@menu, defaults)
    end
  end
  end
  if defaults==true && !$scene.is_a?(Scene_Main)
    if Session.logged?
    @menu.submenu(p_("MainMenu", "Quick &actions")) {|m|
    QuickActions.get.each {|a|m.quickaction(a.label, a) if a.show}
    }
  end
  end
    if defaults or defaults==:defaults
            @menu.header=@header if $activecontrols==nil || $activecontrols.size==0
            if Session.logged?
      @menu.submenu(p_("MainMenu", "&Community")) {|m|
      if Session.name!=nil && Session.name!="guest"
    m.scene(p_("MainMenu", "&Messages"), Scene_Messages)
    end
    m.scene(p_("MainMenu", "&Blogs"), Scene_Blog)
    m.scene(p_("MainMenu", "&Forum"), Scene_Forum)
    if Session.name!=nil && Session.name!="guest"
    m.scene(p_("MainMenu", "&Chat"), Scene_Chat)
        m.scene(p_("MainMenu", "No&tes"), Scene_Notes)
            m.scene(p_("MainMenu", "What's &new?"), Scene_WhatsNew)
    m.scene(p_("MainMenu", "Po&lls"), Scene_Polls)
    end
    @menu.submenu(p_("MainMenu", "&Users")) {|m|
    if Session.name!=nil && Session.name!="guest"
    m.scene(p_("MainMenu", "My &contacts"), Scene_Contacts)
    m.scene(p_("MainMenu", "Users who a&dded me to contacts"), Scene_Users_AddedMeToContacts)
    end
    m.scene(p_("MainMenu", "Who is &online?"), Scene_Online)
    m.scene(p_("MainMenu", "&badges"), Scene_Honors)
    m.scene(p_("MainMenu", "&Users list"), Scene_Users)
    m.scene(p_("MainMenu", "Ad&mins"), Scene_Admins)
    m.scene(p_("MainMenu", "User searc&h"), Scene_UserSearch)
    m.scene(p_("MainMenu", "Recently &active users"), Scene_Users_RecentlyActived)
    m.scene(p_("MainMenu", "Recently &registered users"), Scene_Users_RecentlyRegistered)
    }
    if Session.name!=nil&&Session.name!='guest'
      @menu.scene(p_("MainMenu", "Manage my &account"), Scene_Account)
      end
    }
    end
    @menu.submenu(p_("MainMenu", "&Programs")) {|m|
    list=Programs.list
    for prg in list
      m.scene(prg::MainMenuOption||prg::Name||prg.to_s, prg) if prg::NoMenuItem!=true
      end
    m.scene(p_("MainMenu", "Programs installation"), Scene_Programs)
    }
    @menu.submenu(p_("MainMenu", "&Tools")) {|m|
    m.scene(p_("MainMenu", "Program &settings"), Scene_Settings)
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
   m.scene(p_("MainMenu", "User &agreement"), Scene_License)
    }
    @menu.submenu(p_("MainMenu", "&Quit")) {|m|
    m.option(p_("MainMenu", "Hide in &tray")) {
    tray
    }
    if Session.logged?
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
    end
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
    if ($subthreads||[]).size>0 || $mainthread!=$currentthread
      @menu.submenu(p_("MainMenu", "&Windows")) {|m|
      for i in -1...$subthreads.size
        if i>=0
        sc=$subthreads[i]
      else
        sc=$mainthread
        end
        m.option(p_("MainMenu", "Window %{number}")%{'number'=>i+1}, sc) {|sc|
                $switchthread=sc
        $focus = true
Log.info("Switching to thread #{i+1}")
        }
        end
      }
      end
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