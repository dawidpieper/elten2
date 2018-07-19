#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Compiler
  def main
    return $scene=Scene_Main.new
    speech("Witaj w kompilatorze Elten API. Naciśnij enter, aby kontynuować lub escape, aby zamknąć.")
    loop_update until escape or enter
    return $scene=Scene_Main.new if escape
    creator
  end
  def creator(step=1)
    @forms=[] if @forms==nil
    if @forms[i]==nil
      @fields=[]
      case step
  when 1
    @fields=[FilesTree.new("Lokalizacja docelowa",getdirectory(40)+"\\",true,true,"Documents"),Edit.new("Nazwa folderu projektu","","myeapiapp"),Edit.new("Nazwa projektu","","My Elten API Application")]
    when 2
@fields=[CheckBox.new("Automatycznie załącz moduły Elten API",1),CheckBOX.new("Wyeksportuj z zewnętrznymi bibliotekami rozszerzeń",1)]
              when 3
                @fields=[CheckBox.new("Zezwalaj na używanie zapisanych ustawień programu Elten, jeśli na komputerze uruchamiania projektu zainstalowana jest zgodna wersja Eltena",1),CheckBox.new("Automatycznie zapytaj o wybór głosu w wypadku braku ustawionego",1)]
                when 4
                  @fields=[Select.new(["Nie dołączaj dźwięków tematu dźwiękowego","Użyj dźwięków tematu domyślnego","Użyj dźwięków obecnie używanego tematu dźwiękowego"],true,0,"Dołącz dźwięki interfejsu")]
  end

  end

    end
  end
#Copyright (C) 2014-2016 Dawid Pieper