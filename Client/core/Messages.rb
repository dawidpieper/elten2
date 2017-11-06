#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Messages
  def initialize(wn=false)
    @wn=wn
    end
  def main
    if $name=="guest"
      speech("Ta funkcja nie jest dostępna na koncie gościa.")
      speech_wait
      $scene=Scene_Main.new
      return
      end
    if @wn == false    
    $msg = srvproc("messages_received","name=#{$name}\&token=#{$token}\&hash=2")
  else
    $msg = srvproc("messages_received","name=#{$name}\&token=#{$token}\&new=1\&hash=2")
  end
            case $msg[0].chop!.to_i
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
     @messages = $msg[1].to_i
     if @wn == false
     wterrt = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&messages=#{@messages}\&posts=-1\&set=1")
          wterr = wterrt[0].to_i
        else
         wterrt = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&messages=#{@messages}\&posts=-1\&set=2")
          wterr = wterrt[0].to_i
          end
                    if @messages == 0
if @wn == false
            speech("Nie masz żadnych wiadomości.")
          speech_wait
        else
          speech("Brak nowych wiadomości")
          speech_wait
          $scene=Scene_WhatsNew.new
          return
          end
     end
     if @messages > 0
              mes=eval($msg[2],nil,"msg").reverse
       @message = []
          l = 2
     for m in mes
              id,mread,subject,sender,date,text,attachments=m
              ind=@message.size
                     @message[ind] = Struct_Message.new(id)
                            @message[ind].mread = mread
                                                                   @message[ind].text = text
                                        @message[ind].subject = subject
                    @message[ind].sender = sender
                    @message[ind].id = id
                    @message[ind].text+="\r\n"+date
                    @message[ind].attachments=attachments.split(",")
                              end
     @msgsel = []
     for i in 0..@message.size - 1
       @msgsel[i] = ""
       if @message[i].mread == 0 and @wn == false
         @msgsel[i] += "Nowa: \004NEW\004 "
         end
       @msgsel[i] += @message[i].subject + " OD: " + @message[i].sender
              end
     h=""
     h="Wiadomości odebrane" if @wn == false
              @sel = Select.new(@msgsel,true,0,h)
          if @msgsel.size==0 and @wn==false
       speech("Brak nowych wiadomości")
       speech_wait
       $scene=Scene_WhatsNew.new
     end
     loop do
loop_update
       @sel.update
       update
       if alt
                  menu
       end
       if escape or (Input.trigger?(Input::LEFT) and @wn == true)
         if @search == true
           for i in 0..@sel.commandoptions.size-1
             @sel.enable_item(i)
           end
           @sel.header="Wiadomości odebrane"
           @sel.index=@lastindex
           @sel.focus
           @search=false
           else
         if @wn == false         
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
     else
       loop do
loop_update
         if $scene != self
           break
           end
         if alt
                      menu(false)
         end
         if escape
speech_stop
                      $scene = Scene_Main.new
           end
         end
     end
     end
     def update
         $msgcur = @sel.index
         $scene = Scene_Messages_Delete.new(@message[$msgcur].id,@wn) if $key[0x2e]
         if enter
         msgtemp = srvproc("message_read","name=#{$name}\&token=#{$token}\&id=#{@message[$msgcur].id}")
                  if msgtemp[0].to_i < 0
           speech("Błąd")
           speech_wait
           $scene = Scene_Main.new
           return
         end
         dialog_open
         @message[$msgcur].mread = Time.now.to_i
         @msgsel[$msgcur] = @message[$msgcur].subject + " OD: " + @message[$msgcur].sender
         @sel.commandoptions = @msgsel  
                  fields = [Edit.new(@message[$msgcur].subject + " Od: " + @message[$msgcur].sender,"MULTILINE|READONLY",@message[$msgcur].text,true)]
                  if @message[$msgcur].attachments.size>0
                    att=[]
                    for at in @message[$msgcur].attachments
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
    at=@message[$msgcur].attachments[form.fields[1].index]
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
      downloadfile($url+"attachments/"+id,loc+"\\"+name)
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
   def menu(messages=true)
play("menu_open")
play("menu_background")
@menu = menulr(["Odpowiedz","Usuń","Wyślij nową wiadomość","Przekaż dalej","Oznacz wszystkie wiadomości jako przeczytane","Szukaj","Pokaż wiadomości wysłane","Anuluj"],true)
if messages==false
  @menu.disable_item(0)
  @menu.disable_item(1)
  @menu.disable_item(3)
  @menu.disable_item(4)
  @menu.disable_item(5)
else
  $msgcur = @sel.index
  end
if @wn == true
  @menu.disable_item(2)
  @menu.disable_item(5)
  @menu.disable_item(5)
  end
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
  $scene = Scene_Messages_New.new(@message[$msgcur].sender,"RE: " + @message[$msgcur].subject.sub("RE: ",""),"",@wn)
when 1
  $scene = Scene_Messages_Delete.new(@message[$msgcur].id,@wn)
when 2
$scene = Scene_Messages_New.new("","","",@wn)
when 3
$scene = Scene_Messages_New.new("","FW: " + @message[$msgcur].subject,"Przekazana przez: #{$name} \r\n" + @message[$msgcur].text,@wn)
when 4
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
when 5
  sr=input_text("Podaj tekst do wyszukania","ACCEPTESCAPE")
  if sr!="\004ESCAPE\004"
  @search=true
  @lastindex=@sel.index
for i in 0..@message.size-1
  if @message[i].text.downcase.include?(sr.downcase) == false
    @sel.disable_item(i)
  elsif @message[i].text.include?("\004AUDIO\004")==true
    @sel.disable_item(i)
    end
end
@sel.header="Wyniki wyszukiwania"
@sel.focus
  end
  loop_update
  when 6
      $scene = Scene_Messages_Sent.new
  when 7
if @wn == false
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
           @form = Form.new(@fields)
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
               elsif rec == 0 and @form.fields[2].text!=[[]]
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
               elsif rec == 0 and @form.fields[2].text==[[]]
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
                                                              if @scene != false and @scene != true
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
                                      host = $url.sub("https://","")
  host.delete!("/")
        fl=read(a)
    boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"data\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
    q = "POST /attachments.php?add=1\&filename=#{File.basename(a).urlenc}\&name=#{$name}\&token=#{$token} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary.to_s}\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
      File.delete("temp/audiomessage.mp3") if FileTest.exists?("temp/audiomessage.mp3")
      h = run("bin\\ffmpeg.exe -y -i \"temp\\audiomessage.wav\" -b:a 128K temp/audiomessage.mp3",true)
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
  speech("błąd")
  return -1
  break
  end
        end
                  fl = read("temp/audiomessage.mp3")
            host = $url.sub("https://","")
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
    q = "POST /message_send.php?name=#{$name}\&token=#{$token}\&to=#{receiver.urlenc}\&subject=#{subject.urlenc}\&audio=1#{ex} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary.to_s}\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
           if @scene != false and @scene != true
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
                 speech("Brak uprawnień")
                 speech_wait
                 $scene = Scene_Main.new
               end
               dialog_close
         end
       end
       
       class Scene_Messages_Delete
         def initialize(id,wn=false)
           @id = id.to_i
         @wn=wn
           end
         def main
                      o=simplequestion("Czy jesteś pewien, że chcesz usunąć tę wiadomość?")
                          if o == 0
                 $scene = Scene_Messages.new(@wn)
                 else
                   delete
                            end
             end
             def delete
                                    msgtemp = srvproc("message_mod","delete=1\&token=#{$token}\&name=#{$name}\&id=#{@id}")
               err = msgtemp[0].to_i
              
                                             case err
               when 0
                 speech("Usunięto.")
                 speech_wait
                 $scene = Scene_Messages.new(@wn)
                 when -1
                   speech("Błąd połączenia się z bazą danych.")
                   speech_wait
                   $scene = Scene_Messages.new
                   when -2
                     speech("Klucz sesji wygasł.")
                     speech_wait
                     $scene = Scene_Loading.new
                   end
                return   
               end
             end
             
             class Scene_Messages_Sent
  def main
            $msg = srvproc("messages_sent","name=#{$name}\&token=#{$token}")
        case $msg[0].chop!.to_i
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
     @messages = $msg[1].to_i
          if @messages == 0
       speech("Nie wysłałeś żadnych wiadomości lub wszystkie wysłane przez ciebie wiadomości zostały usunięte.")
       speech_wait
     end
     if @messages > 0
     @message = []
          l = 2
     for i in 0..@messages - 1
       c = i
      t = 0
      id = @messages - 1 - i
      @message[id] = Struct_Message.new(id)
      while $msg[l] != "\004END\004\n"
         t += 1
         if t == 1
           mread = $msg[l].to_i
           @message[id].mread = $msg[l].to_i
                           elsif t > 4
           @message[id].text = "" if @message[id] == nil
                             @message[id].text += $msg[l] if $msg[l] != nil
                  elsif t == 2
                      @message[id].subject = $msg[l]
         elsif t == 3
           @message[id].receiver = $msg[l]
         elsif t == 4
           @message[id].id = $msg[l]
         end
         l += 1
       end
       l += 1
     end
     @msgsel = []
     for i in 0..@message.size - 1
       @msgsel[i] = ""
       if @message[i].mread == 0
         @msgsel[i] += "Nieprzeczytana: \004NEW\004 "
         end
       @msgsel[i] += @message[i].subject + " DO: " + @message[i].receiver
       end
     @sel = Select.new(@msgsel,true,0,"Wiadomości wysłane")
     loop do
loop_update
       @sel.update
       update
       if alt
                  menu
       end
       if escape
                  $scene = Scene_Messages.new
         end
       if $scene != self
         break
         end
       end
     else
       loop do
loop_update
         if $scene != self
           break
           end
         if alt
                      menu_no_messages
         end
         if escape
speech_stop
                      $scene = Scene_Messages.new
           end
         end
     end
     end
     def update
         $msgcur = @sel.index
         if enter
           dialog_open       
           $inpt = Edit.new(@message[$msgcur].subject + " Do: " + @message[$msgcur].receiver,"MULTILINE|READONLY",@message[$msgcur].text)
         play("list_select")
loop do
  loop_update
  $inpt.update
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
     speech("Wiadomości wysłane: " + @msgsel[@sel.index])
      end
   end
   def menu_no_messages
play("menu_open")
play("menu_background")
@sel = menulr(["Nowa wiadomość","Anuluj"])
loop do
loop_update
@sel.update
if enter
case @sel.index
when 0
$scene = Scene_Messages_New.new("","","",$scene)
break
when 1
$scene = Scene_Messages.new
break
end
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
delay(0.25)
return
end
def menu
play("menu_open")
play("menu_background")
@sel = menulr(["Wyślij wiadomość do tego odbiorcy","Usuń","Wyślij nową wiadomość","Przekaż dalej","Anuluj"])
loop do
loop_update
@sel.update
$msgcur = @sel.index
if enter
case @sel.index
when 0
  $scene = Scene_Messages_New.new(@message[$msgcur].receiver,"","",$scene)
when 1
  $scene = Scene_Messages_Delete.new(@message[$msgcur].id)
  when 2
$scene = Scene_Messages_New.new("","","",$scene)
when 3
$scene = Scene_Messages_New.new("","FW: " + @message[$msgcur].subject,"Przekazana przez: #{$name} \r\n" + @message[$msgcur].text)
    when 4
$scene = Scene_Messages.new
end
break
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
delay
end
end


class Scene_Messages_Sent_Delete
         def initialize(id)
           @id = id.to_i
         end
         def main
           speech("Czy jesteś pewien, że chcesz usunąć tę wiadomość?")
           speech_wait
           @sel = menulr(["Nie","Tak"])
           loop do
loop_update
             @sel.update
             if $scene != self
               break
             end
             if enter
               case @sel.index
               when 0
                 $scene = Scene_Messages_Sent.new
                 when 1
                   delete
               end
               end
             end
             end
             def delete
                              msgtemp = srvproc("message_sent_mod","delete=1\&token=#{$token}\&name=#{$name}\&id=#{@id}")
                              err = msgtemp[0].to_i
                                             case err
               when 0
                 speech("Usunięto.")
                 speech_wait
                 $scene = Scene_Messages_Sent.new
                 when -1
                   speech("Błąd połączenia się z bazą danych.")
                   speech_wait
                   $scene = Scene_Messages.new
                   when -2
                     speech("Klucz sesji wygasł.")
                     speech_wait
                     $scene = Scene_Loading.new
                   end
                return   
               end
             end
             
             class Struct_Message
               attr_accessor :id
               attr_accessor :receiver
               attr_accessor :sender
               attr_accessor :subject
               attr_accessor :text
               attr_accessor :mread
               attr_accessor :attachments
               def initialize(id=0)
                 @id=id
                 @receiver=$name
                 @sender=$name
                 @subject=""
                 @mread=0
                 @text=""
                 @attachments=[]
                 end
               end
#Copyright (C) 2014-2016 Dawid Pieper