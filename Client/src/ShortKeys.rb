#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_ShortKeys
  def main
    @shorts=_doc('shortkeys')
    input_text(p_("ShortKeys", "List of keyboard shortcuts"),EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly|EditBox::Flags::MarkDown,@shorts)
speech_stop
$scene = Scene_Main.new
end
end