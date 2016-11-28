#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Media
  def main
    mediatemp = srvproc("media","name=#{$name}\&token=#{$token}")
        if mediatemp[0].to_i < 0
      speech("Błąd")
      speech_wait
      $sene = Scene_Main.new
      return
    end
    @categoryid = []
    @category = []
    @categorydescription = []
    l = 1
    t = 0
    i = 0
    loop do
      case t
      when 0
        @categoryid[i] = mediatemp[l].to_i
        t += 1
        when 1
          @category[i] = mediatemp[l].delete("\n")
          t += 1
          when 2
            @categorydescription[i] = "" if @categorydescription[i] == nil
            if mediatemp[l].delete("\r\n") != "\004END\004"
              @categorydescription[i] += mediatemp[l]
            else
              t = 0
              i += 1
              end
      end
      l += 1
      break if l >= mediatemp.size-1
      end
    @sel = Select.new(@category + ["Nowa kategoria","Podaj adres URL"])
    loop do
loop_update
      @sel.update
      update
      break if $scene != self
      end
    end
    def update
      if enter
                if @sel.index == @sel.commandoptions.size - 1
        url = input_text("podaj adres URL","ACCEPTESCAPE")
        if url == "\004ESCAPE\004"
          main
          return
          end
          play("menu_open")
          play("menu_background")
          sel = SelectLR.new(["Odtwarzaj","Dodaj do playlisty","Anuluj"])      
          loop do
            loop_update
                        sel.update
                      break if escape
                      if enter
                      case sel.index
                                              when 0
                          $scene = Scene_Player.new(url,self)
                          when 1
                            $playlist.push(url)
                            when 2
                              break
                      end
                      break
                  end
                end
                play("menu_close")
                Audio.bgs_stop
      elsif @sel.index == @sel.commandoptions.size - 2
      $scene = Scene_Media_New.new
        else
        $scene = Scene_Media_Category.new(@categoryid[@sel.index])
      end
        end
      if escape
                $scene = Scene_Main.new
        end
      end
    end
    
    class Scene_Media_Category
      def initialize(id)
        @id = id
        end
  def main
        mediatemp = srvproc("media","name=#{$name}\&token=#{$token}\&get=#{@id}")
        if mediatemp[0].to_i < 0
      speech("Błąd")
      speech_wait
      $scene = Scene_Main.new
      return
    end
    @fileid = []
    @fileurl = []
    @filename = []
    @filedescription = []
    l = 1
    t = 0
    i = 0
    loop do
      case t
      when 0
        @fileid[i] = mediatemp[l].to_i
        t += 1
        when 1
          @fileurl[i] = mediatemp[l]
        t += 1
        when 2
          @filename[i] = mediatemp[l].delete("\n")
          t += 1
          when 3
            @filedescription[i] = "" if @filedescription[i] == nil
            if mediatemp[l].delete("\r\n") != "\004END\004"
              @filedescription[i] += mediatemp[l]
            else
              t = 0
              i += 1
              end
      end
      l += 1
      break if l >= mediatemp.size-1
      end
    @sel = Select.new(@filename + ["Nowy plik"])
    loop do
loop_update
      @sel.update
      update
      break if $scene != self
      end
    end
    def update
      if enter
                if @sel.index < @sel.commandoptions.size - 1
        url = @fileurl[@sel.index]
                sel = SelectLR.new(["Odtwarzaj","Dodaj do playlisty","Anuluj"])      
          play("menu_open")
          play("menu_background")
                loop do
            loop_update
            sel.update
                      break if escape
                      if enter
                      case sel.index
                                              when 0
                          $scene = Scene_Player.new(url,self)
                          when 1
                            $playlist.push(url)
                            when 2
                              break
                      end
                      break
                  end
                end
                play("menu_close")
      Audio.bgs_stop
                else
        $scene = Scene_Media_Category_New.new(@id)
      end
        end
      if escape
                $scene = Scene_Media.new
        end
      end
    end
    
class Scene_Media_New
  def main
    @fields = []
    @fields[0] = Edit.new("Nazwa kategorii","","",true)
    @fields[1] = Edit.new("Opis kategorii","MULTILINE","",true)
    @fields[2] = Button.new("Dodaj")
    @fields[3] = Button.new("Anuluj")
    @form = Form.new(@fields)
    loop do
      loop_update
      @form.update
update
break if $scene != self
      end
    end
    def update
if escape or ((enter or space) and @form.index == 3)
  $scene = Scene_Media.new
end
if (enter or space) and (@form.index == 2 or $key[0x11] == true)
  @form.fields[0].finalize
  categoryname = @form.fields[0].text_str
  @form.fields[1].  finalize
  categorydescription = @form.fields[1].text_str
    mt = srvproc("media_mod","name=#{$name}\&token=#{$token}\&categoryname=#{categoryname}\&categorydescription=#{categorydescription}")
    if mt[0].to_i < 0
    speech("Błąd")
    speech_wait
    $scene = Scene_Media.new
    return
  end
  speech("Kategoria została dodana!")
  speech_wait
  $scene = Scene_Media.new
  return
  end
      end
    end
    
    class Scene_Media_Category_New
      def initialize(id)
        @id = id
      end
      def main
                @fields = []
        @fields[0] = Edit.new("Tytuł","","",true)
        @fields[1] = Edit.new("Adres URL","","",true)
        @fields[2] = Edit.new("Opis","MULTILINE","",true)
        @fields[3] = Button.new("Dodaj")
        @fields[4] = Button.new("Anuluj")
        @form = Form.new(@fields)
        loop do
          loop_update
          @form.update
          update
          break if $scene != self
          end
        end
        def update
          if escape or ((enter or space) and @form.index == 4)
            $scene = Scene_Media_Category.new(@id)
          end
          if (@form.index == 3 or $key[0x11] == true) and (enter or space)
            @form.fields[0].finalize
            @form.fields[1].finalize
            @form.fields[2].finalize
            filename = @form.fields[0].text_str
            fileurl = @form.fields[1].text_str.gsub("/listen.pls","")
                        filedescription = @form.fields[2].text_str
s = false
    mt = srvproc("media_mod","name=#{$name}\&token=#{$token}\&set=#{@id.to_s}\&filename=#{filename}\&fileurl=#{fileurl}\&filedescription=#{filedescription}")
if mt[0].to_i < 0
  speech("Błąd")
  speech_wait
  $scene = Scene_Media_Category.new(@id)
  return
end
speech("Dodano.")
speech_wait
$scene = Scene_Media_Category.new(@id)
            end
            end
          end
#Copyright (C) 2014-2016 Dawid Pieper