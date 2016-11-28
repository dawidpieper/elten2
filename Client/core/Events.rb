#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Events
  def initialize(id)
    @id = id
  end
  def main
        case @id
    when 1
Audio.bgm_play("Audio/BGM/SINI.mid",80,100)
txt = ""
if $language == "PL_PL"
  txt = "W imieniu wszystkich osób zarządzających Eltenem chciałbym wam wszystkim życzyć wesołych, rodzinnych świąt Bożego Narodzenia i szczęśliwego nowego roku dwa tysiące piętnastego. Elten istnieje od czterech miesięcy jako program w wersji publicznej. Pierwsze wersje testowe pojawiły się jeszcze dnia  dwudziestego czwartego lipca. W ciągu tego czasu Elten wciąż się rozwijał, aktualnie liczy około dwustu użytkowników. Dziękuję wam wszystkim za aktywne angażowanie się w ten projekt. Istnieje zwyczaj dawania w święta Bożego Narodzenia różnych prezentów. Dlatego też gra Saper w programie Elten dostępna jest za darmo. Pozdrawiam, Dawid Pieper"
else
  txt = "On behalf of all administrators of Elten I would like to wish you all a merry, family Christmas and happy new year two thousands fifteen! Elten there for four months as a program in the public version. The first test versions have appeared on the twenty fourth of July. During this time Elten continued to grow, currently has about two hundred members. Thank you all for your active involvement in the project. There is a custom of giving at Christmas various gifts. Therefore, Saper game is available for free. Greetings, Dawid Pieper"
end
for i in 1..Graphics.frame_rate * 5
  loop_update
  end
speech(txt)
speech_wait
Audio.bgm_fade(5000)
for i in 1..40*5
  Graphics.update
  end
  when 2
    txt = ""
if $language == "PL_PL"
  txt = "Proszę oddalić się od tego komputera!"
else
  txt = "Please move away from the computer!"
end
speech(txt)
speech_wait  
for i in 0..3
  delay(1) if i > 0
  speech((3-i).to_s)
end
play("shortexplosion")
delay(0.5)
play("explosion")
delay(1)
if $language == "PL_PL"
  txt = "Komputer gotowy do pracy. Pozdrawiam!"
else
  txt = "Computer ready to go. Greetings!"
end
speech(txt)
speech_wait  
when 3
txt = ""
if $language == "PL_PL"
  txt = "W imieniu całej administracji, chciałbym wam, drodzy użytkownicy, życzyć wszystkiego najlepszego, wielu łask Bożych i spokoju z okazji tegorocznych świąt Wielkanocnych. Niech zmartwychwstały Jezus napełnia was i wasze rodziny miłością i szczęściem. Dawid Pieper"
else
  txt = "On behalf of all administrators of Elten I would like to wish you all a calm and happy Easter. Lets Risen Jesus fills you with peace and happiness. Dawid Pieper"
end
speech(txt)
speech_wait  
when 4
  txt = ""
if $language == "PL_PL"
txt = "Drodzy użytkownicy! \r\n Dzisiaj mija rok od premiery programu: 24 sierpnia 2014. \r\n W tym czasie program się znacznie rozwinął, pojawiło się wiele nowych możliwości. Zwiększyła się też jego społeczność. \r\n Pozwólcie, że będę pierwszą osobą, która mu złoży życzenia urodzinowe. \r\n Życzę zatem, aby ten program rozwijał się dalej, jego społeczność rosła i by mógł zaspokoić potrzeby wszystkich użytkowników. \r\n Dziękuję Wam wszystkim za aktywność w programie i za to, że to Wy, drodzy użytkownicy, tworzycie Eltenowską społeczność. \r\n Z okazji rocznicy powstania programu, postanowiłem wydać nową wersję: Elten 1.3. \r\n Zdecydowałem się na zmianę domyślnego tematu dźwiękowego i dodanie wielu obiecanych od dawna funkcji. \r\n Mowa tu głównie o playliście, na razie jest tylko jedna, opcji przeglądania wiadomości wysłanych oraz kilku poprawkach błędów, które były widoczne już od dłuższego czasu. \r\n Dziękuję wam jeszcze raz za wszystko. \r\n Na początku tego roku zaczęliśmy wykorzystywać nowy serwer. Do tej pory jednak używaliśmy w większości funkcji starego silnika. \r\n Jako, że obciążenie serwera jest jednak minimalne, zdecydowałem się na kilka zmian w systemie. \r\n Najważniejszą jest zwiększenie dwa razy maksymalnej długości wpisów na forum i na blogach, a także długości treści wiadomości prywatnych. \r\n Dawid Pieper"
else
  txt = "Dear users! \ r \ n Today marks one year since the launch of the program: 24 August 2014. \ r \ n During this time much has developed, there have been many new functions. also increased its community. \ r \ n Let I'll be the first person who will make its happy birthday. \ r \ n I wish, therefore, that this program continue to grow, the community grew and it could meet the needs of all users. \ r \ n Thank you all for activity in the program and for the fact that you are the Elten's community! \ r \ n David Pieper "
end
speech(txt)
speech_wait  
when 6
  Audio.bgm_play("Audio/BGM/SINI.mid",80,100)
txt = ""
if $language == "PL_PL"
  txt = "W imieniu całej administracji programu chciałbym wam, drodzy użytkownicy, życzyć wesołych i rodzinnych świąt Bożego Narodzenia.\r\nOby ten czas był dla was miły.\r\nW prawdzie tegoroczny grudzień dla Eltena nie był zbyt łaskawy z powodu katastrofy serwera, ale mam nadzieję, że wszystko uda się odbudować, a problem ten będzie tylko źródłem doświadczenia w radzeniu sobie z tego typu sytuacjami.\r\nOstatnio przyszedł do mnie Mikołaj i wspominał coś o jakimś prezencie. Ja tam nie wiem do końca, o co chodzi, ale mówił, że jak ktoś jest zainteresowany, powinien zajrzeć na forum PL_ELTEN.\r\nPróbowałem go wypytać o więcej szczegółów, ale nie chciał ich zdradzić.\r\nNie pozostaje więc nic innego, jak wejść na to forum i sprawdzić, co też się tam pojawiło.\r\nPonoć wątek od razu rozpoznacie.\r\nWesołych świąt i szczęśliwego nowego roku 2016!\r\nPozdrawiam\r\nDawid Pieper"
else
  txt = "On behalf of all administrators of Elten I would like to wish you all a merry, family Christmas and happy new year two thousands sixteen! Elten there for 1,5 years as a program. During this time Elten continued to grow, currently has about three hundred members. Thank you all for your active involvement in the project. Santa Claus told me that I should to give you a present.\r\nBut, I unfortunatelly haven't translated it yet.\r\nBut I'll try my best to finish it to February.\r\nGreetings, DP"
end
for i in 1..Graphics.frame_rate * 5
  loop_update
  end
speech(txt)
speech_wait
Audio.bgm_fade(5000)
for i in 1..40*5
  Graphics.update
  end
end
    $scene = Scene_Main.new
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper