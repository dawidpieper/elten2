#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Users
  def main
            @users = srvproc("users",{})
        err = @users[0].to_i
    case err
    when -1
      alert(_("Database Error"))
      $scene = Scene_Main.new
      return
      when -2
        alert(_("Token expired"))
        $scene = Scene_Main.new
        return
        when -3
          alert(_("You haven't permissions to do this"))
          $scene = Scene_Main.new
          return
    end
        for i in 0..@users.size - 1
      @users[i].delete!("\r")
      @users[i].delete!("\r\n")
    end
        usr = []
    for i in 1..@users.size - 1
      usr.push(@users[i]) if @users[i].size > 0
    end
    usr.polsort!
        selt = []
    for i in 0..usr.size - 1
      selt[i] = usr[i] + ". " + getstatus(usr[i])
      end
    @sel = ListBox.new(selt,p_("Users", "List of users"))
        @usr = usr
    @sel.bind_context{|menu|context(menu)}
    loop do
loop_update
      @sel.update
      if escape
        $scene = Scene_Main.new
        break
      end
      if enter
                usermenu(@usr[@sel.index],false)
                        end
      break if $scene != self
      end
    end
    def context(menu)
menu.useroption(@usr[@sel.index])
menu.option(_("Refresh"), nil, "r") {
main
}
end
end