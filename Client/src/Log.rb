#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Log
  def main
    @fields=[
    ListBox.new(["Debug", "Info", "Warning", "Error"], p_("Log", "Log level"), 1, 0, true),
    CheckBox.new(p_("Log", "Show event level"), true),
    CheckBox.new(p_("Log","Show event time"), true),
    EditBox.new(p_("Log", "Log"), EditBox::Flags::ReadOnly, "", true),
    Button.new(p_("Log", "Close"))
    ]
    @form=Form.new(@fields)
    loop do
      loop_update
      @form.update
      if @oldlevel!=@form.fields[0].index || @olddsplevel!=@form.fields[1].checked||@olddspdate!=@form.fields[2].checked
        @oldlevel=@form.fields[0].index
        @olddsplevel=@form.fields[1].checked
        @olddspdate=@form.fields[2].checked
        @form.fields[3].settext(Log.get(1000, @oldlevel-1, @olddsplevel.to_b, @olddspdate.to_b))
      end
      break if escape or @form.fields[4].pressed?
    end
    $scene=Scene_Main.new
  end
  end