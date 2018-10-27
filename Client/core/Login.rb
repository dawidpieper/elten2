#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Login
  def main
    token=""
    name = ""
    password = ""
    crp = ""
    autologin = readini($configdata + "\\login.ini","Login","AutoLogin","-1").to_i
            if autologin.to_i <= 0
    while name == ""
    name = input_text(_("Login:type_login"),"ACCEPTESCAPE")
      end
              if name == "\004ESCAPE\004"
    $scene = Scene_Loading.new
    return
    end
  password=""
    while password == ""
    password = input_text(_("Login:type_pass"),"ACCEPTESCAPE|password")
  end
if password=="\004ESCAPE\004"
  $scene=Scene_Loading.new
  return
end
name=finduser(name) if finduser(name).upcase==name.upcase
else
      name = readini($configdata + "\\login.ini","Login","Name","")
                  if autologin.to_i == 1
    password_c = readini($configdata + "\\login.ini","Login","Password","")
    password = password_c
                    password = ""
l = false
mn = password[password.size - 1..password.size - 1]
mn = mn.to_i
mn += 1
l = false
for i in 0..password.size - 1 - mn
  if l == true
    l = false
  else
    password += password[i..i]
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
elsif autologin == 2
  password_c = readini($configdata + "\\login.ini","Login","Password","")
    password = password_c
  crp=password
elsif autologin == 3
  token=readini($configdata + "\\login.ini","Login","Token","")
  end
  end
  ver = $version.to_s
  ver += " BETA" if $isbeta == 1
  ver += " RC" if $isbeta == 2
b=0
  b=$beta if $isbeta==1
  b=$alpha if $isbeta==2
  password="" if autologin.to_i==2
  suc=false
  while suc==false
  if token=="" and crp!=""
  logintemp = srvproc("login","login=1\&name=#{name}\&crp=#{crp}\&version=#{ver.to_s}\&beta=#{b.to_s}\&appid=#{$appid}&lang=#{$language}")
elsif token!=""
    logintemp = srvproc("login","login=1\&name=#{name}\&token=#{token}\&version=#{ver.to_s}\&beta=#{b.to_s}\&appid=#{$appid}\&lang=#{$language}")
else
  logintemp = srvproc("login","login=1\&name=#{name}\&password=#{password}\&version=#{ver.to_s}\&beta=#{b.to_s}\&appid=#{$appid}\&lang=#{$language}")
end
suc=true
if logintemp[0].to_i==-5
  suc=false
tries=0
label=_("Login:type_authcode")
while tries<3
  code=input_text(label,"ACCEPTESCAPE").delete("\r\n")
  if code=="\004ESCAPE\004"
    writeini($configdata+"\\login.ini","Login","AutoLogin","0")
    return $scene=Scene_Loading.new
    break
  end
  ath=srvproc("authentication","authenticate=1\&appid=#{$appid}\&name=#{name}\&code=#{code}")[0].to_i
  if ath<0
    tries+=1
    if tries>=3
      speech(_("Login:error_verification"))
      speech_wait
      writeini($configdata+"\\login.ini","Login","AutoLogin","0")
    return $scene=Scene_Loading.new
    break
    else
      label=_("Login:type_authcodeagain")
    end
  else
        break
    end
  end
  end
end
    if logintemp.size > 1
  $token = logintemp[1] if logintemp.size > 1
  $token.delete!("\r\n")
  $event = logintemp[2]
  $greeting = logintemp[3]
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
if autologin.to_i == -1 or autologin.to_i == 1 or autologin.to_i == 2
  dialog_open  
  if autologin.to_i == -1
  @sel = menulr([_("General:str_no"),_("General:str_yes"),_("Login:opt_asknomore")],true,0,s_("Login:alert_autologin", {'user'=>name}))
else
  @sel=menulr([_("General:str_no"),_("General:str_yes")],true,0,_("Login:alert_crpdeprecated"))
    end
  loop do
loop_update
    @sel.update
    if enter
            case @sel.index
      when 0
        when 1
          loop do
          password=input_text(_("Login:type_pass"),"ACCEPTESCAPE|PASSWORD") if password=="" or password==nil
          if password=="\004ESCAPE\004"
            break
          else
            lt=srvproc("login","login=2\&name=#{name}\&password=#{password}\&computer=#{$computer.urlenc}\&appid=#{$appid}")
            if lt[0].to_i<0
              speech(_("Login:error_identity"))
              speech_wait
              password = ""
            else
writeini($configdata+"\\login.ini","Login","AutoLogin","3")
              writeini($configdata+"\\login.ini","Login","Name",name)
              writeini($configdata+"\\login.ini","Login","Token",lt[1].delete("\r\n"))
              writeini($configdata+"\\login.ini","Login","password",nil)
                            if autologin.to_i==-1
              speech(_("Login:info_autologin"))
            else
              speech(_("Login:info_crpupdated"))
              end
         speech_wait
         break   
         end
                        end
          end
       when 2
         writeini($configdata+"\\login.ini","Login","AutoLogin","0")
         speech(_("Login:info_asknomore"))
         speech_wait
         end
       break
        end
      end
      dialog_close
 end
 File.delete("temp\\agent.tmp") if FileTest.exists?("temp\\agent.tmp") 
 writefile("temp/agent.tmp","#{$name}\r\n#{$token}\r\n#{$wnd.to_s}")
  if $agentloaded != true
  agent_start
$agentloaded = true
end
if $speech_wait == true
  $speech_wait = false
  speech_wait
  end
play("login")
if $greeting == "" or $greeting == "\r\n" or $greeting == nil or $greeting == " "
speech(s_("Login:info_loggedinas", {'user'=>name})) if $silentstart != true
else
  speech($greeting) if $silentstart != true
  end
  $name = name
  $token = logintemp[1]
  $token.delete!("\r\n")
  $event = logintemp[2]
  $greeting = logintemp[3]
  pr = srvproc("profile","name=#{$name}\&token=#{$token}\&get=1\&searchname=#{$name}")
$fullname = ""
$gender = -1
$birthdateyear = 0
$birthdatemonth = 0
$birthdateday = 0
$location = ""
if pr[0].to_i == 0
  $fullname = pr[1].delete("\r\n")
        $gender = pr[2].delete("\r\n").to_i
        if pr[3].to_i>1900 and pr[4].to_i > 0 and pr[4].to_i < 13 and pr[5].to_i > 0 and pr[5].to_i < 32
        $birthdateyear = pr[3].delete("\r\n")
        $birthdatemonth = pr[4].delete("\r\n")
        $birthdateday = pr[5].delete("\r\n")
        end
        $location = pr[6].delete("\r\n")
                        if $birthdateyear.to_i>0
        $age = Time.now.year-$birthdateyear.to_i
if Time.now.month < $birthdatemonth.to_i
  $age -= 1
elsif Time.now.month == $birthdatemonth.to_i
  if Time.now.day < $birthdateday.to_i
    $age -= 1
    end
  end
  $age -= 2000 if $age > 2000      
    end
  end
    when -1
        speech(_("General:error_db"))
    $token = nil
    speech_wait
    when -2
      writeini($configdata+"\\login.ini","Login","AutoLogin","0")
      speech(_("Login:error_wrongdata")) if autologin.to_i==0
      $token = nil
      speech_wait
      when -3
        writeini($configdata+"\\login.ini","Login","AutoLogin","0")
        speech(_("Login:error_logon"))
        $token = nil
        speech_wait
        when -4
          speech(_("Login:error_srv"))
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