#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Version
  def main
    txt = "ELTEN #{Elten.version.to_s}"
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
    f=ChildProc.new("bin\\youtube-dl --version")
    loop_update while f.avail==0
    delay(0.1)
    txt+="Youtube-DL "+f.read.split("\n")[0].delete("\r")+"\r\n"
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
#Copyright (C) 2014-2019 Dawid Pieper