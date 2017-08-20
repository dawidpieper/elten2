#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Interface
  def main
                        @field = []
    @field[0] = Select.new(["Liniowy","Kołowy"],true,0,"Sposób wyświetlania list wyboru",true)
    @field[1] = Edit.new("Czas odświerzania stanu klawiszy (ms) (Uwaga! Nie zaleca się zmiany tej wartości!)","",$interface_keyms.to_i,true)
    @field[2] = CheckBox.new("Odtwarzaj dźwięki tematu dźwiękowego")
        @field[3] = Select.new(["Znaki","Wyrazy","Znaki i wyrazy","Brak"],true,0,"Echo pisania",true)
    @field[4] = CheckBox.new("Automatycznie minimalizuj okno programu do zasobnika systemowego")
        @field[5] = CheckBox.new("Uruchamiaj program w trybie pełnoekranowym")
    @field[6] = CheckBox.new("Włącz automatyczne logowanie")
    @field[7] = CheckBox.new("Przetwarzaj diakretyki heksagonalnie (zaawansowane)")
    @field[8] = Edit.new("Czas odświerzania sesji (s) (Uwaga! Nie zaleca się zmiany tej wartości!)","",$interface_refreshtime.to_i,true)
    @field[9]=CheckBox.new("Zezwalaj na automatyczne buforowanie treści z youtube (przyspiesza czas ładowania filmów, ale może dodatkowo wykorzystywać połączenie Internetowe)")
    @field[10]=CheckBox.new("Automatycznie uruchamiaj program Elten przy starcie systemu")
    @field[11] = Button.new("Zapisz")
    @field[12] = Button.new("Anuluj")
    @form = Form.new(@field)
@form.fields[0].index = readini($configdata + "\\interface.ini","Interface","ListType","0").to_i
@form.fields[1].settext(readini($configdata + "\\interface.ini","Interface","KeyUpdateTime","75").to_s)
@form.fields[2].checked = readini($configdata + "\\interface.ini","Interface","SoundThemeActivation","1").to_i
@form.fields[3].index = readini($configdata + "\\interface.ini","Interface","TypingEcho","0").to_i
@form.fields[4].checked = readini($configdata + "\\interface.ini","Interface","HideWindow","0").to_i
@form.fields[5].checked = readini($configdata + "\\interface.ini","Interface","FullScreen","1").to_i
if readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i >= 0
  @form.fields[6].checked = 1
else
  @form.fields[6].checked = 0
  end
@form.fields[7].checked = readini($configdata + "\\interface.ini","Interface","HexSpecial","1").to_i
@form.fields[8].settext(readini($configdata + "\\interface.ini","Interface","RefreshTime","1").to_s)
@form.fields[9].checked = readini($configdata + "\\interface.ini","Interface","YTBuffering","1").to_i
autoportalert = false
@runkey=Win32::Registry::HKEY_CURRENT_USER.create("Software\\Microsoft\\Windows\\CurrentVersion\\Run")
begin
  @runkey['elten']
  @form.fields[10].checked=1
@autostart=true
autoportalert=true
  rescue Exception
  @form.fields[10].checked=0
  @autostart=false
      end
@field[0].focus  
loop do
      loop_update
      @form.update
if @form.fields[10].checked==1
  if @form.fields[6].checked==0
  speech("Autostart programu wymaga włączenia automatycznego logowania.")
  @form.fields[10].checked=0
end
if $portable == 1 and autoportalert == false
  if simplequestion("Uwaga! Próbujesz włączyć autostart programu używając przenośnej wersji Eltena. Ta funkcja będzie działać tylko w wypadku, gdy program znajdzie się na stałym dysku komputera, a zatem będzie dostępny przy każdym starcie systemu. Nie można również zmienić jego lokalizacji. Czy chcesz kontynuować mimo to?")==0
  @form.fields[10].checked=0
  else
  autoportalert = true
end
end
else
    autoportalert = false
    end
      if ((enter or space) and @form.index == 11) or ($key[0x11] == true and enter)
        writeini($configdata + "\\interface.ini","Interface","ListType",@form.fields[0].index.to_s)
@form.fields[1].finalize
writeini($configdata + "\\interface.ini","Interface","KeyUpdateTime",@form.fields[1].text_str)
writeini($configdata + "\\interface.ini","Interface","SoundThemeActivation",@form.fields[2].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","TypingEcho",@form.fields[3].index.to_s)
writeini($configdata + "\\interface.ini","Interface","HideWindow",@form.fields[4].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","FullScreen",@form.fields[5].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","HexSpecial",@form.fields[7].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","YTBuffering",@form.fields[9].checked.to_s)
@form.fields[8].finalize
@form.fields[8].settext(1) if @form.fields[8].text_str.to_i>30 or @form.fields[8].text_str.to_i<1
writeini($configdata + "\\interface.ini","Interface","RefreshTime",@form.fields[8].text_str)
$interface_listtype = @form.fields[0].index.to_i
$interface_keyms = @form.fields[1].text_str.to_i
$interface_ackeyms = @form.fields[1].text_str.to_i * 3
$interface_soundthemeactivation = @form.fields[2].checked.to_i
$interface_typingecho = @form.fields[3].index
$interface_hidewindow = @form.fields[4].checked.to_i
$interface_fullscreen = @form.fields[5].checked.to_i
$interface_hexspecial = @form.fields[7].checked.to_i
$interface_ytbuffering = @form.fields[9].checked.to_i
autologin = readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i
if @form.fields[6].checked == 0 and autologin >= 0
  writeini($configdata + "\\login.ini","Login","AutoLogin","-1")
elsif @form.fields[6].checked == 1 and autologin < 0
if readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i == 0 and @form.fields[10].checked == 0
  Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","autologin","2",$configdata + "\\login.ini")          
  Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","name",$name,$configdata + "\\login.ini")
    crp = input_text("Hasło","PASSWORD").crypt($name)
                      Win32API.new("kernel32","WritePrivateProfileString",'pppp','i').call("Login","password",crp,$configdata + "\\login.ini")
    end
  writeini($configdata + "\\login.ini","Login","AutoLogin","0")
  end
$interface_refreshtime = @form.fields[8].text_str.to_i
if @autostart == false and @form.fields[10].checked==1
  path="\0"*1024
Win32API.new("kernel32","GetModuleFileName",'ipi','i').call(0,path,path.size)
path.delete!("\0")
dr="\""+File.dirname(path)+"\\bin\\rubyw.exe\" \""+File.dirname(path)+"\\bin\\agentc.dat\" /autostart"
@runkey['elten']=dr
elsif @autostart == true and @form.fields[10].checked==0
  @runkey.delete("elten")
  end
@runkey.close
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
      if escape or ((enter or space) and @form.index == 12)
        @runkey.close
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