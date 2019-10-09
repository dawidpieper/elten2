#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Blog
  def initialize(index=0)
    @index=index
    end
  def main
    return $scene=Scene_Main.new if $eltsuspend
    @sel = Select.new([_("Blog:opt_managedblogs"),_("Blog:opt_recentlyupdatedblogs"),_("Blog:opt_frequentlyupdatedblogs"),_("Blog:opt_frequentlycommentedblogs"),_("Blog:opt_followedblogs"), _("Blog:opt_popularblogs")],true,@index,_("Blog:head"),true)
  if $name=="guest"
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
    if enter or Input.trigger?(Input::RIGHT)
     case @sel.index
     when 0
       $blogmanagedindex=0
      $scene = Scene_Blog_Managed.new
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
  def initialize(owner=$name,categoryselindex=0,scene=nil)
    @owner=owner
    @categoryselindex = categoryselindex
    @postselindex = 0
    $blogreturnscene=scene
    end
  def main
    return $scene=Scene_Main.new if $eltsuspend
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
@postname = [_("Blog:opt_allposts")]+@postname
sel = @postname+[]
sel.push(_("Blog:opt_newcat")) if blogowners(@owner).include?($name)
sel.push(_("Blog:opt_renameblog")) if blogowners(@owner).include?($name)
sel.push(_("Blog:opt_recategorize")) if blogowners(@owner).include?($name)
sel.push(_("Blog:opt_followers")) if blogowners(@owner).include?($name)
sel.push(_("Blog:opt_coworkers")) if blogowners(@owner).include?($name) and @owner[0..0]=="["
sel.push(_("Blog:opt_deleteblog")) if blogowners(@owner)[0]==$name and @postname.size==1
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
$scene = Scene_Blog_Recategorize.new(@owner,@scene)
elsif @sel.index == @postname.size + 3
b=srvproc("blog_followers","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
if b[0].to_i==0
  users=[]
  b[2..-1].each {|u| users.push(u.delete("\r\n"))}
  if users.size==0
    speech(_("Blog:info_nofollowers"))
    speech_wait
  else
    selt=[]
    users.each{|u| selt.push(u+".\r\n"+getstatus(u))}
        sel=Select.new(selt,true,0,_("Blog:head_followers"))
    loop do
      loop_update
      sel.update
      break if escape or Input.trigger?(Input::LEFT)
      usermenu(users[sel.index]) if alt or enter
      end
    end
  else
    speech(_("General:error"))
    speech_wait
  end
  @sel.focus
elsif @sel.index==@postname.size+4
  owners=blogowners(@owner)
  selt=owners
  selt+=[_("Blog:opt_addcoworker")] if blogowners(@owner)[0]==$name
  sel=Select.new(selt,true,0,_("Blog:head_coworkers"))
  loop do
    loop_update
    sel.update
    if enter and sel.index==owners.size
              cow=input_text(_("Blog:type_coworker"),"ACCEPTESCAPE")
              if cow!="\004ESCAPE\004"
                cow=finduser(cow) if finduser(cow).downcase==cow.downcase
                if user_exist(cow)
                  srvproc("blog_coworkers","name=#{$name}\&token=#{$token}\&searchname=#{@owner}\&ac=add\&user=#{cow}")
                  $blogownerstime=0
                  owners=blogowners(@owner)
                  sel.commandoptions=selt=owners+[_("Blog:opt_addcoworker")]
                  sel.focus
                else
                  speech(_("Blog:error_usernotfound"))
                  end
                end
              end
              if $key[0x2e] and sel.index<owners.size and owners[sel.index]!=$name and blogowners(@owner)[0]==$name
                confirm(_("Blog:alert_release")) {
srvproc("blog_coworkers","name=#{$name}\&token=#{$token}\&searchname=#{@owner}\&ac=release\&user=#{owners[sel.index]}")                
$blogownerstime=0
owners=blogowners(@owner)
                  sel.commandoptions=selt=owners+[_("Blog:opt_addcoworker")]
                  sel.focus
                }
                end
    break if escape or Input.trigger?(Input::LEFT)
  end
  @sel.focus
elsif @sel.index==@postname.size+5
  confirm(_("Blog:alert_deleteblog")) {
  b=srvproc("blog_delete","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
  return $scene=Scene_Blog_Managed.new
  }
                else
categorynew
                end
              end
              $scene = Scene_Blog_Category_Delete.new(@owner,@postid[@sel.index]) if $key[0x2e] and @sel.index < @postid.size and @sel.index != 0 and blogowners(@owner).include?($name)
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
            blogtemp = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&add=1\&categoryid=#{@id.to_s}\&categoryname=#{name}\&searchname=#{@owner}")
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
      bt = srvproc("blog_rename","name=#{$name}\&token=#{$token}\&blogname=#{blogname}\&searchname=#{@owner}")
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
    @menu.disable_item(1) if @sel.index > @postid.size - 1 or @sel.index == 0 or !blogowners(@owner).include?($name)
    @menu.disable_item(2) if @sel.index > @postid.size - 1 or @sel.index == 0 or !blogowners(@owner).include?($name)
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
$scene = Scene_Blog_Recategorize.new(@owner,@scene)
            else
              Audio.bgs_stop    
              categorynew
                end
    when 1
      $scene = Scene_Blog_Category_Rename.new(@owner,@postid[@sel.index],@sel.index)
      when 2
$scene = Scene_Blog_Category_Delete.new(@owner,@postid[@sel.index])      
    end
    break
        end
      end
    Audio.bgs_stop
    play("menu_close")
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
    name=input_text(_("Blog:type_newcatname"),"ACCEPTESCAPE")
  end
  if name != "\004ESCAPE\004"
    bt = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&rename=1\&categoryid=#{@categoryid.to_s}\&categoryname=#{name}\&searchname=#{@searchname}")
    if bt[0].to_i < 0
      speech(_("General:error"))
    else
      speech(_("Blog:info_renamed"))
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
        if simplequestion(_("Blog:alert_deletecategory")) == 0
      $scene = Scene_Blog_Main.new(@searchname)
    else
      bt = srvproc("blog_categories_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@id}\&del=1\&searchname=#{@searchname}")
            if bt[0].to_i < 0
        speech(_("General:error"))
        speech_wait
        $scene = Scene_Blog_Main.new(@searchname)
        return
      end
      speech(_("Blog:info_deleted"))
      speech_wait
      $scene = Scene_Blog_Main.new(@searchname)
      end
    end
 end

class Scene_Blog_Create
  def initialize(shared=false)
    @shared=shared
    end
  def main
    if @shared==false
if simplequestion(_("Blog:alert_noblog")) == 0
  $scene = Scene_Blog_Managed.new
  return
end
end
name = input_text(_("Blog:type_blogname"),"ACCEPTESCAPE")
if name == "\004ESCAPE\004" or name == "\004TAB\004"
    $scene = Scene_Blog_Managed.new
  return
end
speech(_("Blog:wait"))
speech_wait
bp="name=#{$name}\&token=#{$token}\&blogname=#{name}"
bp+="\&shared=1" if @shared==true
$blogownerstime=0
blogtemp = srvproc("blog_create",bp)
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
  speech_wait
  $scene = Scene_Main.new
  return
end
speech(_("Blog:info_blogcreated"))
speech_wait
$scene = Scene_Blog_Managed.new
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
    return$scene=Scene_Main.new if $eltsuspend
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
sel.push(_("Blog:opt_newpost")) if blogowners(@owner).include?($name) and @id != "NEW"
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
      $scene = Scene_Blog_Post_New.new(@owner,@id.to_i,@postmaxid + 1,@categoryselindex)
      end
    end
  if $key[0x2e] and blogowners(@owner).include?($name)
    if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Delete.new(@owner,@id,@postid[@sel.index],@categoryselindex)
      end
    end
    if alt
        menu
    end
  end
  def menu
    play("menu_open")
    play("menu_background")
    @menu = menulr([_("Blog:opt_select"),_("Blog:opt_edit"),_("Blog:opt_movepost"),_("General:str_delete")],true,0,"",true)
    @menu.disable_item(1) if @sel.index >= @postname.size or !blogowners(@owner).include?($name)
    @menu.disable_item(2) if @sel.index >= @postname.size or !blogowners(@owner).include?($name)
    @menu.disable_item(2) if @sel.index >= @postname.size or !blogowners(@owner).include?($name)
    @menu.focus
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
      $scene = Scene_Blog_Post_New.new(@owner,@id,@postmaxid + 1,@categoryselindex)
    end
    when 1
      if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Edit.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
    end
    when 2
    if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Move.new(@owner,@id,@postid[@sel.index],@categoryselindex,@sel.index)
      end
      when 3
      if @sel.index < @postname.size
      $scene = Scene_Blog_Post_Delete.new(@owner,@id,@postid[@sel.index],@categoryselindex)
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
def initialize(owner,category,post,categoryselindex=0)
  @owner=owner
  @category = category
  @post = post
@categoryselindex = categoryselindex
  end
def main
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
@fields[0] = Edit.new(_("Blog:type_posttitle"),"","",true)
@fields[1] = Edit.new(_("Blog:type_post"),"MULTILINE","",true)
@fields[2] = Button.new(_("Blog:btn_createaudiopost"))
@fields[3] = Select.new(categorynames,true,0,_("Blog:head_postcategories"),true,true)
@fields[4] = Select.new([_("Blog:opt_viseveryone"),_("Blog:opt_vislogged")],true,0,_("Blog:head_visibility"),true)
@fields[5] = CheckBox.new(_("Blog:chk_comments"),1)
@fields[6] = Button.new(_("Blog:btn_send"))
@fields[7] = Button.new(_("General:str_cancel"))
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
                                      @r=Recorder.start("temp/audioblogpost.opus",96)
                                      play("recording_start")
            @recst=1
            @form.fields[2]=Button.new(_("Blog:btn_stoprec"))
            @editpost=@form.fields[1]
            @form.fields[1]=nil
            @recfile="temp/audioblogpost.opus"
            when 1
              file=getfile("","",false,nil,[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma",".opus",".aac"])
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
            @r.stop
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
speech(_("Blog:wait"))
speech_wait
bufid = buffer(text)
bt = "name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@post}\&postname=#{postname.urlenc}\&buffer=#{bufid}\&add=1\&privacy=#{@form.fields[4].index.to_s}\&comments=#{@form.fields[5].checked.to_s}\&searchname=#{@owner}"
   blogtemp = srvproc("blog_posts_mod",bt)
 else
   waiting
   speech(_("Blog:wait"))
   if @recfile!="temp/audioblogpost.opus"
   executeprocess("bin\\ffmpeg.exe -y -i \"#{@recfile}\" -b:a 128K \"temp/audioblogpost.opus\"",true)
      end
        fl=read("temp/audioblogpost.opus")
        if fl[0..3]!='OggS'
          speech(_("General:error"))
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
    q = "POST /srv/blog_posts_mod.php?name=#{$name}\&token=#{$token}\&categoryid=#{cat.urlenc}\&postid=#{@post}\&postname=#{postname.urlenc}\&privacy=#{@form.fields[4].index.to_s}\&comments=#{@form.fields[5].checked.to_s}\&add=1\&searchname=#{@owner}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
            if simplequestion(_("Blog:alert_deletepost")) == 0
      $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
    else
      bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&del=1\&searchname=#{@owner}")
      if bt[0].to_i < 0
        speech(_("General:error"))
        speech_wait
        $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
        return
      end
      speech(_("Blog:info_deleted"))
      speech_wait
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
    blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{@owner}")
if blogtemp[0].to_i < 0
  speech(_("General:error"))
  speech_wait
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
    blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&searchname=#{@owner}\&details=4")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
  speech_wait
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
pc = srvproc("blog_post_categories","name=#{$name}\&token=#{$token}\&searchname=#{@owner}\&postid=#{@postid}")
if pc[0].to_i < 0
  speech(_("General:error"))
  speech_wait
  $scene = Scene_Blog_Main.new(@owner)
  return
  end
postname = pc[1].delete("\r\n")
comm = pc[2].to_i
  @fields = [Edit.new(_("Blog:type_posttitle"),"",postname,true),Select.new([_("Blog:opt_textpost"),_("Blog:opt_audiopost")],true,0,_("Blog:head_posttype"),true),Edit.new(_("Blog:type_post"),"MULTILINE",@posttext[0].delline(1)+"\004LINE\004",true),Select.new(categorynames,true,0,_("Blog:head_postcategories"),true,true),Select.new([_("Blog:opt_viseveryone"),_("Blog:opt_vislogged")],true,@postprivacy[0].to_i,_("Blog:head_visibility"),true),CheckBox.new(_("Blog:chk_comments"),@postcomments[0].to_b),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))]
  @textfield=@fields[2]
  @audiofield=Button.new(_("Blog:btn_audiopost"))    
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
    m=[_("Blog:btn_play"),_("Blog:opt_changeaudiofile"),_("General:str_cancel")]
    m[0]=nil if @postaudio==nil
    case menuselector(m)
        when 0
                    player(@postaudio,postname)
          when 1
            fl=getfile(_("Blog:head_selaudiofile"),getdirectory(5)+"\\",false,nil,[".mp3",".wav",".ogg",".mid",".mod",".m4a",".flac",".wma",".opus",".aac"])
            @postaudio=fl if fl!="" and fl!=nil
      end
    @form.focus
      end
  if (enter and $key[0x12]) or ((enter or space) and @form.index == 6)
@form.fields[0].finalize
if @postcomments[0]==1 and @form.fields[5].checked==0
  confirm(_("Blog:alert_deletecomments")) do
    srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&postid=#{@postid.to_s}\&delcomments=1\&searchname=#{@owner}")
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
bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str.urlenc}\&buffer=#{buf.to_s}\&edit=1\&privacy=#{@form.fields[4].index.to_s}\&comments=#{@form.fields[5].checked.to_s}\&searchname=#{@owner}")
elsif @postaudio!=nil&&@postaudio.include?($url)
    bt = srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&categoryid=#{cat}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str.urlenc}\&edit=1\&privacy=#{@form.fields[4].index.to_s}\&comments=#{@form.fields[5].checked.to_s}\&searchname=#{@owner}")
elsif @postaudio!=nil
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
      q = "POST /srv/blog_posts_mod.php?name=#{$name}\&token=#{$token}\&categoryid=#{cat.urlenc}\&postid=#{@postid.to_s}\&postname=#{@form.fields[0].text_str.urlenc}\&edit=1\&privacy=#{@form.fields[4].index.to_s}\&comments=#{@form.fields[5].checked.to_s}\&searchname=#{@owner}\&audio=1 HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: multipart/form-data; boundary=#{boundary}\r\nContent-Length: #{length}\r\n\r\n#{data}"
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
    return $scene=Scene_Main.new if $eltsuspend
    blogtemp = srvproc("blog_read","name=#{$name}\&token=#{$token}\&categoryid=#{@category}\&postid=#{@postid}\&searchname=#{@owner}&details=5")
blogtemp.each {|l| l.delete!("\r\n")}
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
  speech_wait
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
  @fields[1]=Select.new(@medias.map {|m| m['snippet']['title']},true,0,_("Blog:head_media"),true)
  end
if $name!="guest"
@fields.push(Edit.new(_("Blog:type_comment"),"MULTILINE","",true))
else
  @fields.push(nil)
  end
@fields.push(nil)
if blogowners(@owner).include?($name)
@fields.push(Button.new(_("Blog:btn_modifypost")))
else
  @fields.push(nil)
  end
@fields.push(Button.new(_("Blog:btn_back")))
@form = Form.new(@fields)
if @comments==0
  @form.fields[-3]=nil
  @form.fields[-4]=nil
  end
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
    @names[l] = blogtemp[i].delete("\r\n")
    u = true
  else
    l += 1
        @owners[l] = blogtemp[i].delete("\r\n")
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
  o=@owners[i]
  if o[0..0]=="["
    o=blogowners(o).join(", ")
    end
  sel[i] = [@names[i], o]
end
@sel = TableSelect.new([nil,_("Blog:opt_phr_author")],sel,$bloglistindex,_("Blog:head_list"))
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
  if escape or (!$keyr[0x10]&&Input.trigger?(Input::LEFT))
    $scene = Scene_Blog.new($blogsorderby+1)
  end
      if enter or (!$keyr[0x10]&&Input.trigger?(Input::RIGHT))
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
sel = (b=blogowners(@owners[@sel.index]))+[_("Blog:opt_open")]
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
  if @menu.index<b.size
    if usermenu(b[@menu.index],true) != "ALT"
          @menu = menulr(sel)
        else
          break
        end
elsif @menu.index==b.size
  $bloglistindex = @sel.index
        $scene = Scene_Blog_Main.new(@owners[@sel.index],0,$scene)
  elsif @menu.index==b.size+1
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
elsif @menu.index==b.size+2
  confirm(_("Blog:alert_markblogasread")) do
    if srvproc("blog_markasread","name=#{$name}\&token=#{$token}\&user=#{@owners[@sel.index]}")[0].to_i==0
      speech(_("Blog:info_blogmarkedasread"))
    else
      speech(_("General:error"))
    end
    speech_wait
    end
        elsif @menu.index==b.size+3
          @main = true
  elsif @menu.index==b.size+4
$scene = Scene_Main.new
end
break
end
if Input.trigger?(Input::DOWN) and @menu.index<b.size
    Input.update
  if usermenu(b[@menu.index],true) != "ALT"
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
main if @main == true
return
end
end

class Scene_Blog_Recategorize
  def initialize(searchname,scene=nil)
    @searchname=searchname
    @scene=scene
    end
  def main
    blogtemp = srvproc("blog_categories","name=#{$name}\&token=#{$token}\&searchname=#{@searchname}")
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
blogtemp = srvproc("blog_posts","name=#{$name}\&token=#{$token}\&searchname=#{@searchname}\&categoryid=0\&assignnew=1\&listcategories=1\&reverse=1")
err = blogtemp[0].to_i
if err < 0
  speech(_("General:error"))
  speech_wait
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
bt=srvproc("blog_posts_mod","name=#{$name}\&token=#{$token}\&recategorize=1\&buffer=#{buf}\&searchname=#{@searchname}")
if bt[0].to_i<0
  speech(_("General:error"))
  else
  speech(_("Blog:info_recategorized"))
end
speech_wait
break
    end
  end
$scene=Scene_Blog_Main.new(@searchname,-1,@scene)
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

class Scene_Blog_Managed
  def main
    b=srvproc("blog_managed","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
    if b[0].to_i<0
      speech(_("General:error"))
      speech_wait
      return $scene=Scene_Blog.new
    end
    @blognames=[_("Blog:opt_myblog")]
    @blogids=[$name]
    for i in 2...b.size
      if i%2==0
        @blogids.push(b[i].delete("\r\n"))
      else
        @blognames.push(b[i].delete("\r\n"))
        end
      end
    selt=@blognames+[_("Blog:opt_create")]
        @sel=Select.new(selt,true,$blogmanagedindex||0,_("Blog:head_list"))
    loop do
      loop_update
      @sel.update
      $blogmanagedindex=@sel.index
      if enter or Input.trigger?(Input::RIGHT)
        if @sel.index<@blogids.size
          $scene=Scene_Blog_Main.new(@blogids[@sel.index],0,self)
        else
          $scene=Scene_Blog_Create.new(true)
        end
        end
      $scene=Scene_Blog.new if Input.trigger?(Input::LEFT) or escape
      break if $scene!=self
      end
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
    @blogids=[$name]
    @blognames=[_("Blog:opt_myblog")]
    b=srvproc("blog_managed","name=#{$name}\&token=#{$token}\&searchname=#{$name}")
    if b[0].to_i>0
      speech(_("General:error"))
      speech_wait
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
      @form=Form.new([Select.new(@blognames,true,@blogids.index(@owner)||0,_("Blog:head_postdestination"),true), Select.new([_("Blog:opt_moveall"),_("Blog:opt_moveonly")],true,0,_("Blog:head_movetype"),true), Button.new(_("Blog:btn_movepost")), Button.new(_("General:str_cancel"))])
      loop do
        loop_update
        @form.update
        if @form.fields[2].pressed?
bl=srvproc("blog_move","name=#{$name}\&token=#{$token}\&searchname=#{@owner}\&postid=#{@post.to_s}\&destination=#{@blogids[@form.fields[0].index]}\&movetype=#{@form.fields[1].index.to_s}")
if bl[0].to_i<0
  speech(_("General:error"))
else
  speech(_("Blog:info_postmoved"))
end
speech_wait
break
          end
        break if escape or @form.fields[3].pressed?
                  end
    $scene = Scene_Blog_Posts.new(@owner,@category,@categoryselindex,@postselindex)
  end
  end
#Copyright (C) 2014-2019 Dawid Pieper