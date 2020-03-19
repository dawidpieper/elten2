#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_UserSearch
  def main
    usr=""
    while usr==""
      usr=input_text(p_("UserSearch", "Search users"),"ACCEPTESCAPE")
    end
    if usr=="\004ESCAPE\004"
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
@sel=Select.new(selt,true,0,p_("UserSearch", "Found items"))
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