#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
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
  $l = false
  langtemp = srvproc("languages","langtemp")
    err = langtemp[0].to_i
  case err
  when 0
    $l = true
  when -1
    speech(_("General:error_db"))
    speech_wait
        when -2
      speech(_("General:error_tokenexpired"))
      speech_wait
    end
    if $l == true
    langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg",$langdata + "\\" + langs[i].to_s + ".elg")
end
speech_wait
end  
er = false
if $nbeta > $beta and $isbeta==1
if (m = srvproc("bin/beta","name=#{$name}\&token=#{$token}\&get=1"))[0].to_i == 0
    if m.size > 1
      if m[1].to_i == 0
    er = true if simplequestion(_("Update:alert_joinbeta")) == 0
        end
else
er = true
end
else
  er = true
  end
    if er == true
  if $preinitialized != true
          $denyupdate = true
          $scene = Scene_Loading.new
        else
          $scene = Scene_Main.new
        end
                return
        end
        end
        if $nbeta > $beta and $isbeta==1
downloadfile($url + "bin/beta.php?"+hexspecial("name=#{$name}\&token=#{$token}\&download=2\&version=#{$nversion.to_s}\&beta=#{$nbeta.to_s}"),$bindata + "\\eltenup.exe",_("Update:wait_downloading"))
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
        if $downloadstarted != true
        $downloadstarted = true
    Graphics.update
  end
  speech_wait
  speech(_("Update:wait_languages"))  
  $l = false
  langtemp = srvproc("languages","langtemp")
    err = langtemp[0].to_i
  case err
  when 0
    $l = true
  when -1
    speech(_("General:error_db"))
    speech_wait
        when -2
      speech(_("General:error_tokenexpired"))
      speech_wait
    end
    if $l == true
    langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg",$langdata + "\\" + langs[i].to_s + ".elg")
  end
speech_wait
end  
        speech(_("Update:wait_reinstallationdownloading"))
download($url + "bin/download_elten.exe",$bindata + "\\download_elten.exe")
    speech_wait
    speech(_("Update:info_reinstall"))
    speech_wait
  run($bindata + "\\download_elten.exe /wait")
  exit!
    end
  end
#Copyright (C) 2014-2016 Dawid Pieper