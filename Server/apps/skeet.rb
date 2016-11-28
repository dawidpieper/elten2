  class Program_Skeet < Program
def initialize
  @name = "Skeet"
  @version = 0
  @author = "Dawid Pieper"
end
def main
speech("Aby rozpocząć grę, naciśnij N. Aby opuścić program, naciśnij ESCAPE.")
speech_wait
loop do
loop_update
if $scene != self
break
end
if escape
sleep(0.1)
finish
return
break
end
if GetAsyncKeyState(78) != 0
sleep(0.1)
@level = 1
@lives = 3
@points = 0
@speed = 40
difficulty
return
break
end
end
end
def difficulty
  speech("Wybierz poziom trudności")
  speech_wait
  @sel = SelectLR.new(["Łatwy","Średni","Trudny"])
  loop do
loop_update
    @sel.update
    if escape
      sleep(0.1)
      main
      return
      break
      end
    if enter
      @difficulty = @sel.index + 1
      game
      return
      break
      end
    end
  end
def game
  playpos("right",0)
while @lives > 0
  speech("Poziom: #{@level}, punkty: #{@points}, życia: #{@lives}.\r\nNaciśnij spację, aby wypuścić dysk.")
  speech_wait
  Input.update
  until Input.trigger?(Input::C)
    Graphics.update
    Input.update
    playpos("right",0) if Input.trigger?(Input::L)
  end
  sleep(0.1)
pos = -0.9 - ((rand(3 + @difficulty).to_f / 6.to_f).to_f).to_f
points = 2250 + (@difficulty * 50)
fin = false
for i in 0..20 + rand(4)
pos += (0.1).to_f
playpos("right",pos.to_f)
for j in 1..@speed
points -= 5 if points > 4
sleep(0.01)
Graphics.update
Input.update
if Input.trigger?(Input::C)
  fin = true
  break
  end
end
Graphics.update
if fin == true
playpos("edit_endofline",pos)
break
end
end
case @difficulty
when 1
  min = -0.8
  max = 0.8
  when 2
    min = -0.5
    max = 0.5
    when 3
      min = -0.2
      max = 0.2
end
if pos >= min and pos <= max
@points += points
@level += 1
speech("Trafiony.\r\n")
speech_wait
else
speech("Pudło.")
speech_wait
@level += 1
@lives -= 1
end
@speed -= 1 if @speed > 1
end
speech("Koniec gry.\r\nTwój wynik.\r\nPunkty: #{@points} .\r\nPoziom: #{@level}")
speech_wait
main
return
end
def close
  end
end

for i in 0..$app.size -  1
if $app[i] == "Skeet" or $app[i] == "skeet"
$appstart[i] = Program_Skeet
end
end