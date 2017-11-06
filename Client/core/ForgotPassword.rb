#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ForgotPassword
  def main
    name=input_text("Jeśli zapomniałeś swojego hasła, nadal możesz je odzyskać dzięki podanemu adresowi e-mail. Jeśli chcesz, możesz wygenerować hasło tymczasowe, dzięki któremu możesz zalogować się do swojego konta i zmienić hasło. Uwaga! Po wygenerowaniu hasła tymczasowego nadal będzie możliwe zalogowanie się przy użyciu starego hasła. Pamiętaj, hasło tymczasowe jest hasłem jednokrotnego użytku. Aby wygenerować hasło tymczasowe, podaj swój login.","ACCEPTESCAPE")
    if name=="\004ESCAPE\004"
      $scene=Scene_Loading.new
      return
    end
    mail=input_text("Podaj swój adres e-mail","ACCEPTESCAPE")
    if mail=="\004ESCAPE\004"
      $scene=Scene_Loading.new
      return
    end           
    speech("Proszę czekać, trwa tworzenie hasła tymczasowego.")
    fp=srvproc("resetpassword","name=#{name}\&mail=#{mail}")
    speech_wait
    if fp[0].to_i<0
      speech("Błąd! Nie odnaleziono konta #{name} skojarzonego z adresem #{mail}.")
    else
      speech("Hasło tymczasowe zostało wygenerowane i wysłane na twój adres E-mail.")
    end
    speech_wait
    $scene=Scene_Loading.new
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper