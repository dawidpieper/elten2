#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Forum
  def initialize(index=0)
    @index = index
    end
 def main
      $forums = srvproc("forum_posts","token=" + $token + "&name=" + $name + "&cat=0")
                case $forums[0].to_i
when 0
for i in 0..$forums.size - 1
    $forums[i].delete!("\n")
    end
  $forumtime = Time.now.to_i
  forumlist = []
  forumid = 0
  $forumthreads = []
  $forumposts = []
  t = 0
  for i in 1..$forums.size - 1
    case t
    when 0
    forumlist[forumid] = $forums[i]
    when 1
      $forumthreads[forumid] = $forums[i].to_i
      when 2
    $forumposts[forumid] = $forums[i].to_i
        forumid += 1
  end
  t += 1  
  t = 0 if t == 3
  end
         @command = nil
  $forumnames = forumlist
          sel = []
    sel.push("Śledzone wątki")
  for i in 0..forumlist.size - 1
    if $forumnames[i] != nil and $forumthreads[i] != nil
    sel.push($forumnames[i] + " . Wątki: " + $forumthreads[i].to_s + ", WPisy: " + $forumposts[i].to_s)
    end
  end
  @forums = sel.size - 1
      @command = Select.new(sel,true,@index,"Wybierz forum")
  when -1
    speech("Błąd połączenia z bazą danych.")
    when -2
      speech("Wartość tokenu wygasła. Zaloguj się ponownie")
      loop_update
      $scene = Scene_Loading.new
      return
      when -3
        speech("Błąd odczytu rekordów.")
        when -4
          speech("Nie odnaleziono listy forów.")
          when -5
            speech("Wystąpił błąd podczas próby połączenia z serwerem.")
          end
          if $forums[0].to_i < 0 and $scene == self
            $scene = Scene_Main.new
          end
          loop do
            if $scene != self
              break
            end
loop_update
            if @command != nil
              @command.update
              update
              end
            end
          end
          def update
            if escape
              $scene = Scene_Main.new
            end
            if alt
                            menu
              end
            if enter or Input.trigger?(Input::RIGHT)
              if @command.index > 0
              $scene = Scene_Forum_Forum.new($forumnames[@command.index - 1],@command.index)
            else
              $scene=Scene_Forum_Forum.new("")#$scene = Scene_Forum_FT.new tutaj
              end
              end
            end
            def menu
play("menu_open")
play("menu_background")
@menu = SelectLR.new(["otwórz","Anuluj"])
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
$scene = Scene_Forum_Forum.new($forumnames[@command.index - 1],@command.index)
when 1
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
loop_update
end
          end
          
          class Scene_Forum_Forum
            def initialize(forum="",forumindex=0,threadidindex=0)
              @forum = forum
              @forumindex = forumindex
              @threadidindex = threadidindex
              end
  def main
   $forums = srvproc("forum","token=" + $token + "&name=" + $name + "&forum=1&forumname=" + @forum.to_s)
   $forumname = @forum
   case $forums[0].to_i
when 0
  forumlist = []
  forumid = 0
  for i in 0..$forums.size - 1
    $forums[i].delete!("\n")
  end
  i = 2
  forumtitles = []
  $forumid = []
  $threadmaxid = 0
  loop do
      forumlist[forumid] = $forums[i]
      $forumid[forumid] = $forums[i].to_s
      $threadmaxid = $forumid[forumid].to_i if $forumid[forumid].to_i > $threadmaxid
      i += 1
      forumtitles[forumid] = $forums[i]
    forumid += 1
    break if i >= ($forums[1].to_i) * 2
    i += 1
  end
          $threadnames = forumtitles
    $threadposts = []
    $threadnewposts = []
    poststemp = srvproc("forum_posts","name=#{$name}\&token=#{$token}\&cat=1\&forumname=#{@forum}")
        l = 1
    id = true
    ti = 0
    tt = ""
    i = 0
    loop do
      if id == true
        ti = poststemp[l].to_i
        id = false
      else
        for j in 0..$forumid.size - 1
        $threadposts[j] = poststemp[l] if ti == $forumid[j].to_i
        end
        id = true
      end
      l += 1
      break if l >= poststemp.size
      i += 1
    end
        poststemp = srvproc("forum_posts","name=#{$name}\&token=#{$token}\&cat=2\&forumname=#{@forum}")
        l = 1
    id = true
    ti = 0
    tt = ""
    i = 0
    loop do
      if id == true
        ti = poststemp[l].to_i
        id = false
      else
        for j in 0..$forumid.size - 1
        $threadnewposts[j] = poststemp[l] if ti == $forumid[j].to_i
        end
        id = true
      end
      l += 1
      break if l >= poststemp.size
      i += 1
      end
    sel = []
    for i in 0..$threadnames.size - 1
      if $threadnames[i] != nil and $threadposts[i] != nil
        selt = ""
        selt += "Nowy: \004NEW\004" if $threadposts[i].to_i > $threadnewposts[i].to_i
        selt += $threadnames[i].to_s + " . Wpisy: " + $threadposts[i].to_s
                       sel.push(selt)
        end
      end
  @command = nil
    index = 0
  for i in 0..$forumid.size - 1
    index = i if $forumid[i] == @threadidindex
    end
  @command = Select.new(sel,true,index,"Wybierz temat")
  when -1
    speech("Błąd połączenia z bazą danych.")
    when -2
      speech("Wartość tokenu wygasła. Zaloguj się ponownie")
      loop_update
      $scene = Scene_Loading.new
      when -3
        speech("Błąd odczytu rekordów.")
        when -4
          speech("Nie odnaleziono listy tematów.")
          when -5
            speech("Wystąpił błąd podczas próby połączenia z serwerem.")
          end
          if $forums[0].to_i < 0 and $scene != self
            $scene = Scene_Forum.new
          end
          if $forums[1].to_i == 0
            speech("Pusta lista...")
                        end
          loop do
            if $scene != self
              break
            end
loop_update
            if @command != nil
              @command.update
              update
            else
            if escape or Input.trigger?(Input::LEFT)
              $scene = Scene_Forum.new
              end
            end
            end
          end
          def update
            if alt
                            menu
              end
            if escape or Input.trigger?(Input::LEFT)
              $scene = Scene_Forum.new(@forumindex)
            end
            if enter or Input.trigger?(Input::RIGHT)
                                          $scene = Scene_Forum_Thread.new($forumid[@command.index],false,@forumindex,$threadnewposts[@command.index].to_i)
              end
            end
            def menu
play("menu_open")
play("menu_background")
sel = ["otwórz","Zmień śledzenie wątku","Nowy temat","Anuluj"]
sel.push("Usuń Wątek") if $rang_moderator > 0
@menu = SelectLR.new(sel)
@menu.disable_item(2) if @forum == ""
loop do
loop_update
@menu.update
if enter
case @menu.index
when 0
$scene = Scene_Forum_Thread.new($forumid[@command.index])
when 1
  fttemp = srvproc("forum_ft","name=#{$name}\&token=#{$token}\&add=1\&forum=#{$forumname}\&thread=#{$forumid[@command.index]}")
      err = fttemp[0].to_i
  case err
  when 0
    speech("Dodano do śledzonych wątków.")
    when -1
      speech("Błąd połączenia się z bazą danych")
      when -2
        speech("Klucz sesji wygasł.")
        $scene = Scene_Loading.new
        when -3
          ftmp = srvproc("forum_ft","name=#{$name}\&token=#{$token}\&remove=1\&forum=#{$forumname}\&thread=#{$forumid[@command.index]}")
                    err = ftmp[0].to_i
          case err
          when 0
            speech("Usunięto z listy śledzonych wątków")
@command.disable_item(@command.index) if @forum == ""
          when -1
            speech("Błąd połączenia się z bazą danych.")
            when -2
              speech("Klucz sesji wygasł.")
              $scene = Scene_Loading.new
          end
        end
        speech_wait
when 2
  $scene = Scene_Forum_Forum_New.new($forumname,@forumindex)
when 3
  $scene = Scene_Forum.new(@forumindex)
when 4
$scene = Scene_Forum_Forum_Delete.new($forumname, $forumid[@command.index])
end
break
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
loop_update
end
          end
          
          class Scene_Forum_Thread
            def initialize(id="0",ft=false,forumindex=0,knownposts=-1,returner=0)
              @id = id
              @ft = ft
              @forumindex = forumindex
              @knownposts = knownposts
              @returner = returner
              end
  def main
    id = @id
    $threadid = id.to_s
   $forums = srvproc("forum","token=" + $token + "&name=" + $name + "&forum=2&forumname=" + $forumname + "&threadid=" + $threadid)
   case $forums[0].to_i
when 0
  $posts = $forums[1].to_i
  $post = []
  $postcur = 0
  l = 1
  $postauthor = []
  $postid = []
  $postauthorname = []
  for i in 0..$posts - 1
        $post[i] = ""
    $postauthor[i] = ""
    $postauthorname[i] = ""
        t = 0
    l += 1
        loop do
            t += 1
                        if $forums[l] != "\004END\004\n" and $forums[l] != nil
        if t != 2 and t != 1
      $post[i] += $forums[l].to_s
    elsif t == 2
      $postauthor[i] += $forums[l].to_s.maintext if $forums[l] != nil
      if $forums[l].to_s != nil
        if $forums[l].to_s.lore == ""
      $postauthorname[i] += $forums[l].to_s.maintext if $forums[l] != nil
    else
      $postauthorname[i] += $forums[l].to_s.lore if $forums[l] != nil
    end
    end
          elsif t == 1
                  $postid[i] = $forums[l].to_i if $forums[l] != nil
                  end
          else
      break
      end
            l += 1
    end
    $post[i] += "\004LINE\004#{(i+1).to_s}/#{$posts.to_s}"
      end
  for i in 0..$postauthor.size - 1
    $postauthor[i].delete!("\n") if $postauthor[i] != nil
    end
    @fields = []
    @thr = []
    for i in 0..$post.size - 1
            @fields[i] = Edit.new($postauthorname[i],"MULTILINE|READONLY",$post[i],true)
    end
        @fields.push(Edit.new("Twoja odpowiedź","MULTILINE","",true))
    @fields.push(Button.new("Dodaj wpis"))
    @fields.push(Button.new("Powrót"))
            when -1
    speech("Błąd połączenia z bazą danych.")
    when -2
      speech("Wartość tokenu wygasła. Zaloguj się ponownie")
      speech_wait
      $scene = Scene_Loading.new
      return
      when -3
        speech("Błąd odczytu rekordów.")
        when -4
          speech("Nie odnaleziono listy wpisów.")
          when -5
            speech("Wystąpił błąd podczas próby połączenia z serwerem.")
          end
          if $forums[0].to_i < 0 and $scene == self
            $scene = Scene_Forum.new
          end
          if $forums[1].to_i == 0
            speech("Pusta lista...")
                        end
          @form = Form.new(@fields)
            loop do
            @form.update
            $postcur = @form.index if @form.index < @form.fields.size - 1
loop_update
              update
              if $scene != self
                break
                end
            end
          end
          def update
                        if escape or ((enter or space) and @form.index == @form.fields.size - 1)
                            if @returner == 0
              if @ft == false
              $scene = Scene_Forum_Forum.new($forumname,@forumindex,@id)
            else
              $scene = Scene_Forum_FT.new
            end
          else
            $scene = @returner
            end
            end
            if alt
                            menu
            end
            if ((enter or space) and @form.index == @form.fields.size - 2) or ($key[0x11] == true and enter and @form.index == @form.fields.size - 3)
              @form.fields[@form.fields.size - 3].finalize
text = @form.fields[@form.fields.size - 3].text_str
              buf = buffer(text).to_s
ft = srvproc("forum_edit","name=" + $name + "&token=" + $token + "&forumname=" + $forumname + "&threadid=" + $threadid + "&buffer=" + buf)
srvproc("forum","token=" + $token + "&name=" + $name + "&forum=2&forumname=" + $forumname + "&threadid=" + $threadid)
if ft[0].to_i == 0
  speech("Wpis został utworzony.")
else
  speech("Błąd tworzenia wpisu.")
end
speech_wait
main
return
              end
              if $key[0x11] == true and $key[0x12] == false
if $key[0xBC] == true
  $postcur = 0
  @form.index = $postcur
  @form.fields[$postcur].focus
end
if $key[0xBE] == true
  $postcur = $post.size - 1
@form.index = $postcur
@form.fields[$postcur].focus
  end
                if $key[0x55] == true and @knownposts <= $post.size - 1 and @knownposts != -1
         $postcur = @knownposts
@form.index = $postcur
@form.fields[$postcur].focus         
end
if $key[0x4E] == true
  $postcur = $post.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
end
if $key[0x46] == true
  text = "--Cytat (#{$postauthorname[$postcur]}:\r\n#{$post[$postcur].delline(3).gsub(signature($postauthorname[$postcur]),"")}\r\n) -- Koniec Cytatu"
    @form.fields[@form.fields.size - 3].settext(text)
  $postcur = $post.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
  end
                  end
              end
            def menu
play("menu_open")
play("menu_background")
if $postcur >= $post.size
  author = ""
  else
author = $postauthorname[$postcur]
end
sel = [author,"Nowy wpis","Odpowiedz z cytatem","Edytuj wpis", "Przejdź do ostatniego wpisu","Przejdź do pierwszego nowego wpisu","Anuluj","Usuń wpis"]
@menu = SelectLR.new(sel)
@menu.disable_item(0) if $postcur >= $post.size
@menu.disable_item(2) if $postcur >= $post.size
@menu.disable_item(3) if ($postauthorname[$postcur].delete("\r\n") != $name and $rang_moderator != 1) or $postcur >= $post.size
@menu.disable_item(5) if @knownposts > $post.size - 1 or @knownposts == -1
@menu.disable_item(7) if $postcur >= $post.size or $rang_moderator <= 0
@menu.update
@menu.focus
loop do
loop_update
@menu.update
if enter or (Input.trigger?(Input::DOWN) and @menu.index == 0)
case @menu.index
when 0
  if usermenu($postauthor[$postcur],true) != "ALT"
    if $scene == self
    @menu = SelectLR.new(sel)
  else
    break
    end
  else
    break
  end
when 1
  $postcur = $post.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
when 2
  text = "--Cytat (#{$postauthor[$postcur]}:\r\n#{$post[$postcur].delline(3)}\r\n) -- Koniec Cytatu"
    @form.fields[@form.fields.size - 3].settext(text)
  $postcur = $post.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
when 3
 dialog_open
  fields = [Edit.new("Treść wpisu","MULTILINE",$post[$postcur].delline(3).gsub(signature($postauthorname[$postcur]),""),true),Button.new("Zapisz"),Button.new("Anuluj")]
 form = Form.new(fields)
 loop do
   loop_update
   form.update
   if escape or (enter and form.index == 2)
     @form.fields[@form.index].focus
     dialog_close
     break
   end
   if (enter and $key[0x11]) or ((enter or space) and form.index == 1)
     form.fields[0].finalize
     post = form.fields[0].text_str
     buf = buffer(post)
     ef = srvproc("forum_mod","name=#{$name}\&token=#{$token}\&forumname=#{$forumname}\&threadid=#{@id}\&postid=#{$postid[$postcur]}\&buffer=#{buf.to_s}\&edit=1}")
     if ef[0].to_i < 0
       speech("Błąd")
     else
       speech("Zapisano")
     end
     speech_wait
     dialog_close
     main
     return
     break
     end
   end
when 4
  $postcur = $post.size - 1
@form.index = $postcur
@form.fields[$postcur].focus
when 5
  $postcur = @knownposts
@form.index = $postcur
@form.fields[$postcur].focus
when 6
  $scene = Scene_Forum_Forum.new($forumname,@forumindex,@id)
when 7
  $scene = Scene_Forum_Thread_Delete.new($forumname,@id,$postid[$postcur],@forumindex)
end
break if @menu.index != 0
end
if alt or escape
break
end
end
Audio.bgs_stop
play("menu_close")
loop_update
end
          end
          
                                
                      class Scene_Forum_Forum_New
                        def initialize(forumname,forumindex=0)
                          @forumname = forumname
                          @forumindex = forumindex
                          end
                          def main
                            forumname = @forumname
                            forum = forumname
                            @fields = []
                            thread=""
                            text = ""
                            @fields[0] = Edit.new("Tytuł wątku","","",true)
                                                         @fields[1] = Edit.new("Treść wpisu","MULTILINE","",true)
                                                         @fields[2] = Button.new("Wyślij")
                                                         @fields[3] = Button.new("Anuluj")
                                                         @fields[4] = Edit.new("Pseudonim:","","",true) if $rang_moderator == 1 or $rang_developer == 1
                                                        @form = Form.new(@fields)
                                                         loop do
                              @form.update
                                                          loop_update
                                                                      if ($key[0x11] == true or @form.index == 2) and enter
                                                                        play("list_select")
                                                                        @form.fields[0].finalize
                                                                        thread = @form.fields[0].text_str
                                                                        @form.fields[1].finalize
                                                                        text = @form.fields[1].text_str
                                                                        break
                                                                      end
                                                                      if escape or (@form.index == 3 and enter)
                                                                                                                                                loop_update
                                                                        $scene = Scene_Forum_Forum.new($forumname)
                                                                        return
                                                                        break
                                                                        end
                              end
                                                        buf = buffer(text).to_s
addtourl = ""
                            addtourl = "\&uselore=1\&lore=#{@form.fields[4].text_str}" if @form.fields[4] != nil
                            ft = srvproc("forum_edit","name=" + $name + "&token=" + $token + "&forumname=" + forum + "&threadname=" + thread + "&buffer=" + buf + "\&threadid=" + ($threadmaxid + 1).to_s+addtourl)
$threadmaxid += 1
if ft[0].to_i == 0
  speech("Wątek został utworzony.")
else
  speech("Błąd tworzenia wątku!")
end
speech_wait
$scene = Scene_Forum_Forum.new(forum,@forumindex)
                          end
                        end
                        
                        
                        class Scene_Forum_Forum_Delete
                          def initialize(forumname,threadid,ft=false,forumindex=0)
                            @forumname = forumname
                            @threadid = threadid
                            @ft = ft
                            @forumindex = forumindex
                            end
                          def main
                            forumname = @forumname
                            threadid = @threadid
                            speech("Czy jesteś pewien, że chcesz usunąć wątek?")
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
                                  $scene = Scene_Forum_Forum.new(forumname,@forumindex)
                                  when 1
                                    delete
                                end
                                end
                              end
                            end
                            def delete
                              forumname = @forumname
                              threadid = @threadid
                              forumtemp = srvproc("forum_mod","name=#{$name}\&token=#{$token}\&forumname=#{forumname}\&threadid=#{threadid}\&delete=1")
                                                            ft = forumtemp[0].to_i
                              case ft
                              when 0
                                speech("Wątek został usunięty.")
                                when -1
                                  speech("Błąd połączenia się z bazą danych.")
                                  when -2
                                    speech("Klucz sesji wygasł.")
                                    when -3
                                      speech("Nie masz odpowiednich uprawnień, by wykonać tę operację.")
                                    end
                                    speech_wait
                                    if @ft == false
                                    $scene = Scene_Forum_Forum.new(forumname,@forumindex)
                                  else
                                    $scene = Scene_Forum_FT.new
                                    end
                                  end
                                end
                                
                                class Scene_Forum_Thread_Delete
                          def initialize(forumname,threadid,postid,ft=false,forumindex=0)
                            @forumname = forumname
                            @threadid = threadid
                            @postid = postid
                            @ft = ft
                            @forumindex = forumindex
                            end
                          def main
                            forumname = @forumname
                            threadid = @threadid
                            postid = @postid
                            speech("Czy jesteś pewien, że chcesz usunąć wpis #{postid} z wątku #{threadid}?")
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
                                  if @ft == false
                                  $scene = Scene_Forum_Thread.new(threadid,false,@forumindex)
                                else
                                  $scene = Scene_Forum_Thread.new(threadid,@ft,@forumindex)
                                  end
                                  when 1
                                    delete
                                end
                                end
                              end
                            end
                            def delete
                              forumname = @forumname
                              threadid = @threadid
                              postid = @postid
                              forumtemp = srvproc("forum_mod","name=#{$name}\&token=#{$token}\&forumname=#{forumname}\&threadid=#{threadid}\&postid=#{postid}\&delete=2")
                              ft = forumtemp[0].to_i
                              case ft
                              when 0
                                speech("Wpis został usunięty.")
                                when -1
                                  speech("Błąd połączenia się z bazą danych.")
                                  when -2
                                    speech("Klucz sesji wygasł.")
                                    when -3
                                      speech("Nie masz odpowiednich uprawnień, by wykonać tę operację.")
                                    end
                                    speech_wait
                                    if @ft == false
                                    $scene = Scene_Forum_Thread.new(threadid,false,@forumindex)
                                  else
                                    $scene = Scene_Forum_Thread.new(threadid,true,@forumindex)
                                    end
                                  end
                                end
#Copyright (C) 2014-2016 Dawid Pieper