# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class Scene_SoundThemes
  def main
    @return = false
st=Dir.entries(Dirs.soundthemes)
st.delete("..")
st.delete(".")
@soundthemes = []
for s in st
      f=Dirs.soundthemes+"\\"+s
      if File.file?(f) && File.extname(f).downcase==".elsnd"
        t=load_soundtheme(f, false)
        @soundthemes.push(t)
        end
      end
    @soundthemes.push(SoundTheme.new(p_("SoundThemes", "default"), nil))
  loop_update
    @selt = @soundthemes.map{|s| s.name}
   @sel = ListBox.new(@selt,p_("SoundThemes", "Sound themes"))
  @sel.bind_context{|menu|context(menu)}
  loop do
loop_update
    @sel.update
    update
    break if $scene != self or @return == true
          end
  end
  def update
    $scene = Scene_Main.new if escape
    if enter
                            seltheme(@soundthemes[@sel.index])
            return
          end
        end
        def context(menu)
          menu.option(p_("SoundThemes", "Select")) {
              seltheme(@soundthemes[@sel.index])
          }
          if holds_premiumpackage("audiophile")
menu.option(p_("SoundThemes", "Download sound themes"), nil, "d") {
stdownload
            @return = true
}
end
          menu.option(p_("SoundThemes", "New"), nil, "n") {
                        $scene=Scene_Sounds.new("")
          }
          if @sel.index<@soundthemes.size-1
          menu.option(p_("SoundThemes", "Edit"), nil, "e") {
                        $scene=Scene_Sounds.new(@soundthemes[@sel.index].file)
          }
          menu.option(p_("SoundThemes", "Delete")) {
                          confirm(p_("SoundThemes", "Are you sure you want to delete this soundtheme?")) {
                File.delete(@soundthemes[@sel.index].file)
                @return=true
                main
                }
          }
          end
          end
    def seltheme(theme)
      confirm(p_("SoundThemes", "Do you wish to use this sound theme?")) {
              if theme.file!="" &&theme.file!=nil
                                                Configuration.soundtheme = File.basename(theme.file, ".elsnd")
                                  else
              Configuration.soundtheme=nil
            end
            use_soundtheme(theme.file)
                                   writeconfig("Interface", "SoundTheme", Configuration.soundtheme)
                alert(_("Saved"))
                          return true
                          }
                          return false
end
    def stdownload
      sttemp = srvproc("soundthemes",{"format"=>"elsnd"})
            err = sttemp[0].to_i
      if err < 0
        alert(_("Error"))
        $scene = Scene_Main.new
        return
      end
      @std=[]
      for i in 0...sttemp[1].to_i
        st=Struct_SoundThemes_SoundTheme.new
        st.file=sttemp[2+i*4].delete("\r\n")
        st.size=sttemp[2+i*4+1].to_i
        st.name=sttemp[2+i*4+2].delete("\r\n")
        st.stamp=sttemp[2+i*4+3].delete("\r\n")
        @std.push(st)
      end
      sts=@std.map{|s|
      status=p_("SoundThemes", "Not downloaded")
      for st in @soundthemes
        next if st.file==nil
        if File.basename(st.file)==File.basename(s.file)
            if s.stamp.to_i>st.stamp.to_i
            status=p_("SoundThemes", "Update available")
          else
            status=p_("SoundThemes", "Downloaded")
            end
          end
        end
      [s.name,status]
      }
         @sel = TableBox.new([nil,p_("SoundThemes","Status")],sts,0,p_("Soundthemes", "Select theme to download"))
  loop do
   loop_update
   @sel.update
   if escape
          main
     return
   end
   if enter and @std.size>0
     st=@std[@sel.index]
     size=""
     if st.size<1024
       size=st.size.to_s+"B"
     elsif st.size<1048576
       size=(((st.size/1024.0)*10.0).round/10.0).to_s+"kB"
     else
       size=(((st.size/1048576.0)*10.0).round/10.0).to_s+"MB"
       end
     confirm(p_("SoundThemes", "Do you want to download theme %{name}? Need to download %{size} of data.")%{'name'=>st.name, 'size'=>size}) {
          downloadtheme(st)
          }
     return
     end
   end
 end
 def downloadtheme(st)
            downloadfile($url+"/soundthemes/"+st.file, Dirs.soundthemes+"/"+st.file.delete("/\\"))
  alert(_("Saved"))
  main
  return
   end
 end
 
 class Struct_SoundThemes_SoundTheme
   attr_accessor :name, :file, :size, :stamp
   end