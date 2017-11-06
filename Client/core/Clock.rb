#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

class Scene_Clock
  def main
  @field=[]
  @field[0]=Select.new(["Brak","Głos i dźwięk","Tylko głos","Tylko dźwięk"],true,0,"Automatyczny odczyt czasu",true)
  @field[1]=Select.new(["godzinę","pół godziny","kwadrans"],true,0,"Odczytuj co",true)
  @field[2]=Select.new(["Dodaj"],true,0,"Alarmy",true)
@field[3]=Button.new("Zapisz")
@field[4]=Button.new("Anuluj")
@field[0].index=readini($configdata+"\\interface.ini","Interface","SayTimeType","1").to_i
@field[1].index=readini($configdata+"\\interface.ini","Interface","SayTimePeriod","1").to_i-1
@alarms=[]
@alarms=load_data($configdata+"\\alarms.dat") if FileTest.exists?($configdata+"\\alarms.dat")
sel=[]
for a in @alarms
  sel.push("Godzina: #{sprintf("%02d:%02d",a[0],a[1])}, typ: #{if a[2]==0;"Jednorazowy";else;"Cykliczny";end}")
  end
sel.push("Dodaj")
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
form=Form.new([Select.new(c[0..23],false,a[0],"Godzina",true),Select.new(c[0..59],false,a[1],"Minuta",true),Select.new(["Jednorazowy","Cykliczny"],true,a[2],"Rodzaj",true),Button.new("Zapisz"),Button.new("Anuluj")])
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
  sel.push("Godzina: #{sprintf("%02d:%02d",a[0],a[1])}, typ: #{if a[2]==0;"Jednorazowy";else;"Cykliczny";end}")
  end
sel.push("Dodaj")
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
  sel.push("Godzina: #{sprintf("%02d:%02d",a[0],a[1])}, typ: #{if a[2]==0;"Jednorazowy";else;"Cykliczny";end}")
  end
sel.push("Dodaj")
@field[2].commandoptions=sel
play("edit_delete")
loop_update
speech(@field[2].commandoptions[@field[2].index])
end
if (space or enter) and @form.index==3
  writeini($configdata+"\\interface.ini","Interface","SayTimeType",@field[0].index.to_s)
writeini($configdata+"\\interface.ini","Interface","SayTimePeriod",@field[1].index+1)
  save_data(@alarms,$configdata+"\\alarms.dat")
  speech("Zapisano")
  speech_wait
  $scene=Scene_Main.new
  break
  end
  end
end
end
#Copyright (C) 2014-2016 Dawid Pieper