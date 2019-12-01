#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module Log
  class Entry
    attr_reader :level, :message, :time
    def initialize(level, message, time)
      @level=level
      @message=message
      @time=time
    end
  end
  Events=[]
    class <<self
      def add(level,msg, tm=nil)
                  tm=Time.now if tm==nil
                Events.push(Entry.new(level,msg, tm))
      end
      def debug(msg)
        add(-1,msg)
      end
      def info(msg)
        add(0,msg)
      end
      def warning(msg)
        add(1,msg)
      end
      def error(msg)
        add(2,msg)
      end
      def head(msg)
        add(nil,msg)
      end
      def get(limit=100, level=0, dsplevel=true)
        lg=[]
        lgh=[]
for i in 0...Events.size
  l=Events[i]
  w=""
  if dsplevel
  case l.level
  when -1
    w="D: "
    when 0
     w="I: "
     when 1
       w="W: "
       when 2
         w="E: "
       end
       end
       t=sprintf("%02d:%02d:%02d", l.time.hour, l.time.min, l.time.sec)
  txt=(w+l.message+" (#{t})")+""
  if l.level==nil
    lgh.push(txt)
  elsif l.level>=level
    lg.push(txt)
    end
  end
  li=0
  li=lg.size-limit if lg.size>limit
return lgh.join("\r\n")+"\r\n"+lg[li..-1].join("\r\n")
       
        end
     end 
  end
#Copyright (C) 2014-2019 Dawid Pieper