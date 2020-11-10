# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Portable
  def main
    @form = Form.new([FilesTree.new(p_("Portable", "Destination"), Dirs.user, true, true, "Documents"), CheckBox.new(p_("Portable", "Copy current settings")), CheckBox.new(p_("Portable", "Copy downloaded soundthemes")), Button.new(p_("Portable", "continue")), Button.new(_("Cancel"))])
    loop do
      loop_update
      @form.update
      if escape or ((enter or space) and @form.index == 4)
        $scene = Scene_Main.new
        return
        break
      end
      if (enter or space) and @form.index == 3
        break
      end
    end
    waiting
    speak(p_("Portable", "Please wait while files are being prepared"))
    @destdir = @form.fields[0].path + "\\" + @form.fields[0].file + "\\Elten_#{$version.to_s}_#{if $alpha > 0; "_RC" + $alpha.to_s; elsif $beta > 0; "_B" + $beta.to_s; else; ""; end}_portable"
    copier
    loop_update
    speech_wait
    if @form.fields[1].checked == 1 or @form.fields[2].checked == 1
      Dir.mkdir("#{@destdir}/eltendata") if FileTest.exists?("#{@destdir}/eltendata") == false
      if @form.fields[1].checked == 1
        speak(p_("Portable", "Copying settings"))
        copyfile(Dirs.eltendata + "\\elten.ini", @destdir + "\\eltendata/elten.ini")
        speech_wait
        if Configuration.voice != -1 and Configuration.voice != -3
          waiting_end
          v = selector([p_("Portable", "Use a screenreader or a system default voice"), p_("Portable", "Reset synthesizer settings"), p_("Portable", "Ask each time"), p_("Portable", "Use current setting")], p_("Portable", "If you use a created copy of Elten on another computer, the voice settings may  not work properly. This is especially noticeable in a situation when another  computer has other voices installed. How do you want to configure the generated  version?"), 0, 3, 1)
          value = 0
          value = "NVDA" if v == 0
          value = "" if v == 1
          value = "?" if v == 2
          writeini("#{@destdir}/eltendata/elten.ini", "Voice", "Voice", value.to_s) if value != 0
          writeini("#{@destdir}/elten.ini", "Interface", "SoundTheme", "")
          waiting
        end
      end
      if @form.fields[2].checked == 1
        speak(p_("Portable", "Copying sound themes"))
        copier(".", "/eltendata/soundthemes", "", Dirs.soundthemes + "/")
        speech_wait
      end
    end
    writeini("#{@destdir}\\elten.ini", "Elten", "Portable", "1")
    waiting_end
    alert(p_("Portable", "Elten Portable version created successfully."))
    $scene = Scene_Main.new
  end

  def copier(dir = ".", dest = "", incl = "", start = "")
    loop_update
    Dir.mkdir("#{@destdir}" + dest) if dir == "." and FileTest.exists?("#{@destdir}" + dest) == false
    Dir.mkdir("#{@destdir}" + dest + "/" + dir) if dir != "." and FileTest.exists?("#{@destdir}" + dest + "/" + dir) == false
    dr = Dir.entries(start + dir)
    dr.delete(".")
    dr.delete("..")
    for t in dr
      f = dir + "/" + t
      f = t if dir == "."
      if File.file?(start + f)
        Win32API.new("kernel32", "CopyFile", "ppi", "i").call(start + f, "#{@destdir}" + dest + "/" + f, 0) if f.include?("tmp") == false and f.include?(Dirs.temp + "") == false and t.include?(incl)
      elsif File.directory?(start + f)
        if f != Dirs.temp + "" and f.downcase.include?("kopia") == false
          copier(f, dest, incl, start)
        end
      end
    end
  end
end
