#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Program
  attr_reader :name
  attr_reader :version
  attr_reader :author
  def finish
    close
    speech("program: #{@name} został zamknięty.")
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
end
#Copyright (C) 2014-2016 Dawid Pieper