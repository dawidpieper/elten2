class Scene_EasterEggs
  def main
    ea = srvproc("eastereggs", {})
    if ea[0].to_i < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end

    begin
      ee = JSON.load(ea[1])
    rescue Exception
      ee = []
    end

    selt = []
    for e in ee
      desc = ""
      case e["id"]
      when "message"
        desc = p_("EasterEggs", "Write a message to user you have never written to")
      when "audioblog"
        desc = p_("EasterEggs", "Publish a public audio post on your blog")
      when "polls"
        desc = np_("EasterEggs", "Answer %{cnt} poll during the period of this game", "Answer %{cnt} polls during the period of this game", e["parameters"].to_i) % { "cnt" => e["parameters"].to_s }
      when "conference"
        desc = p_("EasterEggs", "Spend an hour at public conference")
      when "feed"
        desc = p_("EasterEggs", "Post to your feed")
      else
        desc = e["desc"]
      end
      desc = e["desc"] if e["desc"] != nil && e["desc"] != "" && e["desc"].delete("\r\n") != ""
      l = desc + " - " + np_("EasterEggs", "%{cnt} user has completed this challenge", "%{cnt} users have completed this challenge", e["count"].to_i) % { "cnt" => e["count"].to_s }
      l += " (" + np_("EasterEggs", "%{cnt} easter egg available for this challenge", "%{cnt} easter eggs available for this challenge", e["eggs"].to_i) % { "cnt" => e["eggs"].to_s } + ")"
      l += "\004NEW\004" if e["collected"] == false
      selt.push(l)
    end

    cnt = ($eeggs || []).size
    selt.push(np_("Main", "%{cnt} Easter egg still await finder!", "%{cnt} easter egss still await finder!", cnt) % { "cnt" => cnt })

    @sel = ListBox.new(selt, p_("EasterEggs", "Global challenges"))
    @sel.focus
    loop do
      loop_update
      @sel.update
      break if enter or escape
    end
    $scene = Scene_Main.new
  end
end
