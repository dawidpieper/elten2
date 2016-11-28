#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_ReadMe
  def main
    readme = IO.readlines("readme.txt")
    text = ""
    for i in 0..readme.size - 1
      text += readme[i]
    end
    input_text("Przeczytaj mnie","READONLY|ACCEPTESCAPE|MULTILINE",text)
    $scene = Scene_Main.new
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper