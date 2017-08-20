#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module Controls
      class Form
        attr_accessor :index
        attr_accessor :fields
        def initialize(fields,index=0)
          @fields = fields
          @index = index
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
              @fields[@index] = Edit.new(@fields[@index][1],@fields[@index][2],@fields[@index][3],false,@fields[@index][4])
            end
            end
          @fields[@index].focus
          play("form_marker")
          loop_update
        end
        def update
                            if $key[0x09] == true
            if $key[0x10] == false
              ind=@index
              @index += 1
              while @fields[@index] == nil and @index<@fields.size
                @index+=1
              end
              if @index >= @fields.size
                @index=ind
                play("border")
            end
          else
ind=@index
            @index-=1
            while @fields[@index]==nil
              @index-=1
              end
            if @index < 0
              @index = ind
                          play("border")
                                      end
          end
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
@fields[@index] = Edit.new(@fields[@index][1],@fields[@index][2],@fields[@index][3],false,@fields[@index][4])
            end
            end
                      @fields[@index].focus
        else
          @fields[@index].update
end
                  end
                end
  def input_text(header="",type="normaltext",text="")
  ro = false
  type.gsub("READONLY") {
  ro = true
  }
  ae = false
    type.gsub("ACCEPTESCAPE") {
  ae = true
  }
  ml = false
      type.gsub("MULTILINE") {
  ml = true
  }
        type.gsub("MULTILINES") {
  ml = true
  }
  dialog_open
  inp = Edit.new(header,type,text)
  loop do
loop_update
    inp.update
    rtmp = false
    rtmp = true if ml == false or $key[0x11] == true
    break if enter and rtmp == true
    if ro == true and ($key[0x09] == true or escape or alt)
      r = ""
  r = "\004ALT\004" if alt
    r = "\004TAB\004" if $key[0x09] == true and $key[0x10] == false
    r = "\004SHIFTTAB\004" if $key[0x09] == true and $key[0x10] == true
    r = "\004ESCAPE\004" if escape
    Audio.bgs_stop
    dialog_close  
    return r
      break
      end
    if escape and ae == true
      Audio.bgs_stop
      dialog_close
      return("\004ESCAPE\004")
      break
      end
    end
    inp.finalize
    Audio.bgs_stop
    r=inp.text_str
  dialog_close
    return r
end

  class Edit
  attr_accessor :text
  attr_accessor :index
  attr_accessor :line
    attr_accessor :bindex
  attr_accessor :bline
    attr_accessor :eindex
  attr_accessor :eline
  attr_accessor :textstr
  attr_accessor :edit_clp
attr_accessor :readonly
attr_accessor :acceptescape
attr_accessor :accepttab
attr_accessor :multilines
attr_accessor :word
attr_accessor :audiotext
attr_accessor :silent
def initialize(header="",type="NORMALTEXT",text="",quiet=false,init=false)
  @origtext=text  
  @text=text.to_s.gsub(/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/) do
      @audiotext=$1
      ""
      end
    @header = header
  @type = type
    @quiet = quiet
    if init == false
        @toinit = true
                return
    end
@repeat = nil
    @undo = []
@toundo = [[],0,0]
@changed = false    
header = dict(header)
  @word = ""
  @readonly = false
  @acceptescape = false
  @accepttab = false
@multilines = false
  @changed = true#*
  @text = []
@text[0] = []
@index = 0
  @index = @text[0].size
@line = 0
@lines = 0
@eindex = @index
@eline = @line
@header = header
                                                      gks = Win32API.new($eltenlib,"KeyState",'i','i')
                                                      type.downcase.gsub("password") do
                                                        "password"
                                                        @password = true
                                                      end
                                                      type.gsub("pas") do
                                                        "pas"
                                                        @password = true
                                                        end
type.gsub("acceptescape") do
  "acceptescape"
  @acceptescape = true
  end
  type.gsub("ACCEPTESCAPE") do
  "ACCEPTESCAPE"
  @acceptescape = true
end
type.gsub("readonly") do
  text = header if text == ""
  @readonly = true
  "readonly"
end
type.gsub("READONLY") do
  text = header if text == ""
@readonly = true
"READONLY"
end
type.gsub("accepttab") do
  "accepttab"
  @accepttab = true
  end
  type.gsub("ACCEPTTAB") do
  "ACCEPTTAB"
  @accepttab = true
end
  type.gsub("ACCEPTALT") do
  "ACCEPTALT"
  @acceptalt = true
end  
  type.gsub("acceptalt") do
  "ACCEPTALT"
  @acceptalt = true
end
type.gsub("MULTILINES") do
  "MULTILINES"
  @multilines = true
end
  type.gsub("MULTILINE") do
  "MULTILINE"
  @multilines = true
end
text = "" if text == nil
  if text.size > 0
    text.gsub!("\004LINE\004","\n")
    text.delete!("\r")
    text.delete!("\004")
    tm=text.split("\n")
    @text=[]
    for l in tm
      @text.push(dict(l).split(""))
    end
    @lines=@text.size-1
    setline(0)
    setindex(0)
  end
    @textstr = text
  focus if quiet != true
end
def update
      if @toinit == true
  @toinit = false
  initialize(@header,@type,@text,false,true)
    end
        s = false
                  if @changed == true
        @changed = false
                if @undo[0] != nil
  s = true if @text != @toundo[0]
  else
  s = true
end
    if s == true
      suc=false                                      
      if @undothread==nil
        suc=true
      else
        if @undothread.is_a?(Thread)
        suc=true if @undothread.status==false
        end
        end
        if suc == true              
        @undothread=Thread.new do
                        @undo.insert(0,@toundo)
                        @toundo=[@text.deep_dup,@index,@line]
                                                @undothread=nil
                        s = false
                                              end
                      end
          end
            if @undo.size > 100
        @undo.delete_at(@undo.size-1)
  end
  end
        if $focus == true
    focus
    $focus = false
  end
  index=@index
  line=@line
  eindex=@eindex
  eline=@eline
          curupdate($key[0x10])
                          if @index!=@eindex or @line!=@eline
    play("edit_checked")
    end
if $key[115] == true and $key[0x10] == false
  t=""
  ind = @index
  for i in @line..@lines
    ind = 0 if i>@line
t+=@text[i][ind..@text[i].size-1].to_s
    t+="\r\n"
  end
  t="\004AUDIO\004#{@audiotext}\004AUDIO\004"+t if @audiotext!=nil
      speech(t)
  end
if escape
  Audio.bgs_stop
  end
if $key[0x11] == true and $key[67] == true and $key[0x12] == false
  gc = getcheck
    Win32API.new($eltenlib,"CopyToClipboard",'pp','v').call(utf8(gc.to_s),utf8(gc.to_s).size + 1)
    speech("Skopiowano")
  end
  if $key[0x11] == true and $key[88] == true and $key[0x12] == false
  gc = getcheck
    Win32API.new($eltenlib,"CopyToClipboard",'pp','v').call(utf8(gc.to_s),utf8(gc.to_s).size + 1)
    delcheck
    speech("Wycięto")
  end
  if $key[0x11] == true and $key[86] == true and $key[0x12] == false
    txt = futf8(Win32API.new($eltenlib,"PasteFromClipboard",'v','p').call)
    txtt = []
    txt.delete!("\r")
    txtt[0] = []
    r = 0
    i = 0
    loop do
      if txt[i..i] == "\n"
        r += 1
        txtt[r] = []
      else
        if utf8(txt[i..i]) == "?" and txtt[i..i] != "?"
          txtt[r].push(txt[i..i+1])
          i += 1
        else
        txtt[r].push(txt[i..i])
        end
      end
          i += 1
    break if i > txt.size - 1
      end      
      @text[@line] += txtt[0]
       if txtt.size >= 2
         if @lines == @line
           @lines += 1
           @text[@line + 1] = []
           end
      @text[@line + 1] = txtt[txtt.size - 1] + @text[@line + 1]
      max = 0
      for i in 1..txtt.size - 2
        @text.insert(@line+i,txtt[i])
        max += 1
      end
      @lines += max
      setline(max + 1)
      end
      setindex(@index + txtt[txtt.size - 1].size)
      speech("Wklejono")
    end
    if $key[0x11] == true and $key[90] == true and $key[0x12] == false and @undo.size>0
      if @undo[0][0]!=nil and @undo[0][0]!=[]
              @text = @undo[0][0]
      @index = @undo[0][1]
      @line = @undo[0][2]
      @eindex = @index
      @eline = @line
@repeat = @toundo
      @undo.delete_at(0)
      @toundo = [textcopy,@index,@line]
      end
      speech("Cofnięto")
      end
    if $key[0x11] == true and $key[89] == true
      if @repeat != nil
        @text = @repeat[0]
        @index = @repeat[1]
        @line = @repeat[2]
        @repeat = nil
        speech("Powtórzono")
        end
      end
if $key[0x11] == true and $key[82] == true and $key[0x12]==false and FileTest.exists?("temp/savedtext.tmp")
  settext(read("temp/savedtext.tmp"))
  speech("Wczytano")
  end
      if $key[0x11] == true and $key[83] == true and $key[0x12]==false
        writefile("temp\\savedtext.tmp",text_str)
        speech("Zapisano")
        end
      if $key[0x11] == true and $key[84] == true and $key[12]==false
              gc = getcheck
                            gc=text_str if gc.size<=2 or gc==nil or gc=="\004LINE\004"
                                                        if $key[0x10]==false
              speech(translate(0,$language,gc))
            else
              translator(gc)
              end
    end
    if $key[0x11] == true and $key[65] == true and $key[0x12] == false
      setindex(0)
      setline(0)
      @eline = @lines
      @eindex = @text[@eline].size - 1
            end
  if $key[0x11] == true or @multilines == false
  rtmp = true
else
  rtmp = false
  end
  if $key[0xD] and rtmp == true and @readonly != true
  play("list_select")
      finalize
@textstr += "\005" if @multilines == true
    @textstr = @textstr
    return(@textstr)
  end
  if $key[0x09] and @readonly == true and @accepttab == true
        if $key[0x10] == false
    return("\004TAB\004")
  else
    return("\004SHIFTTAB\004")
  end
  end
  if $key[0x12] and @readonly == true and @acceptalt == true
    @readonly = false
    return("\004ALT\004")
    end
  if $key[0x1B] and @acceptescape == true and @readonly != true
    @readonly = false
    return("\004ESCAPE\004")
  end
      if $key[0x09] == true and @accepttab == true
      if $key[0x10] == false
        @text = []
    @text[0] = ["\004","T","A","B","\004"]
    return("\004TAB\004")
  else
    @text = []
    @text[0] = ["\004","S","H","I","F","T","T","A","B","\004"]
    return("\004SHIFTTAB\004")
    end
  end
  if $key[0x1B] and @readonly == true and @acceptescape == true
    @readonly = false
    return("\004ESCAPE\004")
    end
  t=getkeychar
if t==" "
      if @index >= 100 and @readonly != true and @multilines == true
              @text[@line] = [] if @text[@line] == nil
        if @index >= @text[@line].size
@lines = 0 if @lines == nil
@lines += 1
setline(@line+1)
@text.insert(@line,[])
@text[@line] = []
setindex(0)
else
  @lines = 0 if @lines == nil
@lines += 1
setline(@line + 1)
@text.insert(@line,[])
text = @text[@line - 1][@index..@text[@line - 1].size - 1]
text = [] if text == nil
  @text[@line] = text
for i in 0..@text[@line - 1].size - @index - 1
 @text[@line - 1].delete_at(@text[@line - 1].size - 1)
  end
setindex(0)
end
espeech("\n")
@word = "" if @word == nil
espeech(@word) if ($interface_typingecho == 1 or $interface_typingecho == 2) and @word.size > 1
  @word = ""
      else
    @text = @text = input_text_multilines_push(@text,@line,@index," ")
    end
    @changed = true#*
  end
if t!="" and t!=" "
@text = @text = input_text_multilines_push(@text,@line,@index,t)
    @changed = true#*
end
if @readonly != true
  if $key[0x08] and (@index > 0 or @line > 0 or (@eline != @line or @index != @eindex)) and @readonly != true
    gc = getcheck
    if @index == @eindex and @line == @eline
if @text[@line].size > 0 and @index > 0
  play("edit_delete")
    espeech(@text[@line][@index - 1])
    @text[@line].delete_at(@index - 1)
    setindex(@index - 1)
    @word.chop!
else
if @line > 0
  setindex(@text[@line-1].size)
  @text[@line-1] += @text[@line]
  play("edit_delete")
@text.delete_at(@line)
setline(@line - 1)
@lines -= 1
end
end
elsif @index != @eindex or @line != @eline
  play("edit_delete")
  delcheck
  setindex(@index - 1) if @index > 0
  espeech(@text[@line][@index]) if (@text[@line][@index] != nil)
end
@changed = true#*
    end
    if $key[0x2E]
      if $key[0x11] == false
      gc = getcheck
      if @index == @eindex and @line == @eline
  if @index < @text[@line].size
            play("edit_delete")
    if @index < @text[@line].size - 1
    espeech(@text[@line][@index + 1])
  else
    espeech("\n")
    end
    @text[@line].delete_at(@index)
  else
    if @line < @lines
          play("edit_delete")
for i in 0..@text[@line + 1].size - 1
  @text[@line].push(@text[@line + 1][i])
end
@text[@line + 1] = []
if @lines > @line + 1
for i in @line + 2..@lines
  @text[i - 1] = @text[i]
end
@lines -= 1
else
  @lines -= 1
end
if @index > @text[@line].size
  setindex(@index - 1)
  end
if @index < @text[@line].size
espeech(@text[@line][@index])
else
  espeech("\n")
  end
end
end
elsif @index != @eindex or @line != @eline
  play("edit_delete")
  delcheck
  if @text[@line] != nil
  espeech(@text[@line][@index]) if (@text[@line][@index] != nil)
  end
end
else
  @text = []
  @lines = 0
  @text[0] = []
  @line = 0
  @index = 0
  @eindex = 0
  play("edit_delete")
end
end
    @changed = true#*
  end
  @bindex = @index
  @bline = @line
end
def input_text_multilines_push(text,line,index,char)
  if @readonly != true
  @index = index
  @text = text
@line = line
char = "" if char == nil
if @text[@line].size == @index
@text[@line].push(char)
else
@text[@line].insert(@index,char)
end
@eindex=@index=@index + 1
speech_stop
espeech(char) if $interface_typingecho == 0 or $interface_typingecho == 2 or char == " "
cnr = [",",".","/",";","'","[","]","-","=","<",">","?",":","\"","{","}","|","+","_","!","@","#","$","%","^","&","*","(",")","\\"," "]
cnf = false
for i in 0..cnr.size - 1
  cnf = true if cnr[i] == char
  end
@word += char
if cnf == true
    espeech(@word) if $interface_typingecho == 1 or $interface_typingecho == 2
  @word = ""
  end
  @changed = true#*
return(@text)
else
  if $key[0x20]==true and @audiotext!=nil
    if $speechaudio != nil
      if $speechaudio.closed==false
        if $speechaudio.playing?
          $speechaudio.pause
        else
          $speechaudio.play
          end
        end
      end
    else
  play("border")
  end
  return(@text)
end
end
def finalize
  @textstr = ""
for l in @text
  @textstr+=l.to_s+"\004LINE\004"
end
@textstr.gsub!("\004LINE\004","") if @multilines == false
@text_o = @textstr
if escape or enter or $key[0x09]
  Audio.bgs_stop
  end
if @acceptescape == true and @text[0][0] == "\004"
        return("\004ESCAPE\004")
      end
          return(@textstr)
  end
def text_str
return "" if @text=="" or @line==nil
  finalize
  return @textstr
  end
def getindex(chk=false)
  if chk == false
    return @index
  else
    return @eindex
  end
end
def getline(chk=false)
  if chk == false
    return @line
  else
    return @eline
  end
  end
  def setindex(setter,wordreset=true)
  @word = "" if wordreset == true
    Audio.bgs_stop
  if $key[0x10]==false
    @index = setter
  @eindex = setter
  @eline = @line
else
  @eindex = setter
  end
  end
def setline(setter)
  @word = ""
  if $key[0x10] == false
  @line = setter
  @eline = setter
else
  @eline=setter
  end
  end
def curupdate(chk=false)
    if Input.trigger?(Input::LEFT)
    if $key[0x11] == false
      if getindex(chk) > 0
      setindex(getindex(chk) - 1)
      espeech(@text[getline(chk)][getindex(chk)])
      @changed = true#*
else
if getline(chk) > 0
setline(getline(chk)-1)
setindex(@text[getline(chk)].size)
espeech("\n")
else
  play("border")
end
end
else
  f,l,t=findword(-1)
  setline(l)
  setindex(f)
  espeech(t)
  end
  end
  if Input.trigger?(Input::RIGHT)
    if $key[0x11] == false
      if getindex(chk) < @text[getline(chk)].size - 1
      setindex(getindex(chk) + 1)
      espeech(@text[getline(chk)][getindex(chk)])
      @changed = true#*
    elsif getindex(chk) == @text[getline(chk)].size - 1
      setindex(getindex(chk) + 1)
            espeech("\n")
            play("border") if getline(chk) == @liness
      @changed = true#*
elsif getindex(chk) > @text[getline(chk)].size - 1
if @lines > getline(chk)
setline(getline(chk) + 1)
setindex(0)
@text[getline(chk)] = [] if @text[getline(chk)] == nil
espeech(@text[getline(chk)][0].to_s)
end
end
else
f,l,t=findword(1)
  setline(l)
  setindex(f)
  espeech(t)
  end    
  end
    if $key[0x23] and $key[0x11] == false
      setindex(@text[getline(chk)].size)
      espeech("\n")
    end
    if $key[0x24] and $key[0x11] == false
      espeech(@text[getline(chk)][0])
      setindex(0)
      end
  if $key[0x23] and $key[0x11] == true
setline(@lines)
    setindex(@text[getline(chk)].size)
    tmp = ""
      for i in 0..@text[getline(chk)].size-1
  tmp += @text[getline(chk)][i]
end
espeech(tmp)
    end
    if $key[0x24] and $key[0x11] == true
            setline(0)
      setindex(0)
tmp = ""
for i in 0..@text[getline(chk)].size-1
  tmp += @text[getline(chk)][i]
end
espeech(tmp)
      end
      if $key[0x21] == true
        line = getline(chk) - 15
        line = 0 if line < 0
        setline(line)
        tmp = ""
for i in 0..@text[getline(chk)].size-1
  tmp += @text[getline(chk)][i]
end
espeech(tmp)
end
if $key[0x22] == true
  line = getline(chk)+15
  line = @lines if line > @lines
  setline(line)
  tmp = ""
for i in 0..@text[getline(chk)].size-1
  tmp += @text[getline(chk)][i]
end
espeech(tmp)
  end
      @text[getline(chk)] = [] if @text[getline(chk)] == nil
if ($key[0x0D] and $key[0x11] == false and @readonly == true) and @multilines == true
  link = ""
  lso = 0
  c = @text[getline(chk)]
  for i in 0..c.size-1
        if lso == 0
      if c[i].to_s == "h" and c[i+1].to_s == "t" and c[i+2].to_s == "t" and c[i+3].to_s == "p" and (c[i+4].to_s == ":" or c[i+5].to_s == ":") and (c[i+5].to_s == "/" or c[i+6].to_s == "/")
      lso = 1
      end
      end
    if lso == 1
      link += c[i].to_s
      lso = 2 if c[i+1].to_s == " "
    end
  end
  if link != ""
    system("start #{link}")
    end
  end
      if ($key[0x0D] and $key[0x11] == false and @readonly != true) and @multilines == true
                @text[getline(chk)] = [] if @text[getline(chk)] == nil
        if getindex(chk) >= @text[getline(chk)].size
@lines = 0 if @lines == nil
@lines += 1
setline(getline(chk)+1)
@text.insert(getline(chk),[])
@text[getline(chk)] = []
setindex(0)
else
  @lines = 0 if @lines == nil
@lines += 1
setline(getline(chk) + 1)
@text.insert(getline(chk),[])
text = @text[getline(chk) - 1][getindex(chk)..@text[getline(chk) - 1].size - 1]
text = [] if text == nil
  @text[getline(chk)] = text
for i in 0..@text[getline(chk) - 1].size - getindex(chk) - 1
 @text[getline(chk) - 1].delete_at(@text[getline(chk) - 1].size - 1)
  end
setindex(0)
end
espeech("\n")
@word = "" if @word == nil
espeech(@word) if ($interface_typingecho == 1 or $interface_typingecho == 2) and @word.size > 1
  @word = ""
end
  if Input.trigger?(Input::DOWN)
if @lines > getline(chk)
    buf = ""
    @text[getline(chk) + 1] = [] if @text[getline(chk) + 1] == nil
for i in 0..@text[getline(chk) + 1].size - 1
buf += @text[getline(chk) + 1][i].to_s
end
      espeech(buf)
setline(getline(chk) + 1)
if @text[getline(chk)].size >= @text[getline(chk) - 1].size - 1
else
setindex(@text[getline(chk)].size)
end
else
  play("border")
      buf = ""
for i in 0..@text[getline(chk)].size - 1
buf += @text[getline(chk)][i].to_s
end
      espeech(buf)
      end
  end
  if Input.trigger?(Input::UP)
if getline(chk) > 0
setline(getline(chk) - 1)
buf = ""
while @text[getline(chk)]==nil and getline(chk) > 0
  setline(getline(chk)-1)
end
@text[getline(chk)]=[] if @text[getline(chk)]==nil
for i in 0..@text[getline(chk)].size - 1
  buf += @text[getline(chk)][i].to_s
  end
espeech(buf)
@text[getline(chk)]=[] if @text[getline(chk)]==nil
@text[getline(chk)+1]=[] if @text[getline(chk)+1]==nil
if @text[getline(chk)].size > @text[getline(chk) + 1].size - 1
else
setindex(@text[getline(chk)].size)
end
else
  play("border")
  buf = ""
for i in 0..@text[getline(chk)].size - 1
  buf += @text[getline(chk)][i].to_s
  end
espeech(buf)
end
end
end
def getcheck
  if @text[@line] == nil or @text[@eline] == nil
    return ""
    end
  check = ""
if @line == @eline
  if @eindex > @index
  check = @text[@line][@index..@eindex]
else
    check = @text[@line][@eindex..@index]
  end
else
  if @eline > @line
  check = @text[@line][@index..@text[@line].size - 1]
  check += ["\r","\n"]
  for i in @line + 1..@eline - 1
  check += @text[i][0..@text[i].size - 1]
  check += ["\r","\n"]
end
  check += @text[@eline][0..@eindex]
else
      check = @text[@eline][@eindex..@text[@eline].size - 1]
      check += ["\r","\n"]
  for i in @eline + 1..@line - 1
  check += @text[i][0..@text[i].size - 1]
  check += ["\r","\n"]
end
      check += @text[@line][0..@index]
  end
end
if check.is_a?(Array)
  tc = []
  for i in 0..check.size - 1
    tc.push(check[i])
    end
  check = tc
    end
return check
end
def delcheck
  @word = ""
  if @line == @eline
  if @eindex > @index
  for i in @index..@eindex
    @text[@line].delete_at(@index)
    end
else
      for i in @eindex..@index
    @text[@line].delete_at(@eindex)
    end
  end
else
  if @eline > @line
  for i in @index..@text[@line].size - 1
    @text[@line].delete_at(@index)
    end
  max = 0
  for i in 0..@eindex
    @text[@eline].delete_at(0)
  end
      t = @text[@line][0..@index - 1]
      @text[@eline] = t + @text[@eline]
        for i in @line..@eline - 1
    @text.delete_at(@line)
    max += 1
  end
  @lines -= max
    else
        for i in @eindex..@text[@eline].size - 1
    @text[@eline].delete_at(@eindex)
    end
  max = 0
    t = @text[@eline][0..@eindex - 1]
  for i in 0..@index
    @text[@line].delete_at(0)
  end
      @text[@line] = t + @text[@line]
        for i in @eline..@line - 1
    @text.delete_at(@eline)
    max += 1
  end
  @lines -= max
      end
    end
    @eindex = @index
    @eline = @line
    Audio.bgs_stop
@changed = true#*
    end
def settext(text,reset=true)
  if @toinit == true
  @toinit = false
    initialize(@header,@type,text,false,true)
    end
  @word = ""
  if reset == true
  setindex(0)
  @line = 0
    @eindex=0
  @eline = 0
end
text.gsub!("\004LINE\004","\n")  
i = 0
        text.delete!("\r")
        i = 0
    t = 0
    line=0
    index=0
    @text=[[]]
    @lines=0
    loop do
      t += 1
      if t == 4096
        Graphics.update
        t = 0
        end
      if text[i..i] == "\n"
    @lines += 1
    line=line+1
    index=0
    @text[line] = []
  else
    if text[i..i] != "\004"
          if utf8(text[i..i + 1]) != text[i..i + 1] and text[i - 1..i] == text[i - 1..i] and utf8(text[i..i]) == "?"
        @text[line].push(text[i..i + 1])
        i += 1
        else
@text[line].push(text[i..i])
end
else
  if text[i..i+5] == "\004LINE\004"
        @lines += 1
    line=lineline+1
    index=0
    @text[line] = []
    i += 5
    end
end
  end
  break if i >= text.size - 1
  i += 1
      end
end
def findword(direction=1)
f=0
ch=0
for i in 0..@text[@line].size
  if @text[@line][i-1]==" " or (i == 0 and direction == -1 and @index > 0) or (i == @text[@line].size and i!=@index and direction == 1)
    if i < @index and direction == -1
      f=i
ch+=1
      elsif i > @index and direction == 1
ch+=1 if f==0
        f = i if f == 0
            end
    end
  end
      l=@line
f = @text[@line].size if f == 0 and direction == 1
if f == 0 and ch == 0 and @line > 0 and direction == -1
  f=@text[@line-1].size
  l=@line-1
elsif f == @text[@line].size and ch==0 and @line<@lines
    f=0
  l=@line+1
end
t=""
for c in @text[l][f..@text[l].size-1]
  if c != " "
  t+=c
else
  break
  end
end
t="\n" if f==@text[l].size
return [f,l,t]
  end
def focus
if @toinit == true
  @toinit = false
  initialize(@header,@type,@text,false,true)
  return
  end
    finalize
    @textstr = "" if @textstr == nil
    if @silent != true        
    play("edit_marker")
            tp = "Edycja"
            if @readonly == true
              tp = "Tekst"
              end
                          textstr = @textstr
if @audiotext!=nil
  tp="Media"
  textstr="\004AUDIO\004#{@audiotext}\004AUDIO\004"+textstr
  end
  if @password == true
  textstr = ""
    end
            speech(dict(@header.to_s) + " ... " + dict(tp) + ": " + textstr.gsub("\r\n"," "))
            end
end    
def espeech(text)
  if @password != true
  speech(text)
else
  play("edit_password_char")
  end
end
def textcopy
  t = []
  for i in 0..@text.size - 1
    t[i] = []
    for j in 0..@text[i].size - 1
      t[i][j] = @text[i][j] if @text[i][j] != nil
      end
    end
    return t
    end
  end
    class Select
attr_accessor :index
attr_accessor :commandoptions    
attr_reader :grayed
attr_reader :selected
def initialize(options,border=true,index=0,header="",quiet=false,multi=false,lr=false,silent=false)
      border=false if $interface_listtype == 1
      index = 0 if index == nil
      index = 0 if index >= options.size
      self.index = index
            @commandoptions = []
                        @hotkeys = {}
            for i in 0..options.size - 1
              if options[i]!=nil
for j in 0..options[i].size-1
  @hotkeys[options[i][j+1..j+1].upcase[0]] = i if options[i][j..j] == "&"
end
            @commandoptions.push(options[i].delete("&")) if options[i] != nil
            end
            end                        
                        @grayed = []
                                    @selected = []
            for i in 0..@commandoptions.size - 1
              @grayed[i] = false
              @selected[i] = false
              end
            @border = border
            @multi = multi
@silent=silent
            header="" if header==nil
            options[index]="" if options[index]==nil
                        @header = header
              focus if quiet == false
              @lr=lr
    end
    def update
      if $focus == true
    focus
    $focus = false
    end
    if $key[0x11]   and $key[0x12] and $key[82]
      for i in 0..@commandoptions.size-1
        @commandoptions[i]=@commandoptions[i].split("").reverse.join if @commandoptions[i].is_a?(String)
        speech("Coś niejasne?")
        end
      end
    oldindex = self.index
      options = @commandoptions
if (Input.trigger?(Input::UP) and @lr==false) or (Input.trigger?(Input::LEFT) and @lr==true)
  @run = true
  self.index -= 1
        while @grayed[self.index] == true
    self.index -= 1
  end
    if self.index < 0
    oldindex = -1 if @border == false
    self.index = 0
    while @grayed[self.index] == true
      self.index += 1
      end
self.index = options.size - 1 if @border == false
  end  
  elsif (Input.trigger?(Input::DOWN) and @lr==false) or (Input.trigger?(Input::RIGHT) and @lr==true)
@run = true
    self.index += 1
    while @grayed[self.index] == true
    self.index += 1
  end
  if self.index >= options.size
    oldindex = -1 if @border == false
    self.index = options.size - 1
    while @grayed[self.index] == true
      self.index -= 1
      end
self.index = 0 if @border == false
  end  
  end
  if $key[0x23] == true
@run = true
        self.index = options.size - 1
      while @grayed[self.index] == true
    self.index -= 1
    end
    end
  if $key[0x24] == true
@run = true
        self.index = 0
      while @grayed[self.index] == true
    self.index += 1
    end
    end
  if $key[0x21] == true and @lr==false
    if self.index > 14
            self.index -= 15
          else
            self.index = 0
            end
            @run = true
      while @grayed[self.index] == true
    self.index -= 1
    end
    end
        if $key[0x22] == true and @lr==false
       if self.index < (options.size - 15)
            self.index += 15
          else
            self.index = options.size-1
            end
            @run = true
            self.index = 0 if @grayed[self.index] == true
      while @grayed[self.index] == true
    self.index += 1
    end
        end
        suc = false
        k=getkeychar
                if k != "" and k != " "
          i=k.upcase[0]
          if @hotkeys[i]==nil
                  @run = true
        for j in self.index + 1..options.size - 1
          if suc == false              
          if (dict(options[j])[0..0].upcase==k.upcase or dict(options[j])[0..1].upcase==k.upcase)
          suc = true
          self.index = j
          while @grayed[self.index] == true
    self.index += 1
    end
  end
  end
        end
                for j in 0..self.index
        options[j]=" " if options[j]==nil
        if suc == false          
        if (dict(options[j])[0..0].upcase==k.upcase or dict(options[j])[0..1].upcase==k.upcase)
          suc = true
          self.index = j
          while @grayed[self.index] == true
    self.index += 1
    end
  end
  end
      end
      if suc == false
      else
      end
    else
      @index = @hotkeys[i]
      $enter = 2
      end
      end
        if enter
      play("list_select") if @silent == false
    end
    self.index = 0 if self.index >= options.size
  if self.index == -1
        while @grayed[self.index] == true
    self.index += 1
  end
  end
if self.index >= @commandoptions.size
      while @grayed[self.index] == true
    self.index -= 1
    end
  end
  if @run == true
  speech_stop
o = dict(options[self.index])
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
  end
o += "...\r\nSkrót: " + ASCII(ss) if ss.is_a?(Integer)
o += "\r\n\r\n(Zaznaczono)" if @selected[self.index] == true
  speech(o)
  play("list_checked") if @selected[self.index] == true
end
    if oldindex != self.index
  self.index = 0 if options.size == 1 or options[self.index] == nil
  play("list_focus") if @silent == false
@run = false
elsif oldindex == self.index and @run == true
    play("border") if @silent == false
    @run = false
  end
  if space and @multi == true
    if @selected[@index] == false
      @selected[@index] = true
      play("list_checked")
      speech("Zaznaczono")
    else
      @selected[@index] = false
      play("list_unchecked")
      speech("Odznaczono")
      end
    end
end
def focus
   play("list_marker") if @lr==false
              while @grayed[self.index] == true
                            self.index += 1
            end
            if self.index > @commandoptions.size - 1
              while @grayed[self.index] == true
              self.index -= 1
              end
              end
            options=@commandoptions
              sp = dict(@header) + ": " if @header!=nil and @header!=""
              sp="" if sp==nil
            if options.size>0
              sp += dict(options[self.index].delete("&"))
ss = false
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
  end
sp += "...\r\nSkrót: " + ASCII(ss) if ss.is_a?(Integer)
end            
sp += dict("Pusta lista") if @commandoptions.size==0
speech(sp)
                end
    def disable_item(id)
  @grayed[id] = true
  options = @commandoptions
  while @grayed[self.index] == true
    self.index += 1
  end
  if self.index >= options.size
    oldindex = -1 if @border == false
    self.index = options.size - 1
    while @grayed[self.index] == true
      self.index -= 1
      end
self.index = 0 if @border == false
  end  
  end
  end
        class Button
        attr_accessor :label
        def initialize(label="")
          @label = label
        end
        def update
          if $focus == true
    focus
    $focus = false
    end
          end
        def focus
          play("button_marker")
          speech(dict(@label) + "... " + dict("Przycisk"))
        end
      end
      class CheckBox
        attr_accessor :label
        attr_accessor :checked
        def initialize(label="",checked=0)
          @label = label
          @checked = checked
        end
        def update
          if $focus == true
    focus
    $focus = false
    end
          if space or enter
            if @checked == 1
              @checked = 0
              speech("Nieoznaczone")
            else
              @checked = 1
              speech("Oznaczone")
              end
            end
          end
        def focus
          play("checkbox_marker")
          text = dict(@label) + " ... "
          if @checked == 0
            text += dict("Nieoznaczone")
          else
            text += dict("Oznaczone")
          end
          text += " "
          text += dict("pole wyboru")
          speech(text)
        end
      end        
      class FilesTree
        attr_accessor :header
                attr_accessor :file
                attr_accessor :cpath
                attr_accessor :cfile
                attr_accessor :exts
                def initialize(header="",path="",hidefiles=false,quiet=false,file=nil,exts=nil)
        @path=path
        @cpath=path
        @file=""
                @hidefiles=hidefiles
        @header=header
        if file!=nil
          @cfile=@file=file
          end
        @exts=exts
          focus if quiet==false
      end
      def update(init=false)
        if $focus
          $focus=false
          speech(@file)
          end
        if @sel == nil or @refresh == true
              if @path == ""
          @disks = []
    @letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    for i in 0..@letters.size - 1
      if FileTest.exist?(@letters[i] + ":")
        @disks.push(@letters[i] + ":")
        end
      end
h=""
h=@header if init==true
      @sel=Select.new(@disks,true,0,h)
@files=@disks
else
  fls=Dir.entries(@cpath)
fls.delete("..")
fls.delete(".")
if @hidefiles == true
  for i in 0..fls.size-1
    fls[i]=nil if File.file?(@path+fls[i])
  end
  fls.delete(nil)
  end
if @exts!=nil
        for i in 0..fls.size-1
          if File.file?(@path+fls[i])
          s=false
                    for e in @exts
     s=true if File.extname(@path+fls[i]).downcase==e.downcase
     end
  fls[i]=nil if s==false
  end
     end
  fls.delete(nil)
      end
  ind=0
ind=fls.find_index(@file)
h=""
h=@header if init==true
@sel=Select.new(fls,true,ind,h,true)
@sel.focus if @refresh != true
@files=filec(fls)
end
@refresh=false
end
@sel.update
@file=@sel.commandoptions[@sel.index]
@file="" if @sel.commandoptions.size==0
if (Input.trigger?(Input::RIGHT) or @go == true) and File.directory?(@cpath+@files[@sel.index])
  @go = false
    s=true
    begin
    Dir.entries(@cpath+@files[@sel.index]) if s == true
  rescue Exception
    s=false
    retry
      end
  if s == true
      @path+=@file+"\\"
      @cpath+=@files[@sel.index]+"\\"
  @sel=nil
  end
    end
if Input.trigger?(Input::LEFT) and @path.size>0
  t=@path.split("\\")
  @file=t.last
  t[t.size-1]=""
@path=t.join("\\")
t=@cpath.split("\\")
    t[t.size-1]=""
@cpath=t.join("\\")
@sel=nil
end
        end
      def path
        return @path
      end
      def path=(pt)
        @path=pt
        @cpath=pt
        @sel=nil
        end
        def go
          @go = true
          update
          end
        def refresh
          @refresh=true
          end
          def selected(c=false)
          r=""
          if c == false
            r = @path + @file
          else
            r = @cpath + @files[@sel.index]
          end
          return r
          end
          def focus
          if @sel == nil        
          loop_update
            update(true)
          else
                    hin=""
          hin=dict(@header)+": \r\n" if @header!=""
                  hin += @file
        speech(hin)
        end
        end
        end
      def selector(options,header="",index=0,escapeindex=nil,type=0,border=true)
        dis=[]
        for i in 0..options.size-1
          if options[i]==nil
            dis.push(i)
            options[i]=""
            end
          end
lsel=""
        if type == 0
        lsel = Select.new(options,border,index,header)
      else
        lsel = menulr(options,border,index,header)
      end
      for d in dis
        lsel.disable_item(d)
        end
        loop do
          loop_update
          lsel.update
          if enter
            return lsel.index
            break
          end
          if escape and escapeindex!=nil
            return escapeindex
            break
            end
          end
        end
     def menulr(options,border=true,index=0,header="",quiet=false)
       return Select.new(options,border,index,header,quiet,false,true)
     end
     def getfile(header="",path="",save=false,file=nil)
       dialog_open
       loop_update
       ft=FilesTree.new(header,path,save,true)
       ft.file=file if file!=nil
                     ft.focus
       loop do
         loop_update
         ft.update
         if escape
           dialog_close
           return ""
           break
         end
         if enter
           dialog_close
           f=ft.path+ft.file
           f.chop! if f[f.size-1]=="\\"
           if save == false and File.file?(f)
             return f
           break
         end
         if save == true
           if File.directory?(f)
                          return f
             break
           else
             d=f.split("\\")
             d[d.size-1]=""
             f=d.join("\\")
             return f
             break
             end
           end
         end
         if space
           pt=ft.path
           ftp=input_text("Podaj ścieżkę","ACCEPTESCAPE",ft.path)
           ft.path=ftp if ftp!="\004ESCAPE\004" and File.directory?(ftp)
           end
         end
       end  
     end
     end
#Copyright (C) 2014-2016 Dawid Pieper