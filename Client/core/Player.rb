#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Player
  def initialize(file,scene)
    @file = file.delete("\r\n").gsub(" ","%20")
    @scene = scene
  end
  def main
    player(@file)        
    $scene = @scene
        $scene = Scene_Main.new if $scene == nil
      end
      end
#Copyright (C) 2014-2019 Dawid Pieper