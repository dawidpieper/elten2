#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Program
      def finish
            close
    speech("program \został zamknięty.")
    speech_wait
    $scene = Scene_Main.new
    return
  end
  def exit
    finish
  end
  def exit!
    finish
  end
  def self.finish
    finish
  end
  def self.init
    self.load
    if @usermenuoption != nil
      $usermenuextra=[] if $usermenuextra==nil
      $usermenuextrascenes=[] if $usermenuextrascenes==nil
      $usermenuextra.push(@usermenuoption)
      $usermenuextrascenes.push(self)
      end
      if @menulabel==nil
        @menulabel=@appname
      end
      $app=[] if $app==nil
      $app.push([@appname,@appversion,@menulabel,self])
              end
end
#Copyright (C) 2014-2016 Dawid Pieper