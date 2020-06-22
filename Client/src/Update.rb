#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Update_Confirmation
  def initialize(toscene=nil)
    @toscene = toscene
    @toscene=Scene_Loading.new if @toscene==nil
    end
  def main
    msg = p_("Update", " A new version of this program is available. Do you want to download and instal it?")
                           case confirm(msg)
        when 0
          if $preinitialized != true
          $denyupdate = true
          $scene                  =@toscene
          else
          $denyupdate = true
                              $scene = Scene_Main.new
          end
          when 1
                                $scene = Scene_Update.new
        end
      end
  end

class Scene_Update
  def main
        $updating = true
        if $downloadstarted != true
        $started = true
    Graphics.update
  end
            downloadfile($url + "bin/eltenup.exe",Dirs.eltendata + "\\eltenup.exe",p_("Update", "Please wait while files are downloaded."),nil,true)
    speech_wait
    if Session.name!="" and Session.name!=nil
    alert(p_("Update", " The update has been downloaded. To install it, the program must be restarted.  Press enter to continue or escape to cancel."))
    cn=true
    for i in 1..Graphics.frame_rate*30
      loop_update
      break if enter
      if escape
        cn=false
        $scene=Scene_Main.new
                break
        end
      end
    else
      cn=true
      alert(p_("Update", "Now, the update will be installed. The program will restart."))
      end
      if cn == true                      
      $exit=true  
                                        $scene=nil
    $exitupdate=true
    end
    end
      end
  
  class Scene_ReInstall
  def main
        $updating = true
        speak(p_("Update", "Please wait while files are downloaded."))
                $downloadstarted = true
        speak(p_("Update", "Please wait while files are downloaded."))
download($url + "bin/download_elten.exe",Dirs.eltendata + "\\download_elten.exe")
    speech_wait
    alert(p_("Update", " The program will be now reverted to the latest stable version. Elten will restart.  It may take several minutes."))
  run(Dirs.eltendata + "\\download_elten.exe /wait")
  exit!
    end
  end