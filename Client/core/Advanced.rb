#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Advanced
  def main
    @field=[]
    @field[0] = Edit.new(_("Advanced:head_keyreftime"),Edit::Flags::Numbers,$advanced_keyms.to_s,true)
        @field[1] = Edit.new(_("Advanced:head_sesreftime"),Edit::Flags::Numbers,$advanced_refreshtime.to_s,true)
                    @field[2]=CheckBox.new(_("Advanced:chk_timesyncing"))
    @field[3] = Button.new(_("General:str_save"))
    @field[4] = Button.new(_("General:str_cancel"))
    @form = Form.new(@field)
@form.fields[0].settext($advanced_keyms.to_s)
@form.fields[1].settext($advanced_refreshtime.to_s)
@form.fields[2].checked = $advanced_synctime
      @field[0].focus  
loop do
      loop_update
      @form.update
      if ((enter or space) and @form.index == 3) or ($key[0x12] == true and enter)
@form.fields[0].finalize
writeconfig("Advanced","KeyUpdateTime",@form.fields[0].text_str)
writeconfig("Advanced","SyncTime",@form.fields[2].checked)
@form.fields[1].finalize
writeconfig("Advanced","AgentRefreshTime",@form.fields[1].text_str)
$advanced_keyms = @form.fields[0].text_str.to_i
$advanced_refreshtime = @form.fields[1].text_str.to_i
$advanced_synctime = @form.fields[2].checked.to_i
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
      if escape or ((enter or space) and @form.index == 4)
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