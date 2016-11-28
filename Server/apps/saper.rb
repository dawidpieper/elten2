class Program_Saper < Program
  def initialize
    @name = "Saper"
    @version = 0
    @author = "Dawid Pieper"
  end
  def main
    return if $scene != self
    speech("Saper")
    speech_wait
    sleep(1)
    speech("Naciśnij enter, aby rozpocząć grę. Naciśnij escape, aby wyjść.")
    loop do
      loop_update
      if enter
        sleep(0.1)
        start
      end
      if escape
        sleep(0.1)
        finish
      end
      break if $scene != self
      end
	  end
    def start
      @how = []
      for i in 0..9
        @how[i] = []
        end
      @tried = []
      for i in 0..9
        @tried[i] = []
      end
            @checked = []
      for i in 0..9
        @checked[i] = []
        end
      @mines = input_text("Podaj liczbę min do rozmieszczenia.").to_i
      if @mines > 20
        speech("Zbyt wiele min. Ustawiono 20.")
        speech_wait
        @mines = 20
      end
      if @mines < 3
        speech("Zbyt mało min Ustawiono 3..")
        speech_wait
        @mines = 3
      end
      @mine_pos_x = []
      @mine_pos_y = []
      used = []
      for i in 0..@mines - 1
        @mine_pos_x[i] = rand(10)
        @mine_pos_y[i] = rand(10)
        for j in 0..used.size - 1
          while used[j] == @mine_pos_x[i].to_s + " " + @mine_pos_y[i].to_s
            @mine_pos_x[i] -= rand(3) - 1
            @mine_pos_y[i] -= rand(3) - 1
            end
          end
          used[i] = @mine_pos_x[i].to_s + " " + @mine_pos_y[i].to_s
      end
       game
     end
     def game
       @lr = ["a","b","c","d","e","f","g","h","i","j"]
       @ud = ["1","2","3","4","5","6","7","8","9","10"]
       @lr_sel = SelectLR.new(@lr)
       speech_wait
       @ud_sel = Select.new(@ud,true)
       loop do
         loop_update
         olr = @lr_sel.index
         oud = @ud_sel.index
         @lr_sel.update
         @ud_sel.update
if oud != @ud_sel.index or olr != @lr_sel.index
  speech_stop
  inf = @lr[@lr_sel.index] + " " + @ud[@ud_sel.index]
  inf += " .  " + how(@lr_sel.index,@ud_sel.index).to_s if tried(@lr_sel.index,@ud_sel.index) == true
  speech(inf)
  play("right") if @checked[@lr_sel.index][@ud_sel.index]
end
if $key[0xD] and tried(@lr_sel.index,@ud_sel.index) == false
  open(@lr_sel.index, @ud_sel.index) if @checked[@lr_sel.index][@ud_sel.index] != true
end
if $key[0x1B]
  sleep(0.1)
  main
end
if $key[0x20] and tried(@lr_sel.index,@ud_sel.index) == false
  check(@lr_sel.index,@ud_sel.index)
  end
break if $scene != self
end
         end
              def how(x,y)
         if @how[x][y] == nil
           return(0)
         else
           return(@how[x][y])
           end
		   end
              def tried(x,y)
         if @tried[x][y] == true
           return(true)
         else
           return(false)
           end
         end
         def open(x,y)
           suc = false
           for i in 0..@mine_pos_x.size - 1
             if @mine_pos_x[i] == x and @mine_pos_y[i] == y
               suc = true
               end
             end
   if suc == true
play("explosion")
sleep(1)
main
return
end
mines = 0
for i in x-1..x+1
  for j in y-1..y+1
    for k in 0..@mine_pos_x.size - 1
      if @mine_pos_x[k] == i and @mine_pos_y[k] == j
        mines += 1
        end
      end
    end
end
speech(mines.to_s)
@tried[x][y] = true
@how[x][y] = mines
checked = 0
for i in 0..9
  for j in 0..9
    if @tried[i][j] == true
checked += 1      
      end
  end
end
if checked == 100 - @mines
  play("applause")
  sleep(1)
  main
  end
end
def check(x,y)
  if @checked[x][y] == true
    play("edit_delete")
  @checked[x][y] = false
else
  play("right")
  @checked[x][y] = true
  end
  end
    def close
    loop_update
    end
  end

for i in 0..$app.size -  1
if $app[i] == "Saper" or $app[i] == "SAPER"
$appstart[i] = Program_Saper
end
end