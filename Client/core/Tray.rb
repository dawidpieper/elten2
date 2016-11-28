#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Tray
  def main
      run("bin\\elten_tray.bin")
  Win32API.new("user32","SetFocus",'i','i').call($wnd)
  Win32API.new("user32","ShowWindow",'ii','i').call($wnd,0)
  Graphics.update
  Graphics.update
  play("login")
  speech("ELTEN")
  $scene = Scene_Main.new
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper