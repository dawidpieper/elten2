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
    oldpassword = input_text(_("Account:type_oldpass"),"password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    while password == ""
    password = input_text(_("Account:type_newpass"),"password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while repeatpassword == ""
    repeatpassword = input_text(_("Account:type_newpassagain"),"password|ACCEPTESCAPE")
  end
  if repeatpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
  if password != repeatpassword
    speech(_("General:error_difpass"))
    speech_wait
    main
  end
    act = srvproc("account_mod","changepassword=1\&name=#{$name}\&token=#{$token}\&oldpassword=#{oldpassword}\&password=#{password}")
    err = act[0].to_i
  case err
  when 0
    speech(_("Account:info_passchanged"))
    speech_wait
    Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","AutoLogin","-1",$configdata + "\\login.ini")
    $scene = Scene_Loading.new
    when -1
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        $scene = Scene_Loading.new
        when -6
          speech(_("General:error_wrongoldpass"))
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
    password = input_text(_("Account:type_pass"),"password|ACCEPTESCAPE")
  end
  if password == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while mail == ""
    mail = input_text(_("Account:type_newmail"),"ACCEPTESCAPE")
  end
  if mail == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    act = srvproc("account_mod","changemail=1\&name=#{$name}\&token=#{$token}\&oldpassword=#{password}\&mail=#{mail}")
    err = act[0].to_i
  case err
  when 0
    speech(_("Account:info_mailchanged"))
    speech_wait
    $scene = Scene_Main.new
    when -1
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        $scene = Scene_Loading.new
        when -6
          speech(_("General:error_wrongoldpass"))
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
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..vc.size - 1
        text += vc[i]
      end
@form = Form.new([Edit.new(_("Account:type_visitingcard"),"MULTILINE",text,true),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
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
  speech(_("General:info_saved"))
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech(_("General:error_db"))
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech(_("General:error_tokenexpired"))
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
  end
  
  class Scene_Account_Status
    def main
            speech(_("Account:head_status"))
      speech_wait
      text = ""
      while text == ""
      text = input_text(_("Account:type_status"),"ACCEPTESCAPE")
    end
    if text == "\004ESCAPE\004"
      $scene = Scene_Main.new
      return
    end
    ef = setstatus(text)
    if ef != 0
      speech(_("General:error"))
    else
      speech(_("Account:info_statuschanged"))
    end
    speech_wait
    $scene = Scene_Main.new
        end
  end
  
  class Scene_Account_Profile
    def main
            speech(_("Account:head_profile"))
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
      fields.push(Edit.new(_("Account:type_fullname"),"",fullname,true))
      fields.push(Select.new([_("General:female"),_("General:male")],false,gender,_("Account:head_gender"),true))
      fields.push(Edit.new(_("Account:type_birthdateyear"),"NUMBERS|LENGTH04",birthdateyear,true))
      fields.push(Edit.new(_("Account:type_birthdatemonth"),"NUMBERS|LENGTH02",birthdatemonth,true))
      fields.push(Edit.new(_("Account:type_birthdateday"),"NUMBERS|LENGTH02",birthdateday,true))
      fields.push(Edit.new(_("Account:type_location"),"",location,true))
      fields.push(CheckBox.new(_("Account:chk_hideprofile"),publicprofile))
      fields.push(Button.new(_("General:str_save")))
      fields.push(Button.new(_("General:str_cancel")))
      speech_wait
      @form = Form.new(fields)
      loop do
        loop_update
        @form.update
        if ((space or enter) and @form.index == 7) or (enter and $key[0x11])
$fullname=fields[0].text_str
$gender=fields[1].index
          pr = srvproc("profile","name=#{$name}\&token=#{$token}\&mod=1\&fullname=#{fields[0].text_str}\&gender=#{fields[1].index.to_s}\&birthdateyear=#{fields[2].text_str.to_i.to_s}\&birthdatemonth=#{fields[3].text_str.to_i.to_s}\&birthdateday=#{fields[4].text_str.to_i.to_s}\&location=#{fields[5].text_str}\&publicprofile=#{fields[6].checked}")
if pr[0].to_i < 0
    speech(_("General:error"))
  speech_wait
else
  speech(_("General:info_saved"))
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
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..sg.size - 1
        text += sg[i]
      end
@form = Form.new([Edit.new(_("Account:type_signature"),"MULTILINE",text,true),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
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
  speech(_("General:info_saved"))
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech(_("General:error_db"))
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech(_("General:error_tokenexpired"))
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
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech(_("General:error_tokenexpired"))
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..gt.size - 1
        text += gt[i]
      end
@form = Form.new([Edit.new(_("Account:type_greeting"),"",text,true),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
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
  speech(_("General:info_saved"))
  speech_wait
  $scene = Scene_Main.new
  when -1
    speech(_("General:error_db"))
    speech_wait
    $scene = Scene_Main.new
    when -2
      speech(_("General:error_tokenexpired"))
      speech_wait
      $scene = Scene_Loading.new
end
dialog_close    
end
end

class Scene_Account_Avatar
  def main
    dialog_open
    @tree=FilesTree.new(_("Account:head_avatar"),getdirectory(26),false,false,"Documents",[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma"])
    loop do
      loop_update
      @tree.update
      break if escape
      if enter
        pt=@tree.path+@tree.file
        if File.directory?(pt)==false
          avatar_set(pt)
          break
          end
              end
    end
    dialog_close
    $scene=Scene_Main.new
    end
  end
  
  class Scene_Account_WhatsNew
    def main
      wnc=srvproc("whatsnew_config","name=#{$name}\&token=#{$token}\&get=1")
      if wnc[0].to_i<0
        speech(_("General:error"))
        speech_wait
        return $scene=Scene_Main.new
      end
      options=[_("Account:opt_notifyandshow"),_("Account:opt_notify"),_("Account:opt_ignore")]
      cats=[_("Account:head_messages"),_("Account:head_followedthreads"),_("Account:head_followedblogs"),_("Account:head_blogcomments"),_("Account:head_followedforums"),_("Account:head_followedforumsposts"),_("Account:head_contacts"),_("Account:head_birthday"),_("Account:head_mentions")]
      @fields=[]
      for i in 0..cats.size-1
        @fields.push(Select.new(options,true,wnc[i+1].to_i,cats[i],true))
      end
@fields+=[Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))]
      @form=Form.new(@fields)
            loop do
        loop_update
        @form.update
        if (enter or space) and @form.index==@fields.size-2
          heads=["messages","followedthreads","followedblogs","blogcomments","followedforums","followedforumsthreads","friends","birthday","mentions"]
          t=""
          for i in 0..heads.size-1
            t+="&"+heads[i]+"="+@fields[i].index.to_s
          end
          prm="name=#{$name}\&token=#{$token}\&set=1"+t
                    if srvproc("whatsnew_config",prm)[0].to_i<0
            speech(_("General:error"))
          else
            speech(_("General:info_saved"))
            speech_wait
            break
            end
          end
        break if escape or ((enter or space) and @form.index==@fields.size-1)
          
        end
$scene=Scene_Main.new
        end
      end
      
      class Scene_Account_AutoLogins
  def main
        al=[]
    loop do
      password=input_text(_("Account:type_pass"),"PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        return $scene=Scene_Main.new
        break
      else
        al=srvproc("autologins","name=#{$name}\&token=#{$token}\&password=#{password}")
        if al[0].to_i<0
          speech(_("Account:error_identity"))
          speech_wait
        else
          break
          end
        end
    end
    als=[]
    t=0
        for a in al[1..al.size-1]
              case t
    when 0
      ret=0
      tim=""
      begin
        if ret<10        
        tm=Time.at(a.to_i)
        tim=sprintf("%04d-%02d-%02d %02d:%02d",tm.year,tm.month,tm.day,tm.hour,tm.min)
      end
    rescue Exception
      ret+=1
      retry
        end
              als.push([tim])
      t+=1
      when 1
        als.last.push(a.delete("\r\n"))
        t+=1
        when 2
                    als.last.push(a.delete("\r\n"))
          t=0
  end
end
selt=[]
for s in als
  selt.push("Komputer: #{s[2]}, adres IP utworzenia: #{s[1]}, data wygenerowania: #{s[0]}")
end
@sel=Select.new(selt,true,0,_("Account:head_autologintokens"))
loop do
  loop_update
  @sel.update
  break if escape
  break if $scene!=self
  globallogout if $key[0x2e] or enter
  if alt
    case menuselector([_("Account:opt_logoutallsessions"),_("General:str_refresh"),_("General:opt_cancel")])
    when 0
      globallogout
      when 1
        return main
        when 2
          return $scene=Scene_Main.new
          return
          end
    end
  end
$scene=Scene_Main.new
  end
def globallogout
  confirm(_("Account:alert_logoutall")) do
        loop do
      password=input_text(_("Account:type_pass"),"PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        @sel.focus
        return
        break
      else
        lg=srvproc("logout","global=1\&name=#{$name}\&token=#{$token}\&password=#{password}")
        if lg[0].to_i<0
          speech(_("Account:error_identity"))
          speech_wait
        else
          $name=""
          $token=""
          $restart=true
          $scene=Scene_Loading.new
          break
          return
          end
        end
    end
    end
  end
end

class Scene_Account_BlackList
  def main
            bt = srvproc("blacklist","name=#{$name}\&token=#{$token}\&get=1")
            if bt[0].to_i<00
          speech(_("General:error"))
      speech_wait
      $scene = Scene_Main.new
      return
      end
      @blacklist = []
      selt=[]
      if bt.size>1            
      for u in bt[1..bt.size-1]
        @blacklist.push(u.delete("\r\n"))
              selt.push(u + ". " + getstatus(u))
        end
end
        header=_("Account:head_blacklist")
              @sel = Select.new(selt,true,0,header)
                              loop do
loop_update
        @sel.update if @blacklist.size > 0
        update
        if $scene != self
          break
          end
                  end
      end
      def update
        $scene = Scene_Main.new if escape
                            if $key[0x2e]
          if @blacklist.size >= 1
          if simplequestion(_("Account:alert_deletefromblacklist")) == 1
            if srvproc("blacklist","name=#{$name}\&token=#{$token}\&del=1\&user=#{@blacklist[@sel.index]}")[0].to_i<0
              speech(_("General:error"))
            else
              play("edit_delete")
              speech(_("Account:info_deletedfromblacklist"))
            end
            speech_wait
            @blacklist.delete_at(@sel.index)
            @sel.commandoptions.delete_at(@sel.index)
            @sel.focus
            end
          end
          end
        menu if alt
        usermenu(@blacklist[@sel.index],false) if enter and @blacklist.size > 0
                                      end
        def menu
          play("menu_open")
          play("menu_background")
          @menu=menulr(["",_("Account:opt_add"),_("General:str_delete"),_("General:str_refresh"),_("General:str_cancel")],true,0,"",true)
          @menu.commandoptions[0]=@blacklist[@sel.index] if @blacklist.size>0
          if @blacklist.size==0
          @menu.disable_item(2)
          @menu.disable_item(0)
        end
        @menu.focus
          loop do
            loop_update
            @menu.update
            break if escape or alt or $scene!=self
            if enter or (@menu.index==0 and Input.trigger?(Input::DOWN))
              case @menu.index
              when 0
                loop_update
                if usermenu(@blacklist[@sel.index],true) == "ALT"
                break
              else
                                @menu.focus
                              end
                when 1
                  user=input_text(_("Account:type_blacklistaddusername"),"ACCEPTESCAPE")
                  user=finduser(user) if user!="\004ESCAPE\004" and finduser(user).downcase==user.downcase
                  if user=="\004ESCAPE\004"
                                      elsif user_exist(user)==false
                    speech(_("Account:error_usernotfound"))
                    speech_wait
                                      else
                  confirm(_("Account:alert_addtoblacklist")) do
                    bl=srvproc("blacklist","name=#{$name}\&token=#{$token}\&add=1\&user=#{user}")
                    case bl[0].to_i
                    when 0
                      speech(s_("Account:info_phr_addedtoblacklist",{'user'=>user}))
                      @sel.commandoptions.push(user)
                      @blacklist.push(user)
                      when -1
                        speech(_("General:error_db"))
                        when -2
                          speech(_("General:error_tokenexpired"))
                          speech_wait
                          $scene=Scene_Loading.new
                          return
                          when -3
                            speech(_("General:error_blacklistadmin"))
                            when -4
                              speech(_("General:error_blacklistalreadyadded"))
                              when -5
                                speech(_("Account:error_usernotfound"))
                    end
                  speech_wait
                    end
                  end
                  break
                  when 2
                                        confirm(_("Account:alert_deletefromblacklist")) do
            if srvproc("blacklist","name=#{$name}\&token=#{$token}\&del=1\&user=#{@blacklist[@sel.index]}")[0].to_i<0
              speech(_("General:error"))
            else
              play("edit_delete")
              speech(_("Account:info_deletedfromblacklist"))
            end
            speech_wait
            @blacklist.delete_at(@sel.index)
            @sel.commandoptions.delete_at(@sel.index)
            @sel.focus
            end
            break        
            when 3
                      $scene=Scene_Account_BlackList.new
                      break
                      when 4
                        $scene=Scene_Main.new
              break
                        end
              end
            end
play("menu_close")
          Audio.bgs_fade(200)
                  end
        end
#Copyright (C) 2014-2016 Dawid Pieper