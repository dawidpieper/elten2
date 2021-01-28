# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

module GlobalMenu
  class <<self
    @@activecontrols=[]
  def show(defaults=true)
        return if opened?
        return if construct(defaults)==false
        loop_update(false)
        return if @menu.size==0
        @currentmenu = @menu
                @menu.open
        @currentmenu = nil
        loop_update(false)
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
        m.scene(p_("MainMenu", "&Conferences"), Scene_Conference)
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
    m.scene(p_("MainMenu", "Ad&mins and authors"), Scene_Admins)
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
        m.scene(p_("MainMenu", "Create &Portable version"), Scene_Portable) if $portable==0
    o=p_("MainMenu", "&Reinstall")
    o=p_("MainMenu", "&Install") if $portable!=0
m.scene(o, Scene_Install)
    m.scene(p_("MainMenu", "&Log viewer"), Scene_Log)
    m.scene(p_("MainMenu", "&Console"), Scene_Console)
    m.scene(p_("MainMenu", "De&bugging"), Scene_Debug)
    }
    @menu.submenu(p_("MainMenu", "&Help")) {|m|
    m.scene(p_("MainMenu", "&Changelog"), Scene_Changes)
    m.scene(p_("MainMenu", "Program &version"), Scene_Version)
    m.scene(p_("MainMenu", "Sounds &guide"), Scene_Sounds)
      m.scene(p_("MainMenu", "&Read me"), Scene_Documentation, "readme")
   m.scene(p_("MainMenu", "&License agreement"), Scene_Documentation, "license")
   m.scene(p_("MainMenu", "&Terms and conditions"), Scene_Documentation, "rules")
   m.scene(p_("MainMenu", "&Privacy policy"), Scene_Documentation, "privacypolicy")
   m.scene(p_("MainMenu", "Infor&mation about migration to Elten version 2.4"), Scene_Documentation, "migration24")
    }
    @menu.submenu(p_("MainMenu", "&Quit")) {|m|
    m.option(p_("MainMenu", "Hide in &tray")) {
    tray
    }
    if Session.logged?
    m.option(p_("MainMenu", "&Logout")) {
    if FileTest.exists?(Dirs.eltendata+"\\login.dat")
  srvproc("logout",{"autologin"=>"1", "computer"=>$computer})
  File.delete(Dirs.eltendata+"\\login.dat")
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