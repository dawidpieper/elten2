#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_SpeedTest
  def main
    @form=Form.new([Select.new([_("SpeedTest:opt_session"),_("SpeedTest:opt_whatsnew"),_("SpeedTest:opt_forum"),_("SpeedTest:opt_messages"),_("SpeedTest:opt_blogs")],true,0,_("SpeedTest:head_mode"),true),Edit.new(_("SpeedTest:type_attempts"),Edit::Flags::Numbers,"10",true),Button.new(_("SpeedTest:btn_start")),Button.new(_("General:str_cancel"))])
    loop do
      loop_update
      @form.update
      break if $scene!=self
      $scene=Scene_Main.new if ((space or enter) and @form.index==3) or escape
      if (space or enter) and @form.index==2
        mod=""
        params={}
        case @form.fields[0].index
        when 0
          mod="active"
          when 1
            mod="agent"
            when 2
              mod="forum_struct"
              when 3
                mod="messages_conversations"
                when 4
                  mod="blog_list"
                end
                speech(_("SpeedTest:wait"))
      n=@form.fields[1].text.to_i
      times=[]
      n.times {
            t=srvproc(mod,params,3)
     times.push(t)
     loop_update
           }
      result="#{_("SpeedTest:txt_phr_avgtime")}: #{((times.sum).to_f/n.to_f*1000).round}ms
#{_("SpeedTest:txt_phr_mintime")}: #{((times.min)*1000).round}ms
#{_("SpeedTest:txt_phr_maxtime")}: #{((times.max)*1000).round}ms

"
      for i in 0...n
        result+=(i+1).to_s+". "+(times[i]*1000).round.to_s+"ms\r\n"
        end
      input_text(_("SpeedTest:read_result"),Edit::Flags::ReadOnly,result)
      @form.focus
      end
      end
  end
  end
#Copyright (C) 2014-2019 Dawid Pieper