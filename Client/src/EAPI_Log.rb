#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

  module EltenAPI
module Log  
class Entry
    attr_reader :level, :message, :time
    def initialize(level, message, time)
      @level=level
      @message=message
      @time=time
    end
    def to_s(dsplevel=true, dspdate=true)
w=""
  if dsplevel
  case self.level
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
       t=sprintf("%02d:%02d:%02d", self.time.hour, self.time.min, self.time.sec)
  txt=w+self.message+""
  txt+=" (#{t})" if dspdate==true
  return txt
      end
  end
  Events=[]
  @@logfile=0
  @@writefile=nil
    class <<self
      include EltenAPI
      def add(level,msg, tm=nil)
        if @@logfile==0
          cf = Win32API.new("kernel32", "CreateFileW", 'piipiii', 'i')
          path=Dirs.eltendata+"\\elten.log"
          @@logfile = cf.call(unicode(path), 0x40000000, 1|2, nil, 2, 128, 0)
          end
                  tm=Time.now if tm==nil
                  e=Entry.new(level, msg, tm)
                Events.push(e)
                                if @@logfile>0
@@writefile = Win32API.new("kernel32","WriteFile",'ipipi','I') if @@writefile==nil
bp = [0].pack("l")
tx=e.to_s+"\n"
@@writefile.call(@@logfile, tx ,tx.size, bp, 0)
end
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
      def get(limit=100, level=0, dsplevel=true, dspdate=true)
        lg=[]
        lgh=[]
for i in 0...Events.size
  l=Events[i]
  txt=l.to_s(dsplevel, dspdate)
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

   end