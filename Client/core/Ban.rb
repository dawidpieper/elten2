#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Ban_Ban
  def initialize(user="",scene=nil)
    @user = user
    @scene = scene
  end
  def main
    user = ""
    user = @user if @user != nil
    while user == ""
      user = input_text("Podaj nazwę użytkownika do zbanowania.","ACCEPTESCAPE")
    end
    if user == "\004ESCAPE\004"
      if @scene == nil
        $scene = Scene_Main.new
      else
        $scene = @scene
        end
    end
speech("Wybierz czas trwania okresu zbanowania")
speech_wait
sel = ["Kwadrans","Godzina","Dwie godziny","Dzień","Dwa dni","Tydzień","Dwa tygodnie","Trzydzieści dni","Dziewięćdziesiąt dni","Sto osiemdziesiąt dni","Trzysta sześćdziesiąt dni"]
@sel = Select.new(sel)
loop do
  loop_update
  @sel.update
  update
  break if $scene != self
end
end
def update
  if escape
        if @scene == nil
      $scene = Scene_Main.new
    else
      $scene = @scene
      end
    end
    if enter
            totime = Time.now.to_i
      case @sel.index
   when 0
     totime += 15 * 60
     when 1
       totime += 60 * 60
       when 2
         totime += 2 * 60 * 60
         when 3
           totime += 24 * 60 * 60
           when 4
             totime += 2 * 24 * 60 * 60
             when 5
               totime += 7 * 24 * 60 * 60
               when 6
                 totime += 2 * 7 * 24 * 60 * 60
                 when 7
                   totime += 30 * 24 * 60 * 60
                   when 8
                     totime += 3 * 30 * 24 * 60 * 60
                     when 9 
                       totime += 6 * 30 * 24 * 60 * 60
                       when 10
                         totime += 12 * 30 * 24 * 60 * 60
      end
           bantemp = srvproc("ban","name=#{$name}\&token=#{$token}\&searchname=#{@user}\&totime=#{totime}\&ban=1")
      err = bantemp[0]
err = err.to_i
if err == 0
  speech("Zbanowano.")
else
  speech("Błąd.")
end
speech_wait
if @scene == nil
  $scene = Scene_Main.new
else
  $scene = @scene
  end
      end
  end
end


class Scene_Ban_Unban
  def initialize(user="",scene=nil)
    @user = user
    @scene = scene
  end
  def main
    user = ""
    user = @user if @user != nil
    while user == ""
      user = input_text("Podaj nazwę użytkownika do odbanowania.","ACCEPTESCAPE")
    end
    if user == "\004ESCAPE\004"
      if @scene == nil
        $scene = Scene_Main.new
      else
        $scene = @scene
        end
    end
                  bantemp = srvproc("ban","name=#{$name}\&token=#{$token}\&searchname=#{@user}\&unban=1")
      err = bantemp[0]
err = err.to_i
if err == 0
  speech("Odbanowano.")
else
  speech("Błąd.")
end
speech_wait
if @scene == nil
  $scene = Scene_Main.new
else
  $scene = @scene
  end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper