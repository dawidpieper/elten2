# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Online
  def main
    @online = srvproc("online", {})
    @onl = []
    for o in @online[1..-1]
      @onl.push(o.delete("\r\n"))
    end
    @onl.polsort!
    selt = []
    for u in @onl
      selt.push(u + ". " + getstatus(u, false))
    end
    cnt = @onl.size
    @sel = ListBox.new(selt, (np_("Online", "%{count} user online", "%{count} users online", cnt)) % { "count" => cnt })
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
