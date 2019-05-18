#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Chat
  def main
    if $name=="guest"
      speech(_("General:error_guest"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
    if isbanned($name)
      speech(_("Chat:error_banned"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
    if $ruby == true
      speech(_("General:error_platform"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
    $agent.write(JSON.generate({'func'=>'chat_open'})+"\r\n")
    ct=srvproc("chat","name=#{$name}\&token=#{$token}\&recv=1")
    if ct[0].to_i<0
      speech(_("General:error"))
      speech_wait
      $scene=Scene_Main.new
      return
    end
    @msg=ct[1]
    if $chat != true
    play("chat_message")
    speech("#{_("Chat:info_phr_lastmessage")}: #{@msg}")
              ct=srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=#{_("Chat:joined").urlenc}")
    if ct[0].to_i<0
      speech(_("General:error"))
      speech_wait
      $scene=Scene_Main.new
      return
    end   
          end
    @lastmsg=@msg
    speech_wait if $chat!=true
        @form=Form.new([Edit.new(_("Chat:type_message"),"","",true),Edit.new(_("Chat:read_history"),"MULTILINE|READONLY"," ",true),Select.new([],true,0,_("Chat:opt_users"),true),Button.new(_("Chat:btn_hide")),Button.new(_("General:str_quit"))])
        @form.fields[1].silent=true
        @form.fields[1].update
        @form.fields[1].silent=false
        ct=srvproc("chat","name=#{$name}\&token=#{$token}\&hst=1")
        if ct[0].to_i<0
          speech(_("General:error"))
          speech_wait
          $scene=Scene_Main.new
          return
        end
        hs=ct[1..ct.size-1].join
        @form.fields[1].settext(hs)
        @form.fields[1].index=@form.fields[1].text.size
        onl=srvproc("chat_online","name=#{$name}\&token=#{$token}")
        if onl[0].to_i<0
          speech(_("General:error"))
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
        $agent.write(JSON.generate({'func'=>'chat_close'})+"\r\n")
        break
        end
      if (((enter or space) and @form.index == 3)) or (escape and $chat==true)
                play("signal")
                $chat=true
                $agent.write(JSON.generate({'func'=>'chat_open'})+"\r\n")
                                break
        end
      upd+=1
      if upd > 120
                upd=0 
                if @form.index == 1
                          ct=srvproc("chat","name=#{$name}\&token=#{$token}\&hst=1")
        if ct[0].to_i<0
          speech(_("General:error"))
          speech_wait
          $scene=Scene_Main.new
          return
        end
        hs=ct[1..ct.size-1].join
        @form.fields[1].settext(hs,false)
                        elsif @form.index == 2
                                onl=srvproc("chat_online","name=#{$name}\&token=#{$token}")
        if onl[0].to_i<0
          speech(_("General:error"))
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
       if @form.index == 0 and @form.fields[0].text!=""
       txt=@form.fields[0].text_str
       @form.fields[0].settext("")
       ct=srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=#{txt}")
       if ct[0].to_i < 0
         speech(_("General:error"))
       else
         play("signal")
                end
                              elsif @form.index == 2
                usermenu(@form.fields[2].commandoptions[@form.fields[2].index])
              end
              end
                end
          if $chat!=true
            ct=srvproc("chat","name=#{$name}\&token=#{$token}\&send=1\&text=#{_("Chat:left").urlenc}")
    if ct[0].to_i<0
      speech(_("General:error"))
      speech_wait
      $scene=Scene_Main.new
      return
    end   
    end
         $scene=Scene_Main.new
  end
end
#Copyright (C) 2014-2018 Dawid Pieper