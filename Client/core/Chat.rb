#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Chat
  def main
    writefile("temp/agent_chat.tmp","2")
    ct=srvproc("chat","name=#{$name}\&token=#{$token}\&recv=1")
    if ct[0].to_i<0
      speech("Błąd")
      speech_wait
      $scene=Scene_Main.new
      return
    end
    @msg=ct[1]
    if $chat != true
    play("chat_message")
    speech("Ostatnia wiadomość: #{@msg}")
              ct=srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=Dołączył%20do%20dyskusji.")
    if ct[0].to_i<0
      speech("Błąd")
      speech_wait
      $scene=Scene_Main.new
      return
    end   
          end
    @lastmsg=@msg
    speech_wait if @chatthread!=true
        @form=Form.new([Edit.new("Twoja wiadomość","","",true),Edit.new("Historia wiadomości","MULTILINE|READONLY"," ",true),Select.new([],true,0,"Aktywne osoby",true),Button.new("Ukryj chat"),Button.new("Zamknij")])
        @form.fields[1].silent=true
        @form.fields[1].update
        @form.fields[1].silent=false
        ct=srvproc("chat","name=#{$name}\&token=#{$token}\&hst=1")
        if ct[0].to_i<0
          speech("Błąd")
          speech_wait
          $scene=Scene_Main.new
          return
        end
        hs=ct[1..ct.size-1].join
        @form.fields[1].settext(hs)
        @form.fields[1].line=@form.fields[1].text.size-1
        onl=srvproc("chat_online","name=#{$name}\&token=#{$token}")
        if onl[0].to_i<0
          speech("Błąd.")
          speech_wait
          $scene=Scene_Main.new
          return
        end
        @form.fields[2].commandoptions=[]
                for o in onl[1..onl.size-1]
          @form.fields[2].commandoptions.push(o.delete("\r\n")) if o.size>2
          end
        upd=0
    loop do
      loop_update
      @form.update
      if (escape and $chat!=true) or ((enter or space) and @form.index==4)
        $chat=false
        File.delete("temp/agent_chat.tmp") if FileTest.exists?("temp/agent_chat.tmp")
        break
        end
      if (((enter or space) and @form.index == 3)) or (escape and @chatthread==true)
                play("signal")
                $chat=true
                writefile("temp\\agent_chat.tmp","1")
                                break
        end
      upd+=1
      if upd > 120
                upd=0 
                if @form.index == 1
                          ct=srvproc("chat","name=#{$name}\&token=#{$token}\&hst=1")
        if ct[0].to_i<0
          speech("Błąd")
          speech_wait
          $scene=Scene_Main.new
          return
        end
        hs=ct[1..ct.size-1].join
        @form.fields[1].settext(hs,false)
                        elsif @form.index == 2
                                onl=srvproc("chat_online","name=#{$name}\&token=#{$token}")
        if onl[0].to_i<0
          speech("Błąd.")
          speech_wait
          $scene=Scene_Main.new
          return
        end
        @form.fields[2].commandoptions=[]
        for o in onl[1..onl.size-1]
          @form.fields[2].commandoptions.push(o.delete("\r\n")) if o.size>2
                        end
        end
            end
     if enter
       if @form.index == 0 and @form.fields[0].text!=[[]]
       txt=@form.fields[0].text_str
       @form.fields[0].settext("")
       ct=srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=#{txt}")
       if ct[0].to_i < 0
         speech("Błąd")
       else
         play("signal")
                end
                              elsif @form.index == 2
                usermenu(@form.fields[2].commandoptions[@form.fields[2].index])
              end
              end
                end
          if $chat!=true
            ct=srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=opuścił%20dyskusję")
    if ct[0].to_i<0
      speech("Błąd")
      speech_wait
      $scene=Scene_Main.new
      return
    end   
    end
         $scene=Scene_Main.new
  end
end
#Copyright (C) 2014-2016 Dawid Pieper