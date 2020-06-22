#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_License
  def main
        $exit = true
    license(true)
    $exit = nil
    $scene = Scene_Main.new
  end
  end