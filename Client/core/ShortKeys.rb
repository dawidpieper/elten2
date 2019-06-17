#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ShortKeys
  def main
    @shorts=$dict['_doc_shortkeys']||""
    input_text(_("ShortKeys:head"),Edit::Flags::MultiLine|Edit::Flags::ReadOnly|Edit::Flags::MarkDown,@shorts)
speech_stop
$scene = Scene_Main.new
end
end
#Copyright (C) 2014-2019 Dawid Pieper