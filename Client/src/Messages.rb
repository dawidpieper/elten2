#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Messages
    def initialize(wn=2000)
      $notifications_callback = Proc.new {|notif|
if notif['cat']==1
  play(notif['sound']) if notif['sound']!=nil
else
  speech(notif['alert']) if notif['alert']!=nil
  play(notif['sound']) if notif['sound']!=nil
  end
      }
          if wn==true or wn==false or wn.is_a?(Integer)
      @wn=wn
    elsif wn.is_a?(Array)
            import(wn)
      @imported=true
      end
    end
  def main()
   if @imported!=true
    if @wn!=true
    @cat=0
    load_users
  else
    @cat=1
    load_conversations("","new")
  end
else
case @cat
when 0
  @sel_users.focus
  when 1
    @sel_conversations.focus
    when 2
      @form_messages.fields[@form_messages.index].focus
      load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit, true)
end
  @imported=false
  end
   loop do
     loop_update
     break if $scene!=self
     case @cat
     when 0
       update_users
       when 1
         update_conversations
         when 2
           update_messages
     end
        end
   loop_update
 end
def export
  return [@wn,@cat,@users,@sel_users,@conversations,@conversations_user,@conversations_sp,@sel_conversations,@messages,@messages_subject,@messages_user,@messages_sp,@sel_messages,@form_messages]
end
def import(arr)
    @wn,@cat,@users,@sel_users,@conversations,@conversations_user,@conversations_sp,@sel_conversations,@messages,@messages_subject,@messages_user,@messages_sp,@sel_messages,@form_messages=arr
  end
  def name_conversation(conv)
        if $conversations==nil or ($conversationstime||0)<Time.now.to_f-90
          $conversations={}
      $conversationstime=Time.now.to_f
      c=srvproc("messages_groups",{"ac"=>"name"})
      if c[0].to_i==0
        for i in 0...c[1].to_i
          $conversations[c[i*2+2].delete("\r\n")]=c[i*2+3].delete("\r\n")
          end
        end
    end
    $conversations[conv]||conv
    end
 def load_users(limit=@users_limit||20)
   @lastuser=nil
   @lastuser=@users[@sel_users.index] if @users.is_a?(Array) and @sel_users.is_a?(Select)
   @users=[]
   @users_limit=limit
    msg=srvproc("messages_conversations",{"limit"=>@users_limit})
    if msg[0].to_i<0
      alert(_("Error"))
      return $scene=Scene_Main.new
      end
l=0
@users_more=(msg[2].to_i==1)?true:false
for i in 3..msg.size-1
  line=msg[i].delete("\r\n")
  case l
  when 0
    @users.push(Struct_Messages_User.new(line))
    when 1
    @users[-1].lastuser=line
    when 2
        @users[-1].lastdate=Time.at(line.to_i)
        when 3
          @users[-1].lastsubject=line
      when 4
        @users[-1].read=line.to_i
        when 5
          @users[-1].lastid=line.to_i
              end
      l+=1
      l=0 if l==6
    end
    selt=[]
    ind=0
    for u in @users
      user=u.user
      user=name_conversation(user) if user[0..0]=="["
            selt.push(user+":\r\n"+p_("Messages", "Last message")+": "+u.lastuser+": "+u.lastsubject+".\r\n"+sprintf("%04d-%02d-%02d %02d:%02d",u.lastdate.year,u.lastdate.month,u.lastdate.day,u.lastdate.hour,u.lastdate.min)+"\r\n")
      selt[-1]+="\004INFNEW{#{p_("Messages", "New")}: }\004" if u.read==0 and u.lastuser!=$name
      ind=selt.size-1 if u.user==@lastuser.user if @lastuser!=nil
    end
selt.push(p_("Messages", "Show older")) if @users_more
    @sel_users=Select.new(selt,true,ind,p_("Messages", "Messages"))
    @sel_users.bind_context{|menu|context_users(menu)}
end
def update_users
  @sel_users.update
  if enter or arrow_right
    if @sel_users.index<@users.size
    load_conversations(@users[@sel_users.index].user)
    @cat=1
  else
    @sel_users.index-=1
    load_users(@users_limit+20)
    speech @sel_users.commandoptions[@sel_users.index]
    end
  end
  $scene=Scene_Main.new if escape
end
def context_users(menu)
  if @users.size >0 and @sel_users.index<@users.size
menu.option(p_("Messages", "Reply")) {
  $scene = Scene_Messages_New.new(@users[@sel_users.index].user,"","",export)
}
end
if @users[@sel_users.index].user[0..0]=="["
menu.option(p_("Messages", "Leave")) {
    confirm(p_("Messages", "Are you sure you want to leave this group?")) {
    srvproc("messages_groups",{"ac"=>"leave", "groupid"=>@users[@sel_users.index].user})
    }
    load_users
        @sel_users.focus
}
end
menu.option(p_("Messages", "Create new conversation")) {
    new_conversation
    @sel_users.focus
}
menu.option(p_("Messages", "Send a new message")) {
$scene = Scene_Messages_New.new("","","",export)
}
menu.option(p_("Messages", "Mark all messages as read")) {
  msgtemp = srvproc("message_allread",{})
    if msgtemp[0].to_i < 0
    alert(_("Error"))
    $scene = Scene_Main.new
    end
    alert(p_("Messages", "All messages have been marked as read."))
speech_wait
if @wn == true
  $scene = Scene_WhatsNew.new
else
  main
  end
}
menu.option(p_("Messages", "Search")) {
    load_messages("","","search")
@cat=2
}
menu.option(p_("Messages", "Show flagged messages")) {
load_messages("","","flagged")
@cat=2
}
menu.option(_("Refresh")) {
main
}
end
def new_conversation
  form=Form.new([
  Edit.new(p_("Messages", "Conversation name"),"","",true),
  Select.new([$name,p_("Messages", "Add user to this conversation")],true,0,p_("Messages", "Conversation members")),
  Button.new(p_("Messages", "Create")),
  Button.new(_("Cancel"))
  ])
  cre=form.fields[2]
  form.fields[2]=nil
  users=[$name]
  loop do
    loop_update
    form.update
    break if form.fields[3].pressed? or escape
    if enter and form.index==1 and form.fields[1].index==users.size and users.size<10
      user=input_text(p_("Messages", "User to add"),"ACCEPTESCAPE")
      if user!="\004ESCAPE\004"
        user=finduser(user) if finduser(user).downcase==user.downcase
        if user_exist(user) and !users.include?(user)
          users.push(user)
         form.fields[1].commandoptions.insert(users.size-1,user)
       end
       form.fields[1].focus
        end
    end
    if form.index==1 and $key[0x2e] and form.fields[1].index>0 and form.fields[1].index<users.size
      play("edit_delete")
      users.delete_at(form.fields[1].index)
      form.fields[1].commandoptions.delete_at(form.fields[1].index)
      speak(form.fields[1].commandoptions[form.fields[1].index])
    end
    if users.size>1 and form.fields[0].text.size>0
      form.fields[2]=cre
    else
      form.fields[2]=nil
    end
if form.fields[2]!=nil and form.fields[2].pressed?
  r=srvproc("messages_groups",{"ac"=>"create", "groupname"=>form.fields[0].text, "users"=>users.join},")}")
  if r[0].to_i<0
    alert(_("Error"))
  else
    alert(p_("Messages", "Conversation has been created"))
  end
  speech_wait
  load_users
  break
  end
    end
    loop_update
  end
  def load_conversations(user,sp=nil,limit=@conversations_limit||20)
    msg=""
    if sp==nil
    @user=user
   @lastconversation=nil
   @lastconversation=@conversations[@sel_conversations.index] if @conversations.is_a?(Array) and @sel_conversations.is_a?(Select)
   @lastconversation_user=user
   @conversations=[]
   @conversations_user=user
   @conversations_limit=limit
msg=srvproc("messages_conversations",{"user"=>user, "limit"=>@conversations_limit.to_i})
   else
   @conversations_sp=sp
   @conversations=[]
   msg=srvproc("messages_conversations",{"sp"=>sp})
 end
         if msg[0].to_i<0
      alert(_("Error"))
      return $scene=Scene_WhatsNew.new
      end
if msg[1].to_i==0 and sp=='new'
  alert(p_("Messages", "There are no new messages"))
  return $scene=Scene_WhatsNew.new
  end
      @conversations_more=(msg[2].to_i==1)?true:false
      l=0
for i in 4..msg.size-1
  line=msg[i].delete("\r\n")
  case l
  when 0
    @conversations.push(Struct_Messages_Conversation.new(line))
    when 1
    @conversations[-1].lastuser=line
    when 2
        @conversations[-1].lastdate=Time.at(line.to_i)
      when 3
        @conversations[-1].read=line.to_i
        when 4
          @conversations[-1].lastid=line.to_i
              end
      l+=1
      l=0 if l==5
    end
        selt=[]
        ind=0
    for c in @conversations
      lu=c.lastuser
      lu=name_conversation(lu) if lu[0..0]=="["
      selt.push(((c.subject!="")?(c.subject):p_("Messages", "No subject"))+":\r\n"+((sp==nil)?p_("Messages", "Last message"):p_("Messages", "From"))+": "+lu+".\r\n"+sprintf("%04d-%02d-%02d %02d:%02d",c.lastdate.year,c.lastdate.month,c.lastdate.day,c.lastdate.hour,c.lastdate.min)+"\r\n")
      selt[-1]+="\004INFNEW{#{p_("Messages", "New")}: }\004" if c.read==0 and c.lastuser!=$name
      ind=selt.size-1 if c.subject==@lastconversation.subject and user==@lastconversation_user if @lastconversation!=nil and @lastconversation_user!=nil
    end
    selt.push(p_("Messages", "Show older")) if @conversations_more
    u=user
    u=name_conversation(user) if user[0..0]=="["
    @sel_conversations=Select.new(selt,true,ind,((sp==nil)?(p_("Messages", "Conversations with %{user}")%{'user'=>u}):""))
    @sel_conversations.bind_context{|menu|context_conversations(menu)}
  end
  def update_conversations
    @sel_conversations.update
    if enter or arrow_right
      if @sel_conversations.index<@conversations.size
      load_messages(@conversations_user||@conversations[@sel_conversations.index].lastuser,@conversations[@sel_conversations.index].subject,@conversations_sp)
      @cat=2
    else
      @sel_conversations.index-=1
      load_conversations(@conversations_user,nil,@conversations_limit+20)
speech @sel_conversations.commandoptions[@sel_conversations.index]
      end
      end
    if escape or arrow_left or @sel_conversations.commandoptions.size==0
      if @conversations_sp!="new"
      load_users
      loop_update
      @cat=0
      @sel_conversations=nil
    else
      return $scene=Scene_WhatsNew.new
    end
    end
    end
def context_conversations(menu)
  if @conversations.size >0 and @sel_conversations.index<@conversations.size
menu.option(p_("Messages", "Reply")) {
  $scene = Scene_Messages_New.new(@user,"RE: "+@conversations[@sel_conversations.index].subject,"",export)
}
end
if @conversations_sp!="new"
menu.option(p_("Messages", "Send a new message")) {
$scene = Scene_Messages_New.new("","","",export)
}
end
menu.option(_("Refresh")) {
main
}
end
    def load_messages(user,subject,sp=nil,limit=@messages_limit||50,complete=false)
                     @messages=[] if !complete
   @messages_user=user
   @messages_subject=subject
   @messages_sp=sp
   @messages_limit=limit if !complete
   msg=""
   if sp=="flagged"
     msg=srvproc("messages_conversations",{"sp"=>"flagged"})
   elsif sp=="search"
     term=input_text(p_("Messages", "Enter a phrase to look for"),"ACCEPTESCAPE",@lastsearch||"")
     if term=="\004ESCAPE\004"
       @cat=0
       return
       end
                   @lastsearch=term
     msg=srvproc("messages_conversations",{"sp"=>"search", "search"=>term})
     else
   msg=srvproc("messages_conversations",{"user"=>user, "subj"=>subject, "limit"=>@messages_limit.to_s})
   end
@messages_wn=0
   if $agent_msg!=nil
     @messages_wn=$agent_msg
       end
   if msg[0].to_i<0
            alert(_("Error"))
      return $scene=Scene_Main.new
      end
@messages_more=(msg[2].to_i==1)?true:false if !complete
      m=nil
curids=[]
@messages.each {|m| curids.push(m.id)}
for mesg in msg[4..-1].join.split("\r\n\004END\004")
  mesg[0..1]="" if mesg[0..1]=="\r\n"
  next if mesg==""
  message=mesg.split("\r\n")
      for l in 0..7
        line=message[l]
  case l
  when 0
    m=Struct_Message.new(line.to_i)
        when 1
    m.sender=line
    m.receiver=((m.sender==$name)?user:$name)
when 2
  m.subject=line
    when 3
                  m.date=Time.at(line.to_i)
                when 4
                m.mread=line.to_i
        when 5
          m.marked=line.to_i
          when 6
            m.attachments=(line||"").split(",")
            m.attachments.delete(nil) if m.attachments.size>0
            name_attachments(m.attachments, m.attachments_names) if m.attachments.size>0
            when 7
        m.text=message[l..-1].join("\n")
        if !(complete and curids.include?(m.id))
          o=(complete)?0:(@messages.size)
          @messages.insert(o,m)
        end
    end
    end
        end
         selt=[]
    for m in @messages
      if !curids.include?(m.id)
      if complete
      play "messages_update"
    end
        m.date=Time.now if m.date==0
            selt.push(m.sender+":\r\n"+((sp!=nil and sp!="new")?(m.subject+":\r\n"):"")+m.text.gsub("\004LINE\004","\r\n").split("")[0...5000].join+((m.text.size>5000)?"... #{p_("Messages", "Read more")}":"")+"\r\n"+sprintf("%04d-%02d-%02d %02d:%02d",m.date.year,m.date.month,m.date.day,m.date.hour,m.date.min)+"\r\n")
      selt[-1]+="\004INFNEW{#{p_("Messages", "New")}: }\004" if m.mread==0
      selt[-1]+="\004ATTACHMENT\004" if m.attachments.size>0
      end
    end
    selt.push(p_("Messages", "Show older")) if @messages_more and !complete
    if !complete
      u=user
    u=name_conversation(user) if user[0..0]=="["
    head=p_("Messages", "Messages in conversation %{subject} with %{user}")%{'subject'=>subject,'user'=>u}
    head=p_("Messages", "Flagged messages") if sp=='flagged'
    head=p_("Messages", "Found items") if sp=='search'
    @sel_messages=Select.new(selt,true,0,head)
        @form_messages=Form.new([@sel_messages,nil,Edit.new(p_("Messages", "Your reply"),"MULTILINE","",true),nil,Button.new(p_("Messages", "Compose"))],0,true)
  @form_messages.fields[2..4]=[nil,nil,nil] if msg[3].to_i==0 or @messages_sp=='flagged' or @messages_sp=='search'
  else
    @sel_messages.commandoptions=selt+@sel_messages.commandoptions
    @sel_messages.index+=selt.size
  end
  @sel_messages.bind_context{|menu|context_messages(menu)}
    end
  def update_messages
   if $agent_msg != nil and @form_messages!=nil and @form_messages.index!=2
     mwn=$agent_msg
          load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit, true) if mwn>@messages_wn
     @messages_wn=mwn
   end
   @form_messages.update
       if escape or ((arrow_left and @form_messages.index==0) and @form_messages.fields[0]==@sel_messages) or (@sel_messages.commandoptions.size-@sel_messages.grayed.count(true))==0
      if @form_messages.fields[0]==@sel_messages
      if @messages_sp!="flagged" and @messages_sp!="search"
      load_conversations(@messages_user,@messages_sp)
      @cat=1
      @sel_messages=nil
    else
      load_users
      @cat=0
    end
    loop_update
  else
    hide_message
    end
    end
                      download_attachment(@messages[@sel_messages.index].attachments[@form_messages.fields[1].index]) if enter and @form_messages.index==1 and @form_messages.fields[1]!=nil
                      if (enter or arrow_right) and @sel_messages!=nil and @sel_messages.index==@messages.size
                        ind=@sel_messages.index
      load_messages(@messages_user,@messages_subject,@messages_sp,@messages_limit+50)
      @sel_messages.index=ind
      speech @sel_messages.commandoptions[@sel_messages.index]
      end
              return if @messages.size==0 or @sel_messages==nil or @messages[@sel_messages.index]==nil
     if @message_display==nil or @message_display[0]!=@messages[@sel_messages.index].id
@message_display=[@messages[@sel_messages.index].id,Time.now]
elsif @message_display[0]==@messages[@sel_messages.index].id and ((t=Time.now).to_i*1000000+t.usec)-(@message_display[1].to_i*1000000+@message_display[1].usec)>3000000 and @messages[@sel_messages.index].receiver==$name and @messages[@sel_messages.index].mread==0
  @messages[@sel_messages.index].mread=Time.now.to_i
  @sel_messages.commandoptions[@sel_messages.index].gsub!(/\004INFNEW\{([^\}]+)\}\004/,"")
end
if @messages[@sel_messages.index]!=nil
if @sel_messages.index<@messages.size and @messages[@sel_messages.index]!=nil and @messages[@sel_messages.index].attachments.size>0 and (@form_messages.fields[1]==nil or @form_messages.fields[1].commandoptions!=name_attachments(@messages[@sel_messages.index].attachments,@messages[@sel_messages.index].attachments_names))
  @form_messages.fields[1]=Select.new(name_attachments(@messages[@sel_messages.index].attachments, @messages[@sel_messages.index].attachments_names),true,0,p_("Messages", "Attachments"),true)
elsif @sel_messages.index>=@messages.size or @messages[@sel_messages.index].attachments.size==0 and @form_messages.fields[1]!=nil
  @form_messages.fields[1]=nil
  @form_messages.index=0 if @form_messages.index==1
  end
deletemessage if $key[0x2e] and @sel_messages.index<@messages.size and @form_messages.index==0
      if enter or arrow_right and @form_messages.index==0 and @form_messages.fields[0]==@sel_messages
      if @sel_messages.index<@messages.size
      show_message(@messages[@sel_messages.index])
      loop_update
      return if $scene!=self
      @sel_messages.commandoptions[@sel_messages.index].gsub!(/\004INFNEW\{([^\}]+)\}\004/,"") if @messages[@sel_messages.index].receiver==$name
      end
    end
    end
      if @form_messages.fields[2]!=nil
  if @form_messages.fields[2].text=="" and @form_messages.fields[3]!=nil
@form_messages.fields[3]=nil
elsif @form_messages.fields[2].text!="" and @form_messages.fields[3]==nil
  @form_messages.fields[3]=Button.new(p_("Messages","Send"))
  end
    if ((enter or space) and @form_messages.index==3) or ((enter and $key[0x11]) and @form_messages.index==2)
      bufid=buffer(@form_messages.fields[2].text)
      msgtemp = srvproc("message_send", {"to"=>@messages_user, "subject"=>("RE: "+@messages_subject), "buffer"=>bufid})
if msgtemp[0].to_i<0
      alert(_("Error"))
    else
      @form_messages.index=2
      @form_messages.fields[2].settext("")
      alert(p_("Messages", "Message has been sent"))
      end
load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit, true)
      end
if (enter or space) and @form_messages.index==4
  rec=@messages[@sel_messages.index].sender
  rec=@messages[@sel_messages.index].receiver if rec==$name
    $scene = Scene_Messages_New.new(rec,"RE: " + @messages[@sel_messages.index].subject.sub("RE: ",""),@form_messages.fields[2],export)  
  end
          end
      end
  def context_messages(menu)
    if @messages.size>0 and @sel_messages.index<@messages.size
menu.option(p_("Messages", "Reply")) {
  rec=@messages[@sel_messages.index].sender
  rec=@messages[@sel_messages.index].receiver if rec==$name
  $scene = Scene_Messages_New.new(rec,"RE: " + @messages[@sel_messages.index].subject.sub("RE: ",""),"",export)
}
end
if @sel_messages.index<@messages.size and @messages[@sel_messages.index].receiver==$name
  s=p_("Messages", "Flag")
s=p_("Messages", "Remove flag") if @messages[@sel_messages.index].marked==1  
menu.option(s) {
  if @messages[@sel_messages.index].marked==0
    if srvproc("messages",{"mark"=>"1", "id"=>@messages[@sel_messages.index].id})[0].to_i<0
      alert(_("Error"))
    else
      alert(p_("Messages", "The message has been flagged."))
      @messages[@sel_messages.index].marked=1
      end
    else
if srvproc("messages",{"unmark"=>"1", "id"=>@messages[@sel_messages.index].id})[0].to_i<0
      alert(_("Error"))
    else
      alert(p_("Messages", "The message is no longer flagged."))
      @messages[@sel_messages.index].marked=0
      end
      end
  @sel_messages.focus
}
end
if @messages.size>0 and @sel_messages.index<@messages.size and @messages_user[0..0]!="["
menu.option(_("Delete")) {
  deletemessage
}
end
if @messages_sp!="new"
menu.option(p_("Messages", "Send a new message")) {
$scene = Scene_Messages_New.new("","","",export)
}
end
if @messages.size>0 and @sel_messages.index<@messages.size
menu.option(p_("Messages", "Forward")) {
  t="#{@messages[@sel_messages.index].sender}: \r\n" + @messages[@sel_messages.index].text
    $scene = Scene_Messages_New.new("","FW: " + @messages[@sel_messages.index].subject, t, export)
}
end
menu.option(_("Refresh")) {
main
}
end
  def show_message(message)
                 dialog_open
         message.mread = 1 if message.receiver==$name
         date=sprintf("%04d-%02d-%02d %02d:%02d",message.date.year,message.date.month,message.date.day,message.date.hour,message.date.min)
                                        @form_messages.fields[0]=Edit.new(message.subject + " #{p_("Messages", "From")}: " + message.sender,"MULTILINE|READONLY",message.text+"\r\n"+date)
                                      end
                                      def hide_message
                                                                                @form_messages.fields[0]=@sel_messages
                                        @form_messages.index=0
                                        @sel_messages.focus
                                        dialog_close
                                        end
                       def download_attachment(at)
                                 ati=srvproc("attachments",{"info"=>"1", "id"=>at})
                      if ati[0].to_i<0
                        alert(_("Error"))
                        $scene=Scene_Main.new
                        return
                      end
    id=at
    name=ati[2].delete("\r\n")
        loc=getfile(p_("Messages", "Where do you want to save this file?"),getdirectory(40)+"\\",true,"Documents")
    if loc!=nil
      waiting
      downloadfile($url+"attachments/"+id.to_s,loc+"\\"+name, "", p_("Messages", "The attachment has been downloaded."))
      waiting_end
          else
      loop_update
    end
                         end
                       def deletemessage
                         return if @messages_user[0..0]=="["
  confirm(p_("Messages", "Are you sure you want to delete this message?")) do
    if srvproc("messages",{"delete"=>"1", "id"=>@messages[@sel_messages.index].id.to_s})[0].to_i<0
      alert(_("Error"))
            return
    end
    alert(p_("Messages", "The message has been deleted."))
                        @sel_messages.disable_item(@sel_messages.index)
                        @sel_messages.focus
      end
    end
  end

  class Struct_Messages_User
    attr_accessor :user, :read, :lastdate, :lastuser, :lastsubject, :lastid
    def initialize(user="")
      @user=user
      end
    end
  
    class Struct_Messages_Conversation
    attr_accessor :subject, :read, :lastdate, :lastuser,  :lastid
    def initialize(subj="")
      @subject=subj
    end
    end
     
     class Scene_Messages_New
       def initialize(receiver="",subject="",text="",scene=false)
         @receiver = receiver
         @subject = subject
         @text = text
         @scene = scene
         end
       def main
         dialog_open
         receiver=@receiver
         subject=@subject
         text=@text
         text=@text.text_str if @text.is_a?(Edit)
         @fields = []
           @fields[0] = Edit.new(p_("Messages", "Recipient"),"",receiver,true)
           @fields[0]=nil if receiver[0..0]=="["
@fields[1] = Edit.new(p_("Messages", "Subject:"),"",subject,true)
           @fields[2] = ((@text.is_a?(Edit))?@text:Edit.new(p_("Messages", "Message:"),"MULTILINE",text,true)) if !(@text.is_a?(String) and @text.include?("\004AUDIO\004"))
           @fields[3] = Button.new(p_("Messages", "Record an audio message")) if !(@text.is_a?(String) and @text.include?("\004AUDIO\004"))
           @fields[4]=nil
           @fields[5]=nil
           @fields[6] = Button.new(_("Cancel"))
           @fields[7]=nil
           @fields[8]=nil
           @fields[9]=Button.new(p_("Messages", "Attach a file"))                      
                      ind=0
           ind=1 if receiver!=""
           ind=2 if receiver!="" and subject!=""
           @form = Form.new(@fields,ind)
rec=0
@attachments=[]
                                 loop do                     
                                   if @attachments.size==0
                                     @form.fields[5]=nil
                                   else
                                     fl=[]
                                     for a in @attachments
                                       fl.push(File.basename(a))
                                       end
                                     if @form.fields[5]==nil
                                       @form.fields[5]=Select.new(fl,true,0,p_("Messages", "Attachments"),true)
                                     else
                                       @form.fields[5].commandoptions=fl
                                       @form.fields[5].index-=1 if @form.fields[5].index>@form.fields[5].commandoptions.size-1
                                     end
                                     end
             loop_update
                          if @form.fields[4]==nil
               sc=false
               if rec == 2
                 sc=true
               elsif rec == 0 and (@form.fields[2]==nil or @form.fields[2].text!="")
                 sc=true
                 end
               if sc == true
                 @form.fields[4] = Button.new(p_("Messages", "Send"))
                      @form.fields[7] = Button.new(p_("Messages", "Send as admin")) if $rang_moderator > 0 or $rang_developer > 0
           @form.fields[8] = Button.new(p_("Messages", "Send to all users")) if $rang_moderator > 0 or $rang_developer > 0
           end
         elsif @form.fields[4]!=nil
           sc=false
               if rec == 1
                 sc=true
               elsif rec == 0 and (@form.fields[2]!=nil and @form.fields[2].text=="")
                 sc=true
                 end
           if sc == true
                 @form.fields[4]=nil
                      @form.fields[7]=nil if $rang_moderator > 0 or $rang_developer > 0
           @fields[8]=nil if $rang_moderator > 0 or $rang_developer > 0
           end
               end
             if (arrow_up or arrow_down) and @form.index == 0
               s = selectcontact
               if s != nil
                 @form.fields[0].settext(s)
                 end
               end
           @form.update
               if (enter or space) and @form.index == 3
             if rec == 0
                          @r=Recorder.start($tempdir+"/audiomessage.opus",96)
                          play("recording_start")
             @msgedit=@form.fields[2]
             @form.fields[2]=Button.new(p_("Messages", "An audio message"))
             @form.fields[3]=Button.new(p_("Messages", "Stop recording"))
           @form.fields[7]=nil
             @form.fields[8]=nil
             rec = 1
         elsif rec == 1
           play("recording_stop")
           @r.stop
           @form.fields[3]=Button.new(p_("Messages", "Play"))
           @form.fields[2] = Button.new(p_("Messages", "Cancel recording"))
           rec = 2
         elsif rec == 2
                      player($tempdir+"/audiomessage.opus","",true)
                                   end
                                 end
                                 if (enter or space) and @form.index == 2 and rec > 1
                                   @form.fields[2] = @msgedit
                                   rec = 0
                                   @form.fields[3] = Button.new(p_("Messages", "Record an audio message"))
                                   @form.index=2
                                   @form.fields[2].focus
                                   end
               if (enter or space) and @form.index==9
                 if @attachments.size>=3
                   alert(p_("Messages", "You cannot add more attachments to this message."))
                   else
                 loc=getfile(p_("Messages", "Select a file to attach"),getdirectory(5)+"\\",false)
                 if loc!=nil
                   size=File.size(loc)
                                      if size>16777215
                     alert(p_("Messages", "The file is too large."))
                     else
                   @attachments.push(loc)
                   alert(p_("Messages", "File attached."))
                 end
               else
                 loop_update
                   end
                 end
                 end
                 if $key[0x2E] and @form.index==5
                   play("edit_delete")
                   @attachments.delete_at(@form.fields[5].index)
                   @form.fields[5].commandoptions.delete_at(@form.fields[5].index)
                   if @attachments.size>0
                     @form.fields[5].index-=1 while @form.fields[5].index>=@attachments.size
                     speech(@form.fields[5].commandoptions[@form.fields[5].index])
                   else
                     @form.index=2
                     @form.fields[2].focus
                     end
                   end
                 if (enter or space) and ((@form.index == 4 or @form.index == 7 or @form.index == 8) or ($key[0x11] == true and enter))
                                   @form.fields[0].finalize if @form.fields[0]!=nil
                                                          @form.fields[1].finalize
                       @form.fields[2].finalize if rec==0 and @form.fields[2]!=nil
                       receiver = @form.fields[0].text_str if @form.fields[0]!=nil
                       receiver=@receiver if @form.fields[0]==nil
                       receiver.sub!("@elten-net.eu","")
                       receiver=finduser(receiver) if receiver.include?("@")==false and finduser(receiver).upcase==receiver.upcase
                       if (user_exist(receiver) == false or @form.index == 8 and (/^[a-zA-Z0-9.\-_\+]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/=~receiver)==nil) and @form.fields[0]!=nil
                         alert(p_("Messages", "The recipient cannot be found."))
                       elsif (/^[a-zA-Z0-9.\-_\+]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/=~receiver)!=nil
                         if confirm(p_("Messages", "Do you want to send this message as e-mail?")) == 1
                           subject = @form.fields[1].text_str
                       text = @form.fields[2].text_str if rec == 0 and @form.fields[2]!=nil
                       play("list_select")
                       break
                       end
                         else
                       subject = @form.fields[1].text_str
                       text = @form.fields[2].text_str if rec == 0 and @form.fields[2]!=nil
                       text=@text if @form.fields[2]==nil
                       play("list_select")
                       break
                       end
                     end
                     if escape or ((enter or space) and @form.index == 6)
                                                              if @scene != false and @scene != true and @scene.is_a?(Integer)==false and @scene.is_a?(Array)==false
           $scene = @scene
         else
                      $scene = Scene_Messages.new(@scene)
         end
         loop_update
         dialog_close  
         return  
           break
         end
         end
         @att=""
         if @attachments.size>0
                      for a in @attachments
    @att+=send_attachment(a)+","
  end
  @att.chop! if @att[-1..-1]==","
           end
                    msgtemp=""
         if rec == 0
           bufid = buffer(text)
                    tmp = ""
         tmp = "admin_" if @form.index == 7
         msgtemp = ""
         if @form.index != 8
                 prm={"to"=>receiver, "subject"=>subject, "buffer"=>bufid}
                       if @att!="" and @att!=nil
                                  bufatt=buffer(@att)
      prm['bufatt']=bufatt.to_s
              end         
           msgtemp = srvproc("message_#{tmp}send",prm)
       else
             @users = srvproc("users",{})
        err = @users[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      dialog_close
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Main.new
        dialog_close
        return
        when -3
          alert(_("You haven't permissions to do this"))
          $scene = Scene_Main.new
          dialog_close
          return
    end
        for i in 0..@users.size - 1
      @users[i].delete!("\r")
      @users[i].delete!("\r\n")
    end
    usr = []
    for i in 1..@users.size - 1
      usr.push(@users[i]) if @users[i].size > 0
    end
    for receiver in usr
      loop_update
      ex=""
      prm={"to"=>receiver, "subject"=>subject, "buffer"=>bufid}
            if @att!="" and @att!=nil
      bufatt=buffer(@att)
      prm['bufatt']=bufatt.to_s
    end
    msgtemp = srvproc("message_send",prm)
      end
    end
  else
    if rec == 1
    @r.stop
    play("recording_stop")
  end
  waiting            
                  fl = readfile($tempdir+"/audiomessage.opus")
                  if fl[0..3]!='OggS'
                    alert(_("Error"))
                    return $scene=Scene_Main.new
                    end
            host = $srv
  host.delete!("/")
              boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"data\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
    ex=""
      if @att!="" and @att!=nil
      bufatt=buffer(@att)
        ex="\&bufatt=#{bufatt}"
      end
    q = "POST /srv/message_send.php?name=#{$name}\&token=#{$token}\&to=#{receiver.urlenc}\&subject=#{subject.urlenc}\&audio=1#{ex} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary.to_s}\r\nContent-Length: #{length}\r\n\r\n#{data}"
 a = connect(host,80,q)
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    alert(_("Error"))
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = sn.split("\r\n")
msgtemp = bt[1].to_i
waiting_end
                                      end
         case msgtemp[0].to_i
         when 0
           alert(p_("Messages", "Message has been sent"))
           if @scene != false and @scene != true and @scene.is_a?(Integer) == false and @scene.is_a?(Array)==false
           $scene = @scene
         else
           @text.settext("") if @text.is_a?(Edit)
           $scene = Scene_Messages.new(@scene)
           dialog_close
           return
           end
           when -1
             alert(_("Database Error"))
             $scene = Scene_Main.new
             dialog_close
             return
             when -2
               alert(_("Token expired"))
               $scene = Scene_Loading.new
               dialog_close
               return
               when -3
                 alert(_("You haven't permissions to do this"))
                                  when -4
                 alert(p_("Messages", "The recipient cannot be found."))  
               end
               dialog_close
         end
       end
       
class Struct_Message
attr_accessor :id, :receiver, :sender, :subject, :mread, :marked, :date, :attachments, :text, :attachments_names
               def initialize(id=0)
                 @id=id
                 @receiver=$name
                                  @sender=$name
                 @subject=""
                 @mread=0
                 @text=""
                 @attachments=[]
                 @date=0
                                                   @marked=0
@attachments_names=[]
                                                   end
               end