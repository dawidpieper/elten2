#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

def firstrun;$scene=Scene_FirstRun.new;end
class Scene_FirstRun
  def main
        speech("Witam w programie Elten! Przede wszystkim chciałbym podziękować za zainstalowanie oraz za zarejestrowanie się w tym portalu. Ten kreator pomoże ci skonfigurować twoje konto. Aby kontynuować, naciśnij enter. Aby opuścić kreator, naciśnij escape.")
    loop do
      loop_update
              break if enter
        if escape
          $scene=Scene_Main.new
          return
          end
    end
    vc = srvproc("visitingcard","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
    if vc[1]=="     "
      a=simplequestion("Miejscem, w którym możesz napisać coś o sobie, jest twoja wizytówka. Twoja wizytówka może być przeczytana przez każdego użytkownika i dostępna jest z poziomu twojego menu, na przykład po wciśnięciu klawisza alt na twoim wpisie na forum bądź też na liście kontaktów, osób zalogowanych i tak dalej. Czy chcesz teraz napisać swoją wizytówkę?")
      if a == 1
      $scenes.insert(0,Scene_Account_VisitingCard.new)
sleep(1)
      delay(0.1)
      sleep(1)
      while $stopmainthread;sleep(0.1);end
              end
    end
    if $gender==-1 
      a=simplequestion("Podstawowe informacje o tobie można odnaleźć w profilu. Jest on wyświetlony w wizytówce. Dodatkowo, jego wypełnienie pozwala na informowanie znajomych o takich zdarzeniach, jak twoje urodziny, a także na spersonalizowanie komunikatów programu. Możesz zdecydować czy twój profil ma być dostępny publicznie, czy też tylko dla osób z twojej listy kontaktów. Czy chcesz teraz wypełnić swój profil")
      if a == 1
        $scenes.insert(0,Scene_Account_Profile.new)
        sleep(1)
        delay(0.1)
        sleep(1)
        while $stopmainthread;sleep(0.1);end
                end
    end
    av = srvproc("avatar","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&checkonly=1")
    if av[0].to_i<0 
      a=simplequestion("Awatar to nagranie audio, które jest dostępne do odtworzenia z poziomu menu twojego profilu. Może to być nagranie twojego głosu, utwór muzyczny lub dowolny inny dźwięk. Czy chcesz teraz ustawić swój awatar?")
      if a == 1
        $scenes.insert(0,Scene_Account_Avatar.new)
        sleep(1)
        delay(0.1)
        sleep(1)
        while $stopmainthread;sleep(0.1);end
        end
    end
if signature($name)=="   "
a=simplequestion("Twoja sygnaturka to tekst, który pojawia się pod każdym twoim wpisem na forum. Może to być zwykłe pozdrowienie, cytat lub cokolwiek innego, co chcesz zobaczyć pod swoimi postami. Czy chcesz teraz ustawić swoją sygnaturę?")
if a == 1
  $scenes.insert(0,Scene_Account_Signature.new)
  sleep(1)
  delay(0.1)
  sleep(1)
  while $stopmainthread;sleep(0.1);end
  end
end
if getstatus($name)=="" 
  a=simplequestion("Status to krótka wiadomość tekstowa widziana przy twoim loginie na liście konttaktów, osób zalogowanych i innych listach użytkowników. Może to być lubiany cytat, informacja o, jak sama nazwa wskazuje, statusie czy dowolny inny tekst. Czy chcesz ustawić swój status?")
  if a == 1
    $scenes.insert(0,Scene_Account_Status.new)
    sleep(1)
    delay(0.1)
    sleep(1)
    while $stopmainthread;sleep(0.1);end
    end
end
if $greeting == "" or $greeting == nil or $greeting == "\n" or $greeting == "\r\n" or $greeting == " "
  a=simplequestion("Ostatnią rzeczą dotyczącą twojego konta, którą możesz ustawić, jest wiadomość powitalna. Wiadomość powitalna to komunikat, który odczytywany jest podczas twojego logowania się do konta. Czy chcesz ją ustawić?")
  if a == 1
    $scenes.insert(0,Scene_Account_Greeting.new)
    sleep(1)
    delay(0.1)
    sleep(1)
    while $stopmainthread;sleep(0.1);end
    end
end
speech("Gratulacje, zakończyłeś konfigurowanie swojego profilu. Kolejne ustawienia dotyczą funkcjonowania samego programu. Wciśnij enter, aby skonfigurować ustawienia programu lub escape, aby opuścić ten kreator.")
loop do
      loop_update
              break if enter
        if escape
          $scene=Scene_Main.new
          return
          end
        end
if $soundthemepath=="Audio"
  a=simplequestion("Aby zróżnicować dźwięki interfejsu programu, dostępne są dodatkowe pakiety dźwiękowe tworzone przez użytkowników Eltena. Czy chcesz otworzyć teraz ustawienia tematu dźwiękowego?")
if a == 1
  $scenes.insert(0,Scene_SoundThemes.new)
  sleep(1)
  delay(0.1)
  sleep(1)
  while $stopmainthread;sleep(0.1);end
  end
end
if $interface_typingecho==0 
e=selector([_("FirstRun:opt_chars"),_("FirstRun:opt_words"),_("FirstRun:opt_charsandwords"),_("FirstRun:opt_none")],"Jak łatwo zauważyć, domyślnie Elten informuje o każdym wpisanym w pola tekstowe znaku. Zachowanie to można zmienić. Wybierz ustawienie echa klawiszy:",0,0,1)
writeini($configdata + "\\interface.ini","Interface","TypingEcho",e.to_s)
$interface_typingecho=e
end
if $interface_hidewindow==0 
  $interface_hidewindow=simplequestion("Jeśli chcesz, możesz skonfigurować Eltena tak, by ukrywał się po zminimalizowaniu. Dzięki temu możliwa jest swobodna praca na komputerze bez otwartego na wierzchu okna Eltena. W czasie, gdy okno jest ukryte, nadal będziesz otrzymywać powiadomienia o nowych wiadomościach czy wpisach na forum. Przywrócenie okna możliwe jest z poziomu zasobnika systemowego lub dzięki kombinacji klawiszy Control + Alt + Shift + T, jak Tadeusz. Czy chcesz automatycznie minimalizować okno Eltena do zasobnika systemowego?")
  writeini($configdata + "\\interface.ini","Interface","HideWindow",$interface_hidewindow.to_s)
end
@autostart=false
@runkey=Win32::Registry::HKEY_CURRENT_USER.create("Software\\Microsoft\\Windows\\CurrentVersion\\Run")
begin
  @runkey['elten']
  @autostart=true
rescue Exception
  @autostart=false
end
if @autostart == false 
  if simplequestion("Elten może być skonfigurowany tak, by uruchamiał się wraz ze startem systemu. W takim wypadku startował będzie do zasobnika systemowego, a więc okno będzie ukryte. Pokaże się dopiero po wywołaniu Eltena z zasobnika lub po użyciu skrótu klawiszowego CTRL + ALT + SHIFT + T, jak Tadeusz. Czy chcesz włączyć autostart Eltena?") == 1
if readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i <= 0
password=nil
  loop do
          password=input_text(_("FirstRun:type_pass"),"PASSWORD") if password=="" or password==nil
                    if password!=""
            lt=srvproc("login","login=2\&name=#{$name}\&password=#{password}\&computer=#{$computer.urlenc}\&appid=#{$appid}")
            if lt[0].to_i<0
              speech("Wystąpił błąd podczas uwierzytelniania tożsamości. Możliwe, że podane zostało błędne hasło.")
              speech_wait
              password = ""
            else
writeini($configdata+"\\login.ini","Login","AutoLogin","3")
              writeini($configdata+"\\login.ini","Login","Name",$name)
              writeini($configdata+"\\login.ini","Login","Token",lt[1].delete("\r\n"))
              writeini($configdata+"\\login.ini","Login","password",nil)
                                                   break   
         end
                        end
          end                      
    end
           path="\0"*1024
Win32API.new("kernel32","GetModuleFileName",'ipi','i').call(0,path,path.size)
path.delete!("\0")
dr="\""+File.dirname(path)+"\\bin\\rubyw.exe\" \""+File.dirname(path)+"\\bin\\agentc.dat\" /autostart"
@runkey['elten']=dr
    end
end
@runkey.close
speech("Konfiguracja programu Elten została zakończona, dziękujemy. Teraz możesz rozpocząć używanie programu. Wszelkie dodatkowe informacje i wskazówki znajdziesz w menu pomoc. Przede wszystkim zapraszamy do aktywności na forum i do przywitania się w wątku \"Poznajmy się\". Pozdrawiam, Dawid Pieper. Naciśnij enter, aby przejść do programu Elten.")
loop do
  loop_update
  break if enter or escape
end
$scene=Scene_Main.new
  end
  end
#Copyright (C) 2014-2018 Dawid Pieper