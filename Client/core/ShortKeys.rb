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
F12 - restart


Skróty w Plikach
F4 - wyciszenie odtwarzanego pliku

Skróty w wątkach
CTRL+, - skok do pierwszego wpisu
CTRL+. - skok do ostatniego wpisu
CTRL+U - skok do pierwszego nowego wpisu
CTRL+N - odpowiedź
CTRL+F - odpowiedź z cytatem
    
Inne skróty:
CTRL+SHIFT+ALT+E - powrót z zasobnika
"
    input_text("Lista skrótów klawiszowych","MULTILINE|READONLY|ACCEPTESCAPE",@shorts)
speech_stop
$scene = Scene_Main.new
end
end
#Copyright (C) 2014-2016 Dawid Pieper