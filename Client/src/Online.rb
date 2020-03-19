#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Online
  def main
                    @online = srvproc("online",{})
    @onl=[]
            for o in @online[1..-1]
      @onl.push(o.delete("\r\n"))
    end
    @onl.polsort!
                selt = []
    for u in @onl
      selt.push(u + ". " + getstatus(u,false))
      end
    @sel = Select.new(selt,true,0,p_("Online", "Who is on line?"))
    @sel.bind_context {|menu|context(menu)}
            loop do
loop_update
      @sel.update
      if escape
        $scene = Scene_Main.new
        break
      end
      if enter
                usermenu(@onl[@sel.index],false)
        end
      break if $scene != self
      end
    end
    def context(menu)
menu.useroption(@onl[@sel.index])
menu.option(_("Refresh")) {
            initialize
  main
}
end
end