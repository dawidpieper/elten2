#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Debug
  def main
    @form=Form.new([EditBox.new(p_("Debug", "A report"),EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly,createdebuginfo),CheckBox.new(p_("Debug", "Report connections to the server"),$netsignal.to_i),Button.new(p_("Debug", "OK"))])
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