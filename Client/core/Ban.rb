#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
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
      user = input_text(_("Ban:type_banusername"),"ACCEPTESCAPE")
    end
    if user == "\004ESCAPE\004"
      if @scene == nil
        $scene = Scene_Main.new
      else
        $scene = @scene
        end
    end
sel = [_("Ban:opt_day"),_("Ban:opt_threedays"),_("Ban:opt_week"),_("Ban:opt_twoweeks"),_("Ban:opt_month"),_("Ban:opt_yrquarter"),_("Ban:opt_year")]
@form=Form.new([Select.new(sel,true,0,"Czas trwania okresu zbanowania",true),Edit.new(_("Ban:type_reason")),Edit.new(_("Ban:type_additionalmsg"),"MULTILINE"),Button.new(_("Ban:btn_ban")),Button.new(_("General:str_cancel"))])
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
  speech(_("Ban:info_banned"))
else
  speech(_("General:error"))
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
      user = input_text(_("Ban:type_unbanusername"),"ACCEPTESCAPE")
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
                    speech(_("General:error"))
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
                    @form=Form.new([Edit.new(_("Ban:read_reason"),"READONLY",bantemp[3],true),Edit.new(_("Ban:read_validuntil"),"READONLY",bantotime,true),Edit.new(_("Ban:type_cancelreason"),"","",true),Button.new(_("Ban:btn_unban")),Button.new(_("General:str_cancel"))])
    loop do
      loop_update
      @form.update
      break if ((space or enter) and @form.index==4) or escape
      if (space or enter) and @form.index==3
                    bantemp = srvproc("ban","name=#{$name}\&token=#{$token}\&searchname=#{@user}\&unban=1\&reason=#{@form.fields[2].text_str}")
      err = bantemp[0]
err = err.to_i
if err == 0
  speech(_("Ban:info_unbanned"))
speech_wait
break
  else
  speech(_("General:error"))
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
#Copyright (C) 2014-2019 Dawid Pieper