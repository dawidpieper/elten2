#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Console
  def main
    console
    $scene=Scene_Main.new if $scene==self
  end
  end