#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_SoundThemes
  def main(canceled=false)
    @return = false
st=Dir.entries($soundthemesdata + "\\inis")
st.delete("..")
st.delete(".")
@st = st
$soundtheme = [0..st.size - 1]
for i in 0..st.size - 1
      $soundtheme[i] = readini($soundthemesdata + "\\inis\\" + st[i],"SoundTheme","Name")
      end
  if st.size <= 0
    speech(_("SoundThemes:info_nothemes"))
    speech_wait
    if canceled == false
    stdownload
  else
    $scene = Scene_Main.new
    end
return
  end
  @stsize = $soundtheme.size
  $soundtheme.push(_("SoundThemes:opt_default"))
  loop_update
    @selt = $soundtheme
  @selt.push(_("SoundThemes:opt_download"))
  @sel = Select.new(@selt,false,0,_("SoundThemes:head"))
  loop do
loop_update
    @sel.update
    update
    if $scene != self or @return == true
      break
      end
    end
  end
  def update
    if escape
            $scene = Scene_Main.new
    end
    if enter
            if @sel.index < @stsize
      $soundthemepath = readini($soundthemesdata + "\\inis\\" + @st[@sel.index],"SoundTheme","Path")
        tmp = $soundthemesdata + "\\" + $soundthemepath
    @name = $soundthemepath
    if $soundthemepath.size < 1
      $soundthemepath = ""
      @name = ""
      speech(_("General:error"))
      speech_wait
          else
      $soundthemepath = tmp
      end
    elsif @sel.index == @st.size
            $soundthemepath = ""
            @name = ""
          else
            stdownload
            @return = true
            return
    end
                   iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('SoundTheme','Path',@name,utf8($configdata + "\\soundtheme.ini"))
                speech(_("General:info_saved"))
                speech_wait
                          $soundthemespath = @name
        if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
    $scene = Scene_Main.new
      end
    end
    def stdownload
      sttemp = srvproc("soundthemes","name=#{$name}\&token=#{$token}")
            err = sttemp[0].to_i
      if err < 0
        speech(_("General:error"))
        speech_wait
        $scene = Scene_Main.new
        return
      end
      @st_name = []
      @st_path = []
      @st_file = []
   for i in 1..sttemp.size - 1
     sttemp[i].delete!("\r\n")
     download($url + sttemp[i],"st.ini")
     @st_file[i] = sttemp[i]
         st_name = readini(".\\st.ini","SoundTheme","Name")
   st_path = readini(".\\st.ini","SoundTheme","Path")
   @st_name[i] = st_name
   @st_path[i] = st_path
   @st_name[i].delete!("\0")
   @st_path[i].delete!("\0")
   File.delete("st.ini") if $DEBUG != true
 end
   @sel = Select.new(@st_name,false,0,_("Soundthemes:head_themetodownload"))
  loop do
   loop_update
   @sel.update
   if escape
          main(canceled=true)
     return
   end
   if enter
          downloadtheme(@st_file[@sel.index],@st_name[@sel.index],@st_path[@sel.index])
     return
     end
   end
 end
 def downloadtheme(ini,name,path)
   bgm=Dir.entries(".\\Audio\\BGM")
bgs=Dir.entries(".\\Audio\\BGS")
me=Dir.entries(".\\Audio\\ME")
se=Dir.entries(".\\Audio\\SE")
bgm.delete("..")
bgm.delete(".")
bgs.delete("..")
bgs.delete(".")
me.delete("..")
me.delete(".")
se.delete("..")
se.delete(".")
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata + "\\" + path), nil)
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata + "\\" + path + "\\BGM"),nil)
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata + "\\" + path + "\\BGS"), nil)
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata + "\\" + path + "\\ME"), nil)
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(utf8($soundthemesdata + "\\" + path + "\\SE"), nil)
  for i in 0..bgm.size - 1
    download(url = $url + "soundthemes/" + path + "/BGM/" + bgm[i],$soundthemesdata + "\\" + path + "\\BGM\\" + bgm[i])
    loop_update
  end
  for i in 0..bgs.size - 1
    download(url = $url + "soundthemes/" + path + "/BGS/" + bgs[i],$soundthemesdata + "\\" + path + "\\BGS\\" + bgs[i])
    loop_update
  end
    for i in 0..me.size - 1
    download(url = $url + "soundthemes/" + path + "/ME/" + me[i],$soundthemesdata + "\\" + path + "\\ME\\" + me[i])
    loop_update
  end
    for i in 0..se.size - 1
    download(url = $url + "soundthemes/" + path + "/SE/" + se[i],$soundthemesdata + "\\" + path + "\\SE\\" + se[i])
    loop_update
  end
  download(url = $url + ini,$eltendata + "/" + ini)
  speech(_("General:info_saved"))
  speech_wait
  main
  return
   end
end
#Copyright (C) 2014-2019 Dawid Pieper