# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_SpeedTest
  def main
    @form = Form.new([ListBox.new([p_("SpeedTest", "Session refresh"), p_("SpeedTest", "What's new"), p_("SpeedTest", "Forum structure (uncompressed)"), p_("SpeedTest", "Forum structure (compressed)"), p_("SpeedTest", "Messages recipients"), p_("SpeedTest", "Blogs list")], p_("SpeedTest", "Unit to test"), 0, 0, true), EditBox.new(p_("SpeedTest", "Number of attempts to perform"), EditBox::Flags::Numbers, "10", true), Button.new(p_("SpeedTest", "Start")), Button.new(_("Cancel"))])
    loop do
      loop_update
      @form.update
      break if $scene != self
      $scene = Scene_Main.new if ((space or enter) and @form.index == 3) or escape
      if @form.fields[2].pressed? and @form.fields[1].text.to_i > 0
        mod = ""
        params = {}
        case @form.fields[0].index
        when 0
          mod = "active"
        when 1
          mod = "agent"
        when 2
          mod = "forum_struct"
        when 3
          mod = "forum_struct"
          params = { "zs" => 1, "useflags" => 1 }
        when 4
          mod = "messages_conversations"
        when 5
          mod = "blog_list"
        end
        speak(p_("SpeedTest", "Performing test, please wait"))
        waiting
        n = @form.fields[1].text.to_i
        times = []
        n.times {
          t = srvproc(mod, params, 3, nil, false)
          times.push(t)
          loop_update
        }
        waiting_end
        result = "#{p_("SpeedTest", "Average time")}: #{((times.sum).to_f / n.to_f * 1000).round}ms
#{p_("SpeedTest", "Minimum time")}: #{((times.min) * 1000).round}ms
#{p_("SpeedTest", "Maximum time")}: #{((times.max) * 1000).round}ms

"
        for i in 0...n
          result += (i + 1).to_s + ". " + (times[i] * 1000).round.to_s + "ms\r\n"
        end
        input_text(p_("SpeedTest", "Test results"), EditBox::Flags::ReadOnly, result)
        @form.focus
      end
    end
  end
end
