#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Files
  def initialize(startpath=false)
    @startpath=""
    @startpath=startpath if startpath != false
    @reset=false
    @clp_name=""
    @clp_type=0
        end
  def main
    @tree=FilesTree.new("Pliki",@startpath)
    loop do
      loop_update
      @tree.update
update
        break if $scene != self
      end
    end
    def update
      $scene=Scene_Main.new if escape
     menu if alt
     if enter
       file=@tree.selected(true)
              if File.directory?(file)
dialog_open
         ind=selector(["Otwórz ten folder","Dodaj wszystkie nagrania z tego folderu do playlisty","Anuluj"],"",0,2,1)
         dialog_close
         if ind == 0
           @tree.go
         elsif ind == 1
           $playlist+=audiosearcher(file)
           speech("Pliki dodane do playlisty.")
           speech_wait
           end
                  else
ext=File.extname(file).downcase
if ext==".ogg" or ext==".mp3" or ext==".wav" or ext==".mid" or ext==".flac" or ext==".mod"
  dialog_open
  ind = selector(["Odtwarzaj","Dodaj do playlisty","Ustaw jako awatar","Anuluj"],"",0,3,1)
dialog_close
case ind
when 0
  player(@tree.path+@tree.file,"Odtwarzanie: #{File.basename(@tree.path+@tree.file)}",true)
  when 1
    $playlist.push(@tree.path+@tree.file)
    when 2
      avatar_set(@tree.path+@tree.file)
      speech_wait
    end
  elsif ext == ".txt"
    form=Form.new([Edit.new(@tree.file,"MULTILINE",read(file)),Button.new("Zapisz"),Button.new("Anuluj")])
    loop do
      loop_update
      form.update
      break if escape or ((space or enter) and form.index == 2)
      if ((space or enter) and form.index == 1) or (enter and $key[0x11])
        writefile(@tree.path+@tree.file,form.fields[0].text_str.gsub("\004LINE\004","\r\n"))
        speech("Zapisano")
        break
              end
            end
            end
end
speech(@tree.file)
       end
     end 
     def audiosearcher(path)
       loop_update
           return if path == nil
  nextsearchs = []
  results = []
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
       results.push(path + "\\" + tfiles[i])
     end
     end
     if Win32API.new($eltenlib,"FilesInDir",'p','p').call(path + "\\" + tfiles[i]) != "|||" and tfiles[i] != "." and tfiles[i] != ".."
       nextsearchs.push(path + "\\" + tfiles[i])
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
def menu
  afile=@tree.path+@tree.file
  file=@tree.selected(true)
  play("menu_open")
  play("menu_background")
  sel = ["Otwórz w skojarzonej aplikacji","Wyślij na serwer","Kopiuj","Wytnij","Wklej","Usuń","Zmień nazwę","Nowy plik","Nowy folder","Wyczyść playlistę","Anuluj"]
  @menu=menulr(sel)
  loop do
    loop_update
    @menu.update
    if alt or escape
      break
    end
    if enter
      loop_update
      case @menu.index
when 0
      system("start \"#{afile}\"")
      when 1
        if sendfile(afile).is_a?(String)
          speech("Wysłano")
        else
          speech("Błąd")
        end
        speech_wait
        when 2
            if File.file?(file)
@clp_type = 1
@clp_file = afile
@clp_name = @tree.file
speech("Skopiowano.")
else
  speech("Kopiować można tylko pliki.")
end
speech_wait
when 3
              if File.file?(file)
@clp_type = 2
@clp_file = afile
@clp_name = @tree.file
speech("Wycięto.")
else
  speech("Wycinać można tylko pliki.")
end
speech_wait
when 4
  if @clp_type == 1
Win32API.new("kernel32","CopyFile",'ppi','i').call(utf8(@clp_file),utf8(@tree.path + @clp_name),0)
speech("Wklejono.")
end
if @clp_type == 0
speech("Brak plików w schowku")
end
if @clp_type == 2
Win32API.new("kernel32","MoveFile",'pp','i').call(utf8(@clp_file),utf8(@tree.path + @clp_name))
@clp_type = 0
@reset = true
speech("Wklejono.")
end
speech_wait  
when 5
  if simplequestion("Czy jesteś pewien, że chcesz usunąć #{@tree.file}?") == 1
    if File.directory?(afile)
      deldir(afile)
    else
      File.delete(afile)
    end
    speech("Usunięto.")
    speech_wait
  end
  when 6
    name=""
    while name==""
    name=input_text("Nowa nazwa","ACCEPTESCAPE",@tree.file)
    end
    if name != "\004ESCAPE\004"
    Win32API.new("kernel32","MoveFile",'pp','i').call(utf8(file),utf8(@tree.path+name))
    speech("Nazwa została zmieniona.")
    speech_wait
  end
  when 7
    name=""
    while name == ""
    name=input_text("Podaj nazwę pliku","ACCEPTESCAPE","text.txt")
    end
    if name != "\004ESCAPE\004"
      writefile(@tree.path+name,"")
      speech("Plik został utworzony.")
      speech_wait
      end
    when 8
name=""
while name==""
      name=input_text("Podaj nazwę folderu","ACCEPTESCAPE","folder")
      end
    if name != "\004ESCAPE\004"
      Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8(@tree.path+name),nil)
      speech("Folder został utworzony.")
      speech_wait
    end
    when 9
      $playlist=[]
      $playlistindex = 0
      when 10
        $scene=Scene_Main.new
    end
    @tree.refresh
    break
    end
  end
  play("menu_close")
Audio.bgs_stop
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper