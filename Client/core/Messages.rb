#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Messages
  def initialize(wn=2000)
    @wn=wn
    end
  def main
    if $name=="guest"
      speech("Ta funkcja nie jest dostępna na koncie gościa.")
      speech_wait
      $scene=Scene_Main.new
      return
      end
          @msg = srvproc("messages","name=#{$name}\&token=#{$token}\&list=1#{if @wn==true;"\&unread=1";elsif @wn==0;"";else;"\&limit=#{@wn}";end}")
            case @msg[0].to_i
    when -1
      speech("Błąd połączenia się z bazą danych.")
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        $scene = Scene_Loading.new
        return
        when -3
          speech("Nieznany błąd.")
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
            speech("Nie masz żadnych wiadomości.")
          speech_wait
        elsif @wn==true and @unread==0
          speech("Brak nowych wiadomości")
          speech_wait
          $scene=Scene_WhatsNew.new
          return
               end
     @msgsel = []
     for i in 0..@message.size - 1
       @msgsel[i] = ""
       if @message[i].receiver==$name                         
       @msgsel[i] += @message[i].subject + " Od: " + @message[i].sender
     else
       @msgsel[i] += @message[i].subject + " Do: " + @message[i].receiver
       end
                         @msgsel[i] += "\004INFNEW{Nowa: }\004 " if @message[i].mread == 0 and @wn != true       
                         @msgsel[i] += "\004ATTACHMENT\004 " if @message[i].attachments != "" and @message[i].attachments!=[]
              end
     h=""
     h="Wiadomości odebrane" if @wn != true
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
@sel.commandoptions.push("Załaduj więcej wiadomości") if @wn.is_a?(Integer) and @wn<@messages
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
           @sel.header="Wiadomości odebrane"
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
           speech("Błąd")
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
                               fields = [Edit.new(@message[@msgcur].subject + " Od: " + @message[@msgcur].sender,"MULTILINE|READONLY",@message[@msgcur].text+"\r\n"+date,true)]
                  if @message[@msgcur].attachments.size>0
                    att=[]
                    for at in @message[@msgcur].attachments
                      ati=srvproc("attachments","name=#{$name}\&token=#{$token}\&info=1\&id=#{at}")
                      if ati[0].to_i<0
                        speech("Błąd")
                        $scene=Scene_Main.new
                        return
                      end
                      att.push(ati[2])  
                    end
                    fields[1]=Select.new(att,true,0,"Załączniki",true)
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
                        speech("Błąd")
                        $scene=Scene_Main.new
                        return
                      end
    id=at
    name=ati[2].delete("\r\n")
        loc=getfile("Gdzie chcesz zapisać ten plik?",getdirectory(40)+"\\",true,"Documents")
    if loc!=""
      waiting
      downloadfile($url+"attachments/"+id.to_s,loc+"\\"+name)
      speech_wait
      waiting_end
      speech("Załącznik został pobrany.")
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
@menu = menulr(["Odpowiedz","Oznacz","Usuń","Wyślij nową wiadomość","Przekaż dalej","Oznacz wszystkie wiadomości jako przeczytane","Szukaj","Pokaż oznaczone wiadomości","Odśwież","Pokaż wiadomości wysłane","Anuluj"],true,0,"",true)
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
  @menu.commandoptions[1]="Usuń oznaczenie" if @message[@msgcur]!=nil and @message[@msgcur].marked>0
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
  $scene = Scene_Messages_New.new(rec,"RE: " + @message[@msgcur].subject.sub("RE: ",""),"",@wn)
when 1
  if @message[@msgcur].marked==0
    if srvproc("messages","name=#{$name}\&token=#{$token}\&mark=1\&id=#{@message[@msgcur].id}")[0].to_i<0
      speech("Błąd.")
      speech_wait
    else
      speech("Wiadomość została oznaczona.")
      speech_wait
      @message[@msgcur].marked=1
      end
    else
if srvproc("messages","name=#{$name}\&token=#{$token}\&unmark=1\&id=#{@message[@msgcur].id}")[0].to_i<0
      speech("Błąd.")
      speech_wait
    else
      speech("Wiadomość nie jest już oznaczona.")
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
           speech("Błąd")
           speech_wait
           $scene = Scene_Main.new
           return
         end
         @message[@msgcur].text=msgtemp[9..msgtemp.size-1].join
         end
  $scene = Scene_Messages_New.new("","FW: " + @message[@msgcur].subject,"Przekazana od: #{@message[@msgcur].sender} \r\n" + @message[@msgcur].text,@wn)
when 5
  msgtemp = srvproc("message_allread","name=#{$name}\&token=#{$token}")
    if msgtemp[0].to_i < 0
    speech("Błąd")
    speech_wait
    $scene = Scene_Main.new
    return 
    end
    speech("Wszystkie wiadomości zostały oznaczone jako przeczytane.")
speech_wait
if @wn == true
  $scene = Scene_WhatsNew.new
  return
else
  $scene=Scene_Messages.new
  return
  end
  when 6
  sr=input_text("Podaj tekst do wyszukania","ACCEPTESCAPE")
  if sr!="\004ESCAPE\004"
  @search=true
  @lastindex=@sel.index
msgtemp=srvproc("messages","name=#{$name}\&token=#{$token}\&search=1\&query=#{sr}")
if msgtemp[0].to_i<0
  speech("Błąd.")
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
@sel.header="Wyniki wyszukiwania"
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
@sel.header="Wiadomości oznaczone"
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
@sel.header="Wiadomości wysłane"
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
delay
end
def deletemessage
  confirm("Czy jesteś pewien, że chcesz usunąć tę wiadomość?") do
    if srvproc("messages","name=#{$name}\&token=#{$token}\&delete=1\&id=#{@message[@sel.index].id.to_s}")[0].to_i<0
      speech("Błąd")
      speech_wait
      @sel.focus
      return
    end
    speech("Wiadomość została usunięta.")
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
         @fields = []
           @fields[0] = Edit.new("Odbiorca","",receiver,true)
@fields[1] = Edit.new("Temat:","",subject,true)
           @fields[2] = Edit.new("Treść:","MULTILINE",text,true)
           @fields[3] = Button.new("Nagraj wiadomość głosową")
           @fields[4]=nil
           @fields[5]=nil
           @fields[6] = Button.new("Anuluj")
           @fields[7]=nil
           @fields[8]=nil
           @fields[9]=Button.new("Załącz plik")                      
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
                                       @form.fields[5]=Select.new(fl,true,0,"Załączniki",true)
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
                 @form.fields[4] = Button.new("Wyślij")
                      @form.fields[7] = Button.new("Wyślij jako administracja") if $rang_moderator > 0 or $rang_developer > 0
           @form.fields[8] = Button.new("Wyślij do wszystkich") if $rang_moderator > 0 or $rang_developer > 0
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
             @form.fields[2]=Button.new("Wiadomość głosowa")
             @form.fields[3]=Button.new("Zakończ nagrywanie")
           @form.fields[7]=nil
             @form.fields[8]=nil
             rec = 1
         elsif rec == 1
           play("recording_stop")
           recording_stop
           @form.fields[3]=Button.new("Odtwórz")
           @form.fields[2] = Button.new("Anuluj nagrywanie")
           rec = 2
         elsif rec == 2
                      player("temp/audiomessage.wav","",true)
                                   end
                                 end
                                 if (enter or space) and @form.index == 2 and rec > 1
                                   @form.fields[2] = @msgedit
                                   rec = 0
                                   @form.fields[3] = Button.new("Nagraj wiadomość głosową")
                                   @form.index=2
                                   @form.fields[2].focus
                                   end
               if (enter or space) and @form.index==9
                 if @attachments.size>=3
                   speech("Nie można dodać więcej załączników.")
                   else
                 loc=getfile("Wybierz plik do załączenia",getdirectory(5)+"\\",false)
                 if loc!=""
                   size=read(loc,true)
                                      if size>16777215
                     speech("Plik jest zbyt duży.")
                     else
                   @attachments.push(loc)
                   speech("Załącznik dodany.")
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
                       if user_exist(receiver) == false or @form.index == 8 and (/^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/=~receiver)==nil
                         speech("Odbiorca wiadomości nie istnieje")
                       elsif (/^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/=~receiver)!=nil
                         if simplequestion("Czy chcesz wysłać tą wiadomość jako E-mail?") == 1
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
                                                              if @scene != false and @scene != true and @scene.is_a?(Integer)==false
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
  a = connect(host,80,q,2048,"Przesyłanie: #{File.basename(a)}")
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech("Błąd")
    return nil
  end
  sn = a[s..a.size - 1]
    a = nil
        bt = strbyline(sn)
err = bt[0].to_i
            speech_wait
                        if err < 0
      speech("Błąd")
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
           msgtemp = srvproc("message_#{tmp}send","name=#{$name}\&token=#{$token}\&to=#{receiver}\&subject=#{subject}\&buffer=#{bufid}#{ex}")
       else
             @users = srvproc("users","name=#{$name}\&token=#{$token}")
        err = @users[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      dialog_close
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Main.new
        dialog_close
        return
        when -3
          speech("Nie masz odpowiednich uprawnień, by wykonać tę operację.")
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
  speech("Konwertowanie pliku...")
      File.delete("temp/audiomessage.opus") if FileTest.exists?("temp/audiomessage.opus")
      h = run("bin\\ffmpeg.exe -y -i \"temp\\audiomessage.wav\" -b:a 96K temp/audiomessage.opus",true)
      t = 0
      tmax = 1000
      loop do
        loop_update
x=Elten::Engine::Kernel.getexitcodeprocess(h)
        x.delete!("\0")
if x != "\003\001"
  break
  end
t += 10.0/Graphics.frame_rate
if t > tmax
  speech("błąd")
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
    speech("Błąd")
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
           speech("Wiadomość została wysłana")
           speech_wait
           if @scene != false and @scene != true and @scene.is_a?(Integer) == false
           $scene = @scene
         else
           $scene = Scene_Messages.new(@scene)
           dialog_close
           return
           end
           when -1
             speech("Błąd połączenia się z bazą danych.")
             speech_wait
             $scene = Scene_Main.new
             dialog_close
             return
             when -2
               speech("Klucz sesji wygasł.")
               speech_wait
               $scene = Scene_Loading.new
               dialog_close
               return
               when -3
                 speech("Nie posiadasz uprawnień do wykonania tej operacji. Prawdopodobnie znajdujesz się na czarnej liście odbiorcy wiadomości.")
                 speech_wait
                                  when -4
                 speech("Odbiorca wiadomości nie istnieje.")  
               end
               dialog_close
         end
       end
       
class Struct_Message
               attr_accessor :id
               attr_accessor :receiver
               attr_accessor :sender
               attr_accessor :subject
                              attr_accessor :mread
                                             attr_accessor :marked
               attr_accessor :date
                              attr_accessor :attachments
                              attr_accessor :text
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
                 end
               end
#Copyright (C) 2014-2016 Dawid Pieper