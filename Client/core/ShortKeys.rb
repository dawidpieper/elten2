#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ShortKeys
  def main
        @shorts = "
Skróty podstawowe:
Strzałki - poruszanie się po elementach list wyboru i menu
Tabulator i Shift+Tabulator - poruszanie się między polami formularzy
Enter - potwierdzanie list wyboru i przycisków
Spacja - potwierdzanie przycisków i zmiana wartości pól wyboru

Skróty globalne:
F3 - ukrycie programu w zasobniku
F5 - ściszanie tematu dźwiękowego
F6 - zgłaśnianie tematu dźwiękowego
F8 - aktualny czas
Shift+F8 - aktualna data
F9 - kontakty
Shift+F9 - lista zalogowanych osób
F10 - co nowego
SHIFT+F10 - wiadomości
F11 - powtórz wypowiedź
SHIFT+F11 - chat
F12 - restart
SHIFT+F3 - play/pauza playlisty
SHIFT+F4 - poprzedni utwór z playlisty
SHIFT+F5 - ściszanie playlisty
SHIFT+F6 - zgłaśnianie playlisty
SHIFT+F7 - następny utwór z playlisty

Skróty w polach tekstowych
CTRL+Z - cofnij
CTRL+Y - powtórz
CTRL+X - wytnij
CTRL+C - kopiuj
CTRL+V - wklej
CTRL+A - zaznacz wszystko
CTRL+S - zapis do bufora
CTRL+R - przywrócenie bufora
CTRL+T - szybkie tłumaczenie
CTRL+SHIFT+T - tłumacz
CTRL+F - szukaj
Enter - otwórz link
SHIFT+Strzałki - zaznaczanie
F4 - czytaj od kursora
CTRL+ENTER - zatwierdź

Skróty w plikach
Spacja - podgląd
SHIFT+Spacja - wstrzymanie podglądu
F4 - zatrzymanie podglądu

Skróty w odtwarzaczu
Góra/dół - zgłaśnianie i ściszanie
Lewo/prawo - przewijanie
Shift + góra/duł - zmiana częstotliwości
SHIFT + lewo/prawo - zmiana pozycji
Spacja - odtwórz / pauza

Skróty w wątkach
CTRL+, - skok do pierwszego wpisu
CTRL+. - skok do ostatniego wpisu
CTRL+U - skok do pierwszego nowego wpisu
CTRL+N - odpowiedź
CTRL+D - odpowiedź z cytatem
    
Inne skróty:
CTRL+SHIFT+ALT+T - powrót z zasobnika
"
    input_text("Lista skrótów klawiszowych","MULTILINE|READONLY|ACCEPTESCAPE",@shorts)
speech_stop
$scene = Scene_Main.new
end
end
#Copyright (C) 2014-2016 Dawid Pieper