      class Program_DevTool < Program
      s=""
def initialize
s=""
@name = "DevTool"
@author = "Dawid Pieper"
@version = 0
@devtooldata = $appsdata + "\\devtool"
@srcdata = @devtooldata + "\\src"
Win32API.new("kernel32","CreateDirectory",'pp','i').call(@devtooldata,nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(@srcdata,nil)
end
      def main
      s=""
        speech("DEVTOOL")
        speech_wait
sel = ["Nowy Program","Nowy Moduł","Otwórz"]
sel.push("Kontynuuj edycję.") if @text != nil
@sel = SelectLR.new(sel)
loop do
loop_update
@sel.update
if escape
delay
finish
return
break
end
if Input.trigger?(Input::C)
case @sel.index
when 0
@text = "class Program_MyProgram < Program #Program_MyProgram to nazwa klasy programu. Zmień ją w zależności od potrzeb. Klasa programu powinna zaczynać się od \"Program_\". Nie powinna zawierać spacji ani polskich diakretyków.\r\ndef initialize #Tu znajdują się parametry programu oraz funkcje, które zostaną wykonane przez Eltena przed uruchomieniem programu\r\n@name = \"MyProgram\" #Nazwa programu\r\n@author = \"#{$name}\" #autor\r\n@version = 0 #wersja określona przez jedną liczbę całkowitą\r\nend\r\ndef main #To jest funkcja, która uruchamia się po włączeniu programu\r\nfinish #ta komenda nakazuje zamknięcie programu\r\nend\r\ndef close #ta funkcja zostanie wywołana po zamknięciu programu\r\nend\r\nend"
when 1
@text = "module MyModule #nazwa tworzonego modułu\r\n#Tu znajdują się funkcje, które zostaną wywołane przy starcie programu Elten\r\nclass <<self #tu znajdują się funkcje tworzonego modułu\r\ndef test #przykładowa funkcja\r\nspeech(\"test\") #wypowiedz słowo \"test\"\r\nspeech_wait #poczekaj na zakończenie wypowiedzi\r\n#Po wywołaniu w konsoli polecenia \"NazwaModułu.test\" użytkownik usłyszy słowo test, po czym wywoływanie funkcji się zakończy.\r\nend\r\nend\r\nend"
when 2
@text = load
when 3
@text = @txt
end
@type = @sel.index
break
end
break if $scene != self
end
@text = "" if @text == nil
@oldtext = @text
bool = false
        while (@text == "" or @text == nil or @text == @oldtext) or bool == false
        bool = true
          @txt = @text = input_text("Podaj kod programu","MULTILINE|ACCEPTESCAPE",@text).to_s
          if @text == "\004ESCAPE\004"
main
            return
            break
            end
          end
          @text.gsub!("\004LINE\004","\r\n")
		  sleep(0.2)
          Input.update
speech("Co zrobić?")
speech_wait
@sel = SelectLR.new(["Zapisz","Załaduj do Eltena"])
sleep(0.1)
loop do
loop_update
@sel.update
if $scene != self
break
end
if Input.trigger?(Input::C)
case @sel.index
when 0
@file = ""
while @file == "" or @file == nil
@file = input_text("Podaj nazwę pliku","","myprogram.rb")
end
cf = Win32API.new("kernel32","CreateFile",'piipiip','i')
plik = cf.call(@srcdata + "\\" + @file.to_s,2,1|2|4,nil,2,0,nil)
writefile = Win32API.new("kernel32","WriteFile",'ipipp','I')
bp = "\0" * 1024
writefile.call(plik,@txt.to_s,@txt.size,bp,nil)
bp = nil
Win32API.new("kernel32","CloseHandle",'i','i').call(plik)
plik = 0
speech("Kod został zapisany")
speech_wait
when 1
cf = Win32API.new("kernel32","CreateFile",'piipiip','i')
$tmpname = rand(1048576).to_s + rand(1048576).to_s + rand(1048576).to_s + ".rb"
plik = cf.call($tmpname,2,1|2|4,nil,2,0,nil)
writefile = Win32API.new("kernel32","WriteFile",'ipipp','I')
bp = "\0" * 1024
writefile.call(plik,@txt.to_s,@txt.size,bp,nil)
bp = nil
Win32API.new("kernel32","CloseHandle",'i','i').call(plik)
plik = 0
$consoleused = true
require($tmpname)
$consoleused = false        
File.delete($tmpname)
speech("Załadowano moduł.")
speech_wait
input_text("Aby uruchomić program, wpisz w konsoli programu dostępnej po wciśnięciu w głównym oknie klawisza f7 następujący kod: . KLASA to główna klasa programu zdefiniowana na początku przez dyrektywę class. Dla programów, domyślna klasa to Program_MyProgram. Jeśli tworzysz moduł, który nie wymaga ładowania, pomiń ten krok.","ACCEPTESCAPE|READONLY","$scene = KLASA.new")
end
main
end
end
end
def load
txt = ""
speech("Wybierz kod do otwarcia.")
speech_wait
@src = Dir::entries(@srcdata)
@src.delete(".")
@src.delete("..")
if @src.size < 1
speech("Brak projektów")
speech_wait
main
end
@sel = Select.new(@src)
@file = ""
loop do
Graphics.update
Input.update
@sel.update
if escape
sleep(0.1)
main
end
if Input.trigger?(Input::C)
@file = @srcdata + "\\" + @src[@sel.index]
break
end
end
txt = IO.readlines(@file)
@text = ""
for i in 0..txt.size - 1
@text += txt[i]
end
speech("Załadowano.")
speech_wait
return(@text)
end
def close

end
end



for i in 0..$app.size -  1
if $app[i] == "DevTool" or $app[i] == "devtool"
$appstart[i] = Program_DevTool
end
end