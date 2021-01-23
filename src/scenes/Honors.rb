# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Honors
  def initialize(user = nil, toscene = nil, honor = nil)
    @user = user
    @toscene = toscene
    @honor = honor
  end

  def main
    if @user == nil
      hn = srvproc("honors", { "list" => 2 })
    else
      hn = srvproc("honors", { "list" => 2, "user" => @user })
    end
    if hn[0].to_i < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    @honors = []
    i = 0
    h = 0
    if hn.size > 2
      for t in hn[2..hn.size - 1]
        case i
        when 0
          @honors[h] = Struct_Honor.new(t.to_i)
          i += 1
        when 1
          @honors[h].name = t.delete("\r\n")
          i += 1
        when 2
          @honors[h].description = t.delete("\r\n")
          i += 1
        when 3
          @honors[h].enname = t.delete("\r\n")
          i += 1
        when 4
          @honors[h].endescription = t.delete("\r\n")
          i += 1
        when 5
          j = t.delete("\r\n")
          @honors[h].levels = JSON.load(j) if j != ""
          i += 1
        when 6
          j = t.delete("\r\n")
          @honors[h].enlevels = JSON.load(j) if j != ""
          i += 1
        when 7
          @honors[h].level = t.to_i
          h += 1
          i = 0
        end
      end
    end
    selt = []
    ind = 0
    for h in @honors
      ind = selt.size if h.id == @honor
      selt.push(makeselt(h))
    end
    selt.push(p_("Honors", "A new badge"))
    header = ""
    if @user == nil
      header = p_("Honors", "Badges")
    else
      header = p_("Honors", "Badges of %{user}") % { "user" => @user }
    end
    if @user != nil and @honors == []
      alert(p_("Honors", "The user has been given no badges."))
      $scene = Scene_Main.new
      return
    end
    @sel = ListBox.new(selt, header, ind)
    @sel.disable_item(selt.size - 1) if Session.moderator == 0 or @user != nil
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      if enter and @sel.index == @sel.options.size - 1
        $scene = Scene_Honors_New.new
      elsif (enter or arrow_right) and @sel.index < @honors.size
        $scene = Scene_Honors_Users.new(@honors[@sel.index].id, @user, @toscene)
      end
      if escape
        if @toscene == nil
          $scene = Scene_Main.new
        else
          $scene = @toscene
        end
      end
      break if $scene != self
    end
  end

  def makeselt(h)
    selt = ""
    if Configuration.language == "pl-PL"
      selt = h.name
    else
      selt = h.enname
    end
    if h.levels.size > 1 and @user != nil
      selt += " (" + p_("Honors", "Level") + " " + (h.level + 1).to_s + ")"
    end
    if Configuration.language == "pl-PL"
      selt += ":\r\n" + h.description + "\r\n"
    else
      selt += ":\r\n" + h.endescription + "\r\n"
    end
    if h.levels.size == 1
      if Configuration.language == "pl-PL"
        selt += h.levels[0]
      else
        selt += h.enlevels[0]
      end
    elsif h.levels.size > 1
      for i in h.level...h.levels.size
        selt += p_("Honors", "Level") + (i + 1).to_s + ": "
        if Configuration.language == "pl-PL"
          selt += h.levels[i]
        else
          selt += h.enlevels[i]
        end
        selt += "\r\n"
      end
    end
    return selt
  end

  def context(menu)
    if @sel.index != @sel.options.size - 1
      menu.option(p_("Honors", "Set as main honor")) {
        hn = srvproc("honors", { "setmain" => "1", "honor" => @honors[@sel.index].id })
        if hn[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Honors", "The badge has been set as default."))
        end
      }
      if Session.moderator == 1
        menu.option(p_("Honors", "Grant a badge")) {
          user = input_user(p_("Honors", "Who should be granted this badge?"))
          if user != nil
            hn = srvproc("honors", { "user" => user, "award" => "1", "honor" => @honors[@sel.index].id })
            if hn[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Honors", "The badge has been granted"))
            end
          end
        }
        menu.option(p_("Honors", "Edit challenges")) {
          loop_update
          editchallenges(@honors[@sel.index])
          @sel.options[@sel.index] = makeselt(@honors[@sel.index])
          loop_update
        }
        menu.option(p_("Honors", "Delete")) {
          confirm(p_("Honors", "Are you sure you want to delete this badge? All users granted with this badge will loose it.")) {
            hn = srvproc("honors", { "delhonor" => 1, "honor" => @honors[@sel.index].id })
            if hn[0].to_i < 0
              alert(_("Error"))
            else
              alert(p_("Honors", "Honor deleted"))
            end
            main
          }
        }
      end
    end
    menu.option(_("Refresh")) {
      $scene = Scene_Honors.new(@user)
    }
  end

  def editchallenges(honor)
    levels = honor.levels.deep_dup
    enlevels = honor.enlevels.deep_dup
    selt = []
    for i in 0..levels.size - 1
      selt.push("#{i + 1}: #{levels[i]}, #{enlevels[i]}")
    end
    selt += [p_("Honors", "Add challenge")]
    form = Form.new([ListBox.new(selt, p_("Honors", "Challenges"), 0, 0, true), Button.new(_("Save")), Button.new(_("Cancel"))])
    loop do
      loop_update
      form.update
      break if escape or form.fields[2].pressed?
      if form.index == 0 and form.fields[0].index < levels.size and $key[0x2e]
        levels.delete_at(form.fields[0].index)
        enlevels.delete_at(form.fields[0].index)
        selt = []
        for i in 0..levels.size - 1
          selt.push("#{i + 1}: #{levels[i]}, #{enlevels[i]}")
        end
        selt += [p_("Honors", "Add challenge")]
        form.fields[0].options = selt
        play("editbox_delete")
        form.fields[0].focus
      end
      if form.fields[1].pressed?
        honor.levels = levels
        honor.enlevels = enlevels
        bl = buffer(JSON.generate(levels))
        bel = buffer(JSON.generate(enlevels))
        hn = srvproc("honors", { "setlevels" => 1, "buf_levels" => bl, "buf_enlevels" => bel, "honor" => honor.id })
        if hn[0].to_i < 0
          alert(_("Error"))
        else
          alert(_("Saved"))
          break
        end
      end
      if enter and form.index == 0
        l = form.fields[0].index
        subform = Form.new([
          EditBox.new(p_("Honors", "Level"), "", levels[l] || "", true),
          EditBox.new(p_("Honors", "English level"), "", enlevels[l] || "", true),
          Button.new(_("Save")),
          Button.new(_("Cancel"))
        ])
        loop do
          loop_update
          subform.update
          break if escape or subform.fields[3].pressed?
          if subform.fields[2].pressed?
            levels[l] = subform.fields[0].text
            enlevels[l] = subform.fields[1].text
            break
          end
        end
        selt = []
        for i in 0..levels.size - 1
          selt.push("#{i + 1}: #{levels[i]}, #{enlevels[i]}")
        end
        selt += [p_("Honors", "Add challenge")]
        form.fields[0].options = selt
        form.fields[0].focus
      end
    end
    @sel.focus if @sel != nil
  end
end

class Scene_Honors_Users
  def initialize(honor, user = nil, toscene = nil)
    @honor = honor
    @user = user
    @toscene = toscene
  end

  def main
    usr = srvproc("honors", { "users" => 1, "honor" => @honor })
    @tusers = []
    @tselt = []
    for i in 0...usr[1].to_i
      l = usr[2 + i * 2 + 1].to_i
      o = usr[2 + i * 2]
      @tusers[l] ||= []
      @tselt[l] ||= []
      @tusers[l].push(o.delete("\r\n"))
      @tselt[l].push(@tusers[l].last + " (" + p_("Honors", "level") + (l.to_i + 1).to_s + ")")
    end
    @selt = []
    @users = []
    (@tusers.size - 1).downto(0) { |i|
      if @tusers[i] != nil
        @tusers[i].polsort!
        @tselt[i].polsort!
        @users += @tusers[i]
        @selt += @tselt[i]
      end
    }
    selt = []
    for i in 0...@selt.size
      u = @selt[i]
      selt.push(u + ". " + getstatus(@users[i], false))
    end
    @sel = ListBox.new(selt)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      if escape or arrow_left
        $scene = Scene_Honors.new(@user, @toscene, @honor)
      end
      if enter
        usermenu(@users[@sel.index], false)
      end
      break if $scene != self
    end
  end

  def context(menu)
    menu.useroption(@users[@sel.index])
    menu.option(_("Refresh")) {
      main
    }
  end
end

class Scene_Honors_New
  def main
    @form = Form.new([EditBox.new(p_("Honors", "Badge name"), "", "", true), EditBox.new(p_("Honors", "Badge description"), "", "", true), EditBox.new(p_("Honors", "Badge name in English"), "", "", true), EditBox.new(p_("Honors", "Badge description in English"), "", "", true), Button.new(p_("Honors", "Add")), Button.new(_("Cancel"))])
    loop do
      loop_update
      @form.update
      break if escape or ((enter or space) and @form.index == 5)
      if (enter or space) and @form.index == 4
        honorname = @form.fields[0].text
        honordescription = @form.fields[1].text
        honorenname = @form.fields[2].text
        honorendescription = @form.fields[3].text
        hn = srvproc("honors", { "addhonor" => "1", "honorname" => honorname, "honordescription" => honordescription, "honorenname" => honorenname, "honorendescription" => honorendescription })
        if hn[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Honors", "The badge has been added"))
        end
        speech_wait
        break
      end
    end
    $scene = Scene_Honors.new
  end
end

class Struct_Honor
  attr_accessor :id
  attr_accessor :name
  attr_accessor :description
  attr_accessor :enname
  attr_accessor :endescription
  attr_accessor :levels
  attr_accessor :enlevels
  attr_accessor :level

  def initialize(id = 0)
    @id = id
    @name = ""
    @description = ""
    @enname = ""
    @endescription = ""
    @levels = []
    @enlevels = []
    @level = 0
  end
end
