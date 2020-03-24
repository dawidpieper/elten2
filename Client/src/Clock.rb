#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

                                                                         class Scene_Clock
    def main
        @field=[]
              @field[0]=Select.new([],true,0,p_("Clock", "Alarms"),true)
              @field[1]=Button.new(_("Save"))
              @field[2]=Button.new(_("Cancel"))
              @alarms=[]
              @alarms=load_data($eltendata+"\\alarms.dat") if FileTest.exists?($eltendata+"\\alarms.dat")
              sel=[]
              for a in @alarms
                  sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "repeated");end}")
                end
                @field[0].commandoptions=sel
                @form=Form.new(@field)
                @form.bind_context{|menu|context(menu)}
                loop do
                    loop_update
                      @form.update
                        if escape or ((space or enter) and @form.index==2)
                              $scene=Scene_Main.new
                                      return
                                              break
                                            end
                                            if enter and @form.index==0
                                              editalarm(@form.fields[0].index)
                                              end
                                                                         if $key[0x2e] and @form.index==0 and @alarms[@form.fields[0].index]!=nil
deletealarm(@form.fields[0].index)
                                                                           end
                                                                           if (space or enter) and @form.index==1
                                                                                 save_data(@alarms,$eltendata+"\\alarms.dat")
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
                                                                                                                                                                          menu.option(p_("Clock", "Delete alarm")) {
                                                                                     deletealarm(@form.fields[0].index)
                                                                                     }
                                                                                     end
                                                                                   menu.option(p_("Clock", "New alarm")) {
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
                                                  form=Form.new([Select.new(c[0..23],false,a[0],p_("Clock", "Hour"),true),Select.new(c[0..59],false,a[1],p_("Clock", "Minute"),true),Select.new([p_("Clock", "One time"),p_("Clock", "Repeated")],true,a[2],p_("Clock", "Type"),true),Button.new(_("Save")),Button.new(_("Cancel"))])
                                                  loop do
                                                    loop_update
                                                      form.update
                                                        if escape or ((space or enter) and form.index==4)
                                                              break
                                                            end
                                                              if ((space or enter) and form.index==3)
                                                                    a=[form.fields[0].index,form.fields[1].index,form.fields[2].index]
                                                                        @alarms[alarmindex]=a
                                                                           sel=[]
                                                                           for a in @alarms
                                                                               sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "Repeated");end}")
                                                                             end
                                                                             @field[0].commandoptions=sel 
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
                                                                               sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "Repeated");end}")
                                                                             end
                                                                             @field[0].commandoptions=sel
                                                                             play("edit_delete")
                                                                             loop_update
                                                                             speech(@field[0].commandoptions[@field[0].index])
                                                                           end
                                                                                 end