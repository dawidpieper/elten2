#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Sounds
  def initialize(theme=nil)
    @theme=theme
    end
  def main
    if @theme!=nil
      if @theme!="" and FileTest.exists?($soundthemesdata+"\\"+@theme+"\\__name.txt")
        @name=read($soundthemesdata+"\\"+@theme+"\\__name.txt")
        @changed=false
      else
        @name=input_text(_("Sounds:type_name"), "ACCEPTESCAPE", " by #{$name}")
        return $scene=Scene_Main.new if @name=="\004ESCAPE\004"
        n=@name.split(" ")
        ind=n.size
        for i in 0...n.size
          ind=i if n[i].downcase=='by'
          end
        for i in 0...n.size
                    break if i==ind
                    s=n[i]
                              t=s.split("")[0].upcase+s.split("")[1..-1].join.downcase
                              @theme+=t
          end
        @theme=@theme.delspecial
        @changed=true
                end
      end
        @snd=[]
    d=Dir.entries("Audio/BGS")
    d.delete(".")
    d.delete("..")
    d.each {|f|
        n="Sounds:opt_bgs#{f.delete("_").downcase.gsub(".ogg","")}"
    @snd.push(Struct_Sounds_Sound.new("BGS/"+f,_(n), @theme)) if _(n)!=n
        }
    d=Dir.entries("Audio/SE")
    d.delete(".")
    d.delete("..")
    d.each {|f|
        n="Sounds:opt_se#{f.delete("_").downcase.gsub(".ogg","")}"
    @snd.push(Struct_Sounds_Sound.new("SE/"+f,_(n), @theme)) if _(n)!=n
        }
    return $scene=Scene_Main.new if @snd.size==0
    h=_("Sounds:head")
    h=s_("Sounds:head_editor", {'theme'=>@name}) if @theme!=nil
    @sel=Select.new(@snd.map{|o| o.description}, true, 0, h, true, false, false, true)
    @fields = [@sel, Button.new(_("Sounds:btn_play"))]
    if @theme!=nil
      @fields.push(Button.new(_("Sounds:btn_change")))
      @fields.push(Button.new(_("Sounds:btn_save")))
      @fields.push(Button.new(_("Sounds:btn_export"))) if @changed==false
      end
    @form=Form.new(@fields)
    a=nil
    loop do
      loop_update
      @form.update
      break if escape
            if (space and @form.index==0) or @form.fields[1].pressed?
              a.close if a!=nil
              a=Bass::Sound.new(@snd[@sel.index].path)
              a.volume=0.01*$volume
                a.play
              end
              if @theme!=nil
                if (enter and @form.index==0) or @form.fields[2].pressed?
                file=getfile(_("Sounds:head_newsond"),"",false,nil,[".ogg", ".mp3", ".wav", ".opus", ".aac", ".wma", ".m4a"])
                loop_update
if file!=nil
  @snd[@sel.index].path=file
  @form.fields[4]=nil
  @changed=true
end
@form.fields[@form.index].focus
end
if @form.fields[3].pressed?
  save
  @changed=false
  @form.fields[4]=Button.new(_("Sounds:btn_export"))
  @form.fields[@form.index].focus
end
if @form.fields[4]!=nil and @form.fields[4].pressed?
  loc=getfile(_("Sounds:head_export"), getdirectory(40)+"\\", true, "Documents")
  if loc!=nil
    compress($soundthemesdata+"\\"+@theme, loc+"\\"+@theme+".7z")
  end
  @form.fields[@form.index].focus
  end
                end
              end
              if @changed and @theme!=nil
                confirm(_("Sounds:alert_save")) {save}
                end
    a.close if a!=nil
    $scene=Scene_Main.new
  end
  
    def save
    waiting
      createdirifneeded($soundthemesdata+"\\"+@theme)
  createdirifneeded($soundthemesdata+"\\"+@theme+"\\BGS")
  createdirifneeded($soundthemesdata+"\\"+@theme+"\\SE")
  @snd.each {|s|
  if s.path!=s.defpath
    if File.extname(s.defpath).downcase==".ogg"
      Win32API.new("kernel32","CopyFileW",'ppi','i').call(unicode(s.path), unicode($soundthemesdata+"\\"+@theme+"\\"+s.stfile+""),0)
    else
      executeprocess("ffmpeg -i \"#{s.path}\" \"#{$soundthemesdata}\\#{@theme}\\#{s.stfile}\"")
    end
    s.path=$soundthemesdata+"\\"+@theme+"\\"+s.stfile
    s.defpath=s.path
    end
  }
  writefile($soundthemesdata+"\\"+@theme+"\\__name.txt", @name)
  waiting_end
    end
  
end

class Struct_Sounds_Sound
  attr_reader :description, :stfile
  attr_accessor :path, :defpath
  def initialize(f, d, t=nil)
    @description=d
    sp=$soundthemepath
    sp=$soundthemesdata+"\\"+t if t!=nil
    @path=sp+"/"+f
    @path="Audio/"+f if !FileTest.exists?(@path)
    @defpath=@path
    @stfile=f
  end
  end
#Copyright (C) 2014-2019 Dawid Pieper