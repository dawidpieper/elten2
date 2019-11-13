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
                 case simplequestion(msg)
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
    if simplequestion(_("Update:alert_betawarning")) == 0
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
        speech(_("Update:wait"))
        if $downloadstarted != true
        $started = true
    Graphics.update
  end
  speech_wait
  speech(_("Update:wait_languages"))  
  downloadfile($url+"locale.dat","temp/locale_new.dat")
  begin
    fp=File.open("temp/locale_new.dat","rb")
  loc =Marshal.load(Zlib::Inflate.inflate(fp.read))
  fp.close
if loc.is_a?(Array) and loc.size>0
  $locales=loc
  set_locale($language)
  writefile("Data/locale.dat",read("temp/locale_new.dat"))
    end
    rescue Exception
    end
  speech_wait
          if $nbeta > $beta and $isbeta==1
downloadfile($url + "bin/beta.php?name=#{$name}\&token=#{$token}\&download=2\&version=#{$nversion.to_s}\&beta=#{$nbeta.to_s}",$bindata + "\\eltenup.exe",_("Update:wait_downloading"))
  else
  downloadfile($url + "bin/eltenup.exe",$bindata + "\\eltenup.exe",_("Update:wait_downloading"))
end
    speech_wait
    if $name!="" and $name!=nil
    speech(_("Update:info_downloaded"))
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
      speech(_("Update:info_updatewillinstall"))
      speech_wait
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
        speech(_("Update:wait"))
                $downloadstarted = true
      speech_wait
        speech(_("Update:wait_reinstallationdownloading"))
download($url + "bin/download_elten.exe",$bindata + "\\download_elten.exe")
    speech_wait
    speech(_("Update:info_reinstall"))
    speech_wait
  run($bindata + "\\download_elten.exe /wait")
  exit!
    end
  end
#Copyright (C) 2014-2019 Dawid Pieper