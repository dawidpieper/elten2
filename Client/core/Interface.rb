#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Interface
  def main
                        @field = []
    @field[0] = Select.new([_("Interface:opt_linear"),_("Interface:opt_circular")],true,0,_("Interface:head_listspresentation"),true)
    @field[1] = CheckBox.new(_("Interface:chk_soundtheme"))
        @field[2] = Select.new([_("Interface:opt_chars"),_("Interface:opt_words"),_("Interface:opt_charsandwords"),_("Interface:opt_none")],true,0,_("Interface:head_typingecho"),true)
        @field[3] = CheckBox.new(_("Interface:chk_linewrapping"))
    @field[4] = CheckBox.new(_("Interface:chk_tray"))
            @field[5] = CheckBox.new(_("Interface:chk_autologin"))
        @field[6]=CheckBox.new(_("Interface:chk_autostart"))
    @field[7] = Button.new(_("General:str_save"))
    @field[8] = Button.new(_("General:str_cancel"))
    @form = Form.new(@field)
@form.fields[0].index = readini($configdata + "\\interface.ini","Interface","ListType","0").to_i
@form.fields[1].checked = readini($configdata + "\\interface.ini","Interface","SoundThemeActivation","1").to_i
@form.fields[2].index = readini($configdata + "\\interface.ini","Interface","TypingEcho","0").to_i
@form.fields[3].checked = readini($configdata + "\\interface.ini","Interface","LineWrapping","1").to_i
@form.fields[4].checked = readini($configdata + "\\interface.ini","Interface","HideWindow","0").to_i
if readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i != 0
  @form.fields[5].checked = 1
else
  @form.fields[5].checked = 0
  end
autoportalert = false
@runkey=Win32::Registry::HKEY_CURRENT_USER.create("Software\\Microsoft\\Windows\\CurrentVersion\\Run")
begin
  @runkey['elten']
  @form.fields[6].checked=1
@autostart=true
autoportalert=true
  rescue Exception
  @form.fields[6].checked=0
  @autostart=false
      end
      @field[0].focus  
loop do
      loop_update
      @form.update
if @form.fields[6].checked==1
  if @form.fields[5].checked==0
  speech(_("Interface:error_autologinrequired"))
  @form.fields[6].checked=0
end
if $portable == 1 and autoportalert == false
  if simplequestion(_("Interface:alert_guestautostart"))==0
  @form.fields[6].checked=0
  else
  autoportalert = true
end
end
else
    autoportalert = false
    end
      if ((enter or space) and @form.index == 7) or ($key[0x12] == true and enter)
        writeini($configdata + "\\interface.ini","Interface","ListType",@form.fields[0].index.to_s)
writeini($configdata + "\\interface.ini","Interface","SoundThemeActivation",@form.fields[1].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","TypingEcho",@form.fields[2].index.to_s)
writeini($configdata + "\\interface.ini","Interface","LineWrapping",@form.fields[3].checked.to_s)
writeini($configdata + "\\interface.ini","Interface","HideWindow",@form.fields[4].checked.to_s)
$interface_listtype = @form.fields[0].index.to_i
$interface_soundthemeactivation = @form.fields[1].checked.to_i
$interface_typingecho = @form.fields[2].index
$interface_linewrapping = @form.fields[3].checked.to_i
$interface_hidewindow = @form.fields[4].checked.to_i
autologin = readini($configdata + "\\login.ini","Login","AutoLogin","-1").to_i
if @form.fields[5].checked == 0 and autologin != 0
  writeini($configdata + "\\login.ini","Login","AutoLogin","0")
elsif @form.fields[5].checked == 1 and autologin == 0
if readini($configdata + "\\login.ini","Login","AutoLogin","-1").to_i <= 0 and @form.fields[6].checked == 0
  writeini($configdata + "\\login.ini","Login","AutoLogin","-1")
                              end
    end
if @autostart == false and @form.fields[6].checked==1
  path="\0"*1025
Win32API.new("kernel32","GetModuleFileName",'ipi','i').call(0,path,path.size)
path.delete!("\0")
dr="\""+File.dirname(path)+"\\bin\\rubyw.exe\" \""+File.dirname(path)+"\\bin\\agentc.dat\" /autostart"
@runkey['elten']=dr
elsif @autostart == true and @form.fields[6].checked==0
  @runkey.delete("elten")
  end
@runkey.close
speech(_("General:info_saved"))
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
#Copyright (C) 2014-2018 Dawid Pieper