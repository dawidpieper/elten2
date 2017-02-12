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
     $subject = []
     $sender = []
     $id = []
     $read = []
     l = 2
     for i in 0..$messages - 1
       c = i
      t = 0
      id = $messages - 1 - i
      $message[id] = ""
      while $msg[l] != "\004END\004\n"
         t += 1
         if t == 1
           read = $msg[l].to_i
           $read[id] = $msg[l].to_i
                           elsif t > 4
           $message[id] = "" if $message[id] == nil
                             $message[id] += $msg[l] if $msg[l] != nil
                  elsif t == 2
                      $subject[id] = $msg[l].delete("\r\n")
         elsif t == 3
           $sender[id] = $msg[l].delete("\r\n")
         elsif t == 4
           $id[id] = $msg[l].delete("\r\n")
         end
         l += 1
       end
       l += 1
     end
     $msgsel = []
     for i in 0..$message.size - 1
       $msgsel[i] = ""
       if $read[i] == 0
         $msgsel[i] += "Nowa: \004NEW\004 "
         end
       $msgsel[i] += $subject[i] + " OD: " + $sender[i]
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
         msgtemp = srvproc("message_read","name=#{$name}\&token=#{$token}\&id=#{$id[$msgcur]}")
                  if msgtemp[0].to_i < 0
           speech("Błąd")
           speech_wait
           $scene = Scene_Main.new
           return
         end
         dialog_open
         $read[$msgcur] = Time.now.to_i
         $msgsel[$msgcur] = $subject[$msgcur] + " OD: " + $sender[$msgcur]
         $sel.commandoptions = $msgsel  
         $inpt = Edit.new($subject[$msgcur] + " Od: " + $sender[$msgcur],"MULTILINE|READONLY",$message[$msgcur])
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
  $scene = Scene_Messages_New.new($sender[$msgcur],"RE: " + $subject[$msgcur].sub("RE: ",""),"")
when 1
  $scene = Scene_Messages_Delete.new($id[$msgcur])
when 2
$scene = Scene_Messages_New.new
when 3
$scene = Scene_Messages_New.new("","FW: " + $subject[$msgcur],"Przekazana przez: #{$name} \r\n" + $message[$msgcur])
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
           @fields[3] = Button.new("Wyślij")
           @fields[4] = Button.new("Anuluj")
           @fields[5] = Button.new("Wyślij jako administracja") if $rang_moderator > 0 or $rang_developer > 0
           @fields[6] = Button.new("Wyślij do wszystkich") if $rang_moderator > 0 or $rang_developer > 0
                                 @form = Form.new(@fields)
           loop do                     
             loop_update
             @form.update
             if (Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN)) and @form.index == 0
               s = selectcontact
               if s != nil
                 @form.fields[0].settext(s)
                 end
               end
           if (enter or space) and ((@form.index == 3 or @form.index == 5 or @form.index == 6) or $key[0x11] == true)
                                   @form.fields[0].finalize
                       @form.fields[1].finalize
                       @form.fields[2].finalize
                       receiver = @form.fields[0].text_str
                       if user_exist(receiver) == false or @form.index == 6
                         speech("Odbiorca wiadomości nie istnieje")
                         else
                       subject = @form.fields[1].text_str
                       text = @form.fields[2].text_str
                       play("list_select")
                       break
                       end
                     end
                     if escape or ((enter or space) and @form.index == 4)
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
                  bufid = buffer(text)
         tmp = ""
         tmp = "admin_" if @form.index == 5
         msgtemp = ""
         if @form.index != 6
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
                      @sel = SelectLR.new(["Nie","Tak"],true,0,"Czy jesteś pewien, że chcesz usunąć tę wiadomość?")
           loop do
loop_update
             @sel.update
             if $scene != self
               break
             end
             if enter
               case @sel.index
               when 0
                 $scene = Scene_Messages.new
                 when 1
                   delete
               end
               end
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
     $subject = []
     $receiver = []
     $id = []
     $read = []
     l = 2
     for i in 0..$messages - 1
       c = i
      t = 0
      id = $messages - 1 - i
      $message[id] = ""
      while $msg[l] != "\004END\004\n"
         t += 1
         if t == 1
           read = $msg[l].to_i
           $read[id] = $msg[l].to_i
                           elsif t > 4
           $message[id] = "" if $message[id] == nil
                             $message[id] += $msg[l] if $msg[l] != nil
                  elsif t == 2
                      $subject[id] = $msg[l]
         elsif t == 3
           $receiver[id] = $msg[l]
         elsif t == 4
           $id[id] = $msg[l]
         end
         l += 1
       end
       l += 1
     end
     $msgsel = []
     for i in 0..$message.size - 1
       $msgsel[i] = ""
       if $read[i] == 0
         $msgsel[i] += "Nieprzeczytana: \004NEW\004 "
         end
       $msgsel[i] += $subject[i] + " DO: " + $receiver[i]
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
           $inpt = Edit.new($subject[$msgcur] + " Do: " + $receiver[$msgcur],"MULTILINE|READONLY",$message[$msgcur])
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
  $scene = Scene_Messages_New.new($receiver[$msgcur],"","",$scene)
when 1
  $scene = Scene_Messages_Delete.new($id[$msgcur])
  when 2
$scene = Scene_Messages_New.new("","","",$scene)
when 3
$scene = Scene_Messages_New.new("","FW: " + $subject[$msgcur],"Przekazana przez: #{$name} \r\n" + $message[$msgcur])
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
#Copyright (C) 2014-2016 Dawid Pieper