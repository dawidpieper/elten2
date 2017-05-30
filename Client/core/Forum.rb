#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Forum
  def initialize(index=0)
    @iindex = index
    end
 def main
   $forums = srvproc("forum_posts","token=" + $token + "&name=" + $name + "&cat=0\&details=2")
                      case $forums[0].to_i
when 0
for i in 0..$forums.size - 1
    $forums[i].delete!("\n")
    end
  $forumtime = Time.now.to_i
  forumlist = []
  forumid = 0
  @forums=[]
    t = 0
    for i in 1..$forums.size - 1
    case t
    when 0
    forumlist[forumid] = $forums[i]
    @forums[forumid]=Struct_Forum_Forum.new($forums[i])
        when 1
      @forums[forumid].fullname=$forums[i]
      when 2
      @forums[forumid].group=$forums[i]
      when 3
      @forums[forumid].threads=$forums[i].to_i
      when 4
    @forums[forumid].posts=$forums[i].to_i
    when 5
      @forums[forumid].type=$forums[i].to_i
        forumid += 1
  end
  t += 1
  t = 0 if t == 6
  end
                        groups = []
  sel = []
 seli=[]
  for i in 0..@forums.size-1
    if groups.include?(@forums[i].group)==false
      groups.push(@forums[i].group) 
      sel.push([])
      seli.push([])
      end
    end
        for i in 0..forumlist.size - 1
    if @forums[i] != nil
    sel[groups.find_index(@forums[i].group)].push(@forums[i].fullname + " . Wątki: " + @forums[i].threads.to_s + ", WPisy: " + @forums[i].posts.to_s)
    seli[groups.find_index(@forums[i].group)].push(i)
  end
    end
  forums = @forums.size
  indexa=0
  indexb=0
  @cat = 0
  if @iindex > 0
    indexa = groups.find_index(@forums[@iindex-1].group)+1
    indexb=seli[indexa-1].find_index(@iindex-1)
    @cat = 1
    end
                @commandforums = []
        for i in 0..groups.size-1
          @commandforums[i] = Select.new(sel[i],true,indexb,"Wybierz Forum",true)
        end
        grp = []
        for g in groups
          t = 0
          ps = 0
          f = 0
          for i in 0..@forums.size-1
            if @forums[i].group == g
              f += 1
              t += @forums[i].threads
              ps += @forums[i].posts
              end
            end
          grp.push(g + " . Fora: #{f.to_s}, Wątki: #{t.to_s}, Wpisy: #{ps.to_s}")
          end
        @commandcats = Select.new(["Śledzone wątki"]+grp,true,indexa,"Forum",true)
        if @cat == 0
          @commandcats.focus
        else
          @commandforums[@commandcats.index-1].focus
          end
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
          @sels = sel
          @seli = seli
                    loop do
            if $scene != self
              break
            end
loop_update
            if @cat == 0
              @commandcats.update
              catupdate
            else
              @commandforums[@commandcats.index-1].update
              forumupdate
              end
                          end
          end
          def catupdate
            if escape
              $scene = Scene_Main.new
              end
              if enter or Input.trigger?(Input::RIGHT)
                if @commandcats.index>0
                @cat = 1
                @commandforums[@commandcats.index-1].index=0
                @commandforums[@commandcats.index-1].focus
              else
                $scene = Scene_Forum_Forum.new("",0)
                end
                end
            end
          def forumupdate
            @index = @seli[@commandcats.index-1][@commandforums[@commandcats.index-1].index]
                        if escape or Input.trigger?(Input::LEFT)
              @cat=0
              @commandcats.focus
            end
            if alt
                            menu
                          end
                          if enter or Input.trigger?(Input::RIGHT)
                                        $scene = Scene_Forum_Forum.new(@forums[@index].name,@index+1,0,@forums[@index].type)
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
$scene = Scene_Forum_Forum.new(@forums[@index].name,@index+1)
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
                        def initialize(forum="",forumindex=0,threadidindex=0,forumtype=0)
                                        @forum = forum
              @forumindex = forumindex
              @threadidindex = threadidindex
              @forumtype=forumtype
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
                    @threads=[]
          for i in 0..forumtitles.size-1
            @threads[i]=Struct_Forum_Thread.new($forumid[i],forumtitles[i])
            end
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
        @threads[j].posts = poststemp[l] if ti == @threads[j].id.to_i
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
        @threads[j].readposts = poststemp[l] if ti == @threads[j].id.to_i
        end
        id = true
      end
      l += 1
      break if l >= poststemp.size
      i += 1
      end
    sel = []
    for i in 0..@threads.size - 1
      if @threads[i] != nil
        selt = ""
        selt += "Nowy: \004NEW\004" if @threads[i].posts.to_i > @threads[i].readposts.to_i
        selt += @threads[i].name.to_s + " . Wpisy: " + @threads[i].posts.to_s
                       sel.push(selt)
        end
      end
  @command = nil
    index = 0
  for i in 0..$forumid.size - 1
    index = i if @threads[i].id == @threadidindex
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
                                          $scene = Scene_Forum_Thread.new(@threads[@command.index].id,false,@forumindex,@threads[@command.index].readposts.to_i,0,@forumtype)
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
$scene = Scene_Forum_Thread.new(@threads[@command.index].id,false,@forumindex,@threads[@command.index].readposts.to_i,0,@forumtype)
when 1
  fttemp = srvproc("forum_ft","name=#{$name}\&token=#{$token}\&add=1\&forum=#{$forumname}\&thread=#{@threads[@command.index].id}")
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
          ftmp = srvproc("forum_ft","name=#{$name}\&token=#{$token}\&remove=1\&forum=#{$forumname}\&thread=#{@threads[@command.index].id}")
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
  $scene = Scene_Forum_Forum_New.new($forumname,@forumindex,@forumtype)
when 3
  $scene = Scene_Forum.new(@forumindex)
when 4
$scene = Scene_Forum_Forum_Delete.new($forumname, @threads[@command.index].id,0,@forumindex,@forumtype)
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
            def initialize(id="0",ft=false,forumindex=0,knownposts=-1,returner=0,forumtype=0)
              @id = id
              @ft = ft
              @forumindex = forumindex
              @knownposts = knownposts
              @returner = returner
              @forumtype=forumtype
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
  @posts=[]
    for i in 0..$posts - 1
        @posts[i] = Struct_Forum_Post.new
            t = 0
    l += 1
        loop do
            t += 1
                        if $forums[l] != "\004END\004\n" and $forums[l] != nil
        if t != 2 and t != 1
      @posts[i].post += $forums[l].to_s
    elsif t == 2
      @posts[i].author += $forums[l].to_s.maintext if $forums[l] != nil
      if $forums[l].to_s != nil
        if $forums[l].to_s.lore == ""
      @posts[i].authorname += $forums[l].to_s.maintext if $forums[l] != nil
    else
      @posts[i].authorname += $forums[l].to_s.lore if $forums[l] != nil
    end
    end
          elsif t == 1
                  @posts[i].id = $forums[l].to_i if $forums[l] != nil
                  end
          else
      break
      end
            l += 1
    end
    @posts[i].post += "\004LINE\004#{(i+1).to_s}/#{$posts.to_s}"
      end
  for i in 0..@posts.size - 1
    @posts[i].author.delete!("\n") if @posts[i] != nil
    end
    @fields = []
    @thr = []
    for i in 0..@posts.size - 1
            @fields[i] = Edit.new(@posts[i].authorname,"MULTILINE|READONLY",@posts[i].post,true)
          end
          if @posts[0]!=nil and @forumtype==0
          @posts[0].post.gsub("\004AUDIO\004") do
            @forumtype=2
            end
            end
          if @forumtype == 0
        @fields.push(Edit.new("Twoja odpowiedź","MULTILINE","",true))
    @fields.push(nil)
  else
    @fields.push(Button.new("Nagraj nowy wpis"))
    @fields.push(nil)
    @fields.push(nil)
    end
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
                    @form = Form.new(@fields)
            loop do
loop_update
if @forumtype == 0
      if @form.fields[@form.fields.size-3].text!=[[]]
  @form.fields[@form.fields.size-2]=Button.new("Dodaj wpis")
else
  @form.fields[@form.fields.size-2]=nil
end
  end
              @form.update
            $postcur = @form.index if @form.index < @form.fields.size - 1
              update
              if $scene != self
                break
                end
            end
          end
          def update
                        if escape or ((enter or space) and @form.index == @form.fields.size - 1)
                            if @returner == 0
                            @forumtype=0 if @forumtype==2
                              $scene = Scene_Forum_Forum.new($forumname,@forumindex,@id,@forumtype)
                      else
            $scene = @returner
            end
            end
            if alt
                            menu
            end
            if @forumtype == 0
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
elsif @forumtype >= 1
  @recording=0 if @recording==nil
  if (enter or space) and @form.index==@form.fields.size-4
        if @recording == 0 or @recording == 2
    @recording=1
    recording_start("temp/audiopost.wav")
    play("recording_start")
    @form.fields[@form.fields.size-4]=Button.new("Zakończ nagrywanie")
    @form.fields[@form.fields.size-3]=nil
  elsif @recording == 1
    recording_stop
    play("recording_stop")
    @form.fields[@form.fields.size-4]=Button.new("Nagraj ponownie")
    @form.fields[@form.fields.size-3]=Button.new("Odtwórz")
    @form.fields[@form.fields.size-2]=Button.new("Dodaj wpis")
    @recording = 2
    end
  end
  if (enter or space) and @form.index == @form.fields.size-3 and @recording == 2
    player("temp/audiopost.wav","",true)
  end
  if (enter or space) and @form.index == @form.fields.size-2
    if @recording == 1
      play("recording_stop")
      recording_stop
    end
    if @recording != 0
                    speech("Konwertowanie...")
      File.delete("temp/audiopost.mp3") if FileTest.exists?("temp/audiopost.mp3")
      h = run("bin\\ffmpeg.exe -y -i \"temp\\audiopost.wav\" -b:a 128K temp/audiopost.mp3",true)
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
      speech("Przygotowywanie do wysłania wpisu...")
        data = ""
            begin
            data = read("temp/audiopost.mp3").urlenc(true) if data == ""
          rescue Exception
            play("right")
            retry
          end
          data = "post="+data
  host = $url.sub("https://","")
  host.delete!("/")
  length = data.size
srvproc("forum","token=" + $token + "&name=" + $name + "&forum=2&forumname=" + $forumname + "&threadid=" + $threadid)
  q = "POST /forum_edit.php?name=#{$name}\&token=#{$token}\&forumname=#{$forumname.urlenc}\&threadid=#{$threadid}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
        ft = strbyline(sn)
if ft[0].to_i == 0
  speech("Wpis został utworzony.")
else
  speech("Błąd tworzenia wpisu.")
end
speech_wait
main
return
      end
    end
    end
              if $key[0x11] == true and $key[0x12] == false
if $key[0xBC] == true
  $postcur = 0
  @form.index = $postcur
  @form.fields[$postcur].focus
end
if $key[0xBE] == true
  $postcur = @posts.size - 1
@form.index = $postcur
@form.fields[$postcur].focus
  end
                if $key[0x55] == true and @knownposts <= @posts.size - 1 and @knownposts != -1
         $postcur = @knownposts
@form.index = $postcur
@form.fields[$postcur].focus         
end
if $key[0x4E] == true
  $postcur = @posts.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
end
if $key[0x46] == true
  text = "--Cytat (#{@posts[$postcur].authorname}:\r\n#{@posts[$postcur].post.delline(3).gsub(signature(@posts[$postcur].authorname),"")}\r\n) -- Koniec Cytatu"
    @form.fields[@form.fields.size - 3].settext(text)
  $postcur = @posts.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
  end
                  end
              end
            def menu
play("menu_open")
play("menu_background")
if $postcur >= @posts.size
  author = ""
  else
author = @posts[$postcur].authorname
end
sel = [author,"Nowy wpis","Odpowiedz z cytatem","Edytuj wpis", "Przejdź do ostatniego wpisu","Przejdź do pierwszego nowego wpisu","Anuluj","Usuń wpis"]
@menu = SelectLR.new(sel)
 if $postcur >= @posts.size
   @menu.disable_item(0)
   @menu.disable_item(2)
   @menu.disable_item(3)
   @menu.disable_item(7)
   @menu.disable_item(5) if @knownposts > @posts.size - 1 or @knownposts == -1
   else
@menu.disable_item(0) if $postcur >= @posts.size
@menu.disable_item(2) if $postcur >= @posts.size
@menu.disable_item(3) if (@posts[$postcur].authorname.delete("\r\n") != $name and $rang_moderator != 1) or $postcur >= @posts.size
@menu.disable_item(5) if @knownposts > @posts.size - 1 or @knownposts == -1
@menu.disable_item(7) if $postcur >= @posts.size or $rang_moderator <= 0
end
@menu.update
@menu.focus
loop do
loop_update
@menu.update
if enter or (Input.trigger?(Input::DOWN) and @menu.index == 0)
case @menu.index
when 0
  if usermenu(@posts[$postcur].author,true) != "ALT"
    if $scene == self
    @menu = SelectLR.new(sel)
  else
    break
    end
  else
    break
  end
when 1
  $postcur = @posts.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
when 2
  text = "--Cytat (#{@posts[$postcur].authorname}:\r\n#{@posts[$postcur].post.delline(3)}\r\n) -- Koniec Cytatu"
    @form.fields[@form.fields.size - 3].settext(text)
  $postcur = @posts.size - 1
@form.index = $postcur+1
@form.fields[$postcur+1].focus
when 3
 dialog_open
  fields = [Edit.new("Treść wpisu","MULTILINE",@posts[$postcur].post.delline(3).gsub(signature(@posts[$postcur].author),""),true),Button.new("Zapisz"),Button.new("Anuluj")]
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
     ef = srvproc("forum_mod","name=#{$name}\&token=#{$token}\&forumname=#{$forumname}\&threadid=#{@id}\&postid=#{@posts[$postcur].id}\&buffer=#{buf.to_s}\&edit=1}")
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
  $postcur = @posts.size - 1
@form.index = $postcur
@form.fields[$postcur].focus
when 5
  $postcur = @knownposts
@form.index = $postcur
@form.fields[$postcur].focus
when 6
  $scene = Scene_Forum_Forum.new($forumname,@forumindex,@id,@posttype)
when 7
@forumtype=0 if @forumtype==2
  $scene = Scene_Forum_Thread_Delete.new($forumname,@id,@posts[$postcur].id,@forumindex,@forumtype)
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
                        def initialize(forumname,forumindex=0,forumtype=0)
                          @forumname = forumname
                          @forumindex = forumindex
                                                @forumtype=forumtype
                                                end
                          def main
                                                                                    forumname = @forumname
                            forum = forumname
                            @fields = []
                            thread=""
                            text = ""
                            rectitlest=0
                            recpostst=0
                            if @forumtype == 0                            
                            @fields[0] = Edit.new("Tytuł wątku","","",true)
                                                         @fields[1] = Edit.new("Treść wpisu","MULTILINE","",true)
                                                         @fields[2] = nil
                                                         @fields[3] = Button.new("Anuluj")
                                                         @fields[4] = Edit.new("Pseudonim:","","",true) if $rang_moderator == 1 or $rang_developer == 1
                                                       else
                                                         @fields[0]=Button.new("Nagraj tytuł")
                                                         @fields[1]=nil
                                                         @fields[2]=Button.new("Nagraj wpis")
                                                         @fields[3]=nil
                                                         @fields[4]=nil
                                                         @fields[5]=Button.new("Anuluj")
                                                       end
                                                                                                               @form = Form.new(@fields)
                                                         loop do
                                                          loop_update
                                                          if @forumtype == 0
                                                          if @form.fields[0].text!=[[]] and @form.fields[1].text!=[[]]
                                                            @form.fields[2]=Button.new("Wyślij")
                                                          else
                                                            @form.fields[2]=nil
                                                          end
                                                          end
                                                          @form.update
                                                          if @forumtype == 0            
                                                          if ($key[0x11] == true or @form.index == 2) and enter
                                                                        play("list_select")
                                                                        @form.fields[0].finalize
                                                                        thread = @form.fields[0].text_str
                                                                        @form.fields[1].finalize
                                                                        text = @form.fields[1].text_str
                                                                        break
                                                                      end
                                                                    else
                                                                      if (enter or space) and @form.index == 0 and recpostst != 1
                                                                                                                                                if rectitlest == 0 or rectitlest == 2
                                                                          play("recording_start")
                                                                          recording_start("temp/audiothreadtitle.wav")
                                                                          @form.fields[0]=Button.new("Zatrzymaj nagrywanie tytułu")
                                                                          rectitlest=1
                                                                          @form.fields[1]=nil
                                                                        elsif rectitlest == 1
                                                                          recording_stop
                                                                            play("recording_stop")
                                                                            rectitlest=2
                                                                            @form.fields[0]=Button.new("Nagraj tytuł ponownie")
                                                                            @form.fields[1]=Button.new("Odtwórz tytuł")
end                                                                            
                                                                      end
                                                       if (enter or space) and @form.index == 1 and rectitlest == 2
                                                         player("temp/audiothreadtitle.wav","",true)
                                                       end
                                                       if (enter or space) and @form.index == 2
                                                       if recpostst == 0 or recpostst == 2
                                                                          play("recording_start")
                                                                          recording_start("temp/audiothreadpost.wav")
                                                                          @form.fields[0]=Button.new("Zatrzymaj nagrywanie wpisu")
                                                                          recpostst=1
                                                                          @form.fields[3]=nil
                                                                        elsif recpostst == 1
                                                                          recording_stop
                                                                            play("recording_stop")
                                                                            recpostst=2
                                                                            @form.fields[2]=Button.new("Nagraj wpis ponownie")
                                                                            @form.fields[3]=Button.new("Odtwórz wpis")
@fields[4]=Button.new("Wyślij")
                                                                            end                                                                            
                                                                      end
                                                       if (enter or space) and @form.index == 3 and recpostst == 2
                                                         player("temp/audiothreadpost.wav","",true)
                                                       end
                                                                      if (enter or space) and @form.index==4
                                                                        if recpostst==1 or rectitlest==1
                                                                          play("recording_stop")
                                                                        recording_stop
                                                                      end
                                                                      break
                                                                        end
                                                       end
                                                                      if escape or (((@form.index == 5 and @forumtype>=1) or (@form.index==3 and @forumtype==0)) and enter)
                                                                        recording_stop if @rectitlest==1 or @recpostst==1
                                                                        loop_update
                                                                        $scene = Scene_Forum_Forum.new($forumname,@forumindex,0,@forumtype)
                                                                        return
                                                                        break
                                                                        end
                              end
                              if @forumtype == 0                          
                              buf = buffer(text).to_s
addtourl = ""
                            addtourl = "\&uselore=1\&lore=#{@form.fields[4].text_str}" if @form.fields[4] != nil
                            ft = srvproc("forum_edit","name=" + $name + "&token=" + $token + "&forumname=" + forum + "&threadname=" + thread + "&buffer=" + buf + "\&threadid=" + ($threadmaxid + 1).to_s+addtourl)
                          else
                                          speech("Konwertowanie...")
      File.delete("temp/audiothreadtitle.mp3") if FileTest.exists?("temp/audiothreadtitle.mp3")
      h = run("bin\\ffmpeg.exe -y -i \"temp\\audiothreadtitle.wav\" -b:a 128K temp/audiothreadtitle.mp3",true)
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
      File.delete("temp/audiothreadpost.mp3") if FileTest.exists?("temp/audiothreadpost.mp3")
      h = run("bin\\ffmpeg.exe -y -i \"temp\\audiothreadpost.wav\" -b:a 128K temp/audiothreadpost.mp3",true)
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
            data = "post="+read("temp/audiothreadpost.mp3").urlenc(true) + "\&threadname="+read("temp/audiothreadtitle.mp3").urlenc(true) if data == ""
          rescue Exception
            retry
          end
  host = $url.sub("https://","")
  host.delete!("/")
  length = data.size
  q = "POST /forum_edit.php?name=#{$name}\&token=#{$token}\&forumname=#{forum.urlenc}\&threadid=#{($threadmaxid+1).to_s}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
ft = bt[1].to_i
end
$threadmaxid += 1
if ft[0].to_i == 0
  speech("Wątek został utworzony.")
else
  speech("Błąd tworzenia wątku!")
end
speech_wait
$scene = Scene_Forum_Forum.new(forum,@forumindex,0,@forumtype)
                          end
                        end
                        
                        
                        class Scene_Forum_Forum_Delete
                          def initialize(forumname,threadid,ft=false,forumindex=0,forumtype=0)
                            @forumname = forumname
                            @threadid = threadid
                            @ft = ft
                            @forumindex = forumindex
                            @forumtype=forumtype
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
                                  $scene = Scene_Forum_Forum.new(forumname,@forumindex,0,@forumtype)
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
                                                                        $scene = Scene_Forum_Forum.new(forumname,@forumindex,0,@forumtype)
                                                                                                        end
                                end
                                
                                class Scene_Forum_Thread_Delete
                          def initialize(forumname,threadid,postid,ft=false,forumindex=0,forumtype=0)
                            @forumname = forumname
                            @threadid = threadid
                            @postid = postid
                            @ft = ft
                            @forumindex = forumindex
                            @forumtype=forumtype
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
                                  $scene = Scene_Forum_Thread.new(threadid,false,@forumindex,@forumtype)
                                else
                                  $scene = Scene_Forum_Thread.new(threadid,@ft,@forumindex,@forumtype)
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
                                    $scene = Scene_Forum_Thread.new(threadid,false,@forumindex,@forumtype)
                                  else
                                    $scene = Scene_Forum_Thread.new(threadid,true,@forumindex,@forumtype)
                                    end
                                  end
                                end
                                
                                
                                class Struct_Forum_Forum
                                  attr_accessor :name
                                  attr_accessor :group
                                  attr_accessor :fullname
                                  attr_accessor :threads
                                  attr_accessor :posts
                                  attr_accessor :type
                                  def initialize(name="")
                                    @name=name
                                    @group=0
                                    @fullname=""
                                    @posts=0
                                    @threads=0
                                    @type=0
                                    end
                                  end
                                  
                                  class Struct_Forum_Thread
                                    attr_accessor :id
                                    attr_accessor :name
                                    attr_accessor :posts
                                    attr_accessor :readposts
                                    def initialize(id=0,name="")
                                      @id=id
                                      @name=name
                                      @posts=0
                                      @readposts=0
                                    end\
                                  end
                                  
                                  class Struct_Forum_Post
                                    attr_accessor :id
                                    attr_accessor :author
                                    attr_accessor :post
                                    attr_accessor :authorname
                                    def initialize(id=0)
                                      @id=id
                                      @author=""
                                      @post=""
                                      @authorname=""
                                    end
                                    end
#Copyright (C) 2014-2016 Dawid Pieper