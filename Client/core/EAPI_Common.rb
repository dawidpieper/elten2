#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module Common
        def quit
      dialog_open
            sel = SelectLR.new(["Anuluj","Ukryj program w zasobniku systemowym","Wyjście"],true,0,"Zamykanie programu...")
      loop do
        loop_update
        sel.update
        if escape
          dialog_close
          break
            $exit = false
            return(false)
            end
        if enter
          dialog_close
          case sel.index
          when 0
            break
            $exit = false
            return(false)
            when 1
              $exit = false
              $scene = Scene_Tray.new
              return false
            when 2
              $scene = nil
              break
              $exit = true
              return(true)
                $exit = false
                return false
          end
          end
        end
      end
      
      class Scene_Console
      def main
                        kom = ""
        while kom == "" or kom == nil
          kom = input_text("Podaj polecenia do wykonania","MULTILINE|ACCEPTESCAPE").to_s
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
eval(kom,nil,"Console")
$consoleused = false        
$scene = Scene_Main.new if $scene == self
end
end

def error_ignore
  $scene = Scene_Main.restart
end

    def usermenu(user,submenu=false)
            ct = srvproc("contacts_mod","name=#{$name}\&token=#{$token}\&searchname=#{user}")
      err = ct[0].to_i
if err == -3
  @incontacts = true
else
  @incontacts = false
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
  play("menu_open") if submenu != true
play("menu_background") if submenu != true
sel = ["Napisz prywatną wiadomość","Wizytówka","Otwórz blog tego użytkownika","Pliki udostępniane przez tego użytkownika"]
if @incontacts == true
  sel.push("Usuń z kontaktów")
else
  sel.push("Dodaj do kontaktów")
end
sel.push("Odtwórz awatar")
if $rang_moderator > 0
  if @isbanned == false
    sel.push("Zbanuj")
  else
    sel.push("Odbanuj")
    end
  end
  fl = srvproc("uploads","name=#{$name}\&token=#{$token}\&searchname=#{user}")
  if fl[0].to_i < 0
    speech("Błąd")
    speech_wait
    return
  end
    @menu = SelectLR.new(sel)
@menu.disable_item(2) if @hasblog == false
@menu.disable_item(3) if fl[1].to_i==0
@menu.disable_item(5) if @hasavatar == false
loop do
loop_update
@menu.update
if enter
  case @menu.index
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
      if @incontacts == true
        $scene = Scene_Contacts_Delete.new(user,self)
      else
        $scene = Scene_Contacts_Insert.new(user,self)
      end
      when 5
        play("menu_close")
      Audio.bgs_stop
      speech("Pobieranie...")
      avatar(user)
            return("ALT")
      break        
      when 6
        if @isbanned == false
          $scene = Scene_Ban_Ban.new(user,self)
        else
          $scene = Scene_Ban_Unban.new(user,self)
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
Graphics.transition(10) if submenu != true
end


     def whatsnew(quiet=false)
       wntemp = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&get=1")
       err = wntemp[0]
messages = wntemp[1].to_i
posts = wntemp[2].to_i
blogposts = wntemp[3].to_i
                                    if messages <= 0 and posts <= 0 and blogposts <= 0
  speech("Nie ma nic nowego.") if quiet != true
else
  $scene = Scene_WhatsNew.new(true)
end
speech_wait
end


def createsoundtheme(name="")
  while name == ""
    name = input_text("Podaj nazwę tematu dźwiękowego.")
  end
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
speech("Pliki tematu dźwiękowego utworzone w: " + stp)
speech_wait
speech("Nazwa tematu: " + name)
speech_wait
speech("Podmień pliki domyślnego tematu dźwiękowego w utworzonym katalogu plikami, które mają wchodzić w jego skład.")
speech_wait
sel = SelectLR.new(["Otwórz folder tematu w plikach","Otwórz folder tematu w systemowym eksploratorze plików","Zamknij"],true,0,"Co chcesz zrobić?")
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
        system("start " + stp)
        when 2
          return
          break
    end
    end
  end
end


          def createdebuginfo
            di = ""
            di += "*ELTEN | DEBUG INFO*\r\n"
            if $@ != nil
              if $! != nil
            di += $!.to_s + "\r\n" + $@.to_s + "\r\n"
          end
          end
            di +="\r\n[Computer]\r\n"
            di += "OS version: " + Win32API.new($eltenlib,"WindowsVersion",'v','i').call.to_s + "\r\n"
            di += "Appdata path: " + $appdata + "\r\n"
            di += "Elten data path: " + $eltendata.to_s + "\r\n"
                procid = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("PROCESSOR_IDENTIFIER",procid,procid.size)
procid.delete!("\0")
di += "Processor Identifier: " + procid.to_s + "\r\n"
                procnum = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("NUMBER_OF_PROCESSORS",procnum,procnum.size)
procnum.delete!("\0")
di += "Number of processors: " + procnum.to_s + "\r\n"
                cusername = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("USERNAME",cusername,cusername.size)
cusername.delete!("\0")
di += "User name: " + cusername.to_s + "\r\n"
di += "\r\n[Elten]\r\n"
di += "User: " + $name.to_s + "\r\n"
di += "Token: " + $token.to_s + "\r\n"
ver = $version.to_s
ver += "_BETA" if $isbeta == 1
di += "Version: " + ver.to_s + "\r\n"
di += "Start time: " + $start.to_s + "\r\n"
di += "Current time: " + Time.now.to_i.to_s + "\r\n"
if $app!=nil
di += "\r\n[Programs]\r\n"
for i in 0..$app.size - 1
di += $app[i].to_s
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
return di
end

def bug(getinfo=true,info="")
  loop_update
  if getinfo == true
  while info == ""
    info = input_text("Opisz znaleziony błąd","MULTILINE|ACCEPTESCAPE")
  end
  if info == "\004ESCAPE\004"
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
    speech("Błąd.")
    r = err
  else
    speech("Wysłano.")
    r = 0
  end
  speech_wait
  return r
end





class Scene_Relogin
def main
  speech("Klucz sesji wygasł. Czy chcesz zalogować się ponownie jako #{$name} ?")
  speech_wait
      autologin = readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i
                  name = readini($configdata + "\\login.ini","Login","Name")
            al = true if autologin.to_i != 0 and name == $name
  if simplequestion == 1
    if al == false
    password = input_text("Podaj hasło dla użytkownika #{$name}","password")
else
            password_c = "\0" * 128
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Login","password","0",password_c,password_c.size,$configdata + "\\login.ini")
    password_c.delete!("\0")
psw = password_c
password = ""
l = false
mn = psw[psw.size - 1..psw.size - 1]
mn = mn.to_i
mn += 1
l = false
for i in 0..psw.size - 1 - mn
  if l == true
    l = false
  else
    password += psw[i..i]
    l = true
    end
  end
      password = decrypt(password)
    password = password.gsub("a`","ą")
password = password.gsub("c`","ć")
password = password.gsub("e`","ę")
password = password.gsub("l`","ł")
password = password.gsub("n`","ń")
password = password.gsub("o`","ó")
password = password.gsub("s`","ś")
password = password.gsub("x`","ź")
password = password.gsub("z`","ż")
end
    logintemp = srvproc("login","login=1\&name=#{$name}\&password=#{password}\&version=#{$version.to_s}\&beta=#{$beta.to_s}\&relogin=1")
      $token = logintemp[1]
  $token.delete!("\r\n")
  $name = name
if logintemp[0].to_i < 0
  speech("Błąd, nie mogę się zalogować. Prawdopodobnie podano błędne hasło lub jesteś zbanowany.")
  speech_wait
 $token = nil
 $scene = Scene_Main.new
else
  speech("Operacja zakończona powodzeniem")
  $scene = Scene_Main.new
  end
else
  $scene = Scene_Lodaing.new
end
end
end




  def selectcontact
                ct = srvproc("contacts","name=#{$name}\&token=#{$token}")
        err = ct[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
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
        speech("Pusta Lista")
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
          $focus = true
                    return(nil)
        end
        if enter and $contact.size > 0
          $focus = true
          play("list_select")
                    return($contact[sel.index])
          end
        end
        end
      

  def visitingcard(user=$name)
    prtemp = srvproc("getprivileges","name=#{$name}\&token=#{$token}\&searchname=#{user}")
        vc = srvproc("visitingcard","name=#{$name}\&token=#{$token}\&searchname=#{user}")
    err = vc[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      return -1
      when -2
        speech("Klucz sesji wygasł.")
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
text += "Użytkownik: #{user} \r\n"
text += getstatus(user)
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
        birthdateyear = pr[3].delete("\r\n")
        birthdatemonth = pr[4].delete("\r\n")
        birthdateday = pr[5].delete("\r\n")
        location = pr[6].delete("\r\n")
        text += fullname+"\r\n"
        text+="Płeć: "
        if gender == 0
          text += "kobieta\r\n"
        else
          text += "mężczyzna\r\n"
        end
        age = Time.now.year-birthdateyear.to_i
if Time.now.month < birthdatemonth.to_i
  age -= 1
elsif Time.now.month == birthdatemonth.to_i
  if Time.now.day < birthdateday.to_i
    age -= 1
    end
  end
  age -= 2000 if age > 2000      
  text += "Wiek: #{age.to_s}\r\n"
  end
  ui = userinfo(user)
if ui != -1
if gender == -1
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
text += "Zna użytkowników: " + ui[2].to_s + "\r\n"
if gender == -1
text += "Znan(y/a)"
elsif gender == 0
  text += "Znana"
elsif gender == 1
  text += "Znany"
end
text += " przez użytkowników: " + ui[3].to_s + "\r\n"
text += "Wpisy na forum: " + ui[4].to_s + "\r\n"
end
text += "\r\n\r\n"
      for i in 1..vc.size - 1
        text += vc[i]
      end
      inptr = Edit.new("Wizytówka: #{user}","READONLY|MULTILINE",text)
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
        $nbeta = nbeta
    $nversion = nversion
    if $nversion > $version or $nbeta > $beta
      $scene = Scene_Update_Confirmation.new
    else
      speech("Brak dostępnych aktualizacji.")
      speech_wait
    end
  end
  

          

          

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

II. Rejestracje
1. Użytkownikiem Eltena może zostać każda osoba, która ukończyła trzynasty rok życia.
2. Autor lub moderacja mogą nie udzielić zgody na rejestrację w szczególnych wypadkach, gdy rada starszych programu uzna, że osoba chcąca się zarejestrować nie ma prawa do dokonania tej czynności.
3. W przypadku łamania postanowień niniejszego regulaminu, użytkownik może zostać pozbawiony (okresowo lub trwale) dostępu do swojego konta. Decyzję o tym podejmują moderatorzy lub autor.
4. Podanie prawdziwego adresu e-mail jest obowiązkowe. W szczególnych wypadkach może on zostać użyty w celu weryfikacji tożsamości użytkownika.

III. Blogi i prywatne wiadomości
1. Zarówno blogi, jak i prywatne wiadomości należą do użytkownika.
2. Nie mniej jednak, za obrażanie społeczności poprzez wysyłanie do nieznanych ludzi masowych wiadomości o charakterze obraźliwym będzie karane.
3. Autor programu nie ponosi odpowiedzialności za treści umieszczane na blogach i w prywatnych wiadomościach.

IV. Forum
1. Na forum należy przestrzegać zasad netykiety. Zabrania się wyzywania czy  obrażania innych użytkowników, jak również nadużywania określeń uważanych powszechnie za wulgarne.
2. Każdy na forum ma prawo do własnego zdania w danych kwestiach.
3. Za utrzymanie porządku na forum odpowiadają moderatorzy, mając prawo do:
A. Ostrzegania użytkownika,
B. Usuwania wątków lub wpisów stojących w niezgodzie z niniejszym regulaminem,
C. Przenoszenia wpisów,
D. W szczególnych wypadkach, gdy uznana zostanie taka konieczność, edycji wpisów,
E. Pozbawiania użytkownika dostępu do jego konta.
4. Moderatorzy mają prawo do edycji wpisów w ypadku:
A. Niecelowego ujawnienia danych prywatnych innych osób bez zgody tych osób, na wniosek osoby poszkodowanej,
B. W wypadku wątków o specyficznym sposobie lub zakresie wypowiedzi, w celu dostosowania wpisu do szablonu lub charakteru wątku.
5. Użytkownik, umieszczając daną treść na forum, oświadcza, że ma prawo do jej publikacji.
6. Na forum należy przestrzegać zasad ułatwiających łatwe przeglądanie wpisów, unikać mieszania tematów, zakładania ich na niewłaściwych forach lub tworzenia tematów odbiegających całkowicie od zadanego tytułu.

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
else
  @license = "Elten terms of use and license agreement the following terms are software license agreement of Elten and Elten Network.

I. General
1. Dawid Pieper is The author of the program and the owner of both the software and the data. He grants you a license to use this application, as long as Elten is supported by him.
2. Elten is an open source software licensed under Open Public License. It is forbidden to create independent distribution and copies of Elten, as long as Elten is supported by the developer. Also any deliberate malicious action on the server, both indirectly and directly, are forbidden.
3. any safety tests, mainly penetration tests, are allowed, but the condition is to inform the author of their carrying out and about their results. It is prohibited to use any found errors.
4. the Elten can be developed by any programmer, however, none of the written-in feature may not harm the users or their privacy. The new changes ultimately approves or rejects the author of the program.
5. Users publishing their work are the authors of these works, do not waive any ownership or copyrights on any of the other users or the author. However, they give to the author the right to distribute these works in order to place them on the sites of Portal Elten.

II. Registration
1. Elten user can be any person who is thirteenth years old or older.
2. the author or moderation may refuse the registration request in special occassions.
3. in the case of breaches of the provisions of these terms, the user can be deprived (temporarily or permanently) of access his/her account. The decision shall be taken the moderators or the author.
4. Entering a real e-mail address is required. In special cases, it may be used to verify the identity of the user.

III. the Blogs and private messaging
1. Both blogs, and private messages belong to the user writing them.
2. Sending to unknown people mass offensive messages will be punished.
3. the Author is not responsible for the content posted on the blogs and in private messages.

IV. The Forum
1. The users have to follow the rules of Netiquette. It is forbidden to insult other users, as well as abuse of the words that are vulgar.
2. Everyone has the right to his/her own opinion.
3. Moderators have rights to:
A. Warning the user,
B. Removing threads or posts standing in conflict with these terms and conditions,
C. Moving posts,
D. In special cases, when considered as necessary, edit posts,
E. Ban users.
4. the Moderators have the right to edit entries, when:
A. Disclosure of the private data of other people without their consent, at the request of the injured person,
B. In special threads where posts must be adapted to common templates.
5. the user by placing the content on the forum, declares that he/she has the right to publicate it.

V. Administration
1. The user receive or is deprived of special rights by the author of the program.
2. the Belongings to the administration does not release from the obligation to comply with these terms.
3. the user may receive the following titles:
A. Betatester
B. Moderator,
C. Translator,
D. Media Administrator,
E. Developer.

VI. Other
1. In the case do not take in these terms and conditions, the decision about the correctness or incorrectness of an act takes the author.
2. User declares that he/she knows and understands these terms and conditions.
3. Any user may report the ambiguity or doubt as to the correctness of any point in these terms and conditions.
4. the author shall have the right at any time to change or cancel the terms and conditions."
end
form = Form.new([Edit.new("Umowa licencyjna oraz regulamin użytkowania programu Elten oraz sieci Elten Network","MULTILINE|READONLY",@license,true),Button.new("Akceptuję"),Button.new("Nie akceptuję, zamknij program")])
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
    q = simplequestion("Czy akceptujesz umowę licencyjną oprogramowania Elten?")
    if q == 0
      exit
    else
      break
      end
    end
    end
  end
end

end
def player(file,label="",wait=false)
if label != ""
  dialog_open if wait==false
speech(label)
speech_wait if wait == true
$dialogvoice.close if $dialogvoice != nil
$dialogvoice = nil
end
sound = AudioFile.new(file)
    sound.play
        loop do
          pos=sound.position
sleep(0.05) if wait == true
          loop_update
      if space
        if sound.playing?
        sound.pause
      else
        sound.play
        pos=0
        end
        end
      if escape or enter
        if wait == false
        for i in 1..50
          sound.volume -= 0.02
          loop_update
        end
        end
sound.close
dialog_close if label != ""          
return
break
      end
            if Input.repeat?(Input::RIGHT)
        sound.position += 5000
      end
      if Input.repeat?(Input::LEFT)
        sound.position -= 5000
      end
            if Input.repeat?(Input::UP)
        sound.volume += 0.05
sound.volume = 0.5 if sound.volume == 0.6
      end
      if Input.repeat?(Input::DOWN)
        sound.volume -= 0.05
sound.volume = 0.01 if sound.volume == 0
end
if wait == true
  if pos != 0 and sound.playing? == true
    if pos == sound.position
      sound.close
      return
      break
      end
    end
  end
  pos=sound.position
end
end
def thr1
                begin
                loop do
                  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x11) > 0 and $speech_wait == true
                    speech_stop
                    $speech_wait = false
                    end
                  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x77) > 0
                    time = ""
                    if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) > 0
time = srvproc("time","dateformat=Y-m-d")
else
  time = srvproc("time","dateformat=H:i:s")
  end
speech(time[0])
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x75) > 0 and $volume < 100
  $volume += 5 if $volume < 100
  writeini($configdata + "\\interface.ini","Interface","MainVolume",$volume.to_s)
  play("list_focus")
  sleep(0.1)
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x74) > 0 and $volume > 1
  $volume -= 5 if $volume > 1
  play("list_focus")
  writeini($configdata + "\\interface.ini","Interface","MainVolume",$volume.to_s)
  sleep(0.1)
end
if Win32API.new($eltenlib,"KeyState",'i','i').call(0x72) > 0
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
if $name != "" and $name != nil and $token != nil and $token != ""
  if Win32API.new($eltenlib,"KeyState",'i','i').call(0x78) > 0
    if Win32API.new($eltenlib,"KeyState",'i','i').call(0x10) <= 0 and $scene.is_a?(Scene_Contacts) == false
    $scenes.insert(0,Scene_Contacts.new)
      elsif $scene.is_a?(Scene_Online) == false and Win32API.new("user32","GetAsyncKeyState",'i','i').call(0x10) > 0
        $scenes.insert(0,Scene_Online.new)
  end
  sleep(0.1)
  end
        if Win32API.new($eltenlib,"KeyState",'i','i').call(0x79) > 0 and $scene.is_a?(Scene_WhatsNew) == false
    $scenes.insert(0,Scene_WhatsNew.new)
    sleep(0.1)
    end
  end
  sleep(0.1)
end
rescue Exception
  print $!.message
  retry
                end
                  end
def thr2
          loop do
            begin
            if $voice != -1
              sleep(0.01)
            Win32API.new("screenreaderapi","nvdaStopSpeech",'v','i').call
            Win32API.new("screenreaderapi","jfwStopSpeech",'v','i').call
            Win32API.new("screenreaderapi","weStopSpeech",'v','i').call
                      end
              rescue Exception
        fail
      end
      end
          end
def thr3
              $playlistlastindex = 0
              position = -1
              loop do
                sleep(0.1)
                if $playlist != nil
              if $playlist.size > 0
                if $playlistindex != nil
if $playlistbuffer == nil
                  volume = 80
                  volume = (volume.to_f / $volume.to_f * 100.0)
                                                                                                                        $playlistbuffer = nil
                                                                            begin
                          $playlistbuffer = AudioFile.new($playlist[$playlistindex])
                        rescue Exception
                          $playlist.delete_at($playlistindex)
                          $playlistindex = 0
                          retry
                        end
                        if $playlistbuffer != nil
                                                                                                                          $playlistbuffer.play
                                                $playlistbuffer.volume = volume
                                              end                                
                                              $playlistlastindex = $playlistindex                                                             
                                              else
                                                                                                                             if $playlistbuffer.position == position
                                                                                                                               if $playlistpaused != true
                                                                                                                                                                                                                                                                   $playlistbuffer = nil 
                                                                 position = -1
                                                                 if $playlistindex == $playlistlastindex
                                                                 $playlistindex += 1
                                              $playlistindex = 0 if $playlistindex >= $playlist.size                                              
                                            end
                                          else
                                            position += 150
                                            end
                                                                                                                                                                                                   elsif position < $playlistbuffer.position
                                                               position = $playlistbuffer.position                                                               
                                                               end
                                                                 end
                             end
              end
              end
            end
                        end
def thr4
                loop do
                  sc = $scene
                  if $scenes.size > 0
                                        $subthread = Thread.new do
                                          sleep(0.1)
                      $scene = $scenes[0]
                      $scenes.delete_at(0)
                      while $scene != nil
                        $scene.main
                                              end
                      end
                                        $stopmainthread = true
                    $subthread.value
                    $stopmainthread = false
$scene = sc
$focus = true if $scene.is_a?(Scene_Main) == false                    
$scene = Scene_Main.new if $scene.is_a?(Scene_Main)
loop_update
                    $mainthread.wakeup
                                        end
                  end
                            end
def thr5
                       begin
    loop do
      $messageproc = true
@message = "\0" * 32768
      if Win32API.new("user32","GetMessage",'piii','i').call(@message,$wnd,0,16384) != 0
            hwnd, message, wparam, lparam, time, pt = @message.unpack('iiiii')
                        
                                end
      $messageproc = false
        sleep(0.3)
      end
      rescue Exception
      fail
      end
    end
end
#Copyright (C) 2014-2016 Dawid Pieper