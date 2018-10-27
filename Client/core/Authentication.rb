#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Authentication
  def main
    auth=srvproc("authentication","name=#{$name}\&token=#{$token}\&state=1")
    if auth[0].to_i<0
      speech("Błąd.")
      speech_wait
      return $scene=Scene_Main.new
    end
    state=auth[1].to_i
    action=0
    if state==0
      action=selector(["Włącz","Zamknij"],"Dwuetapowe uwierzytelnianie pozwala na lepsze zabezpieczenie konta poprzez potwierdzanie każdego logowania numerem telefonu. Gdy ta opcja jest włączona, przy każdorazowym logowaniu do portalu Elten z nowego urządzenia wysyłana będzie wiadomość SMS z kodem weryfikującym. Wpisanie tego kodu będzie wymagane, aby zalogować się do programu.",0,1,1)
    else
      action=selector(["Wyłącz","Zamknij"],"Dwuetapowe uwierzytelnianie jest włączone dla tego konta.",0,1,1)
    end
if action==0
  if state==0
password=""
suc=true
phone=""
  password=input_text("Podaj swoje hasło","PASSWORD|ACCEPTESCAPE") while password==""
  return main if password=="\004ESCAPE\004"
phone=input_text("Podaj swój numer telefonu, który będzie używany podczas weryfikacji. Pamiętaj o wpisaniu numeru kierunkowego, na przykład +48 dla polski","ACCEPTESCAPE") while (phone=="" or (phone[0..0]!="+" and phone[0..1]!="00") or phone.size<11 or (/[a-zA-Z,.\/;'\"\[\]!@\#\$%\^\&\*\(\)\_]/=~phone)!=nil) and phone!="\004ESCAPE\004"
return main if phone=="\004ESCAPE\004"
return main if confirm("Uwierzytelnianie dwuetapowe zostało wprowadzone w Eltenie 2.28. Po aktywowaniu go, zalogowanie się ze starszych wersji programu nie będzie możliwe. Czy kontynuować mimo to?")==0
return main if input_text("Czy ten numer telefonu jest poprawny? Wciśnij enter aby kontynuować lub escape aby anulować.","ACCEPTESCAPE|READONLY",phone)=="\004ESCAPE\004"
if suc==true
speech("Proszę czekać, trwa łączenie z serwerem...")
enb=srvproc("authentication","name=#{$name}\&token=#{$token}\&password=#{password}\&phone=#{phone}\&enable=1&lang=#{$language}")
speech_wait
if enb[0].to_i<0
  speech("Błąd.")
  speech_wait
else
  code=""
  tries=0
  label="Na wskazany numer telefonu otrzymasz wiadomość SMS z kodem aktywującym uwierzytelnianie dwuetapowe. Wprowadź ten kod"
  while tries<3
  code=input_text(label,"NUMBERS").delete("\r\n") while code==""
    cnf=srvproc("authentication","name=#{$name}\&token=#{$token}\&verify=1\&code=#{code}\&appid=#{$appid}")
  if cnf[0].to_i<0
        tries+=1
        code=""
        if tries<3
          label="Wprowadzony kod nie jest poprawny. Spróbuj jeszcze raz."
        else
          speech("Wprowadzony kod nie jest poprawny.")
          end
    speech_wait
  else
    speech("Uwierzytelnianie dwuetapowe zostało aktywowane dla tego konta.")
    speech_wait
    break
  end
end
  end

  end
elsif state==1
  password=""
  password=input_text("Podaj hasło","PASSWORD|ACCEPTESCAPE") while password==""
  if password!="\004ESCAPE\004" and confirm("Czy jesteś pewien, że chcesz wyłączyć uwierzytelnianie dwuetapowe?")==1
    dsb=srvproc("authentication","name=#{$name}\&token=#{$token}\&disable=1\&password=#{password}")
    if dsb[0].to_i==0
      speech("Uwierzytelnianie dwuetapowe zostało wyłączone.")
    elsif dsb[0].to_i==-2
      speech("Podano nieprawidłowe hasło.")
      else
      speech("Błąd.")
    end
    speech_wait
    end
    end
  end
    $scene=Scene_Main.new if action==1
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper