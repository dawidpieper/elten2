# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Sounds
  def initialize(theme = nil)
    @theme = theme
  end

  def main
    @soundnames = {
      "SE/cancel" => p_("Sounds", "Operation cancelled"),
      "BGS/dialog_background" => p_("Sounds", "Background of dialog windows"),
      "SE/dialog_open" => p_("Sounds", "Dialog window opened"),
      "SE/dialog_close" => p_("Sounds", "Dialog window closed"),
      "BGS/menu_background" => p_("Sounds", "Menu Background"),
      "SE/menu_open" => p_("Sounds", "Menu opened"),
      "SE/menu_close" => p_("Sounds", "Menu closed"),
      "SE/form_marker" => p_("Sounds", "Marker of a form"),
      "SE/list_marker" => p_("Sounds", "Marker of a listbox"),
      "SE/list_multimarker" => p_("Sounds", "Marker of a multiselect listbox"),
      "SE/list_focus" => p_("Sounds", "Focus move on a listbox"),
      "SE/border" => p_("Sounds", "Border of a listbox"),
      "SE/list_submenu" => p_("Sounds", "Expandable item on a listbox"),
      "SE/list_expand" => p_("Sounds", "Item expanded"),
      "SE/list_collapse" => p_("Sounds", "Item collapsed"),
      "SE/list_select" => p_("Sounds", "Item selected"),
      "SE/list_checked" => p_("Sounds", "Checked item on a listbox"),
      "SE/list_unchecked" => p_("Sounds", "Unchecked item on a listbox"),
      "SE/list_new" => p_("Sounds", "New or updated item on a listbox"),
      "SE/list_attachment" => p_("Sounds", "Item with attachment on a listbox"),
      "SE/list_closed" => p_("Sounds", "Closed item on a listbox"),
      "SE/list_pinned" => p_("Sounds", "Pinned item on a listbox"),
      "SE/file_archive" => p_("Sounds", "Compressed file on a files tree"),
      "SE/file_audio" => p_("Sounds", "Audio file on a files tree"),
      "SE/file_dir" => p_("Sounds", "Directory on a files tree"),
      "SE/file_document" => p_("Sounds", "Document on a files tree"),
      "SE/file_text" => p_("Sounds", "Text file on a files tree"),
      "SE/edit_marker" => p_("Sounds", "Marker of an editbox in a form"),
      "BGS/edit_checked" => p_("Sounds", "A piece of text in an editbox is checked"),
      "SE/edit_bigletter" => p_("Sounds", "Capitalized letter in an editbox"),
      "SE/edit_delete" => p_("Sounds", "Delete of a text in an editbox"),
      "SE/edit_endofline" => p_("Sounds", "End of line in an editbox"),
      "SE/edit_password_char" => p_("Sounds", "Password character in an editbox"),
      "SE/edit_space" => p_("Sounds", "Space in an editbox"),
      "SE/button_marker" => p_("Sounds", "Marker of a button in a form"),
      "SE/checkbox_marker" => p_("Sounds", "Marker of a checkbox in a form"),
      "SE/login" => p_("Sounds", "User signed in or Elten window focused"),
      "SE/logout" => p_("Sounds", "User signed out or Elten closed"),
      "SE/minimize" => p_("Sounds", "Elten minimized into tray"),
      "SE/chat_message" => p_("Sounds", "New chat message"),
      "SE/messages_update" => p_("Sounds", "Messages window updated"),
      "SE/new" => p_("Sounds", "New event"),
      "SE/notification_birthday" => p_("Sounds", "Notification: birthday of a friend"),
      "SE/notification_blogcomment" => p_("Sounds", "Notification: new comment on your blog"),
      "SE/notification_followedblog" => p_("Sounds", "Notification: new post on a followed blog"),
      "SE/notification_followedforum" => p_("Sounds", "Notification: new thread on a followed forum"),
      "SE/notification_followedforumpost" => p_("Sounds", "Notification: new post on a followed forum"),
      "SE/notification_followedthread" => p_("Sounds", "Notification: new post in a followed thread"),
      "SE/notification_friend" => p_("Sounds", "Notification: new friend"),
      "SE/notification_mention" => p_("Sounds", "Notification: new mention"),
      "SE/notification_message" => p_("Sounds", "Notification: new message"),
      "SE/recording_start" => p_("Sounds", "Recording started"),
      "SE/recording_stop" => p_("Sounds", "Recording stopped"),
      "SE/right" => p_("Sounds", "Error"),
      "SE/clock" => p_("Sounds", "Clock sound"),
      "BGS/alarm" => p_("Sounds", "Alarm Sound"),
      "BGS/waiting" => p_("Sounds", "Waiting for an action to be completed"),
      "SE/signal" => p_("Sounds", "Signal")
    }
    if @theme != nil
      if @theme != "" and FileTest.exists?(Dirs.soundthemes + "\\" + @theme + "\\__name.txt")
        @name = readfile(Dirs.soundthemes + "\\" + @theme + "\\__name.txt")
        @changed = false
      else
        @name = input_text(p_("Sounds", "Type name of the soundtheme"), 0, "by #{Session.name}", true)
        return $scene = Scene_SoundThemes.new if @name == nil
        n = @name.split(" ")
        ind = n.size
        for i in 0...n.size
          ind = i if n[i].downcase == "by"
        end
        for i in 0...n.size
          break if i == ind
          s = n[i]
          t = s.split("")[0].upcase + s.split("")[1..-1].join.downcase
          @theme += t
        end
        @theme = @theme.delspecial
        @changed = true
      end
    end
    @snd = []
    for file in @soundnames.keys
      if FileTest.exists?("Audio/#{file}.ogg")
        @snd.push(Struct_Sounds_Sound.new(file + ".ogg", @soundnames[file], @theme))
      else
      end
    end
    return $scene = Scene_Main.new if @snd.size == 0
    h = p_("Sounds", "Sounds guide, press space to play")
    h = p_("Sounds", "Editing sound theme %{theme}") % { "theme" => @name } if @theme != nil
    @sel = ListBox.new(@snd.map { |o| o.description }, h, 0, ListBox::Flags::Silent, true)
    @fields = [@sel, Button.new(p_("Sounds", "Play")), Button.new(p_("Sounds", "Stop"))]
    if @theme != nil
      @fields.push(Button.new(p_("Sounds", "Change")))
      @fields.push(Button.new(p_("Sounds", "Save")))
      @fields.push(Button.new(p_("Sounds", "Export"))) if @changed == false
    end
    @form = Form.new(@fields)
    a = nil
    loop do
      loop_update
      @form.update
      break if escape
      if (space and @form.index == 0) or @form.fields[1].pressed?
        a.close if a != nil
        a = Bass::Sound.new(@snd[@sel.index].path)
        a.volume = 0.01 * Configuration.volume
        a.play
      end
      if @form.fields[2].pressed?
        if a != nil
          a.close
          a = nil
        end
      end
      if @theme != nil
        if (enter and @form.index == 0) or @form.fields[3].pressed?
          file = getfile(p_("Sounds", "Select new sound"), "", false, nil, [".ogg", ".mp3", ".wav", ".opus", ".aac", ".wma", ".m4a"])
          loop_update
          if file != nil
            @snd[@sel.index].path = file
            @form.fields[5] = nil
            @changed = true
          end
          @form.fields[@form.index].focus
        end
        if @form.fields[4].pressed?
          save
          @changed = false
          @form.fields[5] = Button.new(p_("Sounds", "Export"))
          @form.fields[@form.index].focus
        end
        if @form.fields[5] != nil and @form.fields[5].pressed?
          loc = getfile(p_("Sounds", "Where to save this theme"), Dirs.user + "\\", true, "Documents")
          if loc != nil
            compress(Dirs.soundthemes + "\\" + @theme, loc + "\\" + @theme + ".7z")
          end
          @form.fields[@form.index].focus
        end
      end
    end
    if @changed and @theme != nil
      confirm(p_("Sounds", "Do you want to save this soundtheme?")) { save }
    end
    a.close if a != nil
    if @theme == nil
      $scene = Scene_Main.new
    else
      $scene = Scene_SoundThemes.new
    end
  end

  def save
    waiting
    createdirifneeded(Dirs.soundthemes + "\\" + @theme)
    createdirifneeded(Dirs.soundthemes + "\\" + @theme + "\\BGS")
    createdirifneeded(Dirs.soundthemes + "\\" + @theme + "\\SE")
    @snd.each { |s|
      if s.path != s.defpath
        if File.extname(s.defpath).downcase == ".ogg"
          copyfile(s.path, Dirs.soundthemes + "\\" + @theme + "\\" + s.stfile + "")
        else
          VorbisRecorder.encode_file(s.path, Dirs.soundthemes + "\\" + @theme + "\\" + s.stfile)
        end
        s.path = Dirs.soundthemes + "\\" + @theme + "\\" + s.stfile
        s.defpath = s.path
      end
    }
    writefile(Dirs.soundthemes + "\\" + @theme + "\\__name.txt", @name)
    waiting_end
  end
end

class Struct_Sounds_Sound
  attr_reader :description, :stfile
  attr_accessor :path, :defpath

  def initialize(f, d, t = nil)
    @description = d
    sp = Configuration.soundthemepath
    sp = Dirs.soundthemes + "\\" + t if t != nil
    @path = sp + "/" + f
    @path = "Audio/" + f if !FileTest.exists?(@path)
    @defpath = @path
    @stfile = f
  end
end
