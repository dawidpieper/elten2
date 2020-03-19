#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Login
  def initialize(skipauto=false)
    @skipauto=skipauto
    end
  def main
    token=""
    name = ""
    password = ""
        autologin = readconfig("Login","AutoLogin",-1)
            if autologin.to_i <= 0 or @skipauto==true
    while name == ""
    name = input_text(p_("Login", "Username:"),"ACCEPTESCAPE")
      end
              if name == "\004ESCAPE\004"
    $scene = Scene_Loading.new(true)
    return
    end
  password=""
    while password == ""
    password = input_text(p_("Login", "Password:"),"ACCEPTESCAPE|password")
  end
if password=="\004ESCAPE\004"
  $scene=Scene_Loading.new
  return
end
name=finduser(name) if finduser(name).upcase==name.upcase
else
      name = readconfig("Login","Name","")
if autologin == 3
  token=readconfig("Login","Token","")
    tokenenc=readconfig("Login","TokenEncrypted",-1)
    tokenenc=-1 if tokenenc>0 and token.bytesize<=130
    suc=false
    while suc==false and tokenenc>=1
    pin=nil
    pin=input_text(p_("Login", "Enter pin code"),"PASSWORD|ACCEPTESCAPE") if tokenenc==2
      if pin=="\004ESCAPE\004"
       @skipauto=true
       return main
        end
      t=decrypt(Base64.strict_decode64(token),pin) if tokenenc>0
      if t=="" and pin==nil
        @skipauto=true
        return main
      elsif t!=""
        token=t
        break
      end
      end
  if tokenenc==-1
    if confirm(p_("Login", "Do you want to enable auto-Login-key encryption? When encrypted, the Auto-Login Key will be readable only on this computer, and its copying or exporting will not allow other devices to access your account. Note: If you encrypt your Auto-Login Key, the created portable versions will not be able to automatically log into your account from other devices, even if you copy your settings, and you will be prompted to enter your password. You can create as many auto-login-keys as you wish for all other computers you are using."))==0
      writeconfig("Login","TokenEncrypted",0)
    else
      writeconfig("Login","TokenEncrypted",1)
      pin=makepin
      writeconfig("Login","Token",Base64.strict_encode64(crypt(token,pin)))
      writeconfig("Login","TokenEncrypted",2) if pin!=nil
      end
    end
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
  if token!=""
    logintemp = srvproc("login", {"login"=>"1", "name"=>name, "token"=>token, "version"=>ver.to_s, "beta"=>b.to_s, "appid"=>$appid, "lang"=>$language, "crp"=>cryptmessage(JSON.generate({'name'=>name,'time'=>Time.now.to_i}))})
else
  logintemp = srvproc("login",{"login"=>"1", "name"=>name, "password"=>password, "version"=>ver.to_s, "beta"=>b.to_s, "appid"=>$appid, "lang"=>$language, "crp"=>cryptmessage(JSON.generate({'name'=>name,'time'=>Time.now.to_i}))})
end
suc=true
if logintemp[0].to_i==-5
  suc=false
tries=0
label=p_("Login", " Two-factor authentication is enabled on this account. Enter the code sent to you  by text message to allow this device to login. If you do not have access to the  phone number used, select the password reset option to disable two-factor  authentication.")
while tries<3
  code=input_text(label,"ACCEPTESCAPE").delete("\r\n")
  if code=="\004ESCAPE\004"
    writeconfig("Login","AutoLogin",0)
    return $scene=Scene_Loading.new
    break
  end
  ath=srvproc("authentication", {"authenticate"=>"1", "appid"=>$appid, "name"=>name, "code"=>code})[0].to_i
  if ath<0
    tries+=1
    if tries>=3
      alert(p_("Login", "Verification failed."))
      writeconfig("Login","AutoLogin",0)
    return $scene=Scene_Loading.new
    break
    else
      label=p_("Login", "The entered code is wrong, please try again")
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
    prtemp = srvproc("getprivileges",{"searchname"=>$name})
$rang_tester = prtemp[1].to_i
$rang_moderator = prtemp[2].to_i
$rang_media_administrator = prtemp[3].to_i
$rang_translator = prtemp[4].to_i
$rang_developer = prtemp[5].to_i
if autologin.to_i == -1 or autologin.to_i == 1 or autologin.to_i == 2
  dialog_open  
  if autologin.to_i == -1
  @sel = menulr([_("No"),_("Yes"),p_("Login", "Do not ask again")],true,0,p_("Login", "Do you want to enable auto log in for account %{user}?")%{'user'=>name})
else
  @sel=menulr([_("No"),_("Yes")],true,0,p_("Login", " The saved login data uses the old account authentication method in which  susceptibility to hacker attacks has been detected. New, safer automatic login  algorithms have been introduced in Elten 2.2. It is recommended that you convert  the saved information into a new system in order to improve the security of your  account. Do you want to update the saved information now?"))
    end
  loop do
loop_update
    @sel.update
    if enter
            case @sel.index
      when 0
        when 1
          loop do
          password=input_text(p_("Login", "Password:"),"ACCEPTESCAPE|PASSWORD") if password=="" or password==nil
          if password=="\004ESCAPE\004"
            break
          else
            lt=srvproc("login", {"login"=>2, "name"=>name, "password"=>password, "computer"=>$computer, "appid"=>$appid, "crp"=>cryptmessage(JSON.generate({'name'=>name,'time'=>Time.now.to_i}))})
            if lt[0].to_i<0
              alert(p_("Login", " An error occurred while authenticating the identity. You might have provided an  incorrect password."))
              password = ""
            else
              token=lt[1].delete("\r\n")
              n=0
              confirm(p_("Login", "Do you want to enable auto-Login-key encryption? When encrypted, the Auto-Login Key will be readable only on this computer, and its copying or exporting will not allow other devices to access your account. Note: If you encrypt your Auto-Login Key, the created portable versions will not be able to automatically log into your account from other devices, even if you copy your settings, and you will be prompted to enter your password. You can create as many auto-login-keys as you wish for all other computers you are using.")) {
              pin=makepin
              token=Base64.strict_encode64(crypt(token,pin))
              writeconfig("Login","Token",token)
              n=1
              n=2 if pin!=nil
                            }
                            writeconfig("Login","TokenEncrypted",n)
writeconfig("Login","AutoLogin",3)
              writeconfig("Login","Name",name)
              writeconfig("Login","Token",token)
                                          if autologin.to_i==-1
              alert(p_("Login", " Automatic login will be proceeding until you log out.Automatic login keys can be  managed from the My Account tab in the Community menu."))
            else
              alert(p_("Login", " Login data has been updated. Automatic login will be proceeding until you log  out. Automatic login keys can be managed from the My Account tab in the Community  menu."))
              end
         speech_wait
         break   
         end
                        end
          end
       when 2
         writeconfig("Login","AutoLogin",0)
         alert(p_("Login", "To reenable auto log in feature, proceed to the general settings."))
         end
       break
        end
      end
      dialog_close
 end
    if $agentloaded != true
  agent_start
  $agentloaded = true
else
  $agent.write(Marshal.dump({'func'=>'relogin','name'=>$name,'token'=>$token}))
end
if $speech_wait == true
  $speech_wait = false
  speech_wait
end
play("login")
if $greeting == "" or $greeting == "\r\n" or $greeting == nil or $greeting == " "
speech(p_("Login", "Logged in as: %{user}")%{'user'=>name}) if $silentstart != true
else
  speech($greeting) if $silentstart != true
  end
  $name = name
  $token = logintemp[1]
  $token.delete!("\r\n")
    $greeting = logintemp[3]
delay(0.1)
    pr = srvproc("profile",{"get"=>"1", "searchname"=>$name})
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
        alert(_("Database Error"))
    $token = nil
    speech_wait
    @skipauto=true
    return main
    when -2
            alert(p_("Login", "Invalid login or password.")) if autologin.to_i==0
      $token = nil
      speech_wait
      @skipauto=true
      return main
      when -3
                alert(p_("Login", "Login failure."))
        $token = nil
        speech_wait
        @skipauto=true
      return main
        when -4
          alert(p_("Login", "Connection failure."))
          $token = nil
          speech_wait
        end
                $speech_wait = true
        $scene = Scene_Loading.new
        $preinitialized = false
                $scene = Scene_Main.new if $token != nil
      end
      def makepin
        pin=""
        while pin==""
          if confirm(p_("Login", "Do you want to encrypt this key with a custom pin code? You will be prompted for this code everytime you start Elten to unlock your account, but it will not be saved on the server and will be valid only for the auto-login-key stored on this device."))==0
            return nil
          else
            p1=input_text(p_("Login", "Enter pin code"),"PASSWORD|ACCEPTESCAPE")
            next if p1=="\004ESCAPE\004"
            p2=input_text(p_("Login", "Enter pin code again"),"PASSWORD|ACCEPTESCAPE")
            next if p2=="\004ESCAPE\004"
            if p1==p2
              return p1
            else
              alert(p_("Login", "The pin codes entered are different, please try again."))
              end
            end
          end
        end
end