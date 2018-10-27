#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Blog
  def initialize(index=0)
    @index=index
    end
  def main
    @sel = Select.new([_("Blog:opt_myblog"),_("Blog:opt_recentlyupdatedblogs"),_("Blog:opt_frequentlyupdatedblogs"),_("Blog:opt_frequentlycommentedblogs"),_("Blog:opt_followedblogs")],true,@index,_("Blog:head"),true)
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
  speech(_("General:error"))
  speech_wait
  $scene = Scene_Main.new
  return
end
exist = blogtemp[1].to_i
if exist == 0
  if @owner==$name
    $scene = Scene_Blog_Create.new
  else
    speech(_("Blog:error_blognotfound"))
    $scene=$blogreturnscene
    $scene=Scene_Blog.new if $scene==nil
    end
  return
end
blogtemp = srvproc("blog_name","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
  speech_wait
  $scene = Scene_Main.new
    if $blogreturnscene == nil
    $scene = Scene_Main.new
  else
    $scene = $blogreturnscene
    $blogreturnscene = nil
    end
end
blogname = blogtemp[1].delete("\r\n")
@blogname=blogname
blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
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
@postname = [_("Blog:opt_allposts")]+@postname
sel = @postname+[]
sel.push(_("Blog:opt_newcat")) if $name==@owner
sel.push(_("Blog:opt_renameblog")) if @owner==$name
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
blogrename
    elsif @sel.index == @postname.size + 2
$scene = Scene_Blog_Recategorize.new(@scene)
            else
categorynew
                end
              end
              $scene = Scene_Blog_Category_Delete.new(@postid[@sel.index]) if $key[0x2e] and @sel.index < @postid.size and @sel.index != 0 and $name == @owner
  if alt
        menu
    end
  end
  def categorynew
                          name = ""
        while name == ""
      name = input_text(_("Blog:type_catname"),"ACCEPTESCAPE")
    end
    if name != "\004ESCAPE\004" or name == "\004TAB\004"
            blogtemp = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&add=1\&categoryid=#{@id.to_s}\&categoryname=#{name}")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
else
  speech(_("Blog:info_categorycreated"))
  @sel.commandoptions.insert(-4,name)
  @postname.push(name)
    @postid.push(blogtemp[1].to_i)
end
speech_wait
end
@sel.focus
end
def blogrename
          blogname = ""
    while blogname == ""
      blogname = input_text(_("Blog:type_newblogname"),"ACCEPTESCAPE",@blogname)
    end
    if blogname != "\004ESCAPE\004"
      bt = srvproc("blog_rename","name=#{$name}\&token=#{$token}\&blogname=#{blogname}")
      if bt[0].to_i == 0
        @sel.header=@blogname=blogname
        speech(_("Blog:info_blogrenamed"))
      else
        speech(_("General:error"))
      end
      speech_wait
    end
    @sel.focus
    end
def menu
    play("menu_open")
    @menu = menulr([_("Blog:opt_select"),_("Blog:opt_rename"),_("General:str_delete")])
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
          if @sel.index < @postname.size
      $scene = Scene_Blog_Posts.new(@owner,@postid[@sel.index],@sel.index)
    elsif @sel.index == @postname.size + 1
Audio.bgs_stop
      blogrename
elsif @sel.index == @postname.size + 2
$scene = Scene_Blog_Recategorize.new(@scene)
            else
              Audio.bgs_stop    
              categorynew
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
    speech(_("Blog:alert_noblog"))
    speech_wait
if simplequestion == 0
  $scene = Scene_Main.new
  return
end
name = input_text(_("Blog:type_blogname"),"ACCEPTESCAPE")
if name == "\004ESCAPE\004" or name == "\004TAB\004"
    $scene = Scene_Main.new
  return
end
speech(_("Blog:wait"))
speech_wait
blogtemp = srvproc("blog_create","name=#{$name}\&token=#{$token}\&blogname=#{name}")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
  speech_wait
  $scene = Scene_Main.new
  return
end
speech(_("Blog:info_blogcreated"))
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
      name = input_text(_("Blog:type_catname"),"ACCEPTESCAPE")
    end
    if name == "\004ESCAPE\004" or name == "\004TAB\004"
            $scene = Scene_Blog_Main.new
      return
    end
blogtemp = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&add=1\&categoryid=#{@id.to_s}\&categoryname=#{name}")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
else
  speech(_("Blog:info_categorycreated"))
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
    name=input_text(_("Blog:type_newcatname"),"ACCEPTESCAPE")
  end
  if name != "\004ESCAPE\004"
    bt = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&rename=1\&categoryid=#{@categoryid.to_s}\&categoryname=#{name}")
    if bt[0].to_i < 0
      speech(_("General:error"))
    else
      speech(_("Blog:info_renamed"))
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
        if simplequestion(_("Blog:alert_deletecategory")) == 0
      $scene = Scene_Blog_Main.new
    else
      bt = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@id}\&del=1")
            if bt[0].to_i < 0
        speech(_("General:error"))
        speech_wait
        $scene = Scene_Blog_Main.new
        return
      end
      speech(_("Blog:info_deleted"))
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
  speech(_("General:error"))
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
sel.push(_("Blog:opt_newpost")) if @owner==$name and @id != "NEW"
if sel.size==0 and @id=="NEW"
  speech(_("Blog:info_nonewcommentsonyourblog"))
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
  if $key[0x2e] and @owner==$name
    if @sel.index < @postname.size
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
    @menu = menulr([_("Blog:opt_select"),_("Blog:opt_edit"),_("General:str_delete")])
    @menu.disable_item(1) if @sel.index >= @postname.size or $name!=@owner
    @menu.disable_item(2) if @sel.index >= @postname.size or $name!=@owner
    loop do
      loop_update
      @menu.update
      if alt or escape
        break
      end
      if enter
        case @menu.index
        when 0
              if @sel.index < @postname.size
      $scene = Scene_Blog_Read.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
    elsif @sel.commandoptions.size>0
      $scene = Scene_Blog_Post_New.new(@id,@postmaxid + 1,@categoryselindex)
    end
    when 1
      if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Edit.new(@id,@postid[@sel.index],@categoryselindex,@sel.index)
      end
    when 2
      if @sel.index < @postname.size
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
  speech(_("General:error"))
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
@fields[0] = Edit.new(_("Blog:type_posttitle"),"","",true)
@fields[1] = Edit.new(_("Blog:type_post"),"MULTILINE","",true)
@fields[2] = Button.new(_("Blog:btn_createaudiopost"))
@fields[3] = Select.new(categorynames,true,0,_("Blog:head_postcategories"),true,true)
@fields[4] = Select.new([_("Blog:opt_viseveryone"),_("Blog:opt_vislogged")],true,0,_("Blog:head_visibility"),true)
@fields[5] = Button.new(_("Blog:btn_send"))
@fields[6] = Button.new(_("General:str_cancel"))
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
            o=selector([_("Blog:btn_recpost"),_("Blog:opt_useexistingfile"),_("General:str_cancel")],"",0,2,1)
                        play("menu_close")
                        Audio.bgs_stop
            case o
                        when 0
delay(0.2)
                          play("recording_start")
            recording_start("temp/audioblogpost.wav",3600)
            @recst=1
            @form.fields[2]=Button.new(_("Blog:btn_stoprec"))
            @editpost=@form.fields[1]
            @form.fields[1]=nil
            @recfile="temp/audioblogpost.wav"
            when 1
              file=getfile
              if file!=""
                @editpost=@form.fields[1]
                @recfile=file
              @recst=2
            @form.fields[2]=Button.new(_("Blog:btn_play"))
            @form.fields[1]=Button.new(_("Blog:btn_createtextpost"))
            @form.fields[2].focus
          end
          loop_update
                              end
          elsif @recst == 1
                        play("recording_stop")
            recording_stop
            @recst=2
            @form.fields[2]=Button.new(_("Blog:btn_play"))
            @form.fields[1]=Button.new(_("Blog:btn_createtextpost"))
          else
            player(@recfile,"",true)
            end
          loop_update
            end
        if (enter or space) and @form.index == 1 and @recst == 2
          @recst=0
          @form.fields[2]=Button.new(_("Blog:btn_createaudiopost"))
          @form.fields[1]=@editpost
          @form.index=1
          @form.fields[1].focus
          loop_update
          end
  if ((@form.index == 5 or $key[0x11] == true) and enter) or (@form.index==5 and space)
          @form.fields[0].finalize
                    @form.fields[1].finalize if @recst == 0
                    recording_stop if @recst == 1
          postname = @form.fields[0].text_str
          text = @form.fields[1].text_str if @recst==0
          play("list_select")
          break
          end
if escape or ((enter or space) and @form.index == 6)
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
speech(_("Blog:wait"))
speech_wait
bufid = buffer(text)
bt = "name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@post}\&postname=#{postname}\&buffer=#{bufid}\&add=1\&privacy=#{@form.fields[4].index.to_s}"
   blogtemp = srvproc("blog_posts_mod",bt)
 else
   waiting
                 speech(_("Blog:wait_converting"))
      File.delete("temp/audioblogpost.opus") if FileTest.exists?("temp/audioblogpost.opus")
      h = run("bin\\ffmpeg.exe -y -i \"#{@recfile}\" -b:a 128K temp/audioblogpost.opus",true)
      t = 0
      tmax = 20000
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
        fl=read("temp/audioblogpost.opus")
        boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
      host = $srv
  host.delete!("/")
    q = "POST /srv/blog_posts_mod.php?name=#{$name}\&token=#{$token}\&categoryid=#{cat.urlenc}\&postid=#{@post}\&postname=#{postname.urlenc}\&privacy=#{@form.fields[4].index.to_s}\&add=1\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
        blogtemp = strbyline(sn)
   end
err = blogtemp[0].to_i
waiting_end
if err < 0
  speech(_("General:error"))
else
        speech(_("Blog:info_postcreated"))
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
            if simplequestion(_("Blog:alert_deletepost")) == 0
      $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
    else
      bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&del=1")
      if bt[0].to_i < 0
        speech(_("General:error"))
        speech_wait
        $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
        return
      end
      speech(_("Blog:info_deleted"))
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
if blogtemp[0].to_i < 0
  speech(_("General:error"))
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
    blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&searchname=#{$name}\&details=3")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
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
@postprivacy=[]
for i in 0..lines - 1
  t = 0
  @posttext[i] = ""
  loop do
    t += 1
    if t > 5
  @posttext[i] += blogtemp[l].to_s + "\r\n"
elsif t == 1
  @postbid[i] = blogtemp[l].to_i
elsif t == 2
  @postauthor[i] = blogtemp[l]
  elsif t == 5
  @postprivacy[i] = blogtemp[l].to_i
  end
l += 1
break if blogtemp[l] == "\004END\004" or l >= blogtemp.size or blogtemp[l] == "\004潤\n" or blogtemp[l] == nil
end
l += 1
end
pc = srvproc("blog_post_categories","name=#{$name}\&token=#{$token}\&searchname=#{$name}\&postid=#{@postid}")
if pc[0].to_i < 0
  speech(_("General:error"))
  speech_wait
  $scene = Scene_Blog_Main.new
  return
  end
postname = pc[1].delete("\r\n")
comm = pc[2].to_i
  @fields = [Edit.new(_("Blog:type_posttitle"),"",postname,true),Edit.new(_("Blog:type_post"),"MULTILINE",@posttext[0].delline(1)+"\004LINE\004",true),Select.new(categorynames,true,0,_("Blog:head_postcategories"),true,true),Select.new([_("Blog:opt_viseveryone"),_("Blog:opt_vislogged")],true,@postprivacy[0].to_i,_("Blog:head_visibility"),true),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))]
    if (/\004AUDIO\004([a-zA-Z0-9\\:\/\-_ ]+)\004AUDIO\004/=~@posttext[0]) != nil
                @postaudio=$1
        @postaudio.sub!("/",$url) if @postaudio[0..0]=="/"
        @fields[1]=Button.new(_("Blog:btn_audiopost"))    
        end    
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
  if escape or ((enter or space) and @form.index == 5)
    $scene = Scene_Blog_Posts.new($name,@category,@categoryselindex,@postselindex)
  end
  if (enter or space) and @form.index==1 and @postaudio!=nil
    case menuselector([_("Blog:btn_play"),_("Blog:opt_changeaudiofile"),_("General:str_cancel")])
        when 0
                    player(@postaudio,postname)
          when 1
            fl=getfile(_("Blog:head_selaudiofile"),getdirectory(5)+"\\")
            @postaudio=fl if fl!="" and fl!=nil
      end
    @form.focus
      end
  if (enter and $key[0x12]) or ((enter or space) and @form.index == 4)
@form.fields[0].finalize
    cat = ""
for i in 0..categoryids.size-1
  cat += categoryids[i].to_s + "," if @form.fields[2].selected[i] == true
end
bt=[]
if @postaudio==nil
post = @form.fields[1].text_str
    buf = buffer(post)    
bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str.urlenc}\&buffer=#{buf.to_s}\&edit=1\&privacy=#{@form.fields[3].index.to_i}")
elsif @postaudio.include?($url)
    bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str.urlenc}\&edit=1\&privacy=#{@form.fields[3].index.to_s}")
else
  waiting
                 speech(_("Blog:wait_converting"))
      File.delete("temp/audioblogpost.opus") if FileTest.exists?("temp/audioblogpost.opus")
      executeprocess("bin\\ffmpeg.exe -y -i \"#{@postaudio}\" -b:a 128K \"temp/audioblogpost.opus\"",true)
              fl=read("temp/audioblogpost.opus")
        boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
      host = $srv.delete("/")
      q = "POST /srv/blog_posts_mod.php?name=#{$name}\&token=#{$token}\&categoryid=#{cat.urlenc}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str.urlenc}\&edit=1\&privacy=#{@form.fields[3].index.to_s}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
a = connect(host,80,q).delete("\0")
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
waiting_end
        end
if bt[0].to_i < 0
  speech(_("General:error"))
else
  speech(_("General:info_saved"))
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
blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&searchname=#{@owner}&details=1")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
  speech_wait
  $scene = Scene_Blog_Main.new(@owner)
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\n")
end
lines = blogtemp[1].to_i
@knownposts=blogtemp[2].to_i
l = 3
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
@fields.push(Edit.new(_("Blog:type_comment"),"MULTILINE"))
else
  @fields.push(nil)
  end
@fields.push(nil)
if @owner==$name
@fields.push(Button.new(_("Blog:btn_modifypost")))
else
  @fields.push(nil)
  end
@fields.push(Button.new(_("Blog:btn_back")))
@form = Form.new(@fields)
loop do
  loop_update
  @form.update
  update
  if @form.fields[@form.fields.size-4]!=nil and @form.fields[@form.fields.size-4].text!="" and @form.fields[@form.fields.size-3]==nil
    @form.fields[@form.fields.size-3]=Button.new(_("Blog:btn_send"))
  elsif @form.fields[@form.fields.size-4]!=nil and @form.fields[@form.fields.size-4].text=="" and @form.fields[@form.fields.size-3]!=nil
    @form.fields[@form.fields.size-3]=nil
    end
  break if $scene != self
  end
end
def update
  if $key[0x11] and !$key[0x12]
    if $key[0xBC]
      @form.index=@postcur=0
      @form.focus
    elsif $key[0xBE]
      @form.index=@postcur=@form.fields.size-5
      @form.focus
    elsif $key[0x4E]
      @form.index=@postcur=@form.fields.size-4
    @form.focus
      elsif $key[0x55] and @knownposts<@post.size
      @form.index=@postcur=@knownposts
      @form.focus
    end
    end
  if (enter or space) and @form.index == @form.fields.size - 3
    @form.fields[@form.fields.size - 4].finalize
    txt = @form.fields[@form.fields.size - 4].text_str
    if txt.size == 0 or txt == "\r\n"
      speech(_("General:error"))
      return
    end
    buf = buffer(txt)
    bt = srvproc("blog_posts_comment","name=#{$name}\&token=#{$token}\&searchname=#{@owner}\&categoryid=#{@category.to_s}\&postid=#{@postid.to_s}\&buffer=#{buf.to_s}")
    case bt[0].to_i
    when 0
      speech(_("Blog:info_commentcreated"))
      speech_wait
      main
      return
      when -1
        speech(_("General:error_db"))
        when -2
          speech(_("General:error_tokenexpired"))
          speech_wait
          $scene = Scene_Loading.new
          return
            end
  end
if (enter or space) and @form.index == @form.fields.size - 2
  @form.fields[0].finalize
  txt = @form.fields[0].text_str
  txt += "\r\nZmodyfikowany\r\n"
  $scene = Scene_Blog_Post_Edit.new(@category,@postid,@categoryselindex,@postselindex)
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
      blogname = input_text(_("Blog:type_newblogname"),"ACCEPTESCAPE")
    end
    if blogname != "\004ESCAPE\004"
      bt = srvproc("blog_rename","name=#{$name}\&token=#{$token}\&blogname=#{blogname}")
      if bt[0].to_i == 0
        speech(_("Blog:info_blogrenamed"))
      else
        speech(_("General:error"))
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
@fields[0] = Edit.new(_("Blog:type_post"),"MULTILINE",@posttext,true)
@fields[1] = Button.new(_("Blog:btn_send"))
@fields[2] = Button.new(_("General:str_cancel"))
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
speech(_("Blog:wait"))
speech_wait
bufid = buffer(text)
blogtemp = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@post}\&buffer=#{bufid}\&mod=1")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
else
  speech(_("Blog:info_modified"))
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
     speech(_("General:error"))
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
  speech(_("General:error"))
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
  sel[i] = @names[i] + " - #{_("Blog:opt_phr_author")}: " + @owners[i]
end
@sel = Select.new(sel,true,$bloglistindex,_("Blog:head_list"))
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
sel = [@owners[@sel.index],_("Blog:opt_open")]
isf = false
for u in @followedblogs
  isf = true if u == @owners[@sel.index]
end
if isf == true
  sel.push(_("Blog:opt_unfollowblog"))
else
  sel.push(_("Blog:opt_followblog"))
end
sel += [_("Blog:opt_markallasread"),_("General:str_refresh"),_("General:str_cancel")]
@menu = menulr(sel)
loop do
loop_update
@menu.update
break if $scene != self
if enter
  case @menu.index
  when 0
    if usermenu(@owners[@sel.index],true) != "ALT"
          @menu = menulr(sel)
        else
          break
        end
when 1
  $bloglistindex = @sel.index
        $scene = Scene_Blog_Main.new(@owners[@sel.index],0,$scene)
  when 2
   if isf == false
err = srvproc("blog_fb","name=#{$name}\&token=#{$token}\&add=1\&searchname=#{@owners[@sel.index]}")[0].to_i
if err != 0
  speech(_("General:error"))
else
  speech(_("Blog:info_blogfollowed"))
  @followedblogs.push(@owners[@sel.index])
end
speech_wait
else
  err = srvproc("blog_fb","name=#{$name}\&token=#{$token}\&remove=1\&searchname=#{@owners[@sel.index]}")[0].to_i
if err != 0
  speech(_("General:error"))
else
  speech(_("Blog:info_blogunfollowed"))
  @followedblogs.delete(@owners[@sel.index])
end
speech_wait
end
when 3
  confirm(_("Blog:alert_markblogasread")) do
    if srvproc("blog_markasread","name=#{$name}\&token=#{$token}\&user=#{@owners[@sel.index]}")[0].to_i==0
      speech(_("Blog:info_blogmarkedasread"))
    else
      speech(_("General:error"))
    end
    speech_wait
    end
        when 4
          @main = true
  when 5
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
  speech(_("General:error"))
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
  speech(_("General:error"))
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
@fields+=[Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))]
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
  speech(_("General:error"))
  else
  speech(_("Blog:info_recategorized"))
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