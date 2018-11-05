#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Languages
  def main
            @langs_f = Dir.entries($langdata)
        @langs_f.delete(".")
        @langs_f.delete("..")
@langs = []
for i in 0..@langs_f.size - 1
  tmp = read($langdata + "\\" + @langs_f[i],false,true).split("\n")
      tmp[2] = "" if tmp[2] == nil
  @langs[i] = tmp[2].sub("(UTF)","")
    @langs[i] = "" if @langs[i] == nil
  @langs[i].delete!("\n")
end
for i in 0..@langs.size - 1
  if @langs[i] == nil
    @langs.delete_at(i)
  elsif @langs[i].size <= 0
    @langs.delete_at(i)
    end
  end
  sel = ["POLSKI - POLSKA"]
sel += @langs
sel.push(_("Languages:opt_download"))
@selt = sel
@sel = Select.new(sel,true,0,_("Languages:head"))
loop do
  loop_update
  @sel.update
  update
  if $scene != self
    break
    end
  end
end
def update
  if escape
        if $token != "" and $token != nil and $name != "" and $name != nil
    $scene = Scene_Main.new
  else
    $scene = Scene_Loading.new
    end
  end
if enter
  play("right")
  if @sel.index < @selt.size - 1 and @sel.index > 0
lng = @langs_f[@sel.index - 1]
lng = lng.sub(".elg","")
                   iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Language','Language',lng,utf8($configdata + "\\language.ini"))
$language = lng
if $language.upcase != "PL_PL"
  $lang_src = []
      $lang_dst = []
    if $language != "PL_PL"
      $langwords = read($langdata + "\\" + $language + ".elg",false,true).split("\n")
            $langwords.delete_at(0)
      $langwords.delete_at(0)
      $langwords.delete_at(0)
                          for i in 0..$langwords.size - 1
        $langwords[i].delete!("\n")
        $langwords[i].gsub!('\r\n',"\r\n")
        s = false
        $lang_src[i] = ""
        $lang_dst[i] = ""
        for j in 0..$langwords[i].size - 1
          if s == false
            if $langwords[i][j..j] != "|" and $langwords[i][j..j] != "\\"
            $lang_src[i] += $langwords[i][j..j]
          else
            s = true
          end
        else
          if $langwords[i][j..j] != "|" and $langwords[i][j..j] != "\\"
            $lang_dst[i] += $langwords[i][j..j]
            end
            end
          end
        end
                end
end                
speech(_("General:info_saved"))
elsif @sel.index == 0
                   iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call('Language','Language',"PL_PL",utf8($configdata + "\\language.ini"))
  $language = "PL_PL"
  $lang_src = []
  $lang_dst = []
  speech(_("General:info_saved"))
  elsif @sel.index == @selt.size - 1
  langtemp = srvproc("languages","")
    err = langtemp[0].to_i
  case err
  when -1
    speech(_("General:error_db"))
    speech_wait
    $scene = Scene_Main.new
    return
    when -2
      speech(_("General:error_tokenexpired"))
      speech_wait
      $scene = Scene_Loading.new
      return
    end
    langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg",$langdata + "\\" + langs[i].to_s + ".elg")
  end
speech(_("Languages:info_downloaded"))
speech_wait
main
return
    end
  end
  end
  end
#Copyright (C) 2014-2018 Dawid Pieper