#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ForgotPassword
  def main
    @user=""
    loop do    
    @user=input_text(_("ForgotPassword:head_reset"),"ACCEPTESCAPE")
    return $scene=Scene_Loading.new if @user=="\004ESCAPE\004"
    @user=finduser(@user) if finduser(@user).downcase==@user.downcase
          break
      end
@mail=""
    loop do    
    @mail=input_text(_("ForgotPassword:type_mail"),"ACCEPTESCAPE")
    return $scene=Scene_Loading.new if @mail=="\004ESCAPE\004"
              break
      end
  ut=srvproc("user_exist", {"searchname"=>@user, "searchmail"=>@mail})
  if ut[0].to_i<0
    speech(_("General:error"))
    speech_wait
    return $scene=Scene_Loading.new
  end
    if ut[2].to_i==0 or ut[1].to_i==0
    speech(_("ForgotPassword:error_match"))
    speech_wait
    return main
  end
@sel=Select.new([_("ForgotPassword:opt_genkey"),_("ForgotPassword:opt_typekey"),_("General:str_quit")],true,0,_("ForgotPassword:head"))
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
        speech(_("ForgotPassword:wait"))
    fp=srvproc("resetpassword",{"mail"=>@mail, "step"=>"1"})
    speech_wait
    if fp[0].to_i<0
      speech(_("ForgotPassword:error_unexpected"))
    else
      speech(_("ForgotPassword:info_keysent"))
    end
    speech_wait
  end
  def proceed
    key=""
    loop do
    key=input_text(_("ForgotPassword:type_key"),"ACCEPTESCAPE")
    return if key=="\004ESCAPE\004"
fp=srvproc("resetpassword",{"mail"=>@mail, "key"=>key, "step"=>"2"})
if fp[0].to_i==0
  break
else
  speech(_("ForgotPassword:error_wrongkey"))
  speech_wait
end
end
newpassword=""
loop do
  newpassword=input_text(_("ForgotPassword:type_newpass"),"ACCEPTESCAPE|PASSWORD")
  return if newpassword=="\004ESCAPE\004"
  confirmpassword=input_text(_("ForgotPassword:type_newpassagain"),"ACCEPTESCAPE|PASSWORD")
  return if confirmpassword=="\004ESCAPE\004"
  if confirmpassword!=newpassword
    speech(_("ForgotPassword:error_difpass"))
    speech_wait
  elsif newpassword==""
    speech(_("ForgotPassword:error_emptypass"))
    speech_wait
    else
    break
    end
end
speech(_("ForgotPassword:wait_changing"))
fp=srvproc("resetpassword",{"mail"=>@mail, "key"=>key, "step"=>"2", "change"=>"1", "newpassword"=>newpassword})
speech_wait
if fp[0].to_i<0
  speech(_("ForgotPassword:error_unexpected"))
else
  speech(_("ForgotPassword:info_changed"))
end
speech_wait
return
end
end
#Copyright (C) 2014-2019 Dawid Pieper