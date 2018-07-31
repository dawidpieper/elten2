#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_MainMenu  
def initialize
    $runprogram = nil
    play("menu_open")
    play("menu_background")
    @header = "Menu: "
  end
  def main
        sel = ["Społe&czność","&Media","&Pliki","Pro&gramy","&Narzędzia","U&stawienia","P&omoc","W&yjście"]
                @sel = menulr(sel,true,0,@header)
        @header = ""
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if enter or (Input.trigger?(Input::DOWN) and @sel.index != 2)
        index = @sel.index
        case @sel.index
        when 0
          community
          when 1
            media
                        when 2
            $scene = Scene_Files.new
            close
            break
            when 3
              programs
          when 4
            tools
            when 5
              settings
            when 6
              help
          when 7
            exit
          end
          if $scene == self
            loop_update
@sel = menulr(sel)
                  @sel.index = index
          @sel.focus
          end
          end
          if escape or alt
close
            end
          end
        end
        def programs
    Graphics.transition(10)  if $ruby != true
    sel=[]
    $app=[] if $app==nil
    for a in $app
      sel.push(a[2])
    end
    sel.push("Zainstaluj nowe programy")
    @sel = menulr(sel)
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if Input.trigger?(Input::UP) or escape
                return
        end
      if enter
  if @sel.index<@sel.commandoptions.size-1
        $runprogram = $app[@sel.index][3]
  $runprogram=nil if @sel.commandoptions.size==0
else
  $scene=Scene_Programs.new
  end
close
break
          end
          if alt
close
            end
          end
        end
                  def help
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(["Lista &zmian","&Wersja programu","&Przeczytaj mnie","Lista &skrótów klawiszowych","Zgłoś &błąd","&Licencja użytkownika"])
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if Input.trigger?(Input::UP) or escape
                return
        end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Changes.new
          close
          break
          when 1
            startmessage = "ELTEN: " + $version.to_s
    startmessage += " BETA #{$beta.to_s}" if $isbeta == 1
    startmessage += " RC #{$alpha.to_s}" if $isbeta == 2
    speech(startmessage)
            speech_wait
          close
          break
          when 2
            $scene = Scene_ReadMe.new
            close
            break
            when 3
              $scene = Scene_ShortKeys.new
              close
              break
            when 4
            $scene = Scene_Bug.new
            close
            break
            when 5
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
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(["Ustawienia &interfejsu","Ustawienia &głosu","&Zegar","Tematy &dźwiękowe","Zarządzanie &językami","Ustawienia z&aawansowane"])
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if Input.trigger?(Input::UP) or escape
                return
        end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Interface.new
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
            $scene = Scene_SoundThemes.new
            close 
            break
            when 4
              $scene = Scene_Languages.new
              close
              break
              when 5
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
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(sel = ["Wiado&mości","&Blogi","&Forum","&Chat","No&tatki","Co &nowego?","&Ankiety","&Użytkownicy","M&oje Konto"])
    @sel.disable_item(8) if $name=="guest"
    loop do
      loop_update
      @sel.update
      if $scene != self
        break
      end
      if Input.trigger?(Input::UP) or escape
                return
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
                users
                if $scene == self
               loop_update
                                 @sel = menulr(sel)
                                 @sel.disable_item(8) if $name=="guest"                                 
                @sel.index = index
                            @sel.focus
                          else
                            return
                            end
  when 8
                index = @sel.index
                myaccount
                if $scene == self
               loop_update
                                 @sel = menulr(sel)
                @sel.index = index
                            @sel.focus
                          else
                            return
                            end
            end
          end
                    if Input.trigger?(Input::DOWN) and @sel.index == 7
            index = @sel.index
            users
            if $scene == self
            @sel = menulr(sel)
            @sel.disable_item(8) if $name=="guest"
            @sel.index = index
            @sel.focus
          else
            return
            end
                       end
          if Input.trigger?(Input::DOWN) and @sel.index == 8
            index = @sel.index
            myaccount
            if $scene == self
            @sel = menulr(sel)
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
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(["Edytuj &profil","Zmiana &statusu","Moja sy&gnatura","Moja wiadomość po&witalna","Moja w&izytówka","Moje &odznaczenia","U&dostępnione przeze mnie pliki","Ustaw &awatar","Ustawienia co &nowego","Moje &uprawnienia","Cza&rna lista","Klucze automatycznego &logowania","Zmień &Hasło","Zmień adres e-&mail","Ustawienia uwierzytelniania dwu&etapowego"])
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if Input.trigger?(Input::UP) or escape
                return
        end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Account_Profile.new
          close
          break
        when 1
              $scene = Scene_Account_Status.new
              close
              break
        when 2
          $scene = Scene_Account_Signature.new
          close
          break
          when 3
                        $scene = Scene_Account_Greeting.new
            close
            break
          when 4
            $scene = Scene_Account_VisitingCard.new
            close
            break
            when 5
              $scene=Scene_Honors.new($name)
              close
              break
            when 6
              $scene = Scene_Uploads.new
              close
              break
              when 7
              $scene=Scene_Account_Avatar.new
              close
              break
            when 8
              $scene=Scene_Account_WhatsNew.new
              close
              break
              when 9
              $scene=Scene_MyPermissions.new
              close
              break
              when 10
                $scene=Scene_Account_BlackList.new
                close
                break
              when 11
                $scene=Scene_Account_AutoLogins.new
                close
                break
              when 12
          $scene = Scene_Account_Password.new
          close
          break
        when 13
          $scene = Scene_Account_Mail.new
          close
          break
          when 14
            $scene = Scene_Authentication.new
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
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(sel=["&Generator tematów dźwiękowych","&Test prędkości łącza","Zarządzanie p&rogramem","Czytanie do &pliku","&Konsola","Kompilator &ELTENAPI","De&bugowanie"])
    @sel.disable_item(6) if $DEBUG!=true
        loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if enter or (Input.trigger?(Input::DOWN) and @sel.index == 2)
        case @sel.index
        when 0
  $scene = Scene_SoundThemesGenerator.new
  close
  break
  when 1
   speedtest
   close
   break
  when 2
    index = @sel.index
    management
        if $scene == self
               loop_update
                  @sel = menulr(sel)
                @sel.index = index
                            @sel.focus
                          else
                            return
                          end
                          when 3
                            $scene=Scene_SpeechToFile.new
                            close
                            break
       when 4
     $scene = Scene_Console.new
     close
     break
     when 5
       $scene = Scene_Compiler.new
       close
       break
       when 6
         $scene=Scene_Debug.new
         close
         break
               end
          end
          if Input.trigger?(Input::UP) or escape
                        return
            end
          if alt
            close
            end
          end
        end  
        def exit
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(["&Ukryj program w zasobniku systemowym","Wy&loguj się","W&yjście","&Restart","Restart do trybu de&bugowania"])
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
    close
    delay(0.5)
    tray
  break
          when 1
autologin=readini($configdata+"\\login.ini","Login","AutoLogin","0").to_i
if autologin==3
  srvproc("logout","name=#{$name}\&token=#{$token}\&autologin=1\&autotoken=#{readini($configdata+"\\login.ini","Login","Token","")}")
end
if autologin.to_i>0
  writeini($configdata+"\\login.ini","Login","AutoLogin","-1")
  writeini($configdata+"\\login.ini","Login","Name",nil)
  writeini($configdata+"\\login.ini","Login","Password",nil)
  writeini($configdata+"\\login.ini","Login","Token",nil)
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
              Graphics.transition(120)
              $scene = Scene_Loading.new
              close
              break
              when 4
                play("logout")
              Graphics.transition(120)
              $DEBUG=true
              $scene = Scene_Loading.new
              close
              break
            end
          end
          if Input.trigger?(Input::UP) or escape
                        return
            end
          if alt
            close
            end
          end
        end
  def close
    play("menu_close")
Audio.bgs_fade(2000)
for i in 1..Graphics.frame_rate
  loop_update
  end
    $scene = Scene_Main.new if $scene == self
              if $runprogram != nil
                                            $scene=$runprogram.new
                end
              end
              def management
     Graphics.transition(10)  if $ruby != true
sel=["Sprawdź dostępność &aktualizacji","&Reinstalacja programu","Utwórz wersję &przenośną","Przywróć ustawienia &domyślne"]
if $portable == 1
  sel=["","Za&instaluj program","Utwórz &kopię","Przywróć ustawienia &domyślne"]
  end
     @sel = menulr(sel)
     if $portable == 1
       @sel.index=1
       @sel.focus
       @sel.disable_item(0)
       end
        loop do
      loop_update
      @sel.update
      if $scene != self
        break
      end
      if enter
        case @sel.index
        when 0
          versioninfo
          close
          break
          when 1
            $scene = Scene_ReInstall.new if simplequestion("Czy chcesz przywrócić ostatnią stabilną wersję programu? Wszystkie ustawienia zostaną zachowane.") == 1
                        close
            break
            when 2
            $scene=Scene_Portable.new
            close
            break
            when 3
              if simplequestion("Czy jesteś pewien, że chcesz usunąć wszystkie ustawienia programu i przywrócić wartości domyślne? Elten zostanie uruchomiony ponownie.") == 0
                close
                break
                else
              dr = Dir.entries($configdata)
              dr.delete(".")
              dr.delete("..")
              for file in dr
                if File.extname(file).downcase == ".ini"
                  File.delete($configdata+"\\"+file)
                end
                  end
              play("right")
                  $scene = Scene_Loading.new
                  close
              break
              end
          end
          end
      if Input.trigger?(Input::UP) or escape
        return
      end
      if alt
        close
      end
      
      end
    end
    def media
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(["Katalog &mediów","&Youtube"])
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if Input.trigger?(Input::UP) or escape
                return
        end
      if enter
        case @sel.index
        when 0
          $scene = Scene_Media.new
          close
          break
        when 1
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
    Graphics.transition(10)  if $ruby != true
    @sel = menulr(["Moje &kontakty","Użytkownicy, którzy &dodali mnie do swoich kontaktów","Kto jest zal&ogowany?","Lista &użytkowników","Rada &starszych","S&zukanie użytkowników","Ostatnio &aktywni użytkownicy","Ostatnio za&rejestrowani użytkownicy","Ostatnio zmienione awa&tary"])
    loop do
loop_update
      @sel.update
      if $scene != self
        break
      end
      if Input.trigger?(Input::UP) or escape
                return
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
#Copyright (C) 2014-2016 Dawid Pieper