#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ReadMe
  def main    readme = IO.readlines("readme.txt")
    text=""
    if $language=="PL_PL"
    text = "Witam w programie Elten!
Ten dokument zawiera kilka wskazówek i informacji dotyczących tej aplikacji.

1. Wymagania systemowe
System operacyjny: Windows XP lub nowszy
Pamięć RAM: 512MB
Procesor: 800MHz
Dysk twardy: 256MB wolnego miejsca
Dostęp do Internetu

2. Informacje wstępne
Autorem oprogramowania jest Dawid Pieper. Jest to program o otwartym kodzie źródłowym, który można odnaleźć pod adresem
http://github.com/dawidpieper/elten2
Szczegóły licencjonowania określa osobny dokument.
Elten to sieć społecznościowa dedykowana osobom niewidomym. Składa się z serwera, portalu Internetowego oraz, przede wszystkim, klienta przeznaczonego dla systemu Windows.
Prócz tego jest to API dla programistów i podstawa pod inne aplikacje dedykowane osobom niewidomym.

3. Rejestracja i logowanie
Zarówno rejestracji, jak i logowania można dokonać z poziomu powitalnego okna programu. Pamiętaj, by wybrać nieoczywiste hasło, by nikt niepowołany nie mógł wejść na twoje konto.
Ważne, by podać prawdziwy adres e-mail, ponieważ może on zostać użyty do odzyskania hasła w wypadku jego utracenia.
Po zalogowaniu się na swoje konto możesz włączyć automatyczne logowanie, dzięki czemu nie będzie potrzeby podawania loginu i hasła przy każdym uruchomieniu Eltena.

4. Podstawowe funkcje
Elten jest przede wszystkim siecią społecznościową. Najważniejsze jego funkcje odnajdziesz po otwarciu menu, klawiszem alt, w głównym oknie po zalogowaniu.
Podmenu społeczność to funkcje związane z, jak sama nazwa mówi, komunikacją z innymi osobami.
Odnajdziesz tutaj forum, blogi, jak i prywatne wiadomości.
Warto rozważyć wypełnienie swojego profilu w podmenu moje konto.
Możesz napisać coś o sobie w wizytówce.
Kolejne menu to media, w którym możesz odnaleźć materiały pokazywane przez innych użytkowników programu, jak i przeglądać portal youtube.
Pliki to prosty menedżer plików. Możesz tu przeglądać pliki tekstowe, odtwarzać muzykę bądź kopiować lub przenosić poszczególne dokumenty. Można stąd również zmienić swój awatar, czyli nagranie dostępne do odtworzenia z twojego menu profilu przez inne osoby. Możliwe również jest wysłanie jakiegoś pliku na serwer, dzięki czemu każdy inny użytkownik będzie miał możliwość pobrania danego dokumentu.
Programy to zbiór zewnętrznych aplikacji napisanych na silniku programu Elten.
Narzędzia zawierają opcje do zarządzania programem. Odnajdziesz tutaj konsolę programistyczną, test prędkości łącza. Z poziomu tego menu możesz utworzyć również nowy temat dźwiękowy czy zaktualizować program do najnowszej wersji.
Ustawienia, jak sama nazwa wskazuje, to różnego rodzaju opcje pozwalające na zmianę zachowania Eltena. warto pamiętać, że można między innymi skonfigurować program tak, by automatycznie ukrywał się w zasobniku systemowym po zminimalizowaniu okna.
Menu pomoc zawiera informacje o programie i jego użytkowaniu. Najważniejsza opcja to prawdopodobnie lista zmian między kolejnymi wersjami. Znajdziesz tutaj też listę skrótów klawiszowych czy opcję zgłoszenia błędu.
Ostatnie menu, wyjście, pozwala na zamknięcie lub ukrycie aplikacji.

5. Kontakt do autora
W razie jakichkolwiek pytań, uwag czy sugestii proszę o kontakt.
Mój nick na portalu Elten to pajper.
Mail: dawidpieper@o2.pl .
Wszelkie inne dane kontaktowe odnajdziesz w mojej wizytówce."
else
  text="Welcome in Elten!
This document contains some tips and information related to this application.

1. System requirements
Operating system: Windows XP or newer
RAM: 512MB
Processor: 800MHz
Harddrive: 256MB of free space
Internet access

2. Preliminary information
The author of the program is Dawid Pieper. It is open-source application, which code you can find in Github repository at:
http://github.com/dawidpieper/elten2
The details of licensing of this software are contained in a separated document.
Elten is a social network developed especially for the blind. It consists of a server, Internet web page, and above all, client designed for Windows.
In addition, it's API for developers writing programs for the blind.

3. Registration and login
Both registration and login menus can be accessed from the welcome window. Remember to choose an untypical password that outsiders are unable to access your account.
It is important to type a real email address, because it can be used to recover the forgot password.
After succesfull log in to your account you can enable automatic logon, so you will not need to enter a username and password each time you launch Elten.

4. Basic functions
Elten is primarily a social network. Its main functions can be accessed via menu available by pressing alt button in a main window, after login.
Menu called community, as it name says, contains functions used to communicate with other Elten users.
You cand find options such as forum, blogs or private messages here.
You should consider filling in your profile in submenu my account.
Also, you can write down something about you in your visitingcard.
The second menu is called Media. You can find materials shared by other people here, as well, as browse Youtube.
Files is a simple file manager. You can edit text files here, play music and, if you want, upload your avatar. Avatar is a sound record available for playing by other users in your profile menu. Also, you can upload some files to the server, so they'll be available for download by another Elten users.
Programs menu contains outside applications written in Elten API.
Tools is a submenu containing, as it name says, tools developed in order to manage Elten. You can test your Internet connection or access the console here, as well as generate new sound theme or update Elten to the newest version.
Settings contain different configuration options. You can consider for example automatical hiding of Elten window in a tray, this option can be found in interface settings.
Help menu includes documents related to the program usage. You can find changelog here, as well as keyboard shortcut list, license or this document. You can also report a bug via this menu.
The last menu, quit, allows you to hide or close the application.

5. Contact the author
In case of any questions, comments or suggestions, please contact me.
My nickname on Elten is pajper.
Mail: dawidpieper@o2.pl .
Any other contact information are provided in my visitingcard."
end
        input_text("Przeczytaj mnie","READONLY|ACCEPTESCAPE|MULTILINE",text)
    $scene = Scene_Main.new
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper