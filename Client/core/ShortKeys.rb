#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ShortKeys
  def main
    @shorts=$dict['_doc_shortkeys']||""
    input_text(_("ShortKeys:head"),"MULTILINE|READONLY|ACCEPTESCAPE",@shorts)
speech_stop
$scene = Scene_Main.new
end
end
#Copyright (C) 2014-2018 Dawid Pieper