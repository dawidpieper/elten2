#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_General
  def main
                        @field = []
    @field[0] = Select.new([_("General:opt_linear"),_("General:opt_circular")],true,0,_("General:head_listspresentation"),true)
    @field[1] = CheckBox.new(_("General:chk_soundtheme"))
        @field[2] = Select.new([_("General:opt_chars"),_("General:opt_words"),_("General:opt_charsandwords"),_("General:opt_none")],true,0,_("General:head_typingecho"),true)
        @field[3] = CheckBox.new(_("General:chk_linewrapping"))
    @field[4] = CheckBox.new(_("General:chk_tray"))
            @field[5] = CheckBox.new(_("General:chk_autologin"))
        @field[6]=CheckBox.new(_("General:chk_autostart"))
    @field[7] = Button.new(_("General:str_save"))
    @field[8] = Button.new(_("General:str_cancel"))
    @form = Form.new(@field)
@form.fields[0].index = $interface_listtype
@form.fields[1].checked = $interface_soundthemeactivation
@form.fields[2].index = $interface_typingecho
@form.fields[3].checked = $interface_linewrapping
@form.fields[4].checked = $interface_hidewindow
if readconfig("Login","AutoLogin",0) != 0
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
  alert(_("General:error_autologinrequired"))
  @form.fields[6].checked=0
end
if $portable == 1 and autoportalert == false
  if confirm(_("General:alert_guestautostart"))==0
  @form.fields[6].checked=0
  else
  autoportalert = true
end
end
else
    autoportalert = false
    end
      if ((enter or space) and @form.index == 7) or ($key[0x12] == true and enter)
        writeconfig("Interface","ListType",@form.fields[0].index)
writeconfig("Interface","SoundThemeActivation",@form.fields[1].checked)
writeconfig("Interface","TypingEcho",@form.fields[2].index)
writeconfig("Interface","LineWrapping",@form.fields[3].checked)
writeconfig("Interface","HideWindow",@form.fields[4].checked)
$interface_listtype = @form.fields[0].index.to_i
$interface_soundthemeactivation = @form.fields[1].checked.to_i
$interface_typingecho = @form.fields[2].index
$interface_linewrapping = @form.fields[3].checked.to_i
$interface_hidewindow = @form.fields[4].checked.to_i
autologin = readconfig("Login","AutoLogin",-1)
if @form.fields[5].checked == 0 and autologin != 0
  writeconfig("Login","AutoLogin",0)
elsif @form.fields[5].checked == 1 and autologin == 0
if readconfig("Login","AutoLogin",-1) <= 0 and @form.fields[6].checked == 0
  writeconfig("Login","AutoLogin",-1)
                              end
    end
if @autostart == false and @form.fields[6].checked==1
  path="\0"*1025
Win32API.new("kernel32","GetModuleFileName",'ipi','i').call(0,path,path.size)
path.delete!("\0")
dr="\""+File.dirname(path)+"\\bin\\rubyw.exe\" \""+File.dirname(path)+"\\bin\\agent.dat\" /autostart"
@runkey['elten']=dr
elsif @autostart == true and @form.fields[6].checked==0
  @runkey.delete("elten")
  end
@runkey.close
alert(_("General:info_saved"))
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
#Copyright (C) 2014-2019 Dawid Pieper