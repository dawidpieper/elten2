#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Users_LastAvatars
  def main
    avt=srvproc("lastavatars","name=#{$name}\&token=#{$token}")
    if avt[0].to_i<0
      speech("Błąd.")
      speech_wait
      return $scene=Scene_Main.new
    end
    @users=[]
    @times=[]
    t=0
    for l in avt[1..avt.size-1]
      if t==0
        @users.push(l.delete("\r\n"))
        t=1
      else
        begin
        t=Time.at(l.to_i)
          @times.push(sprintf("%04d-%02d-%02d %02d:%02d",t.year,t.month,t.day,t.hour,t.min))
      rescue Exception
        retry
        end
        t=0
        end
    end
    selt=[]
    for i in 0..29
      selt.push(@users[i]+" ("+@times[i]+")"+".\r\n"+getstatus(@users[i]))
    end
    @sel=Select.new(selt,true,0,"Ostatnio zmienione awatary")
    loop do
      loop_update
      @sel.update
      return $scene=Scene_Main.new if escape
      if enter or alt
      usermenu(@users[@sel.index])
      loop_update
      end
      end
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper