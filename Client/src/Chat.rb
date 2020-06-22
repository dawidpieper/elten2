#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Chat
  def main
    if Session.name=="guest"
      alert(_("This section is unavailable for guests"))
      $scene=Scene_Main.new
      return
      end
    if isbanned(Session.name)
      alert(p_("Chat", "You have been banned."))
      $scene=Scene_Main.new
      return
      end
    if $ruby == true
      alert(_("Function not supported on this platform"))
      $scene=Scene_Main.new
      return
      end
    $agent.write(Marshal.dump({'func'=>'chat_open'}))
    ct=srvproc("chat",{"recv"=>"1"})
    if ct[0].to_i<0
      alert(_("Error"))
      $scene=Scene_Main.new
      return
    end
    @msg=ct[1]
    if $chat != true
    play("chat_message")
    speech("#{p_("Chat", "Last message")}: #{@msg}")
              ct=srvproc("chat",{"send"=>"1", "text"=>p_("Chat", "Joined the discussion")})
    if ct[0].to_i<0
      alert(_("Error"))
      $scene=Scene_Main.new
      return
    end   
          end
    @lastmsg=@msg
    speech_wait if $chat!=true
        @form=Form.new([EditBox.new(p_("Chat", "Your message"),0,"",true),EditBox.new(p_("Chat", "Messages history"),EditBox::Flags::MultiLine|EditBox::Flags::ReadOnly," ",true),ListBox.new([],p_("Chat", "Users online"),0,0,true),Button.new(p_("Chat", "Hide the chat window")),Button.new(_("Exit"))])
        @form.fields[1].silent=true
        @form.fields[1].update
        @form.fields[1].silent=false
        ct=srvproc("chat",{"hst"=>"1"})
        if ct[0].to_i<0
          alert(_("Error"))
          $scene=Scene_Main.new
          return
        end
        hs=ct[1..ct.size-1].join
        @form.fields[1].settext(hs)
        @form.fields[1].index=@form.fields[1].text.size
        onl=srvproc("chat_online",{})
        if onl[0].to_i<0
          alert(_("Error"))
          $scene=Scene_Main.new
          return
        end
        @form.fields[2].options=[]
                for o in onl[1..onl.size-1]
          @form.fields[2].options.push(o.delete("\r\n")) if o.size>2
          end
        upd=0
    loop do
      loop_update
      @form.update
      if (escape and $chat!=true) or ((enter or space) and @form.index==4)
        $chat=false
        $agent.write(Marshal.dump({'func'=>'chat_close'}))
        break
        end
      if (((enter or space) and @form.index == 3)) or (escape and $chat==true)
                play("signal")
                $chat=true
                $agent.write(Marshal.dump({'func'=>'chat_open'}))
                                break
        end
      upd+=1
      if upd > 120
                upd=0 
                if @form.index == 1
                          ct=srvproc("chat",{"hst"=>"1"})
        if ct[0].to_i<0
          alert(_("Error"))
          $scene=Scene_Main.new
          return
        end
        hs=ct[1..ct.size-1].join
        @form.fields[1].settext(hs,false)
                        elsif @form.index == 2
                                onl=srvproc("chat_online",{})
        if onl[0].to_i<0
          alert(_("Error"))
          $scene=Scene_Main.new
          return
        end
        @form.fields[2].options=[]
        for o in onl[1..onl.size-1]
          @form.fields[2].options.push(o.delete("\r\n")) if o.size>2
                        end
        end
            end
     if enter
       if @form.index == 0 and @form.fields[0].text!=""
       txt=@form.fields[0].text
       @form.fields[0].settext("")
       ct=srvproc("chat",{"send"=>"1", "text"=>txt})
       if ct[0].to_i < 0
         alert(_("Error"))
       else
         play("signal")
                end
                              elsif @form.index == 2
                usermenu(@form.fields[2].options[@form.fields[2].index])
              end
              end
                end
          if $chat!=true
            ct=srvproc("chat", {"send"=>"1", "text"=>p_("Chat", "Left the discussion.")})
    if ct[0].to_i<0
      alert(_("Error"))
      $scene=Scene_Main.new
      return
    end   
    end
         $scene=Scene_Main.new
  end
end