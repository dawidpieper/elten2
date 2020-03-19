#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Files
  def initialize(startpath=false)
    @startpath=""
    @startpath=startpath if startpath != false
    @reset=false
    @clp_name=""
    @clp_type=0
        end
  def main
            @tree=FilesTree.new(p_("Files", "Files"),@startpath,false,false,nil,nil,true)
            @tree.bind_context{|menu|context(menu)}
    loop do
      loop_update
      @tree.update
update
        break if $scene != self
      end
    if @played!=nil
       @played.close
       @played=nil
       end
      end
    def update
                
      $scene=Scene_Main.new if escape
     if $key[0x10] and @played!=nil
       if arrow_right(true)
         @played.position+=1
       elsif arrow_left(true)
                  if @played.position<1
         @played.position=0
       else
         @played.position-=1
       end
     elsif arrow_up
       @played.volume+=0.05 if @played.volume<1
       elsif arrow_down
       @played.volume-=0.05 if @played.volume>0.05
         end
       end
     if space
       if $key[0x10]==false
       file=@tree.selected(true)
       ext=File.extname(file).downcase
       if @tree.filetype==1
                  if @played!=nil
                           @played.close
       @played=nil
                 end
     if @playedfile != @tree.selected
            begin
                     @played=Bass::Sound.new(@tree.selected(true),1)
                     if @played.cls!=nil
                     @playedfile=@tree.selected
       @played.play
     @playedpause=false
   else
     @played=nil
     end
     rescue Exception
       begin
                  @played=Bass::Sound.new(@tree.selected(true),0)
         @playedfile=@tree.selected
         @played.play
     @playedpause=false
       rescue Exception
         alert(p_("Files", "This file cannot be played."))
         end
       end
        else
     @playedfile=nil
   end
                 end
                                elsif @played!=nil
                 if @playedpause==false
                                  @played.pause
                                  @playedpause=true
                                else @playedpause==true
                                  @played.play
                                  @playedpause=false
                                  end
                 end
     end
                 if $key[115] and @played!=nil
       @played.close
       @played=nil
     end
     if $key[0x2e]
         if confirm(p_("Files", "Do you really want to delete %{filename}?")%{'filename'=>@tree.file}) == 1
    if File.directory?(@tree.selected(false))
      deldir(@tree.selected(false))
alert(p_("Files", "Deleted"))
      else
      begin
      File.delete(@tree.selected(false))
    rescue Exception
      alert(p_("Files", "The file cannot be deleted, access denied."))
      end
    end
        @tree.refresh
        play("edit_delete")                
      end
       end
     if $key[0x11] and $key[0x43]
              @clp_type = 1
@clp_file = @tree.selected
@clp_name = @tree.file
alert(p_("Files", "copied"))
end
if $key[0x11] and $key[0x44]
  if File.directory?(@tree.selected(false))
  o=countsub(@tree.selected(false))
  speech(o[1].to_s+" "+o[0].to_s)
else
  ext=File.extname(@tree.selected)
  if @tree.filetype==1
    t=Bass::Sound.new(@tree.selected)
    d=t.length
    t.close
    if d<360000
        h=d/3600
        m=d/60%60
  s=d%60
  speech(sprintf("%02d:%02d:%02d",h,m,s))
  end          
  end
  end
  end
if $key[0x11] and $key[0x49]
  size=getsize(@tree.selected(false))
  unit="B"
  if size>1024
    size=size.to_f/1024.0
    unit="KB"
  end
  if size>1024
    size=size.to_f/1024.0
    unit="MB"
  end
  if size>1024
    size=size.to_f/1024.0
    unit="GB"
  end
  if size>1024
    size=size.to_f/1024.0
    unit="TB"
  end
      size=(size*100).round.to_f/100.0
      size=size.to_i if size.to_i==size.to_f
      size=0 if size<0
  speech(size.to_s+unit)
  end
     if $key[0x11] and $key[0x4f]
       run("explorer #{@tree.selected}")
            end
          if $key[0x11] and $key[0x56] and @clp_type>0
                paste
@tree.refresh
end
     if $key[0x11] and $key[0x58]
                     @clp_type = 2
@clp_file = @tree.selected
@clp_name = @tree.file
alert(p_("Files", "Cut out"))
end
       if enter
       file=@tree.selected(true)
              if File.directory?(file)
dialog_open
         ind=selector([p_("Files", "Open this directory"),p_("Files", "Add all audio files in this directory to playlist"),_("Cancel")],"",0,2,1)
         dialog_close
         if ind == 0
           @tree.go
         elsif ind == 1
           waiting
           aus=audiosearcher(file)
           waiting_end
                      speech(p_("Files", "Files added to playlist: %{count}.")%{'count'=>aus.size.to_s})
                      $playlist+=aus
           speech_wait
           end
                  else
if @played!=nil
                           @played.close
       @played=nil
                 end
                    ext=File.extname(file).downcase
if @tree.filetype==1
audiomenu
  elsif @tree.filetype==2
textmenu
elsif @tree.filetype==4
documentmenu            
elsif @tree.filetype==5
  confirm(p_("Files", " Do you want to run this Elten API script? Scripts coming from unknown sources can  harm your computer or give access to your account to unauthorised persons.  Continue if you trust a source this script comes from.")) do
    eval(readfile(@tree.selected),nil,@tree.file)
    @tree.focus
    end
elsif @tree.filetype==3
            dialog_open
            ind=selector([p_("Files", "Extract"),_("Cancel")],"",0,1,1)
            dialog_close
            if ind == 0
                            decompress("#{@tree.selected}","#{@tree.path}*")
              alert(p_("Files", "Unpacked."))
              @tree.refresh
              speech_wait
              end
                                        end
end
speech(@tree.file)
       end
     end 
     def audiosearcher(path)
       @audiosearcherlastupdate=0 if @audiosearcherlastupdate==nil
       if @audiosearcherlastupdate<Time.now.to_i-5
       loop_update
       @audiosearcherlastupdate=Time.now.to_i
       end
           return if path == nil
  nextsearchs = []
  results = []
  begin      
  files=Dir.entries(path)
rescue Exception
  return []
  end
  files.delete("..")
  files.delete(".")
    exts = [".mp3",".ogg",".wav",".mid",".wma",".opus",".m4a",".aac",".flac"]
        for f in files
          d=path+"\\"+f
          if File.directory?(d)
                        nextsearchs.push(d)
            else
                 if exts.include?(File.extname(f.downcase))
              results.push(d)
     end
             end
   end
        for i in 0..nextsearchs.size-1
    ns = nextsearchs[i]
    nextsearchs[i] = nil
    results+=audiosearcher(ns)
  end
  return results
end
def paste
  if @clp_type>0
  if File.file?(@clp_file)
  if @clp_type==1
copyfile(@clp_file,@tree.path + @clp_name)
elsif @clp_type==2
Win32API.new("kernel32","MoveFileW",'pp','i').call(unicode(@clp_file),unicode(@tree.path + @clp_name))
end
else
  copydir(@clp_file,@tree.path + @clp_name)
if @clp_type==2
  deldir(@clp_file)
  end
end
alert(p_("Files", "pasted"))
else
  alert(p_("Files", "The clipboard is empty"))
end
end
def countsub(dir)
  return [0,0] if dir==nil
  ds=0
  fs=0
  fl=Dir.entries(dir)
  fl.delete(".")
  fl.delete("..")
  for f in fl
    if f!=nil
    if File.file?(dir+"\\"+f)
      fs+=1
    else
      ds+=1
      o=countsub(dir+"\\"+f)
      ds+=o[0]
      fs+=o[1]
    end
    end
  end
  return [ds,fs]
  end
def context(menu)
    if @played!=nil
       @played.close
       @played=nil
     end
     ext=""
if @tree.file!=nil
       afile=@tree.path+@tree.file
  file=@tree.selected(true)
  ext=File.extname(file).downcase
  end
  menu.submenu(p_("Files", "File")) {|m|
  m.option(p_("Files", "Open in an associated application")) {
        run("explorer \"#{afile}\"")
  }
  if ext==".rar" or ext==".zip" or ext==".7z"
  m.option(p_("Files", "Extract")) {
      decompress(@tree.selected,@tree.path+"*")
              alert(p_("Files", "Unpacked."))
  }
else
  m.option(p_("Files", "Compress")) {
            f=selector(["zip","rar","7zip"],p_("Files", "Select archive format"),0,-1,1)
      if f>=0
        dest=file
        case f
        when 0
          dest+=".zip"
          when 1
            dest+=".rar"
            when 2
              dest+=".7z"
        end
        compress(file,dest)
        alert(p_("Files", "Compressed"))
        end
  }
end
  if File.directory?(@tree.selected(true))
m.option(p_("Files", "Add all audio files in this directory to playlist")) {
        if File.directory?(@tree.selected(true))
          waiting
          aus=audiosearcher(file)
          waiting_end
           speech(p_("Files", "Files added to playlist: %{count}.")%{'count'=>aus.size.to_s})
           $playlist+=aus
           speech_wait
        end
}
end
  m.option(p_("Files", "Rename")) {
      name=""
    while name==""
    name=input_text(p_("Files", "A new file name"),"ACCEPTESCAPE",@tree.file)
    end
    if name != "\004ESCAPE\004"
    Win32API.new("kernel32","MoveFileW",'pp','i').call(unicode(file),unicode(@tree.path+name))
    alert(p_("Files", "The file name has been changed."))
  end
  }
  m.option(_("Delete")) {
    confirm(p_("Files", "Do you really want to delete %{filename}?")%{'filename'=>@tree.file}) {
    if File.directory?(afile)
      deldir(afile)
    else
      File.delete(afile)
    end
    alert(p_("Files", "Deleted"))
}
  }
    }
    menu.submenu(p_("Files", "Clipboard")) {|m|
    m.option(p_("Files", "Copy")) {
    @clp_type = 1
@clp_file = afile
@clp_name = @tree.file
alert(p_("Files", "Copied"))
    }
    m.option(p_("Files", "Cut")) {
                  @clp_type = 2
@clp_file = afile
@clp_name = @tree.file
alert(p_("Files", "Cut out"))
    }
    m.option(p_("Files", "Paste")) {
      paste
  @tree.refresh
    }
    }
  menu.submenu(p_("Files", "Create")) {|m|
  m.option(p_("Files", "New folder")) {
    name=""
while name==""
      name=input_text(p_("Files", "Enter a folder name"),"ACCEPTESCAPE","")
      end
    if name != "\004ESCAPE\004"
      Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode(@tree.path+name),nil)
      alert(p_("Files", "The folder has been created."))
    end
  }
  m.option(p_("Files", "New text file")) {
    pr=".txt"
  name=""
    while name == ""
    name=input_text(p_("Files", "Enter a file name"),"ACCEPTESCAPE",pr)
  end
  if name!="\004ESCAPE\004"            
  writefile(@tree.path+name,"")
        alert(p_("Files", "The file has been created."))
  end
  }
  m.option(p_("Files", "New record")) {
          pr=".wav"
        name=""
    while name == ""
    name=input_text(p_("Files", "Enter a file name"),"ACCEPTESCAPE",pr)
    end
    if name != "\004ESCAPE\004"
            form=Form.new([Button.new(p_("Files", "Record")),Button.new(_("Cancel"))])
     rec=0
     loop do
       loop_update
       form.update
       if ((space or enter) and form.index == 0)
         if rec == 0
           rec = 1
                      @r=Recorder.start(@tree.path+name)
                      play("recording_start")
         form.fields[0]=Button.new(_("Save"))
           elsif rec == 1
           @r.stop
           play("recording_stop")
           alert(_("Saved"))
           break
                      end
         end
       if escape or ((enter or space) and form.index==1)
         @r.stop if rec==1
         break
         end
       end
            alert(p_("Files", "The file has been created."))
        end
  }
  }
  menu.option(p_("Files", "Delete the playlist")) {
        $playlist=[]
      $playlistindex = 0
      alert(p_("Files", "Playlist cleared"))
  }
      if @tree.filetype==1
        menu.customoption(p_("Files", "Audio")) {audiomenu(true)}
        end
  if @tree.filetype==2
        menu.customoption(p_("Files", "Text")) {textmenu(true)}
        end
  if @tree.filetype==4
        menu.customoption(p_("Files", "Document")) {documentmenu(true)}
        end
end
def audiomenu(submenu=false)
  dialog_open if submenu==false
  sl=[p_("Files", "Play"),p_("Files", "Add to playlist"),p_("Files", "convert")]
  sl.push(_("Cancel")) if submenu==false
  ck=nil
  ck=0x25 if submenu
    ind = selector(sl,"",0,-1,(submenu)?(0):(1),true,Input::LEFT)
dialog_close if submenu==false
case ind
when 0
  player(@tree.selected(true),p_("Files", "Playing: %{file}")%{'file'=>File.basename(@tree.path+@tree.file)},true)
  when 1
    $playlist.push(@tree.path+@tree.file)
      when 2
formats=[".mp3",".ogg",".wav",".flac",".wma",".aac",".m4a",".opus"]
f=selector(formats,p_("Files", "Convert to"),0,-1)
if f!=-1
format=formats[f]
extra=""
if format!=".wav" and format!=".flac"
  bts=[48,64,96,128,160,192,224,256,320]
  btrs=[]
  for b in bts
    btrs.push(b.to_s+"KBPS")
  end
  bt=selector(btrs,p_("Files", "Sound quality"),5)
  extra="-b:a #{bts[bt]}K "
    end
speak(p_("Files", "Please wait, the file is being converted."))
waiting
c="bin/ffmpeg -y -i \"#{@tree.selected}\" #{extra}\"#{@tree.selected.gsub(File.extname(@tree.selected),format)}\""
executeprocess(c,true)
speech_wait
waiting_end
alert(p_("Files", "Converted."))
speech_wait
@tree.refresh
end
end
return (ind==-1)?false:true
end
def textmenu(submenu=false)
  file=@tree.selected
        r=readfile(file)
            dialog_open if submenu==false
      sl=[p_("Files", "Edit"),p_("Files", "Read to file")]
      sl.push(_("Cancel")) if submenu==false
        ck=nil
  ck=0x25 if submenu
          ind=selector(sl,"",0,-1,(submenu)?(0):(1),true,ck)
    dialog_close if submenu==false
    Audio.bgs_stop if submenu and ind != -1
    case ind
    when 0
    form=Form.new([Edit.new(@tree.file,"MULTILINE",r),Button.new(_("Save")),Button.new(_("Cancel"))])
    loop do
      loop_update
      form.update
      break if escape or ((space or enter) and form.index == 2)
      if ((space or enter) and form.index == 1) or (enter and $key[0x11])
        writefile(@tree.path+@tree.file,form.fields[0].text_str.gsub("\004LINE\004","\r\n"))
        alert(_("Saved"))
        break
              end
            end
            when 1
              speechtofile("",r,File.basename(file))
            end
            return (ind==-1)?false:true
            end
          def documentmenu(submenu=false)
      dialog_open if submenu==false
      sl=[p_("Files", "Read"),p_("Files", "Read to file")]
      sl.push(_("Cancel")) if submenu==false
        ck=nil
  ck=0x25 if submenu
          ind=selector(sl,"",0,-1,(submenu)?(0):(1),true,ck)
    dialog_close if submenu==false
    text=""
    fid=0
    fid="tx"+rand(36**8).to_s(36)+""
    if ind<2 and ind>-1
      speak(p_("Files", "Processing..."))
      waiting
      convert_book(@tree.selected, $tempdir+"\\#{fid}.txt")
      return if !FileTest.exists?($tempdir+"\\"+fid+".txt")
            text=readfile($tempdir+"\\"+fid+".txt")
            waiting_end
      end
    case ind
    when 0
          File.delete($tempdir+"\\"+fid+".txt")
          form=Form.new([Edit.new(@tree.file,"MULTILINE|READONLY",text),Button.new(_("Exit"))])
    loop do
      loop_update
      form.update
      break if escape or ((space or enter) and form.index == 1)
                  end
            when 1
              speechtofile($tempdir+"\\#{fid}.txt","",File.basename(@tree.file).gsub(File.extname(@tree.file),""))
                          end
            File.delete($tempdir+"\\"+fid+".txt") if FileTest.exists?($tempdir+"\\"+fid+".txt")
                          return (ind==-1)?false:true
            end
          

end