#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Users_RecentlyActived
  def main
            @users = srvproc("online",{"period"=>"86400"})
            for i in 0..@users.size - 1
      @users[i].delete!("\r")
      @users[i].delete!("\r\n")
    end
        onl = []
    for i in 1..@users.size - 1
      onl.push(@users[i]) if @users[i].size > 0
    end
            selt = []
    for i in 0..onl.size - 1
      selt[i] = onl[i] + "." + " " + getstatus(onl[i])
      end
    @sel = Select.new(selt,true,0,p_("Users_RecentlyActived", "Recently active users"))
        @onl = onl
        @sel.bind_context{|menu|context(menu)}
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