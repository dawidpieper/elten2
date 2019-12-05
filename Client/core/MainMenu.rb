#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_MainMenu  
def initialize
    $runprogram = nil
    play("menu_open")
    play("menu_background")
    @header = _("MainMenu:head")
  end
  def main
                sel = [_("MainMenu:opt_community"),_("MainMenu:opt_addons"),_("MainMenu:opt_tools"),_("MainMenu:opt_settings"),_("MainMenu:opt_help"),_("MainMenu:opt_quit")]
                @sel = menulr(sel,true,0,@header)
        @header = ""
        skiploop=false
    loop do
      loop_update if skiploop==false
      @sel.update
      if $scene != self
        break
      end
      if enter or (arrow_down) or skiploop
        index = @sel.index
        case @sel.index
        when 0
          s=community
          when 1
            s=addons
          when 2
            s=tools
            when 3
              s=settings
            when 4
              s=help
          when 5
            s=exit
          end
          if $scene == self
            loop_update if s==false
@sel = menulr(sel)
                  @sel.index = index
          @sel.focus
        end
        if s==true
        skiploop=true
      else
        skiploop=false
                end
          end
          if escape or alt
close
            end
          end
        end
                  def help
        @sel = Select.new([_("MainMenu:opt_changelog"),_("MainMenu:opt_version"),_("MainMenu:opt_sounds"),_("MainMenu:opt_readme"),_("MainMenu:opt_shortkeys"),_("MainMenu:opt_report"),_("MainMenu:opt_license")])
    loop do
loop_update
      if arrow_left or arrow_right or escape or (arrow_up and @sel.index==0)
                return (arrow_left or arrow_right)
              end
                    @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Changes.new
          close
          break
          when 1
$scene=Scene_Version.new
          close
          break
          when 2
            $scene=Scene_Sounds.new
            close
            break
          when 3
            $scene = Scene_ReadMe.new
            close
            break
            when 4
              $scene = Scene_ShortKeys.new
              close
              break
            when 5
            $scene = Scene_Bug.new
            close
            break
            when 6
              $scene = Scene_License.new
              close
              break
            end
          end
          if alt
close
            end
          end
        end
          def settings
    @sel = Select.new([_("MainMenu:opt_general"),_("MainMenu:opt_voice"),_("MainMenu:opt_clock"),_("MainMenu:opt_soundcard"),_("MainMenu:opt_soundthemes"),_("MainMenu:opt_languages"),_("MainMenu:opt_advanced")])
    loop do
loop_update
      if arrow_left or arrow_right or escape or (arrow_up and @sel.index==0)
                return (arrow_left or arrow_right)
              end
                    @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
          $scene = Scene_General.new
          close
          break
        when 1
          $scene = Scene_Voice.new
          close
          break
          when 2
                  $scene=Scene_Clock.new
                  close
                  break
          when 3
            $scene=Scene_SoundCard.new
            close
            break
            when 4
            $scene = Scene_SoundThemes.new
            close 
            break
            when 5
              $scene = Scene_Languages.new
              close
              break
              when 6
                $scene=Scene_Advanced.new
                close
                break
                            end
          end
          if alt
close
            end
          end
        end
  def community
    @sel = Select.new(sel = [_("MainMenu:opt_messages"),_("MainMenu:opt_blogs"),_("MainMenu:opt_forum"),_("MainMenu:opt_chat"),_("MainMenu:opt_notes"),_("MainMenu:opt_whatsnew"),_("MainMenu:opt_polls"),_("MainMenu:opt_users"),_("MainMenu:opt_account")])
          @sel.disable_item(8) if $name=="guest"
    loop do
      loop_update
      if (arrow_right and @sel.index!=7 and @sel.index!=8) or escape or (arrow_up and @sel.index==0)
                return (arrow_right)
              end
                    @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Messages.new
          close
          break
          when 1
            $scene = Scene_Blog.new
            close
            break
        when 2
          $scene = Scene_Forum.new
          close
          break
          when 3
                          $scene = Scene_Chat.new
              close
              break
          when 4
                            $scene=Scene_Notes.new
                close
                break
            when 5
              whatsnew
              close
              break
                          when 6
                  $scene=Scene_Polls.new
  close
  break
  when 7
    index = @sel.index
                s=users
                return s if s==true
                if $scene == self
               loop_update
                                 @sel = Select.new(sel)
                                 @sel.disable_item(8) if $name=="guest"                                 
                @sel.index = index
                            @sel.focus
                          else
                            return
                            end
  when 8
                index = @sel.index
                s=myaccount
                return s if s==true
                if $scene == self
               loop_update
                                 @sel = Select.new(sel)
                @sel.index = index
                            @sel.focus
                          else
                            return
                            end
            end
          end
                    if arrow_right and @sel.index == 7
            index = @sel.index
            s=users
            return s if s==true
            if $scene == self
            @sel = Select.new(sel)
            @sel.disable_item(8) if $name=="guest"
            @sel.index = index
            @sel.focus
          else
            return
            end
                       end
          if arrow_right and @sel.index == 8
            index = @sel.index
            s=myaccount
            return s if s==true
            if $scene == self
            @sel = Select.new(sel)
            @sel.index = index
            @sel.focus
          else
            return
            end
                       end
          if alt
close
            end
          end
        end
          def myaccount
    @sel = Select.new([_("MainMenu:opt_profile"),_("MainMenu:opt_greeting"),_("MainMenu:opt_honors"),_("MainMenu:opt_avatar"),_("MainMenu:opt_whatsnewconfig"),_("MainMenu:opt_blacklist"),_("MainMenu:opt_autologintokens"),_("MainMenu:opt_logins"),_("MainMenu:opt_changepassword"),_("MainMenu:opt_changemail"),_("MainMenu:opt_twofactor"),_("MainMenu:opt_mailevents")])
    loop do
loop_update
      if arrow_left or arrow_right or escape
                return (arrow_right)
              end
                    @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Account_Profile.new
          close
          break
        when 1
                        $scene = Scene_Account_Greeting.new
            close
            break
          when 2
                          $scene=Scene_Honors.new($name)
              close
              break
            when 3
                                          $scene=Scene_Account_Avatar.new
              close
              break
            when 4
              $scene=Scene_Account_WhatsNew.new
              close
              break
              when 5
                $scene=Scene_Account_BlackList.new
                close
                break
              when 6
                $scene=Scene_Account_AutoLogins.new
                close
                break
              when 7
                $scene=Scene_Account_Logins.new
                close
                break
                when 8
          $scene = Scene_Account_Password.new
          close
          break
        when 9
          $scene = Scene_Account_Mail.new
          close
          break
          when 10
            $scene = Scene_Authentication.new
          close
          break
          when 11
            $scene=Scene_Account_MailEvents.new
            close
            break
            end
          end
          if alt
close
            end
          end
        end
                  def tools
                    sel=[_("MainMenu:opt_speedtest"),_("MainMenu:opt_portable"),_("MainMenu:opt_reinstall"),_("MainMenu:opt_log"),_("MainMenu:opt_console"),_("MainMenu:opt_debug")]
                    sel[2]=_("MainMenu:opt_install") if $portable!=0
    @sel = Select.new(sel)
        @sel.disable_item(6) if $DEBUG!=true
        loop do
loop_update
      if enter
        case @sel.index
            when 0
      $scene=Scene_SpeedTest.new
      close
      break
      when 1
        $scene=Scene_Portable.new
        close
        break
        when 2
          $scene=Scene_Update.new
          close
          break
       when 3
         $scene=Scene_Log.new
         close
         break
         when 4
     $scene = Scene_Console.new
     close
     break
       when 5
         $scene=Scene_Debug.new
         close
         break
               end
          end
          if arrow_left or (arrow_right and @sel.index!=2) or escape or (arrow_up and @sel.index==0)
                        return (arrow_left or arrow_right)
                      end
                            @sel.update
      if $scene != self
        break
      end
          if alt
            close
            end
          end
        end  
        def exit
    @sel = Select.new([_("MainMenu:opt_tray"),_("MainMenu:opt_logout"),_("MainMenu:opt_exit"),_("MainMenu:opt_restart"),_("MainMenu:opt_restarttodebug")])
    loop do
loop_update
      if enter
        case @sel.index
        when 0
    close
    delay(0.5)
    tray
  break
          when 1
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
            $scene = Scene_Loading.new
            close
            break
            when 2
                            $scene = nil
              close
              break
              when 3
                              play("logout")
              $scene = Scene_Loading.new
              close
              break
              when 4
                play("logout")
              $DEBUG=true
              $scene = Scene_Loading.new
              close
              break
            end
          end
          if arrow_left or escape or (arrow_up and @sel.index==0)
                        return (arrow_left)
                      end
                            @sel.update
      if $scene != self
        break
      end
          if alt
            close
            end
          end
        end
  def close
    play("menu_close")
Audio.bgs_fade(100)
loop_update
    $scene = Scene_Main.new if $scene == self
              if $runprogram != nil
                                            $scene=$runprogram.new
                end
              end
    def addons
    @sel = Select.new([_("MainMenu:opt_files"),_("MainMenu:opt_readtofile"),_("MainMenu:opt_youtube")],true,0,"",true)
        @sel.focus
    loop do
loop_update
      if arrow_left or arrow_right or escape or (arrow_up and @sel.index==0)
                return (arrow_left or arrow_right)
              end
                    @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Files.new
          close
          break
          when 1
            $scene=Scene_SpeechToFile.new
            close
            break
        when 2
          $scene=Scene_Youtube.new
          close
          break
            end
          end
          if alt
close
            end
          end
        end
        def users
    @sel = Select.new([_("MainMenu:opt_contacts"),_("MainMenu:opt_useraddedmetocontacts"),_("MainMenu:opt_online"),_("MainMenu:opt_userslist"),_("MainMenu:opt_admins"),_("MainMenu:opt_usersearch"),_("MainMenu:opt_recentlyactived"),_("MainMenu:opt_recentlyregistered"),_("MainMenu:opt_lastavatars")])
    loop do
loop_update
      if arrow_left or arrow_right or escape
                return (arrow_right)
              end
                    @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
          $scene=Scene_Contacts.new
          close
          break
          when 1
            $scene=Scene_Users_AddedMeToContacts.new
            close
            break
            when 2
              $scene=Scene_Online.new
              close
              break
              when 3
                $scene=Scene_Users.new
                close
                break
                when 4
                                      $scene=Scene_Admins.new
                    close
                    break
                    when 5
                      $scene=Scene_UserSearch.new
                      close
                      break
                      when 6
                        $scene=Scene_Users_RecentlyActived.new
                        close
                        break
                        when 7
                          $scene=Scene_Users_RecentlyRegistered.new
                          close
                          break
                          when 8
                            $scene=Scene_Users_LastAvatars.new
                            close
                            break
            end
          end
          if alt
close
            end
          end
        end
  end
#Copyright (C) 2014-2019 Dawid Pieper