#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Bug
  def main
    speech("Zgłaszanie błędu")
    speech_wait
    bug
    $scene = Scene_Main.new
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper