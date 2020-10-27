# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_Authentication
  def main
    auth=srvproc("authentication",{"state"=>"1"})
    if auth[0].to_i<0
      speak(_("Error"))
      speech_wait
      return $scene=Scene_Main.new
    end
    state=auth[1].to_i
    action=0
    if state==0
      action=selector([_("Enable"),nil,_("Exit")],p_("Authentication", "Two-factor authentication enables better account security by requiring the  confirmation of each login with your phone. When activated, a text message with a  verification code will be sent to you each time you log in from a new device.  Entering this code will be required to sign in to the program."),0,2,1)
    else
      action=selector([_("Disable"),p_("Authentication", "Generate backup codes"),_("Exit")],p_("Authentication", "Two-factor authentication is enabled on this account."),0,2,1)
    end
if action==0
  if state==0
password=""
suc=true
phone=""
  password=input_text(p_("Authentication", "Type your password"),EditBox::Flags::Password,"",true) while password==""
  return main if password==nil
phone=input_text(p_("Authentication", "Type your phone number that will be used during verification. Remember to enter  the country code, for example, +48 for Poland"),0,"",true) while (phone=="" or (phone[0..0]!="+" and phone[0..1]!="00") or phone.size<11 or (/[a-zA-Z,.\/;'\"\[\]!@\#\$%\^\&\*\(\)\_]/=~phone)!=nil) and phone!=nil
return main if phone==nil
return main if confirm(p_("Authentication", "Two-factor authentication was introduced in Elten 2.28. After activating it, it  will not be possible to log in from the older versions of the program. DO you  wish to continue anyway?"))==0
return main if input_text(p_("Authentication", "Is this phone number correct? Press enter to continue or escape to cancel."),EditBox::Flags::ReadOnly,phone, true)==nil
if suc==true
alert(p_("Authentication", "Please wait, connecting to the server ..."))
enb=srvproc("authentication",{"password"=>password, "phone"=>phone, "enable"=>"1", "lang"=>Configuration.language})
speech_wait
if enb[0].to_i<0||enb[0].include?("-")
  alert(_("Error"))
else
  code=""
  tries=0
  label=p_("Authentication", "On the phone number indicated, you will receive a text message with the code  activating two-factor authentication. Enter this code")
  while tries<3
  code=input_text(label,EditBox::Flags::Numbers).delete("\r\n") while code==""
    cnf=srvproc("authentication",{"verify"=>"1", "code"=>code, "appid"=>$appid})
  if cnf[0].to_i<0||cnf[0].include?("-")
        tries+=1
        code=""
        if tries<3
          label=p_("Authentication", "The entered code is not correct. Try again.")
        else
          alert(p_("Authentication", "The entered code is not correct."))
          end
    speech_wait
  else
    alert(p_("Authentication", "Two-factor authentication has been activated on this account."))
    break
  end
end
  end

  end
elsif state==1
  password=""
  password=input_text(p_("Authentication", "Type your password"),EditBox::Flags::Password,"",true) while password==""
  if password!=nil and confirm(p_("Authentication", "Are you sure you want to disable two-factor authentication?"))==1
    dsb=srvproc("authentication",{"disable"=>"1", "password"=>password})
    if dsb[0].to_i==0
      alert(p_("Authentication", "Two-factor authentication has been disabled."))
    elsif dsb[0].to_i==-2
      alert(p_("Authentication", "Invalid password"))
      else
      alert(_("Error"))
    end
    speech_wait
    end
    end
  end
  if action==1
if confirm(p_("Authentication", "Do you want to generate backup codes? These can be used to sign in when you have no access to your phone. All previously generated codes will be deleted."))==1
  password=""
  password=input_text(p_("Authentication", "Type your password"),EditBox::Flags::Password,"",true) while password==""
  return main if password==nil  
  al=srvproc("authentication", {'password'=>password, 'generatebackup'=>1})
    if al[0].to_i<0
      alert(_("Error"))
    else
      codes=[]
      for c in al[1..-1]
        codes.push(c.delete("\r\n"))
      end
      input_text(p_("Authentication", "Generated backup codes"), EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly, codes.join("\r\n\r\n"), true)
      end
    end
        end
    $scene=Scene_Main.new if action==2
  end
  end