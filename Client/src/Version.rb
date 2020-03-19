#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Version
  def main
    txt = "ELTEN #{Elten.version.to_s.delete(".").split("").join(".")}"
    txt+=" BETA #{Elten.beta.to_s}" if Elten.isbeta==1
    txt+=" RC #{Elten.beta.to_s}" if Elten.isbeta==2
    txt+="\r\nBuild ID: #{Elten.build_id}\r\nBuild Date: #{Elten.build_date}\r\n\r\n"
    f=ChildProc.new("bin\\ruby -v")
    loop_update while f.avail==0
    delay(0.1)
    txt+=f.read+"\r\n\r\n"
        f=ChildProc.new("bin\\ffmpeg -version")
    loop_update while f.avail==0
    delay(0.1)
    txt+=f.read.split("\n")[0].delete("\r")+"\r\n"
    if FileTest.exists?($extrasdata+"\\youtube-dl.exe")
    f=ChildProc.new("\"#{$extrasdata}\\youtube-dl\" --version")
    loop_update while f.avail==0
    delay(0.1)
        txt+="Youtube-DL "+f.read.split("\n")[0].delete("\r")+"\r\n"
        end
    f=ChildProc.new("bin\\7z")
    loop_update while f.avail==0
    delay(0.1)
    txt+=f.read.split("\n")[1].delete("\r")+"\r\n"
    f=ChildProc.new("bin\\rar")
    loop_update while f.avail==0
    delay(0.1)
    txt+=f.read.split("\n")[1].delete("\r")+"\r\n"
    input_text("ELTEN",Edit::Flags::ReadOnly|Edit::Flags::MultiLine,txt)
    $scene=Scene_Main.new
  end
  end