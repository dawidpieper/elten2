#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  # EltenAPI common functions
  module Common
    # Opens the quit menu
    #
    # @param header [String] a message to read, header of the menu
        def quit(header=_("EAPI_Common:head_exiting"))
         dialog_open
            sel = menulr([_("General:str_cancel"),_("EAPI_Common:opt_tray"),_("General:str_quit")],true,0,header)
      loop do
        loop_update
        sel.update
        if $key[0x11] and $key[81]
sel.commandoptions=["Zabieraj mi to okno","Spadaj z mojego pulpitu","Mam ciebie dość, zamknij się","Zejdź mi z oczu"]
          sel.focus
          end
        if escape
          dialog_close
          break
            $exit = false
            return(false)
            end
        if enter
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
    
      # Opens a console      
def console
                        kom = ""
        while kom == "" or kom == nil
          kom = input_text(_("EAPI_Common:type_console"),"MULTILINE|ACCEPTESCAPE").to_s
          if kom == "\004ESCAPE\004"
            $scene = Scene_Main.new
            return
            break
            end
          end
          kom.gsub!("\004LINE\004","\r\n")
          kom.delete!("\005")
  kom = kom.gsub("\004LINE\004","\n")
kom.gsub!("elten.edb","elten.dat")
  $consoleused = true
r=false
  begin
  eval(kom,nil,"Console") if r == false
rescue Exception
    plc=""
  for e in $@
    if e!=nil
    plc+=e+"\r\n" if e[0..6]!="Section"
    end
  end
  lin=$@[0].split(":")[1].to_i
    plc+=kom.delete("\r").split("\n")[lin-1]
  input_text(_("EAPI_Common:error_console"),"READONLY|MULTILINE",$!.to_s+"\r\n"+plc)
  r = true
  end
$consoleused = false        
speech_wait
$scene = Scene_Main.new if $scene == self
end

# @deprecated use rescue instead.
def error_ignore
  $scene = Scene_Main.restart
end


# Opens a menu of a specified user
#
# @param user name of the user whose menu you want to open
# @param submenu [Boolean] specifies if the menu is a submenu
# @return [String] returns ALT if menu was closed using an alt menu
    def usermenu(user,submenu=false)
      if $name!="guest"      
      ct = srvproc("contacts_mod","name=#{$name}\&token=#{$token}\&searchname=#{user}")
      err = ct[0].to_i
if err == -3
  @incontacts = true
else
  @incontacts = false
end
end
av = srvproc("avatar","name=#{$name}\&token=#{$token}\&searchname=#{user}\&checkonly=1")
      err = av[0].to_i
if err < 0
  @hasavatar = false
else
  @hasavatar = true
end
bt = srvproc("isbanned","name=#{$name}\&token=#{$token}\&searchname=#{user}")
@isbanned = false
if bt[0].to_i == 0
  if bt[1].to_i == 1
    @isbanned = true
    end
  end
  bl = srvproc("blog_exist","name=#{$name}\&token=#{$token}\&searchname=#{user}")
    if bl[0].to_i < 0
    @hasblog = false
    else
  if bl[1].to_i == 0
    @hasblog = false
  else
    @hasblog = true
    end
    end
  hn=srvproc("honors","name=#{$name}\&token=#{$token}\&user=#{user}\&list=1")
  if hn[0].to_i<0
    @hashonors=false
  else
    if hn[1].to_i==0
      @hashonors=false
    else
      @hashonors=true
    end
    end
    play("menu_open") if submenu != true
play("menu_background") if submenu != true
sel = [_("EAPI_Common:opt_message"),_("EAPI_Common:opt_visitingcard"),_("EAPI_Common:opt_blog"),_("EAPI_Common:opt_sharedfiles"),_("EAPI_Common:opt_honors")]
if $name!="guest"
if @incontacts == true
  sel.push(_("EAPI_Common:opt_delcontact"))
else
  sel.push(_("EAPI_Common:opt_addcontact"))
end
else
  sel.push("")
  end
sel.push(_("EAPI_Common:opt_playavatar"))
if $rang_moderator > 0
  if @isbanned == false
    sel.push(_("EAPI_Common:opt_ban"))
  else
    sel.push(_("EAPI_Common:opt_unban"))
  end
else
  sel.push("")
  end
  if $name!="guest"
  fl = srvproc("uploads","name=#{$name}\&token=#{$token}\&searchname=#{user}")
  if fl[0].to_i < 0
    speech(_("General:error"))
    speech_wait
    return
  end
  end
    if $usermenuextra.is_a?(Array) and $name!="guest"
    sel+=$usermenuextra
    end
  menu = menulr(sel,true,0,"",true)
  menu.disable_item(2) if @hasblog == false
if $name!="guest"
  menu.disable_item(3) if fl[1].to_i==0
else
  menu.disable_item(0)
  menu.disable_item(3)
  menu.disable_item(5)
  end
menu.disable_item(4) if @hashonors==false
menu.disable_item(6) if @hasavatar == false
menu.disable_item(7) if $rang_moderator==0
menu.focus
loop do
loop_update
menu.update
if enter
  case menu.index
  when 0
    $scene = Scene_Messages_New.new(user,"","",self)
    when 1
      play("menu_close")
      Audio.bgs_stop
      visitingcard(user)
            return("ALT")
      break
            when 2
        $scene = Scene_Blog_Main.new(user,0,self)
        when 3
          $scene = Scene_Uploads.new(user,self)
    when 4
        $scene=Scene_Honors.new(user,self)
          when 5
      if @incontacts == true
        $scene = Scene_Contacts_Delete.new(user,self)
      else
        $scene = Scene_Contacts_Insert.new(user,self)
      end
            when 6
        play("menu_close")
      Audio.bgs_stop
      speech(_("EAPI_Common:wait_downloading"))
      avatar(user)
            return("ALT")
      break        
      when 7
        if @isbanned == false
          $scene = Scene_Ban_Ban.new(user,self)
        else
          $scene = Scene_Ban_Unban.new(user,self)
        end
      else
                if $usermenuextrascenes.is_a?(Array)
                  play("menu_close")
                  Audio.bgs_stop
                  $scenes.insert(0,$usermenuextrascenes[menu.index-8].userevent(user))
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
  if submenu == true
        return
    break
  else
        break
    end
  end
  if Input.trigger?(Input::UP) and submenu == true
        Input.update
    return
    break
    end
end
Audio.bgs_stop if submenu != true
play("menu_close") if submenu != true
delay(0.15) if submenu != true
end

# Opens a what's new menu
#
# @param quiet [Boolean] if true, no text is read if there's nothing new
     def whatsnew(quiet=false)
       agtemp = srvproc("agent","name=#{$name}\&token=#{$token}\&client=1")
       err = agtemp[0]
messages = agtemp[8].to_i
posts = agtemp[9].to_i
blogposts = agtemp[10].to_i
blogcomments = agtemp[11].to_i
followedforums=agtemp[12].to_i
followedforumsposts=agtemp[13].to_i
friends=agtemp[14].to_i
birthday=agtemp[15].to_i
mentions=agtemp[16].to_i
$nversion=agtemp[2].to_f
$nbeta=agtemp[3].to_i
                                    if messages <= 0 and posts <= 0 and blogposts <= 0 and blogcomments <= 0 and followedforums<=0 and followedforumsposts<=0 and friends<=0 and birthday<=0 and mentions<=0 and ($nversion<$version or ($nversion==$version and $isbeta!=1))
  speech(_("EAPI_Common:info_nothingnew")) if quiet != true
else
    $scene = Scene_WhatsNew.new(true,agtemp)
end
speech_wait
end

# Opens a soundthemes generator
#
# @param name [String] a soundtheme name
def createsoundtheme(name="")
  while name == ""
    name = input_text(_("EAPI_Common:type_soundthemename"),"ACCEPTESCAPE")
  end
  return if name == "\004ESCAPE\004"
  pathname = name
  pathname.gsub!(" ","_")
  pathname.gsub!("/","_")
  pathname.gsub!("\\","_")
  pathname.gsub!("?","")
  pathname.gsub!("*","")
  pathname.gsub!(":","__")
  pathname.gsub!("<","")
  pathname.gsub!(">","")
  pathname.gsub!("\"","'")
  stp = $soundthemesdata + "\\" + pathname
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(stp,nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(stp + "\\SE",nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(stp + "\\BGS",nil)
dir = Dir.entries("Audio/BGS")
dir.delete("..")
dir.delete(".")
for i in 0..dir.size - 1
Win32API.new("kernel32","CopyFile",'ppi','i').call(".\\Audio\\BGS\\" + dir[i],stp + "\\BGS\\" + dir[i],0)
end
Graphics.update
dir = Dir.entries("Audio/SE")
dir.delete("..")
dir.delete(".")
for i in 0..dir.size - 1
Win32API.new("kernel32","CopyFile",'ppi','i').call(".\\Audio\\SE\\" + dir[i],stp + "\\SE\\" + dir[i],0)
end
Graphics.update
writeini($soundthemesdata + "\\inis\\" + pathname + ".ini","SoundTheme","Name","#{name} by #{$name}")
writeini($soundthemesdata + "\\inis\\" + pathname + ".ini","SoundTheme","Path",pathname)
speech(s_("EAPI_Common:info_soundthemecreation",{'dir'=>stp}))
speech_wait
sel = menulr([_("EAPI_Common:opt_openthemedir"),_("EAPI_Common:opt_openthemedirinexplorer"),_("General:str_quit")],true,0,_("EAPI_Common:head_whattodo"))
loop do
  loop_update
  sel.update
  if escape
        return
    break
  end
  if enter
    case sel.index
    when 0
      $scene = Scene_Files.new(stp)
      return
      break
      when 1
        run("explorer " + stp)
        when 2
          return
          break
    end
    end
  end
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
            di +="\r\n[Computer]\r\n"
            di += "OS version: " + Win32API.new($eltenlib,"WindowsVersion",'','i').call.to_s + "\r\n"
                        di += "Elten data path: " + $eltendata.to_s + "\r\n"
                procid = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("PROCESSOR_IDENTIFIER",procid,procid.size)
procid.delete!("\0")
di += "Processor Identifier: " + procid.to_s + "\r\n"
                procnum = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("NUMBER_OF_PROCESSORS",procnum,procnum.size)
procnum.delete!("\0")
di += "Number of processors: " + procnum.to_s + "\r\n"
ramt=[0].pack("l")
Win32API.new("kernel32","GetPhysicallyInstalledSystemMemory",'p','i').call(ramt)
ram=ramt.unpack("l")[0]/1024

di += "RAM Memory: "+ram.to_s+"MB\r\n"
memt=[0,0,0,0,0,0,0,0,0,0].pack('iiiiiiiiii')
Win32API.new("psapi","GetProcessMemoryInfo",'ipi','i').call($process,memt,memt.size)
di += "Memory usage: "+(memt.unpack('i'*9)[3]/1048576).to_s+"MB\r\n"
di += "Peak memory usage: "+(memt.unpack('i'*9)[2]/1048576).to_s+"MB\r\n"
cusername = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("USERNAME",cusername,cusername.size)
cusername.delete!("\0")
di += "User name: " + cusername.to_s + "\r\n"
di += "\r\n[Elten]\r\n"
di += "User: " + $name.to_s + "\r\n"
di += "Token: " + $token.to_s + "\r\n"
ver = $version.to_s
ver += "_BETA" if $isbeta == 1
ver += "_RC" if $isbeta == 2
ver += $beta.to_s if $isbeta == 1
di += "Version: " + ver.to_s + "\r\n"
di += "URL: "+$url.to_s+"\r\n"
di += "Start time: " + $start.to_s + "\r\n"
di += "Current time: " + Time.now.to_i.to_s + "\r\n"
if $app!=nil
di += "\r\n[Programs]\r\n"
for i in 0..$app.size - 1
di += $app[i][0].to_s
di += "\r\n"
end
end
di += "\r\n[Configuration]\r\n"
di += "Language: " + $language + "\r\n"
di += "Sound theme's path: " + $soundthemespath + "\r\n"
if $voice >= 0
voice = futf8(Win32API.new("screenreaderapi","sapiGetVoiceName",'i','p').call($voice.to_i))
di += "Voice name: " + voice.to_s + "\r\n"
end
di += "Voice id: " + $voice.to_s + "\r\n"
di += "Voice rate: " + $rate.to_s + "\r\n"
di += "Typing echo: " + $interface_typingecho.to_s + "\r\n"
return di
end

# Sends a bug report
#
# @param getinfo [Boolean] ask a user to describe the bug
# @param info [String] predefined information
# @return [Numeric] return 0 if succeeds, otherwise the return value is an error code
def bug(getinfo=true,info="")
  loop_update
  if getinfo == true
    info = prompt(_("EAPI_Common:type_errordsc"),_("EAPI_Common:btn_send"))
    if info == ""
    return 1
  end
  info += "\r\n|||\r\n\r\n\r\n\r\n\r\n\r\n"
  end
  di = createdebuginfo
  info += di
  info.gsub!("\r\n","\004LINE\004")
  buf = buffer(info)
  bugtemp = srvproc("bug","name=#{$name}\&token=#{$token}\&buffer=#{buf}")
      err = bugtemp[0].to_i
  if err != 0
    speech(_("General:error"))
    r = err
  else
    speech(_("EAPI_Common:info_sent"))
    r = 0
  end
  speech_wait
  return r
end



# Opens a list of contacts allowing user to select one
#
# @return [String] returns a selected contact name, if cancelled, the return value is nil
  def selectcontact
                ct = srvproc("contacts","name=#{$name}\&token=#{$token}")
        err = ct[0].to_i
    case err
    when -1
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      $contact = []
      for i in 1..ct.size - 1
        ct[i].delete!("\n")
      end
      Graphics.update
      for i in 1..ct.size - 1
        $contact.push(ct[i]) if ct[i].size > 1
      end
      if $contact.size < 1
        speech(_("EAPI_Common:info_listempty"))
        speech_wait
      end
      selt = []
      for i in 0..$contact.size - 1
        selt[i] = $contact[i] + ". " + getstatus($contact[i])
        end
      sel = Select.new(selt,true,0,"Wybierz kontakt")
      loop do
loop_update
        sel.update if $contact.size > 0
        if escape
          loop_update
          $focus = true
                    return(nil)
        end
        if enter and $contact.size > 0
          loop_update
          $focus = true
          play("list_select")
                    return($contact[sel.index])
          end
        end
        end
      
# Opens a visitingcard of a specified user
#
# @param user [String] user whose visitingcard you want to open
  def visitingcard(user=$name)
    prtemp = srvproc("getprivileges","name=#{$name}\&token=#{$token}\&searchname=#{user}")
        vc = srvproc("visitingcard","name=#{$name}\&token=#{$token}\&searchname=#{user}")
    err = vc[0].to_i
    case err
    when -1
      speech(_("General:error_db"))
      speech_wait
      return -1
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        return -2
      end
      dialog_open
      text = ""
if prtemp[1].to_i > 0
  text += "Betatester, "
end
if prtemp[2].to_i > 0
  text += "Moderator, "
end
if prtemp[3].to_i > 0
  text += "Administrator mediów, "
end
if prtemp[4].to_i > 0
  text += "Tłumacz, "
end
if prtemp[5].to_i > 0
  text += "Programista, "
end
honor=gethonor(user)
text += "#{if honor==nil;"Użytkownik";else;honor;end}: #{user} \r\n"
text += getstatus(user,false)
text += "\r\n"
pr = srvproc("profile","name=#{$name}\&token=#{$token}\&get=1\&searchname=#{user}")
fullname = ""
gender = -1
birthdateyear = 0
birthdatemonth = 0
birthdateday = 0
location = ""
if pr[0].to_i == 0
  fullname = pr[1].delete("\r\n")
        gender = pr[2].delete("\r\n").to_i
        if pr[3].to_i>1900 and pr[4].to_i > 0 and pr[4].to_i < 13 and pr[5].to_i > 0 and pr[5].to_i < 32
        birthdateyear = pr[3].delete("\r\n")
        birthdatemonth = pr[4].delete("\r\n")
        birthdateday = pr[5].delete("\r\n")
        end
        location = pr[6].delete("\r\n")
        text += fullname+"\r\n"
        text+="#{_("EAPI_Common:txt_phr_gender")}: "
        if gender == 0
          text += "#{_("General:female")}\r\n"
        else
          text += "#{_("General:male")}\r\n"
        end
if birthdateyear.to_i>0
        age = Time.now.year-birthdateyear.to_i
if Time.now.month < birthdatemonth.to_i
  age -= 1
elsif Time.now.month == birthdatemonth.to_i
  if Time.now.day < birthdateday.to_i
    age -= 1
    end
  end
  age -= 2000 if age > 2000      
  text += "#{_("EAPI_Common:txt_phr_age")}: #{age.to_s}\r\n"
  end
  end
  ui = userinfo(user)
if ui != -1
if gender == -1 or $language!="PL_PL"
  text += "Widzian(y/a): "
elsif gender == 0
  text += "Widziana: "
elsif gender == 1
  text += "Widziany: "
  end
text+= ui[0] + "\r\n"
text += "Użytkownik "
text += "nie " if ui[1] == false
text += "posiada bloga.\r\n"
text += "#{_("EAPI_Common:txt_phr_knows")}: " + ui[2].to_s + "\r\n"
if gender == -1 or $language!="PL_PL"
text += "Znan(y/a)"
elsif gender == 0
  text += "Znana"
elsif gender == 1
  text += "Znany"
end
text += " przez użytkowników: " + ui[3].to_s + "\r\n"
text += "#{_("EAPI_Common:txt_phr_forumposts")}: " + ui[4].to_s + "\r\n"
text += "#{_("EAPI_Common:txt_phr_pollsanswered")}: " + ui[7].to_s + "\r\n"
text += "#{_("EAPI_Common:txt_phr_usedversion")}: " + ui[5].to_s + "\r\n"
text += "#{_("EAPI_Common:txt_phr_registered")}: " + ui[6].to_s.split(" ")[0] + "\r\n" if ui[6]!=""
end
if vc[1]!="     " and vc.size!=1
text += "\r\n\r\n"
      for i in 1..vc.size - 1
        text += vc[i]
      end
      end
      inptr = Edit.new(s_("Wizytówka: %{user}", {'user'=>user}),"READONLY|MULTILINE",text)
      loop do
        loop_update
        inptr.update
        break if escape
      end
      loop_update
      $focus = true if $scene.is_a?(Scene_Main) == false
      dialog_close
      return 0
    end
    

# Checks for possible updates
def versioninfo
    download($url + "/bin/elten.ini",$bindata + "\\newest.ini")
        nversion = "\0" * 16
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Elten","Version","0",nversion,nversion.size,utf8($bindata + "\\newest.ini"))
    nversion.delete!("\0")
    nversion = nversion.to_f
            nbeta = "\0" * 16
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Elten","Beta","0",nbeta,nbeta.size,utf8($bindata + "\\newest.ini"))
    nbeta.delete!("\0")
    nbeta = nbeta.to_i
    nalpha = "\0" * 16
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Elten","Alpha","0",nalpha,nalpha.size,utf8($bindata + "\\newest.ini"))
    nalpha.delete!("\0")
    nalpha = nalpha.to_i    
    $nbeta = nbeta
    $nversion = nversion
    $nalpha = nalpha
    if $nversion > $version or $nbeta > $beta or $nalpha > $alpha or ($nalpha == 0 and $alpha != 0)
      $scene = Scene_Update_Confirmation.new
    else
      speech(_("EAPI_Common:info_noupdates"))
      speech_wait
    end
  end
  

          

          
# Shows user agreement
#
# @param omit [Boolean] determines whether to allow user to close the window without accepting
    def license(omit=false)
if $language == "PL_PL"
    @license = "Elten

Regulamin użytkowania oraz umowa licencyjna

Poniższe warunki są umową licencyjną oprogramowania Elten oraz sieci Elten Network.
Użytkownicy programu zobowiązują się do przestrzegania poniższych postanowień lub zaprzestania użytkowania programu.

I. Postanowienia ogólne
1. Autorem programu jest Dawid Pieper. Jest właścicielem zarówno oprogramowania, jak i danych i to on udziela licencji na użytkowanie aplikacji, jak długo Elten jest przez niego wspierany.
2. Elten jest oprogramowaniem o otwartym kodzie źródłowym (Open-Source) podlegającym pod licencjonowanie Open Public License. Zabrania się tworzenia niezależnych od Eltena dystrybucji i kopii, jak długo Elten jest wspierany przez autora. Zabrania się również jakiegokolwiek celowego szkodliwego działania na rzecz serwera, zarówno w sposób pośredni, jak i bezpośredni.
3. Wszelkie testy bezpieczeństwa, głównie testy penetracyjne, są dozwolone za poinformowaniem autora o ich przeprowadzaniu oraz o ich wynikach. Zabrania się wykorzystywania jakichkolwiek odnalezionych błędów w zabezpieczeniach.
4. Elten może być rozwijany przez każdego programistę, jednak żadna z dopisanych funkcji nie może szkodzić użytkownikom lub ich prywatności. Nowe zmiany ostatecznie zatwierdza lub odrzuca autor programu.
5. Użytkownicy publikujący swoje prace w serwisie pozostają autorami tych prac, nie zrzekają się praw własności ani praw autorskich na żadnego z innych użytkowników ani autora. Dają jednak autorowi prawo do dystrybuowania tych prac w celu możliwości umieszczania ich na łamach portalu Elten.
6. API oraz inne rozwiązania programistyczne wykorzystane w oprogramowaniu Elten mogą być używane w zewnętrznych, niezależnych projektach pod następującymi warunkami:
A. Oprogramowanie to jest darmowe,
B. Oznaczono wykorzystane fragmenty kodu źródłowego, wraz ze wskazaniem ich pochodzenia.

II. Rejestracje
1. Użytkownikiem Eltena może zostać każda osoba, która ukończyła trzynasty rok życia.
2. Autor lub moderacja mogą nie udzielić zgody na rejestrację w szczególnych wypadkach, gdy rada starszych programu uzna, że osoba chcąca się zarejestrować nie ma prawa do dokonania tej czynności.
3. W przypadku łamania postanowień niniejszego regulaminu, użytkownik może zostać pozbawiony (okresowo lub trwale) dostępu do swojego konta. Decyzję o tym podejmują moderatorzy lub autor.
4. Podanie prawdziwego adresu e-mail jest obowiązkowe. W szczególnych wypadkach może on zostać użyty w celu weryfikacji tożsamości użytkownika.

III. Blogi i prywatne wiadomości
1. Zarówno treści umieszczane na blogach, jak i w prywatnych wiadomościach nie podlegają moderacji, a odpowiedzialnym za nie pozostaje użytkownik je publikujący.
2. Autor ani administracja programu nie ponoszą odpowiedzialności za treści umieszczane na blogach i w prywatnych wiadomościach.
3. Użytkownik może zostać ukarany poprzez uniemożliwienie mu (okresowo lub trwale) dostępu do konta lub usunięcie publikowanych na blogu treści w szczególnych wypadkach, gdy:
A. Naruszają one prawa autorskie, prawa własności lub prawa do dystrybucji należące do osób prywatnych lub organizacji (za wniesieniem wniosku o usunięcie takich treści do administracji programu przez uprawniony podmiot),
B. Mają one charakter obraźliwy względem innych użytkowników (za wniesieniem wniosku o usunięcie tych materiałów przez zainteresowaną stronę).

IV. Forum
1. Na forum należy przestrzegać zasad netykiety. Zabrania się wyzywania czy  obrażania innych użytkowników, jak również nadużywania określeń uważanych powszechnie za wulgarne.
2. Forum jest miejscem wymiany opinii, każdy użytkownik ma prawo do własnego zdania w poruszanych kwestiach.
3. Za utrzymanie porządku na forum odpowiadają moderatorzy, mając prawo do:
A. Ostrzegania użytkownika,
B. Usuwania wątków lub wpisów stojących w niezgodzie z niniejszym regulaminem,
C. Przenoszenia wpisów,
D. W szczególnych wypadkach, gdy uznana zostanie taka konieczność, edycji wpisów,
E. Pozbawiania użytkownika dostępu do jego konta.
4. Moderatorzy mają prawo do edycji wpisów w ypadku:
A. Ujawnienia prywatnych lub wrażliwych danych innych osób bez zgody tych osób, na wniosek osoby poszkodowanej,
B. W wypadku wątków o specyficznym sposobie lub zakresie wypowiedzi, w celu dostosowania wpisu do szablonu lub charakteru wątku.
5. Użytkownik, umieszczając daną treść na forum, oświadcza, że ma prawo do jej publikacji.
6. Na forum należy przestrzegać zasad ułatwiających łatwe przeglądanie wpisów, unikać mieszania tematów, zakładania ich na niewłaściwych forach, nadmiernego odbiegania od tematu wątku.

V. Rada starszych
1. Użytkownik otrzymuje lub zostaje pozbawiony specjalnych praw przez autora programu.
2. Należenie do rady starszych nie zwalnia z obowiązku przestrzegania niniejszego regulaminu.
3. Użytkownik może otrzymać następujące tytuły w radzie starszych:
A. Betatester,
B. Moderator,
C. Tłumacz,
D. Administrator mediów,
E. Programista.
4. W przypadku braku aktywności w programie lub w pełnionej funkcji, użytkownik zostaje pozbawiony członkowstwa w radzie.
5. Niezależnie od rady starszych, użytkownicy mogą otrzymać tytuły specjalne, honorowe, za różnego rodzaju działalność. Tytuły te są nadawane w celu odznaczenia danego osiągnięcia użytkownika. O nadanie takiego tytułu dla siebie lub innych użytkowników może wnioskować każdy użytkownik.
6. Lista tytułów specjalnych jest ustalana przez autora.
7. Zabrania się nadużywania lub przekraczania swoich uprawnień w radzie starszych.

VI. Udostępniane pliki (w tym awatary)
1. Za udostępniane przez siebie pliki odpowiedzialny jest każdy udostępniający je użytkownik.
2. Zabrania się udostępniania materiałów szkodliwych lub potencjalnie niechcianego oprogramowania, jeśli nie jest charakter pliku podkreślony w nazwie, a plik nie jest wysyłany w celach analizy lub szkolenia.
3. Zabrania się celowego wysyłania dużej ilości plików w celach wyczerpania miejsca na serwerze.

VII. Pozostałe
1. W wypadku nie uwzględnienia danej sytuacji w tym regulaminie, decyzję o poprawności lub niepoprawności czynu podejmuje autor.
2. Użytkownik korzystający z programu oświadcza, że zna i rozumie niniejszy regulamin.
3. Dowolny użytkownik może zgłosić niejasność lub wątpliwość co do poprawności dowolnego punktu w niniejszym regulaminie.
4. Autor ma prawo w każdej chwili zmienić lub anulować regulamin."
elsif $language=="DE_DE"
  @license="Elten Nutzungs- und Lizenzbedingungen
Die folgenden Bedingungen sind die Lizenzvereinbarung für die Elten Software und das Elten Netzwerk.
Die Benutzer des Programms verpflichten sich, die folgenden Bestimmungen einzuhalten oder die Nutzung des Programms einzustellen:

I. Allgemeine Bestimmungen
1. Der Autor des Programms ist Dawid Pieper.
Er ist sowohl Eigentümer der Software als auch der Daten und er erteilt eine Lizenz zur Nutzung der Anwendung, solange Elten von ihm unterstützt wird.
2. Elten ist eine Open-Source-Software, die der Open Public License unterliegt. 
Es ist verboten, unabhängig von der ursprünglichen Software Redistributionen zu erstellen, solange Elten vom Autor unterstützt wird. 
Es ist Ihnen ebenfalls nicht gestattet, absichtlich im Auftrag des Servers, entweder indirekt oder direkt, böswillig zu handeln. 
3. Alle Sicherheitstests, hauptsächlich Penetrationstests, sind erlaubt, nachdem der Autor über deren Implementierung und Ergebnisse informiert wurde. 
Es ist Ihnen untersagt, entdeckte Sicherheitslücken auszunutzen. 
4. Elten kann von jedem Programmierer entwickelt werden, jedoch darf keine der implementierten Funktionen den Benutzern oder deren Privatsphäre schaden. 
Neue Änderungen werden schließlich vom Autor des Programms genehmigt oder abgelehnt. 
5. Nutzer, die ihre Arbeiten an Elten veröffentlichen, bleiben die Autoren dieser Werke, sie geben ihre Eigentumsrechte oder Urheberrechte nicht an die anderen Nutzer oder den Autor weiter. 
Sie geben dem Autor jedoch das Recht, diese Werke zu verteilen, um auf den Seiten des Elten-Portals platziert zu werden. 
6. Die API und andere Programmierlösungen, die in der Elten-Client-Software verwendet werden, können in externen, unabhängigen Projekten unter den folgenden Bedingungen verwendet werden:
A. Die Software ist kostenlos,
B. Die verwendeten Quellcodefragmente wurden mit einem Hinweis auf ihre Herkunft gekennzeichnet. 

II. Anmeldungen
1. Elten-Nutzer werden kann jeder ab 13 Jahren. 
2. Der Autor oder die Moderation kann der Registrierung in besonderen Fällen nicht zustimmen, wenn der Ältestenrat des Programms erkennt, dass die Person, die sich anmelden möchte, nicht das Recht dazu hat. 
3. Bei einem Verstoß gegen die Bestimmungen dieses Reglements kann dem Benutzer der Zugriff auf sein Konto (periodisch oder dauerhaft) verweigert werden. 
Die Entscheidung wird von Moderatoren oder dem Autor getroffen. 
4. Die Angabe einer echten E-Mail-Adresse ist obligatorisch. 
In besonderen Fällen kann sie verwendet werden, um die Identität des Benutzers zu überprüfen. 

III. Blogs und private Nachrichten
1. Sowohl Inhalte in Blogs als auch private Nachrichten unterliegen nicht der Moderation. 
2. Der Autor oder die Administration des Programms sind nicht verantwortlich für den Inhalt, der in Blogs und privaten Nachrichten gepostet wird. 
3. Der Benutzer kann in Folgenden Fällen bestraft werden, indem man ihn (in regelmäßigen Abständen oder dauerhaft) daran hindert, auf den Account zuzugreifen oder Inhalte zu entfernen, die im Blog veröffentlicht sind:
A. Sie verstoßen gegen Urheberrechte, Eigentumsrechte oder Verbreitungsrechte, die Einzelpersonen oder Organisationen zustehen (für das Einreichen eines Antrags, diese Inhalte von einer autorisierten Stelle der Programmverwaltung zu entfernen).
B. Sie sind gegenüber anderen Benutzern beleidigend (auf Anfrage für die Entfernung dieser Materialien durch die interessierte Partei). 

IV. Forum
1. Die Regeln der Netiquette sollten im Forum beachtet werden. 
Es ist verboten, andere Benutzer zu beleidigen und die allgemein als vulgär geltenden Begriffe zu missbrauchen. 
2. Das Forum ist ein Ort für den Meinungsaustausch, jeder Benutzer hat das Recht auf eine eigene Meinung zu den aufgeworfenen Fragen. 
3. Moderatoren sind verantwortlich für die Aufrechterhaltung der Ordnung im Forum und haben das Recht darauf:
A. den Benutzer zu warnen,
B. Themen oder Posts im Widerspruch zu diesen Vorschriften zu löschen, 
C. Themen oder Posts zu verschieben, 
D. in besonderen Fällen, wenn  notwendig, Posts zu bearbeiten,
E. dem Benutzer den Zugriff auf sein Konto zu entziehen. 
4. Moderatoren haben das Recht, Posts in folgenden Fällen zu bearbeiten:
A. Offenlegung von privaten oder sensiblen Daten anderer Personen ohne Zustimmung dieser Personen, auf Wunsch der verletzten Person,
B. Im Falle von Themen mit:Art und Umfang des Ausdrucks, um den Post an die Vorlage oder die Art des Themas anzupassen. 
5. Der Nutzer erklärt durch die Veröffentlichung eines bestimmten Inhalts im Forum, dass er das Recht hat, ihn zu veröffentlichen. 
6. Die Benutzer sollten die Regeln befolgen, um das einfache Durchsuchen von Posts zu erleichtern, das Mischen von Themen zu vermeiden, sie in ungeeigneten Foren einzurichten, übermäßige Abweichungen vom Thema. 

V. Verwaltung
1. Der Benutzer erhält oder entzieht dem Urheber des Programms besondere Rechte. 
2. Die Mitgliedschaft im Ältestenrat befreit nicht von der Einhaltung dieser Vorschriften. 
3. Der Benutzer kann die folgenden Titel im Ältestenrat erhalten:
A. Betatester,
B. Moderator,
C. Übersetzer,
D. Medienadministrator,
E. Entwickler. 
4. Im Falle von Inaktivität in dem Programm oder in der ausgeführten Funktion werden dem Benutzer Administrationsrechte entzogen. 
5. Unabhängig von der Mitgliedschaft in der Verwaltung können Benutzer spezielle und Ehrentitel für verschiedene Arten von Aktivitäten erhalten. 
Diese Abzeichen werden in ord verliehen

um die Leistung eines bestimmten Benutzers abzuwählen. 
Einzelne Benutzer können einen solchen Titel für sich selbst oder andere Benutzer beantragen. 
6. Die Liste der Spezialtitel wird vom Autor festgelegt. 
7. Es ist verboten, ihre Rechte durch die Verwaltung zu missbrauchen oder zu übertreffen. 

VI. Freigegebene Dateien (einschließlich Avatare)
1. Jeder Benutzer, der Dateien freigibt, ist für sie verantwortlich. 
2. Es ist verboten, schädliche Materialien oder potenziell unerwünschte Software zu teilen, wenn nicht das Zeichen der Datei im Namen unterstrichen ist und die Datei nicht zur Analyse oder zum Training gesendet wird. 
3. Es ist verboten, eine große Anzahl von Dateien absichtlich zu versenden, um Speicherplatz auf dem Server zu verbrauchen. 
VII. Sonstiges
1. Wenn die Situation in dieser Verordnung nicht berücksichtigt wird, wird die Entscheidung über die Richtigkeit oder Unrichtigkeit der Handlung vom Autor oder der Verwaltung getroffen. 
2. Der Benutzer des Programms erklärt, dass er diese Bestimmungen kennt und versteht. 
3. Jeder Benutzer kann Unklarheit oder Zweifel hinsichtlich der Richtigkeit irgendeines Punktes in diesen Vorschriften melden. 
4. Der Autor hat das Recht, das Reglement jederzeit zu ändern oder zu löschen."
else
  @license = "Elten Terms of Use and License Agreement The following terms are the license agreement for the Elten software and the Elten Network. 

The users of the program undertake to comply with the following provisions or to cease using the program. 

I. General provisions
1. The author of the program is Dawid Pieper. He is the owner of both software and data and he grants a license to use the application, as long as Elten is supported by him.
2. Elten is open source software subject to Open Public License. It is forbidden to create redistributions independent of original software as long as Elten is supported by the author. It is also prohibited to deliberately act maliciously on behalf of the server, either indirectly or directly.
3. All security tests, mainly penetration tests, are allowed after informing the author about their implementation and results. It is forbidden to use any discovered security vulnerabilities.
4. Elten can be developed by any programmer, however none of the implemented features are permitted to harm users or their privacy. New changes are finally approved or rejected by the author of the program.
5. Users publishing their work on Elten remain the authors of these works, they do not give up their ownership rights or copyrights to any of the other users or the author. However, they provide the author the right to distribute these works in order to be placed on the pages of the Elten portal.
6. The API and other programming solutions used in the Elten client software can be used in external, independent projects under the following conditions:
A. The software is free,
B. The source code fragments used have been marked, along with an indication of their origin.

II. Registrations
1. Anyone who has reached the age of thirteen may become a Elten user.
2. Author or moderation may not consent to registration in special cases, when the council of elders of the program will recognize that the person wishing to register does not have the right to do this.
3. In the event of violation of the provisions of these regulations, the user may be deprived (periodically or permanently) of access to his account. The decision is made by moderators or the author.
4. Providing a real e-mail address is mandatory. In special cases, it can be used to verify the user's identity.

III. Blogs and private messages
1. Both content posted on blogs and private messages are not subject to moderation.
2. The author or the administration of the program are not responsible for the content posted on blogs and private messages.
3. The User may be punished by preventing him (periodically or permanently) from accessing the account or removing content published on the blog in special cases of:
A. They infringe copyright, property rights or distribution rights belonging to individuals or organizations (for submitting a request to remove such content to the program administration by an authorized entity),
B. They are offensive to other users (upon request for removal of these materials by the interested party).

IV. Forum
1. The rules of netiquette should be observed on the forum. It is forbidden to insult other users, as well as abuse the terms commonly regarded as vulgar.
2. The forum is a place for exchanging opinions, each user has the right to his own opinion on the issues raised.
3. Moderators are responsible for maintaining order in the forum, having the right to:
A. Warn the user,
B. Delete threads or entries standing in contravention of these regulations,
C. Move threads or posts,
D. In special cases, when necessary, edit entries,
E. Deprive the user of access to his account.
4. Moderators have the right to edit the entry in the case of:
A. Disclosure of private or sensitive data of other people without the consent of these people, at the request of the injured person,
B. In the case of threads with a specific manner or scope of expression, to adapt the entry to the template or the nature of the thread.
5. The User, by posting a given content on the forum, declares that he has the right to publish it.
6. The users should follow the rules to facilitate easy browsing of entries, avoid mixing topics, setting them up in inappropriate forums, excessive deviation from the thread topic.

V. Administration
1. The user receives or is deprived of special rights by the author of the program.
2. Membership in the elder council does not exempt from compliance with these regulations.
3. The user may receive the following titles in the elder council:
A. Betatester,
B. Moderator,
C. Translator,
D. Media Catalogue Administrator,
E. Programmer.
4. In the event of inactivity in the program or in the function performed, the user is deprived of administration privileges.
5. Regardless of the membership in the administration, users can receive special and honorary titles for various types of activities. These badges are awarded in order to deselect a given user's achievement. Individual users can apply for such a title for themselves or other users. 
6. The list of special titles is determined by the author.
7. It is forbidden to abuse or exceed their rights by the administration.

VI. Shared Files (including avatars)
1. Any user sharing files is responsible for them.
2. It is forbidden to share harmful materials or potentially unwanted software, if it is not the character of the file underlined in the name, and the file is not sent for analysis or training.
3. It is forbidden to send a large amount of files deliberately in order to use up space on the server.

VII. Other
1. If the situation is not taken into account in this regulation, the decision on the correctness or incorrectness of the act is taken by the author or administration.
2. The user of the program declares that he knows and understands these regulations.
3. Any user may report ambiguity or doubt as to the correctness of any point in these regulations.
4. The author has the right to change or cancel the regulations at any time."
end
form = Form.new([Edit.new(_("EAPI_Common:read_useragreement"),"MULTILINE|READONLY",@license,true),Button.new(_("EAPI_Common:btn_agree")),Button.new(_("EAPI_Common:btn_disagree"))])
loop do
  loop_update
  form.update
  if (enter or space) and form.index == 2
    exit
  end
  if (space or enter) and form.index == 1
    break
  end
  if escape
    if omit == true
      break
      else
    q = simplequestion(_("EAPI_Common:alert_useragreement"))
    if q == 0
      exit
    else
      break
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
def player(file,label="",wait=false,control=true,trydownload=false,stream=false)
  if File.extname(file).downcase==".mid" and FileTest.exists?($extrasdata+"\\soundfont.sf2") == false
    if confirm(_("EAPI_Common:alert_mididownloadsf"))==1
    downloadfile($url+"extras/soundfont.sf2",$extrasdata+"\\soundfont.sf2","Proszę czekać, trwa pobieranie bazy brzmień midi... To może potrwać kilka minut...","Baza brzmień została pobrana.")
    speech_wait
    Win32API.new("bass","BASS_SetConfigPtr",'ip','l').call(0x10403,utf8($extrasdata+"\\soundfont.sf2"))
  else
    return
    end
      end
  plpause=false
  plpos=0
  if $playlist!=nil and $playlistbuffer!=nil and $playlistbuffer.playing?
    plpause=true
    $playlistbuffer.pause
    end
  if label != ""
  dialog_open if wait==false
speech(label)
$dialogvoice.close if $dialogvoice != nil
$dialogvoice = nil
end
begin
if file[0..3]=="http" or stream
sound = Bass::Sound.new(file,1)
else
  sound = Bass::Sound.new(file)
end
sound.play
rescue Exception
  speech(_("EAPI_Common:error_playing"))
  speech_wait
  return
end   
delay(0.1)
    pause=false    
    basefrequency=sound.frequency
    reset=0
    ppos=0
    loop do
                    loop_update
      if space and control
        if pause!=true
        ppos=sound.position
          sound.pause
        pause=true
              else
                        sound.play
                        if sound.position<ppos
                        for i in 1..20
                        sound.position=ppos
                      end
                      end
        pos=0
        pause=false
                end
        end
      if (escape or enter) and $key[0x10]==false
                for i in 1..50
          sound.volume -= 0.02
          loop_update
        end
sound.close
dialog_close if label != ""          
  $playlistbuffer.play if plpause==true
return
break
end
if control      
  if $key[80]
    d=sound.position.to_i
h=d/3600
        m=(d-d/3600*3600)/60
  s=d-d/60*60
  speech(sprintf("%02d:%02d:%02d",h,m,s))
        end
  if $key[68]
    d=sound.length.to_i
    h=d/3600
        m=(d-d/3600*3600)/60
  s=d-d/60*60
  speech(sprintf("%02d:%02d:%02d",h,m,s))
    end
    if $key[74]
      ppos=sound.position.to_i
      sound.pause
      dpos=input_text(_("EAPI_Common:type_movetosec"),"ACCEPTESCAPE",ppos.to_s)
      dpos=ppos if dpos=="\004ESCAPE\004"
      dpos=dpos.to_i
      dpos=sound.length if dpos>sound.length
      sound.position=dpos
      sound.play
      for i in 1..20
        sound.position=dpos
        end
      end
    if ($key[0x53] or ($key[0x10] and enter)) and file.include?("http")
    tf=file.gsub("\\","/")
    fs=tf.split("/")
    nm=fs.last.split("?")[0]
    if File.extname(nm)==""
      l=label.downcase
      if l.include?("mp3")
        nm+=".mp3"
      elsif l.include?(".wav")
        nm+=".wav"
      elsif l.include?(".ogg")
        nm+=".ogg"
      else
        nm+=".opus"
        end
      end
    loc=getfile(_("EAPI_Common:head_savelocation"),getdirectory(40)+"\\",true,"Music")
    if loc!=nil
            speech(_("EAPI_Common:wait_downloading"))
                        waiting
                        executeprocess("bin\\ffmpeg -y -i \"#{file}\" \"#{loc}\\#{nm}\"",true)
                        waiting_end
                                    speech(_("General:info_saved"))
      end
    end
    if $key[0x10]              ==false
    if Input.repeat?(Input::RIGHT)
                                sound.position += 5
              end
      if Input.repeat?(Input::LEFT)
        sound.position -= 5
      end
            if Input.repeat?(Input::UP)
                      sound.volume += 0.05
sound.volume = 0.5 if sound.volume == 0.6
      end
      if Input.repeat?(Input::DOWN)
        sound.volume -= 0.05
sound.volume = 0.01 if sound.volume == 0
end
else
  if Input.repeat?(Input::RIGHT)
        sound.pan += 0.1
        sound.pan = 1 if sound.pan > 1
      end
      if Input.repeat?(Input::LEFT)
        sound.pan -= 0.1
        sound.pan = -1 if sound.pan < -1
      end
            if Input.repeat?(Input::UP)
        sound.frequency += basefrequency.to_f/100.0*2.0
      sound.frequency=basefrequency*2 if sound.frequency>basefrequency*2
        end
      if Input.repeat?(Input::DOWN)
        sound.frequency -= basefrequency.to_f/100.0*2.0
      sound.frequency=basefrequency/2 if sound.frequency<basefrequency/2
end
end
if $key[0x08] == true
  reset=10
  sound.volume=1
  sound.pan=0
  sound.frequency=basefrequency
  end
end
reset -= 1 if reset > 0
  if wait == true
  if pause != true
    if sound.position(true)>=sound.length(true)-1024 and sound.length(true)>0
                  sound.close
            $playlistbuffer.play if plpause==true
      return
     break
            end
    end
  end
  pos=sound.position
end
$playlistbuffer.play if plpause==true
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
def getkeychar(keys=[],multi=false)
  ret=""
  lng=Win32API.new("user32","GetKeyboardLayout",'i','l').call(0).to_s(2)[16..31].to_i(2)
  for i in 32..255
  if $key[i]
    c="\0"*8
  Win32API.new("user32","ToUnicode",'iippii','i').call(i,0,$keys.pack("c"*256),c,c.bytesize,0)
                          re=c.delete("\0")
re.delete!(" ") if i!=32
buf="\0"*Win32API.new("kernel32","WideCharToMultiByte",'iipipipp','i').call(65001,0,re,re.size,nil,0,nil,nil)
useddef="\0"
Win32API.new("kernel32","WideCharToMultiByte",'iipipipp','i').call(65001,0,re,re.size,buf,buf.size,nil,useddef)
re=buf.delete("\0")
ret=re.split("").last if re!="" and $key[i] and re[0]>=32
end
end
if false
  ret=""    
  keys=$key if keys==[]
  return "" if (keys[0x11]==true and keys[0x12]==false) or (keys[0x11]==false and keys[0x12]==true)    
  caps=(Win32API.new("user32","GetKeyState",'i','i').call(0x14) & 0x0001)!=0
  bigl=false
  bigl=!bigl if caps
  bigl=!bigl if $key[0x10]
  for i in 65..90
        if keys[i]==true
          r=" "
          if $ruby != true
          r[0]=i
        else
          r.setbyte(0,i)
          end
          r=r.downcase if bigl==false
          if keys[0x11]==true and keys[0x12]==true
            pr=r
                    case r
          when "A"
            r="Ą"
            when "C"
              r="Ć"
            when "E"
              r="Ę"
              when "L"
                r="Ł"
                when "N"
                  r="Ń"
                  when "O"
                    r="Ó"
                    when "S"
                      r="Ś"
                      when "X"
                        r="Ź"
                        when "Z"
                          r="Ż"
                          when "a"
                            r="ą"
                            when "c"
                              r="ć"
                              when "e"
                                r="ę"
                                when "l"
                                  r="ł"
                                  when "n"
                                    r="ń"
                                    when "o"
                                      r="ó"
                                      when "s"
                                        r="ś"
                                        when "x"
                                          r="ź"
                                          when "z"
                                            r="ż"
          end
          ret=nil if pr==r
          end
          ret=r if ret!=nil
          ret="" if ret==nil
          end
      end
      for i in [0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69]
        if keys[i] == true
          if $key[0x10] == false
          r=" "
          r[0]=i
          ret=r
        else
          o=0
          if i<58
            o=i-0x30
          else
            o=i-0x60
            end
          case o
          when 1
            ret="!"
            when 2
              ret="@"
              when 3
                ret="#"
                when 4
                  ret="$"
                  when 5
                    ret="%"
                    when 6
                      ret="^"
                      when 7
                        ret="&"
                        when 8
                          ret="*"
                          when 9
                            ret="("
                            when 0
                              ret=")"
          end
            end
          end
      end
      for i in 0..255
if keys[i]==true
case i
when 0x20
  ret=" "
when 0xBA
if $key[0x10]==false
ret=";"
else
ret=":"
end
when 0xBB
if $key[0x10]==false
ret="="
else
ret="+"
end
when 0xBC
if $key[0x10]==false
ret=","
else
ret="<"
end
when 0xBD
if $key[0x10]==false
ret="-"
else
ret="_"
end
when 0xBE
if $key[0x10]==false
ret="."
else
ret=">"
end
when 0xBF
if $key[0x10]==false
ret="/"
else
ret="?"
end
when 0xC0
if $key[0x10]==false
ret="`"
else
ret="~"
end
when 0xDB
if $key[0x10]==false
ret="["
else
ret="{"
end
when 0xDC
if $key[0x10]==false
ret="\\"
else
ret="|"
end
when 0xDD
if $key[0x10]==false
ret="]"
else
ret="}"
end
when 0xDE
if $key[0x10]==false
ret="'"
else
ret="\""
end
when 0xE2
  if $key[0x10]==false
ret="\\"
else
ret="|"
end
end
end
end
if ret!=""
  if lngkeys!=nil
    ret=lngkeys[ret] if lngkeys[ret]!=nil
    end
  end
  end
if multi == true
  if $lastkeychar!=nil and ret!=""
    if $lastkeychar[1]>Time.now.to_i*1000000+Time.now.usec.to_i-200000 and ret!=$lastkeychar[0]
      ret=$lastkeychar[0]+ret
      end
    end
    end
  $lastkeychar=[ret,Time.now.to_i*1000000+Time.now.usec.to_i] if ret!=""
          return ret
        end
        
        # @note this function is reserved for Elten usage
    def lngkeys(param=0)
      lng = Win32API.new("user32","GetKeyboardLayout",'i','l').call(0).to_s(2)[16..31].to_i(2)
      case lng
      when 1031
        return {"@"=>"\"","#"=>"§","^"=>"\&","\&"=>"/","*"=>"(","("=>")",")"=>"=","<"=>";",">"=>":","`"=>"ö","~"=>"Ö","'"=>"ä","\""=>"Ä","/"=>"#","?"=>"'",";"=>"ü",":"=>"Ü","="=>"+","+"=>"*","["=>"ß","{"=>"?","]"=>"´","}"=>"`","\\"=>"^","|"=>"°"} if param==0
return {"Ö"=>1,"Ä"=>1,"Ü"=>1} if param==1
when 2057
  return {"@"=>"\"","\""=>"@"}
end
return lng if param==2
      return {}
    end
    
      # @note this function is reserved for Elten usage
      def thr1
                        begin
                loop do
                  if $ruby != true or $windowminimized != true
                  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x11) > 0 and $speech_wait == true
                    speech_stop
                    $speech_wait = false
                    end
                  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x77) > 0
                    time = ""
                    if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
if $advanced_synctime == 1
                      time = srvproc("time","dateformat=Y-m-d")
                    else
                                            time = [sprintf("%04d-%02d-%02d",Time.now.year,Time.now.month,Time.now.day)]
                                                                                     end
else
  if $advanced_synctime == 1
  time = srvproc("time","dateformat=H:i:s")
  else
                      time = [sprintf("%02d:%02d:%02d",Time.now.hour,Time.now.min,Time.now.sec)]
                      end
  end
speech(time[0])
end
         if Win32API.new($eltenlib,"KeyState",'i','i').call(0x76) > 0
           if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
    $playlistindex += 1 if $playlistbuffer!=nil
  elsif $scene.is_a?(Scene_Console)==false
    $scenes.insert(0,Scene_Console.new)
    end
    sleep(0.1)    
    end
        if Win32API.new($eltenlib,"KeyState",'i','i').call(0x75) > 0
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) <= 0  and $volume < 100
  $volume += 5 if $volume < 100
  writeini($configdata + "\\interface.ini","Interface","MainVolume",$volume.to_s)
  play("list_focus")
elsif Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
  $playlistvolume = 0.8 if $playlistvolume == nil
  if $playlistvolume < 1
  $playlistvolume += 0.1
  play("list_focus",$playlistvolume*-100) if $playlistbuffer==nil or $playlistpaused==true
  end
  end
  sleep(0.1)
  end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x74) > 0
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) <= 0  and $volume > 5
  $volume -= 5 if $volume > 5
  play("list_focus")
  writeini($configdata + "\\interface.ini","Interface","MainVolume",$volume.to_s)
elsif Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
    $playlistvolume = 0.8 if $playlistvolume == nil
  if $playlistvolume > 0.01
    $playlistvolume -= 0.1
  $playlistvolume=0.01 if $playlistvolume==0
    play("list_focus",$playlistvolume*-100) if $playlistbuffer==nil or $playlistpaused==true
  end
  end
  sleep(0.1)
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x73) > 0
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0 and $playlistbuffer != nil
    if $playlistindex != 0
    $playlistindex -= 1
  else
    $playlistindex=$playlist.size-1
    end
    end
    sleep(0.1)
  end
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x70) > 0
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
        if $voice==-1
      $voice=readini($configdata+"\\sapi.ini","Sapi","Voice","-1").to_i
          elsif Win32API.new("screenreaderapi","getCurrentScreenReader",'','i').call>0
      $voice=-1
      end
  if $voice==-1
        speech(_("EAPI_Common:info_usingscreenreader"))
    else
    speech(_("EAPI_Common:info_usingsapi"))
  end
else
  $scenes.insert(0,Scene_ShortKeys.new) if $scene.is_a?(Scene_ShortKeys)==false
      end
  sleep(0.1)  
  end
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x71) > 0
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
    if $scene.is_a?(Scene_Main)
      $scene=Scene_MainMenu.new
      else
    $scenes.insert(0,Scene_MainMenu.new) if $scene.is_a?(Scene_MainMenu)==false
    end
  end
  sleep(0.1)
  end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x72) > 0
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
    if $playlist.size>0 and $playlistbuffer!=nil
if $playlistpaused == true
  $playlistbuffer.play
  $playlistpaused = false
else
  $playlistpaused=true
  $playlistbuffer.pause  
end
end
else
  Audio.bgs_stop
  run("bin\\elten_tray.bin")
  Win32API.new("user32","SetFocus",'i','i').call($wnd)
  Win32API.new("user32","ShowWindow",'ii','i').call($wnd,0)
  Graphics.update  
  Graphics.update
  play("login")
    speech("ELTEN")
    Win32API.new("user32","ShowWindow",'ii','i').call($wnd,1)
end
sleep(0.1)    
end
if $name != "" and $name != nil and $token != nil and $token != ""
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x78) > 0
    if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) <= 0 and $scene.is_a?(Scene_Contacts) == false
    $scenes.insert(0,Scene_Contacts.new)
      elsif $scene.is_a?(Scene_Online) == false and Win32API.new("user32","GetAsyncKeyState",'i','i').call(0x10) > 0
        $scenes.insert(0,Scene_Online.new)
  end
  sleep(0.1)
  end
        if Win32API.new($eltenlib,"KeyState",'i','i').call(0x79) > 0
           if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) == 0 and $scene.is_a?(Scene_WhatsNew) == false
$scenes.insert(0,Scene_WhatsNew.new)
elsif $scene.is_a?(Scene_Messages) == false and Win32API.new($eltenlib,"KeyState",'i','i').call(0x10)!=0
  $scenes.insert(0,Scene_Messages.new)
    end
    sleep(0.1)
  end
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x7a) > 0
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10)==0
    speech(futf8($speech_lasttext))
  elsif $scene.is_a?(Scene_Chat)==false
    $scenes.insert(0,Scene_Chat.new)
    end
    sleep(0.1)
  end
  end
  sleep(0.05)
  end
rescue Exception
    retry
                end
              end
              
# @note this function is reserved for Elten usage
                  def thr2
                                        loop do
            begin
            sleep(0.1)
              if $voice != -1 and ($ruby != true or $windowminimized != true)
                if Win32API.new("screenreaderapi","getCurrentScreenReader",'','i').call>0
Win32API.new("screenreaderapi","stopSpeech",'','i').call
end
                      end
              rescue Exception
        fail
      end
      end
    end
    
    # @note this function is reserved for Elten usage
def thr3
  $playlistvolume=0.8
  $playlistindex = 0 if $playlistindex == nil
  $playlistlastindex = -1 if $playlistlastindex == nil
plpos=0
  loop do
    sleep(0.1)
    if $playlist.size > 0
    plpos=$playlistbuffer.position if $playlistbuffer!=nil and $playlistpaused != true
    if $playlistlastindex != $playlistindex or $playlistbuffer == nil
      $playlistbuffer.close if $playlistbuffer != nil
      $playlistindex=0 if $playlistindex>=$playlist.size        
      if $playlist[$playlistindex] != nil      
                $playlistbuffer = Bass::Sound.new($playlist[$playlistindex])
        else
              $playlistindex += 1
              $playlistindex = 0 if $playlistindex >= $playlist.size
              end
                                      $playlistlastindex=$playlistindex
            if $playlistbuffer != nil
              $playlistbuffer.volume=$playlistvolume
              $playlistbuffer.play
              end
    end
    sleep(0.05)
    if $playlistbuffer != nil
      if $playlistbuffer.position(true)>=$playlistbuffer.length(true)-128 and $playlistpaused != true
        $playlistindex += 1
      elsif $playlistpaused == true
        plpos=-1
      end
      $playlistbuffer.volume=$playlistvolume if $playlistbuffer.volume!=$playlistvolume and $playlistvolume.is_a?(Float) or $playlistvolume.is_a?(Integer)
    end
  else
    sleep(0.5)
    if $playlistbuffer != nil
    $playlistbuffer.close
    $playlistbuffer=nil
  end
  end
    end
end

# @note this function is reserved for Elten usage
  def thr4
    begin    
    $subthreads=[] if $subthreads==nil
                            loop do
                              sleep(0.04)
                                    if $scenes.size > 0
                                      if $currentthread != nil  
                                                                                  $subthreads.push($currentthread)
                                        end
                                      $currentthread = Thread.new do
                                        stopct=false
                                        sc=$scene
                                        begin
                                          if stopct == false
                                                                                    newsc = $scenes[0]
                                          $scenes.delete_at(0)
                                                                $scene = newsc
                      $stopmainthread = true
                                            while $scene != nil and $scene.is_a?(Scene_Main) == false
                        $scene.main
                      end
                                            $stopmainthread = false
                      $scene = sc
$scene=Scene_Main.new if $scene.is_a?(Scene_Main) or $scene == nil
Graphics.update
key_update
$focus = true if $scene.is_a?(Scene_Main) == false                    
end
rescue Exception
      stopct=true
                                                  $stopmainthread = false
                      $scene = sc
$scene=Scene_Main.new if $scene.is_a?(Scene_Main) or $scene == nil
loop_update
$focus = true if $scene.is_a?(Scene_Main) == false                    
  retry
end
end
end
  if $currentthread != nil    
  if $currentthread.status==false or $currentthread.status==nil
        if $subthreads.size > 0
    $currentthread=$subthreads.last
    while $subthreads.last.status==false or $subthreads.last.status==nil
      $subthreads.delete_at($subthreads.size-1)
           end
    if $restart!=true
           $currentthread.wakeup
         else
           $mainthread.wakeup
           $subthreads=[]
           $scene=Scene_Loading.new
           end
      $subthreads.delete_at($subthreads.size-1)
    else
      $mainthread.wakeup
      $currentthread=nil
      end
        end
                                                                                                                                                              end
         sleep(0.1)
       end
     rescue Exception
       retry
       end
     end
     
     # @note this function is reserved for Elten usage
def thr5
                         begin
    loop do
      if $mproc==true
      $messageproc = true
@message = "\0" * 3072 if @message==nil
      if Win32API.new("user32","PeekMessage",'piiii','i').call(@message,$wnd,0,0,0) != 0
            hwnd, message, wparam, lparam, time, pt = @message.unpack('lllll')
if message == 0x20a
            $mouse_wheel=0 if $mouse_wheel==nil
                                    $mouse_wheel+=1 if wparam>0 and $mouse_wheel<1000000
                                    $mouse_wheel-=1 if wparam<0 and $mouse_wheel>-1000000
            end
                                      end
      $messageproc = false
      sleep(0.1)
      else
    sleep(0.5)
  end
  end
      rescue Exception
      fail
    end
  end
  
  # converts the return of Dir.entries to support diacretics
  #
  # @param dr [Array] the files list
  # @return [Array] the converted files list
  def filec(dr)
        rdr=[]
for f in dr
n=f.split(".")
n=n[0..n.size-2].join(".")
  fch=n.split("")
if fch.size<n.size
rf=""
for c in fch
if c.size==1 and c!=" " and c!="." and rf.size<6
rf+=c.to_s
end
end
e=File::extname(f)
idn=1
while rdr.include?(rf+"~"+idn.to_s+e)
idn+=1
end
rdr.push(rf+"~"+idn.to_s+e)
else
rdr.push(f)
end
end
return rdr
end    



# @deprecated use {#filec} instead.
  def afilec(dr)
        used={}        
        for b in 0..dr.size-1               
          d=dr[b]
        d.gsub!("/","\\")
        s=d.split("\\")
        pllet=["ą","ć","ę","ł","ń","ó","ś","ź","ż","Ą","Ć","Ę","Ł","Ń","Ó","Ś","Ź","Ż"]
        for i in 0..s.size-1
          suc=false
          for l in pllet
            suc=true if s[i].include?(l)
            end
          if suc == true
            for j in 0..s[i].size-2
  for l in pllet
  if s[i][j..j+1]==l
        s[i][j]=0
    s[i][j+1]=0
          s[i][s[i].size-1]=0
    s[i].delete!("\0")
    used[s[i]]=0 if used[s[i]]==nil
    used[s[i]]+=1
    s[i]+="~"+used[s[i]].to_s
        break
    end
    end
  end
  end                
  end
                                    dr[b]=s.join("\\")
        end
          return dr
        end
        
        # @note this function is reserved for Elten usage
        def rcwelcome
          msg=""
          if $language == "PL_PL"
            msg="Witajcie w wersji 2.0 RC.
Po betatestach trwających od sierpnia 2016 roku, mogę wreszcie zaprezentować efekty naszych prac.
Ta wersja to RC, release candidate.
Faktyczny Elten 2.0 ukaże się 24 sierpnia 2017 - tak, jak zapowiadałem na forum.
Już dzisiaj jednak udostępniam pierwszą wersję przedpremierową. Jeśli zabraknie czasu na dodawanie kolejnych funkcji, właśnie ta wersja stanie się wersją ostateczną.
Podobnie jak dotychczas, prosiłbym o zgłaszanie wszelkich błędów, uwag i sugestii.
Z pozdrowieniami,
Dawid Pieper"
else
msg="Welcome to Elten 2.0 RC!
We've been developing and testing it since August 2016 and, now, I can finally present you effects of our work.
This version is called RC, which means release candidate.
The final version of Elten 2.0 will be released on 24th August 2017, as I've written on forum.
I hope I'll have time to add some extra features.
However, this version includes a most of new functions.
As always, I'll be grateful for your bug reports and suggestions.
Best regards,
Dawid Pieper"
end
input_text("","MULTILINE|READONLY|ACCEPTESCAPE|ACCEPTTAB",msg)
end

# @note this function is reserved for Elten usage
def agent_start
    #return if $ruby
    File.delete("temp/agent_exit.tmp") if FileTest.exists?("temp/agent_exit.tmp")  
            $agentproc = run("bin\\rubyw -Itemp bin/agentc.dat") if $silentstart!=true
    sleep(0.1)
end

# Gets the size of a file or directory
#
# @param location [String] a location to a file or directory
# @param upd [Boolean] window refreshing
# @return [Numeric] a size in bytes
def getsize(location,upd=true)
               if File.file?(location)
    sz= File.size(location)
        sz=0 if sz<0
    return sz
    end
                      return Dir.size(location)
  end

# Deletes a specified directory with all subdirectories
#
# @param dir [String] a directory location
# @param with [Boolean] if false, deletes all subentries of the directory, but does not delete that directory
def deldir(dir,with=true)
  dr=Dir.entries(dir)
  dr.delete("..")
  dr.delete(".")
  for t in dr
    f=dir+"/"+t
    if File.directory?(f)
      deldir(f)
    else
      Win32API.new("kernel32","DeleteFile",'p','i').call(utf8(f))
      end
    end
    Win32API.new("kernel32","RemoveDirectory",'p','i').call(utf8(dir)) if with == true
  end
  
  # Copies a directory with all files and subdirectories
  #
  # @param source [String] a location of directory to copy
  # @param destination [String] destination
  def copydir(source,destination,esource=nil,edestination=nil)
    if esource==nil
      esource=source
      edestionation=destination
      end
  loop_update
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8(destination),nil)
  e=Dir.entries(esource)
  e.delete("..")
  e.delete(".")
  ec=Dir.entries(esource)
  ec.delete(".")
  ec.delete("..")
  for i in 0..ec.size-1
    if File.directory?(esource+"\\"+ec[i])
      copydir(source+"\\"+e[i],destination+"\\"+e[i],esource+"\\"+ec[i],edestination+"\\"+ec[i])
    else
      begin
      Win32API.new("kernel32","CopyFile",'ppi','i').call(utf8(source+"\\"+e[i]),utf8(destination+"\\"+e[i]),0)
    rescue Exception
      end
      end
    end
  end
  
  # @note this function is reserved for Elten usage
  def tray
    if $ruby==true
      speech(_("General:error_platform"))
      speech_wait
      return
      end
    run("bin\\elten_tray.bin")
  Win32API.new("user32","SetFocus",'i','i').call($wnd)
  Win32API.new("user32","ShowWindow",'ii','i').call($wnd,0)
  loop_update
  loop_update
    Win32API.new("user32","ShowWindow",'ii','i').call($wnd,1)
  end
  
  # Gets the main honor of specified user
  #
  # @param user [String] user name
  # @return [String] return a honor, if no honor selected, returns nil
  def gethonor(user)
    hn=srvproc("honors","name=#{$name}\&token=#{$token}\&list=1\&user=#{user}\&main=1")
    if hn[0].to_i<0 or hn[1].to_i==0
      return nil
    end
        if $language=="PL_PL"
          return hn[3].delete("\r\n")
        else
          return hn[5].delete("\r\n")
          end
        end
        
        # A shortname list of files in dir
        #
        # @param dir [String] a location to the dir
        # @return [Array] an array of files
        def filesindir(dir)
          begin
          dr=Dir.entries(dir)
        rescue Exception
          return []
          end
          dr.delete(".")
dr.delete("..")
o=[]
for f in dr
tmp="\0"*1024
Win32API.new("kernel32","GetShortPathName",'ppi','i').call(utf8(dir+"\\"+f),tmp,tmp.size)
tmp.delete!("\0")
tmp.gsub!("/","\\")
o.push(tmp.split("\\").last)
end
return o
end
def speechtofile(file="",text="",name="")
  text=read(file) if text=="" and file!=""
  text = text[3..text.size-1] if text[0] == 239 and text[1] == 187 and text[2] == 191
              name=File.basename(file).gsub(File.extname(file),"") if file!="" and name==""
  voices=[]
  for i in 0..Win32API.new("screenreaderapi","sapiGetNumVoices",'','i').call-1
    voices.push(futf8(Win32API.new("screenreaderapi","sapiGetVoiceName",'i','p').call(i)))
    end
  scl=[]
  for i in 0..100
    scl.push(i.to_s+"%")
    end
    fields=[Edit.new(_("EAPI_Common:type_title"),"",name,true),Select.new(voices,true,$voice.abs,_("EAPI_Common:head_voice"),true),Select.new(scl,true,$rate,_("EAPI_Common:head_rate"),true),FilesTree.new(_("EAPI_Common:head_dst"),getdirectory(40)+"\\",true,true,"Music"),FilesTree.new("Plik do przeczytania",getdirectory(40)+"\\",false,true,"Documents"),Select.new([_("EAPI_Common:opt_onefile"),_("EAPI_Common:opt_splitbyparagraphs"),_("EAPI_Common:opt_splitevery")],true,0,_("EAPI_Common:head_textsplit"),true),Edit.new(_("EAPI_Common:type_splitevery"),"","15",true),CheckBox.new(_("EAPI_Common:chk_readfilenum")),Select.new(["mp3","ogg","wav"],true,0,"Format wyjściowy",true),Button.new(_("EAPI_Common:btn_preview")),Button.new(_("EAPI_Common:btn_confirm")),Button.new(_("General:str_cancel"))]
    fields[4]=nil if file!="" or text!=""
    splittime=fields[6]
    splitinform=fields[7]
    fields[6]=nil
    fields[7]=nil
    fields[5]=nil if text!="" and text.size<5000
    form=Form.new(fields)
    loop do
      loop_update
      form.update
      if fields[5]!=nil      
      if fields[5].index==2
  fields[6]=splittime
  fields[7]=splitinform
elsif fields[5].index==1
    fields[6]=nil
  fields[7]=splitinform
  else
  fields[6]=nil
  fields[7]=nil
end
end
if (enter or space)
  if form.index==9
        ttext=""
    if text!=""
      ttext=text
    end
    if ttext==""
              ext=File.extname(fields[4].selected(false))
        if ext == ".doc" or ext==".docx" or ext==".epu" or ext==".epub" or ext==".html" or ext==".mobi" or ext==".pdf" or ext==".mob" or ext==".rtf"
        fid="txe#{rand(36**8).to_s(36)}"
            executeprocess("bin\\blb2txt.exe -f \"#{fields[4].selected}\" -v \"temp\\\" -p \"#{fid}\" -e \"utf8\"",true)
            File.rename("temp\\"+fid+".txt","temp\\"+fid+".tmp")
            impfile="temp\\#{fid}.tmp"
            ttext=read(impfile)
          File.delete(impfile)
            else
            ttext=read(fields[4].selected,false,true)
            end
                end
    if ttext!=""
    v=$voice
    r=$rate
    $voice=fields[1].index
    $rate=fields[2].index
    Win32API.new("screenreaderapi","sapiSetVoice",'i','i').call($voice)
    Win32API.new("screenreaderapi","sapiSetRate",'i','i').call($rate)
    t=ttext[0..9999]
    speech(t)
    while speech_actived
      loop_update
      speech_stop if enter or space
    end
    loop_update
    $voice=v
    $rate=r
    Win32API.new("screenreaderapi","sapiSetVoice",'i','i').call($voice)
    Win32API.new("screenreaderapi","sapiSetRate",'i','i').call($rate)
  else
    speech(_("EAPI_Common:error_nofiletoread"))
  end
end
if form.index==10
  ttext=""
    if text!=""
      ttext=text
    end
    if ttext==""
      ttext=read(fields[4].selected) if File.file?(fields[4].selected(false))
    end
  if fields[0].text==""
    speech(_("EAPI_Common:error_nofilename"))
  elsif File.directory?(fields[3].selected(false))==false
    speech(_("EAPI_Common:error_seldestination"))
  elsif ttext==""
    speech(_("EAPI_Common:error_selsource"))
  else
    cmd="bin\\rubyw bin/sapi.dat "
    cmd+="/v #{fields[1].index} "
    cmd+="/r #{fields[2].index} "
    cmd+="/n \"#{fields[0].text_str.gsub("\"","")}\" "
    maxd=0
if fields[5]!=nil
  maxd=fields[6].text_str.to_i*60 if fields[5].index==2
  cmd+="/d #{fields[6].text_str.to_i*60} " if fields[5].index==2
    cmd+="/s 1 " if fields[5].index==1
    cmd+="/p #{fields[7].checked} "  if fields[5].index>0
    end
    cname=fields[0].text_str.delete("\"\'\\/;\[\]\{\}\#\$^*\&|<>").gsub(" ","_")
    outd=fields[3].selected
    if fields[5]!=nil
    if fields[5].index>0
      outd+="\\#{cname}"
      Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8(outd),nil)
    end
    end
    outd+="\\#{cname}.wav"
    cmd+="/o \"#{outd}\" "
        if file==""
      if text!=""
        cmd+="/t \"#{text.gsub("\"","")}\" "
      else
        impfile=fields[4].selected
        ext=File.extname(fields[4].selected(false))
        fid=""
        if ext == ".doc" or ext==".docx" or ext==".epu" or ext==".epub" or ext==".html" or ext==".mobi" or ext==".pdf" or ext==".mob" or ext==".rtf"
        fid="txe#{rand(36**8).to_s(36)}"
            executeprocess("bin\\blb2txt.exe -f \"#{fields[4].selected}\" -v \"temp\\\" -p \"#{fid}\" -e \"utf8\"",true)
            File.rename("temp\\"+fid+".txt","temp\\"+fid+".tmp")
            impfile="temp\\#{fid}.tmp"
            end
            text=read("temp\\"+fid+".tmp")
              cmd+="/i \"#{impfile}\" "
        end
    else
      cmd+="/i \"#{file}\" "
      end
            outfl="temp/sapiout"+rand(36**2).to_s(36)+".tmp"
      cmd+="/l \"#{outfl}\" "
      $ovoice=$voice
      #$voice=-1
      h=run(cmd,true)
      play("waiting")
      starttm=Time.now.to_i
edt=Edit.new(_("EAPI_Common:read_readingtofile"),"READONLY|MULTILINE","",true)
f=false            
t = 0
file=0
fn=false
rf=0
th=Thread.new do
  fr=nil
  case fields[8].index
  when 0
    fr=".mp3"
    when 1
      fr=".ogg"
    end
      rf=0
    while (file>rf or fn==false) and fr!=nil
        sleep(0.5)
  if file>rf+1
        n=rf+1
    if fields[5]!=nil and fields[5].index>0
        b=outd.gsub(File::extname(outd),"_"+sprintf("%03d",n)+File.extname(outd))
      else
        b=outd
        end
    if FileTest.exists?(b)
      c="bin\\ffmpeg -y -i \"#{b}\" \"#{b.gsub(".wav",fr)}\""
      executeprocess(c,true,0,false)
      Win32API.new("kernel32","DeleteFile",'p','i').call(utf8(b))
    end
    rf+=1
  else
    break if fn and rf==file-1
    end
    end
  end
loop do
        loop_update
        tx=read(outfl)
                if /(\d+):(\d+)\/(\d+):(\d+)\/(\d+):(\d+)\/(\d+)/=~tx
                  if $4.to_i>0 and $5.to_i>0
                  edt.settext("#{($4.to_f/($5.to_f+1.0)*100.0).to_i}%\r\n#{_("EAPI_Common:txt_phr_readtofilenum")} #{$1}#{if maxd==0;"";else;" ("+(($6.to_f/maxd.to_f*100.0).to_i%101).to_s+"%)";end}\r\n#{s_("EAPI_Common:txt_phr_sentencenumber",{'cursentence'=>$2,'sentences'=>$3})}\r\n#{_("EAPI_Common:txt_phr_readtime")} #{sprintf("%02d:%02d:%02d",$7.to_i/3600,($7.to_i/60)%60,$7.to_i%60)}#{if Time.now.to_i>starttm;"\r\n#{_("EAPI_Common:txt_phr_timeremaining")}"+sprintf("%02d:%02d:%02d",((Time.now.to_i-starttm)/($4.to_f/$5.to_f)*(1-$4.to_f/$5.to_f)).to_i/3600,((Time.now.to_i-starttm)/($4.to_f/$5.to_f)*(1-$4.to_f/$5.to_f)).to_i/60%60,((Time.now.to_i-starttm)/($4.to_f/$5.to_f)*(1-$4.to_f/$5.to_f)).to_i%60);else;"";end}",false)
          file=$1.to_i
          if f == false
          edt.focus
          f=true
          end
          end
        end
        edt.update
        x="\0"*1024
        Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
if x != "\003\001"
  $voice=$ovoice
    file+=1
    edt.settext(_("EAPI_Common:read_waitprocessingfiles"))
    edt.focus
 fn=true
   while th.status!=false and th.status!=nil
   loop_update
   if file!=1
   edt.settext("Przetwarzanie... #{(rf.to_f/(file-1).to_f*100.0).to_i}%",false)
   end
   edt.update
   end
  waiting_end
   speech(_("EAPI_Common:info_readtofilefinished"))
  speech_wasp
  break
  end
end
break
    end
  end
  if form.index==11
    break
    end
  end
  break if escape
      end
    end
       def decompress(source,destination,msg="Rozpakowywanie...")
         speech(msg)
         waiting
         executeprocess("bin\\7z x \"#{source}\" -y -o\"#{destination}\"",true)
         waiting_end
       end
       def compress(source,destination,msg=_("EAPI_Common:wait_packing"))
         speech(msg)
         waiting
ext=File.extname(destination).downcase
cmd=""
if ext==".rar"
  cmd="bin\\rar a -ep1 -r \"#{destination}\" \"#{source}\" -y"
else
  cmd="bin\\7z a \"#{destination}\" \"#{source}\" -y"
  end
executeprocess(cmd,true)
         waiting_end
       end
      end
    end
#Copyright (C) 2014-2018 Dawid Pieper