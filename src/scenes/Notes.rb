# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Notes
  def main(index = 0)
    if Session.name == "guest"
      alert(_("This section is unavailable for guests"))
      $scene = Scene_Main.new
      return
    end
    nt = srvproc("notes", { "get" => "1" })
    if nt[0].to_i < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    t = 0
    @notes = []
    d = 0
    for i in 2..nt.size - 1
      case t
      when 0
        @notes[d] = Struct_Note.new(nt[i].to_i)
        t += 1
      when 1
        @notes[d].name = nt[i].delete("\r\n")
        t += 1
      when 2
        @notes[d].author = nt[i].delete("\r\n")
        t += 1
      when 3
        @notes[d].created = Time.at(nt[i].delete("\r\n").to_i)
        t += 1
      when 4
        @notes[d].modified = Time.at(nt[i].delete("\r\n").to_i)
        t += 1
      when 5
        if nt[i].delete("\r\n") == "\004END\004"
          t = 0
          d += 1
        else
          @notes[d].text += nt[i]
        end
      end
    end
    selt = []
    for n in @notes
      selt.push(n.name + "\r\n#{p_("Notes", "Author")}: " + n.author + "\r\n#{p_("Notes", "Modified")}: " + format_date(n.modified, false, false))
    end
    @sel = ListBox.new(selt, p_("Notes", "Notes"), index)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      $scene = Scene_Main.new if escape
      if enter and @notes.size > 0
        show(@notes[@sel.index])
        @sel.focus if @refresh != true
      end
      if @refresh == true
        @refresh = false
        main(@sel.index)
        return
      end
      break if $scene != self
    end
  end

  def context(menu)
    if @sel.index < @notes.size
      note = @notes[@sel.index]
      menu.option(p_("Notes", "Read")) {
        show(note)
      }
      menu.option(p_("Notes", "Edit"), nil, "e") {
        show(note, true)
        @sel.focus if @refresh != true
      }
      if note.author == Session.name
        menu.option(_("Delete"), nil, :del) {
          delete(note)
        }
        menu.option(p_("Notes", "Rename")) {
          rename(note)
        }
      else
        menu.option(p_("Notes", "Don't share this note"), nil, :del) {
          delete(note)
        }
      end
    end
    menu.option(p_("Notes", "New note"), nil, "n") {
      $scene = Scene_Notes_New.new
    }
    menu.option(_("Refresh"), nil, "r") {
      main
    }
  end

  def show(note, edit = false)
    id = note.id
    changed = false
    shares = []
    nt = srvproc("notes", { "getshares" => "1", "noteid" => id })
    if nt[0].to_i < 0
      alert(_("Error"))
      return
    end
    if nt.size > 1
      for t in nt[1..nt.size - 1]
        sh = t.delete("\r\n")
        sh = note.author if sh == Session.name
        shares.push(sh)
      end
    end
    sharest = shares + []
    @fields = [EditBox.new(note.name, EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly, note.text, true), Button.new(p_("Notes", "Edit")), ListBox.new(sharest, p_("Notes", "Note shared with"), 0, 0, true), nil, Button.new(_("Cancel"))]
    @fields[0].on(:change) { changed = true }
    @form = Form.new(@fields)
    @form.bind_context { |menu|
      if note.author == Session.name
        menu.option(p_("Notes", "Share")) {
          inpt = EditBox.new(p_("Notes", "Who do you want to share this note with?"))
          loop do
            loop_update
            inpt.update
            if escape
              dialog_close
              break
            end
            inpt.settext(selectcontact) if arrow_up or arrow_down
            if enter
              user = inpt.text.delete("\r\n").gsub("\004LINE\004", "")
              user = finduser(user) if finduser(user).upcase == user.upcase
              if user_exists(user) == false
                alert(p_("Notes", "User cannot be found"))
              else
                nt = srvproc("notes", { "noteid" => note.id, "addshare" => "1", "user" => user })
                if nt[0].to_i < 0
                  alert(_("Error"))
                else
                  speech(p_("Notes", "From now on you share this note with %{user}") % { "user" => user })
                  speech_wait
                  shares.push(user)
                  sharest = shares
                  @form.fields[2].options = sharest
                  break
                end
              end
            end
          end
        }
      end
    }
    if edit == true
      @form.fields[0].flags = EditBox::Flags::MultiLine
      @form.fields[1] = Button.new(_("Save"))
    end
    @form.fields[3] = Button.new(_("Delete")) if note.author == Session.name
    loop do
      loop_update
      @form.update
      if escape or ((enter or space) and @form.index == 4)
        if changed == false or confirm(p_("Notes", "Are you sure you want to close this note without saving?")) == 1
          break
        end
      end
      if (((enter or space) and @form.index == 1)) or ($keyr[0x11] && !$keyr[0x12] && !$keyr[0x10] && $key[69])
        if edit == false
          edit = true
          @form.fields[0].flags = EditBox::Flags::MultiLine
          @form.index = 0
          @form.fields[0].focus
          @form.fields[1] = Button.new(_("Save"))
        else
          text = @form.fields[0].text
          bufid = buffer(text)
          nt = srvproc("notes", { "edit" => "1", "buffer" => bufid, "noteid" => note.id })
          if nt[0].to_i < 0
            alert(_("Error"))
          else
            alert(p_("Notes", "The note has been modified."))
            @refresh = true
            break
          end
        end
      end
      if $key[0x2e] and @form.index == 2 and note.author == Session.name and @form.fields[2].index < shares.size
        if confirm(p_("Notes", "Do you want to stop sharing this note with %{user}?") % { "user" => @form.fields[2].options[@form.fields[2].index] }) == 1
          user = shares[@form.fields[2].index]
          nt = srvproc("notes", { "noteid" => note.id, "delshare" => "1", "user" => user })
          if nt[0].to_i < 0
            alert(_("Error"))
          else
            speech(p_("Notes", "You no longer share this note with %{user}") % { "user" => user })
            shares.delete(user)
            sharest = shares
            @form.fields[2].index -= 1
            @form.fields[2].index = 0 if @form.fields[2].index < 0
            @form.fields[2].options = sharest
            speech_wait
          end
        end
        @form.fields[2].focus
      end
      if (enter or space) and @form.index == 3
        if delete(note) == true
          break
        else
          @form.fields[3].focus
        end
      end
    end
  end

  def delete(note)
    id = note.id
    if note.author == Session.name
      cnf = p_("Notes", "Do you really want to delete %{name}?") % { "name" => note.name }
    else
      cnf = p_("Notes", "Do you really want to end sharing %{name}? It will be deleted from your notes list.") % { "name" => note.name }
    end
    if confirm(cnf) == 0
      return false
    else
      nt = srvproc("notes", { "delete" => "1", "noteid" => id })
      if nt[0].to_i < 0
        alert(_("Error"))
        return false
      else
        alert(p_("Notes", "The note has been deleted."))
      end
      @refresh = true
      return true
    end
  end

  def rename(note)
    name = input_text(p_("Notes", "New note name"), 0, note.name, true)
    if name != nil and name != note.name
      if srvproc("notes", { "rename" => 1, "noteid" => note.id, "newname" => name })[0].to_i < 0
        alert(_("Error"))
      else
        alert(p_("Notes", "The note has been renamed"))
      end
    end
    @refresh = true
  end
end

class Scene_Notes_New
  def main
    @fields = [EditBox.new(p_("Notes", "note title"), 0, "", true), EditBox.new(p_("Notes", "Note content"), EditBox::Flags::MultiLine, "", true), Button.new(p_("Notes", "Add")), Button.new(_("Cancel"))]
    @form = Form.new(@fields)
    btn = @form.fields[2]
    loop do
      loop_update
      if (@form.fields[0].text == "" or @form.fields[1].text == "") and @form.fields[2] != nil
        btn = @form.fields[2]
        @form.fields[2] = nil
      elsif (@form.fields[0].text != "" and @form.fields[1].text != "") and @form.fields[2] == nil
        @form.fields[2] = btn
      end
      @form.update
      break if escape or ((enter or space) and @form.index == 3)
      if ((enter or space) and @form.index == 2)
        name = @form.fields[0].text
        text = @form.fields[1].text
        bufid = buffer(text)
        nt = srvproc("notes", { "create" => "1", "notename" => name, "buffer" => bufid })
        if nt[0].to_i < 0
          alert(_("Error"))
        else
          alert(p_("Notes", "The note has been created"))
          break
        end
      end
    end
    $scene = Scene_Notes.new
  end
end

class Struct_Note
  attr_accessor :id
  attr_accessor :name
  attr_accessor :text
  attr_accessor :author
  attr_accessor :modified
  attr_accessor :created

  def initialize(id = 0)
    @id = id
    @created = Time.now
    @modified = Time.now
    @author = Session.name
    @text = ""
    @name = ""
  end
end
