# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2022 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Users_Sponsors
  def main
    adm = srvproc("admins", { "cat" => "sponsors" })
    @users = adm[1..-1].map { |a| a.delete("\r\n") }
    @users.polsort!
    selt = @users.map { |u| u + ". " + getstatus(u) }
    @sel = ListBox.new(selt, p_("Users_Sponsors", "Sponsors"), 0, 0, false)
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      if escape
        $scene = Scene_Main.new
        break
      end
      if enter
        usermenu(@users[@sel.index], false)
      end
      break if $scene != self
    end
  end

  def context(menu)
    menu.useroption(@users[@sel.index])
    menu.option(_("Refresh"), nil, "r") {
      main
    }
  end
end
