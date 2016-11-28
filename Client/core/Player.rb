#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Player
  def initialize(file,scene)
    @file = file.delete("\r\n").gsub(" ","%20")
    @scene = scene
  end
  def main
    @sound = AudioFile.new(@file)
    @sound.play
        loop do
loop_update
      update
      if $scene != self
        break
        end
      end
    end
    def update
      if space
        if @sound.playing?
        @sound.pause
      else
        @sound.play
        end
        end
      if escape
        for i in 1..Graphics.frame_rate
          @sound.volume -= 100.0/Graphics.frame_rate.to_f / 100.0
          end
        $scene = @scene
        $scene = Scene_Main.new if $scene == nil
      end
            if Input.repeat?(Input::RIGHT)
        @sound.position += 5000
      end
      if Input.repeat?(Input::LEFT)
        @sound.position -= 5000
      end
      end
  end
#Copyright (C) 2014-2016 Dawid Pieper