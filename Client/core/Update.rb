#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Update_Confirmation
  def initialize(toscene=nil)
    @toscene = toscene
    @toscene=Scene_Loading.new if @toscene==nil
    end
  def main
    msg = _("Update:alert_newversion")
          if $nbeta > $beta and $isbeta==1
    msg = _("Update:alert_newbeta")
      end
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
            if $nbeta > $beta and $isbeta==1
    if confirm(_("Update:alert_betawarning")) == 0
      if $preinitialized != true
          $denyupdate = true
          $scene = Scene_Loading.new
        else
          $denyupdate = true
          $scene = Scene_Main.new
        end
        return
      end
              end
            $scene = Scene_Update.new
        end
      end
  end

class Scene_Update
  def main
        $updating = true
        speak(_("Update:wait"))
        if $downloadstarted != true
        $started = true
    Graphics.update
  end
  speech_wait
          if $nbeta > $beta and $isbeta==1
downloadfile($url + "bin/beta.php?name=#{$name}\&token=#{$token}\&download=2\&version=#{$nversion.to_s}\&beta=#{$nbeta.to_s}",$eltendata + "\\eltenup.exe",_("Update:wait_downloading"),nil,true)
  else
  downloadfile($url + "bin/eltenup.exe",$eltendata + "\\eltenup.exe",_("Update:wait_downloading"),nil,true)
end
    speech_wait
    if $name!="" and $name!=nil
    alert(_("Update:info_downloaded"))
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
      alert(_("Update:info_updatewillinstall"))
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
        speak(_("Update:wait"))
                $downloadstarted = true
      speech_wait
        speak(_("Update:wait_reinstallationdownloading"))
download($url + "bin/download_elten.exe",$eltendata + "\\download_elten.exe")
    speech_wait
    alert(_("Update:info_reinstall"))
  run($eltendata + "\\download_elten.exe /wait")
  exit!
    end
  end
#Copyright (C) 2014-2019 Dawid Pieper