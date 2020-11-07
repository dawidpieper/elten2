# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Version
  def main
    txt = "ELTEN #{Elten.version.to_s.delete(".").split("").join(".")}"
    txt += " BETA #{Elten.beta.to_s}" if Elten.isbeta == 1
    txt += " RC #{Elten.beta.to_s}" if Elten.isbeta == 2
    txt += "\r\nBuild ID: #{Elten.build_id}\r\nBuild Date: #{Elten.build_date}\r\n\r\n"
    fruby = ChildProc.new("bin\\ruby -v")
    f7zip = ChildProc.new("bin\\7z")
    loop_update while fruby.avail == 0
    txt += fruby.read + "\r\n\r\n"
    loop_update while f7zip.avail == 0
    txt += f7zip.read.split("\n")[1].delete("\r") + "\r\n"
    input_text("ELTEN", EditBox::Flags::ReadOnly | EditBox::Flags::MultiLine, txt)
    $scene = Scene_Main.new
  end
end
