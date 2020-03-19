#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_General
  def main
                        @field = []
    @field[0] = Select.new([p_("General", "Linear"),p_("General", "Circular")],true,0,p_("General", "The display method of selection lists"),true)
    @field[1] = CheckBox.new(p_("General", "Play sounds of soundthemes"))
        @field[2] = Select.new([p_("General", "Characters"),p_("General", "Words"),p_("General", "Characters and words"),p_("General", "None")],true,0,p_("General", "Typing echo"),true)
        @field[3] = CheckBox.new(p_("General", "Wrap long lines in text fields"))
    @field[4] = CheckBox.new(p_("General", "Automatically minimize Elten Window to system tray"))
            @field[5] = CheckBox.new(p_("General", "Enable auto log in"))
        @field[6]=CheckBox.new(p_("General", "Automatically start Elten after I log on to Windows"))
    @field[7] = Button.new(_("Save"))
    @field[8] = Button.new(_("Cancel"))
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
  alert(p_("General", "Auto log in is required to use auto start"))
  @form.fields[6].checked=0
end
if $portable == 1 and autoportalert == false
  if confirm(p_("General", "Are you sure you want to enable autostart of portable version?"))==0
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
alert(_("Saved"))
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