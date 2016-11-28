#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Blog
  def main
    @sel = Select.new(["Mój blog","Lista blogów"],true,0,"Blogi")
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
      $scene = Scene_Blog_My.new
      when 1
        $bloglistindex = 0
        $scene = Scene_Blog_List.new
   end
   end
    end
end

class Scene_Blog_My
  def initialize(categoryselindex=0)
    @categoryselindex = categoryselindex
    @postselindex = 0
    end
  def main
    blogtemp = srvproc("blog_exist","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
end
exist = blogtemp[1].to_i
if exist == 0
  $scene = Scene_Blog_My_Create.new
  return
end
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
$postid = []
$postname = []
$postmaxid = 0
for i in 0..lines - 1
  $postid[i] = blogtemp[l]
  $postmaxid = $postid[i].to_i if $postid[i].to_i > $postmaxid
  l += 1
  $postname[i] = blogtemp[l]
  l += 1
end
$postid = [0]+$postid
$postname = ["Wszystkie wpisy"]+$postname
sel = $postname
sel.push("Nowa kategoria")
sel.push("Zmień nazwę bloga")
@sel = Select.new(sel,true,@categoryselindex,"Mój blog")
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape or Input.trigger?(Input::LEFT)
        $scene = Scene_Blog.new
  end
  if enter or Input.trigger?(Input::RIGHT)
    if @sel.index < $postname.size - 2
      $scene = Scene_Blog_My_Posts.new($postid[@sel.index],@sel.index)
    elsif @sel.index == $postname.size - 1
$scene = Scene_Blog_My_Rename.new
            else
                  $scene = Scene_Blog_My_Category_New.new($postmaxid + 1)
                end
              end
              $scene = Scene_Blog_My_Category_Delete.new($postid[@sel.index]) if $key[0x2e] and @sel.index < $postid.size - 1 and @sel.index != 0
  if alt
        menu
    end
  end
  def menu
    play("menu_open")
    @menu = SelectLR.new(["Wybierz","Zmień nazwę","Usuń"])
    @menu.disable_item(1) if @sel.index > $postid.size - 1 or @sel.index == 0
    @menu.disable_item(2) if @sel.index > $postid.size - 1 or @sel.index == 0
    loop do
      loop_update
      @menu.update
      if alt or escape
        break
      end
      if enter
        case @menu.index
        when 0
          if @sel.index < $postname.size - 2
      $scene = Scene_Blog_My_Posts.new($postid[@sel.index],@sel.index)
    elsif @sel.index == $postname.size - 1
$scene = Scene_Blog_My_Rename.new
            else
            $scene = Scene_Blog_My_Category_New.new($postmaxid + 1)
      end
    when 1
      $scene = Scene_Blog_My_Category_Rename.new($postid[@sel.index],@sel.index)
      when 2
$scene = Scene_Blog_My_Category_Delete.new($postid[@sel.index])      
    end
    break
        end
      end
    Audio.bgs_stop
    play("menu_close")
            end
end

class Scene_Blog_My_Create
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

class Scene_Blog_My_Category_New
  def initialize(id=0)
    @id = id
    end
  def main
    name = ""
        while name == ""
      name = input_text("Nazwa kategorii","ACCEPTESCAPE")
    end
    if name == "\004ESCAPE\004" or name == "\004TAB\004"
            $scene = Scene_Blog_My.new
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
$scene = Scene_Blog_My.new
  end
end

class Scene_Blog_My_Category_Rename
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
  $scene = Scene_Blog_My.new(@categoryselindex)
    end
  end

class Scene_Blog_My_Category_Delete
  def initialize(id)
    @id = id
  end
  def main
        if simplequestion("Czy jesteś pewien, że chcesz usunąć tą kategorię?") == 0
      $scene = Scene_Blog_My.new
    else
      bt = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@id}\&del=1")
            if bt[0].to_i < 0
        speech("Błąd")
        speech_wait
        $scene = Scene_Blog_My.new
        return
      end
      speech("Usunięto.")
      speech_wait
      $scene = Scene_Blog_My.new
      end
    end
  end

class Scene_Blog_My_Posts
  def initialize(id,categoryselindex=0,postselindex=0)
    @id = id
    @categoryselindex = categoryselindex
    @postselindex = postselindex
    end
  def main
id = @id
blogtemp = srvproc("blog_posts","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&categoryid=#{id}")
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
$postname = []
$postid = []
$postmaxid = 0
for i in 0..lines - 1
  $postid[i] = blogtemp[l].to_i
  $postmaxid = blogtemp[l].to_i if blogtemp[l].to_i > $postmaxid
  l += 1
  $postname[i] = blogtemp[l]
  l += 1
end
sel = $postname
sel.push("Nowy wpis")
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
        $scene = Scene_Blog_My.new(@categoryselindex)
  end
  if enter or Input.trigger?(Input::RIGHT)
        if @sel.index < $postname.size - 1
      $scene = Scene_Blog_My_Read.new(@id,$postid[@sel.index],@categoryselindex,@sel.index)
    else
      $scene = Scene_Blog_My_Post_New.new(@id.to_i,$postmaxid + 1,@categoryselindex)
      end
    end
  if $key[0x2e]
    if @sel.index < $postname.size - 1
      $scene = Scene_Blog_My_Post_Delete.new(@id,$postid[@sel.index],@categoryselindex)
      end
    end
    if alt
        menu
    end
  end
  def menu
    play("menu_open")
    play("menu_background")
    @menu = SelectLR.new(["Wybierz","Edytuj","Usuń"])
    @menu.disable_item(1) if @sel.index >= $postname.size-1
    @menu.disable_item(2) if @sel.index >= $postname.size-1
    loop do
      loop_update
      @menu.update
      if alt or escape
        break
      end
      if enter
        case @menu.index
        when 0
              if @sel.index < $postname.size - 1
      $scene = Scene_Blog_My_Read.new(@id,$postid[@sel.index],@categoryselindex,@sel.index)
    else
      $scene = Scene_Blog_My_Post_New.new(@id,$postmaxid + 1,@categoryselindex)
    end
    when 1
      if @sel.index < $postname.size - 1
      $scene = Scene_Blog_My_Post_Edit.new(@id,$postid[@sel.index],@categoryselindex,@sel.index)
      end
    when 2
      if @sel.index < $postname.size - 1
      $scene = Scene_Blog_My_Post_Delete.new(@id,$postid[@sel.index],@categoryselindex)
      end
    end
            break
        end
      end
play("menu_close")
    Audio.bgs_stop
        end
end

class Scene_Blog_My_Post_New
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
@fields[2] = Select.new(categorynames,true,0,"Przypisz do kategorii",true,true)
@fields[3] = Button.new("Wyślij")
@fields[4] = Button.new("Anuluj")
for i in 0..categoryids.size-1
  @fields[2].selected[i] = true if categoryids[i] == @category
  end
@form = Form.new(@fields)
loop do
  @form.update
  loop_update
        if (@form.index == 3 or $key[0x11] == true) and enter
          @form.fields[0].finalize
          @form.fields[1].finalize
          postname = @form.fields[0].text_str
          text = @form.fields[1].text_str
          play("list_select")
          break
          end
if escape or ((enter or space) and @form.index == 4)
    $scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
  return
end
end
speech("Proszę czekać...")
speech_wait
bufid = buffer(text)
cat = ""
for i in 0..categoryids.size-1
  cat += categoryids[i].to_s + "," if @form.fields[2].selected[i] == true
end
bt = "name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@post}\&postname=#{postname}\&buffer=#{bufid}\&add=1"
   blogtemp = srvproc("blog_posts_mod",bt)
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
else
        speech("Wpis został dodany.")
end
speech_wait
$scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
  end
end

class Scene_Blog_My_Post_Delete
  def initialize(category,post,categoryselindex=0)
    @category = category
    @postid = post
  end
  def main
            if simplequestion("Czy jesteś pewien, że chcesz usunąć ten wpis?") == 0
      $scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
    else
      bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&del=1")
      if bt[0].to_i < 0
        speech("Błąd")
        speech_wait
        $scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
        return
      end
      speech("Usunięto.")
      speech_wait
      $scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
      end
    end
  end

  class Scene_Blog_My_Post_Edit
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
  $scene = Scene_Blog_My.new
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
l = 2
text = ""
$posttext = []
$postauthor = []
$postid = []
for i in 0..lines - 1
  t = 0
  $posttext[i] = ""
  loop do
    t += 1
    if t > 2
  $posttext[i] += blogtemp[l].to_s + "\r\n"
elsif t == 1
  $postid[i] = blogtemp[l].to_i
elsif t == 2
  $postauthor[i] = blogtemp[l]
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
  $scene = Scene_Blog_My.new
  return
  end
postname = pc[1].delete("\r\n")
comm = pc[2].to_i
  @fields = [Edit.new("Tytuł wpisu","",postname,true),Edit.new("Treść wpisu","MULTILINE",$posttext[0].delline(2),true),Select.new(categorynames,true,0,"Przypisz do kategorii",true,true),Button.new("Zapisz"),Button.new("Anuluj")]
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
    $scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
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
$scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)    
end
break if $scene != self
  end
  end
  end
  
class Scene_Blog_My_Read
  def initialize(category,post,categoryselindex=0,postselindex=0)
    @category = category
    @post = post
    @categoryselindex = categoryselindex
    @postselindex = postselindex
    end
  def main
blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@post}\&searchname=#{$name}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  $scene = Scene_Blog_My.new
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
l = 2
text = ""
$posttext = []
$postauthor = []
$postid = []
for i in 0..lines - 1
  t = 0
  $posttext[i] = ""
  loop do
    t += 1
    if t > 2
  $posttext[i] += blogtemp[l].to_s + "\r\n"
elsif t == 1
  $postid[i] = blogtemp[l].to_i
elsif t == 2
  $postauthor[i] = blogtemp[l]
  end
l += 1
break if blogtemp[l] == "\004END\004" or l >= blogtemp.size or blogtemp[l] == "\004潤\n" or blogtemp[l] == nil
end
l += 1
end
$postcur = 0
@fields = []
for i in 0..$posttext.size-1
@fields[i] = Edit.new($postauthor[i],"MULTILINE|READONLY",$posttext[i],true)
end
@fields.push(Edit.new("Twój komentarz","MULTILINE"))
@fields.push(Button.new("Wyślij"))
@fields.push(Button.new("Zmodyfikuj swój wpis"))
@fields.push(Button.new("Powrót"))
@form = Form.new(@fields)
loop do
  loop_update
  @form.update
  update
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
    bt = srvproc("blog_posts_comment","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&categoryid=#{@category.to_s}\&postid=#{@post.to_s}\&buffer=#{buf.to_s}")
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
  $scene = Scene_Blog_My_Post_Modify.new(@category,@post,txt,@categoryselindex,@postselindex)
  end
  if escape or ((enter or space) and @form.index == @form.fields.size - 1)
        $scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
  end
  end
end



class Scene_Blog_My_Rename
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
    $scene = Scene_Blog_My.new
  end
  end

  class Scene_Blog_My_Post_Modify
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
    $scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
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
$scene = Scene_Blog_My_Posts.new(@category,@categoryselindex,@postselindex)
  end
end
  
class Scene_Blog_Other
def initialize(user,scene=nil, selindex=0)
@user = user
$blogreturnscene = scene
@selindex = selindex
end
  def main
user = @user
$bloguser = user
blogtemp = srvproc("blog_exist","name=#{$name}\&token=#{$token}\&searchname=#{user}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  if $blogreturnscene == nil
    $scene = Scene_Main.new
  else
    $scene = $blogreturnscene
    $blogreturnscene = nil
    end
  return
end
exist = blogtemp[1].to_i
if exist == 0
speech("Nie znaleziono bloga, którego autorem jest " + user + ".")
speech_wait
  if $blogreturnscene == nil
    $scene = Scene_Main.new
  else
    $scene = $blogreturnscene
    $blogreturnscene = nil
    end
return
end
blogtemp = srvproc("blog_name","name=#{$name}\&token=#{$token}\&searchname=#{user}")
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
$blogname = blogtemp[1]
blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{user}")
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
$postid = []
$postname = []
$postmaxid = 0
for i in 0..lines - 1
  $postid[i] = blogtemp[l]
  $postmaxid = $postid[i].to_i if $postid[i].to_i > $postmaxid
  l += 1
  $postname[i] = blogtemp[l]
  l += 1
end
$postid = [0]+$postid
$postname = ["Wszystkie wpisy"]+$postname
sel = $postname
@sel = Select.new(sel,true,@selindex,$blogname)
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape or Input.trigger?(Input::LEFT)
          if $blogreturnscene == nil
    $scene = Scene_Main.new
  else
    $scene = $blogreturnscene
    $blogreturnscene = nil
    end
  end
  if enter or Input.trigger?(Input::RIGHT)
          $scene = Scene_Blog_Other_Posts.new($postid[@sel.index],@user,@sel.index)
    end
  end
end

class Scene_Blog_Other_Posts
  def initialize(id,user,categoryselindex=0,postselindex=0)
    @id = id
@user = user
@categoryselindex = categoryselindex
@postselindex = postselindex
end
  def main
user = @user
id = @id
blogtemp = srvproc("blog_posts","name=#{$name}\&token=#{$token}\&searchname=#{user}\&categoryid=#{id}")
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
$postname = []
$postid = []
$postmaxid = 0
for i in 0..lines - 1
  $postid[i] = blogtemp[l].to_i
  $postmaxid = blogtemp[l].to_i if blogtemp[l].to_i > $postmaxid
  l += 1
  $postname[i] = blogtemp[l]
  l += 1
end
sel = $postname
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
        $scene = Scene_Blog_Other.new(@user,$blogreturnscene,@categoryselindex)
  end
  if enter or Input.trigger?(Input::RIGHT)
      $scene = Scene_Blog_Other_Read.new(@id,$postid[@sel.index],@user,@categoryselindex,@sel.index)
    end
  end
end

class Scene_Blog_Other_Read
  def initialize(category,post,user,categoryselindex=0,postselindex=0,returnscene=nil)
    @category = category
    @post = post
@user = user
@categoryselindex = categoryselindex
@postselindex = postselindex
@returnscene = returnscene
end
  def main
user = @user
blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@post}\&searchname=#{user}")
err = blogtemp[0].to_i
if err < 0
  speech("Błąd.")
  speech_wait
  if @returnscene == nil  
  $scene = Scene_Blog_Other.new(user,$blogreturnscene)
else
  $scene = @returnscene
  end
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
l = 2
text = ""
$posttext = []
$postauthor = []
$postid = []
for i in 0..lines - 1
  t = 0
  $posttext[i] = ""
  loop do
    t += 1
    if t > 2
  $posttext[i] += blogtemp[l].to_s + "\r\n"
  
elsif t == 1
  $postid[i] = blogtemp[l].to_i
elsif t == 2
  $postauthor[i] = blogtemp[l]
  end
l += 1
break if blogtemp[l] == "\004END\004" or l >= blogtemp.size or blogtemp[l] == "\004潤\n" or blogtemp[l] == nil
end
l += 1
end
$postcur = 0
@fields = []
for i in 0..$posttext.size-1
@fields[i] = Edit.new($postauthor[i],"MULTILINE|READONLY",$posttext[i],true)
end
@fields.push(Edit.new("Twój komentarz","MULTILINE"))
@fields.push(Button.new("Wyślij"))
@fields.push(Button.new("Powrót"))
@form = Form.new(@fields)
loop do
  loop_update
  @form.update
  update
  break if $scene != self
  end
end
def update
    if (enter or space) and @form.index == @form.fields.size - 2
    @form.fields[@form.fields.size - 3].finalize
    txt = @form.fields[@form.fields.size - 3].text_str
    if txt.size == 0 or txt == "\r\n"
      speech("Błąd")
      return
    end
    buf = buffer(txt)
    bt = srvproc("blog_posts_comment","name=#{$name}\&token=#{$token}\&searchname=#{@user}\&categoryid=#{@category.to_s}\&postid=#{@post.to_s}\&buffer=#{buf.to_s}")
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
  if escape or ((enter or space) and @form.index == @form.fields.size - 1)
    if @returnscene == nil
        $scene = Scene_Blog_Other_Posts.new(@category,@user,@categoryselindex,@postselindex)
        else
        $scene = @returnscene
        end
  end
  end
end


class Scene_Blog_List
  def main
        blogtemp = srvproc("blog_list","name=#{$name}\&token=#{$token}")
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
    $scene = Scene_Blog.new
  end
      if enter or Input.trigger?(Input::RIGHT)
     $bloglistindex = @sel.index
        $scene = Scene_Blog_Other.new(@owners[@sel.index],$scene)
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
  sel.push("Usuń ze śledzonych blogów.")
else
  sel.push("Dodaj do śledzonych blogów.")
end
sel += ["Odśwież","Anuluj"]
@menu = SelectLR.new(sel)
loop do
loop_update
@menu.update
break if $scene != self
if enter
  case @menu.index
  when 0
    if usermenu(@usr[@sel.index],true) != "ALT"
          @menu = SelectLR.new(sel)
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
    @menu = SelectLR.new(sel)
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
Graphics.transition(10)
main if @main == true
return
end
end
#Copyright (C) 2014-2016 Dawid Pieper