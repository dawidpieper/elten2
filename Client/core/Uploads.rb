#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Uploads
  def initialize(name="",toscene=nil)
    if name==""
      @name=$name
    else
      @name=name
    end
    @toscene = toscene
  end
  def main
    if $name=="guest"
      speech(_("General:error_guest"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
    fl = srvproc("uploads","name=#{$name}\&token=#{$token}\&searchname=#{@name}")
    if fl[0].to_i < 0
      speech(_("General:error"))
      speech_wait
      $scene = Scene_Main.new
      return
    end
    count = fl[1].to_i
    t = true
    filenames = []
    files = []
    index = 0
    for i in 2..fl.size-1
      if t == true
        filenames[index] = fl[i].delete("\r\n")
        t=false
      else
        files[index] = fl[i].delete("\r\n")
        index+=1
        t=true
      end
    end
    @sel = Select.new(filenames,true,0,s_("Uploads:head_filesofuser",{'user'=>@name}))
    @filenames=filenames
    @files=files
    loop do
      loop_update
      @sel.update
      update
      break if $scene != self
      end
    end
        def update
      menu if alt
          if escape
        if @toscene == nil
        $scene = Scene_Main.new
      else
        $scene = @toscene
        end
      end
     if enter and @sel.commandoptions.size>0
       loop_update
       d = 0
       n = File.extname(@filenames[@sel.index]).downcase
       if n==".mp3" or n==".wav" or n==".ogg" or n==".mid" or n==".flac" or n==".m4a" or n==".mp2" or n==".opus" or n==".aac" or n==".wma"
         play("menu_open")
         play("menu_background")
         menu = menulr([_("Uploads:opt_download"),_("Uploads:opt_play")])
         loop do
           loop_update
           menu.update
           if enter
             d = menu.index
             break
           end
           if escape
             d=2
             break
             end
           end
                               play("menu_close")
                               Audio.bgs_stop
         end
       case d
       when 0
         dir = getfile(_("Uploads:head_dest"),getdirectory(40)+"\\",true,"Documents")
       if dir == ""
         return
       end
       dir.chop! if dir[dir.size-1] == 92
              downloadfile($url+"uploads/"+@files[@sel.index],dir+"\\"+(@filenames[@sel.index].gsub("~","_")))
       speech(_("General:info_saved"))
       when 1
                  player($url+"uploads/"+@files[@sel.index],@filenames[@sel.index],true,true,true)
                end
                loop_update
                  end
          end
     def menu
     d = 0
     if   @filenames.size>0
     n = File.extname(@filenames[@sel.index]).downcase
   else
     n=""
     end
       play("menu_open")
         play("menu_background")
         menu = menulr([_("Uploads:opt_download"),_("Uploads:opt_play"),"Skopiuj link",_("General:str_delete"),_("Uploads:opt_add")])
       menu.disable_item(1) unless n==".mp3" or n==".wav" or n==".ogg" or n==".mid" or n==".flac" or n==".m4a" or n==".mp2" or n==".opus" or n==".aac" or n==".wma"
       menu.disable_item(3) if @name != $name
       menu.disable_item(4) if @name != $name
                  loop do
           loop_update
           menu.update
           if enter
             d = menu.index
             break
           end
           if escape or alt
             d=5
             break
             end
           end
                               play("menu_close")
                Audio.bgs_stop
                               case d
       when 0
dir = getfile(_("Uploads:head_dest"),getdirectory(40)+"\\",true,"Documents")         
       if dir == "\004ESCAPE\004"
         return
       end
       dir.chop! if dir[dir.size-1] == 92
              downloadfile($url+"uploads/"+@files[@sel.index],dir+"\\"+(@filenames[@sel.index].gsub("~","_")))
       speech(_("General:info_saved"))
       when 1
         player($url+"uploads/"+@files[@sel.index],@filenames[@sel.index],true,true,true)
      when 2
        u=$url+"downloadfile.php\?fileid="+@files[@sel.index]
        Win32API.new($eltenlib,"CopyToClipboard",'pi','i').call(u,u.size+1)
        speech(_("Uploads:info_copiedtoclip"))
        speech_wait
        when 3
        if simplequestion(s_("Uploads:alert_deletefile", {'filename'=>@filenames[@sel.index]})) == 1
          ef = srvproc("uploads_mod","name=#{$name}\&token=#{$token}\&del=1\&file=#{@files[@sel.index]}")
          if ef[0].to_i < 0
            speech(_("General:error"))
            speech_wait
          else
            speech(_("Uploads:info_deleted"))
            speech_wait
            @sel.disable_item(@sel.index)
            end
          end
       when 4
         f=getfile(_("Uploads:head_filetosend"),getdirectory(5)+"\\",false)
         if f!="" and f!=nil
           sendfile(f,true)
           main
           return
           end
          end
       loop_update
       end
     end
  
#Copyright (C) 2014-2016 Dawid Pieper