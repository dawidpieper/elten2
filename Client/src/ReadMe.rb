#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_ReadMe
  def main
    text=_doc('readme')
        input_text(p_("ReadMe", "Readme"),EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly|EditBox::Flags::MarkDown,text)
    $scene = Scene_Main.new
  end
  end