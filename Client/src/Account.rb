#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Account
  def initialize
    @settings=[]
  end
  def getconfig
    a=srvproc("account", {'ac'=>'get'})
    @values={}
    if a[0].to_i==0
      @values=JSON.load(a[1])
    end
    end
  def currentconfig(key)
    getconfig if @values==nil
    return @values[key]
  end
  def setcurrentconfig(key,val)
@values[key]=val.to_s
end
  def setting_category(cat)
    @settings.push([cat, nil])
    @form.fields[0].commandoptions.push(cat)
  end
  def on_load(&func)
    return if @settings.size==0
    @settings.last[1]=func
    end
def make_setting(label, type, key, mapping=nil)
  return if @settings.size==0
  mapping=mapping.map{|x|x.to_s} if mapping!=nil
  @settings.last.push([label, type, key, mapping])
end
def save_category
  for i in 2...@settings[@category].size
    setting=@settings[@category][i]
    next if setting[1]==:custom
    index=i-1
    val=@form.fields[index].value
    val=val.to_i if setting[1]==:number or setting[1]==:bool
    val=setting[3][val] if setting[3]!=nil
    setcurrentconfig(setting[2], val)
    end
  end
def show_category(id)
  return if @form==nil or @settings[id]==nil
  save_category if @category!=nil
  @category=id
  @form.show_all
  @form.fields[1..-4]=nil
  f=[]
for s in @settings[id][2..-1]
  label, type, key, mapping = s
  field=nil
  case type
  when :text
    field=Edit.new(label, "", currentconfig(key),true)
    when :longtext
      field=Edit.new(label, "MULTILINE", currentconfig(key),true)
    when :number
    field=Edit.new(label, "NUMBERS", currentconfig(key),true)
    when :bool
      field=CheckBox.new(label, (currentconfig(key).to_i!=0).to_i)
      when :custom
        field=Button.new(label)
        proc=key
        field.on(:press, 0, true, &proc)
    else
      index=currentconfig(key)
      index=mapping.find_index(index)||0 if mapping!=nil
      field=Select.new(type, true, index.to_i, label, true)
    end
@form.fields.insert(-4, field)
end
@settings[id][1].call if @settings[id][1]!=nil
end
def apply_settings
  save_category
  j={}
  for k in @values.keys
    v=@values[k]
    j[k]=v
  end
  json=JSON.generate(j)
  b=buffer(json)
  srvproc("account", {'ac'=>'set', 'buffer'=>b})
  end
def make_window
  @form=Form.new
  @form.fields[0] = Select.new([], true, 0, p_("Account", "Category"), true)
  @form.fields[1]=Button.new(_("Apply"))
  @form.fields[2]=Button.new(_("Save"))
  @form.fields[3]=Button.new(_("Cancel"))
end
def load_profile
  setting_category(p_("Account", "Profile"))
  make_setting(p_("Account", "Full name"), :text, "fullname")
  make_setting(p_("Account", "Gender"), [_("Female"), _("Male")], "gender")
  years=(1900..Time.now.year).to_a
  monthsmapping=(1..12)
  months=[_("January"), _("February"), _("March"), _("April"), _("May"), _("June"), _("July"), _("August"), _("September"), _("October"), _("November"), _("December")]
  days = (1..31).to_a
  make_setting(p_("Account", "Birth date: year"), years.map{|y|y.to_s}, "birthdateyear", years)
  make_setting(p_("Account", "Birth date: month"), months, "birthdatemonth", monthsmapping)
  make_setting(p_("Account", "Birth date: day"), days.map{|y|y.to_s}, "birthdateday", days)
  make_setting(p_("Account", "Country"), [""], "LocationCountry")
  make_setting(p_("Account", "State / Province"), [""], "LocationState")
  make_setting(p_("Account", "City"), [""], "LocationCity")
  on_load {
  @form.fields[4].on(:move) {
  m=@form.fields[4].index+1
  if m==1 or m==3 or m==5 or m==7 or m==8 or m==10 or m==12
    @form.fields[5].enable_item(-1+29)
    @form.fields[5].enable_item(-1+30)
    @form.fields[5].enable_item(-1+31)
  elsif m==2
    @form.fields[5].disable_item(-1+30)
    @form.fields[5].disable_item(-1+31)
  if @form.fields[3].index%4==0 && @form.fields[3].index!=100
    @form.fields[5].enable_item(-1+29)
  else
    @form.fields[5].disable_item(-1+29)
  end
else
  @form.fields[5].enable_item(-1+29)
  @form.fields[5].enable_item(-1+30)
  @form.fields[5].disable_item(-1+31)
end
}
@form.fields[3].on(:move) {@form.fields[4].trigger(:move)}
@form.fields[4].trigger(:move)
location=currentconfig("location")
location_a={}
countries=[""]+Lists.locations.map {|c| location_a=c if c['geonameid']==location.to_i;c['country']}.uniq.polsort
subcountries=[]
cities=[]
ind=[-1, -1, -1]
@form.fields[6].commandoptions=countries
if ind[0]==-1
  ind[0]=countries.find_index(location_a['country'])||0
  @form.fields[6].index=ind[0]
  end
@form.fields[6].on(:move) {
            subcountries=[""]+Lists.locations.map {|c| (c['country']==countries[@form.fields[6].index])?(c['subcountry']):(nil)}.uniq
            subcountries.delete(nil)
            subcountries.polsort!
                        @form.fields[7].commandoptions = subcountries
            if ind[1]==-1
              ind[1]=subcountries.find_index(location_a['subcountry'])||0
              @form.fields[7].index=ind[1]
              else
            @form.fields[7].index=0
            end
            @form.fields[7].trigger(:move)
}
@form.fields[7].on(:move) {
cities=[""]+Lists.locations.map {|c| (c['country']==countries[@form.fields[6].index]&&c['subcountry']==subcountries[@form.fields[7].index])?(c['name']):(nil)}.uniq
cities.delete(nil)
cities.polsort!
@form.fields[8].commandoptions = cities
if ind[2]==-1
  ind[2]=cities.find_index(location_a['name'])||0
  @form.fields[8].index=ind[2]
  else
@form.fields[8].index=0
end
@form.fields[8].trigger(:move)
}
@form.fields[8].on(:move) {
loc=0
Lists.locations.each {|l| loc=l['geonameid'] if l['country']==countries[@form.fields[6].index] and l['subcountry']==subcountries[@form.fields[7].index] and l['name']==cities[@form.fields[8].index]}
setcurrentconfig("location", loc)
}
@form.fields[6].trigger(:move)
  }
end
def load_visitingcard
  setting_category(p_("Account", "Visiting card"))
  make_setting(p_("Account", "Visiting card"), :longtext, 'visitingcard')
end
def load_privacy
  setting_category(p_("Account", "Privacy"))
  make_setting(p_("Account", "Hide my profile for strangers"), :bool, "publicprofile")
  make_setting(p_("Account", "Black list"), :custom, Proc.new{insert_scene(Scene_Account_BlackList.new)})
  end
def load_signs
  setting_category(p_("Account", "Status and signature"))
  make_setting(p_("Account", "Status displayed after your name on all lists of users"), :text, 'status')
  make_setting(p_("Account", "Signature placed below all your forum posts"), :text, 'signature')
end
def load_whatsnew
  setting_category(p_("Account", "What's new notifications"))
  options=[p_("Account", "Notice and show in what's new"),p_("Account", "Notice only"),p_("Account", "Ignore")]
  cats=[p_("Account", "New messages"),p_("Account", "New posts in followed threads"),p_("Account", "New posts on the followed blogs"),p_("Account", "New comments on your blog"),p_("Account", "New threads on followed forums"),p_("Account", "New posts on followed forums"),p_("Account", "New friends"),p_("Account", "Friends' birthday"),p_("Account", "Mentions")]
  sets = ["wn_messages", "wn_followedthreads", "wn_followedblogs", "wn_blogcomments", "wn_followedforums", "wn_followedforumsthreads", "wn_friends", "wn_birthday", "wn_mentions"]
  for i in 0...sets.size
    make_setting(cats[i], options, sets[i])
    end
  end
  def load_security
    setting_category(p_("Account", "Account security"))
    make_setting(p_("Account", "Change e-mail"), :custom, Proc.new{insert_scene(Scene_Account_Mail.new)})
    make_setting(p_("Account", "Change password"), :custom, Proc.new{insert_scene(Scene_Account_Password.new)})
    make_setting(p_("Account", "Manage Two-Factor authentication"), :custom, Proc.new{insert_scene(Scene_Authentication.new)})
    make_setting(p_("Account", "Manage mail events-reporting"), :custom, Proc.new{insert_scene(Scene_Account_MailEvents.new)})
    make_setting(p_("Account", "Manage auto-login tokens"), :custom, Proc.new{insert_scene(Scene_Account_AutoLogins.new)})
    make_setting(p_("Account", "Show last logins"), :custom, Proc.new{insert_scene(Scene_Account_Logins.new)})
    end
      def main
        make_window
        load_profile
        load_visitingcard
        load_signs
        load_whatsnew
        load_privacy
        load_security
        @form.focus
        loop do
          loop_update
          @form.update
          show_category(@form.fields[0].index) if @category!=@form.fields[0].index
          if @form.fields[-3].pressed?
            apply_settings
            speak(_("Saved"))
          end
                    if @form.fields[-2].pressed? or (enter and !@form.fields[@form.index].is_a?(Button))
            apply_settings
            alert(_("Saved"))
            $scene=Scene_Main.new
          end
          if escape or @form.fields[-1].pressed?
            $scene=Scene_Main.new
          end
          break if $scene!=self
        end
      end
    end
    
    
    
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
          Session.name=""
          Session.token=""
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
        @sel.update
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
          Session.name=""
          Session.token=""
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