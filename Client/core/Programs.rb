#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Programs
  def main
    if $ruby == true
      speech(_("General:error_platform"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
    if FileTest.exists?($configdata+"\\apps.dat")==false
      save_data([],$configdata+"\\apps.dat")
    end
    @installed=load_data($configdata+"\\apps.dat")
apps = srvproc("apps","name=#{$name}\&token=#{$token}\&list=1")
@apps=[]        
        nb = apps[1].to_i
    l = 2
    for i in 0..nb - 1
      @apps[i]=Struct_Program.new
      t = 0
            while apps[l] != "\004END\004\n" and apps[l] != nil
        t += 1
      if t > 3
      @apps[i].description += apps[l]
    elsif t == 1
      @apps[i].ini = apps[l].delete!("\r\n")+".ini"
    elsif t == 2
      @apps[i].name = apps[l].delete!("\n")
    elsif t == 3
      @apps[i].version = apps[l].delete!("\n")
    end
    l += 1
    end
    l += 1
  end
sel=[]
for a in @apps
  sel.push(a.name+".\r\n"+a.description)
end
@sel=Select.new(sel,true,0,_("Programs:head"))
loop do
  loop_update
  @sel.update
  break if escape
  if enter
    suc=false
    for a in @installed
            suc=true if a.ini==@apps[@sel.index].ini
            end
    if suc == true
      speech(_("Programs:info_alreadyinstalled"))
    elsif simplequestion(s_("Programs:alert_installprogram",{'name'=>@apps[@sel.index].name})) == 1
      install(@apps[@sel.index])
      speech_wait
      @sel.focus
    else
      @sel.focus
    end
        end
end
    $scene=Scene_Main.new
  end
  def install(app)
    a=app
        download($url+"apps/inis/"+a.ini,"temp/"+a.ini)
        a.class=readini("temp\\"+a.ini,"App","Class","")
        a.file=readini("temp\\"+a.ini,"App","File","")
                download($url+"apps/"+a.file,"temp/"+a.file+".rb")
        require("temp/"+a.file)
        eval(a.class+".init")
        @installed.push(app)
    save_data(@installed,$configdata+"\\apps.dat")
    speech(_("Programs:info_installed"))
    end
  end
  
  class Struct_Program
    attr_accessor :id
    attr_accessor :name
    attr_accessor :description
    attr_accessor :label
    attr_accessor :file
    attr_accessor :author
    attr_accessor :version
    attr_accessor :ini
    attr_accessor :class    
    def initialize(id=0)
      @id=id
      @name=""
      @author=""
      @version=0.0
      @file=""
      @description=""
      @ini=""
      @class=""
          end
    end
#Copyright (C) 2014-2018 Dawid Pieper