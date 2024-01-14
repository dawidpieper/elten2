# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2023 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_SoundThemes
  def main
    @return = false
    st = Dir.entries(Dirs.soundthemes)
    st.delete("..")
    st.delete(".")
    @soundthemes = []
    for s in st
      f = Dirs.soundthemes + "\\" + s
      if File.file?(f) && File.extname(f).downcase == ".elsnd"
        t = load_soundtheme(f, false)
        @soundthemes.push(t) if t != nil
      end
    end
    @soundthemes.push(SoundTheme.new(p_("SoundThemes", "default"), nil))
    loop_update
    @selt = @soundthemes.map { |s| s.name }
    @sel = ListBox.new(@selt, p_("SoundThemes", "Sound themes"), 0, 0, false)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      update
      break if $scene != self or @return == true
    end
  end

  def update
    $scene = Scene_Main.new if escape
    if enter
      seltheme(@soundthemes[@sel.index])
      return
    end
  end

  def context(menu)
    menu.option(p_("SoundThemes", "Select")) {
      seltheme(@soundthemes[@sel.index])
    }
    menu.option(p_("SoundThemes", "Download sound themes"), nil, "d") {
      stdownload
      @return = true
    }
    menu.option(p_("SoundThemes", "New"), nil, "n") {
      $scene = Scene_Sounds.new("")
    }
    if @sel.index < @soundthemes.size - 1
      menu.option(p_("SoundThemes", "Edit"), nil, "e") {
        $scene = Scene_Sounds.new(@soundthemes[@sel.index].file)
      }
      menu.option(p_("SoundThemes", "Delete")) {
        confirm(p_("SoundThemes", "Are you sure you want to delete this soundtheme?")) {
          File.delete(@soundthemes[@sel.index].file)
          @return = true
          main
        }
      }
    end
  end

  def seltheme(theme)
    confirm(p_("SoundThemes", "Do you wish to use this sound theme?")) {
      if theme.file != "" && theme.file != nil
        Configuration.soundtheme = File.basename(theme.file, ".elsnd")
      else
        Configuration.soundtheme = nil
      end
      use_soundtheme(theme.file)
      writeconfig("Interface", "SoundTheme", Configuration.soundtheme)
      alert(_("Saved"))
      return true
    }
    return false
  end

  def stdownload
    sttemp = srvproc("soundthemes", { "format" => "elsnd", "ac" => "list", "details" => 1 })
    err = sttemp[0].to_i
    if err < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    @std = []
    for i in 0...sttemp[1].to_i
      st = Struct_SoundThemes_SoundTheme.new
      st.file = sttemp[2 + i * 7].delete("\r\n")
      st.size = sttemp[2 + i * 7 + 1].to_i
      st.name = sttemp[2 + i * 7 + 2].delete("\r\n")
      st.stamp = sttemp[2 + i * 7 + 3].delete("\r\n")
      st.user = sttemp[2 + i * 7 + 4].delete("\r\n")
      st.time = sttemp[2 + i * 7 + 5].to_i
      st.count = sttemp[2 + i * 7 + 6].to_i
      @std.push(st)
    end
    sel = ListBox.new([p_("SoundThemes", "Most popular"), p_("SoundThemes", "Recently added")] + @std.map { |s| s.user }.uniq.polsort, p_("SoundThemes", "Available sound themes"))
    sel.disable_item(0) if @std.map { |s| s.count.to_i }.sum < 20
    sel.focus
    loop do
      loop_update
      sel.update
      break if escape
      if sel.expanded? || sel.selected?
        cat = :popular
        cat = :added if sel.index == 1
        cat = @std.map { |s| s.user }.uniq.polsort[sel.index - 2] if sel.index >= 2
        stdownload_category(cat)
        loop_update
        sel.focus
      end
    end
    main
    return
  end

  def stdownload_category(category)
    std = []
    sts = []
    rfr = Proc.new {
      case category
      when :popular
        std = @std.sort_by { |s| s.count }.reverse
      when :added
        std = @std.sort_by { |s| s.time }.reverse
      else
        std = @std.select { |s| s.user == category }.sort_by { |s| s.time }.reverse
      end
      sts = std.map { |s|
        status = p_("SoundThemes", "Not downloaded")
        for st in @soundthemes
          next if st.file == nil
          if File.basename(st.file) == File.basename(s.file)
            if s.stamp.to_i > st.stamp.to_i
              status = p_("SoundThemes", "Update available")
            else
              status = p_("SoundThemes", "Downloaded")
            end
          end
        end
        [s.name, status, s.user, s.count.to_s]
      }
    }
    sel = TableBox.new([nil, p_("SoundThemes", "Status"), p_("SoundThemes", "Author"), p_("SoundThemes", "Used by")], [], 0, p_("Soundthemes", "Select theme to download"), true)
    rfr.call
    sel.rows = sts
    sel.reload
    sel.bind_context { |menu|
      st = std[sel.index]
      menu.option(p_("SoundThemes", "Download")) {
        size = ""
        if st.size < 1024
          size = st.size.to_s + "B"
        elsif st.size < 1048576
          size = (((st.size / 1024.0) * 10.0).round / 10.0).to_s + "kB"
        else
          size = (((st.size / 1048576.0) * 10.0).round / 10.0).to_s + "MB"
        end
        confirm(p_("SoundThemes", "Do you want to download theme %{name}? Need to download %{size} of data.") % { "name" => st.name, "size" => size }) {
          downloadtheme(st)
          rfr.call
          sel.rows = sts
          sel.reload
        }
      }
      if st.user == Session.name || Session.moderator == 1
        menu.option(p_("SoundThemes", "Delete"), nil, :del) {
          confirm(p_("SoundThemes", "Are you sure you want to delete sound theme %{name} from the server?") % { "name" => st.name }) {
            srvproc("soundthemes", { "format" => "elsnd", "ac" => "delete", "theme" => File.basename(st.file, ".elsnd") })
            @std.delete(st)
            return
          }
        }
      end
    }
    sel.focus
    loop do
      loop_update
      sel.update
      if escape || sel.collapsed?
        break
      end
      if enter and std.size > 0
        st = std[sel.index]
        size = ""
        if st.size < 1024
          size = st.size.to_s + "B"
        elsif st.size < 1048576
          size = (((st.size / 1024.0) * 10.0).round / 10.0).to_s + "kB"
        else
          size = (((st.size / 1048576.0) * 10.0).round / 10.0).to_s + "MB"
        end
        confirm(p_("SoundThemes", "Do you want to download theme %{name}? Need to download %{size} of data.") % { "name" => st.name, "size" => size }) {
          downloadtheme(st)
          rfr.call
          sel.rows = sts
          sel.reload
        }
      end
    end
  end

  def downloadtheme(st)
    download_file($url + "/soundthemes/" + st.file, Dirs.soundthemes + "/" + st.file.delete("/\\"), true, true, true)
    oldst = @soundthemes.find { |s| s.file != nil && File.basename(s.file) == File.basename(st.file) }
    @soundthemes.delete(oldst) if oldst != nil
    @soundthemes.push(st)
    alert(_("Saved"))
  end
end

class Struct_SoundThemes_SoundTheme
  attr_accessor :name, :file, :size, :stamp, :user, :time, :count
end
