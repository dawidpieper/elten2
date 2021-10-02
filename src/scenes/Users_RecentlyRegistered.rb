# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Users_RecentlyRegistered
  def main
    @users = srvproc("recentlyregistered", {})
    for i in 0..@users.size - 1
      @users[i].delete!("\r")
      @users[i].delete!("\r\n")
    end
    onl = []
    for i in 1..50
      onl.push(@users[i]) if @users[i] != nil and @users[i].size > 0
    end
    selt = []
    for i in 0..onl.size - 1
      selt[i] = onl[i] + "." + " " + getstatus(onl[i])
    end
    @sel = ListBox.new(selt, p_("Users_RecentlyRegistered", "Recently registered users"), 0, 0, false)
    @onl = onl
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      if escape
        $scene = Scene_Main.new
        break
      end
      if enter
        usermenu(@onl[@sel.index], false)
      end
      break if $scene != self
    end
  end

  def context(menu)
    menu.useroption(@onl[@sel.index])
    menu.option(_("Refresh"), nil, "r") {
      initialize
      main
    }
  end
end
