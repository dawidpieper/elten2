class Program_Chess
def initialize
  @chessboard = [[2,3,4,5,6,4,3,2,0,0],[1,1,1,1,1,1,1,1,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[-1,-1,-1,-1,-1,-1,-1,-1,0,0],[-2,-3,-4,-5,-6,-4,-3,-2,0,0]]
  end
def correctmovement?(startx,starty,stopx,stopy,id)
return false if startx > 7 or startx < 0 or starty > 7 or starty < 0 or stopx > 7 or stopx < 0 or stopy > 7 or stopy < 0
if id == 1
return true if stopy == starty + 1 and stopx == startx and @chessboard[starty+1][startx] == 0
return true if stopy == starty + 2 and stopx == startx and @chessboard[starty+1][startx] == 0 and starty == 1
return true if stopy == starty + 1 and stopx == startx + 1 and @chessboard[starty+1][startx+1] < 0
return true if stopy == starty + 1 and stopx == startx - 1 and @chessboard[starty+1][startx-1] < 0
return false
end
if id == -1
return true if stopy == starty - 1 and stopx == startx and @chessboard[starty-1][startx] == 0
return true if stopy == starty - 2 and stopx == startx and @chessboard[starty-2][startx] == 0 and starty == 6
return true if stopy == starty - 1 and stopx == startx - 1 and @chessboard[starty-1][startx-1] > 0
return true if stopy == starty - 1 and stopx == startx + 1 and @chessboard[starty-1][startx+1] > 0
return false
end
if id == 2
return false if stopy != starty and stopx != startx
tstartx = startx
tstopx = stopx
tstarty = starty
tstopy = stopy
if startx < stopx
tstartx = startx
tstopx = stopx
end
if startx > stopx
tstartx = stopx
tstopx = startx
end
if starty < stopy
tstarty = starty
tstopy = stopy
end
if starty > stopy
tstarty = stopy
tstopy = starty
end
suc = true
for i in tstartx+1..tstopx-1
suc = false if @chessboard[starty][i] != 0
end
for i in tstarty+1..tstopy-1
suc = false if @chessboard[i][startx] != 0
end
suc = false if @chessboard[stopy][stopx] > 0
return suc
end
if id == -2
return false if stopy != starty and stopx != startx
tstartx = startx
tstarty = starty
tstopx = stopx
tstopy = stopy
if startx > stopx
tstartx = startx
tstopx = stopx
end
if startx < stopx
tstartx = stopx
tstopx = startx
end
if starty > stopy
tstarty = starty
tstopy = stopy
end
if starty < stopy
tstarty = stopy
tstopy = starty
end
suc = true
for i in tstartx+1..tstopx-1
suc = false if @chessboard[starty][i] != 0
end
for i in tstarty+1..tstopy-1
suc = false if @chessboard[i][startx] != 0
end
suc = false if @chessboard[stopy][stopx] < 0
return suc
end
if id == 3
suc = false
suc = true if ((startx - stopx == -1 or startx - stopx == 1) and (starty - stopy == -2 or starty - stopy == 2)) or ((startx - stopx == -2 or startx - stopx == 2) and (starty - stopy == -1 or starty - stopy == 1))
suc = false if @chessboard[stopy][stopx] > 0
return suc
end
if id == -3
suc = false
suc = true if ((startx - stopx == -1 or startx - stopx == 1) and (starty - stopy == -2 or starty - stopy == 2)) or ((startx - stopx == -2 or startx - stopx == 2) and (starty - stopy == -1 or starty - stopy == 1))
suc = false if @chessboard[stopy][stopx] < 0
return suc
end
if id == 4
tstartx = startx
tstarty = starty
tstopx = stopx
tstopy = stopy
if startx < stopx
tstartx = startx
tstopx = stopx
end
if startx > stopx
tstartx = stopx
tstopx = startx
end
if starty < stopy
tstarty = starty
tstopy = stopy
end
if starty > stopy
tstarty = stopy
tstopy = starty
end
suca = true
sucb = false
fin = 0
for i in 1..8
fin = i
if (startx + i == stopx or startx - i == stopx) and (starty + i == stopy or starty - i == stopy)
sucb = true
break
end
end
if suca == true
x = stopx - startx
y = stopy - starty
x = 1 if x > 0
y = 1 if y > 0
x = -1 if x < 0
y = -1 if y < 0
for i in 1..fin-1
if startx+x*i > 7 or starty+y*i > 7 or startx+x*i < 0 or starty+y*i < 0
break
else
if @chessboard[starty+y*i][startx+x*i] != 0
suca = false
end
end
end
end
suc = false
suc = true if suca == true and sucb == true
suc = false if @chessboard[stopy][stopx] > 0
return suc
end
if id == -4
tstartx = startx
tstarty = starty
tstopx = stopx
tstopy = stopy
if startx < stopx
tstartx = startx
tstopx = stopx
end
if startx > stopx
tstartx = stopx
tstopx = startx
end
if starty < stopy
tstarty = starty
tstopy = stopy
end
if starty > stopy
tstarty = stopy
tstopy = starty
end
suca = true
sucb = false
fin = 0
for i in 1..8
fin = i
if (startx + i == stopx or startx - i == stopx) and (starty + i == stopy or starty - i == stopy)
sucb = true
break
end
end
if suca == true
x = stopx - startx
y = stopy - starty
x = 1 if x > 0
y = 1 if y > 0
x = -1 if x < 0
y = -1 if y < 0
for i in 1..fin-1
if startx+x*i > 7 or starty+y*i > 7 or startx+x*i < 0 or starty+y*i < 0
break
else
if @chessboard[starty+y*i][startx+x*i] != 0
suca = false
end
end
end
end
suc = false
suc = true if suca == true and sucb == true
suc = false if @chessboard[stopy][stopx] < 0
return suc
end
if id == 5
suc = false
suc = true if correctmovement?(startx,starty,stopx,stopy,2) or correctmovement?(startx,starty,stopx,stopy,4)
return suc
end
if id == -5
suc = false
suc = true if correctmovement?(startx,starty,stopx,stopy,-2) or correctmovement?(startx,starty,stopx,stopy,-4)
return suc
end
if id == 6
suc = false
suc = true if (stopx - startx == -1 or stopx - startx == 1 or stopx - startx == 0) and (stopy - starty == -1 or stopy - starty == 1 or stopy - starty == 0)
suc = false if @chessboard[stopy][stopx] > 0
return suc
end
if id == -6
suc = false
suc = true if (stopx - startx == -1 or stopx - startx == 1) and (stopy - starty == -1 or stopy - starty == 1)
suc = false if @chessboard[stopy][stopx] < 0
return suc
end
end
def export
  exp = ""
  for y in 0..7
    for x in 0..7
      exp += @chessboard[y][x].to_s
    end
    end
  return exp
end
def import(imp)
  i = 0
  for y in 0..7
    for x in 0..7
      it = imp[i..i]
      if it == "-"
      i += 1
      it += imp[i..i]
      end
      @chessboard[y][x] = it.to_i
      i += 1
    end
    end
  end
def main
  speech("Czy chcesz rozpocząć nową grę?")
  speech_wait
  if simplequestion == 0
  @id = input_text("Identyfikator gry")
else
  @id = rand(4000000)
  @opponent = input_text("Twój przeciwnik:")
  download($url + "chess.php?name=#{$name}\&token=#{$token}\&new=1\&opponent=#{@opponent}\&id=#{@id}\&chessboard=#{export}","chesstemp")
  if IO.readlines("chesstemp")[0].to_i < 0
    speech("Błąd")
    $scene = Scene_Main.new
    return
  end
  input_text("Identyfikator gry","READONLY",@id.to_s)
  end
  download($url + "chess.php?name=#{$name}\&token=#{$token}\&get=1\&id=#{@id}","chesstemp")
  cp = IO.readlines("chesstemp")
  File.delete("chesstemp") if $DEBUG != true
  if cp[0].to_i < 0
    speech("Błąd")
    speech_wait
    $scene = Scene_Main.new
    return
  end
  @player = cp[1].delete("\r\n")
  @color = cp[2].to_i
  import(cp[3])
  @selx = SelectLR.new(["","","","","","","",""])
  @sely = Select.new(["","","","","","","",""])
  if @color == 1  
  speech("Ruch białych")
else
  speech("Ruch czarnych")
  end
  while @player != $name
  @selx.update
  @sely.update
  loop_update
  if escape
    $scene = Scene_Main.new
    return
    break
    end
  download($url + "chess.php?name=#{$name}\&token=#{$token}\&get=1\&id=#{@id}","chesstemp")
  cp = IO.readlines("chesstemp")
  File.delete("chesstemp") if $DEBUG != true
  if cp[0].to_i < 0
    speech("Błąd")
    speech_wait
    $scene = Scene_Main.new
    return
  end
  @player = cp[1].delete("\r\n")
  @color = cp[2].to_i
  import(cp[3])
  end
  if @color == 1
    speech("Ruch białych")
  else
    speech("Ruch czarnych")
    end
  loop do
    loop_update
    @selx.update
    @sely.update
    update
    break if $scene != self
    end
  end
  def update
    if Input.dir4 > 0
      x = @selx.index
      y = @sely.index
      id = @chessboard[y][x]
      desc = ""
      case id
      when 1
        desc = "Biały pion"
        when 2
          desc = "Biała wieża"
          when 3
            desc = "Biały skoczek"
            when 4
              desc = "Biały goniec"
              when 5
                desc = "Biały hetman"
                when 6
                  desc = "Biały król"
                  when -1
                    desc = "Czarny pion"
                    when -2
                      desc = "Czarna wieża"
                      when -3
                        desc = "Czarny skoczek"
                        when -4
                          desc = "Czarny goniec"
                          when -5
                            desc = "Czarny hetman"
                            when -6
                              desc = "Czarny król"
      end
            fx = ["a","b","c","d","e","f","g","h"]
      fy = ["1","2","3","4","5","6","7","8"]
      desc += ".\r\n" if desc != ""
      desc += fx[x]
      desc += fy[y]
speech(desc)
      end
    if $key[32] == true
      @x = @selx.index
      @y = @sely.index
      play("right")
    end
    if $key[13] == true and @x != nil and @y != nil
      suc = false
if @chessboard[@y][@x] > 0 and @color == 1      
  suc = true    
elsif @chessboard[@y][@x] < 0 and @color == -1
  suc = true
end
if suc == false
  speech("To nie jest twoja bierka.")
  return
  end
            if correctmovement?(@x,@y,@selx.index,@sely.index,@chessboard[@y][@x]) == true
        if @color == 1
          @color = -1
          speech("Ruch czarnych")
        else
          @color = 1
          speech("Ruch białych")
          end
              @chessboard[@sely.index][@selx.index] = @chessboard[@y][@x]
        @chessboard[@y][@x] = 0
        play("right")
            if @chessboard[@sely.index][@selx.index] == 1 and @sely.index == 7
        @chessboard[@sely.index][@selx.index] = 5
      end
      if @chessboard[@sely.index][@selx.index] == -1 and @sely.index == 0
      @chessboard[@sely.index][@selx.index] = -5
        end
    download($url + "chess.php?name=#{$name}\&token=#{$token}\&id=#{@id}\&chessboard=#{export}\&set=1","chesstemp")
    if IO.readlines("chesstemp")[0].to_i < 0
      speech("Błąd")
      speech_wait
      $scene = Scene_Main.new
      return
    end
    File.delete("chesstemp")
            delay
        @player = ""
            while @player != $name
          loop_update
		  @selx.update
		  @sely.update
    if escape
      $scene = Scene_Main.new
      return
      break
      end
          download($url + "chess.php?name=#{$name}\&token=#{$token}\&get=1\&id=#{@id}","chesstemp")
  cp = IO.readlines("chesstemp")
  File.delete("chesstemp") if $DEBUG != true
  if cp[0].to_i < 0
    speech("Błąd")
    speech_wait
    $scene = Scene_Main.new
    return
  end
  @player = cp[1].delete("\r\n")
  @color = cp[2].to_i
  import(cp[3])
end
if @color == 1
  speech("Ruch białych")
else
  speech("Ruch czarnych")
  end
  else
        speech("Ten ruch nie jest możliwy")
        end      
  end
if escape
  $scene = Scene_Main.new
  end
    end
end

for i in 0..$app.size -  1
if $app[i] == "Chess" or $app[i] == "chess"
$appstart[i] = Program_Chess
end
end