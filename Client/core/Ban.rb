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
sel = ["Jeden dzień","Trzy dni","Tydzień","Dwa tygodnie","Trzydzieści dni","Dziewięćdziesiąt dni","Rok"]
@form=Form.new([Select.new(sel,true,0,"Czas trwania okresu zbanowania",true),Edit.new("Przyczyna"),Edit.new("Dodatkowa wiadomość dla użytkownika","MULTILINE"),Button.new("Zbanuj"),Button.new("Anuluj")])
loop do
  loop_update
  @form.update
  update
  break if $scene != self
end
end
def update
  if escape or ((space or enter) and @form.index==4)
        if @scene == nil
      $scene = Scene_Main.new
    else
      $scene = @scene
      end
    end
    if (enter or space) and @form.index==3
            totime = Time.now.to_i
      case @form.fields[0].index
          when 0
                    totime += 24 * 60 * 60
           when 1
             totime += 3 * 24 * 60 * 60
             when 2
               totime += 7 * 24 * 60 * 60
               when 3
                 totime += 2 * 7 * 24 * 60 * 60
                 when 4
                   totime += 30 * 24 * 60 * 60
                   when 5
                     totime += 3 * 30 * 24 * 60 * 60
                     when 6
                       totime += 365 * 24 * 60 * 60
                             end
           info=buffer(@form.fields[2].text_str)
                             bantemp = srvproc("ban","name=#{$name}\&token=#{$token}\&searchname=#{@user}\&totime=#{totime}\&ban=1\&reason=#{@form.fields[1].text_str.urlenc}\&info=#{info.to_s}")
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
                  bantemp = srvproc("isbanned","name=#{$name}\&token=#{$token}\&searchname=#{@user}")
                  if bantemp[0].to_i<0
                    speech("Błąd")
                    speech_wait
                    $scene=Scene_Main.new
                    return
                  end
                  if bantemp[1].to_i==1
                    
                    bantotime=""
                    begin
                    t=Time.at(bantemp[2].to_i)
                    bantotime=sprintf("%04d-%02d-%02d %02d:%02d:%02d",t.year,t.month,t.day,t.hour,t.min,t.sec)
                  rescue Exception
                    retry
                    end
                    @form=Form.new([Edit.new("Przyczyna zbanowania","READONLY",bantemp[3],true),Edit.new("Ban ważny do","READONLY",bantotime,true),Edit.new("Przyczyna anulowania bana","","",true),Button.new("Odbanuj"),Button.new("Anuluj")])
    loop do
      loop_update
      @form.update
      break if ((space or enter) and @form.index==4) or escape
      if (space or enter) and @form.index==3
                    bantemp = srvproc("ban","name=#{$name}\&token=#{$token}\&searchname=#{@user}\&unban=1\&reason=#{@form.fields[2].text_str}")
      err = bantemp[0]
err = err.to_i
if err == 0
  speech("Odbanowano.")
speech_wait
break
  else
  speech("Błąd.")
end
end
end
end
if @scene == nil
  $scene = Scene_Main.new
else
  $scene = @scene
  end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper