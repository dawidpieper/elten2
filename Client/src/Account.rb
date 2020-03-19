#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Account_Password
  def main
      oldpassword = ""
  password = ""
  repeatpassword = ""
  while oldpassword == ""
    oldpassword = input_text(p_("Account", "Enter your old password."),"password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    while password == ""
    password = input_text(p_("Account", "Enter your new password."),"password|ACCEPTESCAPE")
  end
  if oldpassword == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while repeatpassword == ""

      repeatpassword = input_text(p_("Account", "Repeat new password."),"password|ACCEPTESCAPE")
  end
  if repeatpassword == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
  if password != repeatpassword
    alert(p_("Account", "Fields: New Password and Repeat New Password have different values."))
    main
  end
    act = srvproc("account_mod", {"changepassword"=>"1", "oldpassword"=>oldpassword, "password"=>password})
    err = act[0].to_i
  case err
  when 0
    alert(p_("Account", "Your password has been changed."))
        $scene = Scene_Main.new
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        when -6
          alert(p_("Account", "The old password is incorrect."))
          $scene = Scene_Main.new
  end
    end
end

class Scene_Account_Mail
  def main
      password = ""
  mail = ""
  while password == ""
    password = input_text(p_("Account", "Enter your password."),"password|ACCEPTESCAPE")
  end
  if password == "\004ESCAPE\004"
    $scene = Scene_Main.new
    return
  end
    while mail == ""
    mail = input_text(p_("Account", "Enter a new e-mail address."),"ACCEPTESCAPE")
  end
  if mail == "\004ESCAPE\004"
        $scene = Scene_Main.new
    return
  end
    act = srvproc("account_mod", {"changemail"=>"1", "oldpassword"=>password, "mail"=>mail})
    err = act[0].to_i
  case err
  when 0
    alert(p_("Account", "E-mail has been changed."))
    $scene = Scene_Main.new
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        when -6
          alert(p_("Account", "The old password is incorrect."))
          $scene = Scene_Main.new
          when -7
alert(p_("Account", "Error, you must disable mail events reporting first."))            
            speech_wait
            $scene = Scene_Main.new
  end
    end
end

class Scene_Account_VisitingCard
  def main
    dialog_open
            vc = srvproc("visitingcard",{"searchname"=>$name})
        err = vc[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..vc.size - 1
        text += vc[i]
      end
@form = Form.new([Edit.new(p_("Account", "Your visiting card:"),"MULTILINE",text,true),Button.new(_("Save")),Button.new(_("Cancel"))])
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
      vc = srvproc("visitingcard_mod",{"buffer"=>buf}      )
err = vc[0].to_i
case err
when 0
  alert(_("Saved"))
  $scene = Scene_Main.new
  when -1
    alert(_("Database Error"))
    $scene = Scene_Main.new
    when -2
      alert(_("Token expired"))
      $scene = Scene_Loading.new
end
dialog_close    
end
  end
  
  class Scene_Account_Status
    def main
            alert(p_("Account", "Change your status"))
      text = ""
      while text == ""
      text = input_text(p_("Account", "Enter a new status"),"ACCEPTESCAPE")
    end
    if text == "\004ESCAPE\004"
      $scene = Scene_Main.new
      return
    end
    ef = setstatus(text)
    if ef != 0
      alert(_("Error"))
    else
      alert(p_("Account", "Your status has been changed."))
    end
    speech_wait
    $scene = Scene_Main.new
        end
  end
  
  class Scene_Account_Profile
    def main
                  profile = srvproc("profile",{"searchname"=>$name, "get"=>"1"})
                    fullname = ""
        gender = 0
        birthdateyear = 0
        birthdatemonth = 0
        birthdateday = 0
        location = ""
        publicprofile = 0
        publicmail = 0
if profile[0].to_i == 0
        fullname = profile[1].delete("\r\n")
        gender = profile[2].delete("\r\n").to_i
        birthdateyear = profile[3].to_i
        birthdatemonth = profile[4].to_i
        birthdateday = profile[5].to_i
        location = profile[6].delete("\r\n")
        publicprofile = profile[7].to_i
        publicmail = profile[8].to_i
      end
      fields = []
      fields.push(Edit.new(p_("Account", "Full name"),"",fullname,true))
      fields.push(Select.new([_("Female"),_("male")],false,gender,p_("Account", "Gender"),true))
      @years=[]
      for i in 1900..Time.now.year
        @years.push(i.to_s)
      end
      @years.push("")
      @years.reverse!
      fields.push(Select.new(@years,true,@years.find_index(birthdateyear.to_s)||0,p_("Account", "Birth date: year"),true))
      fields.push(nil)
      fields.push(nil)
location_a={}
      @countries=[""]+$locations.map {|c| location_a=c if c['geonameid']==location.to_i;c['country']}.uniq.polsort
                                        fields.push(Select.new(@countries,true,@countries.find_index(location_a['country'])||0,p_("Account", "Country"),true))
                                        fields.last.index=@countries.find_index(location)||0 if fields.last.index==0 and location!=""
      fields.push(nil)
      fields.push(nil)
      fields.push(CheckBox.new(p_("Account", "Hide my profile for strangers"),publicprofile))
      vc = srvproc("visitingcard",{"searchname"=>$name})
        err = vc[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..vc.size - 1
text += vc[i]
end
fields.push(Edit.new(p_("Account", "Your visiting card:"),Edit::Flags::MultiLine,text,true))
fields.push(Edit.new(p_("Account", "Enter a new status"),"",getstatus($name,false),true))
            sg = srvproc("signature",{"searchname"=>$name, "get"=>"1"})
        err = sg[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..sg.size - 1
        text += sg[i]
      end
      fields.push(Edit.new(p_("Account", "Your signature:"),"Edit::Flags::MultiLine",text,true))
      fields.last.max_length=256
      fields.push(Button.new(_("Save")))
      fields.push(Button.new(_("Cancel")))
            @form = Form.new(fields)
      loop do
        loop_update
        @form.update
        @oldmonth=fields[3].index if fields[3]!=nil
        @oldday=fields[4].index if fields[4]!=nil
        if fields[2].index>0 and fields[3]==nil
          ind=0
          ind=birthdatemonth.to_i if @months==nil
          ind=@oldmonth if ind==0 and @oldmonth!=nil
                    @months||=["",p_("Account", "January"),p_("Account", "February"),p_("Account", "March"),p_("Account", "April"),p_("Account", "May"),p_("Account", "June"),p_("Account", "July"),p_("Account", "August"),p_("Account", "September"),p_("Account", "October"),p_("Account", "November"),p_("Account", "December")]
          fields[3]=Select.new(@months,true,ind,p_("Account", "Birth date: month"),true)
        elsif fields[2].index==0
          fields[3]=nil
        end
        if fields[2].index>0 and fields[3].index>0
          ind=0
          ind=birthdateday if @olddate==nil
          ind=@oldday if ind==0 and @oldday!=nil
          if @olddate!=[fields[2].index,fields[3].index]
            @olddate=[fields[2].index,fields[3].index]
            @days=[""]
            for i in 1..31
              @days.push(i.to_s) if i<29 or (i==29 and (@years[fields[2].index].to_i!=1900 and @years[fields[2].index].to_i%4==0)) or (i<31 and fields[3].index!=2) or (i==31 and [1,3,5,7,8,10,12].include?(fields[3].index))
            end
            fields[4]=Select.new(@days,true,ind,p_("Account", "Birth date: day"),true)
          end
        elsif fields[2].index==0 or fields[3].index==0
          fields[4]=nil
          end
        if fields[5].index>0
          if @oldcountryindex!=fields[5].index
            ind=0
            @oldcountryindex=fields[5].index
            @oldsubcountryindex=nil
            fields[6].index=0 if fields[6]!=nil
            @subcountries=[""]+$locations.map {|c| (c['country']==@countries[fields[5].index])?(c['subcountry']):(nil)}.uniq
            @subcountries.delete(nil)
            @subcountries.polsort!
            ind=@subcountries.find_index(location_a['subcountry'])||0 if @subcountryinit==nil
            @subcountryinit=true
            fields[6]=Select.new(@subcountries,true,ind,p_("Account", "State / Province"),true)
          end
        elsif fields[5].index==0
          @oldcountryindex=nil
          fields[6]=nil
          end
          if fields[5].index>0 and (fields[6]!=nil and fields[6].index>0)
          if @oldsubcountryindex!=fields[6].index
            ind=0
            @oldsubcountryindex=fields[6].index
            fields[7].index=0 if fields[7]!=nil
            @cities=[""]+$locations.map {|c| (c['country']==@countries[fields[5].index]&&c['subcountry']==@subcountries[fields[6].index])?(c['name']):(nil)}.uniq
            @cities.delete(nil)
            @cities.polsort!
            ind=@cities.find_index(location_a['name'])||0 if @cityinit==nil
            @cityinit=true
            fields[7]=Select.new(@cities,true,ind,p_("Account", "City"),true)
          end
        elsif fields[5].index==0 or (fields[6]!=nil and fields[6].index==0)
          @oldsubcountryindex=nil
          fields[7]=nil
          end
        if ((space or enter) and @form.index == 12) or (enter and $key[0x11])
$fullname=fields[0].text_str
$gender=fields[1].index
pro={"fullname"=>fields[0].text_str, "gender"=>fields[1].index.to_s}
if fields[2].index>0 and (fields[3]!=nil and fields[3].index>0) and (fields[4]!=nil and fields[4].index>0)
pro["birthdateyear"]=@years[fields[2].index]
pro["birthdatemonth"]=fields[3].index.to_s
pro["birthdateday"]=@days[fields[4].index].to_s
end
if fields[7]!=nil
  loc=0
    $locations.each {|l| loc=l['geonameid'] if l['country']==@countries[fields[5].index] and l['subcountry']==@subcountries[fields[6].index] and l['name']==@cities[fields[7].index]}
  pro["location"]=loc.to_s
elsif fields[5].index>0
  pro["location"]=@countries[fields[5].index]
end
pro["publicprofile"]=fields[8].checked
pro["mod"]=1
          pr = srvproc("profile",pro)
          if pr[0].to_i==0
            buf = buffer(fields[9].text_str)
      pr = srvproc("visitingcard_mod",{"buffer"=>buf}      )
    end
    pr=[setstatus(fields[10].text_str)] if pr[0].to_i==0
    if pr[0].to_i==0
            buf = buffer(fields[11].text_str)
      pr = srvproc("signature",{"buffer"=>buf, "set"=>"1"})
    end
          if pr[0].to_i < 0
    alert(_("Error"))
else
  alert(_("Saved"))
end
$scene = Scene_Main.new
          end
        $scene = Scene_Main.new if escape or ((space or enter) and @form.index == 13)
        break if $scene != self
        end
          end
        end
        
        class Scene_Account_Signature
  def main
    dialog_open
            sg = srvproc("signature",{"searchname"=>$name, "get"=>"1"})
        err = sg[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..sg.size - 1
        text += sg[i]
      end
@form = Form.new([Edit.new(p_("Account", "Your signature:"),"MULTILINE",text,true),Button.new(_("Save")),Button.new(_("Cancel"))])
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
      sg = srvproc("signature",{"buffer"=>buf, "set"=>"1"})
err = sg[0].to_i
case err
when 0
  alert(_("Saved"))
  $scene = Scene_Main.new
  when -1
    alert(_("Database Error"))
    $scene = Scene_Main.new
    when -2
      alert(_("Token expired"))
      $scene = Scene_Loading.new
end
dialog_close    
end
end

class Scene_Account_Greeting
  def main
    dialog_open
            gt = srvproc("greetings",{"searchname"=>$name, "get"=>"1"})
        err = gt[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Loading.new
        return
      end
      text = ""
      for i in 1..gt.size - 1
        text += gt[i]
      end
@form = Form.new([Edit.new(p_("Account", "Your welcome message:"),"",text,true),Button.new(_("Save")),Button.new(_("Cancel"))])
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
      gt = srvproc("greetings",{"buffer"=>buf, "set"=>"1"})
err = gt[0].to_i
case err
when 0
  alert(_("Saved"))
  $scene = Scene_Main.new
  when -1
    alert(_("Database Error"))
    $scene = Scene_Main.new
    when -2
      alert(_("Token expired"))
      $scene = Scene_Loading.new
end
dialog_close    
end
end
  
  class Scene_Account_WhatsNew
    def main
      wnc=srvproc("whatsnew_config",{"get"=>"1"})
      if wnc[0].to_i<0
        alert(_("Error"))
        return $scene=Scene_Main.new
      end
      options=[p_("Account", "Notice and show in what's new"),p_("Account", "Notice only"),p_("Account", "Ignore")]
      cats=[p_("Account", "New messages"),p_("Account", "New posts in followed threads"),p_("Account", "New posts on the followed blogs"),p_("Account", "New comments on your blog"),p_("Account", "New threads on followed forums"),p_("Account", "New threads on followed forums"),p_("Account", "New friends"),p_("Account", "Friends' birthday"),p_("Account", "Mentions")]
      @fields=[]
      for i in 0..cats.size-1
        @fields.push(Select.new(options,true,wnc[i+1].to_i,cats[i],true))
      end
@fields+=[Button.new(_("Save")),Button.new(_("Cancel"))]
      @form=Form.new(@fields)
            loop do
        loop_update
        @form.update
        if (enter or space) and @form.index==@fields.size-2
          heads=["messages","followedthreads","followedblogs","blogcomments","followedforums","followedforumsthreads","friends","birthday","mentions"]
          t=""
          prm={"set"=>"1"}
          for i in 0..heads.size-1
            prm[heads[i]]=@fields[i].index.to_s
          end
                    if srvproc("whatsnew_config",prm)[0].to_i<0
            alert(_("Error"))
          else
            alert(_("Saved"))
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
      password=input_text(p_("Account", "Enter your password."),"PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        return $scene=Scene_Main.new
        break
      else
        al=srvproc("autologins",{"password"=>password})
        if al[0].to_i<0
          alert(p_("Account", " An error occurred while authenticating the account. You might have provided an  incorrect password."))
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
              tm=Time.at(a.to_i)
        tim=sprintf("%04d-%02d-%02d %02d:%02d",tm.year,tm.month,tm.day,tm.hour,tm.min)
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
selh=[p_("Account", "Computer"),p_("Account", "Creation IP Address"),p_("Account", "Generation date")]
selt=[]
for s in als
  selt.push([s[2],s[1],s[0]])
end
@sel=TableSelect.new(selh,selt,0,p_("Account", "Auto log in tokens"))
@sel.bind_context{|menu|
    menu.option(p_("Account", "Log out all sessions")) {
          globallogout
    }
    menu.option(_("Refresh")) {
    main
    }
        }
loop do
  loop_update
  @sel.update
  break if escape
  break if $scene!=self
  globallogout if $key[0x2e] or enter
  end
$scene=Scene_Main.new
  end
def globallogout
  confirm(p_("Account", " Are you sure you want to remove all auto log in tokens and log out all sessions?  You will be logged off immediately.")) do
        loop do
      password=input_text(p_("Account", "Enter your password."),"PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        @sel.focus
        return
        break
      else
        lg=srvproc("logout", {"global"=>"1", "password"=>password})
        if lg[0].to_i<0
          alert(p_("Account", " An error occurred while authenticating the account. You might have provided an  incorrect password."))
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
            bt = srvproc("blacklist",{"get"=>"1"})
            if bt[0].to_i<00
          alert(_("Error"))
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
        header=p_("Account", "Black list")
              @sel = Select.new(selt,true,0,header)
              @sel.bind_context{|menu|context(menu)}
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
          if confirm(p_("Account", "Are you sure you want to remove this user from the black list?")) == 1
            if srvproc("blacklist",{"del"=>"1", "user"=>@blacklist[@sel.index]})[0].to_i<0
              alert(_("Error"))
            else
              play("edit_delete")
              alert(p_("Account", "A user has been removed from the black list."))
            end
            speech_wait
            @blacklist.delete_at(@sel.index)
            @sel.commandoptions.delete_at(@sel.index)
            @sel.focus
            end
          end
          end
        usermenu(@blacklist[@sel.index],false) if enter and @blacklist.size > 0
                                      end
        def context(menu)
          s=""
          if @blacklist.size>0
            menu.useroption(@blacklist[@sel.index])
            end
          menu.option(p_("Account", "Add")) {
                            user=input_text(p_("Account", "Type a username which you want to add to blacklist."),"ACCEPTESCAPE")
                  user=finduser(user) if user!="\004ESCAPE\004" and finduser(user).downcase==user.downcase
                  if user=="\004ESCAPE\004"
                                      elsif user_exist(user)==false
                    alert(p_("Account", "The user cannot be found."))
                                      else
                  confirm(p_("Account", " The users added to your black list cannot send you private messages. Are you sure  you want to continue?")) do
                    bl=srvproc("blacklist",{"add"=>"1", "user"=>user})
                    case bl[0].to_i
                    when 0
                      speech(p_("Account", "User %{user} has been added to your blacklist")%{'user'=>user})
                      @sel.commandoptions.push(user)
                      @blacklist.push(user)
                      when -1
                        alert(_("Database Error"))
                        when -2
                          alert(_("Token expired"))
                          $scene=Scene_Loading.new
                          return
                          when -3
                            alert(p_("Account", "You cannot add an administrator to the black list."))
                            when -4
                              alert(p_("Account", "This user is already on your black list."))
                              when -5
                                alert(p_("Account", "The user cannot be found."))
                    end
                  speech_wait
                    end
                  end
          }
          if @blacklist.size>0
          menu.option(_("Delete")) {
                                                  confirm(p_("Account", "Are you sure you want to remove this user from the black list?")) do
            if srvproc("blacklist",{"del"=>"1", "user"=>@blacklist[@sel.index]})[0].to_i<0
              alert(_("Error"))
            else
              play("edit_delete")
              alert(p_("Account", "A user has been removed from the black list."))
            end
            speech_wait
            @blacklist.delete_at(@sel.index)
            @sel.commandoptions.delete_at(@sel.index)
            @sel.focus
            end
          }
          end
          menu.option(_("Refresh")) {
                                $scene=Scene_Account_BlackList.new
          }
                  end
                end
                
                class Scene_Account_Logins
  def main
        lg=[]
    loop do
      password=input_text(p_("Account", "Enter your password."),"PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        return $scene=Scene_Main.new
        break
      else
        lg=srvproc("lastlogins",{"password"=>password})
        if lg[0].to_i<0
          alert(p_("Account", " An error occurred while authenticating the account. You might have provided an  incorrect password."))
        else
          break
          end
        end
    end
    lgs=[]
    t=0
        for l in lg[1...lg.size]
              case t
    when 0
      ret=0
      tim=""
              tm=Time.at(l.to_i)
        tim=sprintf("%04d-%02d-%02d %02d:%02d",tm.year,tm.month,tm.day,tm.hour,tm.min)
              lgs.push([tim])
      t+=1
      when 1
        lgs.last.push(l.delete("\r\n"))
                  t=0
  end
end
selh=["",""]
selt=[]
for s in lgs
  selt.push([s[0],s[1]])
end
@sel=TableSelect.new(selh,selt,0,p_("Account", "Last logins"))
loop do
  loop_update
  @sel.update
  break if escape
  globallogout if $key[0x2e] or enter
  end
$scene=Scene_Main.new
  end
def globallogout
  confirm(p_("Account", " Are you sure you want to remove all auto log in tokens and log out all sessions?  You will be logged off immediately.")) do
        loop do
      password=input_text(p_("Account", "Enter your password."),"PASSWORD|ACCEPTESCAPE")
      if password=="\004ESCAPE\004"
        @sel.focus
        return
        break
      else
        lg=srvproc("logout", {"global"=>"1", "password"=>password})
        if lg[0].to_i<0
          alert(p_("Account", " An error occurred while authenticating the account. You might have provided an  incorrect password."))
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

class Scene_Account_MailEvents
  def main
    @password=input_text(p_("Account", "Enter your password."),"PASSWORD|ACCEPTESCAPE") if @password==nil
    return $scene=Scene_Main.new if @password=="\004ESCAPE\004"
          vr=srvproc("mailevents",{"password"=>@password, "ac"=>"check"})
          if vr[0].to_i<0
            alert(_("Error"))
            return $scene=Scene_Main.new
          end
chk=vr[1].to_i
if chk==0
  confirm(p_("Account", "If you wish, you can configure Elten to report any changes and logins  on your account from new devices to you by E-mail. To do this, you must verify your E-mail address. Do you want to do it now?")) {
  vf=srvproc("mailevents",{"password"=>@password, "ac"=>"verify"})
  if vf[0].to_i<0
    alert(_("Error"))
    return $scene=Scene_Main.new
  end
  code=input_text(p_("Account", "The verification code has been sent to you via E-mail. Please type it here."))
    vf=srvproc("mailevents",{"password"=>@password, "ac"=>"verify", "code"=>code})
  if vf[0].to_i<0
    alert(_("Error"))
    return $scene=Scene_Main.new
  else
    return main
  end
  }
  $scene=Scene_Main.new if $scene==self
else
enb=vr[2].to_i
opt=(enb==0)?p_("Account", "Enable mail events reporting"):p_("Account", "Disable mail events reporting")
h=(enb==0)?p_("Account", "Mail events reporting is disabled. If you wish, you can enable it to receive information about changes made on your account and logins from new devices via E-mail"):p_("Account", "Mail events reporting is enabled.")
@sel=menulr([opt,_("Exit")],true,0,h)
loop do
  loop_update
  @sel.update
  if enter
    case @sel.index
    when 0
e=0
e=1 if enb==0
srvproc("mailevents", {"password"=>@password, "ac"=>"events", "enable"=>e.to_s})
if e==0
  code=input_text(p_("Account", "The verification code has been sent to you via E-mail. Please type it here."))
  srvproc("mailevents", {"password"=>@password, "ac"=>"events", "enable"=>e.to_s, "code"=>code})
  end
return main
      when 1
        $scene=Scene_Main.new
      end
      end
  break if $scene!=self
end  
end
    end
  end