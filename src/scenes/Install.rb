class Scene_Install
  def main
    installmethod=selector([p_("Install", "Install current version"), p_("Install", "Download and install the newest version"), _("Cancel")],p_("Install", "Which version would you like to use?"),0,2,1)
    case installmethod
    when 0
      $exit=true  
                                        $scene=nil
    $exitreinstall=true
      when 1
        $exitupdate_donotsilent=true
        $scene=Scene_Update.new
        when 2
          $scene=Scene_Main.new
    end
  end
  end