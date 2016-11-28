#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_WhatsNew
  def initialize(init=false)
    @init = init
    end
  def main
           wntemp = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&get=1")
              err = wntemp[0]
messages = wntemp[1].to_i
posts = wntemp[2].to_i
blogposts = wntemp[3].to_i
                                                                                            if @init == true     and (posts > 0 or messages > 0)
header = "Co nowego"
else
  header=""
        end
    @sel = Select.new(["Nowe wiadomości (#{messages.to_s})","Nowe wpisy w śledzonych wątkach (#{posts.to_s})","Nowe wpisy na śledzonych blogach (#{blogposts.to_s})"],true,0,header,true)
    @sel.disable_item(0) if messages <= 0
    @sel.disable_item(1) if posts <= 0
    @sel.disable_item(2) if blogposts <= 0
    if posts <= 0 and messages <= 0 and blogposts <= 0
      speech("Nie ma nic nowego.")
      speech_wait
      $scene = Scene_Main.new
      return
    end
    @sel.focus
    loop do
      loop_update
      @sel.update
      if escape
                $scene = Scene_Main.new
      end
      if enter or Input.trigger?(Input::RIGHT)
        case @sel.index
        when 0
          $scene = Scene_WhatsNew_Messages.new
          when 1
            $scene = Scene_WhatsNew_Forum.new
            when 2
              $scene = Scene_WhatsNew_BlogPosts.new
        end
        end
      break if $scene != self
      end
  end
  end

class Scene_WhatsNew_Messages
  def main
            $msg = srvproc("messages_received","name=#{$name}\&token=#{$token}")
        case $msg[0].chop!.to_i
    when -1
      speech("Błąd połączenia się z bazą danych.")
      $scene = Scene_WhatsNew.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        $scene = Scene_Loading.new
        return
        when -3
          speech("Nieznany błąd.")
          $scene = Scene_WhatsNew.new
          return
        end
     $messages = $msg[1].to_i
     if $messages == 0
                 wterrt = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&messages=#{($messages.to_i).to_s}\&posts=-1\&set=1")
          wterr = wterrt[0].to_i
     if wterr < 0
       speech("Błąd")
       speech_wait
       $scene = Scene_WhatsNew.new
       end
       speech("Brak nowych wiadomości.")
       speech_wait
       $scene = Scene_WhatsNew.new
       return
       end
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
           $message[id] += $msg[l]
           $subject[id] = $msg[l]
         elsif t == 3
           $sender[id] = $msg[l]
         elsif t == 4
           $id[id] = $msg[l]
         end
         l += 1
       end
       l += 1
     end
     if $id.size == 0
       speech("Brak nowych wiadomości")
       speech_wait
       end
     $msgsel = []
     for i in 0..$message.size - 1
       $msgsel[i] = ""
       $msgsel[i] += $subject[i] + " OD: " + $sender[i]
     end
     if $messages == 0
       speech("Nie masz żadnych wiadomości.")
       speech_wait
     end
     $sel = Select.new($msgsel)
     speech_stop
     min = 0
     for i in 0..$read.size - 1
       if $read[i] > 0
         min += 1
         $sel.disable_item(i)
         end
       end
               wterrt = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&messages=#{min.to_s}\&posts=-1\&set=1")
          wterr = wterrt[0].to_i
     if wterr < 0
       speech("Błąd")
       speech_wait
       $scene = Scene_WhatsNew.new
     end
     if min == $messages
       speech("Brak nowych wiadomości")
       speech_wait
       $scene = Scene_WhatsNew.new
       return
       end
       $sel.focus
     loop do
loop_update
       $sel.update
       update
       if escape or Input.trigger?(Input::LEFT)
                  $scene = Scene_WhatsNew.new
         end
       if $scene != self
         break
         end
       end
     end
     def update
         $msgcur = $sel.index
         if enter
         msgtemp = srvproc("message_read","name=#{$name}\&token=#{$token}\&id=#{$id[$msgcur]}")
                           if msgtemp[0].to_i < 0
           speech("Błąd")
           speech_wait
           $scene = Scene_WhatsNew.new
           return
           end
         $read[$msgcur] = Time.now.to_i
         $msgsel[$msgcur] = $subject[$msgcur] + " OD: " + $sender[$msgcur]
         $sel.commandoptions = $msgsel  
         $inpt = Edit.new($message[$msgcur],"MULTILINE|READONLY")
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
           return
         break
         end
                end
              end
                            loop_update
main
return
 end
   end
def menu
play("menu_open")
play("menu_background")
@sel = SelectLR.new(["Odpowiedz","Usuń","Przekaż dalej","Oznacz wszystkie wiadomości jako przeczytane"])
loop do
loop_update
@sel.update
$msgcur = $sel.index
if enter
case @sel.index
when 0
  $scene = Scene_Messages_New.new($sender[$msgcur],"RE: " + $subject[$msgcur].sub("RE: ",""),"",self)
when 1
  $scene = Scene_Messages_Delete.new($id[$msgcur],self)
when 2
$scene = Scene_Messages_New.new("","FW: " + $subject[$msgcur],"Przekazana przez: #{$name} \r\n" + $message[$msgcur],self)
when 3
  msgtemp = srvproc("message_allread","name=#{$name}\&token=#{$token}")
    if msgtemp[0].to_i < 0
    speech("Błąd")
    speech_wait
    $scene = Scene_WhatsNew.new
    return 
    end
    speech("Wszystkie wiadomości zostały oznaczone jako przeczytane.")
speech_wait
$scene = Scene_WhatsNew.new
    when 4
$scene = Scene_WhatsNew.new
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

                                class Scene_WhatsNew_Forum
                                  def main
                                    ft = srvproc("forum_ft_news","name=#{$name}\&token=#{$token}\&get=1")
                                                                        err = ft[0].to_i
                                    case err
                                    when -1
                                      speech("Błąd połączenia się z bazą danych")
                                      speech_wait
                                      $scene = Scene_WhatsNew.new
                                      return
                                      when -2
                                        speech("Klucz sesji wygasł.")
                                        speech_wait
                                        $scene = Scene_Loading.new
                                        return
                                      end
                                      @threads = []
                                      for i in 0..ft.size - 1
                                        ft[i].delete!("\n")
                                      end
                                      l = 2
                                      @ft_forum = []
                                      @ft_thread = []
                                      @ft_posts = []
                                      for i in 0..ft[1].to_i - 1
                                        @ft_forum[i] = ft[l]
                                        l += 1
                                        @ft_thread[i] = ft[l]
                                        l += 1
                                      @ft_posts[i] = ft[l].to_i
                                      l += 1
                                        end
                                                                              @ft_newposts = []
                                         for i in 0..@ft_thread.size - 1
                        ftmp = srvproc("forum_read","name=#{$name}\&token=#{$token}\&forumname=#{@ft_forum[i]}\&threadid=#{@ft_thread[i]}")
            if ftmp[0].to_i == 0
        @ft_newposts[i] = ftmp[1].to_i
      end
    end  
                                        sel = []
    for i in 0..@ft_thread.size - 1
      if @ft_thread[i] != nil and @ft_posts[i] != nil and @ft_thread != ""
        selt = ""
                forumtemp = srvproc("forum_getthreadname","name=#{$name}\&token=#{$token}\&forumname=#{@ft_forum[i]}\&threadid=#{@ft_thread[i]}")
                        err = forumtemp[0].to_i
        if err != 0
          speech("Błąd.")
          speech_wait
          $scene = Scene_WhatsNew.new
          return
        end
                selt += forumtemp[1].to_s + " . Wpisy: " + @ft_posts[i].to_s
        sel.push(selt)
        end
      end 
            @sel = Select.new(sel,true,0,"",true)
      if sel.size < 1 or sel == [""]
        speech("Brak nowych wpisów w śledzonych wątkach")
speech_wait
$scene = Scene_WhatsNew.new
return
end
@sel.focus      
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
        if escape or Input.trigger?(Input::LEFT)
                    $scene = Scene_WhatsNew.new
        end
        if enter or Input.trigger?(Input::RIGHT)
                    $forumname = @ft_forum[@sel.index]
          $threadid = @ft_thread[@sel.index]
          $scene = Scene_Forum_Thread.new($threadid,true,0,@ft_newposts[@sel.index],$scene)
        end
        if alt
                    menu
          return
          end
        end
                    def menu
play("menu_open")
play("menu_background")
sel = ["otwórz","Usuń z listy śledzonych wątków","Anuluj"]
sel.push("Usuń Wątek") if $rang_moderator > 0
@menu = SelectLR.new(sel)
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
$forumname = @ft_forum[@sel.index]
          $threadid = @ft_thread[@sel.index]
          $scene = Scene_Forum_Thread.new($threadid,true,0,@ft_newposts[@sel.index],$scene)
when 1
          ftmp = srvproc("forum_ft","name=#{$name}\&token=#{$token}\&remove=1\&forum=#{@ft_forum[@sel.index]}\&thread=#{@ft_thread[@sel.index]}")
                    err = ftmp[0].to_i
          case err
          when 0
            speech("Usunięto z listy śledzonych wątków")
          when -1
            speech("Błąd połączenia się z bazą danych.")
            when -2
              speech("Klucz sesji wygasł.")
              $scene = Scene_Loading.new
          end
        speech_wait
when 2
  $scene = Scene_WhatsNew.new
when 3
$scene = Scene_Forum_Forum_Delete.new(@ft_forum[@sel.index], @ft_thread[@sel.index],true)
end
speech_wait
break
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
loop_update
main
          end
        end
        
        class Scene_WhatsNew_BlogPosts
          def main
            bt = srvproc("blog_fb_news","name=#{$name}\&token=#{$token}")
            if bt[0].to_i < 0
              speech("Błąd")
              speech_wait
              $scene = Scene_WhatsNew.new
              return
            end
            if bt[1].to_i == 0
              speech("Brak nowych wpisów na śledzonych blogach.")
              speech_wait
              $scene = Scene_WhatsNew.new
              return
              end
                         @blogauthor = []
           @blogcategory = []
           @blogpost = []
           @blogpostname = []
           t = 0
           id = 0
           for i in 2..bt.size-1
                          case t
             when 0
                              @blogauthor[id] = bt[i]
               when 1
                 @blogcategory[id] = bt[i]
                 when 2
                   @blogpost[id] = bt[i]
                   when 3
                     @blogpostname[id] = bt[i]
             end
             t+=1
            if t == 4
              t = 0
              id += 1
              end
             end
            sel = []
            for i in 0..@blogpostname.size-1
              sel.push(@blogpostname[i] + "\r\nAutor " + @blogauthor[i])
            end
            @sel = Select.new(sel)
            loop do
              loop_update
              @sel.update
              update
              break if $scene != self
              end
            end
            def update
              if escape or Input.trigger?(Input::LEFT)
                $scene = Scene_WhatsNew.new
              end
             if enter
               $scene = Scene_Blog_Other_Read.new(@blogcategory[@sel.index],@blogpost[@sel.index],@blogauthor[@sel.index],0,0,$scene)
               end
              end
          end
#Copyright (C) 2014-2016 Dawid Pieper