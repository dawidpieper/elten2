#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

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
 def load_users(limit=@users_limit||20)
   @lastuser=nil
   @lastuser=@users[@sel_users.index] if @users.is_a?(Array) and @sel_users.is_a?(Select)
   @users=[]
   @users_limit=limit
    msg=srvproc("messages_conversations","name=#{$name}\&token=#{$token}\&limit=#{@users_limit}")
    if msg[0].to_i<0
      speech(_("General:error"))
      speech_wait
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
            selt.push(u.user+":\r\n"+_("Messages:opt_phr_lastmsg")+": "+u.lastuser+": "+u.lastsubject+".\r\n"+sprintf("%04d-%02d-%02d %02d:%02d",u.lastdate.year,u.lastdate.month,u.lastdate.day,u.lastdate.hour,u.lastdate.min)+"\r\n")
      selt[-1]+="\004INFNEW{#{_("Messages:opt_phr_new")}: }\004" if u.read==0 and u.lastuser==u.user
      ind=selt.size-1 if u.user==@lastuser.user if @lastuser!=nil
    end
selt.push(_("Messages:opt_showmore")) if @users_more
    @sel_users=Select.new(selt,true,ind,_("Messages:head"))
end
def update_users
  @sel_users.update
  if enter or Input.trigger?(Input::RIGHT)
    if @sel_users.index<@users.size
    load_conversations(@users[@sel_users.index].user)
    @cat=1
  else
    @sel_users.index-=1
    load_users(@users_limit+20)
    speech @sel_users.commandoptions[@sel_users.index]
    end
  end
  menu_users if alt
  $scene=Scene_Main.new if escape
end
def menu_users
play("menu_open")
play("menu_background")
@menu = menulr([_("Messages:opt_answer"),_("Messages:opt_compose"),_("Messages:opt_markallasread"),_("Messages:opt_search"),_("Messages:opt_showflagged"),_("General:str_refresh")],true,0,"",true)
@menu.disable_item(0) if @users.size ==0 or @sel_users.index>=@users.size
@menu.focus
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
  $scene = Scene_Messages_New.new(@users[@sel_users.index].user,"","",export)
when 1
$scene = Scene_Messages_New.new("","","",export)
when 2
  msgtemp = srvproc("message_allread","name=#{$name}\&token=#{$token}")
    if msgtemp[0].to_i < 0
    speech(_("General:error"))
    speech_wait
    $scene = Scene_Main.new
    return 
    end
    speech(_("Messages:info_allmarkedasread"))
speech_wait
if @wn == true
  $scene = Scene_WhatsNew.new
  return
else
  return main
  end
  when 3
    load_messages("","","search")
@cat=2
    when 4
load_messages("","","flagged")
@cat=2
when 5
    play("menu_close")
  Audio.bgs_stop
  return main
end
break
end
if alt or escape
loop_update
  break
end
end
Audio.bgs_stop
play("menu_close")
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
msg=srvproc("messages_conversations","name=#{$name}\&token=#{$token}\&user=#{user.urlenc}\&limit=#{@conversations_limit.to_i}")
   else
   @conversations_sp=sp
   @conversations=[]
   msg=srvproc("messages_conversations","name=#{$name}\&token=#{$token}\&sp=#{sp}")
 end
        if msg[0].to_i<0
      speech(_("General:error"))
      speech_wait
      return $scene=Scene_WhatsNew.new
      end
if msg[1].to_i==0 and sp=='new'
  speech(_("Messages:info_nonewmessages"))
  speech_wait
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
      selt.push(((c.subject!="")?(c.subject):_("Messages:opt_phr_nosubj"))+":\r\n"+((sp==nil)?_("Messages:opt_phr_lastmsg"):_("Messages:opt_phr_from"))+": "+c.lastuser+".\r\n"+sprintf("%04d-%02d-%02d %02d:%02d",c.lastdate.year,c.lastdate.month,c.lastdate.day,c.lastdate.hour,c.lastdate.min)+"\r\n")
      selt[-1]+="\004INFNEW{#{_("Messages:opt_phr_new")}: }\004" if c.read==0 and c.lastuser==user
      ind=selt.size-1 if c.subject==@lastconversation.subject and user==@lastconversation_user if @lastconversation!=nil and @lastconversation_user!=nil
    end
    selt.push(_("Messages:opt_showmore")) if @conversations_more
    @sel_conversations=Select.new(selt,true,ind,((sp==nil)?s_("Messages:head_conversations",{'user'=>user}):""))
  end
  def update_conversations
    @sel_conversations.update
    if enter or Input.trigger?(Input::RIGHT)
      if @sel_conversations.index<@conversations.size
      load_messages(@conversations_user||@conversations[@sel_conversations.index].lastuser,@conversations[@sel_conversations.index].subject,@conversations_sp)
      @cat=2
    else
      @sel_conversations.index-=1
      load_conversations(@conversations_user,nil,@conversations_limit+20)
speech @sel_conversations.commandoptions[@sel_conversations.index]
      end
      end
    if escape or Input.trigger?(Input::LEFT)
      if @conversations_sp!="new"
      load_users
      loop_update
      @cat=0
      @sel_conversations=nil
    else
      return $scene=Scene_WhatsNew.new
    end
    end
    menu_conversations if alt
    end
def menu_conversations
play("menu_open")
play("menu_background")
@menu = menulr([_("Messages:opt_answer"),_("Messages:opt_compose"),_("General:str_refresh")],true,0,"",true)
@menu.disable_item(0) if @conversations.size ==0 or @sel_conversations.index>=@conversations.size
@menu.disable_item(1) if @conversations_sp=="new"
@menu.focus
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
  $scene = Scene_Messages_New.new(@user,"RE: "+@conversations[@sel_conversations.index].subject,"",export)
when 1
$scene = Scene_Messages_New.new("","","",export)
when 2
    play("menu_close")
  Audio.bgs_stop
  return main
end
break
end
if alt or escape
loop_update
  break
end
end
Audio.bgs_stop
play("menu_close")
end
    def load_messages(user,subject,sp=nil,limit=@messages_limit||50,complete=false)
               @messages=[] if !complete
   @messages_user=user
   @messages_subject=subject
   @messages_sp=sp
   @messages_limit=limit if !complete
   msg=""
   if sp=="flagged"
     msg=srvproc("messages_conversations","name=#{$name}\&token=#{$token}\&sp=flagged")
   elsif sp=="search"
     term=input_text(_("Messages:type_searchphrase"),"ACCEPTESCAPE",@lastsearch||"")
     if term=="\004ESCAPE\004"
       @cat=0
       return
       end
                   @lastsearch=term
     msg=srvproc("messages_conversations","name=#{$name}\&token=#{$token}\&sp=search&search=#{term.urlenc}")
     else
   msg=srvproc("messages_conversations","name=#{$name}\&token=#{$token}\&user=#{user.urlenc}\&subj=#{subject.urlenc}&limit=#{@messages_limit.to_s}")
   end
@messages_wn=0
   if $agent_msg!=nil
     @messages_wn=$agent_msg
       end
   if msg[0].to_i<0
            speech(_("General:error"))
      speech_wait
      return $scene=Scene_Main.new
      end
@messages_more=(msg[2].to_i==1)?true:false if !complete
      l=0
      o=-1
      curid=0
      curid=@messages[0].id if complete
for i in 4..msg.size-1
  line=msg[i].delete("\r\n")
  case l
  when 0
    break if complete and line.to_i<=curid
    o=(complete)?0:(@messages.size)
    @messages.insert(o,Struct_Message.new(line.to_i))
        when 1
    @messages[o].sender=line
    @messages[o].receiver=((line==$name)?user:$name)
when 2
  @messages[o].subject=line
    when 3
            @messages[o].date=Time.at(line.to_i)
    when 4
                @messages[o].mread=line.to_i
        when 5
          @messages[o].marked=line.to_i
          when 6
            @messages[o].attachments=line.split(",")
            name_attachments(@messages[o]) if @messages[o].attachments.size>0
            when 7
              if line.include?("\004END\004")==false
        @messages[o].text+=line+"\n"
        l-=1
      else
        @messages[o].text.chop!
        end
            end
      l+=1
      l=0 if l==8
    end
         selt=[]
    for m in @messages
      break if m.id<=curid
      if complete
      play "messages_update"
                        end
            selt.push(m.sender+":\r\n"+((sp!=nil and sp!="new")?(m.subject+":\r\n"):"")+m.text.gsub("\004LINE\004","\r\n").split("")[0...5000].join+((m.text.size>5000)?"... #{_("Messages:opt_phr_readmore")}":"")+"\r\n"+sprintf("%04d-%02d-%02d %02d:%02d",m.date.year,m.date.month,m.date.day,m.date.hour,m.date.min)+"\r\n")
      selt[-1]+="\004INFNEW{#{_("Messages:opt_phr_new")}: }\004" if m.mread==0
      selt[-1]+="\004ATTACHMENT\004" if m.attachments.size>0
    end
    selt.push(_("Messages:opt_showmore")) if @messages_more and !complete
    if !complete
    head=s_("Messages:head_messages",{'subject'=>subject,'user'=>user})
    head=_("Messages:head_flagged") if sp=='flagged'
    head=_("Messages:head_searchresults") if sp=='search'
    @sel_messages=Select.new(selt,true,0,head)
        @form_messages=Form.new([@sel_messages,nil,Edit.new(_("Messages:type_reply"),"MULTILINE","",true),nil,Button.new(_("Messages:btn_compose"))],0,true)
  @form_messages.fields[2..4]=[nil,nil,nil] if msg[3].to_i==0 or @messages_sp=='flagged' or @messages_sp=='search'
  else
    @sel_messages.commandoptions=selt+@sel_messages.commandoptions
    @sel_messages.index+=selt.size
  end
    end
  def update_messages
   if $agent_msg != nil and @form_messages!=nil and @form_messages.index!=2
     mwn=$agent_msg
          load_messages(@messages_user, @messages_subject, @messages_sp, @messages_limit, true) if mwn>@messages_wn
     @messages_wn=mwn
    end
@form_messages.update
    if escape or ((Input.trigger?(Input::LEFT) and @form_messages.index==0) and @form_messages.fields[0]==@sel_messages)
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
    menu_messages if alt
                      download_attachment(@messages[@sel_messages.index].attachments[@form_messages.fields[1].index]) if enter and @form_messages.index==1 and @form_messages.fields[1]!=nil
              return if @messages.size==0 or @sel_messages==nil
     if @message_display==nil or @message_display[0]!=@messages[@sel_messages.index].id
@message_display=[@messages[@sel_messages.index].id,Time.now]
elsif @message_display[0]==@messages[@sel_messages.index].id and ((t=Time.now).to_i*1000000+t.usec)-(@message_display[1].to_i*1000000+@message_display[1].usec)>3000000 and @messages[@sel_messages.index].receiver==$name and @messages[@sel_messages.index].mread==0
  @messages[@sel_messages.index].mread=Time.now.to_i
  @sel_messages.commandoptions[@sel_messages.index].gsub!(/\004INFNEW\{([^\}]+)\}\004/,"")
end
if @sel_messages.index<@messages.size and @messages[@sel_messages.index].attachments.size>0 and (@form_messages.fields[1]==nil or @form_messages.fields[1].commandoptions!=name_attachments(@messages[@sel_messages.index]))
  @form_messages.fields[1]=Select.new(name_attachments(@messages[@sel_messages.index]),true,0,_("Messages:head_attachments"),true)
elsif @sel_messages.index>=@messages.size or @messages[@sel_messages.index].attachments.size==0 and @form_messages.fields[1]!=nil
  @form_messages.fields[1]=nil
  @form_messages.index=0 if @form_messages.index==1
  end
deletemessage if $key[0x2e] and @sel_messages.index<@messages.size and @form_messages.index==0
      if enter or Input.trigger?(Input::RIGHT)and @form_messages.index==0 and @form_messages.fields[0]==@sel_messages
      if @sel_messages.index<@messages.size
      show_message(@messages[@sel_messages.index])
      loop_update
      return if $scene!=self
      @sel_messages.commandoptions[@sel_messages.index].gsub!(/\004INFNEW\{([^\}]+)\}\004/,"") if @messages[@sel_messages.index].receiver==$name
    else
      @sel_messages.index-=1
      load_messages(@messages_user,@messages_subject,@messages_sp,@messages_limit+50)
      speech @sel_messages.commandoptions[@sel_messages.index]
      end
    end
      if @form_messages.fields[2]!=nil
  if @form_messages.fields[2].text=="" and @form_messages.fields[3]!=nil
@form_messages.fields[3]=nil
elsif @form_messages.fields[2].text!="" and @form_messages.fields[3]==nil
  @form_messages.fields[3]=Button.new(_"Messages:btn_send")
  end
    if ((enter or space) and @form_messages.index==3) or ((enter and $key[0x11]) and @form_messages.index==2)
      bufid=buffer(@form_messages.fields[2].text)
      msgtemp = srvproc("message_send","name=#{$name}\&token=#{$token}\&to=#{@messages_user}\&subject=#{("RE: "+@messages_subject).urlenc}\&buffer=#{bufid}")
if msgtemp[0].to_i<0
      speech(_("General:error"))
    else
      @form_messages.index=2
      @form_messages.fields[2].settext("")
      speech(_("Messages:info_sent"))
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
  def menu_messages
play("menu_open")
play("menu_background")
@menu = menulr([_("Messages:opt_answer"),_("Messages:opt_flag"),_("General:str_delete"),_("Messages:opt_compose"),_("Messages:opt_forward"),_("General:str_refresh")],true,0,"",true)
@menu.commandoptions[1]=_("Messages:opt_removeflag") if @sel_messages.index<@messages.size and @messages[@sel_messages.index].marked==1
@menu.disable_item(1) if @sel_messages.index<@messages.size and @messages[@sel_messages.index].receiver!=$name
@menu.disable_item(3) if @messages_sp=="new"
if @messages.size==0 or @sel_messages.index>=@messages.size
@menu.disable_item(0)
@menu.disable_item(1)
@menu.disable_item(2)
@menu.disable_item(4)
end
@menu.focus
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
  rec=@messages[@sel_messages.index].sender
  rec=@messages[@sel_messages.index].receiver if rec==$name
  $scene = Scene_Messages_New.new(rec,"RE: " + @messages[@sel_messages.index].subject.sub("RE: ",""),"",export)
when 1
  if @messages[@sel_messages.index].marked==0
    if srvproc("messages","name=#{$name}\&token=#{$token}\&mark=1\&id=#{@messages[@sel_messages.index].id}")[0].to_i<0
      speech(_("General:error"))
      speech_wait
    else
      speech(_("Messages:info_flagged"))
      speech_wait
      @messages[@sel_messages.index].marked=1
      end
    else
if srvproc("messages","name=#{$name}\&token=#{$token}\&unmark=1\&id=#{@messages[@sel_messages.index].id}")[0].to_i<0
      speech(_("General:error"))
      speech_wait
    else
      speech(_("Messages:info_glagremoved"))
      speech_wait
      @messages[@sel_messages.index].marked=0
      end
      end
  @sel_messages.focus
    when 2
  deletemessage
when 3
$scene = Scene_Messages_New.new("","","",export)
when 4
  $scene = Scene_Messages_New.new("","FW: " + @messages[@sel_messages.index].subject,"#{@messages[@sel_messages.index].sender}: \r\n" + @messages[@sel_messages.index].text,export)
when 5
    play("menu_close")
  Audio.bgs_stop
  return main
end
break
end
if alt or escape
loop_update
  break
end
end
Audio.bgs_stop
play("menu_close")
end
  def show_message(message)
                 dialog_open
         message.mread = 1 if message.receiver==$name
         date=sprintf("%04d-%02d-%02d %02d:%02d",message.date.year,message.date.month,message.date.day,message.date.hour,message.date.min)
                                        @form_messages.fields[0]=Edit.new(message.subject + " #{_("Messages:opt_phr_from")}: " + message.sender,"MULTILINE|READONLY",message.text+"\r\n"+date)
                                      end
                                      def hide_message
                                                                                @form_messages.fields[0]=@sel_messages
                                        @form_messages.index=0
                                        @sel_messages.focus
                                        dialog_close
                                        end
def name_attachments(message)
  return message.attachments_names if message.attachments_names!=nil
  att=[]
                    for at in message.attachments
                      ati=srvproc("attachments","name=#{$name}\&token=#{$token}\&info=1\&id=#{at}")
                      if ati[0].to_i<0
                        speech(_("General:error"))
                        $scene=Scene_Main.new
                        return
                      end
                      att.push(ati[2])  
                    end
                    return message.attachments_names=att
  end
                       def download_attachment(at)
                                 ati=srvproc("attachments","name=#{$name}\&token=#{$token}\&info=1\&id=#{at}")
                      if ati[0].to_i<0
                        speech(_("General:error"))
                        $scene=Scene_Main.new
                        return
                      end
    id=at
    name=ati[2].delete("\r\n")
        loc=getfile(_("Messages:head_savelocation"),getdirectory(40)+"\\",true,"Documents")
    if loc!=""
      waiting
      downloadfile($url+"attachments/"+id.to_s,loc+"\\"+name)
      speech_wait
      waiting_end
      speech(_("Messages:info_attachmentdownloaded"))
    else
      loop_update
    end
                         end
                       def deletemessage
  confirm(_("Messages:alert_delete")) do
    if srvproc("messages","name=#{$name}\&token=#{$token}\&delete=1\&id=#{@messages[@sel_messages.index].id.to_s}")[0].to_i<0
      speech(_("General:error"))
      speech_wait
            return
    end
    speech(_("Messages:info_messagedeleted"))
    speech_wait
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
    
class Scene_MessagesO
  def initialize(wn=2000)
    wn=2000 if wn.is_a?(Array)
    @wn=wn
    end
  def main
    if $name=="guest"
      speech(_("General:error_guest"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
          @msg = srvproc("messages","name=#{$name}\&token=#{$token}\&list=1#{if @wn==true;"\&unread=1";elsif @wn==0;"";else;"\&limit=#{@wn}";end}")
            case @msg[0].to_i
    when -1
      speech(_("General:error_db"))
      $scene = Scene_Main.new
      return
      when -2
        speech(_("General:error_token"))
        $scene = Scene_Loading.new
        return
        when -3
          speech(_("General:error_unknown"))
          $scene = Scene_Main.new
          return
        end
        @messages = @msg[1].to_i
     @message=[]
     t=0
     @unread=0
     for l in @msg[2..@msg.size-1]
       case t
       when 0
         @message.push(Struct_Message.new(l.to_i))
         when 1
           @message.last.sender=l.delete("\r\n")
           when 2
           @message.last.receiver=l.delete("\r\n")
           when 3
           @message.last.subject=l.delete("\r\n")
           when 4
           @message.last.date=l.to_i
           when 5
           @message.last.mread=l.to_i
           @unread+=1 if l.to_i==0 and @message.last.receiver==$name
           when 6
           @message.last.marked=l.to_i
                                 when 7
           @message.last.attachments=l.delete("\r\n").split(",")
       end
       t+=1
       t=0 if t==8
       end
     if @wn != true and @messages==0
            speech(_("Messages:info_nomessages"))
          speech_wait
        elsif @wn==true and @unread==0
          speech(_("Messages:info_nonewmessages"))
          speech_wait
          $scene=Scene_WhatsNew.new
          return
               end
     @msgsel = []
     for i in 0..@message.size - 1
       @msgsel[i] = ""
       if @message[i].receiver==$name                         
       @msgsel[i] += @message[i].subject + " #{_("Messages:opt_phr_from")}: " + @message[i].sender
     else
       @msgsel[i] += @message[i].subject + " #{_("Messages:opt_phr_to")}: " + @message[i].receiver
       end
                         @msgsel[i] += "\004INFNEW{#{_("Messages:opt_phr_new")}: }\004 " if @message[i].mread == 0 and @wn != true       
                         @msgsel[i] += "\004ATTACHMENT\004 " if @message[i].attachments != "" and @message[i].attachments!=[]
              end
     h=""
     h=_("Messages:head_received") if @wn != true
              @sel = Select.new(@msgsel,true,0,h,true)
              @recv=0
              for i in 0..@message.size-1
                if @message[i].receiver!=$name
                @sel.disable_item(i)
                              else
                @recv+=1
                end
@sel.disable_item(i) if @message[i].mread>0 and @wn==true
                end
@sel.commandoptions.push(_("Messages:opt_loadmore")) if @wn.is_a?(Integer) and @wn<@messages
                @sel.focus
                loop do
loop_update
       @sel.update
       update
       if alt
                  menu
       end
       if escape or (Input.trigger?(Input::LEFT) and @wn == true)
         if @search == true
           for i in 0..@message.size-1
             @sel.enable_item(i)
             @sel.disable_item(i) if @message[i].receiver!=$name
           end
           @sel.header=_("Messages:head_received")
           @sel.index=@lastindex
           @sel.focus
           @search=false
           @markedsearch=false
           else
         if @wn != true         
         $scene = Scene_Main.new
       else
         $scene=Scene_WhatsNew.new
       end
       end
         end
       if $scene != self
         break
         end
       end
          end
     def update
         @msgcur = @sel.index
         deletemessage if $key[0x2e]
         if enter
           if @wn.is_a?(Integer) and @sel.index==@wn and @wn<@messages
             newwn=@wn+2000
             newwn=@messages if newwn>@messages
             $scene=Scene_Messages.new(newwn)
             else
                    if @message[@msgcur].text==""
           msgtemp = srvproc("messages","name=#{$name}\&token=#{$token}\&id=#{@message[@msgcur].id}\&read=1")
                  if msgtemp[0].to_i < 0
           speech(_("General:error"))
           speech_wait
           $scene = Scene_Main.new
           return
         end
         @message[@msgcur].text=msgtemp[9..msgtemp.size-1].join
         end
         dialog_open
         if @message[@msgcur].receiver==$name
         @message[@msgcur].mread = Time.now.to_i
         @msgsel[@msgcur] = @message[@msgcur].subject + " OD: " + @message[@msgcur].sender
         @msgsel[@msgcur] += "\004ATTACHMENT\004" if @message[@msgcur].attachments!="" and @message[@msgcur].attachments!=[]
         end
                  @sel.commandoptions[@msgcur] = @msgsel  [@msgcur]
         date=""
         tm=Time.now
         ri=0
         begin
         tm=Time.at(@message[@msgcur].date)
         date=sprintf("%04d-%02d-%02d %02d:%02d",tm.year,tm.month,tm.day,tm.hour,tm.min)
           rescue Exception
           ri+=1
             retry if ri<10
           end
                               fields = [Edit.new(@message[@msgcur].subject + " #{_("Messages:opt_phr_from")}: " + @message[@msgcur].sender,"MULTILINE|READONLY",@message[@msgcur].text+"\r\n"+date,true)]
                  if @message[@msgcur].attachments.size>0
                    att=[]
                    for at in @message[@msgcur].attachments
                      ati=srvproc("attachments","name=#{$name}\&token=#{$token}\&info=1\&id=#{at}")
                      if ati[0].to_i<0
                        speech(_("General:error"))
                        $scene=Scene_Main.new
                        return
                      end
                      att.push(ati[2])  
                    end
                    fields[1]=Select.new(att,true,0,_("Messages:head_attachments"),true)
                    end
                  form=Form.new(fields)
         play("list_select")
loop do
  loop_update
  form.update
  if enter and form.index==1
    at=@message[@msgcur].attachments[form.fields[1].index]
    ati=srvproc("attachments","name=#{$name}\&token=#{$token}\&info=1\&id=#{at}")
                      if ati[0].to_i<0
                        speech(_("General:error"))
                        $scene=Scene_Main.new
                        return
                      end
    id=at
    name=ati[2].delete("\r\n")
        loc=getfile(_("Messages:head_savelocation"),getdirectory(40)+"\\",true,"Documents")
    if loc!=""
      waiting
      downloadfile($url+"attachments/"+id.to_s,loc+"\\"+name)
      speech_wait
      waiting_end
      speech(_("Messages:info_attachmentdownloaded"))
    else
      loop_update
    end
                              end
  if escape
                  speech_stop
         break
                end
              if alt
                  menu
         if $scene != self
           dialog_close
           return
         break
         end
                end
              end
dialog_close
              loop_update
     if @wn == true
              main
              return
  end
              @sel.focus
      end
    end
    end
   def menu
play("menu_open")
play("menu_background")
@menu = menulr([_("Messages:opt_answer"),_("Messages:opt_flag"),_("General:str_delete"),_("Messages:opt_compose"),_("Messages:opt_forward"),_("Messages:opt_markallasread"),_("Messages:opt_search"),_("Messages:opt_showflagged"),_("General:str_refresh"),_("Messages:opt_showsent"),_("General:str_cancel")],true,0,"",true)
if @recv ==0
  @menu.disable_item(0)
  @menu.disable_item(1)
  @menu.disable_item(2)
  @menu.disable_item(4)
  @menu.disable_item(5)
  @menu.disable_item(6)
else
  @menu.disable_item(1) if @message[@sel.index]==nil or @message[@sel.index].receiver!=$name
  @msgcur = @sel.index
  @menu.commandoptions[1]=_("Messages:opt_removeflag") if @message[@msgcur]!=nil and @message[@msgcur].marked>0
  end
if @wn == true
  @menu.disable_item(3)
  @menu.disable_item(6)
  @menu.disable_item(9)
end
if @message[@sel.index]==nil
  @menu.disable_item(0)
  @menu.disable_item(2)
  @menu.disable_item(4)
end
@menu.focus
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
  rec=@message[@msgcur].sender
  rec=@message[@msgcur].receiver if @message[@msgcur].sender==$name
  $scene = Scene_Messages_New.new(rec,"RE: " + @message[@msgcur].subject.sub("RE: ",""),"",export)
when 1
  if @message[@msgcur].marked==0
    if srvproc("messages","name=#{$name}\&token=#{$token}\&mark=1\&id=#{@message[@msgcur].id}")[0].to_i<0
      speech(_("General:error"))
      speech_wait
    else
      speech(_("Messages:info_flagged"))
      speech_wait
      @message[@msgcur].marked=1
      end
    else
if srvproc("messages","name=#{$name}\&token=#{$token}\&unmark=1\&id=#{@message[@msgcur].id}")[0].to_i<0
      speech(_("General:error"))
      speech_wait
    else
      speech(_("Messages:info_glagremoved"))
      speech_wait
      @sel.disable_item(@msgcur) if @markedsearch==true and @search==true
      @message[@msgcur].marked=0
      end
      end
  @sel.focus
    when 2
  deletemessage
when 3
$scene = Scene_Messages_New.new("","","",@wn)
when 4
         if @message[@msgcur].text==""
           msgtemp = srvproc("messages","name=#{$name}\&token=#{$token}\&id=#{@message[@msgcur].id}\&read=1")
                  if msgtemp[0].to_i < 0
           speech(_("General:error"))
           speech_wait
           $scene = Scene_Main.new
           return
         end
         @message[@msgcur].text=msgtemp[9..msgtemp.size-1].join
         end
  $scene = Scene_Messages_New.new("","FW: " + @message[@msgcur].subject,"#{@message[@msgcur].sender}: \r\n" + @message[@msgcur].text,@wn)
when 5
  msgtemp = srvproc("message_allread","name=#{$name}\&token=#{$token}")
    if msgtemp[0].to_i < 0
    speech(_("General:error"))
    speech_wait
    $scene = Scene_Main.new
    return 
    end
    speech(_("Messages:info_allmarkedasread"))
speech_wait
if @wn == true
  $scene = Scene_WhatsNew.new
  return
else
  $scene=Scene_Messages.new
  return
  end
  when 6
  sr=input_text(_("Messages:type_searchphrase"),"ACCEPTESCAPE")
  if sr!="\004ESCAPE\004"
  @search=true
  @lastindex=@sel.index
msgtemp=srvproc("messages","name=#{$name}\&token=#{$token}\&search=1\&query=#{sr}")
if msgtemp[0].to_i<0
  speech(_("General:error"))
  speech_wait
  return
  end
ans=[]
for i in 1..msgtemp.size-1
  ans.push(msgtemp[i].to_i)
  end
    for i in 0..@message.size-1
  if ans.include?(@message[i].id)==false
    @sel.disable_item(i)
      end
end
@sel.header=_("Messages:head_searchresults")
@sel.focus
  end
  loop_update
when 7
        @search=true
        @markedsearch=true
  @lastindex=@sel.index
    for i in 0..@message.size-1
  if @message[i].receiver!=$name
    @sel.disable_item(i)
  else
    if @message[i].marked==1
    @sel.enable_item(i)
  else
    @sel.disable_item(i)
    end
      end
end
@sel.header=_("Messages:head_flagged")
@sel.index=0
@sel.focus
  when 8
    play("menu_close")
  Audio.bgs_stop
  main
  return
  when 9
      @search=true
  @lastindex=@sel.index
    for i in 0..@message.size-1
  if @message[i].sender!=$name
    @sel.disable_item(i)
  else
    @sel.enable_item(i)
      end
end
@sel.header=_("Messages:head_sent")
@sel.index=0
@sel.focus
  when 10
if @wn != true
  $scene = Scene_Main.new
else
  $scene=Scene_WhatsNew.new
  end
end
break
end
if alt or escape
loop_update
  break
end
end
Audio.bgs_stop
play("menu_close")
end
def deletemessage
  confirm(_("Messages:alert_delete")) do
    if srvproc("messages","name=#{$name}\&token=#{$token}\&delete=1\&id=#{@message[@sel.index].id.to_s}")[0].to_i<0
      speech(_("General:error"))
      speech_wait
      @sel.focus
      return
    end
    speech(_("Messages:info_messagedeleted"))
    speech_wait
    return $scene=Scene_Messages.new(true) if @wn==true
                ind=@sel.index
    @sel.commandoptions.delete_at(ind)
    @message.delete_at(ind)
      end
  @sel.focus
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
           @fields[0] = Edit.new(_("Messages:type_receiver"),"",receiver,true)
@fields[1] = Edit.new(_("Messages:type_subject"),"",subject,true)
           @fields[2] = ((@text.is_a?(Edit))?@text:Edit.new(_("Messages:type_content"),"MULTILINE",text,true))
           @fields[3] = Button.new(_("Messages:btn_recmessage"))
           @fields[4]=nil
           @fields[5]=nil
           @fields[6] = Button.new(_("General:str_cancel"))
           @fields[7]=nil
           @fields[8]=nil
           @fields[9]=Button.new(_("Messages:btn_attach"))                      
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
                                       @form.fields[5]=Select.new(fl,true,0,_("Messages:head_attachments"),true)
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
               elsif rec == 0 and @form.fields[2].text!=""
                 sc=true
                 end
               if sc == true
                 @form.fields[4] = Button.new(_("Messages:btn_send"))
                      @form.fields[7] = Button.new(_("Messages:btn_sendasadmin")) if $rang_moderator > 0 or $rang_developer > 0
           @form.fields[8] = Button.new(_("Messages:btn_sendtoall")) if $rang_moderator > 0 or $rang_developer > 0
           end
         elsif @form.fields[4]!=nil
           sc=false
               if rec == 1
                 sc=true
               elsif rec == 0 and @form.fields[2].text==""
                 sc=true
                 end
           if sc == true
                 @form.fields[4]=nil
                      @form.fields[7]=nil if $rang_moderator > 0 or $rang_developer > 0
           @fields[8]=nil if $rang_moderator > 0 or $rang_developer > 0
           end
               end
             if (Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN)) and @form.index == 0
               s = selectcontact
               if s != nil
                 @form.fields[0].settext(s)
                 end
               end
           @form.update
               if (enter or space) and @form.index == 3
             if rec == 0
             play("recording_start")
             recording_start("temp/audiomessage.wav")
             @msgedit=@form.fields[2]
             @form.fields[2]=Button.new(_("Messages:btn_audiomessage"))
             @form.fields[3]=Button.new(_("Messages:btn_stoprec"))
           @form.fields[7]=nil
             @form.fields[8]=nil
             rec = 1
         elsif rec == 1
           play("recording_stop")
           recording_stop
           @form.fields[3]=Button.new(_("Messages:btn_play"))
           @form.fields[2] = Button.new(_("Messages:btn_cancelrec"))
           rec = 2
         elsif rec == 2
                      player("temp/audiomessage.wav","",true)
                                   end
                                 end
                                 if (enter or space) and @form.index == 2 and rec > 1
                                   @form.fields[2] = @msgedit
                                   rec = 0
                                   @form.fields[3] = Button.new(_("Messages:btn_recmessage"))
                                   @form.index=2
                                   @form.fields[2].focus
                                   end
               if (enter or space) and @form.index==9
                 if @attachments.size>=3
                   speech(_("Messages:info_nomoreattachments"))
                   else
                 loc=getfile(_("Messages:head_selattachment"),getdirectory(5)+"\\",false)
                 if loc!=""
                   size=read(loc,true)
                                      if size>16777215
                     speech(_("Messages:info_filetoolarge"))
                     else
                   @attachments.push(loc)
                   speech(_("Messages:info_attached"))
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
                                   @form.fields[0].finalize
                                                          @form.fields[1].finalize
                       @form.fields[2].finalize if rec==0
                       receiver = @form.fields[0].text_str
                       receiver.sub!("@elten-net.eu","")
                       receiver=finduser(receiver) if receiver.include?("@")==false and finduser(receiver).upcase==receiver.upcase
                       if user_exist(receiver) == false or @form.index == 8 and (/^[a-zA-Z0-9.\-_\+]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/=~receiver)==nil
                         speech(_("Messages:info_receivernotfound"))
                       elsif (/^[a-zA-Z0-9.\-_\+]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/=~receiver)!=nil
                         if simplequestion(_("Messages:alert_mail")) == 1
                           subject = @form.fields[1].text_str
                       text = @form.fields[2].text_str if rec == 0
                       play("list_select")
                       break
                       end
                         else
                       subject = @form.fields[1].text_str
                       text = @form.fields[2].text_str if rec == 0
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
           data = ""
                                      host = $srv
  host.delete!("/")
        fl=read(a)
    boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"data\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
    q = "POST /srv/attachments.php?add=1\&filename=#{File.basename(a).urlenc}\&name=#{$name}\&token=#{$token} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary.to_s}\r\nContent-Length: #{length}\r\n\r\n#{data}"
  a = connect(host,80,q,2048,s_("Messages:wait_sendingfile",{'file'=>File.basename(a)}))
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech(_("General:error"))
    return nil
  end
  sn = a[s..a.size - 1]
    a = nil
        bt = strbyline(sn)
err = bt[0].to_i
            speech_wait
                        if err < 0
      speech(_("General:error"))
    speech_wait
      else
      @att+=bt[1].delete("\r\n")+","
    end
             end
           end
                    msgtemp=""
         if rec == 0
           bufid = buffer(text)
                    tmp = ""
         tmp = "admin_" if @form.index == 7
         msgtemp = ""
         if @form.index != 8
                 ex=""
            if @att!="" and @att!=nil
              @att.chop!
                    bufatt=buffer(@att)
      ex="\&bufatt="+bufatt.to_s
              end         
           msgtemp = srvproc("message_#{tmp}send","name=#{$name}\&token=#{$token}\&to=#{receiver.urlenc}\&subject=#{subject.urlenc}\&buffer=#{bufid}#{ex}")
       else
             @users = srvproc("users","name=#{$name}\&token=#{$token}")
        err = @users[0].to_i
    case err
    when -1
      speech(_("General:error_db"))
      speech_wait
      $scene = Scene_Main.new
      dialog_close
      return
      when -2
        speech(_("General:error_token"))
        speech_wait
        $scene = Scene_Main.new
        dialog_close
        return
        when -3
          speech(_("General:error_permissions"))
          $scene = Scene_Main.new
          dialog_close
          return
    end
        for i in 0..@users.size - 1
      @users[i].delete!("\r")
      @users[i].delete!("\n")
    end
    usr = []
    for i in 1..@users.size - 1
      usr.push(@users[i]) if @users[i].size > 0
    end
    for receiver in usr
      loop_update
      ex=""
            if @att!="" and @att!=nil
      bufatt=buffer(@att)
      ex="\&bufatt="+bufatt.to_s
    end
    msgtemp = srvproc("message_send","name=#{$name}\&token=#{$token}\&to=#{receiver}\&subject=#{subject}\&buffer=#{bufid}#{ex}")
      end
    end
  else
    if rec == 1
    recording_stop
    play("recording_stop")
  end
  waiting            
  speech(_("Messages:wait_converting"))
      File.delete("temp/audiomessage.opus") if FileTest.exists?("temp/audiomessage.opus")
      h = run("bin\\ffmpeg.exe -y -i \"temp\\audiomessage.wav\" -b:a 96K temp/audiomessage.opus",true)
      t = 0
      tmax = 1000
      loop do
        loop_update
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
if x != "\003\001"
  break
  end
t += 10.0/Graphics.frame_rate
if t > tmax
  speech(_("General:error"))
  return -1
  break
  end
        end
                  fl = read("temp/audiomessage.opus")
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
    speech(_("General:error"))
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = strbyline(sn)
msgtemp = bt[1].to_i
waiting_end
                                      end
         case msgtemp[0].to_i
         when 0
           speech(_("Messages:info_sent"))
           speech_wait
           if @scene != false and @scene != true and @scene.is_a?(Integer) == false and @scene.is_a?(Array)==false
           $scene = @scene
         else
           @text.settext("") if @text.is_a?(Edit)
           $scene = Scene_Messages.new(@scene)
           dialog_close
           return
           end
           when -1
             speech(_("General:error_db"))
             speech_wait
             $scene = Scene_Main.new
             dialog_close
             return
             when -2
               speech(_("General:error_token"))
               speech_wait
               $scene = Scene_Loading.new
               dialog_close
               return
               when -3
                 speech(_("General:error_permissions"))
                 speech_wait
                                  when -4
                 speech(_("Messages:info_receivernotfound"))  
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
@attachments_names=nil
                                                   end
               end
#Copyright (C) 2014-2018 Dawid Pieper