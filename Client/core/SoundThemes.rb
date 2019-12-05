#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_SoundThemes
  def main(canceled=false)
    @return = false
st=Dir.entries($soundthemesdata)
st.delete("..")
st.delete(".")
@soundthemes = []
for s in st
      d=$soundthemesdata+"\\"+s
      if File.directory?(d) and FileTest.exists?(d+"\\__name.txt")
        t=Struct_SoundThemes_SoundTheme.new(s, readfile(d+"\\__name.txt"))
        @soundthemes.push(t)
        end
      end
  if @soundthemes.size==0
    alert(_("SoundThemes:info_nothemes"))
    if canceled == false
    stdownload
  else
    $scene = Scene_Main.new
    end
return
  end
    @soundthemes.push(Struct_SoundThemes_SoundTheme.new("", _("SoundThemes:opt_default")))
  loop_update
    @selt = @soundthemes.map{|s| s.name}
  @selt.push(_("SoundThemes:opt_download"))
  @sel = Select.new(@selt,true,0,_("SoundThemes:head"))
  loop do
loop_update
    @sel.update
    update
    break if $scene != self or @return == true
          end
  end
  def update
    $scene = Scene_Main.new if escape
    return menu if alt
    if enter
            if @sel.index < @soundthemes.size
              seltheme(@soundthemes[@sel.index])
              $scene=Scene_Main.new
              else
            stdownload
            @return = true
            return
          end
        end
        end
        def menu
          m=[_("SoundThemes:opt_select"), _("SoundThemes:opt_new")]
          m+=[_("SoundThemes:opt_edit"), _("SoundThemes:opt_delete")] if @sel.index<@soundthemes.size-1
          mn=menuselector(m)
          case mn
          when 0
            if @sel.index<@soundthemes.size
              seltheme(@soundthemes[@sel.index])
            else
              stdownload
              @return=true
            end
            when 1
              $scene=Scene_Sounds.new("")
            when 2
              $scene=Scene_Sounds.new(@soundthemes[@sel.index].path)
              when 3
                confirm(_("SoundThemes:alert_delete")) {
                deldir($soundthemesdata+"\\"+@soundthemes[@sel.index].path)
                @return=true
                return main
                }
          end
          end
    def seltheme(theme)
              if theme.path!=""
                                                $soundthemepath = $soundthemesdata + "\\" + theme.path
                                  else
              $soundthemepath=""                    
      end
                                   writeconfig("Interface", "SoundTheme", theme.path)
                alert(_("General:info_saved"))
                          $soundthemespath = theme.path
end
    def stdownload
      sttemp = srvproc("soundthemes",{"type"=>"1"})
            err = sttemp[0].to_i
      if err < 0
        alert(_("General:error"))
        $scene = Scene_Main.new
        return
      end
      @std=[]
      for i in 0...sttemp.size/2
        @std.push(Struct_SoundThemes_SoundTheme.new(sttemp[i*2+1].delete("\r\n"), sttemp[i*2+2].delete("\r\n")))
      end
         @sel = Select.new(@std.map{|s| s.name},true,0,_("Soundthemes:head_themetodownload"))
  loop do
   loop_update
   @sel.update
   if escape
          main(canceled=true)
     return
   end
   if enter
          downloadtheme(@std[@sel.index].path)
     return
     end
   end
 end
 def downloadtheme(path)
     Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode($soundthemesdata + "\\" + path), nil)
    Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode($soundthemesdata + "\\" + path + "\\BGS"), nil)
    Win32API.new("kernel32","CreateDirectoryW",'pp','i').call(unicode($soundthemesdata + "\\" + path + "\\SE"), nil)
    st=srvproc("soundthemes",{"listfiles"=>path})
    waiting
    for s in st[1..-1]
      s=s.delete!("\r\n").gsub("../","").gsub("..\\","")
            downloadfile($url+"/soundthemes/"+s, $soundthemesdata+"/"+s,nil,nil,true)
                      end
         waiting_end
  alert(_("General:info_saved"))
  main
  return
   end
 end
 
 class Struct_SoundThemes_SoundTheme
   attr_accessor :path, :name
   def initialize(path=nil, name=nil)
     @path, @name = path, name
     end
   end
#Copyright (C) 2014-2019 Dawid Pieper