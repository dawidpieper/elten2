#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_ShortKeys
  def main
    @shorts=_doc('shortkeys')
    input_text(p_("ShortKeys", "List of keyboard shortcuts"),Edit::Flags::MultiLine|Edit::Flags::ReadOnly|Edit::Flags::MarkDown,@shorts)
speech_stop
$scene = Scene_Main.new
end
end