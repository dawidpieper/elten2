#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Account_Password
  def main
      oldpassword = ""
  password = ""
  repeatpassword = ""
  while oldpassword == ""
    oldpassword = input_text("Podaj stare hasło","password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    while password == ""
    password = input_text("Podaj nowe hasło","password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while repeatpassword == ""
    repeatpassword = input_text("Powtórz nowe hasło","password|ACCEPTESCAPE")
  end
  if repeatpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
  if password != repeatpassword
    speech("Pola: Nowe Hasło i Powtórz Nowe Hasło mają różne wartości.")
    speech_wait
    main
  end
    act = srvproc("account_mod","changepassword=1\&name=#{$name}\&token=#{$token}\&oldpassword=#{oldpassword}\&password=#{password}")
    err = act[0].to_i
  case err
  when 0
    speech("Hasło zostało zmienione.")
    speech_wait
    Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","AutoLogin","0",$configdata + "\\login.ini")
    $scene = Scene_Loading.new
    when -1
      speech("Błąd połączenia z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        when -6
          speech("Podano błędne stare hasło.")
          speech_wait
          $scene = Scene_Main.new
  end
    end
end

class Scene_Account_Mail
  def main
      password = ""
  mail = ""
  while password == ""
    password = input_text("Podaj hasło","password|ACCEPTESCAPE")
  end
  if password == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while mail == ""
    mail = input_text("Podaj nowy adres e-mail","ACCEPTESCAPE")
  end
  if mail == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    act = srvproc("account_mod","changemail=1\&name=#{$name}\&token=#{$token}\&oldpassword=#{password}\&mail=#{mail}")
    err = act[0].to_i
  case err
  when 0
    speech("Adres e-mail został zmieniony.")
    speech_wait
    $scene = Scene_Main.new
    when -1
      speech("Błąd połączenia z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        when -6
          speech("Podano błędne stare hasło.")
          speech_wait
          $scene = Scene_Main.new
  end
    end
end

class Scene_Account_VisitingCard
  def main
    dialog_open
            vc = srvproc("visitingcard","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
        err = vc[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..vc.size - 1
        text += vc[i]
      end
@form = Form.new([Edit.new("Twoja wizytówka:","MULTILINE",text,true),Button.new("Zapisz"),Button.new("Anuluj")])
visitingcard = ""
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index == 2)
    visitingcard = "\004ESCAPE\004"
    break
  end
  if ($key[0x11] and enter) or ((space or enter) and @form.index == 1)
    visitingcard = @form.fields[0].text_str
    break
    end
  end
      if visitingcard == "\004ESCAPE\004" or visitingcard == "\004TAB\004"
        dialog_close
        $scene = Scene_Main.new
        return
      end
buf = buffer(visitingcard)
      vc = srvproc("visitingcard_mod","name=#{$name}\&token=#{$token}\&buffer=#{buf}"      )
err = vc[0].to_i
case err
when 0
  speech("Zapisano.")
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
  end
  
  class Scene_Account_Status
    def main
            speech("Zmiana statusu")
      speech_wait
      text = ""
      while text == ""
      text = input_text("Podaj nowy status","ACCEPTESCAPE")
    end
    if text == "\004ESCAPE\004"
      $scene = Scene_Main.new
      return
    end
    ef = setstatus(text)
    if ef != 0
      speech("Błąd!")
    else
      speech("Status został zmieniony.")
    end
    speech_wait
    $scene = Scene_Main.new
        end
  end
  
  class Scene_Account_Profile
    def main
            speech("Edycja profilu")
      profile = srvproc("profile","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&get=1")
                    fullname = ""
        gender = 0
        birthdateyear = ""
        birthdatemonth = ""
        birthdateday = ""
        location = ""
        publicprofile = 0
        publicmail = 0
if profile[0].to_i == 0
        fullname = profile[1].delete("\r\n")
        gender = profile[2].delete("\r\n").to_i
        birthdateyear = profile[3].delete("\r\n")
        birthdatemonth = profile[4].delete("\r\n")
        birthdateday = profile[5].delete("\r\n")
        location = profile[6].delete("\r\n")
        publicprofile = profile[7].to_i
        publicmail = profile[8].to_i
      end
      fields = []
      fields.push(Edit.new("Imię i nazwisko","",fullname,true))
      fields.push(Select.new(["Kobieta","Mężczyzna"],false,gender,"Płeć",true))
      fields.push(Edit.new("Data urodzenia: rok","NUMBERS|LENGTH04",birthdateyear,true))
      fields.push(Edit.new("Data urodzenia: miesiąc","NUMBERS|LENGTH02",birthdatemonth,true))
      fields.push(Edit.new("Data urodzenia: dzień","NUMBERS|LENGTH02",birthdateday,true))
      fields.push(Edit.new("Lokalizacja","",location,true))
      fields.push(CheckBox.new("Ukryj mój profil przed osobami z poza mojej listy kontaktów",publicprofile))
      fields.push(Button.new("Zapisz"))
      fields.push(Button.new("Anuluj"))
      speech_wait
      @form = Form.new(fields)
      loop do
        loop_update
        @form.update
        if ((space or enter) and @form.index == 7) or (enter and $key[0x11])
pr = srvproc("profile","name=#{$name}\&token=#{$token}\&mod=1\&fullname=#{fields[0].text_str}\&gender=#{fields[1].index.to_s}\&birthdateyear=#{fields[2].text_str.to_i.to_s}\&birthdatemonth=#{fields[3].text_str.to_i.to_s}\&birthdateday=#{fields[4].text_str.to_i.to_s}\&location=#{fields[5].text_str}\&publicprofile=#{fields[6].checked}")
if pr[0].to_i < 0
    speech("Błąd")
  speech_wait
else
  speech("Zapisano")
  speech_wait
end
$scene = Scene_Main.new
          end
        $scene = Scene_Main.new if escape or ((space or enter) and @form.index == 8)
        break if $scene != self
        end
          end
        end
        
        class Scene_Account_Signature
  def main
    dialog_open
            sg = srvproc("signature","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&get=1")
        err = sg[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..sg.size - 1
        text += sg[i]
      end
@form = Form.new([Edit.new("Twoja sygnatura:","MULTILINE",text,true),Button.new("Zapisz"),Button.new("Anuluj")])
signature = ""
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index == 2)
    signature = "\004ESCAPE\004"
    break
  end
  if ($key[0x11] and enter) or ((space or enter) and @form.index == 1)
    signature = @form.fields[0].text_str
    break
    end
  end
      if signature == "\004ESCAPE\004" or signature == "\004TAB\004"
        dialog_close
        $scene = Scene_Main.new
        return
      end
buf = buffer(signature)
      sg = srvproc("signature","name=#{$name}\&token=#{$token}\&buffer=#{buf}\&set=1")
err = sg[0].to_i
case err
when 0
  speech("Zapisano.")
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
end

class Scene_Account_Greeting
  def main
    dialog_open
            gt = srvproc("greetings","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&get=1")
        err = gt[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..gt.size - 1
        text += gt[i]
      end
@form = Form.new([Edit.new("Twoja wiadomość powitalna:","",text,true),Button.new("Zapisz"),Button.new("Anuluj")])
greeting = ""
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index == 2)
    greeting = "\004ESCAPE\004"
    break
  end
  if (enter) or ((space or enter) and @form.index == 1)
    greeting = @form.fields[0].text_str
    break
    end
  end
      if greeting == "\004ESCAPE\004" or greeting == "\004TAB\004"
        dialog_close
        $scene = Scene_Main.new
        return
      end
buf = buffer(greeting)
      gt = srvproc("greetings","name=#{$name}\&token=#{$token}\&buffer=#{buf}\&set=1")
err = gt[0].to_i
case err
when 0
  speech("Zapisano.")
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
  end
#Copyright (C) 2014-2016 Dawid Pieper