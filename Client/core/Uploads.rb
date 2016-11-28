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
    fl = srvproc("uploads","name=#{$name}\&token=#{$token}\&searchname=#{@name}")
    if fl[0].to_i < 0
      speech("Błąd")
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
    @sel = Select.new(filenames,true,0,"Pliki użytkownika #{@name}")
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
     if enter
       loop_update
       d = 0
       n = File.extname(@filenames[@sel.index]).downcase
       if n==".mp3" or n==".wav" or n==".ogg" or n==".mid" or n==".flac" or n==".m4a" or n==".mp2"
         play("menu_open")
         play("menu_background")
         menu = SelectLR.new(["Pobierz","Odtwarzaj"])
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
           $dialogvoice.pause
                    play("menu_close")
         end
       case d
       when 0
         dir = input_text("Podaj ścieżkę, w której chcesz zapisać ten plik","ACCEPTESCAPE",getdirectory(5))
       if dir == "\004ESCAPE\004"
         return
       end
       dir.chop! if dir[dir.size-1] == 92
       speech("Pobieranie...")
       download($url+"uploads/"+@files[@sel.index],dir+"\\"+(@filenames[@sel.index].gsub("~","_")))
       speech("Zapisano.")
       when 1
         loop_update
         dialog_open
      speech("Plik: #{@filenames[@sel.index]}")
      speech_wait
            stream = AudioFile.new($url+"uploads/"+@files[@sel.index])
stream.play            
      loop do
        loop_update
        break if enter or escape
      end
      stream.close
      dialog_close
       end
     end
          end
     def menu
     d = 0
       n = File.extname(@filenames[@sel.index]).downcase
       play("menu_open")
         play("menu_background")
         menu = SelectLR.new(["Pobierz","Odtwarzaj","Usuń"])
       menu.disable_item(1) unless n==".mp3" or n==".wav" or n==".ogg" or n==".mid" or n==".flac" or n==".m4a" or n==".mp2"
       menu.disable_item(2) if @name != $name
                  loop do
           loop_update
           menu.update
           if enter
             d = menu.index
             break
           end
           if escape or alt
             d=3
             break
             end
           end
           $dialogvoice.pause
                    play("menu_close")
                case d
       when 0
         dir = input_text("Podaj ścieżkę, w której chcesz zapisać ten plik","ACCEPTESCAPE",getdirectory(5))
       if dir == "\004ESCAPE\004"
         return
       end
       dir.chop! if dir[dir.size-1] == 92
       speech("Pobieranie...")
       download($url+"uploads/"+@files[@sel.index],dir+"\\"+(@filenames[@sel.index].gsub("~","_")))
       speech("Zapisano.")
       when 1
         loop_update
         dialog_open
      speech("Plik: #{@filenames[@sel.index]}")
      speech_wait
            stream = AudioFile.new($url+"uploads/"+@files[@sel.index])
stream.play            
      loop do
        loop_update
        break if enter or escape
      end
      stream.close
      dialog_close
      when 2
        if simplequestion("Czy jesteś pewien, że chcesz usunąć plik #{@filenames[@sel.index]}?")
          ef = srvproc("uploads_mod","name=#{$name}\&token=#{$token}\&del=1\&file=#{@files[@sel.index]}")
          if ef[0].to_i < 0
            speech("Błąd")
            speech_wait
          else
            speech("Usunięto")
            speech_wait
            @sel.disable_item(@sel.index)
            end
          end
       end
       end
     end
  
#Copyright (C) 2014-2016 Dawid Pieper