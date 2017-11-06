#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Blog
  def initialize(index=0)
    @index=index
    end
  def main
    @sel = Select.new(["Mój blog","Ostatnio aktualizowane blogi","Najczęściej aktualizowane blogi","Najczęściej komentowane blogi","Śledzone blogi"],true,@index,"Blogi",true)
  if $name=="guest"
    @sel.disable_item(0)
    @sel.index=1
    @sel.disable_item(4)
    end
    @sel.focus
    loop do
    loop_update
    @sel.update
    update
    break if $scene != self
    end
  end
  def update
    if escape
            $scene = Scene_Main.new
    end
    if enter or Input.trigger?(Input::RIGHT)
     case @sel.index
     when 0
      $scene = Scene_Blog_Main.new
      when 1
        $bloglistindex=0        
        $scene = Scene_Blog_List.new
        when 2
        $bloglistindex=0        
        $scene = Scene_Blog_List.new(1)
        when 3
        $bloglistindex=0        
        $scene = Scene_Blog_List.new(2)
        when 4
          $bloglistindex=0
        $scene = Scene_Blog_List.new(3)
   end
   end
    end
end

class Scene_Blog_Main
  def initialize(owner=$name,categoryselindex=0,scene=nil)
    @owner=owner
    @categoryselindex = categoryselindex
    @postselindex = 0
    $blogreturnscene=scene
    end
  def main
    blogtemp = srvproc("blog_exist","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
exist = blogtemp[1].to_i
if exist == 0
  if @owner==$name
    $scene = Scene_Blog_Create.new
  else
    speech("Blog nie istnieje.")
    $scene=$blogreturnscene
    $scene=Scene_Blog.new if $scene==nil
    end
  return
end
blogtemp = srvproc("blog_name","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
    if $blogreturnscene == nil
    $scene = Scene_Main.new
  else
    $scene = $blogreturnscene
    $blogreturnscene = nil
    end
end
blogname = blogtemp[1]
blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
  end
@postid = []
@postname = []
@postmaxid = 0
for i in 0..lines - 1
  @postid[i] = blogtemp[l]
  @postmaxid = @postid[i].to_i if @postid[i].to_i > @postmaxid
  l += 1
  @postname[i] = blogtemp[l]
  l += 1
end
@postid = [0]+@postid
@postname = ["Wszystkie wpisy"]+@postname
sel = @postname+[]
sel.push("Nowa kategoria") if $name==@owner
sel.push("Zmień nazwę bloga") if @owner==$name
sel.push("Rekategoryzacja") if @owner==$name
@sel = Select.new(sel,true,@categoryselindex,blogname)
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape or Input.trigger?(Input::LEFT)
    $scene=$blogreturnscene    
    $scene = Scene_Blog.new if $scene==nil
  end
  if enter or Input.trigger?(Input::RIGHT)
    if @sel.index < @postname.size
      $scene = Scene_Blog_Posts.new(@owner,@postid[@sel.index],@sel.index)
    elsif @sel.index == @postname.size + 1
$scene = Scene_Blog_Rename.new
elsif @sel.index == @postname.size + 2
$scene = Scene_Blog_Recategorize.new(@scene)
            else
                  $scene = Scene_Blog_Category_New.new(@postmaxid + 1)
                end
              end
              $scene = Scene_Blog_Category_Delete.new(@postid[@sel.index]) if $key[0x2e] and @sel.index < @postid.size and @sel.index != 0
  if alt
        menu
    end
  end
  def menu
    play("menu_open")
    @menu = menulr(["Wybierz","Zmień nazwę","Usuń"])
    @menu.disable_item(1) if @sel.index > @postid.size - 1 or @sel.index == 0 or @owner!=$name
    @menu.disable_item(2) if @sel.index > @postid.size - 1 or @sel.index == 0 or @owner!=$name
    loop do
      loop_update
      @menu.update
      if alt or escape
        break
      end
      if enter
        case @menu.index
        when 0
          if @sel.index < @postname.size - 2
      $scene = Scene_Blog_Posts.new(@postid[@sel.index],@sel.index)
    elsif @sel.index == @postname.size - 1
$scene = Scene_Blog_Rename.new
            else
            $scene = Scene_Blog_Category_New.new(@postmaxid + 1)
      end
    when 1
      $scene = Scene_Blog_Category_Rename.new(@postid[@sel.index],@sel.index)
      when 2
$scene = Scene_Blog_Category_Delete.new(@postid[@sel.index])      
    end
    break
        end
      end
    Audio.bgs_stop
    play("menu_close")
            end
end

class Scene_Blog_Create
  def main
    speech("Nie posiadasz bloga. Czy chcesz go założyć?")
    speech_wait
if simplequestion == 0
  $scene = Scene_Main.new
  return
end
name = input_text("Podaj nazwę tworzonego bloga.","ACCEPTESCAPE")
if name == "\004ESCAPE\004" or name == "\004TAB\004"
    $scene = Scene_Main.new
  return
end
speech("Proszę czekać...")
speech_wait
blogtemp = srvproc("blog_create","name=#{$name}\&token=#{$token}\&blogname=#{name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd")
  speech_wait
  $scene = Scene_Main.new
  return
end
speech("Blog został utworzony.")
speech_wait
$scene = Scene_Main.new
  end
end

class Scene_Blog_Category_New
  def initialize(id=0)
    @id = id
    end
  def main
    name = ""
        while name == ""
      name = input_text("Nazwa kategorii","ACCEPTESCAPE")
    end
    if name == "\004ESCAPE\004" or name == "\004TAB\004"
            $scene = Scene_Blog_Main.new
      return
    end
blogtemp = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&add=1\&categoryid=#{@id.to_s}\&categoryname=#{name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
else
  speech("Kategoria została utworzona.")
end
speech_wait
$scene = Scene_Blog_Main.new
  end
end

class Scene_Blog_Category_Rename
  def initialize(categoryid,categoryselindex)
    @categoryid=categoryid
    @categoryselindex=categoryselindex
  end
  def main
    name=""
    while name==""
    name=input_text("Podaj nową nazwę dla tej kategorii","ACCEPTESCAPE")
  end
  if name != "\004ESCAPE\004"
    bt = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&rename=1\&categoryid=#{@categoryid.to_s}\&categoryname=#{name}")
    if bt[0].to_i < 0
      speech("Błąd")
    else
      speech("Nazwa została zmieniona.")
    end
    speech_wait
  end
  $scene = Scene_Blog_Main.new(@categoryselindex)
    end
  end

class Scene_Blog_Category_Delete
  def initialize(id)
    @id = id
  end
  def main
        if simplequestion("Czy jesteś pewien, że chcesz usunąć tą kategorię?") == 0
      $scene = Scene_Blog_Main.new
    else
      bt = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@id}\&del=1")
            if bt[0].to_i < 0
        speech("Błąd")
        speech_wait
        $scene = Scene_Blog_Main.new
        return
      end
      speech("Usunięto.")
      speech_wait
      $scene = Scene_Blog_Main.new
      end
    end
  end

class Scene_Blog_Posts
  def initialize(owner,id,categoryselindex=0,postselindex=0)
    @owner=owner
    @id = id
    @categoryselindex = categoryselindex
    @postselindex = postselindex
    end
  def main
id = @id
blogtemp = srvproc("blog_posts","name=#{$name}\&token=#{$token}\&searchname=#{@owner}\&categoryid=#{id}\&assignnew=1")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
l = 2
@postname = []
@postid = []
@postmaxid = 0
@postnew=[]
for i in 0..lines - 1
  @postid[i] = blogtemp[l].to_i
  @postmaxid = blogtemp[l].to_i if blogtemp[l].to_i > @postmaxid
  l += 1
  @postname[i] = blogtemp[l]
  l += 1
    @postnew[i] = blogtemp[l].to_i
  if @postnew[i]>0
    @postname[i]+="\004NEW\004"
    end
  l += 1
end
sel = @postname+[]
sel.push("Nowy wpis") if @owner==$name and @id != "NEW"
if sel.size==0 and @id=="NEW"
  speech("Brak nowych komentarzy na twoim blogu.")
  speech_wait
  $scene=Scene_WhatsNew.new
  return
  end
@sel = Select.new(sel,true,@postselindex)
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape or Input.trigger?(Input::LEFT)
    if @id == "NEW"    
      $scene = Scene_WhatsNew.new
      else
    $scene = Scene_Blog_Main.new(@owner,@categoryselindex,$blogreturnscene)
    end
  end
  if enter or Input.trigger?(Input::RIGHT)
        if @sel.index < @postname.size
      $scene = Scene_Blog_Read.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
    elsif @sel.commandoptions.size>0
      $scene = Scene_Blog_Post_New.new(@id.to_i,@postmaxid + 1,@categoryselindex)
      end
    end
  if $key[0x2e]
    if @sel.index < @postname.size - 1
      $scene = Scene_Blog_Post_Delete.new(@id,@postid[@sel.index],@categoryselindex)
      end
    end
    if alt
        menu
    end
  end
  def menu
    play("menu_open")
    play("menu_background")
    @menu = menulr(["Wybierz","Edytuj","Usuń"])
    @menu.disable_item(1) if @sel.index >= @postname.size-1 or $name!=@owner
    @menu.disable_item(2) if @sel.index >= @postname.size-1 or $name!=@owner
    loop do
      loop_update
      @menu.update
      if alt or escape
        break
      end
      if enter
        case @menu.index
        when 0
              if @sel.index < @postname.size - 1
      $scene = Scene_Blog_Read.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
    elsif @sel.commandoptions.size>0
      $scene = Scene_Blog_Post_New.new(@id,@postmaxid + 1,@categoryselindex)
    end
    when 1
      if @sel.index < @postname.size - 1
      $scene = Scene_Blog_Post_Edit.new(@id,@postid[@sel.index],@categoryselindex,@sel.index)
      end
    when 2
      if @sel.index < @postname.size - 1
      $scene = Scene_Blog_Post_Delete.new(@id,@postid[@sel.index],@categoryselindex)
      end
    end
            break
        end
      end
play("menu_close")
    Audio.bgs_stop
        end
end

class Scene_Blog_Post_New
def initialize(category,post,categoryselindex=0)
  @category = category
  @post = post
@categoryselindex = categoryselindex
  end
def main
blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
  end
categoryids = []
categorynames = []
for i in 0..lines - 1
  categoryids[i] = blogtemp[l].to_i
  l += 1
  categorynames[i] = blogtemp[l]
  l += 1
end
  postname = ""
  text = ""
@fields = []
@fields[0] = Edit.new("Tytuł wpisu","","",true)
@fields[1] = Edit.new("Treść wpisu","MULTILINE","",true)
@fields[2] = Button.new("Utwórz wpis audio")
@fields[3] = Select.new(categorynames,true,0,"Przypisz do kategorii",true,true)
@fields[4] = Button.new("Wyślij")
@fields[5] = Button.new("Anuluj")
for i in 0..categoryids.size-1
  @fields[3].selected[i] = true if categoryids[i] == @category
  end
@form = Form.new(@fields)
@recst=0
loop do
  @form.update
  loop_update
        if (enter or space) and @form.index == 2
          if @recst == 0
            play("menu_open")
            play("menu_background")
            o=selector(["Nagraj nowy wpis","Użyj istniejącego pliku","Anuluj"],"",0,2,1)
                        play("menu_close")
                        Audio.bgs_stop
            case o
                        when 0
delay(0.2)
                          play("recording_start")
            recording_start("temp/audioblogpost.wav")
            @recst=1
            @form.fields[2]=Button.new("Zakończ nagrywanie")
            @editpost=@form.fields[1]
            @form.fields[1]=nil
            @recfile="temp/audioblogpost.wav"
            when 1
              file=getfile
              if file!=""
                @editpost=@form.fields[1]
                @recfile=file
              @recst=2
            @form.fields[2]=Button.new("Odtwórz")
            @form.fields[1]=Button.new("Utwórz wpis tekstowy")
            @form.fields[2].focus
          end
          loop_update
                              end
          elsif @recst == 1
                        play("recording_stop")
            recording_stop
            @recst=2
            @form.fields[2]=Button.new("Odtwórz")
            @form.fields[1]=Button.new("Utwórz wpis tekstowy")
          else
            player(@recfile,"",true)
            end
          loop_update
            end
        if (enter or space) and @form.index == 1 and @recst == 2
          @recst=0
          @form.fields[2]=Button.new("Utwórz wpis audio")
          @form.fields[1]=@editpost
          @form.index=1
          @form.fields[1].focus
          loop_update
          end
  if (@form.index == 4 or $key[0x11] == true) and enter
          @form.fields[0].finalize
                    @form.fields[1].finalize if @recst == 0
                    recording_stop if @recst == 1
          postname = @form.fields[0].text_str
          text = @form.fields[1].text_str if @recst==0
          play("list_select")
          break
          end
if escape or ((enter or space) and @form.index == 5)
    $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
  return
end
end
blogtemp = 0
cat = ""
for i in 0..categoryids.size-1
  cat += categoryids[i].to_s + "," if @form.fields[3].selected[i] == true
  end
if @recst == 0
speech("Proszę czekać...")
speech_wait
bufid = buffer(text)
bt = "name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@post}\&postname=#{postname}\&buffer=#{bufid}\&add=1"
   blogtemp = srvproc("blog_posts_mod",bt)
 else
   waiting
                 speech("Konwertowanie pliku...")
      File.delete("temp/audioblogpost.mp3") if FileTest.exists?("temp/audioblogpost.mp3")
      h = run("bin\\ffmpeg.exe -y -i \"#{@recfile}\" -b:a 128K temp/audioblogpost.mp3",true)
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
        fl=read("temp/audioblogpost.mp3")
        boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
      host = $url.sub("https://","")
  host.delete!("/")
    q = "POST /blog_posts_mod.php?name=#{$name}\&token=#{$token}\&categoryid=#{cat.urlenc}\&postid=#{@post}\&postname=#{postname.urlenc}\&add=1\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
        blogtemp = strbyline(sn)
   end
err = blogtemp[0].to_i
waiting_end
if err < 0
  speech("Błąd.")
else
        speech("Wpis został dodany.")
end
speech_wait
$scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
  end
end

class Scene_Blog_Post_Delete
  def initialize(category,post,categoryselindex=0)
    @category = category
    @postid = post
  end
  def main
            if simplequestion("Czy jesteś pewien, że chcesz usunąć ten wpis?") == 0
      $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
    else
      bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&del=1")
      if bt[0].to_i < 0
        speech("Błąd")
        speech_wait
        $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
        return
      end
      speech("Usunięto.")
      speech_wait
      $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
      end
    end
  end

  class Scene_Blog_Post_Edit
  def initialize(category,post,categoryselindex=0,postselindex=0)
    @category = category
    @postid = post
    @categoryselindex = categoryselindex
    @postselindex = postselindex
  end
  def main
    blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
  end
categoryids = []
categorynames = []
for i in 0..lines - 1
  categoryids[i] = blogtemp[l].to_i
  l += 1
  categorynames[i] = blogtemp[l]
  l += 1
end
    blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&searchname=#{$name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Blog_Main.new
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
l = 2
text = ""
@posttext = []
@postauthor = []
@postbid = []
for i in 0..lines - 1
  t = 0
  @posttext[i] = ""
  loop do
    t += 1
    if t > 2
  @posttext[i] += blogtemp[l].to_s + "\r\n"
elsif t == 1
  @postbid[i] = blogtemp[l].to_i
elsif t == 2
  @postauthor[i] = blogtemp[l]
  end
l += 1
break if blogtemp[l] == "\004END\004" or l >= blogtemp.size or blogtemp[l] == "\004潤\n" or blogtemp[l] == nil
end
l += 1
end
pc = srvproc("blog_post_categories","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&postid=#{@postid}")
if pc[0].to_i < 0
  speech("Błąd")
  speech_wait
  $scene = Scene_Blog_Main.new
  return
  end
postname = pc[1].delete("\r\n")
comm = pc[2].to_i
  @fields = [Edit.new("Tytuł wpisu","",postname,true),Edit.new("Treść wpisu","MULTILINE",@posttext[0].delline(1)+"\004LINE\004",true),Select.new(categorynames,true,0,"Przypisz do kategorii",true,true),Button.new("Zapisz"),Button.new("Anuluj")]
for i in 3..comm+2
  c = pc[i].to_i
    for j in 0..categoryids.size-1
        @fields[2].selected[j] = true if categoryids[j] == c
    end
  end
  @form = Form.new(@fields)
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index == 4)
    $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
  end
  if (enter and $key[0x12]) or ((enter or space) and @form.index == 3)
@form.fields[0].finalize
@form.fields[1].finalize
    post = @form.fields[1].text_str
    buf = buffer(post)
cat = ""
for i in 0..categoryids.size-1
  cat += categoryids[i].to_s + "," if @form.fields[2].selected[i] == true
end
    bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str}\&buffer=#{buf.to_s}\&edit=1")
if bt[0].to_i < 0
  speech("Błąd")
else
  speech("Zapisano")
  end
  speech_wait
$scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)    
end
break if $scene != self
  end
  end
  end
  
class Scene_Blog_Read
  def initialize(owner,category,postid,categoryselindex=0,postselindex=0,scene=nil)
    @owner=owner
    @category = category
    @postid = postid
    @categoryselindex = categoryselindex
    @postselindex = postselindex
    @scene=scene
      end
  def main
blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&searchname=#{@owner}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Blog_Main.new(@owner)
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
l = 2
text = ""
@post = []
for i in 0..lines - 1
  t = 0
  @post[i] = Struct_Blog_Post.new
  loop do
    t += 1
    if t > 2
  @post[i].text += blogtemp[l].to_s + "\r\n"
elsif t == 1
  @post[i].id = blogtemp[l].to_i
elsif t == 2
  @post[i].author = blogtemp[l]
  end
l += 1
break if blogtemp[l] == "\004END\004" or l >= blogtemp.size or blogtemp[l] == "\004潤\n" or blogtemp[l] == nil
end
l += 1
end
@postcur = 0
@fields = []
for i in 0..@post.size-1
@fields[i] = Edit.new(@post[i].author,"MULTILINE|READONLY",@post[i].text,true)
end
if $name!="guest"
@fields.push(Edit.new("Twój komentarz","MULTILINE"))
else
  @fields.push(nil)
  end
@fields.push(nil)
if @owner==$name
@fields.push(Button.new("Zmodyfikuj swój wpis"))
else
  @fields.push(nil)
  end
@fields.push(Button.new("Powrót"))
@form = Form.new(@fields)
loop do
  loop_update
  @form.update
  update
  if @form.fields[@form.fields.size-4]!=nil and @form.fields[@form.fields.size-4].text!=[[]] and @form.fields[@form.fields.size-3]==nil
    @form.fields[@form.fields.size-3]=Button.new("Wyślij")
  elsif @form.fields[@form.fields.size-4]!=nil and @form.fields[@form.fields.size-4].text==[[]] and @form.fields[@form.fields.size-3]!=nil
    @form.fields[@form.fields.size-3]=nil
    end
  break if $scene != self
  end
end
def update
  if (enter or space) and @form.index == @form.fields.size - 3
    @form.fields[@form.fields.size - 4].finalize
    txt = @form.fields[@form.fields.size - 4].text_str
    if txt.size == 0 or txt == "\r\n"
      speech("Błąd")
      return
    end
    buf = buffer(txt)
    bt = srvproc("blog_posts_comment","name=#{$name}\&token=#{$token}\&searchname=#{@owner}\&categoryid=#{@category.to_s}\&postid=#{@postid.to_s}\&buffer=#{buf.to_s}")
    case bt[0].to_i
    when 0
      speech("Komentarz został dodany.")
      speech_wait
      main
      return
      when -1
        speech("Błąd połączenia się z bazą danych.")
        when -2
          speech("Klucz sesji wygasł")
          speech_wait
          $scene = Scene_Loading.new
          return
            end
  end
if (enter or space) and @form.index == @form.fields.size - 2
  @form.fields[0].finalize
  txt = @form.fields[0].text_str
  txt += "\r\nZmodyfikowany\r\n"
  $scene = Scene_Blog_Post_Modify.new(@category,@post,txt,@categoryselindex,@postselindex)
  end
  if escape or ((enter or space) and @form.index == @form.fields.size - 1)
if @scene == nil
    $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
  else
    $scene = @scene
    end
  end
  end
end



class Scene_Blog_Rename
  def main
    blogname = ""
    while blogname == ""
      blogname = input_text("Nowa nazwa bloga","ACCEPTESCAPE")
    end
    if blogname != "\004ESCAPE\004"
      bt = srvproc("blog_rename","name=#{$name}\&token=#{$token}\&blogname=#{blogname}")
      if bt[0].to_i == 0
        speech("Nazwa bloga została zmieniona")
      else
        speech("Błąd")
      end
      speech_wait
    end
    $scene = Scene_Blog_Main.new
  end
  end

  class Scene_Blog_Post_Modify
def initialize(category,post,posttext="",categoryselindex=0,postselindex=0)
  @category = category
  @post = post
@posttext = posttext
  @categoryselindex = categoryselindex
  @postselindex = postselindex
  end
def main
  text = ""
@fields = []
@fields[0] = Edit.new("Treść wpisu","MULTILINE",@posttext,true)
@fields[1] = Button.new("Wyślij")
@fields[2] = Button.new("Anuluj")
@form = Form.new(@fields)
loop do
  @form.update
  loop_update
        if (@form.index == 1 or $key[0x11] == true) and enter
                    @form.fields[0].finalize
                    text = @form.fields[0].text_str
          play("list_select")
          break
          end
if escape or ((enter or space) and @form.index == 2)
    $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
  return
end
end
speech("Proszę czekać...")
speech_wait
bufid = buffer(text)
blogtemp = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@post}\&buffer=#{bufid}\&mod=1")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
else
  speech("Wpis został zmodyfikowany.")
end
speech_wait
$scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
  end
end
  




class Scene_Blog_List
  def initialize(orderby=0)
    $blogsorderby=orderby
    end
  def main
        blogtemp = srvproc("blog_list","name=#{$name}\&token=#{$token}\&orderby=#{$blogsorderby}")
      if blogtemp[0].to_i < 0
     speech("Błąd")
     speech_wait
     $scene = Scene_Blog.new
     return
     end
i = 1
u = true
l = -1
@owners = []
@names = []
loop do
  i += 1
  if u == false
    @names[l] = blogtemp[i].delete("\n")
    u = true
  else
    l += 1
    @owners[l] = blogtemp[i].delete("\n")
    u = false
    end
  break if i >= blogtemp.size - 1
end
fol = srvproc("blog_fb","name=#{$name}\&token=#{$token}\&get=1")
if fol[0].to_i < 0
  speech("błąd")
  speech_wait
  $scene = Scene_Main.new
  return
end
@followedblogs = []
for i in 2..fol.size-1
  @followedblogs.push(fol[i].delete("\r\n"))
  end
sel = []
for i in 0..@names.size - 1
  sel[i] = @names[i] + " - Autor: " + @owners[i]
end
@sel = Select.new(sel,true,$bloglistindex,"Lista blogów")
$bloglistindex=0
@main = false
loop do
  loop_update
  @sel.update
  update
  break if $scene != self or @main == true
  end
end
def update
  if escape or Input.trigger?(Input::LEFT)
    $scene = Scene_Blog.new($blogsorderby+1)
  end
      if enter or Input.trigger?(Input::RIGHT)
     $bloglistindex = @sel.index
        $scene = Scene_Blog_Main.new(@owners[@sel.index],0,$scene)
      end
      if alt
        @main = false
        menu
                end
      end
      def menu
play("menu_open")
play("menu_background")
sel = [@owners[@sel.index],"Otwórz"]
isf = false
for u in @followedblogs
  isf = true if u == @owners[@sel.index]
end
if isf == true
  sel.push("Usuń ze śledzonych blogów")
else
  sel.push("Dodaj do śledzonych blogów")
end
sel += ["Odśwież","Anuluj"]
@menu = menulr(sel)
loop do
loop_update
@menu.update
break if $scene != self
if enter
  case @menu.index
  when 0
    if usermenu(@owner[@sel.index],true) != "ALT"
          @menu = menulr(sel)
        else
          break
        end
when 1
  $bloglistindex = @sel.index
        $scene = Scene_Blog_Other.new(@owners[@sel.index],$scene)
  when 2
   if isf == false
err = srvproc("blog_fb","name=#{$name}\&token=#{$token}\&add=1\&searchname=#{@owners[@sel.index]}")[0].to_i
if err != 0
  speech("Błąd")
else
  speech("Dodano do śledzonych blogów.")
  @followedblogs.push(@owners[@sel.index])
end
speech_wait
else
  err = srvproc("blog_fb","name=#{$name}\&token=#{$token}\&remove=1\&searchname=#{@owners[@sel.index]}")[0].to_i
if err != 0
  speech("Błąd")
else
  speech("Usunięto z listy śledzonych blogów.")
  @followedblogs.delete(@owners[@sel.index])
end
speech_wait
end
        when 3
          @main = true
  when 4
$scene = Scene_Main.new
end
break
end
if Input.trigger?(Input::DOWN) and @menu.index == 0
    Input.update
  if usermenu(@owners[@sel.index],true) != "ALT"
    @menu = menulr(sel)
  else
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
main if @main == true
return
end
end

class Scene_Blog_Recategorize
  def initialize(scene=nil)
    @scene=scene
    end
  def main
    blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
  end
categoryids = []
categorynames = []
for i in 0..lines - 1
  categoryids[i] = blogtemp[l].to_i
  l += 1
  categorynames[i] = blogtemp[l]
  l += 1
end
blogtemp = srvproc("blog_posts","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&categoryid=0\&assignnew=1\&listcategories=1\&reverse=1")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
l = 2
@postname = []
@postid = []
@postmaxid = 0
@postnew=[]
@postcategories=[]
for i in 0..lines - 1
  @postid[i] = blogtemp[l].to_i
  @postmaxid = blogtemp[l].to_i if blogtemp[l].to_i > @postmaxid
  l += 1
  @postname[i] = blogtemp[l]
  l += 1
    @postnew[i] = blogtemp[l].to_i
  if @postnew[i]>0
    @postname[i]+="\004NEW\004"
    end
  l += 1
    @postcategories[i]=[]
  for c in blogtemp[l].split(",")
    @postcategories[i].push(c.to_i)
    end
  l += 1
end
@fields=[]
for i in 0..@postid.size-1
  f=Select.new(categorynames,true,0,@postname[i],true,true)
  for c in @postcategories[i]
    ind=categoryids.find_index(c)
    f.selected[ind]=true
    end
  @fields.push(f)
    end
@fields+=[Button.new("Zapisz"),Button.new("Anuluj")]
@form=Form.new(@fields)
loop do
  loop_update
  @form.update
  break if escape or ((space or enter) and @form.index==@form.fields.size-1)
  if (space or enter) and (@form.index==@form.fields.size-2 or $key[0x11])
    ou=""
for i in 0..@postid.size-1
  ch=[]
  for j in 0..@form.fields[i].selected.size-1
    ch.push(categoryids[j]) if @form.fields[i].selected[j]==true
  end
  ou+=@postid[i].to_s+":"+ch.join(",")+"|" if ch.size>0
end
buf=buffer(ou)
bt=srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&recategorize=1\&buffer=#{buf}")
if bt[0].to_i<0
  speech("Błąd")
  else
  speech("Rekategoryzacja zakończona")
end
speech_wait
break
    end
  end
$scene=Scene_Blog_Main.new($name,-1,@scene)
end
end

class Struct_Blog_Post
  attr_accessor :id
  attr_accessor :author
  attr_accessor :text
  def initialize(id=0)
    @id=id
    @author=$name
    @text=""
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper