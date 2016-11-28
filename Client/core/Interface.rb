#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Interface
  def main
                speech("Ustawienia interfejsu")
    speech_wait
        @field = []
    @field[0] = Select.new(["Liniowy","Kołowy"],true,0,"Sposób wyświetlania list wyboru",true)
    @field[1] = Edit.new("Czas odświerzania stanu klawiszy (ms) (Uwaga! Nie zaleca się zmiany tej wartości!)","","",true)
    @field[2] = CheckBox.new("Odtwarzaj dźwięki tematu dźwiękowego")
        @field[3] = Select.new(["Znaki","Wyrazy","Znaki i wyrazy","Brak"],true,0,"Echo pisania",true)
    @field[4] = CheckBox.new("Uruchamiaj program w trybie pełnoekranowym")
    @field[5] = CheckBox.new("Włącz automatyczne logowanie")
    @field[6] = CheckBox.new("Przetwarzaj diakretyki heksagonalnie (zaawansowane)")
    @field[7] = Button.new("Zapisz")
    @field[8] = Button.new("Anuluj")
    @form = Form.new(@field)
@form.fields[0].index = readini($configdata + "\\interface.ini","Interface","ListType","0").to_i
@form.fields[1].settext(readini($configdata + "\\interface.ini","Interface","KeyUpdateTime","75").to_s)
@form.fields[2].checked = readini($configdata + "\\interface.ini","Interface","SoundThemeActivation","1").to_i
@form.fields[3].index = readini($configdata + "\\interface.ini","Interface","TypingEcho","0").to_i
@form.fields[4].checked = readini($configdata + "\\interface.ini","Interface","FullScreen","1").to_i
if readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i >= 0
  @form.fields[5].checked = 1
else
  @form.fields[5].checked = 0
  end
@form.fields[6].checked = readini($configdata + "\\interface.ini","Interface","HexSpecial","1").to_i
@field[0].focus  
loop do
      loop_update
      @form.update
      if ((enter or space) and @form.index == 7) or ($key[0x11] == true and enter)
        writeini($configdata + "\\interface.ini","Interface","ListType",@form.fields[0].index.to_s)
@form.fields[1].finalize
writeini($configdata + "\\interface.ini","Interface","KeyUpdateTime",@form.fields[1].text_str)
writeini($configdata + "\\interface.ini","Interface","SoundThemeActivation",@form.fields[2].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","TypingEcho",@form.fields[3].index.to_s)
writeini($configdata + "\\interface.ini","Interface","FullScreen",@form.fields[4].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","HexSpecial",@form.fields[6].checked.to_s)
$interface_listtype = @form.fields[0].index.to_i
$interface_keyms = @form.fields[1].text_str.to_i
$interface_ackeyms = @form.fields[1].text_str.to_i * 3
$interface_soundthemeactivation = @form.fields[2].checked.to_i
$interface_typingecho = @form.fields[3].index
$interface_fullscreen = @form.fields[4].checked.to_i
$interface_hexspecial = @form.fields[6].checked.to_i
autologin = readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i
if @form.fields[5].checked == 0 and autologin >= 0
  writeini($configdata + "\\login.ini","Login","AutoLogin","-1")
elsif @form.fields[5].checked == 1 and autologin < 0
  writeini($configdata + "\\login.ini","Login","AutoLogin","0")
    end
speech("Zapisano")
speech_wait
if $name != nil and $name != "" and $token != nil and $token != ""
$scene = Scene_Main.new
else
  $scene = Scene_Loading.new
  end
  return
break
        end
      if escape or ((enter or space) and @form.index == 8)
        if $name != nil and $name != "" and $token != nil and $token != ""
$scene = Scene_Main.new
else
  $scene = Scene_Loading.new
  end
            break
          return
        end
      end
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper