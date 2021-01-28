# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_Clock
    def main
        @field=[]
              @field[0]=ListBox.new([],p_("Clock", "Alarms"),0,0,true)
              @field[1]=Button.new(_("Save"))
              @field[2]=Button.new(_("Cancel"))
              @alarms=[]
              @alarms=load_data(Dirs.eltendata+"\\alarms.dat") if FileTest.exists?(Dirs.eltendata+"\\alarms.dat")
              sel=[]
              for a in @alarms
                  sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "repeated");end}")
                end
                @field[0].options=sel
                @form=Form.new(@field)
                @form.bind_context{|menu|context(menu)}
                loop do
                    loop_update
                      @form.update
                        if escape or @form.fields[2].pressed?
                              $scene=Scene_Main.new
                                      return
                                              break
                                            end
                                            if enter and @form.index==0
                                              editalarm(@form.fields[0].index)
                                              end
                                                                           if @form.fields[1].pressed?
                                                                                 save_data(@alarms,Dirs.eltendata+"\\alarms.dat")
                                                                                   alert(_("Saved"))
                                                                                     $scene=Scene_Main.new
                                                                                       break
                                                                                     end
                                                                                   end
                                                                                 end
                                                                                 def context(menu)
                                                                                   if @alarms.size>0
                                                                                     menu.option(p_("Clock", "Edit alarm")) {
                                                                                     editalarm(@form.fields[0].index)
                                                                                     }
                                                                                                                                                                          menu.option(p_("Clock", "Delete alarm"), nil, :del) {
                                                                                     deletealarm(@form.fields[0].index)
                                                                                     }
                                                                                     end
                                                                                   menu.option(p_("Clock", "New alarm"), nil, "n") {
                                                                                   editalarm
                                                                                   }
                                                                                   end
                                                                                 def editalarm(alarmindex=nil)
                                                                                   alarmindex=@alarms.size if alarmindex==nil
                                                                                                                                   a=[Time.now.hour,Time.now.min,0]
                                                a=@alarms[@field[0].index] if @alarms[@field[0].index]!=nil
                                                c=[]
                                                for i in 0..59
                                                    c.push(i.to_s)
                                                  end
                                                  form=Form.new([ListBox.new(c[0..23],p_("Clock", "Hour"),a[0],0,true),ListBox.new(c[0..59],p_("Clock", "Minute"),a[1],0,true),ListBox.new([p_("Clock", "One time"),p_("Clock", "Repeated")],p_("Clock", "Type"),a[2],0,true),EditBox.new(p_("Clock", "Alarm description"), 0, a[3], true),Button.new(_("Save")),Button.new(_("Cancel"))])
                                                  loop do
                                                    loop_update
                                                      form.update
                                                        break if escape or form.fields[5].pressed?
                                                              if form.fields[4].pressed?
                                                                    a=[form.fields[0].index,form.fields[1].index,form.fields[2].index,form.fields[3].text]
                                                                        @alarms[alarmindex]=a
                                                                           sel=[]
                                                                           for a in @alarms
                                                                               sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "Repeated");end}: #{(a[3]!=nil)?a[3]:""}")
                                                                             end
                                                                             @field[0].options=sel 
                                                                             break
                                                                           end
                                                                         end
                                                                         loop_update
                                                                           @form.fields[0].focus
                                                                         end
                                                                         def deletealarm(alarmindex)
                                                                                                                                                      @alarms.delete_at(alarmindex)
                                                                           sel=[]
                                                                           for a in @alarms
                                                                               sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "Repeated");end}: #{(a[3]!=nil)?a[3]:""}")
                                                                             end
                                                                             @field[0].options=sel
                                                                             play("editbox_delete")
                                                                             loop_update
                                                                             @field[0].sayoption
                                                                           end
                                                                                 end