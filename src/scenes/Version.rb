# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2024 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Version
  def main
    txt = "ELTEN #{Elten.version.to_s.delete(".").split("").join(".")}"
    txt += " BETA #{Elten.beta.to_s}" if Elten.isbeta == 1
    txt += " RC #{Elten.alpha.to_s}" if Elten.isbeta == 2
    txt += "\r\nBuild ID: #{Elten.build_id}\r\nBuild Date: #{Elten.build_date}\r\n"
    txt += "Copyright (C) 2014-2024 Dawid Pieper\r\nElten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. \r\nElten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details."
    txt += "\r\n\r\n"
    fruby = ChildProc.new("bin\\ruby -v")
    f7zip = ChildProc.new("bin\\7za")
    loop_update while fruby.avail == 0
    txt += fruby.read
    txt += "BASS Audio Library " + Bass.version.to_s + " (Copyright (c) 1999-2020 Un4seen Developments Ltd. All rights reserved.)\r\n"
    txt += Win32API.new("bin\\libvorbis.dll", "vorbis_version_string", "", "p").call + "\r\n"
    txt += Win32API.new("bin\\opus.dll", "opus_get_version_string", "", "p").call + "\r\n"
    txt += buildversion("bin\\libssl-1_1.dll") + "\r\n"
    txt += "NVDA Helper Remote " + buildversion("bin\\nvdaHelperRemote.dll") + "\r\n"
    loop_update while f7zip.avail == 0
    txt += f7zip.read.split("\n")[1].delete("\r") + "\r\n"
    input_text("ELTEN", EditBox::Flags::ReadOnly | EditBox::Flags::MultiLine, txt)
    $scene = Scene_Main.new
  end

  private

  def buildversion(file)
    str = getfileversioninfo(file, "FileDescription")
    str += " "
    str += getfileversioninfo(file, "ProductVersion") || ""
    str += " ("
    str += getfileversioninfo(file, "LegalCopyright") || ""
    str += ")"
    return str
  end
end
