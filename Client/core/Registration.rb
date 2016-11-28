#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Registration
  def main
    name = ""
    password = ""
    mail = ""
    while name == ""
    name = input_text("Podaj swój login. Będzie on używany w celu identyfikacji. Maksymalna długość loginu to 64 znaki.")
  end
  name.gsub(".") do
    speech("Nazwa użytkownika nie może zawierać kropek. Znak zostanie pominięty.")
    speech_wait
  end
    name.gsub("/") do
    speech("Nazwa użytkownika nie może zawierać ukośników. Znak zostanie pominięty.")
    speech_wait
  end
    name.gsub("\\") do
    speech("Nazwa użytkownika nie może zawierać ukośników. Znak zostanie pominięty.")
    speech_wait
  end
    name.gsub(" ") do
    speech("Nazwa użytkownika nie może zawierać spacji. Znak zostanie pominięty.")
    speech_wait
  end
      name.gsub("-") do
    speech("Nazwa użytkownika nie może zawierać myślników. Znak zostanie pominięty.")
    speech_wait
  end
    name.delete!("./ -")
  name.delete!("\\")
  pswconfirm = ""
  while password == "" or password != pswconfirm
    password = input_text("Podaj swoje hasło. Zalecane jest silne hasło. Hasło takie składa się z liter i cyfr. Długość hasła powinna być krótsza niż dwieście pięćdziesiąt sześć znaków.","password")
    pswconfirm = input_text("Powtórz hasło","password")
    if pswconfirm != password
      speech("Podane hasła są różne.")
      speech_wait
      end
  end
  while mail == ""
    mail = input_text("Podaj swój adres mailowy. Będzie on używany w przypadku zapomnienia hasła i do wysyłania najważniejszych informacji.")
    end
regtemp = srvproc("register","register=1\&name=#{name}\&password=#{password}\&mail=#{mail}")
id = regtemp[0].to_i
case id
when 0
  speech("Rejestracja powiodła się, dziękujemy. Możesz teraz się zalogować, używając podanych danych.")
  when -1
    speech("Wystąpił nieznany błąd bazy danych.")
    when -2
      speech("Konto o podanym loginie już istnieje.")
      when -3
        speech("Wystąpił błąd zapisu danych.")
        when -4
          speech("Wystąpił błąd połączenia z serwerem.")
        end
        speech_wait
      $scene = Scene_Loading.new
      main if id != 0
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper