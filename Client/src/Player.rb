#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

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