# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_UserSearch
  def main
    usr=""
    while usr==""
      usr=input_text(p_("UserSearch", "Search users"),0,"",true)
    end
    if usr==nil
      $scene=Scene_Main.new
      return
      end
    usf=srvproc("user_search",{"search"=>usr})    
if usf[0].to_i<0
  alert(_("Error"))
    $scene=Scene_Main.new
    return
  end
@results=[]
if usf[1].to_i==0
  alert(p_("UserSearch", "No match found."))
  $scene=Scene_Main.new
  return
end
for u in usf[2..1+usf[1].to_i]
  @results.push(u.delete("\r\n"))
end
selt=[]
for r in @results
  selt.push(r+".\r\n"+getstatus(r))
  end
@sel=ListBox.new(selt,p_("UserSearch", "Found items"))
@sel.bind_context{|menu|context(menu)}
loop do
  loop_update
  @sel.update
  usermenu(@results[@sel.index]) if enter
  $scene=Scene_Main.new if escape
  break if $scene!=self
  end
end
def context(menu)
menu.useroption(@results[@sel.index])
menu.option(p_("UserSearch", "Search again")) {
initialize
main
}
end
end