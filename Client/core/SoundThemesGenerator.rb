#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_SoundThemesGenerator
  def main
    speech("Generator tematów dźwiękowych")
    speech_wait
    createsoundtheme
    $scene = Scene_Main.new if $scene == self
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper