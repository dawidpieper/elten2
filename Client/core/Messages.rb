#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Messages
  def main
        $msg = srvproc("messages_received","name=#{$name}\&token=#{$token}")
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
     $messages = $msg[1].to_i
     wterrt = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&messages=#{$messages}\&posts=-1\&set=1")
          wterr = wterrt[0].to_i
          if $messages == 0
       speech("Nie masz żadnych wiadomości.")
       speech_wait
     end
     if $messages > 0
     $message = []
          l = 2
     for i in 0..$messages - 1
       c = i
      t = 0
      id = $messages - 1 - i
      $message[id] = Struct_Message.new(id)
      while $msg[l] != "\004END\004\n"
         t += 1
         if t == 1
           read = $msg[l].to_i
           $message[id].read = $msg[l].to_i
                           elsif t > 4
           $message[id] = Struct_Message.new(id) if $message[id] == nil
                             $message[id].text += $msg[l] if $msg[l] != nil
                  elsif t == 2
                      $message[id].subject = $msg[l].delete("\r\n")
         elsif t == 3
           $message[id].sender = $msg[l].delete("\r\n")
         elsif t == 4
           $message[id].id = $msg[l].delete("\r\n")
         end
         l += 1
       end
       l += 1
     end
     $msgsel = []
     for i in 0..$message.size - 1
       $msgsel[i] = ""
       if $message[i].read == 0
         $msgsel[i] += "Nowa: \004NEW\004 "
         end
       $msgsel[i] += $message[i].subject + " OD: " + $message[i].sender
       end
     $sel = Select.new($msgsel,true,0,"Wiadomości odebrane")
     loop do
loop_update
       $sel.update
       update
       if alt
                  menu
       end
       if escape
                  $scene = Scene_Main.new
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
                      $scene = Scene_Main.new
           end
         end
     end
     end
     def update
         $msgcur = $sel.index
         $scene = Scene_Messages_Delete.new($id[$msgcur]) if $key[0x2e]
         if enter
         msgtemp = srvproc("message_read","name=#{$name}\&token=#{$token}\&id=#{$message[$msgcur].id}")
                  if msgtemp[0].to_i < 0
           speech("Błąd")
           speech_wait
           $scene = Scene_Main.new
           return
         end
         dialog_open
         $message[$msgcur].read = Time.now.to_i
         $msgsel[$msgcur] = $message[$msgcur].subject + " OD: " + $message[$msgcur].sender
         $sel.commandoptions = $msgsel  
                  $inpt = Edit.new($message[$msgcur].subject + " Od: " + $message[$msgcur].sender,"MULTILINE|READONLY",$message[$msgcur].text)
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
     speech("Wiadomości odebrane: " + $msgsel[$sel.index])
      end
   end
   def menu_no_messages
play("menu_open")
play("menu_background")
@sel = SelectLR.new(["Nowa wiadomość","Pokaż wiadomości wysłane","Anuluj"])
loop do
loop_update
@sel.update
if enter
case @sel.index
when 0
$scene = Scene_Messages_New.new
break
when 1
  $scene = Scene_Messages_Sent.new
  break
when 2
$scene = Scene_Main.new
break
end
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
Graphics.transition(10)
return
end
def menu
play("menu_open")
play("menu_background")
@sel = SelectLR.new(["Odpowiedz","Usuń","Wyślij nową wiadomość","Przekaż dalej","Oznacz wszystkie wiadomości jako przeczytane","Pokaż wiadomości wysłane","Anuluj"])
loop do
loop_update
@sel.update
$msgcur = $sel.index
if enter
case @sel.index
when 0
  $scene = Scene_Messages_New.new($message[$msgcur].sender,"RE: " + $message[$msgcur].subject.sub("RE: ",""),"")
when 1
  $scene = Scene_Messages_Delete.new($message[$msgcur].id)
when 2
$scene = Scene_Messages_New.new
when 3
$scene = Scene_Messages_New.new("","FW: " + $message[$msgcur].subject,"Przekazana przez: #{$name} \r\n" + $message[$msgcur].text)
when 4
  msgtemp = srvproc("message_allread","name=#{$name}\&token=#{$token}")
    if msgtemp[0].to_i < 0
    speech("Błąd")
    speech_wait
    $scene = Scene_Main.new
    return 
    end
for i in 0..$msgsel.size - 1
  $msgsel[i] = $subject[i] + " OD: " + $sender[i]
end
$sel.commandoptions = $msgsel  
    speech("Wszystkie wiadomości zostały oznaczone jako przeczytane.")
speech_wait
when 5
  $scene = Scene_Messages_Sent.new
when 6
$scene = Scene_Main.new
end
break
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
Graphics.transition(5)
end
     end
     
     class Scene_Messages_New
       def initialize(receiver="",subject="",text="",scene=nil)
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
           @fields[4] = Button.new("Wyślij")
           @fields[5] = Button.new("Anuluj")
           @fields[6] = Button.new("Wyślij jako administracja") if $rang_moderator > 0 or $rang_developer > 0
           @fields[7] = Button.new("Wyślij do wszystkich") if $rang_moderator > 0 or $rang_developer > 0
                                 @form = Form.new(@fields)
rec=0
                                 loop do                     
             loop_update
             @form.update
             if (Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN)) and @form.index == 0
               s = selectcontact
               if s != nil
                 @form.fields[0].settext(s)
                 end
               end
           if (enter or space) and @form.index == 3
             if rec == 0
             play("recording_start")
             recording_start("temp/audiomessage.wav")
             @msgedit=@form.fields[2]
             @form.fields[2]=Button.new("Wiadomość głosowa")
             @form.fields[3]=Button.new("Zakończ nagrywanie")
           @form.fields[6]=nil
             @form.fields[7]=nil
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
               if (enter or space) and ((@form.index == 4 or @form.index == 6 or @form.index == 7) or $key[0x11] == true)
                                   @form.fields[0].finalize
                                                          @form.fields[1].finalize
                       @form.fields[2].finalize if rec==0
                       receiver = @form.fields[0].text_str
                       if user_exist(receiver) == false or @form.index == 7
                         speech("Odbiorca wiadomości nie istnieje")
                         else
                       subject = @form.fields[1].text_str
                       text = @form.fields[2].text_str if rec == 0
                       play("list_select")
                       break
                       end
                     end
                     if escape or ((enter or space) and @form.index == 5)
                                                              if @scene != nil
           $scene = @scene
         else
           $scene = Scene_Messages.new
         end
         loop_update
         dialog_close  
         return  
           break
         end
         end
         msgtemp=""
         if rec == 0
           bufid = buffer(text)
         tmp = ""
         tmp = "admin_" if @form.index == 6
         msgtemp = ""
         if @form.index != 7
         msgtemp = srvproc("message_#{tmp}send","name=#{$name}\&token=#{$token}\&to=#{receiver}\&subject=#{subject}\&buffer=#{bufid}")
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
      msgtemp = srvproc("message_send","name=#{$name}\&token=#{$token}\&to=#{receiver}\&subject=#{subject}\&buffer=#{bufid}")
      end
    end
  else
    if rec == 1
    recording_stop
    play("recording_stop")
  end
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
      speech("Przygotowywanie do wysłania wiadomości...")
        data = ""
            begin
            data = read("temp/audiomessage.mp3").urlenc(true) if data == ""
          rescue Exception
            retry
          end
          data = "data="+data
  host = $url.sub("https://","")
  host.delete!("/")
  length = data.size
  q = "POST /message_send.php?name=#{$name}\&token=#{$token}\&to=#{receiver.urlenc}\&subject=#{subject.urlenc}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
                                      end
         case msgtemp[0].to_i
         when 0
           speech("Wiadomość została wysłana")
           speech_wait
           if @scene != nil
           $scene = @scene
         else
           $scene = Scene_Messages.new
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
         def initialize(id)
           @id = id.to_i
         end
         def main
                      o=simplequestion("Czy jesteś pewien, że chcesz usunąć tę wiadomość?")
                          if o == 0
                 $scene = Scene_Messages.new
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
                 $scene = Scene_Messages.new
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
     $messages = $msg[1].to_i
          if $messages == 0
       speech("Nie wysłałeś żadnych wiadomości lub wszystkie wysłane przez ciebie wiadomości zostały usunięte.")
       speech_wait
     end
     if $messages > 0
     $message = []
          l = 2
     for i in 0..$messages - 1
       c = i
      t = 0
      id = $messages - 1 - i
      $message[id] = Struct_Message.new(id)
      while $msg[l] != "\004END\004\n"
         t += 1
         if t == 1
           read = $msg[l].to_i
           $message[id].read = $msg[l].to_i
                           elsif t > 4
           $message[id].text = "" if $message[id] == nil
                             $message[id].text += $msg[l] if $msg[l] != nil
                  elsif t == 2
                      $message[id].subject = $msg[l]
         elsif t == 3
           $message[id].receiver = $msg[l]
         elsif t == 4
           $message[id].id = $msg[l]
         end
         l += 1
       end
       l += 1
     end
     $msgsel = []
     for i in 0..$message.size - 1
       $msgsel[i] = ""
       if $message[i].read == 0
         $msgsel[i] += "Nieprzeczytana: \004NEW\004 "
         end
       $msgsel[i] += $message[i].subject + " DO: " + $message[i].receiver
       end
     $sel = Select.new($msgsel,true,0,"Wiadomości wysłane")
     loop do
loop_update
       $sel.update
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
         $msgcur = $sel.index
         if enter
           dialog_open       
           $inpt = Edit.new($message[$msgcur].subject + " Do: " + $message[$msgcur].receiver,"MULTILINE|READONLY",$message[$msgcur].text)
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
     speech("Wiadomości wysłane: " + $msgsel[$sel.index])
      end
   end
   def menu_no_messages
play("menu_open")
play("menu_background")
@sel = SelectLR.new(["Nowa wiadomość","Anuluj"])
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
Graphics.transition(10)
return
end
def menu
play("menu_open")
play("menu_background")
@sel = SelectLR.new(["Wyślij wiadomość do tego odbiorcy","Usuń","Wyślij nową wiadomość","Przekaż dalej","Anuluj"])
loop do
loop_update
@sel.update
$msgcur = $sel.index
if enter
case @sel.index
when 0
  $scene = Scene_Messages_New.new($message[$msgcur].receiver,"","",$scene)
when 1
  $scene = Scene_Messages_Delete.new($message[$msgcur].id)
  when 2
$scene = Scene_Messages_New.new("","","",$scene)
when 3
$scene = Scene_Messages_New.new("","FW: " + $message[$msgcur].subject,"Przekazana przez: #{$name} \r\n" + $message[$msgcur].text)
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
Graphics.transition(5)
end
end


class Scene_Messages_Sent_Delete
         def initialize(id)
           @id = id.to_i
         end
         def main
           speech("Czy jesteś pewien, że chcesz usunąć tę wiadomość?")
           speech_wait
           @sel = SelectLR.new(["Nie","Tak"])
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
               attr_accessor :read
               def initialize(id=0)
                 @id=id
                 @receiver=$name
                 @sender=$name
                 @subject=""
                 @read=0
                 @text=""
                 end
               end
#Copyright (C) 2014-2016 Dawid Pieper