#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ShortKeys
  def main
    if $language=="PL_PL"    
    @shorts = "Lista skrótów klawiszowych
        
        Skróty podstawowe:
Strzałki - poruszanie się po elementach list wyboru i menu
Tabulator i Shift+Tabulator - poruszanie się między polami formularzy
Enter - potwierdzanie list wyboru i przycisków
Spacja - potwierdzanie przycisków i zmiana wartości pól wyboru

Skróty globalne:
F1 - Lista skrótów klawiszowych
SHIFT+F1 - przełącz wyjście mowy
SHIFT+F2 - nowa instancja menu
F3 - ukrycie programu w zasobniku
F5 - ściszanie tematu dźwiękowego
F6 - zgłaśnianie tematu dźwiękowego
F7 - konsola
F8 - aktualny czas
Shift+F8 - aktualna data
F9 - kontakty
Shift+F9 - lista zalogowanych osób
F10 - co nowego
SHIFT+F10 - wiadomości
F11 - powtórz wypowiedź
SHIFT+F11 - chat
F12 - restart
SHIFT+F12 - restart do trybu debugowania
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
SHIFT - zaznaczanie
F4 - czytaj od kursora
CTRL+ENTER - zatwierdź

Skróty w polach typu media
F4 - odtwórz lub przewiń
CTRL+S - zapisz strumień na dysku
Spacja - play/pauza
SHIFT+Lewo/Prawo - przewijanie

Skróty w plikach
Spacja - podgląd
SHIFT+Spacja - wstrzymanie podglądu
F4 - zatrzymanie podglądu
SHIFT+Góra/Dół - głośność podglądu
SHIFT+Lewo/Prawo - przewijanie podglądu
CTRL+D - odczytaj szczegóły folderu lub długość pliku
CTRL+I - odczytaj rozmiar
CTRL+C - kopiuj
CTRL+X - wytnij
CTRL+V - wklej

Skróty w odtwarzaczu
Góra/dół - zgłaśnianie i ściszanie
Lewo/prawo - przewijanie
Shift + góra/duł - zmiana częstotliwości
SHIFT + lewo/prawo - zmiana pozycji
Spacja - odtwórz / pauza
Backspace - przywróć
D - odczytaj długość
P - odczytaj pozycję
S - zapisz strumień
J - skocz do czasu

Skróty na playliście
Lewo/Prawo - przewijanie
SHIFT+Góra/Dół - przesuwanie elementów na playliście
Enter - odtwórz
Spacja - play/pauza

Skróty w wątkach
CTRL+, - skok do pierwszego wpisu
CTRL+. - skok do ostatniego wpisu
CTRL+U - skok do pierwszego nowego wpisu
CTRL+N - odpowiedź
CTRL+D - odpowiedź z cytatem
CTRL+J - przejdź do wpisu    

Inne skróty:
CTRL+SHIFT+ALT+T - powrót z zasobnika
"
elsif $language=="DE_DE"
  @shorts="Liste der Kurztasten

Grundlegende Tasten:
Pfeiltasten - Navigieren durch die Elemente von Auswahllisten und Menüs
Tabulator und Shift + Tabulator - Navigieren zwischen Formularfeldern
Eingabe - Auswahllisten und Schaltflächen bestätigen
Leertaste - Bestätigung von Schaltflächen und Ändern der Werte von Kontrollkästchen

Globale Tasten
F1 - Liste der Tastenkombinationen
Umschalt + F1 - Sprachausgabe umschalten
UMSCHALT + F2 - neue Menüinstanz
F3 - Programm in den Infobereich minimieren
F4 - Forum
F5 - Verringerung der Lautstärke des gewählten Audiothemas
F6 - Erhöhung der Lautstärke des gewählten Audiothemas
F7 - Konsole
F8 - aktuelle Zeit
Umschalt + F8 - aktuelles Datum
F9 - Kontakte
Umschalt + F9 - wer ist online?
F10 - Was ist neu?
UMSCHALT + F10 - Nachrichten
F11 - letzte Äußerung wiederholen
UMSCHALT + F11 - Chat
F12 - Neustart
UMSCHALT + F12 - Neustart im Debug-Modus
UMSCHALT + F3 - Play / Pause Playlist
UMSCHALT + F4 - vorheriges Lied von der Wiedergabeliste
UMSCHALT + F5 - Playlist-Lautstärke runter
UMSCHALT + F6 - Lautstärke der Playlist erhöhen
UMSCHALT + F7 - nächstes Lied aus der Wiedergabeliste

Kurztasten für Eingabefelder
STRG + Z - rückgängig
STRG + Y - wiederherstellen
STRG + X - Ausschneiden
STRG + C - kopieren
STRG + V - einfügen
STRG + A - Alles markieren
STRG + S - in den Puffer schreiben
STRG + R - den Puffer wiederherstellen
STRG + T - schnelle Übersetzung
STRG + UMSCHALT + T - Übersetzermenü
STRG + F - Suche
Eingabe - Link öffnen
UMSCHALT - Markieren
F4 - Lesen vom Cursor
STRG + EINGABE - bestätigen

Kurzztasten für medien
F4 - spielen oder zurückspulen
STRG + S - Stream auf Festplatte speichern
Leertaste - Abspielen / Pause
UMSCHALT + Links / Rechts - Scrollen

Kurztasten für Dateien
Leertaste - Vorschau
UMSCHALT + Leertaste - Vorschau anhalten
F4 - Vorschau stoppen
UMSCHALT + Hoch / Runter - Vorschaulautstärke
UMSCHALT + Links / Rechts - In der Vorschau spuhlen
STRG + D - Liest Ordnerdetails oder Audiodateilänge
STRG + I - Größe lesen
STRG + C - kopieren
STRG + X - Ausschneiden
STRG + V - einfügen

Kurztasten für den Player
Rauf / Runter - Lautstärke
Links / rechts - blättern
Umschalt + auf / ab - Frequenz
UMSCHALT + links / rechts - Balance
Leertaste - Abspielen / Pause
Rücktaste - wiederherstellen
D - Länge lesen
P - Position lesen
S - stream speichern
J - Gehe zu Zeit

Kurztasten für Wiedergabelisten
Links / Rechts - Scrollen
UMSCHALT + Hoch / Runter - verschiebt Elemente in der Wiedergabeliste
Eingabe - spielen
Leertaste - Abspielen / Pause

Kurztasten für Forumthemen 
STRG +, - Springe zum ersten Beitrag
STRG +. - Springe zum letzten Beitrag
STRG + U - Springe zum ersten neuen Beitrag
STRG + N - antworten
STRG + D - antworten mit Zitat
STRG + J - gehe zu Post

Andere Tasten
STRG + UMSCHALT + ALT + T - Rückkehr aus dem Infobereich"
else
  @shorts="List of keyboard shortcuts

Basic shortcuts:
Arrows - navigating the elements of selection lists and menus
Tabulator and Shift + Tabulator - navigating between form fields
Enter - confirming selection lists and buttons
Space - confirming buttons and changing the values of check boxes

Global shortcuts
F1 - List of keyboard shortcuts
SHIFT + F1 - switch speech output
SHIFT + F2 - new menu instance
F3 - hide program in tray
F5 - sound theme volume down
F6 - sound theme volume up
F7 - console
F8 - current time
Shift + F8 - current date
F9 - contacts
Shift + F9 - who is online
F10 - what's new
SHIFT + F10 - messages
F11 - repeat last said phrase
SHIFT + F11 - chat
F12 - restart
SHIFT + F12 - restart in debug mode
SHIFT + F3 - play / pause playlist
SHIFT + F4 - previous song from playlist
SHIFT + F5 - playlist volume down
SHIFT + F6 - playlist volume up
SHIFT + F7 - next song from playlist

Text fields shortcuts
CTRL + Z - undo
CTRL + Y - repeat
CTRL + X - cut
CTRL + C - copy
CTRL + V - paste
CTRL + A - select all
CTRL + S - write to the buffer
CTRL + R - restore the buffer
CTRL + T - quick translation 
CTRL + SHIFT + T - translator menu
CTRL + F - search
Enter - open link
SHIFT - select
F4 - read from cursor
CTRL + ENTER - confirm

Media fields shortcuts
F4 - play or rewind
CTRL + S - save stream to disk
Space - play / pause
SHIFT + Left / Right - scrolling

Files shortcuts
Space - preview
SHIFT + Space - pause preview
F4 - stop preview
SHIFT + Up / Down - preview volume
SHIFT + Left / Right - scroll preview
CTRL + D - read folder details or audio file length
CTRL + I - read size
CTRL + C - copy
CTRL + X - cut
CTRL + V - paste

Player shortcuts
Up / down - volume
Left / right - scroll
Shift + up / down - frequency
SHIFT + left / right - panorama
Space - play / pause
Backspace - restore
D - read length
P - read position
S - save stream
J - jump to time

Playlist shortcuts
Left / Right - scrolling
SHIFT + Up / Down - move elements in playlist
Enter - play
Space - play / pause

Threads shortcuts
CTRL +, - jump to first post
CTRL +. - jump to the last post
CTRL + U - jump to the first new post
CTRL + N - reply
CTRL + D - quote
CTRL + J - go to post

Other shortcuts:
CTRL + SHIFT + ALT + T - return from the tray"
end
    input_text(_("ShortKeys:head"),"MULTILINE|READONLY|ACCEPTESCAPE",@shorts)
speech_stop
$scene = Scene_Main.new
end
end
#Copyright (C) 2014-2016 Dawid Pieper