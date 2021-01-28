# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_Admins
  def main(cat=0, subcat=0)
    @indexes||=[]
    @selt=[]
    @users=[]
    @subcats=[]
        case cat
    when 0
        @selt=[p_("Admins", "Council of elders"), p_("Admins", "Developers"), p_("Admins", "Translators"), p_("Admins", "Community Administrators"), p_("Admins", "Recommended groups Moderators"), p_("Admins", "Sponsors")]
    @users=[]
    when 1
      adm = srvproc("admins",{"cat"=>"elders"})
        @users= []
    adm[1..-1].each {|a| @users.push(a.delete("\r\n")) }      
    @users.polsort!
    @selt=@users.deep_dup
    when 2
adm = srvproc("admins",{"cat"=>"developers"})
        @users= []
    adm[1..-1].each {|a| @users.push(a.delete("\r\n")) }      
    @users.polsort!
    @selt=@users.deep_dup
    when 3
      if subcat==0
        ld=loadedlanguages
        i=0
      for lo in ld
        l=lo.mo
        lang=Lists.langs[lo.realcode[0..1].downcase]['name']
                            @selt.push(lang)
                            @subcats.push(i+1)
                            i+=1
                            end
                          else
                            ld=loadedlanguages
                            f=ld[subcat-1].mo
                            @users=[]
                            if (/Language-Team: ([^\n]+)\n/=~f)!=nil
                              @users=$1.delete(" \t").split(",")
                              end
      @selt=@users.deep_dup
            end
    when 4
      adm=srvproc("admins", {"cat"=>"administrators"})
      for i in 0...adm.size/2
        @users.push(adm[i*2+2].delete("\r\n"))
        @selt.push(@users.last+" ("+adm[i*2+1].delete("\r\n")+")")
        end
    when 5
      if subcat==0
      adm = srvproc("admins",{"cat"=>"moderators"})
        @groups={}
        i=1
    loop do
        break if i>=adm.size
        id=adm[i].to_i
        i+=1
        name=adm[i].delete("\r\n")
        i+=1
        @groups[id]=[adm[i].delete("\r\n")]
        i+=1
        c=adm[i].to_i
        u=[]
                        for j in 0...c
          u.push(adm[i+1+j].delete("\r\n"))
        end
        @groups[id]+=u.polsort
        i+=1+c
        @selt.push(name)
        @subcats.push(id)
        end
      else
        @users=@groups[subcat]
        @selt=@users.deep_dup
      end
      when 6
        adm = srvproc("admins",{"cat"=>"sponsors"})
        @users= []
    adm[1..-1].each {|a| @users.push(a.delete("\r\n")) }      
    @users.polsort!
    @selt=@users.deep_dup
      end
      for i in 0...@users.size
        @selt[i]+=".\r\n"+getstatus(@users[i])
        end
    h=""
    h=p_("Admins", "Administrators and authors") if cat==0
    ind=@indexes[cat]||0
    ind=0 if subcat>0
    @sel=ListBox.new(@selt,h,ind)
    loop do
      loop_update
      @sel.update
      if @sel.selected? or (@sel.expanded? and @sel.index>=@users.size && @sel.options.size>0) or (alt and @sel.index<@users.size)
        if cat==0
          @indexes={0=>@sel.index}
          return main(@sel.index+1)
          else
        if @sel.index>=@users.size
          @indexes[cat]=@sel.index
          return main(cat,@subcats[@sel.index])
                  else
          usermenu(@users[@sel.index])
          loop_update
          end
          end
        end
      if escape or (arrow_left and cat>0)
        if subcat>0
          return main(cat)
        elsif cat>0
          return main(0)
        else
          break
          end
        end
    end
    $scene=Scene_Main.new
  end
  end