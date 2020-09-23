#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Version
  def main
    txt = "ELTEN #{Elten.version.to_s.delete(".").split("").join(".")}"
    txt+=" BETA #{Elten.beta.to_s}" if Elten.isbeta==1
    txt+=" RC #{Elten.beta.to_s}" if Elten.isbeta==2
    txt+="\r\nBuild ID: #{Elten.build_id}\r\nBuild Date: #{Elten.build_date}\r\n\r\n"
    fruby=ChildProc.new("bin\\ruby -v")
        f7zip=ChildProc.new("bin\\7z")
    loop_update while fruby.avail==0
    txt+=fruby.read+"\r\n\r\n"
    loop_update while f7zip.avail==0
    txt+=f7zip.read.split("\n")[1].delete("\r")+"\r\n"
    input_text("ELTEN",EditBox::Flags::ReadOnly|EditBox::Flags::MultiLine,txt)
    $scene=Scene_Main.new
  end
  end