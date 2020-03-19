#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

class Scene_Clock
  def main
  @field=[]
  @field[0]=Select.new([p_("Clock", "None"),p_("Clock", "Voice and sound"),p_("Clock", "Voice only"),p_("Clock", "Sound only")],true,0,p_("Clock", "Auto timereading"),true)
  @field[1]=Select.new([p_("Clock", "every hour"),p_("Clock", "every half hour"),p_("Clock", "every quarter of an hour")],true,0,p_("Clock", "announce time"),true)
  @field[2]=Select.new([p_("Clock", "Add")],true,0,p_("Clock", "Alarms"),true)
@field[3]=Button.new(_("Save"))
@field[4]=Button.new(_("Cancel"))
@field[0].index=readconfig("Clock","SayTimeType","1").to_i
@field[1].index=readconfig("Clock","SayTimePeriod","1").to_i-1
@alarms=[]
@alarms=load_data($eltendata+"\\alarms.dat") if FileTest.exists?($eltendata+"\\alarms.dat")
sel=[]
for a in @alarms
  sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "repeated");end}")
  end
sel.push(p_("Clock", "Add"))
@field[2].commandoptions=sel
@form=Form.new(@field)
loop do
  loop_update
  @form.update
  if escape or ((space or enter) and @form.index==4)
    $scene=Scene_Main.new
        return
        break
  end
  if enter and @form.index==2
a=[Time.now.hour,Time.now.min,0]
a=@alarms[@field[2].index] if @alarms[@field[2].index]!=nil
c=[]
for i in 0..59
  c.push(i.to_s)
  end
form=Form.new([Select.new(c[0..23],false,a[0],p_("Clock", "Hour"),true),Select.new(c[0..59],false,a[1],p_("Clock", "Minute"),true),Select.new([p_("Clock", "One time"),p_("Clock", "Repeated")],true,a[2],p_("Clock", "Type"),true),Button.new(_("Save")),Button.new(_("Cancel"))])
loop do
loop_update
  form.update
  if escape or ((space or enter) and form.index==4)
    break
  end
  if ((space or enter) and form.index==3)
    a=[form.fields[0].index,form.fields[1].index,form.fields[2].index]
    @alarms[@form.fields[2].index]=a
   sel=[]
for a in @alarms
  sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "Repeated");end}")
  end
sel.push(p_("Clock", "Add"))
@field[2].commandoptions=sel 
break
    end
  end
loop_update
  @form.fields[2].focus
    end
if $key[0x2e] and @form.index==2 and @alarms[@form.fields[2].index]!=nil
@alarms.delete_at(@form.fields[2].index)
sel=[]
for a in @alarms
  sel.push("#{p_("Clock","Hour")}: #{sprintf("%02d:%02d",a[0],a[1])}, #{p_("Clock","Type")}: #{if a[2]==0;p_("Clock", "One time");else;p_("Clock", "Repeated");end}")
  end
sel.push(p_("Clock", "Add"))
@field[2].commandoptions=sel
play("edit_delete")
loop_update
speech(@field[2].commandoptions[@field[2].index])
end
if (space or enter) and @form.index==3
  writeconfig("Clock","SayTimeType",@field[0].index.to_s)
writeconfig("Clock","SayTimePeriod",@field[1].index+1)
  save_data(@alarms,$eltendata+"\\alarms.dat")
  alert(_("Saved"))
  $scene=Scene_Main.new
  break
  end
  end
end
end