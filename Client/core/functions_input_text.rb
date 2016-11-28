#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

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
  attr_accessor :text_str
  attr_accessor :edit_clp
attr_accessor :readonly
attr_accessor :acceptescape
attr_accessor :accepttab
attr_accessor :multilines
attr_accessor :word
def initialize(header="",type="NORMALTEXT",text="",quiet=false,init=false)
  @header = header
  @type = type
  @text = text
  @quiet = quiet
    if init == false
        @toinit = true
                return
    end
@repeat = nil
    @undo = []
@toundo = [[],0,0]
    header = dict(header)
  @word = ""
  @readonly = false
  @acceptescape = false
  @accepttab = false
@multilines = false
  #*
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
                                                      type.gsub("password") do
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
    i = 0
        text.delete!("\r")
    text.sub!("\004LINE\004","\n")
    i = 0
    t = 0
    loop do
      t += 1
      if t == 512
        Graphics.update
        t = 0
        end
      if text[i..i] == "\n"
    @lines += 1
    setline(@line+1)
    setindex(0)
    @text[@line] = []
  else
    if text[i..i] != "\004"
          if utf8(text[i..i + 1]) != text[i..i + 1] and text[i - 1..i] == text[i - 1..i] and utf8(text[i..i]) == "?"
        @text[@line].push(text[i..i + 1])
        i += 1
        else
@text[@line].push(text[i..i])
end
else
  if text[i..i+5] == "\004LINE\004"
        @lines += 1
    setline(@line+1)
    setindex(0)
    @text[@line] = []
    i += 5
    end
end
  end
  break if i >= text.size - 1
  i += 1
      end
    setline(0)
    setindex(0)
    @eline = @line
    @eindex = @index
  end
  @text_str = text
  focus if quiet != true
end
def update
    if @toinit == true
  @toinit = false
  initialize(@header,@type,@text,false,true)
    end
    finalize    
    s = false
      if @undo[0] != nil
  s = true if textcopy != @toundo[0]
  else
  s = true
end
    if s == true
                      @undo.insert(0,@toundo)
                            @toundo = [textcopy,@index,@line]
      s = false    
    end
    if @undo.size > 100
    @undo.reverse!
    @undo.delete_at(0)
    @undo.reverse!
    end
                  if $focus == true
    focus
    $focus = false
    end
    if $key[0x10] == false
  curupdate
else
  chkcurupdate
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
    if $key[0x11] == true and $key[90] == true and $key[0x12] == false
      @text = @undo[0][0]
      @index = @undo[0][1]
      @line = @undo[0][2]
      @eindex = @index
      @eline = @line
@repeat = @toundo
      @undo.delete_at(0)
      @toundo = [textcopy,@index,@line]
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
      if $key[0x11] == true and $key[84] == true
      gc = getcheck
      speech(translate("auto",$language,gc))
    end
    if $key[0x11] == true and $key[65] == true and $key[0x12] == false
      setindex(0)
      setline(0)
      @eline = @lines
      @eindex = @text[@eline].size - 1
      chkcurupdate
      end
  if $key[0x11] == true or @multilines == false
  rtmp = true
else
  rtmp = false
  end
  if $key[0xD] and rtmp == true and @readonly != true
  play("list_select")
      @text_str = ""
          for i in 0..@lines
      @text[i] = "" if @text[i] == nil
for j in 0..@text[i].size - 1
  @text[i][j] = "" if @text[i][j] == nil
      @text_str += @text[i][j][0..@text[i][j].size - 1]
end
@text_str += "\004LINE\004"
end
@text_str.gsub!("\004LINE\004","") if @multilines == false
@text_str += "\005" if @multilines == true
    @text_str = @text_str
    return(@text_str)
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
  if $key[0x10] == false and $key[0x11] == false and $key[0x12] == false and $key[0x14] == false
  if $key[0x20]
    if @index >= 100
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
    #*
  end
  if $key[0x30]
    @text = @text = input_text_multilines_push(@text,@line,@index,"0")
    #*
  end
  if $key[0x31]
    @text = @text = input_text_multilines_push(@text,@line,@index,"1")
    #*
  end
    if $key[0x32]
    @text = @text = input_text_multilines_push(@text,@line,@index,"2")
    #*
  end
    if $key[0x33]
    @text = @text = input_text_multilines_push(@text,@line,@index,"3")
    #*
  end
    if $key[0x34]
    @text = @text = input_text_multilines_push(@text,@line,@index,"4")
    #*
  end
    if $key[0x35]
    @text = @text = input_text_multilines_push(@text,@line,@index,"5")
    #*
  end
    if $key[0x36]
    @text = @text = input_text_multilines_push(@text,@line,@index,"6")
    #*
  end
    if $key[0x37]
    @text = @text = input_text_multilines_push(@text,@line,@index,"7")
    #*
  end
    if $key[0x38]
    @text = @text = input_text_multilines_push(@text,@line,@index,"8")
    #*
  end
    if $key[0x39]
    @text = @text = input_text_multilines_push(@text,@line,@index,"9")
    #*
  end
  if $key[0x41]
    @text = @text = input_text_multilines_push(@text,@line,@index,"a")
   #*
  end
    if $key[0x42]
    @text = @text = input_text_multilines_push(@text,@line,@index,"b")
    #*
  end
    if $key[0x43]
    @text = @text = input_text_multilines_push(@text,@line,@index,"c")
    #*
    end
    if $key[0x44]
    @text = @text = input_text_multilines_push(@text,@line,@index,"d")
    #*
  end
    if $key[0x45]
    @text = @text = input_text_multilines_push(@text,@line,@index,"e")
    #*
  end
    if $key[0x46]
    @text = @text = input_text_multilines_push(@text,@line,@index,"f")
    #*
  end
    if $key[0x47]
    @text = @text = input_text_multilines_push(@text,@line,@index,"g")
    #*
  end
    if $key[0x48]
    @text = @text = input_text_multilines_push(@text,@line,@index,"h")
    #*
  end
    if $key[0x49]
    @text = @text = input_text_multilines_push(@text,@line,@index,"i")
        #*
  end
    if $key[0x4A]
    @text = @text = input_text_multilines_push(@text,@line,@index,"j")
    #*
  end
    if $key[0x4B]
    @text = @text = input_text_multilines_push(@text,@line,@index,"k")
    #*
  end
    if $key[0x4C]
    @text = @text = input_text_multilines_push(@text,@line,@index,"l")
    #*
  end
    if $key[0x4D]
    @text = @text = input_text_multilines_push(@text,@line,@index,"m")
    #*
  end
    if $key[0x4E]
    @text = @text = input_text_multilines_push(@text,@line,@index,"n")
    #*
  end
    if $key[0x4F]
    @text = @text = input_text_multilines_push(@text,@line,@index,"o")
    #*
  end
    if $key[0x50]
    @text = @text = input_text_multilines_push(@text,@line,@index,"p")
    #*
  end
    if $key[0x51]
    @text = @text = input_text_multilines_push(@text,@line,@index,"q")
    #*
  end
    if $key[0x52]
    @text = @text = input_text_multilines_push(@text,@line,@index,"r")
    #*
  end
    if $key[0x53]
    @text = @text = input_text_multilines_push(@text,@line,@index,"s")
    #*
  end
    if $key[0x54]
    @text = @text = input_text_multilines_push(@text,@line,@index,"t")
    #*
  end
    if $key[0x55]
    @text = @text = input_text_multilines_push(@text,@line,@index,"u")
    #*
  end
    if $key[0x56]
    @text = @text = input_text_multilines_push(@text,@line,@index,"v")
    #*
  end
    if $key[0x57]
    @text = @text = input_text_multilines_push(@text,@line,@index,"w")
    #*
  end
    if $key[0x58]
    @text = @text = input_text_multilines_push(@text,@line,@index,"x")
    #*
  end
    if $key[0x59]
    @text = @text = input_text_multilines_push(@text,@line,@index,"y")
    #*
  end
    if $key[0x5A]
    @text = @text = input_text_multilines_push(@text,@line,@index,"z")
    #*
  end
  if $key[0xBA]
    @text = @text = input_text_multilines_push(@text,@line,@index,";")
    #*
    end
  if $key[0xBB]
    @text = @text = input_text_multilines_push(@text,@line,@index,"=")
    #*
    end
    if $key[0xBC]
    @text = @text = input_text_multilines_push(@text,@line,@index,",")
    #*
    end
  if $key[0xBD]
    @text = @text = input_text_multilines_push(@text,@line,@index,"-")
    #*
    end
  if $key[0xBE]
    @text = @text = input_text_multilines_push(@text,@line,@index,".")
    #*
    end
  if $key[0xBF]
    @text = @text = input_text_multilines_push(@text,@line,@index,"/")
    #*
    end
  if $key[0xC0]
    @text = @text = input_text_multilines_push(@text,@line,@index,"`")
    #*
    end
  if $key[0xDB]
    @text = @text = input_text_multilines_push(@text,@line,@index,"[")
    #*
    end
  if $key[0xDC]
    @text = @text = input_text_multilines_push(@text,@line,@index,"\\")
    #*
  end
    if $key[0xDD]
    @text = @text = input_text_multilines_push(@text,@line,@index,"]")
    #*
    end
  if $key[0xDE]
    @text = @text = input_text_multilines_push(@text,@line,@index,"'")
    #*
  end
  
elsif ($key[0x10] == true or $key[0x14] == true) and $key[0x11] == false and $key[0x12] == false
    if $key[0x20]
    @text = @text = input_text_multilines_push(@text,@line,@index," ")
    #*
  end
  if $key[0x30]
    @text = @text = input_text_multilines_push(@text,@line,@index,")")
    #*
  end
  if $key[0x31]
    @text = @text = input_text_multilines_push(@text,@line,@index,"!")
    #*
  end
    if $key[0x32]
    @text = @text = input_text_multilines_push(@text,@line,@index,"@")
    #*
  end
    if $key[0x33]
    @text = @text = input_text_multilines_push(@text,@line,@index,"#")
    #*
  end
    if $key[0x34]
    @text = @text = input_text_multilines_push(@text,@line,@index,"$")
    #*
  end
    if $key[0x35]
    @text = @text = input_text_multilines_push(@text,@line,@index,"%")
    #*
  end
    if $key[0x36]
    @text = @text = input_text_multilines_push(@text,@line,@index,"^")
    #*
  end
    if $key[0x37]
    @text = @text = input_text_multilines_push(@text,@line,@index,"\&")
    #*
  end
    if $key[0x38]
    @text = @text = input_text_multilines_push(@text,@line,@index,"*")
    #*
  end
    if $key[0x39]
    @text = @text = input_text_multilines_push(@text,@line,@index,"(")
    #*
  end
  if $key[0x41]
    @text = @text = input_text_multilines_push(@text,@line,@index,"A")
   #*
  end
    if $key[0x42]
    @text = @text = input_text_multilines_push(@text,@line,@index,"B")
    #*
  end
    if $key[0x43]
    @text = @text = input_text_multilines_push(@text,@line,@index,"C")
    #*
    end
    if $key[0x44]
    @text = @text = input_text_multilines_push(@text,@line,@index,"D")
    #*
  end
    if $key[0x45]
    @text = @text = input_text_multilines_push(@text,@line,@index,"E")
    #*
  end
    if $key[0x46]
    @text = @text = input_text_multilines_push(@text,@line,@index,"F")
    #*
  end
    if $key[0x47]
    @text = @text = input_text_multilines_push(@text,@line,@index,"G")
    #*
  end
    if $key[0x48]
    @text = @text = input_text_multilines_push(@text,@line,@index,"H")
    #*
  end
    if $key[0x49]
    @text = @text = input_text_multilines_push(@text,@line,@index,"I")
        #*
  end
    if $key[0x4A]
    @text = @text = input_text_multilines_push(@text,@line,@index,"J")
    #*
  end
    if $key[0x4B]
    @text = @text = input_text_multilines_push(@text,@line,@index,"K")
    #*
  end
    if $key[0x4C]
    @text = @text = input_text_multilines_push(@text,@line,@index,"L")
    #*
  end
    if $key[0x4D]
    @text = @text = input_text_multilines_push(@text,@line,@index,"M")
    #*
  end
    if $key[0x4E]
    @text = @text = input_text_multilines_push(@text,@line,@index,"N")
    #*
  end
    if $key[0x4F]
    @text = @text = input_text_multilines_push(@text,@line,@index,"O")
    #*
  end
    if $key[0x50]
    @text = @text = input_text_multilines_push(@text,@line,@index,"P")
    #*
  end
    if $key[0x51]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Q")
    #*
  end
    if $key[0x52]
    @text = @text = input_text_multilines_push(@text,@line,@index,"R")
    #*
  end
    if $key[0x53]
    @text = @text = input_text_multilines_push(@text,@line,@index,"S")
    #*
  end
    if $key[0x54]
    @text = @text = input_text_multilines_push(@text,@line,@index,"T")
    #*
  end
    if $key[0x55]
    @text = @text = input_text_multilines_push(@text,@line,@index,"U")
    #*
  end
    if $key[0x56]
    @text = @text = input_text_multilines_push(@text,@line,@index,"V")
    #*
  end
    if $key[0x57]
    @text = @text = input_text_multilines_push(@text,@line,@index,"W")
    #*
  end
    if $key[0x58]
    @text = @text = input_text_multilines_push(@text,@line,@index,"X")
    #*
  end
    if $key[0x59]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Y")
    #*
  end
    if $key[0x5A]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Z")
    #*
  end
  if $key[0xBA]
    @text = @text = input_text_multilines_push(@text,@line,@index,":")
    #*
    end
  if $key[0xBB]
    @text = @text = input_text_multilines_push(@text,@line,@index,"+")
    #*
    end
    if $key[0xBC]
    @text = @text = input_text_multilines_push(@text,@line,@index,"<")
    #*
    end
  if $key[0xBD]
    @text = @text = input_text_multilines_push(@text,@line,@index,"_")
    #*
    end
  if $key[0xBE]
    @text = @text = input_text_multilines_push(@text,@line,@index,">")
    #*
    end
  if $key[0xBF]
    @text = @text = input_text_multilines_push(@text,@line,@index,"?")
    #*
    end
  if $key[0xC0]
    @text = @text = input_text_multilines_push(@text,@line,@index,"~`")
    #*
    end
  if $key[0xDB]
    @text = @text = input_text_multilines_push(@text,@line,@index,"{")
    #*
    end
  if $key[0xDC]
    @text = @text = input_text_multilines_push(@text,@line,@index,"\|")
    #*
  end
    if $key[0xDD]
    @text = @text = input_text_multilines_push(@text,@line,@index,"}")
    #*
    end
  if $key[0xDE]
    @text = @text = input_text_multilines_push(@text,@line,@index,"\"")
    #*
  end
  end
if $key[0x11] == true and $key[0x12] == true
    if $key[0x10] == false and $key[0x14] == false
      if $key[0x41]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ą")
    #*
  end
    if $key[0x43]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ć")
    #*
  end
    if $key[0x45]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ę")
    #*
  end
    if $key[0x4C]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ł")
    #*
  end
    if $key[0x4E]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ń")
    #*
  end
    if $key[0x4F]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ó")
    #*
  end
    if $key[0x53]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ś")
    #*
  end
    if $key[0x58]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ź")
    #*
  end
    if $key[0x5A]
    @text = @text = input_text_multilines_push(@text,@line,@index,"ż")
    #*
  end
elsif ($key[0x10] == true or $key[0x14] == true)
    if $key[0x41]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ą")
    #*
  end
    if $key[0x43]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ć")
    #*
  end
    if $key[0x45]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ę")
    #*
  end
    if $key[0x4C]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ł")
    #*
  end
    if $key[0x4E]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ń")
    #*
  end
    if $key[0x4F]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ó")
    #*
  end
    if $key[0x53]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ś")
    #*
  end
    if $key[0x58]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ź")
    #*
  end
    if $key[0x5A]
    @text = @text = input_text_multilines_push(@text,@line,@index,"Ż")
    #*
end
end
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
    end
    if $key[0x2E]
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
end
    #*
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
setindex(@index + 1,false)
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
  #*
return(@text)
else
  play("border")
  return(@text)
end
end
def finalize
  if @readonly != true
@text_str = ""
for i in 0..@lines
for j in 0..@text[i].size - 1
@text_str += @text[i][j].to_s
end
@text_str += "\004LINE\004"
end
@text_str.gsub!("\004LINE\004","") if @multilines == false
@text_o = @text_str
Audio.bgs_stop
  if @acceptescape == true and @text[0][0] == "\004"
    return("\004ESCAPE\004")
  end
    return(@text_str)
else
  return
  end
end
def setindex(setter,wordreset=true)
  @word = "" if wordreset == true
    Audio.bgs_stop
  @index = setter
  @eindex = setter
  @eline = @line
end
def setline(setter)
  @word = ""
  @line = setter
  @eline = setter
  end
def curupdate
    if Input.trigger?(Input::LEFT)
    if $key[0x11] == false
      if @index > 0
      setindex(@index - 1)
      espeech(@text[@line][@index])
      #*
else
if @line > 0
@line -= 1
setindex(@text[@line].size)
espeech("\n")
else
  play("border")
end
end
else
  if @index > 0
    suc = false
    b=""
    setindex(@index - 1) if @text[@line][@index - 1] == " "
    for i in 1..@index - 1
      b += @text[@line][i] if @text[@line][i] != nil
      if @text[@line][i] == " "
        setindex(i)
        suc = true
        b=""
        end
      end
      if suc == true
        espeech(b)
      else
        if @line > 0
          setline(@line-1)
          setindex(@text[@line].size)
          espeech("\n")
          else
        setindex(0)
        play("border")
        espeech(@text[@line][0])
        end
        end
    end
  end
  end
  if Input.trigger?(Input::RIGHT)
    if $key[0x11] == false
      if @index < @text[@line].size - 1
      setindex(@index + 1)
      espeech(@text[@line][@index])
      #*
    elsif @index == @text[@line].size - 1
      setindex(@index + 1)
            espeech("\n")
            play("border") if @line == @lines
      #*
elsif @index > @text[@line].size - 1
if @lines > @line
setline(@line + 1)
setindex(0)
@text[@line] = [] if @text[@line] == nil
espeech(@text[@line][0].to_s)
end
end
else
  b=""
  loop do
  suc = false
  for i in @index..@text[@line].size - 1
    b += @text[@line][i]
    setindex(i)
    if @text[@line][i] == " " or i >= @text[@line].size - 1
      suc = true
      break
      end
    end
    if suc == true
    espeech(b)
    setindex(@index + 1)
    break
  else
    if @line < @lines
    setline(@line+1)
    setindex(0)
  else
    setindex(@text[@line].size)
    speech("\n")
    break
    end
        end
  end
  end    
  end
    if $key[0x23] and $key[0x11] == false
      setindex(@text[@line].size)
      espeech("\n")
    end
    if $key[0x24] and $key[0x11] == false
      espeech(@text[@line][0])
      setindex(0)
      end
  if $key[0x23] and $key[0x11] == true
setline(@lines)
    setindex(@text[@line].size)
    tmp = ""
      for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
    end
    if $key[0x24] and $key[0x11] == true
            setline(0)
      setindex(0)
tmp = ""
for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
      end
      if $key[0x21] == true
        line = @line - 15
        line = 0 if line < 0
        setline(line)
        tmp = ""
for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
end
if $key[0x22] == true
  line = @line+15
  line = @lines if line > @lines
  setline(line)
  tmp = ""
for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
  end
      @text[@line] = [] if @text[@line] == nil
if ($key[0x0D] and $key[0x11] == false and @readonly == true) and @multilines == true
  link = ""
  lso = 0
  c = @text[@line]
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
end
  if Input.trigger?(Input::DOWN)
if @lines > @line
    buf = ""
    @text[@line + 1] = [] if @text[@line + 1] == nil
for i in 0..@text[@line + 1].size - 1
buf += @text[@line + 1][i].to_s
end
      espeech(buf)
setline(@line + 1)
if @text[@line].size >= @text[@line - 1].size - 1
else
setindex(@text[@line].size)
end
else
  play("border")
      buf = ""
for i in 0..@text[@line].size - 1
buf += @text[@line][i].to_s
end
      espeech(buf)
      end
  end
  if Input.trigger?(Input::UP)
if @line > 0
setline(@line - 1)
buf = ""
for i in 0..@text[@line].size - 1
  buf += @text[@line][i].to_s
  end
espeech(buf)
if @text[@line].size > @text[@line + 1].size - 1
else
setindex(@text[@line].size)
end
else
  play("border")
  buf = ""
for i in 0..@text[@line].size - 1
  buf += @text[@line][i].to_s
  end
espeech(buf)
end
end
end
def chksetindex(setter)
  @word = ""
@eindex = setter
end
def chkcurupdate
 if Input.trigger?(Input::LEFT)
    if $key[0x11] == false
      if @eindex > 0
      chksetindex(@eindex - 1)
      espeech(@text[@eline][@eindex])
      #*
else
if @eline > 0
@eline -= 1
chksetindex(@text[@eline].size)
espeech("\n")
else
  play("border")
end
end
else
  if @eindex > 0
    suc = false
    b=""
    chksetindex(@eindex - 1) if @text[@eline][@eindex - 1] == " "
    for i in 1..@eindex - 1
      b += @text[@eline][i] if @text[@eline][i] != nil
      if @text[@eline][i] == " "
        chksetindex(i)
        suc = true
        b=""
        end
      end
      if suc == true
        espeech(b)
      else
        chksetindex(0)
        play("border")
        espeech(@text[@eline][0])
        end
  else
if @eline > 0
    @eline -= 1
    chksetindex(@text[@eline].size)
    end
    espeech("\n")
  end
  end
  end
  if Input.trigger?(Input::RIGHT)
   if $key[0x11] == false
      if @eindex < @text[@eline].size - 1
      chksetindex(@eindex + 1)
      espeech(@text[@eline][@eindex])
      #*
    elsif @eindex == @text[@eline].size - 1
      chksetindex(@eindex + 1)
            espeech("\n")
            play("border") if @eline == @lines
      #*
elsif @eindex > @text[@eline].size - 1
if @lines > @eline
@eline += 1
chksetindex(0)
@text[@eline] = [] if @text[@eline] == nil
espeech(@text[@eline][0].to_s)
end
end
else
  b=""
  for i in @eindex..@text[@eline].size - 1
    b += @text[@eline][i]
    chksetindex(i)
    if @text[@eline][i] == " "
      break
      end
    end
    espeech(b)
    chksetindex(@eindex + 1)
  end
      end
    if $key[0x23] and $key[0x11] == false
      chksetindex(@text[@eline].size)
      espeech("\n")
    end
    if $key[0x24] and $key[0x11] == false
      espeech(@text[@eline][0])
      chksetindex(0)
      end
      if $key[0x23] and $key[0x11] == true
@eline = @lines
    chksetindex(@text[@line].size)
    tmp = ""
      for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
    end
    if $key[0x24] and $key[0x11] == true
            @eline = 0
      chksetindex(0)
tmp = ""
for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
      end
      if $key[0x21] == true
        line = @line - 15
        line = 0 if line < 0
        @eline = line
        tmp = ""
for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
end
if $key[0x22] == true
  line = @line+15
  line = @lines if line > @lines
  @eline = line
  tmp = ""
for i in 0..@text[@line].size-1
  tmp += @text[@line][i]
end
espeech(tmp)
  end
      if ($key[0x0D] and $key[0x11] == false and @readonly != true) and @multilines == true
                @text[@eline] = [] if @text[@eline] == nil
        if @eindex >= @text[@eline].size - 1
@lines = 0 if @lines == nil
@lines += 1
@eline += 1
@text.insert(@eline,[])
@text[@eline] = []
chksetindex(0)
else
  @lines = 0 if @lines == nil
@lines += 1
@lines += 1
@eline += 1
@text.insert(@eline,[])
text = @text[@eline - 1][@eindex..@text[@eline - 1].size - 1]
text = [] if text == nil
  @text[@eline] = text
for i in 0..@text[@eline - 1].size - @eindex - 1
 @text[@eline - 1].delete_at(@text[@eline - 1].size - 1)
  end
chksetindex(0)
end
espeech("\n")
end
  if Input.trigger?(Input::DOWN)
if @lines > @eline
    buf = ""
    @text[@eline + 1] = [] if @text[@eline + 1] == nil
for i in 0..@text[@eline + 1].size - 1
buf += @text[@eline + 1][i].to_s
end
      espeech(buf)
@eline += 1
if @text[@eline].size >= @text[@eline - 1].size - 1
else
chksetindex(@text[@eline].size)
end
else
  play("border")
      buf = ""
for i in 0..@text[@eline].size - 1
buf += @text[@eline][i].to_s
end
      espeech(buf)
      end
  end
  if Input.trigger?(Input::UP)
if @eline > 0
@eline -= 1
buf = ""
for i in 0..@text[@eline].size - 1
  buf += @text[@eline][i].to_s
  end
espeech(buf)
if @text[@eline].size > @text[@eline + 1].size - 1
else
chksetindex(@text[@eline].size)
end
else
  play("border")
  buf = ""
for i in 0..@text[@eline].size - 1
  buf += @text[@eline][i].to_s
  end
espeech(buf)
end
end
if @index != @eindex or @line != @eline
play("edit_checked")
elsif @index == @eindex and @line == @eline
  Audio.bgs_stop
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
    @eindex = 0
    @eline = 0
    Audio.bgs_stop
end
def settext(text)
  if @toinit == true
  @toinit = false
    initialize(@header,@type,text,false,true)
    end
  @word = ""
  setindex(0)
  @line = 0
  chksetindex(0)
  @eline = 0
  @text = []
  @lines = 0
  @text[@line] = []
  @ln = 0
  for i in 0..text.size - 1
    if text[i..i] != "\n"
    @text[@ln].push(text[i..i])
  else
    @lines += 1
    @ln += 1
    @text[@ln] = []
    end
    end
  end
  def focus
if @toinit == true
  @toinit = false
  initialize(@header,@type,@text,false,true)
  return
  end
    finalize
    @text_str = "" if @text_str == nil
            play("edit_marker")
            tp = "Edycja"
            if @readonly == true
              tp = "Tekst"
            end
text_str = @text_str
if @password == true
  text_str = ""
    end
            speech(dict(@header.to_s) + " ... " + dict(tp) + ": " + text_str.gsub("\r\n"," "))
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
#Copyright (C) 2014-2016 Dawid Pieper