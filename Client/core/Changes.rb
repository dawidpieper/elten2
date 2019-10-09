#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Changes
  def main
    @changes = ["
Wersja 1.0:
Pierwsza wersja programu ELTEN

2014-08-24
","
Wersja 1.01:
- Poprawiono: zgłoszone błędy

2014-08-24
","
Wersja 1.02:
- Poprawiono: zgłoszone błędy

2014-08-24
","
Wersja 1.03:
- Dodano: statusy
- Dodano: opcja ukrycia programu w zasobniku systemowym w menu wyjście
- Zmieniono: Nowy silnik dźwięku: FMOD
- Zmieniono: interfejs programu
- Poprawiono: blogi już działają poprawnie
- Poprawiono: usunięto powodujący błędy GEM_SEAL
- Poprawiono: zachowywanie linii przy wysyłaniu tekstu na serwer
- Poprawiono: kilka innych błędów

2014-09-06
","
Wersja 1.04:
- Dodano: \"Użytkownicy, którzy dodali mnie do swoich kontaktów\"
- Zmieniono: nowy silnik przetwarzania ilości wpisów na forum
- Zmieniono: nowy silnik odczytu statusów
- Zmieniono: interfejs
- Poprawiono: błąd z informowaniem o nowych linijkach tekstu przez słowo LINE
- Poprawiono: błędy z buforowaniem linii i znaków w polach tekstowych
- Poprawiono: błąd z łączeniem wielu znaków w jedną tablicę w polach tekstowych
- Poprawiono: Jeśli nie uda się połączyć z serwerem Youtube, nastąpi próba aktualizacji biblioteki Youtube-DL
- Poprawiono: wiele błędów powodujących zawieszenie się programu, w wypadku zawieszenia, program powtarza wykonywaną klasę

2014-10-19
","
Wersja 1.05:
- Dodano: bufory pozwalające na pisanie dłuższych wpisów na forum, wiadomości i wizytówek
- Poprawiono: stabilność programu
- Zmieniono: interfejs
- Dodano: lista blogów
- Dodano: raportowanie błędów
- Dodano: aktualizacja wersji językowych razem z programem - od kolejnych aktualizacji
- Poprawiono: przepisanie systemu list wyboru
- Poprawiono: przetwarzanie znaków ' oraz `
- Poprawiono: przelogowywanie użytkownika po wygaśnięciu tokenu
- Poprawiono: silnik zamiany wyrażeń nieregularnych przy językach obcych
- Zmieniono: ograniczenie list wyboru - z ostatniego pola nie przechodzi się do pierwszego
- Dodano: możliwość ukrycia programu w zasobniku z menu zamykania programu
- Zmieniono: forum jest drzewem - zapamiętuje zaznaczone wątki i fora oraz pozwala na przemieszczanie się strzałkami lewo-prawo tak, jak klawiszami enter i escape

2014-11-28
","
Wersja 1.06:
- Poprawiono: stabilność programu
- Zmieniono: Nowy system pól tekstowych
- Zmieniono: System przesyłania danych binarnych
- Zmieniono: Zaimplementowana biblioteka WINSOCK
- Dodano: Obsługa bezpośredniego połączenia z serwerami
- Dodano: Obsługa bezpośredniego przekazywania zapytań HTTP
- Dodano: Obsługa bezpośredniego przesyłania buforów
- Dodano: Obsługa specjalnych zdarzeń
- Poprawiono: kilka mniejszych błędów

2014-12-23
","
Wersja 1.07:
- Poprawiono: kilka błędów

2014-12-24
","
Wersja 1.08:
- Dodano: Możliwość zaznaczania tekstu w polach tekstowych poprzez przytrzymanie klawisza shift i poruszanie kursorem lub całego tekstu skrótem CTRL+A
- Dodano: Obsługa schowka poprzez skróty CTRL+X, CTRL+C i CTRL+V
- Dodano: Możliwość tłumaczenia zaznaczonego tekstu na ustawiony w programie język skrótem CTRL+T
- Poprawiono: błędy występujące w polach tekstowych
- Poprawiono: algorytm tworzenia nowych wierszy w polach tekstowych
- Dodano: formularze przy wysyłaniu wpisów na blogi, wiadomości i postów na forum
- Zmieniono: Nowy interfejs wiadomości
- Dodano: Możliwość wyboru kontaktu przy wysyłaniu wiadomości poprzez wciśnięcie strzałki w górę lub w duł w polu \"Odbiorca\"
- Zmieniono: interfejs
- Poprawiono: Buforyzację wpisów na blogach
- Poprawiono: błąd konwersji znaków w polach tekstowych
- Poprawiono: odczyt tablic w polach tekstowych
- Poprawiono: przesyłanie pustych ciągów znakowych

2014-12-31
","
Wersja 1.09:
- Zmieniono: Formularze deklarowane przez klasy, nie pisane ręcznie dla każdej funkcji
- Dodano: Nowe dźwięki
- Zmieniono: interfejs
- Dodano: Dodatkowe dane w wizytówkach
- Zmieniono: Nowe moduły przetwarzania danych
- Zmieniono: Drobne zmiany

2015-01-29
","
Wersja 1.091:
- Poprawiono: kilka zgłoszonych błędów

2015-01-29
","
Wersja 1.092:
- Poprawiono: kilka zgłoszonych błędów

2015-02-07
","
Wersja 1.093:
- Poprawiono: kilka zgłoszonych błędów

2015-02-13
","
Wersja 1.1:
,- Zmieniono: inna metoda przetwarzania modułów i inny sposób zapisu danych, jak i nowe metody szyfrowania
ZMieniono: Nowy system \"Co nowego\"
- Zmieniono: skróty klawiszowe
- Dodano: lista skrótów klawiszowych
- Zmieniono: Lista użytkowników dostępna dla wszystkich
- Dodano: obsługa usuwania kategorii i wpisów na blogach
- Dodano: Wstępna wersja katalogu mediów
- Dodano: Nowa kontrolka: pole wyboru
- Dodano: nowa kategoria menu: \"Narzędzia\"
- Dodano: generator tematów dźwiękowych
- Zmieniono: Nowe metody przetwarzania danych w \"Plikach\"
- Zmieniono: Nowy sposób dodawania programów: są pobierane bezpośrednio z serwera przy starcie programu
- Zmieniono: Biblioteka elten.dll zaktualizowana do nowej wersji zawierającej kilka poprawek
- Dodano: Automatyczne wyciszanie głosu screenreaderów: NVDA, Jaws'a i WindowEyes'a
- Dodano: Opcja \"Rada starszych\" pokazująca listę osób zarządzających programem
- Zmieniono: Znaczne zmiany na forum, zwłaszcza w przeglądzie wątków
- Zmieniono: Udoskonalony system raportowania błędów
- Dodano: Nowe ustawienia interfejsu pozwalające na zmianę echa pisania, czułości klawiatury, wyciszenie dźwięków, sposobu wyświetlania list wyboru i metody startu programu
- Dodano: Obsługa nowych zdarzeń
- Dodano: Nowe dźwięki
- Zmieniono: Różne mniejsze i większe zmiany w interfejsie i funkcjach
- Poprawiono: błąd z wysyłaniem wiadomości na chacie
- Poprawiono: błąd z dublowaniem się informacji o literach przy niektórych konfiguracjach screenreaderów
- Poprawiono: błąd z zaznaczaniem tekstu

2015-03-28
","
Wersja 1.11:
- Poprawiono: zgłoszone błędy

2015-03-29
","
Wersja 1.12:
- Poprawiono: zgłoszone błędy

2015-03-29
","
Wersja 1.13:
- Poprawiono: zgłoszone błędy

2015-04-30
","
Wersja 1.14:
- Zmieniono: nowa metoda kodowania wiadomości między serwerem a klientem (dotyczy forum, wiadomości, blogów, programów i mediów) (te działy dla starszych wersji nie będą więcej wspierane)
- Zmieniono: zaktualizowany protokuł tłumacza do najnowszej wersji Google Translatora
- Poprawiono: zgłoszone błędy

2015-05-08
","
Wersja 1.15:
- Dodano: nowe skróty klawiszowe w forum
- Dodano: informacja we wpisie o jego numerze i numerze w wątku
- Zmieniono: drobne zmiany w interfejsie
- Zmieniono: nowa metoda buforyzacji
- Poprawiono: zgłoszone błędy

2015-05-21
","
Wersja 1.16:
- Poprawiono: zgłoszone błędy

2015-05-27
","
Wersja 1.2:
- Dodano: Opcja testu prędkości łącza
- Dodano: Obsługa protokołu https przy większości połączeń
- Zmieniono: Zmiany w systemie połączeń
- Dodano: Aktualizator w menu
- Dodano: Zmiany w ustawieniach domyślnych
- Dodano: tryb awaryjny
- Poprawiono: zgłoszone błędy

2015-06-20
","
Wersja 1.21:
- Dodano: komentarze na blogach
- Poprawiono: zgłoszone błędy

2015-08-08
","
Wersja 1.22:
- Poprawiono: zgłoszone błędy

2015-08-10
","
Wersja 1.3:
- Dodano: zupełnie nowy agent programu odpowiedzialny za podtrzymywanie tokenu i odbieranie wiadomości
- Zmieniono: z zasobnika można powrócić skrótem CTRL+ALT+SHIFT+E
- Dodano: obsługa nowych skrótów w polach tekstowych: page up, page down, ctrl+home i ctrl+end
- Dodano: zawijanie wierszy
- Zmieniono: drobne zmiany w systemie logowania
- Dodano: playlista
- Dodano: wiadomości wysłane
- Dodano: Możliwość zmiany nazwy bloga i edycji wpisów na nim
- Zmieniono: Drobniejsze zmiany w interfejsie
- Zmieniono: Nowy system aktualizacji i instalacji
- Zmieniono: Nowa procedura uruchamiania programu
- Poprawiono: zgłoszone błędy

2015-08-24
","
Wersja 1.31:
- Poprawiono: zgłoszone błędy
- Zmieniono: drobne zmiany w interfejsie

2015-08-24
","
Wersja 1.32:
- Poprawiono: zgłoszone błędy
- Zmieniono: nowa procedura sprawdzania śledzonych wątków przez \"Co nowego\"
- Zmieniono: API Translatora zaktualizowane do nowej wersji
- Dodano: obsługa wielu aktywnych scen jednocześnie
- Dodano: dwa kolejne wątki odpowiedzialne za wykrywanie pojawiania się zapisów nowych scen oraz za otwieranie tych scen
- Zmieniono: Nowe metody inicjacji pól tekstowych oraz zdalne ich oznaczanie
- Zmieniono: system ładowania wątków

2015-08-29
","
Wersja 1.33:
- Poprawiono: zgłoszone błędy

2015-08-29
","
Wersja 1.34:
- Poprawiono: zgłoszone błędy

2015-08-31
","
Wersja 1.35:
- Zmieniono: zmiany w interfejsie
- Zmieniono: Nowy instalator i aktualizator
- Poprawiono: zgłoszone błędy

2015-09-06
","
Wersja 1.36:
- Poprawiono: zgłoszone błędy

2015-09-06
","
Wersja 1.37:
- Zmieniono: procedura startu programu
- Dodano: obsługa wykonywania operacji w trakcie mowy
- Dodano: opcja cofania i powtarzania ostatnio cofniętej rzeczy w polach tekstowych
- Zmieniono: Drobniejsze zmiany w interfejsie
- Poprawiono: zgłoszone błędy

2015-09-22
","
Wersja 1.38:
- Poprawiono: zgłoszone błędy

2015-09-22
","
Wersja 1.39:
- Dodano: kompilator dla projektów EAPI
- Zmieniono: Drobne zmiany w interfejsie
- Poprawiono: zgłoszone błędy

2015-11-20
","
Wersja 1.391:
- Dodano: nowy sposób przetwarzania audio przez odtwarzacz
- Dodano: przewijanie utworów
- Poprawiono: media

2015-11-27
","
Wersja 1.392:
- Poprawiono: agent programu
- Dodano: druga wersja kompilacji biblioteki Elten.dll - w programie Visual Studio
- Zmieniono: Dobór odpowiedniej biblioteki odbywa się w zależności od możliwości komputera
- Dodano: Przetwarzanie nowych zdarzeń
- Zmieniono: Drobne zmiany w interfejsie

2015-12-23
","
Wersja 1.393:
- Dodano: strumieniowanie danych z Internetu i obsługa radiów internetowych
- Poprawiono: zgłoszone błędy

2015-12-25
","
Wersja 1.394:
- Poprawiono: zgłoszone błędy

2016-03-08
","
Wersja 1.395:
- Poprawiono: zgłoszone błędy

2016-07-22
","
Wersja 1.396:
- Poprawiono: zgłoszone błędy

2016-07-22
","
Wersja 1.397:
- Dodano: możliwość aktualizacji do wersji beta
- Dodano: możliwość kopiowania treści komunikatów błędów do schowka

2016-09-09
","
Wersja 1.398:
- Poprawiono: zgłoszone błędy

2016-11-19
","
Wersja 1.399:
- Zmieniono: Zmiany pozwalające na aktualizację do przyszłej wersji 2.0

2016-12-22
","
Wersja 1.3991:
- Zmieniono: aktualizacja protokołu buforów

2017-03-24
","
Wersja 1.3992:
- Poprawiono: przetwarzanie polskich znaków w nazwach folderów systemowych

2017-03-26
","
Wersja 1.3993:
- Poprawiono: system komunikacji z serwerem

2017-03-27
","
Wersja 1.3994:
- Poprawiono: obsługa polskich znaków w nazwach użytkowników

2017-03-27
","
Wersja 2.0
- Dodano: awatary
- Dodano: obsługa youtube
- Dodano: profile
- Dodano: Rozszerzone wizytówki
- Zmieniono: silnik blogów
- Dodano: fora, wiadomości i blogowe wpisy głosowe
- Zmieniono: podział forów
- Dodano: opcja przeszukiwania forów
- Dodano: pliki udostępniane
- Dodano: sygnatury
- Dodano: wiadomości powitalne
- Dodano: Rozszerzony menedżer plików
- Dodano: ankiety
- Dodano: Nowe ustawienia
- Dodano: Nowe dźwięki
- Dodano: język niemiecki
- Zmieniono: Przepisany silnik plików
- Zmieniono: Przepisany silnik pól tekstowych
- Zmieniono: Przepisany silnik forów
- Zmieniono: Nowe protokoły komunikacji z serwerem
- Dodano: Nowy tłumacz
- Dodano: Nowy odtwarzacz mediów
- Zmieniono: Nowa budowa Elten core
- Dodano: Nowe funkcje Elten API
- Zmieniono: Nowy system aktualizacji
- Zmieniono: Nowy agent
- Zmieniono: Zmiany w interfejsie
- Dodano: Resetowanie hasła
- Dodano: Odznaczenia
- Poprawiono: Ogólna poprawa wydajności
- Poprawiono: obsługa capslocka
- Poprawiono: obsługa klawiatury numerycznej
- Poprawiono: problemy z polskimi znakami w plikach
- Poprawiono: problemy z polskimi znakami w nazwie użytkownika
- Poprawiono: błąd z gubieniem sesji przy utracie połączenia Internetowego
- Poprawiono: problem z zamykaniem się okna Eltena w wypadku zwieszenia
- Poprawiono: problem z brakiem stabilności przy używaniu programu Window Eyes
- Poprawiono: Zawieszające się okno przy pisaniu długich tekstów

2017-08-24
","
Wersja 2.01:
- Dodano: skrót do otwarcia pliku lub folderu w eksploratorze w plikach, CTRL+O
- Poprawiono: błąd przy minimalizowaniu do traya z menu
- Poprawiono: błąd z usuwaniem plików udostępnionych
- Dodano: przytrzymywanie strzałki przesuwa kursor

2017-08-25
","
Wersja 2.02:
- Poprawiono: błąd z odtwarzaniem plików zawierających podwójne spacje
- Poprawiono: błąd z odtwarzaniem plików zawierających wiele polskich znaków
- Dodano: skróty klawiszowe na kopiowanie, wycinanie oraz wklejanie w plikach
- Dodano: Skrót CTRL+D do sprawdzania zawartości folderu w plikach
- Dodano: Skrót CTRL+I do sprawdzania rozmiaru w plikach
- Dodano: opcja tworzenia nagrań głosowych w plikach
- Zmieniono: od teraz możliwe jest kopiowanie i przenoszenie folderów
- Dodano: skróty do folderów dokumenty, muzyka oraz pulpitu w plikach
- Dodano: możliwość konwersji audio w plikach
- Poprawiono: błąd z pomijaniem niektórych plików przez playlisty
- Poprawiono: błąd z niemożnością aktualizacji programu w wypadku ustawionego autostartu
- Poprawiono: błąd z otwieraniem wielu instancji Eltena przy autostarcie
- Zmieniono: od teraz wszystkie nagrania wykonywane są w stereo, o ile karta dźwiękowa oraz mikrofon obsługują ten format

2017-08-26
","
Wersja 2.03:
- Dodano: możliwość eksportowania plików i tekstu do plików, obsługuje tylko sapi
- Dodano: skrót CTRL+P w polach tekstowych do eksportu tekstu do  pliku

2017-08-27
","
Wersja 2.031:
- Poprawiono: błąd podczas czytania do pliku z opcją dzielenia akapitami bądź tworzenia pojedynczego pliku

2017-08-28
","
Wersja 2.04:
- Dodano: możliwość wyboru formatu pobierania treści z YouTube
- Dodano: nowe dźwięki
- Zmieniono: treści z YouTube nie są już buforowane
- Poprawiono: Błąd uniemożliwiający eksport niektórych plików
- Poprawiono: błąd uniemożliwiający uruchomienie Eltena w przypadku ustawionego autostartu

2017-08-28
","
Wersja 2.041:
- Dodano: pasek postępu na YouTube
- Poprawiono: eksport mowy do pliku
- Poprawiono: dźwięki w plikach

2017-08-29
","
Wersja 2.042:
- Dodano: możliwość zapisu wpisów i wiadomości głosowych (skrót CTRL+S)
- Dodano: Możliwość zapisywania awatarów (podczas odtwarzania skrót SHIFT+ENTER)
- Poprawiono: błąd z eksportem tekstu do pliku
- Poprawiono: błąd odtwarzania na youtube
- Poprawiono: błąd uniemożliwiający uruchamianie programu przy jego instalacji w wersji powyżej 2.0

2017-08-31
","
Wersja 2.043:
- Poprawiono: Odtwarzanie filmów z Youtube
- Poprawiono: pobieranie plików z youtube
- Poprawiono: zapis mowy do pliku

2017-09-04
","
Wersja 2.1:
- Dodano: obsługa wysyłania i odbierania maili (każdy użytkownik otrzymał adres E-mail \"login@elten-net.eu\", na który można wysyłać wiadomości odbierane na Eltenie, jak również który będzie podany jako adres nadawcy przy wysyłaniu wiadomości E-mail poza Eltena)
- Dodano: możliwość wysyłania załączników (do trzech w jednej wiadomości, maksymalnie 16MB na załącznik) (dotyczy zarówno wiadomości prywatnych, jak i maili)
- Zmieniono: przywrócone wsparcie dla Google Translate, który będzie preferowanym tłumaczem, jeśli będzie niedostępny, Elten spróbuje użyć tłumacza Yandex
- Dodano: opcja rozpakowywania i pakowania plików (obsługiwane formaty: zip, rar, 7zip)
- Zmieniono: system aktualizacji
- Dodano: paski postępu przy pobieraniu większych plików
- Dodano: obsługa nowych formatów audio
- Dodano: zegary i alarmy
- Dodano: nowe ustawienia
- Dodano: przeszukiwanie pól tekstowych pod skrótem CTRL+F
- Zmieniono: struktura ustawień
- Zmieniono: grupowanie elementów w menu Społeczność
- Zmieniono: skrót cytowania postów to od teraz CTRL+D
- Zmieniono: w głównym oknie pod tabulatorem dostępnych jest kilka opcji do zarządzania playlistą
- Dodano: informowanie, kto jest online, na listach użytkowników
- Dodano: możliwość przewijania wpisów głosowych klawiszem f4
- Dodano: możliwość otwarcia menu programu z dowolnego miejsca kombinacją SHIFT+F2
- Poprawiono: problem z odtwarzaniem YouTube na starszych systemach
- Poprawiono: błąd z wcinaniem się powiadomień w czytany tekst
- Poprawiono: skróty w menu

2017-10-28
","
Wersja 2.11:
- Dodano: możliwość eksportu wersji przenośnej do jednego pliku exe (SFX) (utrata możliwości zapisu ustawień)
- Dodano: z poziomu menu pod klawiszem alt w plikach udostępnionych można skopiować link do konkretnego pliku, który następnie można wykorzystać na przykład w przeglądarce Internetowej
- Zmieniono: od tej pory zbanowani użytkownicy mogą się logować, nie mogą jednak pisać na forum ani używać chatu
- Zmieniono: system zarządzania banami

2017-10-30
","
Wersja 2.12:
- Dodano: Elten APi zawiera teraz drzewo jako programowalną kontrolkę
- Zmieniono: wygląd menu w menedżerze plików
- Poprawiono: błąd przy próbie otwarcia pustego folderu w plikach
- Poprawiono: błędy związane z tłumaczeniami
- Poprawiono: sporadyczny błąd występujący przy ładowaniu listy wyników na YouTube
- Poprawiono: nie można już wysyłać folderów na serwer, poprzednio też było to niemożliwe, ale opcja była dostępna w menu powodując błędy
- Poprawiono: od teraz poprawnie usuwane są foldery z plikami zawierającymi polskie znaki
- Poprawiono: wycinanie folderów działa już jak przenoszenie, nie zaś kopiowanie

2017-11-01
","
Wersja 2.13:
- Dodano: konto gościa
- Dodano: szukanie użytkowników
- Dodano; ostatnio aktywni użytkownicy
- Dodano: ostatnio zarejestrowani użytkownicy
- Zmieniono: od teraz przy wysyłaniu wiadomości i dodawaniu kontaktów program nie informuję o nieistnieniu danego użytkownika, gdy nie zgadza się wielkość liter w loginie
- Poprawiono: zamknięcie menu w plikach udostępnionych otwierało dialog usuwania pliku

2017-11-05
","
Wersja 2.14:
- Dodano: możliwość przeglądania oraz czytania do pliku dokumentów w formatach doc, pdf, epub, mobi, html, rtf
- Dodano: tryb debugowania
- Dodano: lista skrótów klawiszowych pod klawiszem F1
- Dodano: możliwość szybkiego przełączenia wyjścia mowy na czytnik ekranu skrótem SHIFT+F1
- Dodano: nowe dźwięki
- Zmieniono: zaktualizowana biblioteka Elten API (elten.dll)
- Zmieniono: menu w plikach udostępnionych
- Usunięto: nieużywane biblioteki i zależności
- Poprawiono: błąd uniemożliwiający edycję niektórych plików txt
- Poprawiono: menu w plikach udostępnionych otwiera się już normalnie
- Poprawiono: problem uniemożliwiający połączenie z serwerem na niektórych konfiguracjach
- Poprawiono: błąd pozwalający na otwarcie menu w menu
- Poprawiono: optymalizacja kodu

2017-11-10
","
Wersja 2.15:
- Dodano: skrót CTRL+D na pliku dźwiękowy podaje jego długość
- Dodano: Spacja na wyniku wyszukiwania w Youtube podaje jego długość
- Zmieniono: nowa, szybsza procedura wyszukiwania plików audio
- Poprawiono: czytanie do pliku z poziomu menedżera plików działa już poprawnie
- Poprawiono: możliwe jest wybranie obsługi czytnika ekranu z poziomu głównego okna
- Poprawiono: menedżer plików nie wysypuje się już przy folderach zawierających wiele plików
- Poprawiono: drobne poprawki przy odczytywanych komunikatach na forum

2017-11-11
","
Wersja 2.16:
Poprawiono: stabilność
Zaktualizowano: protokół połączenia z serwerem

2017-11-26
","
Wersja 2.17:
- Poprawiono: obsługa przekierowań

2017-12-06
","
Wersja 2.18:
- Poprawiono: protokół połączenia z serwerem
- Poprawiono: zmiany pozwalające na zwiększenie płynności działania
- Zmieniono: system logowania zaktualizowany do wersji z gałęzi beta Eltena 2.2
- Zmieniono: agent zaktualizowany do wersji z gałęzi beta Eltena 2.2 (wyłączywszy nowe powiadomienia)
- Zmieniono: aktualizacja zewnętrznych bibliotek do wersji najnowszych na dzień 1 stycznia 2018

2018-01-03
","
Wersja 2.181:
- Poprawiono: system logowania
- Poprawiono: błąd powodujący krytyczne przerwanie pracy agenta przy przerwaniu połączenia z serwerem

2018-01-06
","
Wersja 2.2:
- Zmieniono: zupełnie nowy silnik audio obsługujący więcej formatów
- Zmieniono: przepisane interfejsy przetwarzania forum i wiadomości
- Zmieniono: przepisany system obsługi klawiatury
- Zmieniono: interfejs menu
- Dodano: wzmianki
- Dodano: ustawienia co nowego
- Dodano: nowe elementy co nowego: nowe wpisy i wątki na śledzonych forach, urodziny znajomych, wzmianki oraz znajomości
- Dodano: śledzone fora
- Dodano: możliwość ukrywania wpisów na blogach przed niezalogowanymi użytkownikami oraz edycji wpisów audio
- Zmieniono: aktualizacja systemu logowania
- Dodano: zarządzanie utworzonymi kluczami automatycznego logowania
- Dodano: nowe skróty w odtwarzaczu plików
- Poprawiono: błąd z wyświetlaniem niektórych folderów w plikach i odtwarzaniem niektórych plików
- Dodano: szczegóły na Youtube pod klawiszem tab
- Dodano: czarna lista
- Poprawiono: problem z odtwarzaniem niektórych formatów plików
- Poprawiono: problemy ze stabilnością programu
- Poprawiono: długi czas ładowania paczek językowych
- Zmieniono: nowa procedura resetowania hasła

2018-02-24
","
Wersja 2.21:
- Poprawiono: problem z otwieraniem menu w wiadomościach przy pustej skrzynce odbiorczej
- Poprawiono: problem uniemożliwiający edycję pierwszego wpisu na blogu
- Poprawiono: problem z wyłączającym się automatycznym logowaniem
- Poprawiono: problem z wczytywaniem kursora w polach edycji
- Poprawiono: dokumenty w menu pomoc powinny już wyświetlać się poprawnie

2018-02-26
","
Wersja 2.22:
- Zmieniono: przepisanie systemu pól tekstowych od podstaw
- Zmieniono: obsługa odtwarzania plików midi
- Poprawiono: błąd uniemożliwiający ustawienie prywatności podczas tworzenia wpisów audio na blogu
- Poprawiono: błąd powodujący wysyłanie powiadomień o wylogowaniu na czacie nawet, gdy czat nie był otwarty
- Dodano: oznaczenie dźwiękowe forów zawierających nieprzeczytane wpisy
- Dodano: możliwość oznaczenia forum jako przeczytane

2018-03-24
","
Wersja 2.221:
- Poprawiono: menu na pustej liście śledzonych forów działa już poprawnie
- Poprawiono: przy wciśnięciu ALT+F4 nie resetuje się już głośność tematu dźwiękowego
- Poprawiono: od teraz wciśnięcie litery na liście plików pustego folderu nie powoduje błędu
- Zmieniono: przy tworzeniu nowych plików i folderów nie jest wpisana w polu nazwy domyślna nazwa

2018-03-28
","
Wersja 2.222:
- Poprawiono: w jednoliniowych polach tekstowych długie wiersze nie są już zawijane
- Poprawiono: w polach numerycznych nie można wprowadzać już liter
- Poprawiono: skrypty Elten API działają poprawnie
- Dodano: możliwość wyłączenia zawijania wierszy
- Dodano: możliwość oznaczania wszystkich wpisów na blogu jako przeczytane

2018-03-31
","
Wersja 2.223:
- Poprawiono: pobieranie uprzednio zbuforowanych filmów na Youtube nie powoduje już krytycznego wyjątku
- Zmieniono: sposób zapisywania informacji o wersji

2018-04-11
","
Wersja 2.224:
- Poprawiono: otwarcie menu na pozycji \"załaduj więcej wiadomości\" nie powoduje już krytycznego błędu
- Poprawiono: tło w oknach dialogowych respektuje głośność tematu dźwiękowego

2018-04-16
","
Wersja 2.23:
- Dodano: nowy format do konwersji audio - opus
- Dodano: przy odtwarzaniu plików udostępnianych obsługiwane jest teraz strumieniowanie formatów OPUS, AAC oraz WMA
- Zmieniono: od teraz wątki głosowe mają tytuły tekstowe
- Zmieniono: przy przeszukiwaniu pól tekstowych nie jest brana pod uwagę wielkość liter
- Zmieniono: przy odtwarzaniu mediów zwiększono zakres zmian częstotliwości
- Poprawiono: otwarcie menu użytkownika z listy blogów nie powoduje już krytycznego błędu
- Poprawiono: zamknięcie okna dialogowego zapisu strumienia nie zamyka całego kontekstu
- Poprawiono: przy odtwarzaniu wpisów głosowych klawiszem F4 jest już poprawnie przetwarzana treść tekstowa
- Poprawiono: menu na liście blogów nie powinno już powodować krytycznych wyjątków przy otwieraniu danego bloga
- Poprawiono: wciśnięcie klawisza enter na pustej liście udostępnionych plików nie powoduje już błędu
- Poprawiono: po wciśnięciu klawisza delete na blogu innego użytkownika pojawiało się pytanie o usunięcie wpisu, po potwierdzeniu Elten wywoływał krytyczny wyjątek

2018-04-23
","
Wersja 2.24:
- ZMieniono: od tej pory audio na serwerze zapisywane jest w formacie OPUS
- Zmieniono: maksymalna długość wpisów na blogach od tej pory wynosi jedną godzinę
- Zmieniono: aktualizacja biblioteki kodeków do wersji najnowszej na dzień 29 kwietnia 2018
- Poprawiono: przewijanie tekstu poprzez przytrzymywanie strzałki w lewo już działa poprawnie
- Poprawiono: lepsze wsparcie dla strumieniowania kodeka OPUS

2018-04-29
","
Wersja 2.241:
- Poprawiono: lepsza obsługa strumieniowania audio

2018-04-30
","
Wersja 2.242:
- Poprawiono: do poprzedniej kompilacji przypadkowo dołączone zostały 64-bitowe wersje kodeków, co uniemożliwiło wysyłanie audio na serwer z komputerów z zainstalowanymi 32-bitowymi systemami operacyjnymi

2018-04-30","
Wersja 2.243:
- Poprawiono: lepsza obsługa strumieniowania audio przy wolniejszym łączu Internetowym

2018-05-03
","
Wersja 2.25:
- Dodano: możliwość przesuwania wpisów przez moderatorów
- Poprawiono: wiersze są już poprawnie zawijane w dłuższych polach tekstowych
- Poprawiono: edycja notatek już działa poprawnie
- Zmieniono: biblioteka kodeka opus zaktualizowana do najnowszej wersji

2018-06-17
","
Wersja 2.26:
- Poprawiono: klawisze page up i page down w polach tekstowych działają już poprawnie
- Poprawiono: podczas wyszukiwania tekstów w polach tekstowych działa już klawisz escape
- Poprawiono: na zakładce głównej forum menu już działa poprawnie
- Poprawiono: polskie diakretyki są już poprawnie odczytywane na liście wyboru syntezatora mowy

2018-06-17
","
Wersja 2.27:
- Poprawiono: problem z pustym \"co nowego\", gdy dostępna jest aktualizacja w gałęzi beta
- Poprawiono: agent poprawnie odczytuje konfigurację w wersjach beta
- Zmieniono: aktualizacja bibliotek do najnowszych na dzień 24.07.2018
- Zmieniono: usunięto zbędne już biblioteki
- Dodano: ignorowanie nowych znaczników w polach tekstowych w celu zgodności z przyszłymi wersjami Eltena
- Poprawiono: podczas rejestracji dodano informację przy nieobsługiwanych znakach

2018-07-26
","
Wersja 2.271:
- Poprawiono: do poprzedniego wydania dołączona została omyłkowo stara wersja agenta
- Poprawiono: system aktualizacji poprawnie rozpoznaje już nowe wydania stabilne, gdy dostępna jest gałąź beta

2018-07-26
","
Wersja 2.28:
- Dodano: obsługa uwierzytelniania dwuetapowego (SMS)

2018-07-30
","
Wersja 2.281:
- Zmieniono: aktualizacja obsługi Youtube

2018-09-08
","
Wersja 2.282:
- Poprawiono: problem w wyniku którego Elten nie zamykał uchwytów plików przy ich analizie, co uniemożliwiało edycję plików na przykład załączanych dowiadomości do momentu zamknięcia programu

2018-09-25
","
Wersja 2.283:
- Poprawiono: system detekcji woluminów przy menu wyboru plików
- ZMieniono: drobne zmiany w domyślnym temacie dźwiękowym

2018-10-21
","
Wersja 2.284:
- Zmieniono: aktualizacja Youtube-DL
- Poprawiono: obsługa aktualizacji do wersji beta

2018-11-08
","
Wersja 2.285:
- Zmieniono: aktualizacja protokołów połączeń z serwerem

2019-03-09
","
Wersja 2.3:
- Dodano: grupy
- Dodano: pięć nowych języków: hiszpański, francuski, horwacki, portugalski i rosyjski
- Dodano: możliwość załączania plików i ankiet na forum
- Dodano: nowe narzędzia moderatorskie
- Dodano: na blogach linki do serwisu Youtube są automatycznie wykrywane i możliwe jest ich odtworzenie z poziomu programu
- Dodano: wsparcie dla unikodu
- Usunięto: katalog mediów
- Usunięto: Kompilator Elten API
- Zmieniono: tłumaczenia od tej pory wykorzystują system kluczy zamiast słownika
- Zmieniono: wiadomości wyświetlane są od teraz w podziale na korespondentów i tematy oraz automatycznie odświeżane
- Zmieniono: powiadomienia zawierają od tej pory szczegółowe informację i różnią się dźwiękiem zależnie od przyczyny wysłania
- Zmieniono: nowy układ menu głównego
- Zmieniono: drobne modyfikacje interfejsu
- Zmieniono: agent programu został przepisany
- Zmieniono: w komunikacji z serwerem od tej pory wykorzystywany jest protokół HTTP w wersji 2.0
- Zmieniono: nowa metoda uwierzytelniania klienta
- Zmieniono: aktualizacja bibliotek
- Poprawiono: tłumaczenie nie wpływa już na wpisywany tekst
- Poprawiono: przy problemie komunikacji z serwerem Elten już się nie zawiesza
- Poprawiono: JSON jest już parsowany poprawnie

2019-08-24
","
Wersja 2.31:
- Dodano: lista ostatnio utworzonych grup
- Dodano: możliwość wyboru karty dźwiękowej
- Zmieniono: przy odczycie książek używana jest od tej pory biblioteka Calibre
- Zmieniono: nowy interfejs testu łącza
- Poprawiono: lista tematów dźwiękowych do pobrania jest już wyświetlana poprawnie
- Poprawiono: ponownie możliwe jest cytowanie wpisów
- Poprawiono: Elten poprawnie odczytuje informacje o dostępnych aktualizacjach
- Poprawiono: agent nie zwraca wyjątku, gdy nie udaje się odtworzyć dźwięku powiadomienia
- Poprawiono: Czytanie do pliku działa już poprawnie
- Poprawiono: zapamiętywana jest główna kolumna wybrana na listach w zakładce forum
- Poprawiono: menu poprawnie przetwarza skróty klawiszowe przy szybkim wciśnięciu klawiszy
- Poprawiono: Elten nie przełącza już domyślnie języka na angielski po aktualizacji, gdy poprzednio nie wybrano żadnego języka
- Poprawiono: opisy forów są już poprawnie odczytywane
- Poprawiono: kursor nie przeskakuje już do pustych kolumn przy nawigacji po tabelach
- Poprawiono: Co nowego ponownie zamyka się, gdy nie ma żadnych więcej oczekujących zdarzeń
- Poprawiono: unifikacja obsługi audio

2019-08-26
","
Wersja 2.32:
- Dodano: możliwość wyboru mikrofonu
- Zmieniono: nowe okno z informacjami o wersji programu
- Zmieniono: od tej pory nagrywane dźwięki są kodowane w locie do formatu Opus
- Zmieniono: wczytywanie forum wymaga mniejszej liczby zapytań do serwera
- Zmieniono: aktualizacja bibliotek
- Poprawiono: wciśnięcie entera podczas pisania pierwszego komentarza na blogu nie powoduje już wyjątku krytycznego
- Poprawiono: wyświetlanie starszych wiadomości działa już poprawnie
- Poprawiono: obsługa kolejkowania zapytań do serwera

2019-09-10
","
Wersja 2.33:
- Dodano: lista wątków i grup popularnych wśród znajomych
- Dodano: lista blogów popularnych wśród znajomych
- Dodano: możliwość wyłączania komentarzy pod określonymi wpisami na blogach

2019-09-14
","
Wersja 2.34:
- Dodano: możliwość zmiany typu wpisu na blogu
- Dodano: historia logowań
- Dodano: możliwość ustawienia raportowania zmian na koncie i nieznanych logowań poprzez wiadomości E-mail
- Dodano: możliwość przeglądania listy osób śledzących naszego bloga
- Dodano: możliwość tworzenia blogów współdzielonych z innymi użytkownikami
- Dodano: lista moderowanych grup
- Zmieniono: od tej pory wizytówka, sygnatura oraz status są ustawiane we wspólnej edycji profilu
- Zmieniono: nowy system wyboru lokalizacji użytkownika
- Zmieniono: kolejne elementy interfejsu są tabelami
- Poprawiono: przełączanie karty dźwiękowej przy wyłączonym temacie dźwiękowym
- Poprawiono: wykrywanie domyślnego mikrofonu
- Usunięto: pliki udostępniane

2019-09-27
","
Wersja 2.341:
- Dodano: możliwość przenoszenia wpisów między blogami
- Poprawiono: menu na liście blogów

2019-09-28","
Wersja 2.342:
- Dodano: możliwość przypinania wątków
- Dodano (eksperymentalnie): na listach klawisz F4 podaje numer wybranej pozycji oraz rozmiar listy

2019-10-01
"]
@changes.reverse!
@changes.each{|c| c.gsub!(/Wersja (\d\.\d+)/) {"Wersja "+$1.delete(".").split("").join(".")}}
@selt = []
for i in 0..@changes.size - 1
  @selt.push(strbyline(@changes[i])[1].delete(":").sub("Wersja ",""))
  end
@sel = Select.new(@selt,true,0,_("Changes:head"))
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape
        $scene = Scene_Main.new
  end
  if enter
    input_text(@selt[@sel.index],"READONLY|ACCEPTESCAPE",@changes[@sel.index][1..@changes[@sel.index].size-1])
    @sel.focus
    end
    end
end
#Copyright (C) 2014-2019 Dawid Pieper