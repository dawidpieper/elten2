#Elten Code
#Copyright (C) 2014-2018 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  # Controls and forms related class
  module Controls
    # A form class  
    class Form
      # @return   [Numeric] a form index
      attr_accessor :index
      # @return [Array] an array of form fields
        attr_accessor :fields
        # Creates a form
        #
        # @param fields [Array] an array of form fields
        # @param index [Numeric] the initial index
        def initialize(fields,index=0,silent=false)
          @fields = fields
          @index = index
          @silent=silent
          if @fields[@index].is_a?(Array)
            if @fields[@index][0] == 0
              @fields[@index] = Edit.new(@fields[@index][1],@fields[@index][2],@fields[@index][3],false,@fields[@index][4])
            end
            end
          @fields[@index].focus
          play("form_marker") if @silent==false
          loop_update
        end
        
        # Updates a form
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
                def focus
                  @fields[@index].focus if @fields[@index]!=nil
                  end
                  end
                
                # Reads a text from user and returns it
                #
                # @param header [String] a window caption
                # @param type [String] the window type
                #  @see Edit
                # @param text [String] an initial text
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
    if ro == true and (escape or alt or enter)
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

# An editbox class
  class OEdit
    # @return [Array] an array consited of lines and, subarrays, characters
  attr_accessor :text
  # @return [Numeric] an index
  attr_accessor :index
  # @return [Numeric] current line
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
# Creates a editbox
#
# @param header [String] a window caption
# @param type [String] a one of more (| terminated) flags:
#  MULTILINE
#  PASSWORD
# READONLY
# @param text [String] an initial text
# @param quiet [Boolean] don't read a caption at initialization time
# @param init [Boolean] initialize the editbox at creation
def initialize(header="",type="NORMALTEXT",text="",quiet=false,init=false)
  @origtext=text  
  @text=text.to_s.gsub(/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/) do
          $dialogvoice.volume=0 if $dialogvoice!=nil
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
@accepttab = true
  "accepttab"
    end
  type.gsub("ACCEPTTAB") do
  @accepttab = true
    "ACCEPTTAB"
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
      @text.push(l.split(""))
    end
    @lines=@text.size-1
    setline(0)
    setindex(0)
  end
    @textstr = text
  focus if quiet != true
end

# Updates an editbox
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
        begin
          suc=true if @undothread.status==false
          rescue Exception
          suc=false
          end
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
  if @audiotext==nil or $speechaudio==nil
  t=""
  ind = @index
  for i in @line..@lines
    ind = 0 if i>@line
t+=@text[i][ind..@text[i].size-1].to_s
    t+="\r\n"
  end
  t="\004AUDIO\004#{@audiotext}\004AUDIO\004"+t if @audiotext!=nil
      espeech(t)
    elsif $speechaudio!=nil
      v=0
                                     if $speechaudio != nil
           if $speechaudio!=nil
                         $speechaudio.position+=5
    end
    end
          end
          end
if $speechaudio!=nil
  if $key[0x10] == true
    if Input.repeat?(Input::LEFT)
      $speechaudio.position-=5
      delay(0.1)
    elsif Input.repeat?(Input::RIGHT)
      $speechaudio.position+=5
      delay(0.1)
    end
    end
  end
          if escape
  Audio.bgs_stop
  end
if $key[0x11] == true and $key[67] == true and $key[0x12] == false
  gc = getcheck
    Win32API.new($eltenlib,"CopyToClipboard",'pp','').call(utf8(gc.to_s),utf8(gc.to_s).size + 1)
    speech(_("EAPI_Form:info_copied"))
  end
  if $key[0x11] == true and $key[88] == true and $key[0x12] == false
  gc = getcheck
    Win32API.new($eltenlib,"CopyToClipboard",'pp','').call(utf8(gc.to_s),utf8(gc.to_s).size + 1)
    delcheck
    speech(_("EAPI_Form:info_cut"))
  end
  if $key[0x11] == true and $key[86] == true and $key[0x12] == false
    txt = futf8(Win32API.new($eltenlib,"PasteFromClipboard",'','p').call)
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
      speech(_("EAPI_Form:info_pasted"))
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
      speech(_("EAPI_Form:info_undone"))
      end
    if $key[0x11] == true and $key[89] == true
      if @repeat != nil
        @text = @repeat[0]
        @index = @repeat[1]
        @line = @repeat[2]
        @repeat = nil
        speech(_("EAPI_Form:info_repeated"))
        end
      end
if $key[0x11] == true and $key[82] == true and $key[0x12]==false and FileTest.exists?("temp/savedtext.tmp") and @readonly!=true
  settext(read("temp/savedtext.tmp"))
  speech(_("EAPI_Form:info_loaded"))
  end
      if $key[0x11] == true and $key[83] == true and $key[0x12]==false
        if @audiotext==nil or (@flags&Flags::ReadOnly)==0
        writefile("temp\\savedtext.tmp",text_str)
        speech(_("General:info_saved"))
      else
        dialog_open
        form=Form.new([FilesTree.new(_("EAPI_Form:head_dst"),getdirectory(40)+"\\",true,true,"Music"),Edit.new(_("EAPI_Form:type_Filename"),"",@header.delete("\r\n").delete("\"").delete("/").delete("\\")+".mp3"),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
        loop do
          loop_update
          form.update
          if escape or ((space or enter) and form.index==3)
            loop_update
            break
            end
          if (space or enter) and form.index==2
            dest=form.fields[0].selected+"\\"+form.fields[1].text_str
            sou=@audiotext
            sou.sub!("/",$url) if sou[0..0]=="/"
                        downloadfile(sou,dest,"Pobieranie...","Pobieranie zakończone")
                                    break
            end
          end
          dialog_close
        end
        end
      if $key[0x11] == true and $key[80] == true
              gc = getcheck
                            gc=text_str.gsub("\004LINE\004"," ") if gc.size<=2 or gc==nil or gc=="\004LINE\004"
                                                        speechtofile("",gc)
                                                        loop_update
                            end
        if $key[0x11] == true and $key[84] == true and $key[12]==false
              gc = getcheck
                            gc=text_str.gsub("\004LINE\004"," ") if gc.size<=2 or gc==nil or gc=="\004LINE\004"
                                                        if $key[0x10]==false
              speech(translatetext(0,$language,gc),1,false)
            else
              translator(gc)
              end
    end
if $key[0x11] == true and $key[0x46] == true
@lastsearch="" if @lastsearch==nil
search=input_text(_("EAPI_Form:type_searchphrase"),"ACCEPTESCAPE",@lastsearch)
loop_update
if search!="\004ESCAPE\004"
  @lastsearch=search
cr=[]
for i in @line..@lines
  cr.push(i)
end
for i in 0..@line
  cr.push(i)
  end
  f=true
  found=false
  for i in cr
l=@text[i].join
res=l.upcase.index(search.upcase)
if res != nil
      ind=0
  b=""
   while b.size<res
    b+=@text[i][ind]
    ind+=1
  end
if f==false or ind>@index
  found=true
  setline(i)
  setindex(ind)
  espeech(@text[@line][ind..@text[@line].size-1].join)
  break
  end
  end
    f=false
  end  
  speech(_("EAPI_Form:info_nomatch"))   if found==false
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
                if $speechaudiopaused!=true
          $speechaudio.pause
          $speechaudiopaused=true
        else
          $speechaudio.play
          $speechaudiopaused=false
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
  if @toinit == true
  @toinit = false
  initialize(@header,@type,@text,true,true)
    end
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
        
        # Gets a text
        #
        # @return [String] a text written in the editbox
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
    return if $speechaudio!=nil
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
  return if $speechaudio!=nil
    @line = setter
  @eline = setter
else
  @eline=setter
  end
end


def curupdate(chk=false)
  return if $speechaudio!=nil and chk==true
    if Input.repeat?(Input::LEFT)
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
  if Input.repeat?(Input::RIGHT)
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
    run("explorer \"#{link}\"")
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
  if Input.repeat?(Input::DOWN)
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
  if Input.repeat?(Input::UP)
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
            tp = _("EAPI_Form:fld_edit")
            if @readonly == true
              tp = _("EAPI_Form:fld_text")
              end
                          textstr = @textstr
if @audiotext!=nil
  tp=_("EAPI_Form:fld_media")
  textstr="\004AUDIO\004#{@audiotext}\004AUDIO\004"+textstr
  end
  if @password == true
  textstr = ""
    end
            speech(@header.to_s + " ... " + tp + ": " + textstr.gsub("\r\n"," "),1,false)
            end
          end    
          
          
def espeech(text)
  if @password != true
  speech(text,1,false)
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
  
  class Edit
    attr_accessor :index
    attr_accessor :text
    attr_accessor :flags
    attr_reader :origtext
    attr_accessor :silent    
    attr_accessor :audiotext
    attr_accessor :check
    def initialize(header="",type="",text="",quiet=false,init=false,silent=false)
      
      @header=header
        @text=text.delete("\r").gsub("\004LINE\004","\n").gsub(/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/) do
          $dialogvoice.volume=0 if $dialogvoice!=nil
          @audiotext=$1
      ""
    end
    @text.gsub!(/\004ATTACH\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004ATTACH\004/,"")
    @text.chop! while @text[@text.size-1..@text.size-1]=="\n"
                @origtext=text
      @index=@check=0
@flags=0
@flags=type if type.is_a?(Integer)
@silent=silent
if type.is_a?(String)
  @flags=@flags|Flags::MultiLine if type.downcase.include?("multiline")
    @flags=@flags|Flags::ReadOnly if type.downcase.include?("readonly")
  @flags=@flags|Flags::Password if type.downcase.include?("password")
  @flags=@flags|Flags::Numbers if type.downcase.include?("numbers")
end
@redo=@undo=[]
focus if quiet==false
    end
    def update
      if $focus==true
        $focus=false
        focus
        end
navupdate
      editupdate
      ctrlupdate
      mediaupdate if @audiotext!="" and @audiotext!=nil                                                            
            esay
        end
def editupdate
      if (c=getkeychar)!="" and (c.to_i.to_s==c or (@flags&Flags::Numbers)==0) and (@flags&Flags::ReadOnly)==0
                speech_stop
        einsert(c)
        play("edit_space") if c==" "
               if ((wordendings=" ,./;'\\\[\]-=<>?:\"|\{\}_+`!@\#$%^&*()_+").include?(c)) and (($interface_typingecho == 1 or $interface_typingecho == 2))
                 s=@text[(@index>50?@index-50:0)...@index]
                                  w=(s[(0 ... s.length).find_all { |i| wordendings.include?(s[i..i]) or s[i..i]=="\n"}.sort[-2]||0..(s.size-1)])
if (w=~/([a-zA-Z0-9ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]+)/)!=nil
  espeech(w)
else
  espeech(c) if @interface_typingecho!=1
  end
elsif $interface_typingecho==0 or $interface_typingecho==2
         espeech(c)
      end
    elsif c!=""
            play("border") if (c!=" " or $speechaudio==nil)
      end
    if enter
      speech_stop
          if (@flags&Flags::MultiLine)>0 and $key[0x11]==false and (@flags&Flags::ReadOnly)==0
      einsert("\n")
      play("edit_endofline")
    elsif ((@flags&Flags::MultiLine)==0 or $key[0x11]) and (@flags&Flags::ReadOnly)==0
      play("list_select")
            end
          end
          if $key[0x2e] and (@index<@text.size or @check<@text.size) and (@flags&Flags::ReadOnly)==0
            play("edit_delete")
            c=[@index,@check].sort
                                                                  c[0]-=1 while c[0]>0 and @text[c[0]-1..c[0]].split("").size==@text[c[0]..c[0]].split("").size
                              c[1]+=1 while c[1]<@text.size-1 and @text[c[1]..c[1]+1].split("").size==@text[c[1]..c[1]].split("").size
                                                                          edelete(c[0],c[1])
                                                                          espeech(@text[@index..@index+1].split("")[0])
          end
          if $key[0x08] and (@index>0 or @check>0) and (@flags&Flags::ReadOnly)==0
play("edit_delete")
c=[]
if @index!=@check
c=[@index,@check].sort
c[0]-=1 while c[0]>0 and @text[c[0]-1..c[0]].split("").size==@text[c[0]..c[0]].split("").size
                              c[1]+=1 while c[1]<@text.size-1 and @text[c[1]..c[1]+1].split("").size==@text[c[1]..c[1]].split("").size
else
  oind=ind=@index-1
  ind-=1 while ind>0 and @text[ind..ind].split("").size==@text[ind-1..ind].split("").size
  c=[ind,oind]
  end
                                                                                                                                espeech(@text[c[0]..c[1]].split("")[0])
            edelete(c[0],c[1])                                    
                                                end
                    end
        def navupdate
            @vindex=$key[0x10]?@check:@index
            @ch=false
          if Input.repeat?(Input::RIGHT) and ($key[0x10]==false or $speechaudio==nil)
                                  @vindex+=1 while @vindex<@text.size-1 and @text[@vindex..@vindex+1].split("").size==1
          if @vindex>=@text.size
                    play("border")
                                      elsif @vindex==@text.size-1
                    @vindex=@text.size
                    play("edit_endofline")
                  else
                    if $key[0x11]==false
                              ind=@vindex+1
        oi=ind
        ind+=1 while ind<@text.size-1 and @text[ind..ind+1].split("").size==1
                espeech(@text[@vindex+1..ind])
                @vindex=oi
              else
                                                @vindex=((@vindex+($key[0x10]?((@vindex>=(@text.size-1))?1:2):1) ... (@vindex<@text.size-100?@vindex+100:@text.length)).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort[0]||@text.size-1)
                                @vindex+=($key[0x10]?((@vindex>=@text.size-1)?0:-1):1)
                                                                                                (@vindex==@text.size)?play("edit_endofline"):espeech(@text[($key[0x10]?((0 .. @vindex).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort.last||0):@vindex)..(@vindex+1 ... @text.length).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort[0]||@text.size-1])
                                                                                              end
                              end
                                              elsif Input.repeat?(Input::LEFT) and ($key[0x10]==false or $speechaudio==nil)
        if @vindex<=0
                    play("border")
                  else
        if $key[0x11]==false
                    ind=@vindex-1
                  ind-=1 while ind>0 and @text[ind-1..ind].split("").size==1
                                            espeech(@text[ind..@vindex-1])
                @vindex=ind
              else
                @vindex=((((@vindex>100)?(@vindex-100):0) ... @vindex-1).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort.last||-1)+1
                @vindex-=1 if $key[0x10] and @check>@vindex and @vindex>0
                espeech(@text[@vindex..(@vindex+1 ... @text.length).find_all { |i| @text[i..i]==" " or @text[i..i]=="\n"}.sort[0]||@text.size-1])
                end
              end
            elsif Input.trigger?(Input::UP)
              b=linebeginning
              e=lineending
                            if b==0
                play("border")
                espeech(e>0?(@text[0..e-1]):"")
              else
                                l=@vindex-b
                em=lineending(b-1)
                bm=linebeginning(b-1)
                l=em-bm if em-bm<l
                l=0 if e-b<=1
                                @vindex=bm+l
                espeech(em>0?(@text[bm..em-1]):"")
                end
            elsif Input.trigger?(Input::DOWN)
              b=linebeginning
              e=lineending
              if e==@text.size
                play("border")
                espeech(@text[b..e-1])
              else
                l=@vindex-b
                ep=lineending(e+1)
                bp=linebeginning(e+1)
                l=ep-bp if ep-bp<l
                l=0 if e-b<=1
                                @vindex=bp+l
                espeech(@text[bp..ep-1])
                end
        end
        if $key[0x24]
                    @ch=@vindex=$key[0x11]?0:linebeginning
                            espeech($key[0x11]?@text[linebeginning..lineending]:@text[@vindex..@text.size-1].split("")[0]) if @vindex<@text.size
                                      elsif $key[0x23]
          @ch=@vindex=$key[0x11]?(@text.size):lineending
          espeech($key[0x11]?@text[linebeginning..lineending]:(((t=@text[lineending..lineending])=="")?"\n":t))
                                                end
                                                        if $key[0x21]
                    if linebeginning==0
                play("border")
                espeech(@text[0..lineending-1])
              else
                lines=getlines
                curline=curlineind=0
                for i in 0..lines.size-1
l=lines[i]
if l<=@vindex                  
curline=l
curlineind=i
end
                                  end
                inlineindex=@vindex-curline
                                  if curlineind<15
                  @vindex=inlineindex
                else
                  inlineindex=lines[curlineind-14]-lines[curlineind-15] if inlineindex>lines[curlineind-14]-lines[curlineind-15]
                  @vindex=lines[curlineind-15]+inlineindex
                  end
                espeech(@text[linebeginning..lineending-1])
                end
            elsif $key[0x22]
              if lineending==@text.size
                play("border")
                                espeech(@text[linebeginning..lineending-1])
              else
                                lines=getlines
                curline=curlineind=0
                for i in 0..lines.size-1
l=lines[i]
if l<=@vindex                  
curline=l
curlineind=i
end
                                  end
                                                  inlineindex=@vindex-curline
                                  if curlineind>lines.size-17
                                                                                          @vindex=lines[-1]+inlineindex
                  @vindex=@text.size if @vindex>@text.size
                else
                  inlineindex=lines[curlineind+16]-lines[curlineind+15] if inlineindex>lines[curlineind+16]-lines[curlineind+15]
                                    @vindex=lines[curlineind+15]+inlineindex
                                    end
                espeech(@text[linebeginning..lineending-1])
                end
          end
                    if $key[0x10]==false and (@index!=@vindex or @ch!=false)
            @check=@index=@vindex
            Audio.bgs_stop
                      elsif ($key[0x10]==true and @check!=@vindex) or ($key[0x11] and $key[65] and !$key[0x12])
            if $key[0x11] and $key[65] and !$key[0x12]
                        @index=0
            @check=@text.size
          else
            @check=@vindex
                        end
                                    if @index!=@check
            @tosay+="\r\n(Zaznaczono: #{getcheck})"
            play("edit_checked")
          else
            Audio.bgs_stop
            end
          end
          Audio.bgs_stop if escape or (enter and $key[0x11]) or $key[0x9]
            esay
  end
def ctrlupdate
if $key[0x11]   and $key[0x12]==false
  if $key[67]
    Clipboard.set_data(unicode(getcheck.gsub("\n","\r\n")),13)
    speech(_("EAPI_Form:info_copied"))
  end
  if $key[88] and (@flags&Flags::ReadOnly)==0
    Clipboard.set_data(unicode(getcheck.gsub("\n","\r\n")),13)
    c=[@index,@check].sort
    edelete(c[0],c[1])
    speech(_("EAPI_Form:info_cut"))
  end
  if $key[86]
    einsert(Clipboard.get_unic.delete("\r"))
    speech(_("EAPI_Form:info_pasted"))
  end
    if $key[90] and @undo.size>0
      u=@undo.last
        @undo.delete_at(@undo.size-1)
u[0]==1?edelete(u[1],u[1]+u[2].size,false):einsert(u[2],u[1],false)
                    @redo.push(u)
          speech(_("EAPI_Form:info_undone"))
    end
      if $key[89] and @redo.size>0
      r=@redo.last
        @redo.delete_at(@redo.size-1)
                r[0]==2?edelete(r[1],r[1]+r[2].size,false):einsert(r[2],r[1],false)
                    @undo.push(r)          
          speech(_("EAPI_Form:info_repeated"))
    end
        $key[0x10]?translator(getcheck):espeech(translatetext(0,$language,getcheck)) if $key[84]
    if $key[70]
      search=input_text(_("EAPI_Form:type_searchphrase"),"ACCEPTESCAPE",@lastsearch||"")
      if search!="\004ESCAPE\004"
        @lastsearch=search
            ind=@index<@text.size-1?@text[@index+1..@text.size-1].downcase.index(search.downcase):0
      ind+=@index+1 if ind!=nil
  ind=@text[0..@index].downcase.index(search.downcase) if ind==nil
    if ind==nil
  speech(_("EAPI_Form:info_nomatch"))
else
  @index=ind
  espeech(@text[@index..@text.size-1])
  end
    end
    
    end
    speechtofile("",getcheck.gsub("\n","\r\n")) if $key[80]
    if $key[82] and FileTest.exists?("temp/savedtext.tmp") and @readonly!=true and (@flags&Flags::ReadOnly)==0 and @audiotext==nil
      @undo=[]  
      settext(read("temp/savedtext.tmp"))
  speech(_("EAPI_Form:info_loaded"))
  end
      if $key[83]
                writefile("temp\\savedtext.tmp",@text)
        speech(_("General:info_saved"))
        end
  end
  espeech(@text[@index..@text.size-1].gsub("\n","\r\n")) if @index<@text.size and $key[115] and (@audiotext==nil or @index>0)
      if enter and (@flags&Flags::ReadOnly)>0 and (/(http(s?)\:\/\/([a-zA-Z0-9:\/,.\?\-\\=\_\+!%\&\(\)]+))/=~@text[linebeginning..lineending-1]) != nil
        espeech(_("EAPI_Form:wait_link"))
        run("explorer \"#{$1}\"") 
        end
  esay
end
def mediaupdate
  return if @audiotext==nil or @audiotext=="" 
  if $key[0x11] and $key[83]
            dialog_open
        form=Form.new([FilesTree.new(_("EAPI_Form:head_dst"),getdirectory(40)+"\\",true,true,"Music"),Edit.new(_("EAPI_Form:type_Filename"),"",@header.delete("\r\n").delete("\"").delete("/").delete("\\")+".mp3"),Button.new(_("General:str_save")),Button.new(_("General:str_cancel"))])
        loop do
          loop_update
          form.update
          break if escape or ((space or enter) and form.index==3)
          if (space or enter) and form.index==2
            dest=form.fields[0].selected+"\\"+form.fields[1].text_str
            sou=@audiotext
            sou.sub!("/",$url) if sou[0..0]=="/"
                        speech(_("EAPI_Form:wait_downloading"))
                        waiting
                        executeprocess("bin\\ffmpeg -y -i \"#{sou}\" \"#{dest}\"",true)
                        waiting_end
                        speech(_("EAPI_Form:info_downloaded"))
                        speech_wait
                                    break
            end
          end
          dialog_close
    end
    ($speechaudio==nil)?speech("\004AUDIO\004"+@audiotext+"\004AUDIO\004"+@text.gsub("\n","\r\n")):$speechaudio.position+=5 if $key[115]
    if $key[0x20]
      if $speechaudio!=nil and $speechaudio.closed==false
      if $speechaudiopaused!=true
          $speechaudio.pause
          $speechaudiopaused=true
        else
          $speechaudio.play
          $speechaudiopaused=false
        end
      else
        $speechaudiopaused=false
        speech("\004AUDIO\004#{@audiotext}\004AUDIO\004")
        end
    end
return if $speechaudio==nil    
                  if $speechaudio!=nil and $key[0x10]==true
      if Input.repeat?(Input::LEFT)
      $speechaudio.position-=5
      delay(0.1)
    elsif Input.repeat?(Input::RIGHT)
      $speechaudio.position+=5
      delay(0.1)
        end
  end      
  
  end
  def linebeginning(index=@vindex)
                  return 0 if index==0
    return 0 if @text.size==0
l=((((index>3000?index-3000:0) ... index).find_all { |i| @text[i..i]=="\n"}[-1])||-1)+1
  r=((index ... (index<@text.size-3000?@index+3000:@text.size)).find_all { |i| @text[i..i]=="\n"}[0])||@text.size    
  ls=getvlines(l,r)
  ind=l
  for n in ls
    ind=n if n<=index
  end
      return ind
end
def lineending(index=@vindex)
              return 0 if @text.size==0
  l=((((index>3000?index-3000:0) ... index).find_all { |i| @text[i..i]=="\n"}[-1])||-1)+1
  r=((index ... (index<@text.size-3000?@index+3000:@text.size)).find_all { |i| @text[i..i]=="\n"}[0])||@text.size
        ls=getvlines(l,r)
      ln=0
    for i in 0...ls.size-1
    ln=i if ls[i]<=index
  end
  ind=ls[ln+1]-1            
    return ind
  end
def getvlines(l,r)
    return [l,r+1] if r-l<120 or (@flags&Flags::MultiLine)==0 or (@flags&Flags::DisableLineWrapping)>0 or $interface_linewrapping==0
  ls=[l]
    for c in l...r
           if @text[c..c]==" " and c-ls[-1]>120 and c!=r-1
                        for oc in c..r
if @text[oc..oc]!=" "
              ls.push(oc)
              break if oc>=r
              break
              end
      end
          end
    end
    ls.delete_at(-1) if ls[-1]>=r          
    ls.push(r+1) if ls[-1]!=r+1
                  return ls
  end
  def getlines
        ns=(0...@text.size).find_all {|c| @text[c..c]=="\n"}
        ns.push(@text.size-1)
        lines=[]
        for i in 0..ns.size-1
                    prior=-1
          prior=ns[i-1] if i>0
          lines+=getvlines(prior+1,ns[i])
          lines.delete_at(-1)
          end
              return lines
          end
  def getcheck
  return @text if @index==@check
  st=[@index,@check].sort
  from=st[0]
  to=st[1]
  to+=1 while to<@text.size and @text[from..to+1].split("").size==@text[from..to].split("").size
  return @text[from..to]
  end
  def einsert(text,index=@index,toundo=true)
  @undo.push([1,index,text]) if toundo==true
@undo.delete_at(0) if @undo.size>100
@redo=[] if toundo==true
    @text.insert(index,text)
  @index+=text.size
  @check=@index
end
def edelete(from,to,toundo=true)
@check=@index=from if @index>from
@undo.push([2,from,@text[from..to]]) if toundo==true
@redo=[] if toundo==true
@undo.delete_at(0) if @undo.size>100
@text[from..to]=""
Audio.bgs_stop
  end
  def espeech(text)
  @tosay=text
  end
def esay
  if @tosay!="" and @tosay!=nil
        if (@flags&Flags::Password)==0
    speech(@tosay)
  else
    play("edit_password_char")
  end
  @tosay=""
end
end
def settext(text,reset=true)
  text.gsub!(/\004ATTACH\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004ATTACH\004/,"")
  @text=text.gsub("\004LINE\004","\n").delete("\r")
  @index=0 if reset==true
  @index=@text.size if @index>@text.size
  end
def finalize
  text_str
  end
  def text_str
  return @text.gsub("\n","\004LINE\004")
  end
  def focus
      play("edit_marker")
      tp=_("EAPI_Form:fld_edit")
      tp=_("EAPI_Form:fld_text") if (@flags&Flags::ReadOnly)>0
      tp=_("EAPI_Form:fld_media") if @audiotext!=nil
      speech(@header.to_s + " ... " + tp + ": " + ((@audiotext!=nil)?"\004AUDIO\004#{@audiotext}\004AUDIO\004":"") + text.gsub("\n"," "),1,false)
    end
    class Flags
MultiLine=1
ReadOnly=2
Password=4
  Numbers=8
  DisableLineWrapping=16
  end
        end
  
    # A listbox class
    class Select
      # @return [Numeric] a listbox index
attr_accessor :index
# @return [Array] listbox options
attr_accessor :commandoptions    
attr_reader :grayed
attr_reader :selected
attr_accessor :silent
attr_accessor :header
# Creates a listbox
#
# @param options [Array] an options list
# @param border [Boolean] restrain the listbox
# @param index [Numeric] an initial index
# @param header [String] a listbox caption
# @param quiet [Boolean] don't read a caption at creation
# @param multi [Boolean] support multiple selection
# @param lr [Boolean] create left-right listbox
# @param silent [Boolean] don't play listbox sounds
def initialize(options,border=true,index=0,header="",quiet=false,multi=false,lr=false,silent=false)
  options=options.deep_dup
      border=false if $interface_listtype == 1
      index = 0 if index == nil
      index = 0 if index >= options.size
      index+=options.size if index<0
      self.index = index
            @commandoptions = []
                        @hotkeys = {}
                        for i in 0..options.size - 1
              if options[i]!=nil
if lr
                for j in 0..options[i].size-1
  @hotkeys[options[i][j+1..j+1].upcase[0]] = i if options[i][j..j] == "&"
end
end
opt=options[i]
opt.delete!("&") if lr
@commandoptions.push(opt) if options[i] != nil
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
            index=0 if index<0
            @index=0 if @index<0
            options[index]="" if options[index]==nil
                        @header = header
              focus if quiet == false
              @lr=lr
            end
            
            # Update the listbox
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
if (($ruby != true and ((Input.repeat?(Input::UP) and @lr==false) or (Input.repeat?(Input::LEFT) and @lr==true)) or ($ruby == true and (($key[0x26] and @lr == false) or ($key[0x25] and @lr == true)) ) and $key[0x10]==false))
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
  elsif (($ruby != true and ((Input.repeat?(Input::DOWN) and @lr==false) or (Input.repeat?(Input::RIGHT) and @lr==true)) or ($ruby == true and (($key[0x28] and @lr == false) or ($key[0x27] and @lr == true)) ) and $key[0x10]==false))
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
            for i in 1..15
              self.index-=1
              while @grayed[self.index] == true and self.index>15-i
    self.index -= 1
  end
              end
          else
            self.index = 0
            end
            @run = true
        while @grayed[self.index] == true
    self.index += 1
  end
    end
        if $key[0x22] == true and @lr==false
       if self.index < (options.size - 15)
            for i in 1..15
              self.index+=1
                  while @grayed[self.index] == true and self.index<@commandoptions.size-i
    self.index += 1
  end              
              end
          else
            self.index = options.size-1
            end
            @run = true
  while @grayed[self.index] == true and self.index<@commandoptions.size
    self.index += 1
  end
        end
        suc = false
        k=getkeychar($key,!@lr)
                if k != "" and k != " "
          i=k.upcase[0]
          if @hotkeys[i]==nil
                  @run = true
        for j in self.index + 1..options.size - 1
          if suc == false              
          if options[j][0..k.size-1].upcase==k.upcase and @grayed[j]!=true
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
        if options[j][0..k.size-1].upcase==k.upcase and @grayed[j]!=true
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
o = options[self.index]
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
  end
o += "...\r\n#{_("EAPI_Form:opt_phr_shortkey")}: " + ASCII(ss) if ss.is_a?(Integer)
o += "\r\n\r\n(Zaznaczono)" if @selected[self.index] == true
o||=""
o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
o=("\004NEW\004"+" "+$1+" "+o).gsub(/\004INFNEW\{([^\}]+)\}\004/,"")
}
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
      speech(_("EAPI_Form:info_checked"))
    else
      @selected[@index] = false
      play("list_unchecked")
      speech(_("EAPI_Form:info_unchecked"))
      end
    end
  end
  
  
def focus(header=@header)
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
              sp = header + ": " if @header!=nil and @header!=""
              sp="" if sp==nil
            if options.size>0
              o = options[self.index].delete("&")
              o.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
o=("\004NEW\004"+" "+$1+" "+o).gsub(/\004INFNEW\{([^\}]+)\}\004/,"")
}
sp += o
ss = false
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
  end
sp += "...\r\n#{_("EAPI_Form:opt_phr_shortkey")}: " + ASCII(ss) if ss.is_a?(Integer)
end            
sp += _("EAPI_Form:info_listempty") if @commandoptions.size==0
speech(sp)
end

# Hides a specified item
#
# @param id [Numeric] the id of an item to hide
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
def enable_item(id)
  @grayed[id]=false
  end
end

# A button class
        class Button
        # @return [String] the label of a button
          attr_accessor :label
          
          # Creates a button
          #
          # @param label [String] a button label
        def initialize(label="")
          @label = label
        end
        
        # Updates a button
        def update
          if $focus == true
    focus
    $focus = false
    end
          end
        def focus
          play("button_marker")
          speech(@label + "... " + _("EAPI_Form:fld_button"))
        end
      end
      
      # A checkbox class
      class CheckBox
        # @return [String] a checkbox label
        attr_accessor :label
        # @return [Numeric] 0 if non-checked, 1 if checked
        attr_accessor :checked
        
        # Creates a checkbox
        #
        # @param checked [Numeric] specifies the default state of a checkbox (0 - not checked, 1 - checked)
        # @param label [String] a checkbox label
        def initialize(label="",checked=0)
          @label = label
          @checked = checked
        end
        
        # Updates a checkbox
        def update
          if $focus == true
    focus
    $focus = false
    end
          if space or enter
            if @checked == 1
              @checked = 0
              speech(_("EAPI_Form:st_unchecked"))
            else
              @checked = 1
              speech(_("EAPI_Form:st_checked"))
              end
            end
          end
        
                    def focus
          play("checkbox_marker")
          text = @label + " ... "
          if @checked == 0
            text += _("EAPI_Form:st_unchecked")
          else
            text += _("EAPI_Form:st_checked")
          end
          text += " "
          text += _("EAPI_Form:fld_checkbox")
          speech(text)
        end
      end        
      
      # Creates a files tree
      class FilesTree
        # @param header [String] a window caption
        attr_accessor :header
        # @return [String] selected file name
                attr_accessor :file
                                attr_reader :cpath
                                # @return [Array] file extensions to show
                attr_accessor :exts
                
                # Creates a files tree
                # @param header [String] a window caption
                # @param path [String] an initial path
                # @param hidefiles [Boolean] hide files
                # @param quiet [Boolean] don't write the caption at creation
                # @param file [String] a file to focus
                # @param exts [Array] an array of file extensions to show
                def initialize(header="",path="",hidefiles=false,quiet=false,file=nil,exts=nil,specialvoices=false)
        @path=path
        @cpath=path
        @file=""
                @hidefiles=hidefiles
        @header=header
        @specialvoices=specialvoices
        if file!=nil
          @file=file
          end
        @exts=exts
          focus if quiet==false
        end
        
        # Updates a files tree
      def update(init=false)
        if $focus
          $focus=false
          speech(@file)
          end
        if @sel == nil or @refresh == true
              if @path == ""
                              buf = "\0" * 1024
          len = Win32API.new("kernel32", "GetLogicalDriveStrings", ['L', 'P'], 'L').call(buf.length, buf)
          @disks=buf.split("\0")
          for i in 0..@disks.size-1
            @disks[i].chop! if @disks[i][-1..-1]=="\\"
            end
@adds=[_("EAPI_Form:opt_desktop"),_("EAPI_Form:opt_documents"),_("EAPI_Form:opt_music")]
@addfiles=[getdirectory(16),getdirectory(5),getdirectory(13)]
ind=@disks.find_index(@file)      
ind=0 if ind==nil
                h=""
h=@header if init==true
@sel=Select.new(@disks+@adds,true,ind,h)
      @sel.silent=true if @specialvoices
      @files=@disks+@addfiles
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
  ind=@sel.index if @sel!=nil
ind-=1 if ind>fls.size-1
ind=fls.find_index(@file,ind)
h=""
h=@header if init==true
@sel=Select.new(fls,true,ind,h,true)
@sel.silent=true if @specialvoices
@sel.focus if @refresh != true
@files=fls
@refresh=false
end
end
@sel.update
@file=@files[@sel.index]
@file="" if @sel.commandoptions.size==0
if cfile!=nil
if @file!=@lastfile and @specialvoices
  @lastfile=@file
          if filetype==0
            play("file_dir")
            elsif filetype==1
  play("file_audio")
elsif filetype==2
  play("file_text")
elsif filetype==3
  play("file_archive")
elsif filetype==4
  play("file_document")
  end
end
  end
  if $key[0x10]==false
if (Input.trigger?(Input::RIGHT) or @go == true) and File.directory?(cfile(true,true))
  @lastfile=nil
  @go = false
    s=true
        begin
    Dir.entries(cfile(true,true)) if s == true
  rescue Exception
    s=false
    retry
      end
  if s == true
        if @path!=""
    @path=cfile(false,true)+"\\"
      @cpath=cfile(true,true)+"\\"
    else
      @path=cfile(false,true)+"\\"
      @cpath=cfile(true,true)+"\\"
      end
  @file=""
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
end

def filetype
  return 0 if File.directory?(cfile(true,true))
  ext=File.extname(selected).downcase
  if ext==".mp3" or ext==".ogg" or ext==".wav" or ext==".mid" or ext==".wma" or ext==".flac" or ext==".aac" or ext==".opus" or ext==".m4a" or ext==".mov" or ext==".mp4" or ext==".avi"
    return 1
  elsif ext==".txt"
    return 2
  elsif ext==".rar" or ext==".zip" or ext==".7z"
    return 3
  elsif ext==".doc" or ext==".rtf" or ext==".htm" or ext==".html" or ext==".docx" or ext==".pdf" or ext==".epub"
    return 4
  elsif ext==".eapi"
    return 5
      else
    return -1
    end
  end

# An opened path
# @return [String] an opened path
      def path(c=false)
        return @path if c==false
        return @cpath if c
      end
      
      # Opens a specified path
      #
      # @param pt [String] a path to open
      def path=(pt)
        @path=pt
        @cpath=pt
        @sel=nil
      end
      
      # Opens the focused path
        def go
          @go = true
          update
        end
        
        # Gets the current file
        # @return [String] current file
        def cfile(c=true,fulllocation=false)
          return "" if @file==nil
                    tmp="\0"*8192
if c==true
                    Win32API.new("kernel32","GetShortPathName",'ppi','i').call(utf8(@cpath+@file),tmp,tmp.size)
                  else
                    Win32API.new("kernel32","GetLongPathName",'ppi','i').call(utf8(@cpath+@file),tmp,tmp.size)
                                        end
tmp.delete!("\0")
tmp.gsub!("/","\\")
tmp=futf8(tmp)
if fulllocation==false
return tmp.split("\\").last
else
  return tmp
end
end
        
          # Refreshes the tree
          def refresh
          @refresh=true
        end
        
        # Returns the path to the selected file or directory
        #
        # @param c [Boolean] use diacretics shortening
        # @return [String] the absolute path to a focused file or directory
          def selected(c=false)
            return "" if @file==nil
          r=""
          if c == false
            r = @path + @file
          else
            if cfile!=nil
            r = @cpath + cfile
          else
            return ""
            end
          end
          return r
          end
          
          def focus
          if @sel == nil        
          loop_update
            update(true)
          else
                    hin=""
          hin=@header+": \r\n" if @header!=""
                  hin += @file
        speech(hin)
        end
        end
      end
      
      class Static
        attr_accessor :label
        def initialize(label="")
          @label=label
        end
        def update
        end
        def focus
          speech(@label)
        end
        end
      
     class Tree
       attr_reader :sel
       attr_accessor :options
       attr_accessor :index
       attr_accessor :commandoptions
       attr_reader :opfocused
       def initialize(options,data=0,header="",quiet=false,lr=false,silent=false)
                index=0
         @options=options
         @header=header
         @silent=silent
         @lr=lr
         @way=[]
@sel=createselect([],0,true)
focus
end
def update
  @sel.update
  @index=getwayindex(@way+[@sel.index])-1
  @opfocused=false
      if (Input.trigger?(Input::RIGHT) and @lr == false) or (Input.trigger?(Input::DOWN) and @lr == true) or enter
    o=@options.deep_dup
    for l in @way
      o=o[l][1..o[l].size-1]
    end
        if o[@sel.index].is_a?(Array)
            @way.push(@sel.index)
            @sel=createselect(@way)
                  elsif enter
          @opfocused=true
          end
    end
              if ((Input.trigger?(Input::LEFT) and @lr == false) or (Input.trigger?(Input::UP) and @lr == true)) and @way.size>0
      ind=@way.last
      @way.delete_at(@way.size-1)
      @sel=createselect(@way,ind)
            end
    end
       def createselect(way=[],selindex=0,quiet=false)
         opt=getelements(way)
         s=Select.new(opt,true,selindex,@header,true,false,@lr,@silent)
         speech(s.commandoptions[s.index]) if quiet!=true
         return s
         end
         def searchway(way=[],tway=[],index=0)
                                 return [index,tway] if way==tway
           t=@options.deep_dup
           for l in tway
             t=t[l][1..t[l].size-1]
           end
           return [index,tway] if t.is_a?(Array)==false
                      for i in 0..t.size-1
                          x=searchway(way,tway+[i],index+1)
               if x[1]==way
                                 return x
                                 break
               else
                 index=x[0]
                 end
                                         end
           return [index,tway]
         end
         def getwayindex(index)
                      return searchway(index)[0]
                                 end
         def getelements(way=[])
sou=@options.deep_dup
         for l in way
           sou=sou[l][1..sou[l].size-1]
                end
              ret=sou
for i in 0..ret.size-1
  while ret[i].is_a?(Array)
    ret[i]=ret[i][0]
    end
  end
return ret
         end
         def focus
@sel.focus         
         end
       end
      
      
# Creates a dialog with a listbox and returns the option selected by user
#
# @param options [Array] an array of option
# @param header [String] a window caption
# @param index [Numeric] an initial index
# @param escapeindex [Numeric] a value to return when pressed the escape key, if nil, the escape is not supported
# @param type [Numeric] if 1, the listbox is horizontal
# @return [Numeric] the index of a selected option
      def selector(options,header="",index=0,escapeindex=nil,type=0,border=true,cancelkey=nil)
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
          if (escape or (cancelkey!=nil and Input.trigger?(cancelkey))) and escapeindex!=nil
            return escapeindex
            break
            end
          end
        end
        
        def menuselector(options)
        dis=[]
        for i in 0..options.size-1
          if options[i]==nil
            dis.push(i)
            options[i]=""
            end
          end
lsel=""
        play("menu_open")
        play("menu_background")
lsel = menulr(options,true,0,"")
                    for d in dis
        lsel.disable_item(d)
        end
        ret=-1
        loop do
          loop_update
          lsel.update
          if enter
            ret=lsel.index
            break
          end
          if alt or escape
            ret=-1
            break
            end
          end
        Audio.bgs_fade(100)
        play("menu_close")
        loop_update
        return ret  
        end
        
        # An alias to Select.new with lr set to 1
     def menulr(options,border=true,index=0,header="",quiet=false)
       return Select.new(options,border,index,header,quiet,false,true)
     end
     
     # Opens a file selection window and returns a path to file selected by user
     #
     # @param header [String] a window caption
     # @param path [String] an initial path
     # @param save [Boolean] hides a files, presents only directories
     # @param file [String] a file to focus
     # @return [String] an absolute path to a selected file or directory
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
           if save == false and File.file?(ft.selected(true))
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
           ftp=input_text(_("EAPI_Form:type_location"),"ACCEPTESCAPE",ft.path)
           ft.path=ftp if ftp!="\004ESCAPE\004" and File.directory?(ftp)
           end
         end
       end  
     end
     end
#Copyright (C) 2014-2018 Dawid Pieper