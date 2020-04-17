#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

                  class Scene_Blog
  def initialize(index=0)
    @index=index
    end
  def main
        @sel = Select.new([p_("Blog", "Managed blogs"),p_("Blog", "Recently updated blogs"),p_("Blog", "Frequently updated blogs"),p_("Blog", "Frequently commented blogs"),p_("Blog", "Followed blogs"), p_("Blog", "Blogs popular with my friends")],true,@index,p_("Blog", "Blogs"),true)
  if Session.name=="guest"
    @sel.disable_item(0)
    @sel.index=1
    @sel.disable_item(4)
    @sel.disable_item(5)
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
    if enter or arrow_right
     case @sel.index
     when 0
       $bloglistindex=0
      $scene = Scene_Blog_List.new(5)
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
        when 5
                    $bloglistindex=0
        $scene = Scene_Blog_List.new(4)
   end
   end
    end
end

class Scene_Blog_Main
  def initialize(owner=Session.name,categoryselindex=0,scene=nil)
    @owner=owner
    @categoryselindex = categoryselindex
    @postselindex = 0
    $blogreturnscene=scene
    end
  def main
        blogtemp = srvproc("blog_exist",{"searchname"=>@owner})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = Scene_Main.new
  return
end
exist = blogtemp[1].to_i
if exist == 0
    if @owner==Session.name
    $scene = Scene_Blog_Create.new
  else
    alert(p_("Blog", "The blog cannot be found."))
    $scene=$blogreturnscene
    $scene=Scene_main.new if $scene==nil
    end
  return
end
blogtemp = srvproc("blog_name",{"searchname"=>@owner})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
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
blogtemp = srvproc("blog_categories",{"searchname"=>@owner})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = Scene_Main.new
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
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
@postname = [p_("Blog", "All posts")]+@postname
sel = @postname+[]
@sel = Select.new(sel,true,@categoryselindex,blogname)
  @sel.bind_context{|menu|context(menu)}
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape or arrow_left
    $scene=$blogreturnscene    
    $scene = Scene_Main.new if $scene==nil
  end
  if enter or arrow_right
    bopen
            end
              $scene = Scene_Blog_Category_Delete.new(@owner,@postid[@sel.index]) if $key[0x2e] and @sel.index < @postid.size and @sel.index != 0 and blogowners(@owner).include?(Session.name)
            end
            def bopen
      $scene = Scene_Blog_Posts.new(@owner,@postid[@sel.index],@sel.index)
                end
  def categorynew
                          name = ""
        while name == ""
      name = input_text(p_("Blog", "Category name"),"ACCEPTESCAPE")
    end
    if name != "\004ESCAPE\004" or name == "\004TAB\004"
            blogtemp = srvproc("blog_categories_mod", {"add"=>"1", "categoryid"=>@id.to_s, "categoryname"=>name, "searchname"=>@owner})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
else
  alert(p_("Blog", "The category has been created."))
  @sel.commandoptions.push(name)
  @postname.push(name)
    @postid.push(blogtemp[1].to_i)
end
speech_wait
return main
end
@sel.focus
end
def context(menu)
    menu.option(p_("Blog", "Select")) {
    bopen
    }
    if !(@sel.index > @postid.size - 1 or @sel.index == 0 or !blogowners(@owner).include?(Session.name))
    menu.option(p_("Blog", "Rename")) {
          $scene = Scene_Blog_Category_Rename.new(@owner,@postid[@sel.index],@sel.index)
    }
    end
if !(@sel.index > @postid.size - 1 or @sel.index == 0 or !blogowners(@owner).include?(Session.name))
    menu.option(_("Delete")) {
    $scene = Scene_Blog_Category_Delete.new(@owner,@postid[@sel.index])      
    }
  end
  if blogowners(@owner).include?(Session.name)
    menu.option(p_("Blog", "New category")) {
    categorynew
    }
    end
            end
          end
          
          class Scene_Blog_Category_Rename
  def initialize(searchname,categoryid,categoryselindex)
    @searchname=searchname
    @categoryid=categoryid
    @categoryselindex=categoryselindex
  end
  def main
    name=""
    while name==""
    name=input_text(p_("Blog", "Type a new category name"),"ACCEPTESCAPE")
  end
  if name != "\004ESCAPE\004"
    bt = srvproc("blog_categories_mod", {"rename"=>"1", "categoryid"=>@categoryid.to_s, "categoryname"=>name, "searchname"=>@searchname})
    if bt[0].to_i < 0
      alert(_("Error"))
    else
      alert(p_("Blog", "The blog has been renamed."))
    end
    speech_wait
  end
  $scene = Scene_Blog_Main.new(@searchname,@categoryselindex)
    end
  end
          
          class Scene_Blog_Category_Delete
  def initialize(searchname,id)
    @searchname=searchname
    @id = id
  end
  def main
        if confirm(p_("Blog", "Are you sure you want to delete this category?")) == 0
      $scene = Scene_Blog_Main.new(@searchname)
    else
      bt = srvproc("blog_categories_mod",{"categoryid"=>@id, "del"=>"1", "searchname"=>@searchname})
            if bt[0].to_i < 0
        alert(_("Error"))
        $scene = Scene_Blog_Main.new(@searchname)
        return
      end
      alert(p_("Blog", "Deleted"))
      $scene = Scene_Blog_Main.new(@searchname)
      end
    end
 end

class Scene_Blog_Create
  def initialize(shared=false, scene=nil)
    @shared=shared
    @scene=scene
    @scene=Scene_Blog.new if @scene==nil
    end
  def main
    if @shared==false
if confirm(p_("Blog", "You do not have any blog. Do you want to create one?")) == 0
  $scene = @scene
  return
end
end
name = input_text(p_("Blog", "Type a blog name"),"ACCEPTESCAPE")
if name == "\004ESCAPE\004" or name == "\004TAB\004"
    $scene = @scene
  return
end
alert(p_("Blog", "Please wait..."))
speech_wait
bp={"blogname"=>name}
bp["shared"]="1" if @shared==true
$blogownerstime=0
blogtemp = srvproc("blog_create",bp)
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = @scene
  return
end
alert(p_("Blog", "The blog has been created."))
speech_wait
$scene = @scene
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
blogtemp = srvproc("blog_posts",{"searchname"=>@owner, "categoryid"=>id, "assignnew"=>"1"})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = Scene_Main.new
  return
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
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
if sel.size==0 and @id=="NEW"
  alert(p_("Blog", "No new comments on your blog."))
  $scene=Scene_WhatsNew.new
  return
  end
@sel = Select.new(sel,true,@postselindex)
@sel.bind_context{|menu|context(menu)}
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape or arrow_left
    if @id == "NEW"    
      $scene = Scene_WhatsNew.new
      else
    $scene = Scene_Blog_Main.new(@owner,@categoryselindex,$blogreturnscene)
    end
  end
  if enter or arrow_right
      $scene = Scene_Blog_Read.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
    end
  if $key[0x2e] and blogowners(@owner).include?(Session.name)
      $scene = Scene_Blog_Post_Delete.new(@owner,@id,@postid[@sel.index],@categoryselindex)
    end
  end
  def context(menu)
    menu.option(p_("Blog", "Select")) {
      $scene = Scene_Blog_Read.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
    }
    if @postname.size>0 and blogowners(@owner).include?(Session.name)
    menu.option(p_("Blog", "Edit")) {
          if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Edit.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
    end
    }
    menu.option(p_("Blog", "Move to another blog")) {
        if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Move.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
      end
    }
    menu.option(_("Delete")) {
          if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Delete.new(@owner,@id,@postid[@sel.index],@categoryselindex)
      end
    }
  end
if blogowners(@owner).include?(Session.name) and @id != "NEW"
  menu.option(p_("Blog", "New post")) {
$scene = Scene_Blog_Post_New.new(@owner,@id.to_i,@postmaxid + 1,@categoryselindex)
}
end
        end
end

class Scene_Blog_Post_New
def initialize(owner,category,post,categoryselindex=0)
  @owner=owner
  @category = category
  @post = post
@categoryselindex = categoryselindex
  end
def main
blogtemp = srvproc("blog_categories",{"searchname"=>@owner})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = Scene_Main.new
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
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
@fields[0] = Edit.new(p_("Blog", "Post title"),"","",true)
@fields[1] = Edit.new(p_("Blog", "Post"),"MULTILINE","",true)
@fields[2] = Button.new(p_("Blog", "Create an audiopost"))
@fields[3] = Select.new(categorynames,true,0,p_("Blog", "Post categories"),true,true)
@fields[4] = Select.new([p_("Blog", "Show to everyone"),p_("Blog", "Do not show to unlogged users")],true,0,p_("Blog", "Visibility"),true)
@fields[5] = CheckBox.new(p_("Blog", "Allow users to comment this post"),1)
@fields[6] = Button.new(p_("Blog", "Send"))
@fields[7] = Button.new(_("Cancel"))
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
            o=selector([p_("Blog", "Record a new post"),p_("Blog", "Use an existing file"),_("Cancel")],"",0,2,1)
                        play("menu_close")
                        Audio.bgs_stop
            case o
                        when 0
                                      @r=Recorder.start($tempdir+"/audioblogpost.opus",96)
                                      play("recording_start")
            @recst=1
            @form.fields[2]=Button.new(p_("Blog", "Stop recording"))
            @editpost=@form.fields[1]
            @form.fields[1]=nil
            @recfile=$tempdir+"/audioblogpost.opus"
            when 1
              file=getfile("","",false,nil,[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma",".opus",".aac"])
              if file!=""
                @editpost=@form.fields[1]
                @recfile=file
              @recst=2
            @form.fields[2]=Button.new(p_("Blog", "Play"))
            @form.fields[1]=Button.new(p_("Blog", "Create a text post"))
            @form.fields[2].focus
          end
          loop_update
                              end
          elsif @recst == 1
                        play("recording_stop")
            @r.stop
            @recst=2
            @form.fields[2]=Button.new(p_("Blog", "Play"))
            @form.fields[1]=Button.new(p_("Blog", "Create a text post"))
          else
            player(@recfile,"",true)
            end
          loop_update
            end
        if (enter or space) and @form.index == 1 and @recst == 2
          @recst=0
          @form.fields[2]=Button.new(p_("Blog", "Create an audiopost"))
          @form.fields[1]=@editpost
          @form.index=1
          @form.fields[1].focus
          loop_update
          end
  if ((@form.index == 6 or $key[0x11] == true) and enter) or (@form.index==6 and space)
          @form.fields[0].finalize
                    @form.fields[1].finalize if @recst == 0
                    @r.stop if @recst == 1
          postname = @form.fields[0].text_str
          text = @form.fields[1].text_str if @recst==0
          play("list_select")
          break
          end
if escape or ((enter or space) and @form.index == 7)
    $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
  return
end
end
blogtemp = 0
cat = ""
for i in 0..categoryids.size-1
  cat += categoryids[i].to_s + "," if @form.fields[3].selected[i] == true
  end
if @recst == 0
alert(p_("Blog", "Please wait..."))
speech_wait
bufid = buffer(text)
bt = {"categoryid"=>cat, "postid"=>@post, "postname"=>postname, "buffer"=>bufid, "add"=>"1", "privacy"=>@form.fields[4].index.to_s, "comments"=>@form.fields[5].checked.to_s, "searchname"=>@owner}
   blogtemp = srvproc("blog_posts_mod",bt)
 else
   waiting
   alert(p_("Blog", "Please wait..."))
   if @recfile!=$tempdir+"/audioblogpost.opus"
   executeprocess("bin\\ffmpeg.exe -y -i \"#{@recfile}\" -b:a 128K \"#{$tempdir}/audioblogpost.opus\"",true)
      end
        fl=readfile($tempdir+"/audioblogpost.opus")
        if fl[0..3]!='OggS'
          alert(_("Error"))
          return $scene=Scene_Main.new
          end
        boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
      host = $srv
  host.delete!("/")
    q = "POST /srv/blog_posts_mod.php?name=#{Session.name}\&token=#{Session.token}\&categoryid=#{cat.urlenc}\&postid=#{@post}\&postname=#{postname.urlenc}\&privacy=#{@form.fields[4].index.to_s}\&comments=#{@form.fields[5].checked.to_s}\&add=1\&searchname=#{@owner}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: close\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
a = elconnect(q)
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    alert(_("Error"))
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        blogtemp = sn.split("\r\n")
   end
err = blogtemp[0].to_i
waiting_end
if err < 0
  alert(_("Error"))
else
        alert(p_("Blog", "The post has been added."))
end
speech_wait
$scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
  end
end

class Scene_Blog_Post_Delete
  def initialize(owner,category,post,categoryselindex=0)
    @owner=owner
    @category = category
    @postid = post
  end
  def main
            if confirm(p_("Blog", "Are you sure you want to delete this post?")) == 0
      $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
    else
      bt = srvproc("blog_posts_mod",{"categoryid"=>@category, "postid"=>@postid, "del"=>"1", "searchname"=>@owner})
      if bt[0].to_i < 0
        alert(_("Error"))
        $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
        return
      end
      alert(p_("Blog", "Deleted"))
      $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
      end
    end
  end

  class Scene_Blog_Post_Edit
  def initialize(owner,category,post,categoryselindex=0,postselindex=0)
    @owner=owner
        @category = category
    @postid = post
    @categoryselindex = categoryselindex
    @postselindex = postselindex
  end
  def main
    blogtemp = srvproc("blog_categories",{"searchname"=>@owner})
if blogtemp[0].to_i < 0
  alert(_("Error"))
  $scene = Scene_Main.new
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
  end
categoryids = []
categorynames = []
for i in 0..lines - 1
  categoryids[i] = blogtemp[l].to_i
  l += 1
  categorynames[i] = blogtemp[l]
  l += 1
end
    blogtemp = srvproc("blog_read",{"categoryid"=>@category, "postid"=>@postid, "searchname"=>@owner, "details"=>"4"})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = Scene_Blog_Main.new(@owner)
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
end
lines = blogtemp[1].to_i
l = 2
text = ""
@posttext = []
@postauthor = []
@postbid = []
@postprivacy=[]
@postcomments=[]
for i in 0..lines - 1
  t = 0
  @posttext[i] = ""
  loop do
    t += 1
    if t > 6
  @posttext[i] += blogtemp[l].to_s + "\r\n"
elsif t == 1
  @postbid[i] = blogtemp[l].to_i
elsif t == 2
  @postauthor[i] = blogtemp[l]
  elsif t == 5
  @postprivacy[i] = blogtemp[l].to_i
elsif t==6
  @postcomments[i] = blogtemp[l].to_i
  end
l += 1
break if blogtemp[l] == "\004END\004" or l >= blogtemp.size or blogtemp[l] == "\004潤\n" or blogtemp[l] == nil
end
l += 1
end
pc = srvproc("blog_post_categories",{"searchname"=>@owner, "postid"=>@postid})
if pc[0].to_i < 0
  alert(_("Error"))
  $scene = Scene_Blog_Main.new(@owner)
  return
  end
postname = pc[1].delete("\r\n")
comm = pc[2].to_i
  @fields = [Edit.new(p_("Blog", "Post title"),"",postname,true),Select.new([p_("Blog", "Text post"),p_("Blog", "Audio post")],true,0,p_("Blog", "Post type"),true),Edit.new(p_("Blog", "Post"),"MULTILINE",@posttext[0].delline(1)+"\004LINE\004",true),Select.new(categorynames,true,0,p_("Blog", "Post categories"),true,true),Select.new([p_("Blog", "Show to everyone"),p_("Blog", "Do not show to unlogged users")],true,@postprivacy[0].to_i,p_("Blog", "Visibility"),true),CheckBox.new(p_("Blog", "Allow users to comment this post"),@postcomments[0].to_b),Button.new(_("Save")),Button.new(_("Cancel"))]
  @textfield=@fields[2]
  @audiofield=Button.new(p_("Blog", "Audio post"))    
    if (/\004AUDIO\004([a-zA-Z0-9\\:\/\-_ ]+)\004AUDIO\004/=~@posttext[0]) != nil
      @fields[1].index=1
                @postaudio=$1
        @postaudio.sub!("/",$url) if @postaudio[0..0]=="/"
        @fields[2]=@audiofield
        @textfield.audiotext=""
        end    
for i in 3..comm+2
  c = pc[i].to_i
    for j in 0..categoryids.size-1
        @fields[3].selected[j] = true if categoryids[j] == c
    end
  end
  @sendbutton=@fields[6]
  @form = Form.new(@fields)
loop do
  loop_update
  @form.update
  if @fields[1].index==0
    @fields[2]=@textfield
    @fields[6]=@sendbutton
  else
    @fields[2]=@audiofield
    @fields[6]=(@postaudio==nil)?nil:@sendbutton
    end
  if escape or ((enter or space) and @form.index == 7)
    $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
  end
  if (enter or space) and @form.index==2 and @fields[1].index==1
    m=[p_("Blog", "Play"),p_("Blog", "Use another file"),_("Cancel")]
    m[0]=nil if @postaudio==nil
    case menuselector(m)
        when 0
                    player(@postaudio,postname)
          when 1
            fl=getfile(p_("Blog", "Select audio file"),getdirectory(5)+"\\",false,nil,[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma",".opus",".aac"])
            @postaudio=fl if fl!="" and fl!=nil
      end
    @form.focus
      end
  if (enter and $key[0x12]) or ((enter or space) and @form.index == 6)
@form.fields[0].finalize
if @postcomments[0]==1 and @form.fields[5].checked==0
  confirm(p_("Blog", "Do you wish to delete all comments on this post? You can disable commenting on this post without deleting comments already posted.")) do
    srvproc("blog_posts_mod",{"postid"=>@postid.to_s, "delcomments"=>"1", "searchname"=>@owner})
  end
  end
    cat = ""
for i in 0..categoryids.size-1
  cat += categoryids[i].to_s + "," if @form.fields[3].selected[i] == true
end
bt=[]
if @fields[1].index==0
post = @form.fields[2].text_str
    buf = buffer(post)    
bt = srvproc("blog_posts_mod",{"categoryid"=>cat, "postid"=>@postid.to_s, "postname"=>@form.fields[0].text_str, "buffer"=>buf.to_s, "edit"=>"1", "privacy"=>@form.fields[4].index.to_s, "comments"=>@form.fields[5].checked.to_s, "searchname"=>@owner})
elsif @postaudio!=nil&&@postaudio.include?($url)
    bt = srvproc("blog_posts_mod",{"categoryid"=>cat, "postid"=>@postid.to_s, "postname"=>@form.fields[0].text_str, "edit"=>"1", "privacy"=>@form.fields[4].index.to_s, "comments"=>@form.fields[5].checked.to_s, "searchname"=>@owner})
elsif @postaudio!=nil
  waiting
                 speak(p_("Blog", "File is being converted..."))
      File.delete($tempdir+"/audioblogpost.opus") if FileTest.exists?($tempdir+"/audioblogpost.opus")
      executeprocess("bin\\ffmpeg.exe -y -i \"#{@postaudio}\" -b:a 128K \"#{$tempdir}/audioblogpost.opus\"",true)
              fl=readfile($tempdir+"/audioblogpost.opus")
        boundary=""
        while fl.include?(boundary)
        boundary="----EltBoundary"+rand(36**32).to_s(36)
        end
    data="--"+boundary+"\r\nContent-Disposition: form-data; name=\"post\"\r\n\r\n#{fl}\r\n--#{boundary}--"
    length=data.size    
      host = $srv.delete("/")
      q = "POST /srv/blog_posts_mod.php?name=#{Session.name}\&token=#{Session.token}\&categoryid=#{cat.urlenc}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str.urlenc}\&edit=1\&privacy=#{@form.fields[4].index.to_s}\&comments=#{@form.fields[5].checked.to_s}\&searchname=#{@owner}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: close\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
a = elconnect(q).delete("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    alert(_("Error"))
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = sn.split("\r\n")
waiting_end
        end
if bt[0].to_i < 0
  alert(_("Error"))
else
  alert(_("Saved"))
  end
  speech_wait
$scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)    
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
        blogtemp = srvproc("blog_read",{"categoryid"=>@category, "postid"=>@postid, "searchname"=>@owner, "details"=>"5"})
blogtemp.each {|l| l.delete!("\r\n")}
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = Scene_Blog_Main.new(@owner)
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
end
lines = blogtemp[1].to_i
@knownposts=blogtemp[2].to_i
@comments=blogtemp[3].to_i
l = 4
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
@fields[(i==0?i:(i+1))] = Edit.new(@post[i].author,Edit::Flags::MultiLine|Edit::Flags::ReadOnly|Edit::Flags::MarkDown,@post[i].text,true)
end
@fields[1]=nil
@medias=[]
yts=@post[0].text.scan(/\/watch\?v\=([a-zA-Z0-9\-\_]+)/).map {|a| a[0]}
yts+=@post[0].text.scan(/youtu.be\/([a-zA-Z0-9\-\_]+)/).map {|a| a[0]}
if yts.size>0
  e=ytlist(yts)
  if e.is_a?(Hash) and e['items'].is_a?(Array)
@medias=e['items']
end
end
if @medias.size>0
  @fields[1]=Select.new(@medias.map {|m| m['snippet']['title']},true,0,p_("Blog", "Media"),true)
  end
if Session.name!="guest"
@fields.push(Edit.new(p_("Blog", "Your comment"),"MULTILINE","",true))
else
  @fields.push(nil)
  end
@fields.push(nil)
if blogowners(@owner).include?(Session.name)
@fields.push(Button.new(p_("Blog", "Edit your post")))
else
  @fields.push(nil)
  end
@fields.push(Button.new(p_("Blog", "Return")))
@form = Form.new(@fields)
if @comments==0
  @form.fields[-3]=nil
  @form.fields[-4]=nil
end
@form.bind_context(p_("Blog", "Blogs")){|menu|context(menu)}
loop do
  loop_update
  @form.update
  update
  if @form.fields[@form.fields.size-4]!=nil and @form.fields[@form.fields.size-4].text!="" and @form.fields[@form.fields.size-3]==nil
    @form.fields[@form.fields.size-3]=Button.new(p_("Blog", "Send"))
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
      @form.index=@postcur=@knownposts+1
      @form.focus
    end
  end
  if enter and @form.index==1
    ytfile(@medias[@form.fields[1].index])
    speech_wait
    loop_update
    @form.fields[@form.index].focus
    end
  if ((enter or space) and @form.index == @form.fields.size - 3) or (enter and $key[0x11] and @form.index==@form.fields.size-4)
    @form.fields[@form.fields.size - 4].finalize
    txt = @form.fields[@form.fields.size - 4].text_str
    if txt.size == 0 or txt == "\r\n"
      alert(_("Error"))
      return
    end
    buf = buffer(txt)
    bt = srvproc("blog_posts_comment",{"searchname"=>@owner, "categoryid"=>@category.to_s, "postid"=>@postid.to_s, "buffer"=>buf.to_s})
    case bt[0].to_i
    when 0
      alert(p_("Blog", "The comment has been added."))
      main
      return
      when -1
        alert(_("Database Error"))
        when -2
          alert(_("Token expired"))
          $scene = Scene_Loading.new
          return
            end
  end
if (enter or space) and @form.index == @form.fields.size - 2
  @form.fields[0].finalize
  txt = @form.fields[0].text_str
    $scene = Scene_Blog_Post_Edit.new(@owner,@category,@postid,@categoryselindex,@postselindex)
    end
  if escape or ((enter or space) and @form.index == @form.fields.size - 1)
if @scene == nil
    $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
  else
    $scene = @scene
    end
  end
end
def context(menu)
  return if @form.index>@post.size or (@form.index==1 and @post.size==1)
      ind=@form.index-1
    ind+=1 if ind<0
    pst=@post[ind]
    menu.useroption(pst.author)
    menu.submenu(p_("Blog", "Navigation")) {|m|
    m.option(p_("Blog", "Go to post")) {
          @form.index=@postcur=0
      @form.focus
    }
    m.option(p_("Blog", "Go to last comment")) {
      @form.index=@postcur=@form.fields.size-5
      @form.focus
    }
    if @knownposts<@post.size
        m.option(p_("Blog", "Go to first unread comment")) {
      @form.index=@postcur=@knownposts+1
      @form.focus
    }
    end
    }
    if ind>0 and blogowners(@owner).include?(Session.name)
    menu.option(p_("Blog", "Delete this comment")) {
         confirm(p_("Blog", "Are you sure you want to delete this comment?")) {
         srvproc("blog_posts_mod",{"delcomment"=>"1", "searchname"=>@owner, "postid"=>@postid, "commentnumber"=>(ind).to_s})    
         main
         }
    }
    end
  end
end
  




class Scene_Blog_List
  def initialize(orderby=0)
    @orderby=orderby
    end
  def main
        blogtemp = srvproc("blog_list",{"orderby"=>@orderby})
      if blogtemp[0].to_i < 0
     alert(_("Error"))
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
    @names[l] = blogtemp[i].delete("\r\n")
    u = true
  else
    l += 1
        @owners[l] = blogtemp[i].delete("\r\n")
        @names[l] = p_("Blog", "My blog") if @owners[l]==@names[l] and @owners[l]==Session.name
      u = false
    end
  break if i >= blogtemp.size - 1
end
fol = srvproc("blog_fb",{"get"=>"1"})
if fol[0].to_i < 0
  alert(_("Error"))
  $scene = Scene_Main.new
  return
end
@followedblogs = []
for i in 2..fol.size-1
  @followedblogs.push(fol[i].delete("\r\n"))
  end
sel = []
for i in 0..@names.size - 1
  o=@owners[i]
  if o[0..0]=="["
    o=blogowners(o).join(", ")
    end
  sel[i] = [@names[i], o]
end
@sel = TableSelect.new([nil,p_("Blog", "Author")],sel,$bloglistindex,p_("Blog", "Blogs list"))
@sel.bind_context{|menu|context(menu)}
$bloglistindex=0
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
  end
end
def update
  if escape or (!$keyr[0x10]&&arrow_left)
    $scene = Scene_Blog.new(@orderby+1)
  end
      if enter or (!$keyr[0x10]&&arrow_right)
     $bloglistindex = @sel.index
        $scene = Scene_Blog_Main.new(@owners[@sel.index],0,$scene)
      end
    end
    def blogrename
          blogname = ""
    while blogname == ""
      blogname = input_text(p_("Blog", "New blog name"),"ACCEPTESCAPE",@names[@sel.index])
    end
    if blogname != "\004ESCAPE\004"
      bt = srvproc("blog_rename",{"blogname"=>blogname, "searchname"=>@owners[@sel.index]})
      if bt[0].to_i == 0
        alert(p_("Blog", "Your blog has been renamed"))
      else
        alert(_("Error"))
      end
    end
    $bloglistindex = @sel.index
main
end
def blogfollowers
  b=srvproc("blog_followers",{"searchname"=>@owners[@sel.index]})
if b[0].to_i==0
  users=[]
  b[2..-1].each {|u| users.push(u.delete("\r\n"))}
  if users.size==0
    alert(p_("Blog", "This blog is not followed by any user"))
  else
    selt=[]
    users.each{|u| selt.push(u+".\r\n"+getstatus(u))}
        sel=Select.new(selt,true,0,p_("Blog", "Followers"))
    loop do
      loop_update
      sel.update
      usermenu(users[sel.index]) if enter
            break if escape or arrow_left or $scene!=self
      end
    end
  else
    alert(_("Error"))
  end
  @sel.focus
loop_update
end
def blogcoworkers
    owners=blogowners(@owners[@sel.index])
  selt=owners
  sel=Select.new(selt,true,0,p_("Blog", "Coworkers"))
  sel.bind_context{|menu|
  menu.useroption(owners[sel.index])
  if blogowners(@owners[@sel.index])[0]==Session.name   and @owners[@sel.index][0..0]=="["
  menu.option(p_("Blog", "Add coworker")) {
                cow=input_text(p_("Blog", "What user you want to add to this blog?"),"ACCEPTESCAPE")
              if cow!="\004ESCAPE\004"
                cow=finduser(cow) if finduser(cow).downcase==cow.downcase
                if user_exist(cow)
                  srvproc("blog_coworkers",{"searchname"=>@owners[@sel.index], "ac"=>"add", "user"=>cow})
                  $blogownerstime=0
                  owners=blogowners(@owners[@sel.index])
                  sel.commandoptions=selt=owners
                  sel.focus
                else
                  alert(p_("Blog", "User not found"))
                  end
                end
  }
  if sel.index>0
    menu.option(p_("Blog", "Delete coworker")) {
                    confirm(p_("Blog", "Are you sure you want to release this coworker?")) {
srvproc("blog_coworkers",{"searchname"=>@owners[@sel.index], "ac"=>"release", "user"=>owners[sel.index]})                
$blogownerstime=0
owners=blogowners(@owners[@sel.index])
                  sel.commandoptions=selt=owners
                  sel.focus
                }
  }
    end
  end
  }
  loop do
    loop_update
    sel.update
              if $key[0x2e] and sel.index<owners.size and owners[sel.index]!=Session.name and blogowners(@owners[@sel.index])[0]==Session.name
                confirm(p_("Blog", "Are you sure you want to release this coworker?")) {
srvproc("blog_coworkers",{"searchname"=>@owners[@sel.index], "ac"=>"release", "user"=>owners[sel.index]})                
$blogownerstime=0
owners=blogowners(@owners[@sel.index])
                  sel.commandoptions=selt=owners
                  sel.focus
                }
                end
    break if escape or arrow_left
  end
  @sel.focus
  loop_update
end
def blogdelete
    confirm(p_("Blog", "Are you sure you want to delete this blog?")) {
    confirm(p_("Blog", "All posts written on this blog will be lost. Are you sure you want to continue?")) {
  b=srvproc("blog_delete",{"searchname"=>@owners[@sel.index]})
  alert(p_("Blogs", "Blog deleted"))
  return main
  }
  } 
  end
      def context(menu)
        if @owners.size>0
b=blogowners(@owners[@sel.index])
b.each{|u| menu.useroption(u)}
menu.option(p_("Blog", "Open")) {
  $bloglistindex = @sel.index
        $scene = Scene_Blog_Main.new(@owners[@sel.index],0,$scene)
}
if b.include?(Session.name)
  menu.option(p_("Blog", "Rename")) {
  blogrename
  }
  menu.option(p_("Blog", "Followers")) {
  blogfollowers
  }
  menu.option(p_("Blog", "Coworkers")) {
  blogcoworkers
  }
  menu.option(p_("Blog", "Recategorize")) {
  $bloglistindex = @sel.index
  $scene = Scene_Blog_Recategorize.new(@owners[@sel.index],$scene)
  }
  if b[0]==Session.name
  menu.option(p_("Blog", "Delete this blog")) {
  blogdelete
  }
  end
  end
isf = false
for u in @followedblogs
  isf = true if u == @owners[@sel.index]
end
s=""
if isf == true
  s=p_("Blog", "Remove from the followed blogs")
else
  s=p_("Blog", "Add to followed blogs")
end
menu.option(s) {
if isf == false
err = srvproc("blog_fb",{"add"=>"1", "searchname"=>@owners[@sel.index]})[0].to_i
if err != 0
  alert(_("Error"))
else
  alert(p_("Blog", "Added to the followed blogs."))
  @followedblogs.push(@owners[@sel.index])
end
speech_wait
else
  err = srvproc("blog_fb",{"remove"=>"1", "searchname"=>@owners[@sel.index]})[0].to_i
if err != 0
  alert(_("Error"))
else
  alert(p_("Blog", "Removed from the followed blogs."))
  @followedblogs.delete(@owners[@sel.index])
end
end
}
menu.option(p_("Blog", "Add this blog to quick actions")) {
QuickActions.create(Scene_Blog_Main, @names[@sel.index]+" (#{p_("Blog", "Blog")})", [@owners[@sel.index]])
alert(p_("Blog", "Blog added to quick actions"), false)
}
menu.option(p_("Blog", "Mark the blog as read")) {
confirm(p_("Blog", "All posts on this blog will be marked as read. Do you want to continue?")) do
    srvproc("blog_markasread",{"user"=>@owners[@sel.index]})
    if srvproc("blog_markasread",{"user"=>@owners[@sel.index]})[0].to_i==0
      alert(p_("Blog", "The blog has been marked as read."))
    else
      alert(_("Error"))
    end
    end
}
end
menu.option(p_("Blog", "Create new blog")) {
$bloglistindex = @sel.index
$scene=Scene_Blog_Create.new(true, $scene)
}
menu.option(_("Refresh")) {
          main
}
end
end

class Scene_Blog_Recategorize
  def initialize(searchname,scene=nil)
    @searchname=searchname
    @scene=scene
    @scene||=Scene_Blog.new
    end
  def main
    blogtemp = srvproc("blog_categories",{"searchname"=>@searchname})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = @scene
  return
end
lines = blogtemp[1].to_i
l = 2
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
  end
categoryids = []
categorynames = []
for i in 0..lines - 1
  categoryids[i] = blogtemp[l].to_i
  l += 1
  categorynames[i] = blogtemp[l]
  l += 1
end
blogtemp = srvproc("blog_posts",{"searchname"=>@searchname, "categoryid"=>"0", "assignnew"=>"1", "listcategories"=>"1", "reverse"=>"1"})
err = blogtemp[0].to_i
if err < 0
  alert(_("Error"))
  $scene = @scene
  return
end
for i in 0..blogtemp.size - 1
  blogtemp[i].delete!("\r\n")
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
    blogtemp[l]||=""
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
@fields+=[Button.new(_("Save")),Button.new(_("Cancel"))]
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
bt=srvproc("blog_posts_mod",{"recategorize"=>"1", "buffer"=>buf, "searchname"=>@searchname})
if bt[0].to_i<0
  alert(_("Error"))
  else
  alert(p_("Blog", "Recategorised"))
end
speech_wait
break
    end
  end
$scene=@scene
end
end

class Struct_Blog_Post
  attr_accessor :id
  attr_accessor :author
  attr_accessor :text
  def initialize(id=0)
    @id=id
    @author=Session.name
    @text=""
  end
end

class Scene_Blog_Post_Move
  def initialize(owner,category,post,categoryselindex=0,postselindex=0)
    @owner=owner
    @category=category
    @post=post
    @categoryselindex=categoryselindex
    @postselindex=postselindex
  end
  def main
    @blogids=[Session.name]
    @blognames=[p_("Blog", "My blog")]
    b=srvproc("blog_managed",{"searchname"=>Session.name})
    if b[0].to_i>0
      alert(_("Error"))
      $scene=Scene_Main.new
      return
      end
        for i in 2...b.size
      if i%2==0
        @blogids.push(b[i].delete("\r\n"))
      else
        @blognames.push(b[i].delete("\r\n"))
        end
      end
      @form=Form.new([Select.new(@blognames,true,@blogids.index(@owner)||0,p_("Blog", "Post destination"),true), Select.new([p_("Blog", "Move this post and all comments"),p_("Blog", "Move only this post, delete all comments")],true,0,p_("Blog", "Move type"),true), Button.new(p_("Blog", "Move")), Button.new(_("Cancel"))])
      loop do
        loop_update
        @form.update
        if @form.fields[2].pressed?
bl=srvproc("blog_move", {"searchname"=>@owner, "postid"=>@post.to_s, "destination"=>@blogids[@form.fields[0].index], "movetype"=>@form.fields[1].index.to_s})
if bl[0].to_i<0
  alert(_("Error"))
else
  alert(p_("Blog", "The post has been moved."))
end
speech_wait
break
          end
        break if escape or @form.fields[3].pressed?
                  end
    $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
  end
  end