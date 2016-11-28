#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Languages
  def main
    speech("Zarządzanie językami")
    speech_wait
    langstm = Win32API.new($eltenlib,"FilesInDir",'p','p').call($langdata)
langst = []
c = 0
langst[c] = ""
for i in 0..imax = langstm.size - 1
  langst[c] += langstm[i..i]
  if langstm[i..i] == "\n"
    c += 1
    langst[c] = "" if imax != i
    end
  end
  langs = []
  for i in 0..langst.size - 1
    langst[i].delete!("\n")
    langs.push(langst[i]) if langst[i] != "." and langst[i] != ".."
    end
@langs_f = []
for i in 0..langs.size - 1
if File.extname($langdata + "\\" + langs[i]) == ".elg" or File.extname($langdata + "\\" + langs[i]) == ".ELG" or File.extname($langdata + "\\" + langs[i]) == ".ELg" or File.extname($langdata + "\\" + langs[i]) == ".Elg" or File.extname($langdata + "\\" + langs[i]) == ".ElG"
  @langs_f.push(langs[i])
  end
end
@langs = []
for i in 0..@langs_f.size - 1
  tmp = readlines($langdata + "\\" + @langs_f[i])
  tmp = [] if tmp == nil
  tmp[2] = "" if tmp[2] == nil
  @langs[i] = tmp[2].sub("(UTF)","")
    @langs[i] = "" if @langs[i] == nil
  @langs[i].delete!("\n")
end
for i in 0..@langs.size - 1
  if @langs[i] == nil
    @langs.delete_at(i)
  elsif @langs[i].size <= 0
    @langs.delete_at(i)
    end
  end
sel = ["POLSKI"]
sel += @langs
sel.push("Pobierz tłumaczenia z serwera")
@selt = sel
@sel = Select.new(sel)
loop do
  loop_update
  @sel.update
  update
  if $scene != self
    break
    end
  end
end
def update
  if escape
        if $token != "" and $token != nil and $name != "" and $name != nil
    $scene = Scene_Main.new
  else
    $scene = Scene_Loading.new
    end
  end
if enter
  play("right")
  if @sel.index < @selt.size - 1 and @sel.index > 0
lng = @langs_f[@sel.index - 1]
lng = lng.sub(".elg","")
                   iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Language','Language',lng,$configdata + "\\language.ini") 
speech("Zapisano.")
$scene = Scene_Loading.new
elsif @sel.index == 0
                   iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Language','Language',"PL_PL",$configdata + "\\language.ini") 
  $scene = Scene_Loading.new
elsif @sel.index == @selt.size - 1
  langtemp = srvproc("languages","")
    err = langtemp[0].to_i
  case err
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
    $scene = Scene_Main.new
    return
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
      return
    end
    langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg",$langdata + "\\" + langs[i].to_s + ".elg")
end
speech("Paczki językowe zostały zaktualizowane")
speech_wait
main
return
    end
  end
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper