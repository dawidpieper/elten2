#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Admins
  def main(cat=0, subcat=0)
    @indexes||=[]
    @selt=[]
    @users=[]
    @subcats=[]
        case cat
    when 0
        @selt=[p_("Admins", "Developers"), p_("Admins", "Translators"), p_("Admins", "Community Administrators"), p_("Admins", "Recommended groups Moderators")]
    @users=[]
    when 1
adm = srvproc("admins",{"cat"=>"developers"})
        @users= []
    adm[1..-1].each {|a| @users.push(a.delete("\r\n")) }      
    @users.polsort!
    @selt=@users.deep_dup
    when 2
      if subcat==0
        d=Dir.entries("locale")
        i=0
      for f in d
        if File.directory?("locale/"+f) and FileTest.exists?("locale/"+f+"/lc_messages/elten.mo")
        l=readfile("locales/#{f}/lc_messages/elten.mo")
        lang=Lists.langs[f[0..1].downcase]['name']
                            @selt.push(lang)
                            @subcats.push(i+1)
                            end
                            i+=1
                            end
                          else
                            d=Dir.entries("locale")
                            f=readfile("locale/"+d[subcat-1]+"/lc_messages/elten.mo")
                            @users=[]
                            if (/Language-Team: ([^\n]+)\n/=~f)!=nil
                              @users=$1.delete(" \t").split(",")
                              end
      @selt=@users.deep_dup
            end
    when 3
      adm=srvproc("admins", {"cat"=>"administrators"})
      for i in 0...adm.size/2
        @users.push(adm[i*2+2].delete("\r\n"))
        @selt.push(@users.last+" ("+adm[i*2+1].delete("\r\n")+")")
        end
    when 4
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
      end
      for i in 0...@users.size
        @selt[i]+=".\r\n"+getstatus(@users[i])
        end
    h=""
    h=p_("Admins", "Administrators") if cat==0
    ind=@indexes[cat]||0
    ind=0 if subcat>0
    @sel=ListBox.new(@selt,h,ind)
    loop do
      loop_update
      @sel.update
      if enter or (arrow_right and @sel.index>=@users.size) or (alt and @sel.index<@users.size)
        if cat==0
          @indexes={0=>@sel.index}
          return main(@sel.index+1)
          else
        if @sel.index>=@users.size
          @indexes[cat]=@sel.index
          return main(cat,@subcats[@sel.index])
                  else
          usermenu(@users[@sel.index])
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