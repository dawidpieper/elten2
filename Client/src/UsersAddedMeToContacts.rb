#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Users_AddedMeToContacts
  def initialize(new=false)
    @new=new
    end
  def main
    if Session.name=="guest"
      alert(_("UsersAddedMeToThis section is unavailable for guests"))
      $scene=Scene_Main.new
      return
      end
      if @new==false          
      @usr = srvproc("contacts_addedme",{})
    else
      @usr = srvproc("contacts_addedme",{"new"=>"1"})
      end
        for i in 0..@usr.size - 1
      @usr[i].delete!("\r")
      @usr[i].delete!("\r\n")
    end
        usr = []
    for i in 1..@usr.size - 1
      usr.push(@usr[i]) if @usr[i].size > 0
    end
    usr.polsort!
    selt = []
    for i in 0..usr.size - 1
      selt[i] = usr[i] + "." + " " + getstatus(usr[i])
      end
    header=p_("UsersAddedMeToContacts", "Users who added me to their contacts list")
    header="" if @new==true
      @sel = ListBox.new(selt,header)
      @sel.bind_context{|menu|context(menu)}
    @user = usr
    loop do
loop_update
      @sel.update
      if escape
        srvproc("contacts_addedme",{"new"=>"2"})
        if @new==false
        $scene = Scene_Main.new
      else
        $scene=Scene_WhatsNew.new
        end
        break
      end
      if enter
                usermenu(@user[@sel.index],false)
        end
      break if $scene != self
      end
    end
    def context(menu)
menu.useroption(@user[@sel.index])
menu.option(_("Refresh"), nil, "r") {
main
}
end
end