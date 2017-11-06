#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Honors
  def initialize(user=nil,toscene=nil)
    @user=user
    @toscene=toscene
    end
  def main
    if @user==nil
    hn=srvproc("honors","name=#{$name}\&token=#{$token}\&list=1")
  else
    hn=srvproc("honors","name=#{$name}\&token=#{$token}\&list=1\&user=#{@user}")
    end
    if hn[0].to_i<0
      speech("Błąd!")
      speech_wait
      $scene=Scene_Main.new
      return
    end
    @honors=[]
    i=0
    h=0
    if hn.size>2
    for t in hn[2..hn.size-1]
      case i
      when 0
        @honors[h]=Struct_Honor.new(t.to_i)
                i+=1
        when 1
          @honors[h].name=t.delete("\r\n")
          i+=1
          when 2
          @honors[h].description=t.delete("\r\n")
          i+=1
          when 3
          @honors[h].enname=t.delete("\r\n")
          i+=1
          when 4
          @honors[h].endescription=t.delete("\r\n")
          h+=1
          i=0
      end
    end
    end
    selt=[]
    for h in @honors
      if $language=="PL_PL"
        selt.push(h.name+":\r\n"+h.description)
      else
                selt.push(h.enname+":\r\n"+h.endescription)
        end
    end
    selt.push("Nowe odznaczenie")
    header=""
    if @user==nil
      header="Odznaczenia"
    else
      header="Odznaczenia użytkownika #{@user}"
    end
    if @user!=nil and @honors==[]
      speech("Użytkownik nie otrzymał żadnych odznaczeń.")
      speech_wait
      $scene=Scene_Main.new
      return
      end
    @sel=Select.new(selt,true,0,header)
@sel.disable_item(selt.size-1) if $rang_moderator==0 or @user != nil
        loop do
      loop_update
      @sel.update
      if enter and @sel.index==@sel.commandoptions.size-1
                $scene=Scene_Honors_New.new
              elsif enter and @user==$name
                if simplequestion("Czy chcesz ustawić to odznaczenie jako główne? Główne odznaczenie pokaże się w twojej wizytówce.")==1
                  hn=srvproc("honors","name=#{$name}\&token=#{$token}\&setmain=1\&honor=#{@honors[@sel.index].id}")
                  if hn[0].to_i<0
                    speech("Błąd")
                  else
                    speech("Odznaczenie ustawiono jako domyślne.")
                  end
                                    end
              end
      menu if alt and @sel.index!=@sel.commandoptions.size-1
              if escape
                if @toscene==nil
                  $scene=Scene_Main.new
                else
                  $scene=@toscene
                end
                end
              break if $scene!=self
    end
  end
  def menu
    play("menu_open")
    play("menu_background")
   menu=menulr(["Odśwież","Nadaj odznaczenie","Anuluj"])
    menu.disable_item(1) if $rang_moderator==0
    loop do
      loop_update
      menu.update
      break if escape
      break if alt
        if enter
          case menu.index
          when 0
            $scene=Scene_Honors.new(@user)
                        when 1
                          user=input_text("Komu nadać to odznaczenie?","ACCEPTESCAPE")
                          if user!="\004ESCAPE\004"
                            if user_exist(user)==false
                              speech("Użytkownik nie istnieje")
                              speech_wait
                            else
                              hn=srvproc("honors","name=#{$name}\&token=#{$token}\&user=#{user}\&award=1\&honor=#{@honors[@sel.index].id}")
                              if hn[0].to_i<0
                                speech("Błąd")
                              else
                                speech("Odznaczenie nadane")
                                                            speech_wait
                              end
                              end
                            end
                                      end
          break
                                      end
    end
        play("menu_close")
    Audio.bgs_stop
    loop_update    
    end
  end

  class Scene_Honors_New
    def main
      @form=Form.new([Edit.new("Nazwa odznaczenia","","",true),Edit.new("Opis odznaczenia","","",true),Edit.new("Angielska nazwa odznaczenia","","",true),Edit.new("Angielski opis odznaczenia","","",true),Button.new("Dodaj"),Button.new("Anuluj")])
      loop do
        loop_update
        @form.update
        break if escape or ((enter or space) and @form.index==5)
          if (enter or space) and @form.index==4
            honorname=@form.fields[0].text_str
            honordescription=@form.fields[1].text_str
                        honorenname=@form.fields[2].text_str
            honorendescription=@form.fields[3].text_str
            hn=srvproc("honors","name=#{$name}\&token=#{$token}\&addhonor=1\&honorname=#{honorname}\&honordescription=#{honordescription}\&honorenname=#{honorenname}\&honorendescription=#{honorendescription}")
                        if hn[0].to_i<0
                            speech("Błąd")
            else
              speech("Odznaczenie zostało dodane")
            end
            speech_wait
            break
            end
      end
      $scene=Scene_Honors.new
    end
    end
  
class Struct_Honor
  attr_accessor :id
  attr_accessor :name
  attr_accessor :description
  attr_accessor :enname
  attr_accessor :endescription
  def initialize(id=0)
    @id=id
    @name=""
    @description=""
    @enname=""
    @endescription=""
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper