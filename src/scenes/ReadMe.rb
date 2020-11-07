# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_ReadMe
  def main
    text = _doc("readme")
    input_text(p_("ReadMe", "Readme"), EditBox::Flags::MultiLine | EditBox::Flags::ReadOnly | EditBox::Flags::MarkDown, text)
    $scene = Scene_Main.new
  end
end
