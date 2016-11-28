#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Login
  def main
        name = ""
    password = ""
    autologin = readini($configdata + "\\login.ini","Login","AutoLogin",0).to_i
            if autologin.to_i <= 0
    while name == ""
    name = input_text("Login:")
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
  while password == ""
    password = input_text("Hasło:","password")
  end
else
      name = readini($configdata + "\\login.ini","Login","Name","")
                  password_c = readini($configdata + "\\login.ini","Login","Password","")
    psw = password_c
password = ""
l = false
mn = psw[psw.size - 1..psw.size - 1]
mn = mn.to_i
mn += 1
l = false
for i in 0..psw.size - 1 - mn
  if l == true
    l = false
  else
    password += psw[i..i]
    l = true
    end
  end
      password = decrypt(password)
    password = password.gsub("a`","ą")
password = password.gsub("c`","ć")
password = password.gsub("e`","ę")
password = password.gsub("l`","ł")
password = password.gsub("n`","ń")
password = password.gsub("o`","ó")
password = password.gsub("s`","ś")
password = password.gsub("x`","ź")
password = password.gsub("z`","ż")
  end
  ver = $version.to_s
  ver += " BETA" if $isbeta == 1
    logintemp = srvproc("login","login=1\&name=#{name}\&password=#{password}\&version=#{ver.to_s}\&beta=#{$beta.to_s}")
    if logintemp.size > 1
  $token = logintemp[1] if logintemp.size > 1
  $token.delete!("\r\n")
  $event = logintemp[2] if logintemp.size > 2
  $name = name
  end
case logintemp[0].to_i
when 0
    srvproc("active","name=#{$name}\&token=#{$token}")
prtemp = srvproc("getprivileges","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
$rang_tester = prtemp[1].to_i
$rang_moderator = prtemp[2].to_i
$rang_media_administrator = prtemp[3].to_i
$rang_translator = prtemp[4].to_i
$rang_developer = prtemp[5].to_i
if autologin.to_i == 0
  dialog_open  
  @sel = SelectLR.new(["Nie","Tak","Nie zadawaj więcej tego pytania"],true,0,"Czy chcesz włączyć automatyczne logowanie dla konta #{name}?")
  loop do
loop_update
    @sel.update
    if enter
            case @sel.index
      when 0
        when 1
          Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","AutoLogin","1",$configdata + "\\login.ini")
          Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","name",name,$configdata + "\\login.ini")
    password_c = crypt(password)
    password_c = password_c.sub("ą","a`")
password_c = password_c.sub("ć","c`")
password_c = password_c.sub("ę","e`")
password_c = password_c.sub("ł","l`")
password_c = password_c.sub("ń","n`")
password_c = password_c.sub("ó","o`")
password_c = password_c.sub("ś","s`")
password_c = password_c.sub("ź","x`")
password_c = password_c.sub("ż","z`")
pswc = password_c
password_c = ""
for i in 0..pswc.size - 1
  password_c += pswc[i..i]
  password_c += (rand(36)).to_s(36)
end
mn = rand(10)
for i in 1..mn
  password_c += (rand(36)).to_s(36)
end
password_c += mn.to_s
          Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","password",password_c,$configdata + "\\login.ini")
                   speech("Automatyczne logowanie będzie ważne do wylogowania się lub do momentu, kiedy zapisane dane stracą ważność, na przykład po zmianie hasła.")
         speech_wait
       when 2
         Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","AutoLogin","-1",$configdata + "\\login.ini")
         speech("Aby włączyć ponownie pytanie o automatyczne logowanie, wybierz odpowiednią opcję z menu ustawień interfejsu.")
         speech_wait
         end
       break
        end
      end
      dialog_close
 end
  writefile("agent.tmp","#{$name}\r\n#{$token}\r\n#{$wnd.to_s}")
  if $agentloaded != true
  $agentproc = run("bin/elten_agent.bin")
$agentloaded = true
end
if $speech_wait == true
  $speech_wait = false
  speech_wait
  end
play("login")
  speech("Zalogowany jako: " + name)
  $name = name
  $token = logintemp[1]
  $token.delete!("\r\n")
  $event = logintemp[2] if logintemp.size > 2
  when -1
    Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","AutoLogin","0",$configdata + "\\login.ini")
    speech("Wystąpił błąd operacji w bazie danych.")
    $token = nil
    speech_wait
    when -2
      Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","AutoLogin","0",$configdata + "\\login.ini")
      speech("Błędny login lub hasło.")
      $token = nil
      speech_wait
      when -3
        speech("Błąd logowania. Zostałeś zbanowany.")
        $token = nil
        speech_wait
        when -4
          speech("Błąd połączenia z serwerem.")
          $token = nil
          speech_wait
        end
                $speech_wait = true
        $scene = Scene_Loading.new
        $preinitialized = false
        if $event.to_i > 0
          $scene = Scene_Events.new($event.to_i)
          else
        $scene = Scene_Main.new if $token != nil
        end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper