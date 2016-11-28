#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Compiler
  def main
            speech("Witaj w kreatorze kompilacji ELTEN API. Aby rozpocząć kompilację, naciśnij enter. Aby zamknąć, naciśnij escape.")
    loop do
      loop_update
      break if enter
      if escape
        $scene = Scene_Main.new
        return
        break
        end
    end
$index = 0
loop do
  r = creator($index)
  if r == -2
    $scene = Scene_Main.new
        return
        break
  end
  if r == -1
    $index -= 1
  end
  if r.is_a?(Array)
    $index += 1
    end
  if $index < 0
    main
    return
    break
    end
    end
  end
  def proc(fields)
    @fields = fields + [Button.new("Wstecz"),Button.new("Dalej"),Button.new("Anuluj")]
    @form = Form.new(@fields)
    loop do
  loop_update
  @form.update
  if escape
    return -2
    break
  end
  if (enter or space)
    if @form.index == @fields.size-3
      return -1
      break
    end 
        if @form.index == @fields.size-2
      return @form.fields
      break
    end 
        if @form.index == @fields.size-1
      return -2
      break
    end 
    if @form.fields[@form.index].is_a?(Button)
      return @form.index
      break
      end
    end
      end
  end
  def creator(index=0)
    index = 1 if index == 14
    index = 0 if index == 10
    fields = []
    $fieldvalues = [] if $fieldvalues == nil
    if $fieldvalues[index] == nil
          case index
when 0
fields = [Edit.new("Podaj lokalizację, w której chcesz zapisać gotowy projekt","",getdirectory(5) + "\\myeapiapp",true),Edit.new("Podaj nazwę projektu","","MyAPP",true),Button.new("Zaawansowane")]
when 11
  fields = [Edit.new("Podaj bibliotekę interpretera Ruby RGSS, której chcesz użyć","","RGSS104E.dll",true)]
  when 12
    fields = [Edit.new("Podaj czas ponownego rejestrowania klawiszy (wartość KeyMS)","","75",true),CheckBox.new("Uruchamiaj aplikację w trybie pełnoekranowym."),Select.new(["Liniowy","Kołowy"],true,0,"Domyślny sposób wyświetlania list wyboru",true)]
    when 13
      fields = [CheckBox.new("Wyświetlaj opis i pozycję błędów w trakcie działania aplikacji"),CheckBox.new("Pozwalaj na zamykanie aplikacji skrótem ALT+F4",1)]
      when 1
        fields = [Edit.new("Podaj kod do skompilowania","MULTILINE","begin\r\nend",true),Button.new("Importuj z pliku...")]
        when 2
speech("Proszę czekać, trwa przetwarzanie danych.")
speech_wait
$fieldvalues[1][0].finalize
$cmpscript = preproc($fieldvalues[1][0].text_str.gsub("\004LINE\004","\r\n"))
$cmpsuc = false
$cmpfin = false
Thread.new do
  begin
    eval("unless true\r\n" + $cmpscript + "\r\nend")
    $cmpsuc = true
    rescue Exception      
    ensure
    $cmpfin = true
    end
end
i = 0
until $cmpfin
  loop_update
  i+=1
if i > 400
  speech("Błąd.")
  speech_wait
  $scene = Scene_Main.new
  return
  break
  end
  end
if $cmpsuc != true
  speech("Kompilacja niemożliwa, w kodzie znaleziono błąd.")
  speech_wait
  $index -= 2
  return []
end
speech("Prekompilacja zakończona pomyślnie.")
speech_wait
$fieldvalues[0][0].finalize
fol = $fieldvalues[0][0].text_str
lib = "RGSS104E.dll"
if $fieldvalues[11] != nil
  $fieldvalues[11][0].finalize
  lib = $fieldvalues[11][0].text_str
  end
fields = [Edit.new("Informacja","READONLY|MULTILINE","Program jest gotowy.\r\nKompilacja zakończona pomyślnie.\r\nLokalizacja docelowa: #{fol}\r\nUwaga! Część błędów mogła zostać niezauważona i może pokazać się dopiero w trakcie pracy programu.\r\nW trakcie prekompilacji nie sprawdzono zgodności wybranej biblioteki: #{lib}. Jeśli wybrana biblioteka jest niepoprawna, aplikacja może nie działać poprawnie.\r\nAby wyeksportować gotowe pliki, naciśnij Dalej.\r\nAby zmienić ustawienia, naciśnij Wstecz.",true)]
when 3
  $fieldvalues[0][0].finalize
fol = $fieldvalues[0][0].text_str
$fieldvalues[0][1].finalize
name = $fieldvalues[0][1].text_str
lib = "RGSS104E.dll"
if $fieldvalues[11] != nil
  $fieldvalues[11][0].finalize
  lib = $fieldvalues[11][0].text_str
end
keyms = nil
fullscreen = nil
listtype = nil
if $fieldvalues[12] != nil
  $fieldvalues[12][0].finalize
  keyms = $fieldvalues[12][0].text_str
  fullscreen = $fieldvalues[12][1].checked.to_s
  listtype = $fieldvalues[12][2].index.to_s
end
errorfailure = nil
permitexit = nil
if $fieldvalues[13] != nil
  errorfailure = $fieldvalues[13][0].checked.to_s
  permitexit = $fieldvalues[13][1].checked.to_s
end
$fieldvalues[1][0].finalize
script = preproc($fieldvalues[1][0].text_str.gsub("\004LINE\004","\r\n"))
$db = [[Time.now.to_i,name,Zlib::Deflate.deflate(script)]]
save_data($db,fol + "\\App.dat")
fl = load_data("Data/eapi")
writefile(fol + "\\App.exe",fl[0])
writefile(fol + "\\App.elt",fl[1])
writefile(fol + "\\RGSS104E.dll",fl[2])
dr = Dir.entries(".\\Bin")
dr.delete("..")
dr.delete(".")
for i in 0..dr.size - 1
  loop_update
  if File.basename(dr[i]).downcase != ".exe"
    Win32API.new("kernel32","CopyFile","ppi","i").call(".\\" + dr[i],fol + "\\Bin\\" + dr[i],0)
    end
  end
  writeini(fol + "\\App.ini","Elten","DB","Data/api")
  writeini(fol + "\\App.ini","Elten","Library",lib)
  writeini(fol + "\\App.ini","Elten","KeyMS",keyms) if keyms.is_a?(String)
  writeini(fol + "\\App.ini","Elten","FullScreen",fullscreen) if fullscreen.is_a?(String)
  writeini(fol + "\\App.ini","Elten","ListType",listtype) if listtype.is_a?(String)
  writeini(fol + "\\App.ini","Elten","ErrorFailure",errorfailure) if errorfailure.is_a?(String)
  writeini(fol + "\\App.ini","Elten","PermitExit",permitexit) if permitexit.is_a?(String)
  Win32API.new("kernel32","CopyFile",'ppi','i').call(".\\elten.jpg",fol+"\\elten.jpg",1)
speech("Kompilacja zakończona pomyślnie.")
speech_wait
main
return -2
    end
  else
    fields = $fieldvalues[index]
    end
pr = proc(fields)
    $fieldvalues[index] = fields
    if pr.is_a?(Integer)
            if pr >= 0
              if index == 0
      index = 11
          end
    if index == 1
      fl = input_text("Podaj lokalizację pliku z kodem do zaimportowania")
      if FileTest.exists?(fl)
        $fieldvalues[1][0].settext(readfile(fl))
        speech("Importowanie zakończone.")
        speech_wait
      else
        speech("Podany plik nie istnieje.")
        speech_wait
                end
      end
    end
    end
    if index == 0
      $fieldvalues[0][0].finalize
      fol = $fieldvalues[0][0].text_str
      fol.rdelete!("\\")
      fol.rdelete!("/")
      $fieldvalues[0][0].settext(fol)
      if FileTest.exist?(fol)
        if FileTest.file?(fol) == true
          speech("W lokalizacji docelowej istnieje już plik o takiej samej nazwie, co wybrana nazwa folderu.")
          speech_wait
          index = -1
          end
        else
          Dir.mkdir(fol)
          if FileTest.exist?(fol) == false
            speech("Nie można utworzyć wybranego folderu.")
            speech_wait
            $index = -1
          else
            Dir.mkdir(fol + "\\Bin")
            end
          end
      end
    $index = index
    return pr
    end
  end
#Copyright (C) 2014-2016 Dawid Pieper