#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Ban_Ban
  def initialize(user="",scene=nil)
    @user = user
    @scene = scene
  end
  def main
    user = ""
    user = @user if @user != nil
    while user == ""
      user = input_text(p_("Ban", "Enter a username to ban"),0,"",true)
    end
    if user == nil
      if @scene == nil
        $scene = Scene_Main.new
      else
        $scene = @scene
        end
    end
sel = [p_("Ban", "Day"),p_("Ban", "Three days"),p_("Ban", "Week"),p_("Ban", "2 weeks"),p_("Ban", "30 days"),p_("Ban", "90 days"),p_("Ban", "Year")]
@form=Form.new([ListBox.new(sel,p_("Ban", "Ban time"),0,0,true),EditBox.new(p_("Ban", "The reason")),EditBox.new(p_("Ban", "An additional message to the user"),EditBox::Flags::MultiLine),Button.new(p_("Ban", "Ban")),Button.new(_("Cancel"))])
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
           info=buffer(@form.fields[2].text)
                             bantemp = srvproc("ban",{"searchname"=>@user, "totime"=>totime, "ban"=>"1", "reason"=>@form.fields[1].text, "info"=>info.to_s})
      err = bantemp[0]
err = err.to_i
if err == 0
  alert(p_("Ban", "Banned."))
else
  alert(_("Error"))
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
      user = input_text(p_("Ban", "Enter a username to unban."),0,"",true)
    end
    if user == nil
      if @scene == nil
        $scene = Scene_Main.new
      else
        $scene = @scene
        end
    end
                  bantemp = srvproc("isbanned",{"searchname"=>@user})
                  if bantemp[0].to_i<0
                    alert(_("Error"))
                    $scene=Scene_Main.new
                    return
                  end
                  if bantemp[1].to_i==1
                    
                    bantotime=""
                    t=Time.at(bantemp[2].to_i)
                    bantotime=format_date(t)
                                      @form=Form.new([EditBox.new(p_("Ban", "The ban reason"),EditBox::Flags::ReadOnly,bantemp[3],true),EditBox.new(p_("Ban", "Ban valid until"),EditBox::Flags::ReadOnly,bantotime,true),EditBox.new(p_("Ban", "The ban cancel reason"),"","",true),Button.new(p_("Ban", "Unban")),Button.new(_("Cancel"))])
    loop do
      loop_update
      @form.update
      break if ((space or enter) and @form.index==4) or escape
      if (space or enter) and @form.index==3
                    bantemp = srvproc("ban",{"searchname"=>@user, "unban"=>"1", "reason"=>@form.fields[2].text})
      err = bantemp[0]
err = err.to_i
if err == 0
  alert(p_("Ban", "Unbanned."))
speech_wait
break
  else
  alert(_("Error"))
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