# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_CallHistory
  def main
    if Session.name == "guest"
      alert(_("This section is unavailable for guests"))
      $scene = Scene_Main.new
      return
    end
    hs = srvproc("calls", { "ac" => "list" })
    if hs[0].to_i < 0
      alert(_("Error"))
      $scene = Scene_Main.new
      return
    end
    @calls = []
    for i in 0...hs[1].to_i
      l = 2 + i * 4
      c = Struct_CallHistory_Call.new
      c.caller = hs[l].delete("\r\n")
      c.user = hs[l + 1].delete("\r\n")
      c.unanswered = hs[l + 2].to_i.to_b
      c.time = hs[l + 3].to_i
      @calls.push(c)
    end
    @refresh = false
    selt = @calls.map { |c|
      r = []
      r[0] = c.caller
      r[1] = p_("CallHistory", "Incoming")
      if c.caller == Session.name
        r[0] = c.user
        r[1] = p_("CallHistory", "Outgoing")
      end
      r[2] = p_("CallHistory", "Answered")
      r[2] = p_("CallHistory", "Unanswered") if c.unanswered
      r[3] = format_date(Time.at(c.time))
      r
    }
    selh = [nil, p_("CallHistory", "Type"), p_("CallHistory", "Status"), p_("CallHistory", "Time")]
    @sel = TableBox.new(selh, selt, 0, p_("CallHistory", "Call History"))
    @sel.bind_context { |menu| context(menu) }
    loop do
      loop_update
      @sel.update
      break if escape
      return main if @refresh
    end
    $scene = Scene_Main.new
  end

  def context(menu)
    return if @calls.size == 0
    c = @calls[@sel.index]
    user = c.user
    user = c.caller if user == Session.name
    menu.useroption(user)
    menu.option(_("Refresh"), nil, "r") { @refresh = true }
  end
end

class Struct_CallHistory_Call
  attr_accessor :caller, :user, :unanswered, :time
end
