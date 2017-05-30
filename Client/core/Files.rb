#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Files
  def initialize(startpath=false)
    @startpath = startpath
    @reset = false
    @clp_name = ""
    @clp_type = 0
    @clp_file = ""
    @pathes_a = []
    @pathes_b = []
    @sd = 0
    if startpath != false
      startpath.gsub("\\") do
      @sd += 1
    end
    startpath.gsub("/") do
      @sd += 1
      end
      end
    @disks = []
    @letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    for i in 0..@letters.size - 1
      if FileTest.exist?(@letters[i] + ":")
        @disks.push(@letters[i] + ":")
        end
      end
  end
  def main(disk="")
        if @startpath != false
      sp = @startpath
      @startpath = false      
      files(sp)
      return
      end
      index=0
      index= @disks.find_index(disk) if disk!=""
      @sel = Select.new(@disks,true,index,"")
    loop do
loop_update
      @sel.update
      st_update
      if $scene != self
        break
      end
      end
    end
    def st_update
      if escape
                $scene = Scene_Main.new
      end
      if enter or Input.trigger?(Input::RIGHT)
                if Win32API.new($eltenlib,"FilesInDir",'p','p').call(@disks[@sel.index]) != "|||"
        @sd = 1
        files(@disks[@sel.index])
      else
        speech("Ten dysk nie jest w tej chwili dostępny.")
                end
        end
      end
      def files(path)
                path += "\\"
        for i in 0..path.size - 1
          path.gsub!("\\\\") do
            "\\"
            end
          end
          $path = path
        temp = Win32API.new($eltenlib,"FilesInDir",'p','p').call(path)
        temp = temp.to_s
        tmp = []
        l = 0
        tmp[l] = ""
        for i in 0..temp.size - 1
          if temp[i..i] != "\n"
            tmp[l] += temp[i..i]
          else
            l += 1
            tmp[l] = ""
            end
          end
          @files = Dir.entries(path)
        @files.delete(".")
        @files.delete("..")
        for i in 0..@files.size-1
          @files[i]=utf8(@files[i])
        end
        @fileshorts = []
        for fi in 0..@files.size-1
          f = @files[fi]+""
          b = f+""
          for i in 0..f.size-1
            f[i]=0 if f[i]>127
          end
          if f == b
            @fileshorts.push(b)
            else
          for i in 0..f.size-1
            f[i]=0 if i>6
          end
          f.delete!("\0")
          s = true
          i = 0
          while s
            i += 1
            if @fileshorts.include?(f+"~"+i.to_s) == false
              a = ""
              if FileTest.exists?(path+"\\"+f+"~"+i.to_s) == false
                a += File.extname(b)
                end
              @fileshorts.push(f+"~"+i.to_s+a)
              s = false
              end
          end
        end
        end
                                        index = -1
        for i in 0..@pathes_a.size - 1
          if @pathes_a[i] == $path
            index = @pathes_b[i]
            break
          end
          end
        $speech_to_utf = false
        @sel = Select.new(@files)
        @sel.index = index if index >= 0
        speech_stop
        speech(@files[@sel.index])
        @path = path
        $speech_to_utf = true
        loop do
          loop_update
          $speech_to_utf = false
          @sel.update
          $speech_to_utf = true
          update
          if @reset == true
                     suc = false
                 for i in 0..@pathes_a.size - 1
          if @pathes_a[i] == $path
            suc = true
            @pathes_b[i] = @sel.index
            break
            end
          end
          if suc == false
                        @pathes_a.push($path)
            @pathes_b.push(@sel.index)
            end
            speech_wait
            @reset = false
            files($path)
            end
          if $scene != self
            break
          end
          end
        end
        def update
          path = $pat
                if alt
                menu
        end
          if escape
                        $scene = Scene_Main.new
end
     if enter or Input.trigger?(Input::RIGHT)
              @path = "C:" if @path == nil
       @files = ["..","..","..",".."] if @files == nil
       @sel = Select.new(["..","..","..",".."]) if @sel == nil
       if @files != nil and @files[0] == nil
         @files[0] = ".."
       end
       flindex = @fileshorts[@sel.index]
                                          if File.directory?(nm = @path + flindex) == true
                  indx = 0
         if enter
           sel = SelectLR.new(["Otwórz ten folder","Dodaj wszystkie nagrania z tego folderu do playlisty","Anuluj"])
           loop do
             loop_update
             sel.update
             if enter
               indx = sel.index
               break
               end
             if escape
               indx = 0
               end
             end
           end
                    case indx
         when 0
           suc = false
                 for i in 0..@pathes_a.size - 1
          if @pathes_a[i] == $path
            suc = true
            @pathes_b[i] = @sel.index
            break
            end
          end
          if suc == false
                        @pathes_a.push($path)
            @pathes_b.push(@sel.index)
            end
         @sd += 1
         files(@path + "\\" + flindex)
         return
         when 1
           @audiosearchresults = []
           nm = futf8(nm).to_s
           nm.chop! if nm[nm.size-1] == "\\"
                      audiosearcher(nm)
           $playlist += @audiosearchresults
           speech("Pliki dodane do playlisty: #{@audiosearchresults.size.to_s}")
           @audiosearchresults = []
           when 2
         end
       else
                  nm = futf8(nm).to_s
nm.gsub!("\\\\","\\")
         ext = File.extname(nm)
if ext == ".OGG" or ext == ".ogg" or ext == ".mp3" or ext == ".MP3" or ext == ".wav" or ext == ".WAV" or ext == ".mid" or ext == ".MID" or ext == ".m4a" or ext == ".M4A" or ext == ".avi" or ext == ".AVI"
  sel = SelectLR.new(["Odtwarzaj","Dodaj do playlisty","Ustaw jako awatar","Anuluj"])
    loop do
    loop_update
    sel.update
    break if enter or escape
    end
  if enter
    case sel.index
    when 0
    player(@path+@files[@sel.index],"Odtwarzanie: #{File.basename(@files[@sel.index])}",true)
  if (wnd = Win32API.new("user32","GetActiveWindow",'v','i').call()) != $wnd
    cls = "\0" * 256
    Win32API.new("user32","GetClassName",'ipi','i').call(wnd,cls,cls.size)
    cls.delete!("\0")
$mvwcls = cls
    end
  Win32API.new("user32","SetFocus",'i','i').call($wnd)
when 1
  $playlist.push(nm)
speech("Plik #{nm} został dodany do playlisty.")
when 2
    avatar_set(nm)
when 3
    end
  end
end
if ext.downcase == ".txt"
text = futf8(readfile(nm))
play("edit_space")
speech(text)
end
if ext.downcase == ".eapi"
scr=readfile(nm)
if simplequestion("Czy chcesz załadować ten plik skryptu EltenAPI? Nienależy uruchamiać skryptów pochodzących z niezaufanych źródeł.") == 1
  eval(futf8(scr))
  speech_wait
  speech("Interpretacja skryptu zakończona.")
end
end
if ext.downcase == ".rb"
scr=readfile(nm)
if simplequestion("Czy chcesz załadować ten plik skryptu Ruby? Skrypty Ruby mogą być niekompatybilne z EltenAPI. Czy chcesz spróbować mimo to? Nienależy uruchamiać skryptów pochodzących z niezaufanych źródeł.") == 1
  eval(scr)
  end
end
         end
       end
       if $key[115] == true
         Audio.me_stop
         speech_stop
         end
       if Input.trigger?(Input::LEFT) and @sd > 1
                 for i in 0..@pathes_a.size - 1
          if @pathes_a[i] == $path
            @pathes_b[i] = 0
            break
            end
          end
                  @sd -= 1
         files(File.dirname(@path))
         return
       elsif @sd <= 1 and Input.trigger?(Input::LEFT)
                 for i in 0..@pathes_a.size - 1
          if @pathes_a[i] == $path
            @pathes_b[i] = 0
            break
            end
          end
         main(@path[0..1])
         return
         end
       end
       def menu
play("menu_open")
play("menu_background")
sel = ["Otwórz w skojarzonej aplikacji","Wyślij na serwer","Kopiuj","Wytnij","Wklej","Usuń","Nowy folder","Wyczyść playlistę","Anuluj"]
@menu = SelectLR.new(sel)
loop do
loop_update
@menu.update
if alt or escape
break
end
if enter
Input.update
case @menu.index
when 0
system(cmd = "start #{$path}#{@files[@sel.index]}")
when 1
 cod = sendfile(@path+futf8(@files[@sel.index]))
 if cod.is_a?(String)
   speech("Wysłano.")
   speech_wait
   end
when 2
  if Win32API.new($eltenlib,"FilesInDir",'p','p').call(nm = @path + "\\" + @files[@sel.index]) == "|||"
@clp_type = 1
@clp_file = $path + @files[@sel.index]
@clp_name = @files[@sel.index]
speech("Skopiowano.")
else
  speech("Kopiować można tylko pliki.")
end
when 3
  if Win32API.new($eltenlib,"FilesInDir",'p','p').call(nm = @path + "\\" + @files[@sel.index]) == "|||"
@clp_type = 2
@clp_file = $path + @files[@sel.index]
@clp_name = @files[@sel.index]
speech("Wycięto")
else
  speech("Wycinać można tylko pliki.")
end
when 4
if @clp_type == 1
Win32API.new("kernel32","CopyFile",'ppi','i').call(@clp_file,$path + @clp_name,0)
speech("Wklejono.")
@reset = true
end
if @clp_type == 0
speech("Brak plików w schowku")
end
if @clp_type == 2
Win32API.new("kernel32","MoveFile",'pp','i').call(@clp_file,$path + @clp_name)
@clp_file = ""
@clp_type = 0
@clp_name = ""
@reset = true
speech("Wklejono.")
end
when 5
speech("Czy jesteś pewien, że chcesz usunąć ten obiekt?")
speech_wait
@q = SelectLR.new(["Nie","Tak"])
loop do
loop_update
@q.update
if enter
if @q.index == 1
Input.update
  if Win32API.new($eltenlib,"FilesInDir",'p','p').call(nm = @path + "\\" + @files[@sel.index]) == "|||"
File.delete($path + @files[@sel.index])
@reset = true
speech("Usunięto.")
speech_wait
else
    if Win32API.new($eltenlib,"FilesInDir",'p','p').call(nm = @path + "\\" + @files[@sel.index]) == ".\n..\n"
      Dir.delete(@path + @files[@sel.index])
      speech("Usunięto.")
      speech_wait
      @reset = true
    else
      speech("Ten folder nie jest pusty.")
    end
end
end
break
end
end
when 6
  name = ""
  while name == ""
  name = input_text("Podaj nazwę tworzonego katalogu")
end
name.delete!("\\")
name.delete!("/")
name.delete!(":")
name.delete!("?")
name.delete!("*")
Win32API.new("kernel32","CreateDirectory",'pp','i').call($path + name,nil)
speech("Wykonano.")
speech_wait
@reset = true
when 7
  $playlist = []
  $playlistindex = 0
  speech("Playlista wyczyszczona")
when 8
$scene = Scene_Main.new
end
break
end
end
play("menu_close")
Audio.bgs_stop
end
def audiosearcher(patch)
  loop_update
  return if patch == nil
  nextsearchs = []
  @audiosearchresults = [] if @audiosearchresults == nil
 temp = Win32API.new($eltenlib,"FilesInDir",'p','p').call(patch)
        temp = temp.to_s
        tmp = []
        l = 0
        tmp[l] = ""
        for i in 0..temp.size - 1
          if temp[i..i] != "\n"
            tmp[l] += temp[i..i]
          else
            l += 1
            tmp[l] = ""
            end
          end
        tfiles = []
        for i in 0..tmp.size - 1
if tmp[i].size > 0
  tmp[i].delete!("\n")
  tfiles.push(tmp[i])
  end
          end
        tfiles.delete(".")
        tfiles.delete("..") 
        tfiles = [] if tfiles == nil
        exts = [".mp3",".ogg",".wav",".mid",".m4a",".avi"]
        for i in 0..tfiles.size - 1
   if tfiles[i] != nil
          for j in 0..exts.size - 1
     if File.extname(tfiles[i].downcase) == exts[j]
       @audiosearchresults.push(patch + "\\" + tfiles[i])
     end
     end
     if Win32API.new($eltenlib,"FilesInDir",'p','p').call(patch + "\\" + tfiles[i]) != "|||" and tfiles[i] != "." and tfiles[i] != ".."
       nextsearchs.push(patch + "\\" + tfiles[i])
            end
   end
 end
  for i in 0..nextsearchs.size-1
    ns = nextsearchs[i]
    nextsearchs[i] = nil
    audiosearcher(ns)
end
end
  end
#Copyright (C) 2014-2016 Dawid Pieper