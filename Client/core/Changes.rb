#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
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
    Poprawki
    
    2014-08-24
    
    ","
        Wersja 1.02:
    Poprawki
    
    2014-08-24
    
    ","
    Wersja 1.03:
    Zmiany:
    Dodano statusy
    Dodano opcję ukrycia programu w zasobniku systemowym w menu wyjście
    Nowy silnik dźwięku: FMOD
    Kilka drobnych zmian
   
    Najważniejsze poprawki:
    Blogi już działają poprawnie
    Usunięto GEM_SEAL
    Zachowywanie linii przy wysyłaniu tekstu na serwer
    I wiele więcej
    
    2014-09-06
    
    ","
    Wersja 1.04:
    Zmiany:
    Nowa opcja: \"Użytkownicy, którzy dodali mnie do swoich kontaktów\"
    Nowy silnik przetwarzania ilości wpisów na forum
    Nowy silnik odczytu statusów
    Drobne zmiany w różnych interfejsach
    Wiele poprawek
    
    Najważniejsze poprawki:
    Usunięto błąd z informowaniem o nowych linijkach tekstu przez słowo LINE
    Usunięto błędy z buforowaniem linii i znaków w polach tekstowych
    Usunięto błąd z łączeniem wielu znaków w jedną tablicę w polach tekstowych
    Usunięto wiele błędów powodujących zawieszenie się programu, w wypadku zawieszenia, program powtarza wykonywaną klasę

        2014-10-19
        
      ","  
        Wersja 1.05:
        Dodane bufory pozwalające na pisanie dłuższych wpisów na forum, wiadomości i wizytówek
        Poprawki stabilności programu
        Zmiany w interfejsie
        Dostępna lista blogów
        Raportowanie błędów
        Aktualizacja wersji językowych razem z programem - od kolejnych aktualizacji
        Poprawki
        
        Najważniejsze poprawki:
        Przepisanie systemu list wyboru
        Poprawne przetwarzanie znaków ' oraz `
        Przelogowywanie użytkownika po wygaśnięciu tokenu
        Nowy silnik zamiany wyrażeń nieregularnych przy językach obcych
        
        Najważniejsze zmiany w interfejsie:
        Ograniczenie list wyboru - z ostatniego pola nie przechodzi się do pierwszego
        Możliwość ukrycia programu w zasobniku z menu zamykania programu
        Forum jest drzewem - zapamiętuje zaznaczone wątki i fora oraz pozwala na przemieszczanie się strzałkami lewo-prawo tak, jak klawiszami enter i escape
        
        2014-11-28
        
        ","
Wersja 1.06:
Zmiany:
Poprawki stabilności programu
Nowy system pól tekstowych
System przesyłania danych binarnych
Zaimplementowana biblioteka WINSOCK
Obsługa bezpośredniego połączenia z serwerami
Obsługa bezpośredniego przekazywania zapytań HTTP
Obsługa bezpośredniego przesyłania buforów
Obsługa specjalnych zdarzeń
Poprawki

2014-12-23

","
Wersja 1.07:
Zmiany:
Poprawki

2014-12-24

","
Wersja 1.08:
Zmiany:
Możliwość zaznaczania tekstu w polach tekstowych poprzez przytrzymanie klawisza shift i poruszanie kursorem lub całego tekstu skrótem CTRL+A
Obsługa schowka poprzez skróty CTRL+X, CTRL+C i CTRL+V
Możliwość tłumaczenia zaznaczonego tekstu na ustawiony w programie język skrótem CTRL+T
Poprawki w polach tekstowych
Poprawiony algorytm tworzenia nowych wierszy w polach tekstowych
Dodane formularze
Formularze przy wysyłaniu wpisów na blogi, wiadomości i postów na forum
Nowy interfejs wiadomości
Możliwość wyboru kontaktu przy wysyłaniu wiadomości poprzez wciśnięcie strzałki w górę lub w duł w polu \"Odbiorca\"
Zmiany w interfejsie programu
Poprawki

Najważniejsze poprawki:
Buforyzacja wpisów na blogach
Poprawki z wyskakującym błędem konwersji znaków w polach tekstowych
Poprawiony odczyt tablic w polach tekstowych
Poprawki przesyłu pustych ciągów znakowych

2014-12-31

","
Wersja 1.09:
Zmiany:
Różnego rodzaju poprawki
Formularze deklarowane przez klasy, nie pisane ręcznie dla każdej funkcji
Nowe dźwięki
Zmiany w interfejsie programu
Dodatkowe dane w wizytówkach
Nowe moduły przetwarzania danych
Drobne zmiany

2015-01-29

","
Wersja 1.091:
Poprawki

2015-01-29

","
Wersja 1.092:
Poprawki

2015-02-07

","
Wersja 1.093:
Poprawki

2015-02-13

","
Wersja 1.1:
Zmiany:
Modyfikacje w silniku takie, jak inna metoda przetwarzania modułów i inny sposób zapisu danych, jak i nowe metody szyfrowania
Nowy system \"Co nowego\"
Nowe i zmodyfikowane skróty klawiszowe i ich lista
Lista użytkowników dostępna dla wszystkich
Obsługa usuwania kategorii i wpisów na blogach
Wstępna wersja katalogu mediów
Nowa kontrolka: pole wyboru
Nowa kategoria menu: \"Narzędzia\"
Dostępny generator tematów dźwiękowych
Nowe metody przetwarzania danych w \"Plikach\"
Nowy sposób dodawania programów: są pobierane bezpośrednio z serwera przy starcie programu
Biblioteka elten.dll zaktualizowana do nowej wersji zawierającej kilka poprawek
Automatyczne wyciszanie głosu screenreaderów: NVDA, Jaws'a i WindowEyes'a
Opcja \"Rada starszych\" pokazująca listę osób zarządzających programem
Znaczne zmiany na forum, zwłaszcza w przeglądzie wątków
Udoskonalony system raportowania błędów
Nowe ustawienia interfejsu pozwalające na zmianę echa pisania, czułości klawiatury, wyciszenie dźwięków, sposobu wyświetlania list wyboru i metody startu programu
Obsługa nowych zdarzeń
Nowe dźwięki
Różne mniejsze i większe zmiany w interfejsie i funkcjach
Poprawki

Najważniejsze poprawki:
Naprawiony błąd z wysyłaniem wiadomości na chacie
Poprawiony błąd z dublowaniem się informacji o literach przy niektórych konfiguracjach screenreaderów
Poprawiony błąd z zaznaczaniem tekstu

2015-03-28

","
Wersja 1.11:
Zmiany:
Poprawki

2015-03-29

","
Wersja 1.12:
Zmiany:
Poprawki

2015-03-29

","
Wersja 1.13:
Zmiany:
Poprawki

2015-04-30

","
Wersja 1.14:
Zmiany:
Nowa metoda kodowania wiadomości między serwerem a klientem (dotyczy forum, wiadomości, blogów, programów i mediów) (te działy dla starszych wersji nie będą więcej wspierane)
Zaktualizowany protokuł tłumacza do najnowszej wersji Google Translatora
Poprawki

2015-05-08

","
Wersja 1.15:
Zmiany:
Nowe skróty klawiszowe w forum
Informacja we wpisie o jego numerze i numerze w wątku
Drobne zmiany w interfejsie
Nowa metoda buforyzacji
Poprawki (zwłaszcza w sekcji programów)

2015-05-21

","
Wersja 1.16:
Poprawki

2015-05-27

","
Wersja 1.2:
Zmiany:
Opcja testu prędkości łącza
Obsługa protokołu https przy większości połączeń
Zmiany w systemie połączeń
Aktualizator w menu
Zmiany w ustawieniach domyślnych
Dodany tryb awaryjny
Poprawki i drobniejsze zmiany

2015-06-20

","
Wersja 1.21:
Zmiany:
Dodane komentarze na blogach
Poprawki

2015-08-08

","
Wersja 1.22:
Poprawki

2015-08-10

","
Wersja 1.3:
Zmiany:
Zupełnie nowy agent programu odpowiedzialny za podtrzymywanie tokenu i odbieranie wiadomości
Z zasobnika można powrócić skrótem CTRL+ALT+SHIFT+E
Obsługa nowych skrótów w polach tekstowych: page up, page down, ctrl+home i ctrl+end
Dodane zawijanie wierszy
Drobne zmiany w systemie logowania
Dodana playlista
Dodane wiadomości wysłane
Możliwość zmiany nazwy bloga i edycji wpisów na nim
Drobniejsze zmiany w interfejsie
Nowy system aktualizacji i instalacji
Nowa procedura uruchamiania programu
Poprawki

2015-08-24

","
Wersja 1.31:
Poprawki i drobne zmiany w interfejsie

2015-08-24

","
Wersja 1.32:
Zmiany:
Poprawki
Nowa procedura sprawdzania śledzonych wątków przez \"Co nowego\"
API Translatora zaktualizowane do nowej wersji
Nowa obsługa wielu aktywnych scen jednocześnie
Dodane dwa kolejne wątki odpowiedzialne za wykrywanie pojawiania się zapisów nowych scen oraz za otwieranie tych scen
Nowe metody inicjacji pól tekstowych oraz zdalne ich oznaczanie
Zmiany w systemie ładowania wątków

2015-08-29


","
Wersja 1.33:
Poprawki

2015-08-29

","
Wersja 1.34:
Poprawki

2015-08-31

","
Wersja 1.35:
Zmiany:
Drobne zmiany w interfejsie
Nowy instalator i aktualizator
Poprawki

2015-09-06

","
Wersja 1.36:
Poprawki

2015-09-06

","
Wersja 1.37:
Zmiany:
Zmiany w procedurze startu programu
Obsługa wykonywania operacji w trakcie mowy
Dodana opcja cofania i powtarzania ostatnio cofniętej rzeczy w polach tekstowych
Drobniejsze zmiany w interfejsie
Poprawki

2015-09-22

","
Wersja 1.38:
Poprawki

2015-09-22

","
Wersja 1.39:
Zmiany:
Poprawki
Dodany kompilator dla projektów EAPI
Drobne zmiany w interfejsie

2015-11-20

","
Wersja 1.391:
Zmiany:
Nowy sposób przetwarzania audio przez odtwarzacz
Możliwe przewijanie utworów
Naprawione media

2015-11-27

","
Wersja 1.392:
Zmiany:
Poprawki w agencie programu
Druga wersja kompilacji biblioteki Elten.dll - w programie Visual Studio
Dobór odpowiedniej biblioteki odbywa się w zależności od możliwości komputera
Przetwarzanie nowych zdarzeń
Drobne zmiany w interfejsie
Poprawki

2015-12-23

","
Wersja 1.393:
Zmiany:
Dodane strumieniowanie danych z Internetu i obsługa radiów internetowych
Poprawki

2015-12-25

","
Wersja 1.394:
Poprawki

2016-03-08
","
Wersja 1.395:
Poprawki

2016-07-22
","
Wersja 1.396:
Poprawki

2016-07-22
","
Wersja 1.397:
Zmiany:
Dodana możliwość aktualizacji do wersji beta
Dodana możliwość kopiowania treści komunikatów błędów do schowka

2016-09-09
","
Wersja 1.398:
Poprawki

2016-11-19
","
Wersja 1.399:
Zmiany pozwalające na aktualizację do przyszłej wersji 2.0

2016-12-22
"]
@changes.reverse!
@selt = []
for i in 0..@changes.size - 1
  @selt.push(strbyline(@changes[i])[1].delete(":").sub("Wersja ","Elten "))
  end
@sel = Select.new(@selt,true,0,"Lista zmian")
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape
    delay
    $scene = Scene_Main.new
  end
  if enter
    input_text(@selt[@sel.index],"MULTILINE|READONLY|ACCEPTESCAPE",@changes[@sel.index])
    @sel.focus
    end
    end
end
#Copyright (C) 2014-2016 Dawid Pieper