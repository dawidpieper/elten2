#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Debug
  def main
    @form=Form.new([Edit.new(_("Debug:read_report"),"MULTILINE|READONLY",createdebuginfo),CheckBox.new(_("Debug:chk_srvconnectionsignal"),$netsignal.to_i),Button.new(_("Debug:btn_ok"))])
    loop do
      loop_update
      @form.update
      break if escape
      if (enter or space) and @form.index==2
                $netsignal=@form.fields[1].checked.to_b
        break
        end
      end
      $scene=Scene_Main.new
  end
  end
#Copyright (C) 2014-2019 Dawid Pieper