#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Update_Confirmation
  def main
    msg = "Dostępna jest nowa wersja programu. Czy chcesz ją pobrać i zainstalować?"
    if $nversion <= $version
    msg = "Dostępna jest nowa wersja beta programu. Czy chcesz ją pobrać i zainstalować?"
  end
               case simplequestion(msg)
        when 0
          if $preinitialized != true
          $denyupdate = true
          $scene = Scene_Loading.new
        else
          $scene = Scene_Main.new
          end
          when 1
            if $nversion <= $version
    if simplequestion("Ostrzeżenie. Próbujesz zainstalować wersję beta. Zawiera ona nieprzetestowaną wersję programu i może działać niestabilnie lub powodować inne błędy. Czy chcesz kontynuować mimo to?") == 0
      if $preinitialized != true
          $denyupdate = true
          $scene = Scene_Loading.new
        else
          $scene = Scene_Main.new
        end
        return
      end
              end
            $scene = Scene_Update.new
        end
      end
  end

class Scene_Update
  def main
        $updating = true
        speech("Proszę czekać, trwa pobieranie plików")
        if $downloadstarted != true
        $downloadstarted = true
    Graphics.update
  end
  speech_wait
  speech("Aktualizowanie pakietów językowych")  
  $l = false
  langtemp = srvproc("languages","langtemp")
    err = langtemp[0].to_i
  case err
  when 0
    $l = true
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
        when -2
      speech("Klucz sesji wygasł.")
      speech_wait
    end
    if $l == true
    langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg",$langdata + "\\" + langs[i].to_s + ".elg")
end
speech_wait
end  
er = false
if $nbeta > $beta
if (m = srvproc("bin/beta","name=#{$name}\&token=#{$token}\&get=1"))[0].to_i == 0
    if m.size > 1
      if m[1].to_i == 0
    er = true if simplequestion("Nie należysz do otwartego programu testów Elten. Czy chcesz do niego przystąpić teraz, by pobrać wersję beta?") == 0
        end
else
er = true
end
else
  er = true
  end
    if er == true
  if $preinitialized != true
          $denyupdate = true
          $scene = Scene_Loading.new
        else
          $scene = Scene_Main.new
        end
                return
        end
        end
        speech("Pobieranie instrukcji aktualizacji")
if $nversion > $version
download($url + "bin/download_elten.exe",$bindata + "\\download_elten.exe")
else
  download($url + "bin/beta.php?name=#{$name}\&token=#{$token}\&download=1\&version=#{$nversion.to_s}\&beta=#{$nbeta.to_s}",$bindata + "\\download_elten.exe")
end
    speech_wait
    speech("Aktualizacja zostanie teraz pobrana i zainstalowana. Program zostanie uruchomiony ponownie. To może potrwać kilka minut.")
    speech_wait
  run($bindata + "\\download_elten.exe /wait")
  exit!
  end
      end
  
  class Scene_ReInstall
  def main
        $updating = true
        speech("Proszę czekać, trwa pobieranie plików")
        if $downloadstarted != true
        $downloadstarted = true
    Graphics.update
  end
  speech_wait
  speech("Aktualizowanie pakietów językowych")  
  $l = false
  langtemp = srvproc("languages","langtemp")
    err = langtemp[0].to_i
  case err
  when 0
    $l = true
  when -1
    speech("Błąd połączenia się z bazą danych.")
    speech_wait
        when -2
      speech("Klucz sesji wygasł.")
      speech_wait
    end
    if $l == true
    langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg",$langdata + "\\" + langs[i].to_s + ".elg")
end
speech_wait
end  
        speech("Pobieranie instrukcji reinstalacji")
download($url + "bin/download_elten.exe",$bindata + "\\download_elten.exe")
    speech_wait
    speech("Program zostanie teraz przywrócony do ostatniej stabilnej wersji. Elten zostanie uruchomiony ponownie. To może potrwać kilka minut.")
    speech_wait
  run($bindata + "\\download_elten.exe /wait")
  exit!
    end
  end
#Copyright (C) 2014-2016 Dawid Pieper