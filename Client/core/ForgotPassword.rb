#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ForgotPassword
  def main
    @user=""
    loop do    
    @user=input_text("W wypadku utraty hasła nadal istnieje możliwość jego zresetowania poprzez weryfikację konta za pośrednictwem podanego adresu E-mail. Możesz wygenerować w ten sposób kod, dzięki któremu możliwa będzie zmiana hasła. Kod zostanie wysłany na twój adres E-mail. Aby kontynuować, wprowadź swój login:","ACCEPTESCAPE")
    return $scene=Scene_Loading.new if @user=="\004ESCAPE\004"
    @user=finduser(@user) if finduser(@user).downcase==@user.downcase
          break
      end
@mail=""
    loop do    
    @mail=input_text("Podaj adres E-mail użyty podczas rejestracji","ACCEPTESCAPE")
    return $scene=Scene_Loading.new if @mail=="\004ESCAPE\004"
              break
      end
  ut=srvproc("user_exist","searchname=#{@user}\&searchmail=#{@mail}")
  if ut[0].to_i<0
    speech("Błąd.")
    speech_wait
    return $scene=Scene_Loading.new
  end
    if ut[2].to_i==0 or ut[1].to_i==0
    speech("Podany adres E-mail nie jest skojarzony z podaną nazwą użytkownika.")
    speech_wait
    return main
  end
@sel=Select.new(["Wygeneruj klucz resetowania hasła","Wprowadź klucz resetowania hasła","Zamknij"],true,0,"Reset hasła")
loop do
  loop_update
  @sel.update
  return $scene=Scene_Loading.new if escape
  if enter
    case @sel.index
    when 0
      request
      @sel.focus
      when 1
    proceed
    @sel.focus
        when 2
      return $scene=Scene_Loading.new
    end
    end
  end
    end
  def request
        speech("Proszę czekać, trwa generowanie klucza resetowania hasła.")
    fp=srvproc("resetpassword","name=#{@user}\&mail=#{@mail}\&step=1")
    speech_wait
    if fp[0].to_i<0
      speech("Wystąpił nieoczekiwany błąd podczas generowania klucza.")
    else
      speech("Klucz resetowania hasła został wysłany na podany adres E-mail. Wybierz opcję wprowadzenia klucza, aby kontynuować")
    end
    speech_wait
  end
  def proceed
    key=""
    loop do
    key=input_text("Wprowadź wygenerowany klucz resetowania hasła.","ACCEPTESCAPE")
    return if key=="\004ESCAPE\004"
fp=srvproc("resetpassword","name=#{@user}\&mail=#{@mail}\&key=#{key}\&step=2")
if fp[0].to_i==0
  break
else
  speech("Wprowadzony klucz jest nieprawidłowy.")
  speech_wait
end
end
newpassword=""
loop do
  newpassword=input_text("Wprowadź nowe hasło","ACCEPTESCAPE|PASSWORD")
  return if newpassword=="\004ESCAPE\004"
  confirmpassword=input_text("Wprowadź ponownie nowe hasło","ACCEPTESCAPE|PASSWORD")
  return if confirmpassword=="\004ESCAPE\004"
  if confirmpassword!=newpassword
    speech("Wprowadzone hasła są różne.")
    speech_wait
  elsif newpassword==""
    speech("Podano puste hasło.")
    speech_wait
    else
    break
    end
end
speech("Proszę czekać, trwa zmiana hasła...")
fp=srvproc("resetpassword","name=#{@user}\&mail=#{@mail}\&key=#{key}\&step=2\&change=1\&newpassword=#{newpassword}")
speech_wait
if fp[0].to_i<0
  speech("Wystąpił nieoczekiwany błąd.")
else
  speech("Hasło zostało zmienione. Możesz się teraz zalogować przy użyciu nowych danych.")
end
speech_wait
return
end
end
#Copyright (C) 2014-2016 Dawid Pieper