#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_SpeedTest
  def main
    @form=Form.new([Select.new([p_("SpeedTest", "Session refresh"),p_("SpeedTest", "What's new"),p_("SpeedTest", "Forum structure (uncompressed)"),p_("SpeedTest", "Forum structure (compressed)"),p_("SpeedTest", "Messages recipients"),p_("SpeedTest", "Blogs list")],true,0,p_("SpeedTest", "Unit to test"),true),Edit.new(p_("SpeedTest", "Number of attempts to perform"),Edit::Flags::Numbers,"10",true),Button.new(p_("SpeedTest", "Start")),Button.new(_("Cancel"))])
    loop do
      loop_update
      @form.update
      break if $scene!=self
      $scene=Scene_Main.new if ((space or enter) and @form.index==3) or escape
      if @form.fields[2].pressed? and @form.fields[1].text_str.to_i>0
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
                mod="forum_struct"
                params={'gz'=>1, 'useflags'=>1}
              when 4
                mod="messages_conversations"
                when 5
                  mod="blog_list"
                end
                speak(p_("SpeedTest", "Performing test, please wait"))
      n=@form.fields[1].text.to_i
      times=[]
      n.times {
            t=srvproc(mod,params,3)
     times.push(t)
     loop_update
           }
      result="#{p_("SpeedTest", "Average time")}: #{((times.sum).to_f/n.to_f*1000).round}ms
#{p_("SpeedTest", "Minimum time")}: #{((times.min)*1000).round}ms
#{p_("SpeedTest", "Maximum time")}: #{((times.max)*1000).round}ms

"
      for i in 0...n
        result+=(i+1).to_s+". "+(times[i]*1000).round.to_s+"ms\r\n"
        end
      input_text(p_("SpeedTest", "Test results"),Edit::Flags::ReadOnly,result)
      @form.focus
      end
      end
  end
  end