# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_ForgotPassword
  def main
    @user=""
    loop do    
    @user=input_text(p_("ForgotPassword", "If you lose your password, you can still reset it via the E-mail address provided  during the registration process. This way you shall generate the password reset  code which will be used to verify your identity. The code will be sent to your e- mail address. Warning! Two-factor authentication will be disabled on your  account. To continue, enter your username"),0,"",true)
    return $scene=Scene_Loading.new if @user==nil
    @user=finduser(@user) if finduser(@user).downcase==@user.downcase
          break
      end
@mail=""
    loop do    
    @mail=input_text(p_("ForgotPassword", "Enter the E-mail address used during the registration process"),0,"",true)
    return $scene=Scene_Loading.new if @mail==nil
              break
      end
  ut=srvproc("user_exist", {"searchname"=>@user, "searchmail"=>@mail})
  if ut[0].to_i<0
    alert(_("Error"))
    return $scene=Scene_Loading.new
  end
    if ut[2].to_i==0 or ut[1].to_i==0
    alert(p_("ForgotPassword", "The typed E-mail address is not associated with the entered username."))
    return main
  end
@sel=ListBox.new([p_("ForgotPassword", "Generate password reset code"),p_("ForgotPassword", "Enter password reset code"),_("Exit")],p_("ForgotPassword", "Password reset"))
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
        alert(p_("ForgotPassword", "Please wait while the password reset key is being generated."))
    fp=srvproc("resetpassword",{"name"=>@user, "mail"=>@mail, "step"=>"1"})
    speech_wait
    if fp[0].to_i<0
      alert(p_("ForgotPassword", "An unexpected error"))
    else
      alert(p_("ForgotPassword", "Password reset key has been sent to your specified E-mail address. To continue,  select the option for entering key."))
    end
    speech_wait
  end
  def proceed
    key=""
    loop do
    key=input_text(p_("ForgotPassword", "Enter the generated password reset code"),0,"",true)
    return if key==nil
fp=srvproc("resetpassword",{"name"=>@user, "mail"=>@mail, "key"=>key, "step"=>"2"})
if fp[0].to_i==0
  break
else
  alert(p_("ForgotPassword", "The entered code is invalid."))
end
end
newpassword=""
loop do
  newpassword=input_text(p_("ForgotPassword", "Type a new password"),"ACCEPTESCAPE|PASSWORD")
  return if newpassword==nil
  confirmpassword=input_text(p_("ForgotPassword", "Type a new password again"),"ACCEPTESCAPE|PASSWORD")
  return if confirmpassword==nil
  if confirmpassword!=newpassword
    alert(p_("ForgotPassword", "The entered passwords are different."))
  elsif newpassword==""
    alert(p_("ForgotPassword", "Empty password provided."))
    else
    break
    end
end
speak(p_("ForgotPassword", "Please wait while the password is being changed"))
fp=srvproc("resetpassword",{"name"=>@user, "mail"=>@mail, "key"=>key, "step"=>"2", "change"=>"1", "newpassword"=>newpassword})
speech_wait
if fp[0].to_i<0
  alert(p_("ForgotPassword", "An unexpected error"))
else
  alert(p_("ForgotPassword", "The password has been changed. You can log in to your account using the new data."))
end
speech_wait
return
end
end