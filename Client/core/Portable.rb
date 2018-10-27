#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Portable
  def main
    @form=Form.new([FilesTree.new(_("Portable:head_dest"),getdirectory(40),true,true,"Documents"),CheckBox.new(_("Portable:chk_langs")),CheckBox.new(_("Portable:chk_settings")),CheckBox.new(_("Portable:chk_soundthemes")),CheckBox.new(_("Portable:chk_sfx")),Button.new(_("Portable:btn_continue")),Button.new(_("General:str_cancel"))])    
loop do
  loop_update
  @form.update
  if escape or ((enter or space) and @form.index==6)
    $scene=Scene_Main.new
    return
    break
  end
  if (enter or space) and @form.index==5
    break
    end
end
waiting
speech(_("Portable:wait"))
@destdir=@form.fields[0].path+"\\"+@form.fields[0].file+"\\Elten_#{$version.to_s}_#{if $alpha > 0;"_RC"+$alpha.to_s;elsif $beta > 0;"_B"+$beta.to_s;else;"";end}_portable"
copier
    loop_update
    speech_wait
        if @form.fields[1].checked==1 or @form.fields[2].checked==1 or @form.fields[3].checked==1
      Dir.mkdir("#{@destdir}/eltendata") if FileTest.exists?("#{@destdir}/eltendata")==false
    if @form.fields[1].checked == 1
      Dir.mkdir("#{@destdir}/eltendata/lng") if FileTest.exists?("#{@destdir}/eltendata/lng")==false
      speech(_("Portable:wait_languages"))
      $l = false
  langtemp = srvproc("languages","langtemp")
    err = langtemp[0].to_i
  case err
  when 0
    $l = true
  when -1
    speech(_("General:error_db"))
    speech_wait
        when -2
      speech(_("General:error_tokenexpired"))
      speech_wait
    end
    if $l == true
    langs = []
for i in 1..langtemp.size - 1    
  langtemp[i].delete!("\n")
  langs.push(langtemp[i]) if langtemp[i].size > 0
end
for i in 0..langs.size - 1
  download($url + "lng/" + langs[i].to_s + ".elg", "#{@destdir}/eltendata/lng/"+langs[i].to_s + ".elg")
end
speech_wait
end  
      end
if @form.fields[2].checked == 1
  speech(_("Portable:wait_settings"))
  copier(".","/eltendata/config",".ini",$configdata+"/")
  speech_wait
  if $voice != -1 and $voice != -3
    waiting_end
    dialog_open
  v = selector([_("Portable:opt_usedefault"),_("Portable:opt_synthreset"),_("Portable:opt_askeverytime"),_("Portable:opt_usecurrent")],_("Portable:head_synth"),0,3,1)
  value=0
  value=-1 if v==0
  value=-2 if v==1
  value=-3 if v==2
  writeini("#{@destdir}/eltendata/config/sapi.ini","Sapi","Voice",value.to_s) if value != 0
  if @form.fields[3].checked==0
    writeini("#{@destdir}/config/soundtheme.ini","SoundTheme","Path","")
  end
  dialog_close
  waiting
end
end
if @form.fields[3].checked == 1
  speech(_("Portable:wait_soundthemes"))
  copier(".","/eltendata/soundthemes","",$soundthemesdata+"/")
  speech_wait
  end
      end        
      writeini("#{@destdir}\\elten.ini","Elten","Portable","1")
      writeini("#{@destdir}\\elten.ini","Elten","SFX","2")
      if @form.fields[4].checked==1
 writefile("temp\\portxfs.tmp","sfx configuration
Setup="+File.basename(@destdir)+"\\"+File.basename($path)+"
TempMode
Silent=1
Overwrite=1
Title=Extracting Elten Temporary Files...
Text
{
Please wait while Elten files are being extracted...
}")
speech(_("Portable:wait_preparingfile"))
executeprocess("bin\\rar.exe a -r -ep1 -df -ma -sfx -z\"temp\\portxfs.tmp\" \"#{@destdir}.exe\" \"#{@destdir}\" -y",true)
speech_wait
        end
      waiting_end
        speech(_("Portable:info_created"))
      speech_wait
      $scene=Scene_Main.new
    end
  def copier(dir=".",dest="",incl="",start="")
loop_update
    Dir.mkdir("#{@destdir}"+dest) if dir=="." and FileTest.exists?("#{@destdir}"+dest)==false
    Dir.mkdir("#{@destdir}"+dest+"/"+dir) if dir != "." and FileTest.exists?("#{@destdir}"+dest+"/"+dir)==false
                        dr=Dir.entries(start+dir)
    dr.delete(".")
    dr.delete("..")
    for t in dr
      f=dir+"/"+t
      f=t if dir=="."
      if File.file?(start+f)
      Win32API.new("kernel32","CopyFile",'ppi','i').call(start+f,"#{@destdir}"+dest+"/"+f,0) if f.include?("tmp")==false and f.include?("temp") == false and t.include?(incl)
    elsif File.directory?(start+f)
      if f!="temp" and f.downcase.include?("kopia")==false
      copier(f,dest,incl,start)
      end
    end
    end
    end
  end
#Copyright (C) 2014-2016 Dawid Pieper