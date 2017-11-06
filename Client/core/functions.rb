#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

def futf8(text)
    mw = Win32API.new("kernel32", "MultiByteToWideChar", "ilpipi", "i")
    wm = Win32API.new("kernel32", "WideCharToMultiByte", "ilpipipp", "i")
    len = mw.call(0, 0, text, -1, nil, 0)
    buf = "\0" * (len*2)
    mw.call(0, 0, text, -1, buf, buf.size/2)
    len = wm.call(65001, 0, buf, -1, nil, 0, nil, nil)
    ret = "\0" * len
    wm.call(65001, 0, buf, -1, ret, ret.size, nil, nil)
    for i in 0..ret.size - 1
      ret[i..i] = "\0" if ret[i] == 0
    end
    ret.delete!("\0")
    return ret
  end

def utf8(text)
  text = "" if text == nil or text == false
ext = "\0" if text == nil
to_char = Win32API.new("kernel32", "MultiByteToWideChar", 'ilpipi', 'i') 
to_byte = Win32API.new("kernel32", "WideCharToMultiByte", 'ilpipipp', 'i')
utf8 = 65001
w = to_char.call(utf8, 0, text.to_s, text.size, nil, 0)
b = "\0" * (w*2)
w = to_char.call(utf8, 0, text.to_s, text.size, b, b.size/2)
w = to_byte.call(0, 0, b, b.size/2, nil, 0, nil, nil)
b2 = "\0" * w
w = to_byte.call(0, 0, b, b.size/2, b2, b2.size, nil, nil)
return(b2)
  end

def speech(text,method=1)
  if $speech_wait == true
    speech_wait
    $speech_wait = false
    end
  text = text.to_s
    text = text.gsub("\004LINE\004") {"\r\n"}
  $trans1 = [] if $t1 == nil
  $trans2 = [] if $t2 == nil
  if $translation == true
    suc = false
    for i in 0..$trans1.size - 1
      if $trans1[i] == text
        suc = true
        end
      end
      if suc == false
        std = $stdout
    $trans1.push(text)
    $trans2.push(text)
    std.reopen("trans","w")
    std.puts(text + "\\|\\" + text)
    end
    end
  if text == " " and $password != true
    if $interface_soundthemeactivation != 0
    play("edit_space")
  else
    speech("Spacja")
    end
    return
  end
  if text == "\n"
    play("edit_endofline")
    return
  end
  if text.size == 1
    if text[0] <= 90 and text[0] >= 65
      play("edit_bigletter")
      end
    end
  if $password == true
    speech_stop
    play("edit_password_char")
    return
    end
  if text != ""
  text = char_dict(text)
  text = dict(text) if $language != "PL_PL" and $language != nil
  text = text.sub("_"," ")
  text.gsub!("\004NEW\004") {
  play("list_new")
  ""
  }
polecenie = "sapiSayString"
polecenie = "sayString" if $voice == -1
text_d = text
text_d = utf8(text) if $speech_to_utf == true
$speech_lasttext = text_d
Win32API.new("screenreaderapi",polecenie,'pi','i').call(text_d,method) if $password != true
end
text_d = text if text_d == nil
return text_d
end

def speech_actived
  polecenie = "sapiIsSpeaking"
  if $voice != -1
  if Win32API.new("screenreaderapi",polecenie,'v','i').call() == 0
    return(false)
  else
    return(true)
  end
else
  i = 0
  loop do
    i += 1
   Graphics.update
   Input.update
   key_update
   break if $key[0x11] or i > $speech_lasttext.size * 10
 end
  return false
  end
  end
  
  def speech_stop
    polecenie = "sapiStopSpeech"
    polecenie = "stopSpeech" if $voice == -1
    Win32API.new("screenreaderapi",polecenie,'v','i').call()
    end
  
class Select
attr_accessor :index
attr_accessor :commandoptions    
attr_reader :grayed
attr_reader :selected
def initialize(options,border=true,index=0,header="",quiet=false,multi=false)
      border=false if $interface_listtype == 1
      index = 0 if index == nil
      index = 0 if index >= options.size
      self.index = index
            @commandoptions = []
            for i in 0..options.size - 1
              @commandoptions.push(options[i]) if options[i] != nil
            end
                                    @grayed = []
                                    @selected = []
            for i in 0..@commandoptions.size - 1
              @grayed[i] = false
              @selected[i] = false
              end
            @border = border
            @multi = multi
            header="" if header==nil
            options[index]="" if options[index]==nil
            @header = header
              focus if quiet == false
    end
    def update
      if $focus == true
    focus
    $focus = false
    end
      oldindex = self.index
      options = @commandoptions
if Input.trigger?(Input::UP)
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
  elsif Input.trigger?(Input::DOWN)
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
  if $key[0x21] == true and self.index > 14
        @run = true
    self.index -= 15
      while @grayed[self.index] == true
    self.index -= 1
    end
    end
    if $key[0x22] == true and self.index < (options.size - 15)
        @run = true
    self.index += 15
      while @grayed[self.index] == true
    self.index += 1
    end
    end
    suc = false
  for i in 65..90
    if $key[i] == true
            for j in self.index + 1..options.size - 1
        opt =dict( options[j])[0]
        opt -= 32 if opt > 90
        if opt == i and suc == false
          suc = true
          self.index = j
                    while @grayed[self.index] == true
    self.index += 1
    end
          end
        end
              for j in 0..self.index
        opt = dict(options[j])[0]
opt = 0 if opt == nil
        opt -= 32 if opt > 90
        if opt == i and suc == false
          suc = true
          self.index = j
                    while @grayed[self.index] == true
    self.index += 1
    end
          end
        end
        @run = true
      if suc == false
      else
                if self.index == oldindex
          oldindex = -1
          end
        end
      end
    end
    if enter
      play("list_select")
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
o += "\r\n\r\n(Zaznaczono)" if @selected[self.index] == true
  speech(o)
  play("list_checked") if @selected[self.index] == true
end
    if oldindex != self.index
  self.index = 0 if options.size == 1 or options[self.index] == nil
  play("list_focus")
@run = false
elsif oldindex == self.index and @run == true
    play("border")
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
   play("list_marker")
              while @grayed[self.index] == true
                            self.index += 1
            end
            if self.index > @commandoptions.size - 1
              while @grayed[self.index] == true
              self.index -= 1
              end
              end
      txt = ""
      txt = dict(@header.to_s) + ": " if @header != ""
      txt += dict(@commandoptions[@index].to_s)
      speech(txt)
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
    
  def ASCII(kod)
    if kod >= 65 and kod <= 90
      kod += 32
    end
              case kod
  when 32
    r=" "
    when 46
      r="kropka"
    when 48
      r="0"
      when 49
        r="1"
        when 50
          r="2"
          when 51
            r="3"
            when 52
              r="4"
              when 53
                r="5"
                when 54
                  r="6"
                  when 55
                    r="7"
                    when 56
                      r="8"
                      when 57
                        r="9"
                        when 64
                          r="Małpa"
  when 97
    r="a"
    when 98
      r="b"
      when 99
        r="c"
        when 100
          r="d"
          when 101
            r="e"
            when 102
              r="f"
              when 103
                r="g"
                when 104
                  r="h"
                  when 105
                    r="i"
                    when 106
                      r="j"
                      when 107
                        r="k"
                        when 108
                          r="l"
                          when 109
                            r="m"
                            when 110
                              r="n"
                              when 111
                                r="o"
                                when 112
                                  r="p"
                                  when 113
                                    r="q"
                                    when 114
                                      r="r"
                                      when 115
                                        r="s"
                                        when 116
                                          r="t"
                                          when 117
                                            r="u"
                                            when 118
                                              r="v"
                                              when 119
                                                r="w"
                                                when 120
                                                  r="x"
                                                  when 121
                                                    r="y"
                                                    when 122
                                                      r="z"
                                                      when 243
                                                        r="ó"
                                                        when 261
                                                          r="ą"
                                                          when 263
                                                            r="ć"
                                                            when 281
                                                              r="ę"
                                                              when 322
                                                                r="ł"
                                                                when 324
                                                                  r="ń"
                                                                  when 347
                                                                    r="ś"
                                                                    when 378
                                                                      r="ź"
                                                                      when 380
                                                                        r="ż"
                                                    end
                                                    r="" if r==nil
                                                    return(r)
                                                  end
                                                  
def download(source,destination)
  source.delete!("\r\n")
  destination.delete!("\r\n")
  $downloadcount = 0 if $downloadcount == nil
  source.sub!("?","?eltc=#{$downloadcount.to_s(36)}\&")
  $downloadcount += 1
    ef = 0
  begin
  ef = Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,utf8(source),utf8(destination),0,nil)
rescue Exception
  Graphics.update
  retry
end
  Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(source)
  if FileTest.exist?(destination) == false
    writefile(destination,-4)
  else
    if File.extname(destination).downcase == ".php"
    des = readfile(destination)
    if des[0] == 239 and des[1] == 187 and des[2] == 191
      des = des[3..des.size-1]
      File.delete(destination)
      writefile(destination,des)
            end
        end
end
        return ef
    end
def GetAsyncKeyState(id)
 return(Win32API.new("user32","GetAsyncKeyState",'i','i').call(id))
end

def speech_wait
  if $voice >= 0
  while speech_actived == true
loop_update
end
else
  speech_actived
  end
  return
end

def char_dict(text)
  r=""
  case text
  when "."
    r="kropka"
    when ","
      r="przecinek"
      when "/"
        r="ukośnik"
        when ";"
          r="średnik"
          when "'"
            r="apostrof"
            when "["
              r="lewy kwadratowy"\
              when "]"
                r="prawy kwadratowy"
                when "\\"
                  r="bekslesz"
                  when "-"
                    r="minus"
                    when "="
                      r="równe"
                      when "`"
                        r="akcent"
                        when "<"
                          r="mniejsze"
                          when ">"
                            r="większe"
                            when "?"
                              r="pytajnik"
                              when ":"
                                r="dwukropek"
                                when "\""
                                  r="cudzysłów"
                                  when "{"
                                    r="lewa klamra"
                                    when "}"
                                      r="prawa klamra"
                                      when "|"
                                        r="kreska pionowa"
                                        when "_"
                                          r="podkreślnik"
                                          when "+"
                                            r="plus"
                                            when "!"
                                              r="wykrzyknik"
                                              when "@"
                                                r="małpa"
                                                when "#"
                                                  r="krzyżyk"
                                                  when "$"
                                                    r="dolar"
                                                    when "%"
                                                      r="procent"
                                                      when "^"
                                                        r="daszek"
                                                        when "\&"
                                                          r="ampersant"
                                                          when "*"
                                                            r="gwiazdka"
                                                            when "("
                                                              r="lewy nawias"
                                                              when ")"
                                                                r="prawy nawias"
                      end
                      if r==""
                        return(text)
                      else
                        return(r)
                        end
                      end
                      
                      def play(voice,volume=100,pitch=100)
                        if $interface_soundthemeactivation != 0
                        volume = (volume.to_f * $volume.to_f / 100.0)
                        volume = 1 if volume < 1
                        volume = 100 if volume > 100
                        volume = volume.to_i
                        if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mid")
                          Audio.se_play("#{$soundthemepath}/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mid")
                          Audio.bgs_play("#{$soundthemepath}/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/SE/#{voice}.wav") or FileTest.exist?("Audio/SE/#{voice}.mp3") or FileTest.exist?("Audio/SE/#{voice}.ogg") or FileTest.exist?("Audio/SE/#{voice}.mid")
                          Audio.se_play("Audio/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/BGS/#{voice}.wav") or FileTest.exist?("Audio/BGS/#{voice}.mp3") or FileTest.exist?("Audio/BGS/#{voice}.ogg") or FileTest.exist?("Audio/BGS/#{voice}.mid")
                          Audio.bgs_play("Audio/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                        end
                      end
                      
class SelectLR
attr_accessor :index
attr_reader :grayed
    def initialize(options,border=true,index=0,header="")
      index = 0 if index >= options.size
      self.index = index
            @commandoptions = []
            @hotkeys = {}
            for i in 0..options.size - 1
for j in 0..options[i].size-1
  @hotkeys[options[i][j+1..j+1].upcase[0]] = i if options[i][j..j] == "&"
  end
            @commandoptions.push(options[i].delete("&")) if options[i] != nil
            end
                        @grayed = []
            for i in 0..@commandoptions.size - 1
              @grayed[i] = false
              end
            @border = border
            options[index]="" if options[index]==nil
            header="" if header==nil
            sp = dict(header) + "\r\n" + dict(options[self.index].delete("&"))
ss = false
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
end
sp += "...\r\nSkrót: " + ASCII(ss) if ss.is_a?(Integer)
            speech(sp)
    @header = header
            end
    def update
      oldindex = self.index
      options = @commandoptions
if Input.trigger?(Input::LEFT)
  @run = true
  self.index -= 1
  if self.index < 0
    if @border != true
      oldindex = -1
      end
    self.index = options.size - 1
    self.index = 0 if @border == true
  end
      while @grayed[self.index] == true
    self.index -= 1
    end
  elsif Input.trigger?(Input::RIGHT)
    @run = true
  self.index += 1
  if self.index >= options.size
    if @border != true
      oldindex = -1
      end
    self.index = 0
    self.index = options.size - 1 if @border == true
  end
  while @grayed[self.index] == true
    self.index += 1
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
  if $key[0x21] == true and self.index > 14
    @run = true
        self.index -= 15
    while @grayed[self.index] == true
    self.index -= 1
    end
  end
    if $key[0x22] == true and self.index < (options.size - 15)
      @run = true
        self.index += 15
    while @grayed[self.index] == true
    self.index += 1
    end
  end
    suc = false
  for i in 65..90
    if $key[i] == true
      if @hotkeys[i] == nil
      @run = true
            for j in self.index + 1..options.size - 1
        opt = options[j][0]
        opt -= 32 if opt > 90
        if opt == i and suc == false
          suc = true
          self.index = j
          while @grayed[self.index] == true
    self.index += 1
    end
          end
        end
              for j in 0..self.index
        opt = options[j][0]
        opt -= 32 if opt > 90
        if opt == i and suc == false
          suc = true
          self.index = j
          while @grayed[self.index] == true
    self.index += 1
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
    end
    if enter
      play("list_select")
    end
    if @border == false
    self.index = 0 if self.index >= options.size
    self.index = options.size - 1 if self.index <= 0
  else
    self.index = options.size - 1 if self.index >= options.size
    self.index = 0 if self.index <= 0
  end
  while @grayed[self.index] == true and self.index < options.size - 2
    self.index += 1
  end
  while @grayed[self.index] == true and self.index > 0
    self.index -= 1
    end
if @run == true
  speech_stop
sp = dict(options[self.index])
ss = false
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
end
sp += "...\r\nSkrót: " + ASCII(ss) if ss.is_a?(Integer)
speech(sp)
end
    if oldindex != self.index
  play("list_focus")
  self.index = 0 if options.size == 1 or options[self.index] == nil
  oldindex = self.index
@run = false
else
  if @run == true
  play("border")
  @run = false
  end
end
end
def disable_item(id)
  @grayed[id] = true
end
def focus
  sp = dict(@header) + "\r\n" + dict(@commandoptions[self.index])
ss = false
for k in @hotkeys.keys
  ss = k if @hotkeys[k] == self.index
end
sp += "...\r\nSkrót: " + ASCII(ss) if ss.is_a?(Integer)
speech(sp)
end
  end
  
  def escape(fromdll = false)
    if fromdll == true
    esc = Win32API.new($eltenlib,"KeyState",'i','i').call(0x1B)
    if esc > 0
      sleep(0.05)
      return(true)
    else
      return(false)
    end
  else
        r = $key[0x1B]
                  return r
    end
    end
    
    def alt(fromdll = false)
      if fromdll == true
    alt = Win32API.new($eltenlib,"KeyState",'i','i').call(0x12)
    if alt > 0
      control = Win32API.new($eltenlib,"KeyState",'i','i').call(0x11)
      if control == 0
      sleep(0.05)
            return(true)
    else
      return(false)
      end
    else
      return(false)
    end
  else
    if $key[0x11] == false
      if $key[0xA4]
        t = Time.now.to_i
        delay
                        if Time.now.to_i <= t+1
        return true
      else
        return false
        end
              else
                return false
        end
          else
      return(false)
      end
    end
    end
    
    def enter(fromdll = false, space = false)
      if $enter.is_a?(Integer)
        if $enter > 0
        $enter -= 1
        return true
        end
        end
      if fromdll == true
    enter = Win32API.new($eltenlib,"KeyState",'i','i').call(0x0D)
    if enter > 0
      sleep(0.05)
      return(true)
    else
      return(false)
    end
  else
if Input.trigger?(Input::C) and $key[67] == false
  if space == false
    if $key[0x20] == false
      if $key[0x0d] == true
      return true
    else
      return false
      end
    else
      return false
      end
    else
  return true
  end
else
  return false
  end
  end
    end
    
        def space(fromdll=false)
          if fromdll == true
    space = Win32API.new($eltenlib,"KeyState",'i','i').call(0x20)
    if space > 0
      sleep(0.05)
      return(true)
    else
      return(false)
    end
  else
if Win32API.new("user32","GetAsyncKeyState",'i','i').call(0x20) != 0 and Input.trigger?(Input::C)
        return true
      else
        return false
        end
    end
    end
    
    def quit
      dialog_open
            sel = SelectLR.new(["Anuluj","Ukryj program w zasobniku systemowym","Wyjście"],true,0,"Zamykanie programu...")
      loop do
        loop_update
        sel.update
        if escape
          dialog_close
          break
            $exit = false
            return(false)
            end
        if enter
          dialog_close
          case sel.index
          when 0
            break
            $exit = false
            return(false)
            when 1
              $exit = false
              $scene = Scene_Tray.new
              return false
            when 2
              $scene = nil
              break
              $exit = true
              return(true)
                $exit = false
                return false
          end
          end
        end
      end
      
      class Scene_Console
      def main
                        kom = ""
        while kom == "" or kom == nil
          kom = input_text("Podaj polecenia do wykonania","MULTILINE|ACCEPTESCAPE").to_s
          if kom == "\004ESCAPE\004"
            $scene = Scene_Main.new
            return
            break
            end
          end
          kom.gsub!("\004LINE\004","\r\n")
          kom.delete!("\005")
  kom = kom.gsub("\004LINE\004","\n")
kom.gsub!("elten.edb","elten.dat")
  $consoleused = true
eval(kom,nil,"Console")
$consoleused = false        
$scene = Scene_Main.new if $scene == self
end
end

def error_ignore
  $scene = Scene_Main.restart
end

    def usermenu(user,submenu=false)
            ct = srvproc("contacts_mod","name=#{$name}\&token=#{$token}\&searchname=#{user}")
      err = ct[0].to_i
if err == -3
  @incontacts = true
else
  @incontacts = false
end
av = srvproc("avatar","name=#{$name}\&token=#{$token}\&searchname=#{user}\&checkonly=1")
      err = av[0].to_i
if err < 0
  @hasavatar = false
else
  @hasavatar = true
end
bt = srvproc("isbanned","name=#{$name}\&token=#{$token}\&searchname=#{user}")
@isbanned = false
if bt[0].to_i == 0
  if bt[1].to_i == 1
    @isbanned = true
    end
  end
  bl = srvproc("blog_exist","name=#{$name}\&token=#{$token}\&searchname=#{user}")
    if bl[0].to_i < 0
    @hasblog = false
    else
  if bl[1].to_i == 0
    @hasblog = false
  else
    @hasblog = true
    end
    end
  play("menu_open") if submenu != true
play("menu_background") if submenu != true
sel = ["Napisz prywatną wiadomość","Wizytówka","Otwórz blog tego użytkownika","Pliki udostępniane przez tego użytkownika"]
if @incontacts == true
  sel.push("Usuń z kontaktów")
else
  sel.push("Dodaj do kontaktów")
end
sel.push("Odtwórz awatar")
if $rang_moderator > 0
  if @isbanned == false
    sel.push("Zbanuj")
  else
    sel.push("Odbanuj")
    end
  end
  fl = srvproc("uploads","name=#{$name}\&token=#{$token}\&searchname=#{user}")
  if fl[0].to_i < 0
    speech("Błąd")
    speech_wait
    return
  end
    @menu = SelectLR.new(sel)
@menu.disable_item(2) if @hasblog == false
@menu.disable_item(3) if fl[1].to_i==0
@menu.disable_item(5) if @hasavatar == false
loop do
loop_update
@menu.update
if enter
  case @menu.index
  when 0
    $scene = Scene_Messages_New.new(user,"","",self)
    when 1
      play("menu_close")
      Audio.bgs_stop
      visitingcard(user)
            return("ALT")
      break
            when 2
        $scene = Scene_Blog_Other.new(user,self)
        when 3
          $scene = Scene_Uploads.new(user,self)
    when 4
      if @incontacts == true
        $scene = Scene_Contacts_Delete.new(user,self)
      else
        $scene = Scene_Contacts_Insert.new(user,self)
      end
      when 5
        play("menu_close")
      Audio.bgs_stop
      speech("Pobieranie...")
      avatar(user)
            return("ALT")
      break        
      when 6
        if @isbanned == false
          $scene = Scene_Ban_Ban.new(user,self)
        else
          $scene = Scene_Ban_Unban.new(user,self)
          end
end
break
end
if alt
  if submenu != true
    break
else
  return("ALT")
  break
end
end
if escape
  if submenu == true
        return
    break
  else
        break
    end
  end
  if Input.trigger?(Input::UP) and submenu == true
        Input.update
    return
    break
    end
end
Audio.bgs_stop if submenu != true
play("menu_close") if submenu != true
Graphics.transition(10) if submenu != true
end

                      def playpos(voice,pos,volume=100)
                        if $interface_soundthemeactivation != 0
                        volume = (volume.to_f / $volume.to_f * 100.0)
                                                $soundbuffer = [] if $soundbuffer == nil
                        $soundbufferid = 24 if $soundbufferid == nil
                        id = $soundbufferid
                        $soundbuffer[id] = nil
                        if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.wav")
                          $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/SE/#{voice}.wav")
                          end
                          if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mp3")
                            $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/SE/#{voice}.mp3")
                          end
                          if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.ogg")
                          $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/SE/#{voice}.ogg")
                        end
                        if FileTest.exist?("#{$soundthemepath}/BGM/#{voice}")
                          $soundbuffer[id] = AudioFile.new("#{$soundthemepath}/BGM/#{voice}")
                        end
                        if $soundbuffer[id] != nil
                                                                                                                          $soundbuffer[id].play
                        $soundbuffer[id].pan = pos
                        $soundbuffer[id].volume = volume
                                                $soundbufferid += 1
                                                $soundbufferid = 24 if $soundbufferid > 96
                        return(id)
                      else
                        return false
                        end
                      end
                        end
                      
                        def translate(from,to,text)
                                                    textc = "text=" + text.to_s.gsub(" ","%20").gsub("?","%3f").gsub(".","%2e").gsub("\\","%5c")
                                                    data = "POST /translate_a/single?client=t\&sl=#{from}\&tl=#{to}\&ie=utf-8\&oe=utf-8\&dt=t\&dt=bd&tk= HTTP/1.1\r\nAccept-Encoding: identity\r\nContent-Length: #{textc.size.to_s}\r\nHost: www.google.com\r\nContent-Type: application/x-www-form-urlencoded\r\nConnection: close\r\nUser-Agent: Elten/#{$version.to_s}\r\n\r\n#{textc}"
                          tt = connect("translate.google.com",80,data,1024+(4*textc.size))
        r = ""
    tt = [] if tt == nil
    ind = 0
        for i in 3..tt.size - 1
      ind += 1
      break if tt[i-3..i] == "\r\n\r\n"
    end
    ind += 1
    for i in ind+6..tt.size - 1
      if tt[i..i] == "\""
        break
      else
        r += tt[i..i]
      end
      end
     Graphics.update
     return(r)
   end
   
   def key_update
     $key = []
     if $keyms == nil
     $lkey = 0 if $lkey == nil
     $keyms= []
     for i in 1..255
       $keyms[i] = $interface_keyms+5
       $keyms[i] = $interface_ackeyms+5 if i == 0x1b
     end
               end
     for i in 1..255
       if Win32API.new($eltenlib,"KeyState",'i','i').call(i) != 0
         if ($keyms[i] > $interface_keyms and i != 0x1b) or ($keyms[i] > $interface_ackeyms)
           $keyms[i] = 0
           $keyms[i] = 50 if $lkey == i
                      $key[i] = true
           $lkey = i
         else
           $keyms[i] += 1
           $key[i] = false
           $key[i] = true if i >= 0x10 and i <= 0x12 or i == 0x14
         end
       else
         $key[i] = false
         $keyms[i] = $interface_keyms+5
         $keyms[i] = $interface_ackeyms + 5 if i == 0x1b
                  end
       end
     end
     
     def whatsnew(quiet=false)
       wntemp = srvproc("whatsnew","name=#{$name}\&token=#{$token}\&get=1")
       err = wntemp[0]
messages = wntemp[1].to_i
posts = wntemp[2].to_i
blogposts = wntemp[3].to_i
                                    if messages <= 0 and posts <= 0 and blogposts <= 0
  speech("Nie ma nic nowego.") if quiet != true
else
  $scene = Scene_WhatsNew.new(true)
end
speech_wait
end

def loop_update
  Graphics.update
  Input.update
  key_update
  speech_stop if Input.trigger?(Input::CTRL)
  Thread::stop if $stopmainthread == true and Thread::current == $mainthread
end

def dict(text)
  return text if $language == nil
  text = "" if text == nil
  if $lang_src != nil and $lang_dst != nil
for i in 3..$lang_src.size - 1
  if $lang_src[i] == text
    r = $lang_dst[i]
    return(r)
    end
  end
end
for i in 3..$lang_dst.size - 1
  suc = false
    $lang_dst[i].gsub("%%") {
  suc = true
  ""
  }
  if suc == true
    dst = $lang_dst[i].gsub("%","")
    src = $lang_src[i].gsub("%","")
  text.sub!(src,dst)
  end
end
text.gsub!("\r\r","  ")
  return(text)
end

def crypt(msg)
  cipher = Cipher.new ar = ["K","D","w","H","X","3","e","1","S","B","g","a","y","v","I","6","u","W","C","0","9","b","z","T","A","q","U","4","O","o","E","N","r","n","m","d","k","x","P","t","R","s","J","L","f","h","Z","j","Y","5","7","l","p","c","2","8","M","V","G","i"," ","Q","F","?",">","<","\"",":","/",".",",","'",":","[","]","{","}","-","=","_","+","\\","|","@","\#","!","`","$","^","\%","\&","*",")","(","\001","\002","\003","\004","\005","\006","\007","\008","\009","\0"]
crypted = cipher.encrypt msg
return(crypted)
end

def decrypt(msg)
 cipher = Cipher.new ar = ["K","D","w","H","X","3","e","1","S","B","g","a","y","v","I","6","u","W","C","0","9","b","z","T","A","q","U","4","O","o","E","N","r","n","m","d","k","x","P","t","R","s","J","L","f","h","Z","j","Y","5","7","l","p","c","2","8","M","V","G","i"," ","Q","F","?",">","<","\"",":","/",".",",","'",":","[","]","{","}","-","=","_","+","\\","|","@","\#","!","`","$","^","\%","\&","*",")","(","\001","\002","\003","\004","\005","\006","\007","\008","\009","\0"]
decrypted = cipher.decrypt msg
return(decrypted)
end

def createsoundtheme(name="")
  while name == ""
    name = input_text("Podaj nazwę tematu dźwiękowego.")
  end
  pathname = name
  pathname.gsub!(" ","_")
  pathname.gsub!("/","_")
  pathname.gsub!("\\","_")
  pathname.gsub!("?","")
  pathname.gsub!("*","")
  pathname.gsub!(":","__")
  pathname.gsub!("<","")
  pathname.gsub!(">","")
  pathname.gsub!("\"","'")
  stp = $soundthemesdata + "\\" + pathname
  Win32API.new("kernel32","CreateDirectory",'pp','i').call(stp,nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(stp + "\\SE",nil)
Win32API.new("kernel32","CreateDirectory",'pp','i').call(stp + "\\BGS",nil)
dir = Dir.entries("Audio/BGS")
dir.delete("..")
dir.delete(".")
for i in 0..dir.size - 1
Win32API.new("kernel32","CopyFile",'ppi','i').call(".\\Audio\\BGS\\" + dir[i],stp + "\\BGS\\" + dir[i],0)
end
Graphics.update
dir = Dir.entries("Audio/SE")
dir.delete("..")
dir.delete(".")
for i in 0..dir.size - 1
Win32API.new("kernel32","CopyFile",'ppi','i').call(".\\Audio\\SE\\" + dir[i],stp + "\\SE\\" + dir[i],0)
end
Graphics.update
writeini($soundthemesdata + "\\inis\\" + pathname + ".ini","SoundTheme","Name","#{name} by #{$name}")
writeini($soundthemesdata + "\\inis\\" + pathname + ".ini","SoundTheme","Path",pathname)
speech("Pliki tematu dźwiękowego utworzone w: " + stp)
speech_wait
speech("Nazwa tematu: " + name)
speech_wait
speech("Podmień pliki domyślnego tematu dźwiękowego w utworzonym katalogu plikami, które mają wchodzić w jego skład.")
speech_wait
sel = SelectLR.new(["Otwórz folder tematu w plikach","Otwórz folder tematu w systemowym eksploratorze plików","Zamknij"],true,0,"Co chcesz zrobić?")
loop do
  loop_update
  sel.update
  if escape
        return
    break
  end
  if enter
    case sel.index
    when 0
      $scene = Scene_Files.new(stp)
      return
      break
      when 1
        system("start " + stp)
        when 2
          return
          break
    end
    end
  end
end

def exceptionlist
  errors=""
exceptions = []
tree = {}
ObjectSpace.each_object(Class) do |cls|
  next unless cls.ancestors.include? Exception
  next if exceptions.include? cls
  next if cls.superclass == SystemCallError # avoid dumping Errno's
  exceptions << cls
  cls.ancestors.delete_if {|e| [Object, Kernel].include? e }.reverse.inject(tree) {|memo,cls| memo[cls] ||= {}}
end
indent = 0
tree_printer = Proc.new do |t|
  t.keys.sort { |c1,c2| c1.name <=> c2.name }.each do |k|
    space = (' ' * indent); space ||= ''
    errors += space + k.to_s + "\r\n"
    indent += 2; tree_printer.call t[k]; indent -= 2
  end
end
tree_printer.call tree
p tree
end

def simplequestion(text="")
  dialog_open  
  sel = SelectLR.new(["Nie","Tak"],true,0,text)
    loop do
    sel.update
    loop_update
        if escape
          loop_update
          dialog_close  
          return(0)
    end
    if enter
      loop_update
      dialog_close
            return(sel.index)
      end
    end
  end
  
  def readlines(file)
    createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(file,1,1|2|4,nil,4,0,0)
if handler < 64
  speech("Błąd.")
  speech_wait
  end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
b = "\0" * 1048576
bp = "\0" * 1048576
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
b.delete!("\0")
bp.delete!("\0")
r = []
c = 0
r[c] = ""
for i in 0..b.size - 1
  b = b.sub("\004LINE\004","\n")
  end
for i in 0..b.size - 1
  r[c] += b[i..i]
  if b[i..i] == "\n"
    c += 1
    r[c] = ""
    end
  end
return(r)
end

def writefile(file,text)
  if text.is_a?(Array)
    t = ""
    for i in text
      t += i + "\r\n"
    end
    text = t
    end
  cf = Win32API.new("kernel32","CreateFile",'piipiip','i')
handle = cf.call(file,2,1|2|4,nil,2,0,nil)
writefile = Win32API.new("kernel32","WriteFile",'ipipi','I')
bp = "\0" * text.size
r = writefile.call(handle,text,text.size,bp,0)
bp = nil
Win32API.new("kernel32","CloseHandle",'i','i').call(handle)
handle = 0
return r
end

def run(file)
  params = 'LPLLLLLLPP'
createprocess = Win32API.new('kernel32','CreateProcess', params, 'I')
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
        pr = createprocess.call(0, file, 0, 0, 0, 0, 0, 0, startinfo, procinfo)
            return procinfo[0,4].unpack('L').first # pid
          end
          
          def createdebuginfo
            di = ""
            di += "*ELTEN | DEBUG INFO*\r\n"
            if $@ != nil
              if $! != nil
            di += $!.to_s + "\r\n" + $@.to_s + "\r\n"
          end
          end
            di +="\r\n[Computer]\r\n"
            di += "OS version: " + Win32API.new($eltenlib,"WindowsVersion",'v','i').call.to_s + "\r\n"
            di += "Appdata path: " + $appdata + "\r\n"
            di += "Elten data path: " + $eltendata.to_s + "\r\n"
                procid = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("PROCESSOR_IDENTIFIER",procid,procid.size)
procid.delete!("\0")
di += "Processor Identifier: " + procid.to_s + "\r\n"
                procnum = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("NUMBER_OF_PROCESSORS",procnum,procnum.size)
procnum.delete!("\0")
di += "Number of processors: " + procnum.to_s + "\r\n"
                cusername = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("USERNAME",cusername,cusername.size)
cusername.delete!("\0")
di += "User name: " + cusername.to_s + "\r\n"
di += "\r\n[Elten]\r\n"
di += "User: " + $name.to_s + "\r\n"
di += "Token: " + $token.to_s + "\r\n"
ver = $version.to_s
ver += "_BETA" if $isbeta == 1
di += "Version: " + ver.to_s + "\r\n"
di += "Start time: " + $start.to_s + "\r\n"
di += "Current time: " + Time.now.to_i.to_s + "\r\n"
di += "\r\n[Programs]\r\n"
for i in 0..$app.size - 1
di += $app[i].to_s
di += "\r\n"
end
di += "\r\n[Configuration]\r\n"
di += "Language: " + $language + "\r\n"
di += "Sound theme's path: " + $soundthemespath + "\r\n"
voice = futf8(Win32API.new("screenreaderapi","sapiGetVoiceName",'i','p').call($voice.to_i))
di += "Voice name: " + voice.to_s + "\r\n"
di += "Voice id: " + $voice.to_s + "\r\n"
di += "Voice rate: " + $rate.to_s + "\r\n"
return di
end

def bug(getinfo=true)
  loop_update
  info = ""
  if getinfo == true
  while info == ""
    info = input_text("Opisz znaleziony błąd","MULTILINE|ACCEPTESCAPE")
  end
  if info == "\004ESCAPE\004"
    return 1
  end
  info += "\r\n|||\r\n\r\n\r\n\r\n\r\n\r\n"
else
  info = ""
  end
  di = createdebuginfo
  info += di
  info.gsub!("\r\n","\004LINE\004")
  buf = buffer(info)
  bugtemp = srvproc("bug","name=#{$name}\&token=#{$token}\&buffer=#{buf}")
      err = bugtemp[0].to_i
  if err != 0
    speech("Błąd.")
    r = err
  else
    speech("Wysłano.")
    r = 0
  end
  speech_wait
  return r
end

class IOT
    def self.readlines(file)
    createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(file,1,1|2|4,nil,4,0,0)
if handler < 64
  speech("Błąd.")
  speech_wait
  end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
b = "\0" * 1048576
bp = "\0" * 1048576
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
b.delete!("\0")
bp.delete!("\0")
r = []
c = 0
r[c] = ""
for i in 0..b.size - 1
  b = b.sub("\004LINE\004","\n")
  end
for i in 0..b.size - 1
  r[c] += b[i..i]
  if b[i..i] == "\n"
    c += 1
    r[c] = ""
    end
  end
return(r.to_s)
end
end

def getstatus(name)
  $statuslisttime = 0 if $statuslisttime == nil
  if Time.now.to_i - 45 > $statuslisttime
    $statuslisttime = Time.now.to_i
  statustemp = srvproc("status_list","name=#{$name}\&token=#{$token}")
    err = statustemp[0].to_i
  if err != 0
    speech("Błąd.")
    speech_wait
    $scene = Scene_Main.new
    return
  end
  for i in 1..statustemp.size - 1
    statustemp[i].delete!("\r\n")
  end
  i = 0
  l = 1
  usr = true
  $statususers = []
  $statustexts = []
  loop do
    if usr == true
      $statususers[i] = statustemp[l]
      usr = false
    else
      if statustemp[l] != "\004END\004"
      $statustexts[i] = "" if $statustexts[i] == nil
      $statustexts[i] += statustemp[l]
    else
      i += 1
      usr = true
      end
    end
    l += 1
    break if l >= statustemp.size
    end
  end
  st = ""
  for i in 0..$statususers.size - 1
    if name == $statususers[i]
      st = $statustexts[i]
      end
    end
    return st
end

def setstatus(text)
  statustemp = srvproc("status_mod","name=#{$name}\&token=#{$token}\&text=#{text}")
    if statustemp[0].to_i != 0
    return statustemp[0].to_i
  else
    return 0
    end
  end
  
  def buffer(data)
                dt = data.gsub("\\","%5c")
                dt = dt.gsub("+","%2b")
                dt = dt.gsub("#","%23")
                dt = dt.gsub("'","%27")
    dt = dt.gsub("&","%26")
dt = hexspecial(dt)
dt = hexspecial(dt)                
return buffer_post(dt)
        s=false
    while s==false
      s=true
      if dt[dt.size - 1..dt.size - 1] == "\004" and dt[dt.size - 6..dt.size - 6] == "\004"
        s=false
        for i in 1..6
        dt.chop!
        end
        end
      end
    bdt = dt
    bdt.gsub!("`","\006")
    bdt.gsub!("'","\007")
    bdt.gsub!("\\","\\\\")
    dt = bdt
        bufid = rand(2147483000) + 1
    bufdt = []
    r = 0
    t = 0
    bufdt[r] = ""
    i = 0
    loop do
            t += 1
      if dt[i..i+5] == "\004LINE\004"
                t -= 6
                end
                    bufdt[r] += dt[i..i] if dt[i..i] != nil
            if utf8(dt[i..i + 1]) != dt[i..i + 1] and dt[i - 1..i] == dt[i - 1..i] and utf8(dt[i..i]) == "?"
              t -= 1
                    end
      if t >= 200
        r += 1
        bufdt[r] = ""
        t = 0
      end
      i += 1
      break if i > dt.size
    end
      buft = srvproc("buffer","name=#{$name}\&token=#{$token}\&ac=1\&id=#{bufid}\&data=#{bufdt[0]}")
            if buft[0].to_i < 0
        speech("Błąd")
        speech_wait
        $scene = Scene_Main.new
        return -1
      end
      for i in 1..bufdt.size - 1
              buft = srvproc("buffer","name=#{$name}\&token=#{$token}\&ac=2\&id=#{bufid}\&data=#{bufdt[i]}")
                          if buft[0].to_i < 0
        speech("Błąd")
        speech_wait
        $scene = Scene_Main.new
        return -1
      end
      end
  return bufid    
end

def dialog_open
    play("dialog_open")
        if FileTest.exist?("#{$soundthemepath}/BGS/dialog_background.ogg")
                          $dialogvoice = AudioFile.new("#{$soundthemepath}/BGS/dialog_background.ogg",2)
                          $dialogvoice.play
                          end
  $dialogopened = true
end

def dialog_close
  if $dialogvoice != nil
    $dialogvoice.close
    $dialogvoice = nil
    end
  play("dialog_close")
  $dialogopened = false
end

class Scene_Relogin
def main
  speech("Klucz sesji wygasł. Czy chcesz zalogować się ponownie jako #{$name} ?")
  speech_wait
      autologin = readini($configdata + "\\login.ini","Login","AutoLogin","0").to_i
                  name = readini($configdata + "\\login.ini","Login","Name")
            al = true if autologin.to_i != 0 and name == $name
  if simplequestion == 1
    if al == false
    password = input_text("Podaj hasło dla użytkownika #{$name}","password")
else
            password_c = "\0" * 128
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Login","password","0",password_c,password_c.size,$configdata + "\\login.ini")
    password_c.delete!("\0")
psw = password_c
password = ""
l = false
mn = psw[psw.size - 1..psw.size - 1]
mn = mn.to_i
mn += 1
l = false
for i in 0..psw.size - 1 - mn
  if l == true
    l = false
  else
    password += psw[i..i]
    l = true
    end
  end
      password = decrypt(password)
    password = password.gsub("a`","ą")
password = password.gsub("c`","ć")
password = password.gsub("e`","ę")
password = password.gsub("l`","ł")
password = password.gsub("n`","ń")
password = password.gsub("o`","ó")
password = password.gsub("s`","ś")
password = password.gsub("x`","ź")
password = password.gsub("z`","ż")
end
    logintemp = srvproc("login","login=1\&name=#{$name}\&password=#{password}\&version=#{$version.to_s}\&beta=#{$beta.to_s}\&relogin=1")
      $token = logintemp[1]
  $token.delete!("\r\n")
  $name = name
if logintemp[0].to_i < 0
  speech("Błąd, nie mogę się zalogować. Prawdopodobnie podano błędne hasło lub jesteś zbanowany.")
  speech_wait
 $token = nil
 $scene = Scene_Main.new
else
  speech("Operacja zakończona powodzeniem")
  $scene = Scene_Main.new
  end
else
  $scene = Scene_Lodaing.new
end
end
end


def avatar(user)
    avatartemp = srvproc("avatar","name=#{$name}\&token=#{$token}\&searchname=#{user}\&checkonly=1",1)
  case avatartemp.strbyline[0].to_i
  when -4
    speech("Użytkownik nie posiada avatara.")
    speech_wait
    return
    when -2
      speech("Klucz sesji wygasł.")
      speech_wait
      $scene = Scene_Loading.new
      return
      when -1
        speech("Błąd połączenia się z bazą danych.")
        speech_wait
        return
      end
      dialog_open
      speech("Awatar: #{user}")
      speech_wait
      $url+"avatars/"+user
      $dialogvoice.pause
      avatar = AudioFile.new($url+"avatars/"+user)
avatar.play            
      loop do
        loop_update
        break if enter or escape
      end
      avatar.close
      dialog_close
      return
      end    
    def avatar_set(file)
      speech("Proszę czekać, to może potrwać kilka minut...")
                              data = ""
            begin
            data = read(file).urlenc if data == ""
          rescue Exception
            retry
          end
                        data = "avatar="+data
  host = $url.sub("https://","")
  host.delete!("/")
  length = data.size
  q = "POST /avatar_mod.php?name=#{$name}\&token=#{$token} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: #{length}\r\n\r\n#{data}"
a = connect(host,80,q)
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech("Błąd")
    return
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = strbyline(sn)
avt = bt[1].to_i
            speech_wait
            if avt < 0
      speech("Błąd")
    else
      speech("Zapisano")
    end
    speech_wait
    return
  end
  
  def read(file)
    createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(file,1,1|2|4,nil,4,0,0)
if handler < 64
  speech("Błąd.")
  speech_wait
  end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
size = File.size(file)
b = "\0" * (size.to_i+1)
bp = "\0" * (size.to_i+1)
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
bp.delete!("\0")
return b
end

def connect(ip,port,data,len=2048)
    addr = Socket.sockaddr_in(port.to_i, ip)
  sock = Socket.new(2,0,0)
sock.connect(addr).to_s
t = 0
ti = Time.now.to_i
s = false
if data.size <= 1048576
begin
s = sock.send(data) if s == false
rescue Exception
  loop_update
  retry
end
else
  speech("Wysyłanie...")
    places = []
  plc = (data.size / 524288).to_i
for i in 0..plc-1
  places.push(data[i*524288..((i+1)*524288)-1])
end
places.push(data[(plc)*524288..data.size-1])
speech_wait
sent = ""
  for i in 0..places.size-1
                loop_update
        speech(((i.to_f/(plc.to_f+1.0))*100.0).to_i.to_s+"%") if speech_actived == false
                  s = false
  begin
s = sock.send(places[i]) if s == false
sent += places[i]
rescue Exception
  loop_update
  retry
end
end
end
b = ""
t = 0
b = sock.recv(len)
sock.close
return b
end

def buffer_post(data)
  data = "data="+data
  id = rand(2000000000)
  host = $url.sub("https://","")
  host.delete!("/")
  length = data.size
  data
  data.size
  length
  gdata = Zlib::Deflate.deflate(data)
  glength = gdata.size
  q = "POST /buffer_post.php?name=#{$name}\&token=#{$token}&id=#{id.to_s} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: #{length}\r\n\r\n#{data}"
a = connect(host,80,q)
a.delete!("\0")
a
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech("Błąd")
    return
  end
  sn = a[s..a.size - 1]
  a
  sn
  a = nil
        bt = strbyline(sn)
if bt[1].to_i < 0
  speech("Błąd")
  speech_wait
  return
end
return id
end

  def selectcontact
                ct = srvproc("contacts","name=#{$name}\&token=#{$token}")
        err = ct[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      $scene = Scene_Main.new
      return
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        $scene = Scene_Loading.new
        return
      end
      $contact = []
      for i in 1..ct.size - 1
        ct[i].delete!("\n")
      end
      Graphics.update
      for i in 1..ct.size - 1
        $contact.push(ct[i]) if ct[i].size > 1
      end
      if $contact.size < 1
        speech("Pusta Lista")
        speech_wait
      end
      selt = []
      for i in 0..$contact.size - 1
        selt[i] = $contact[i] + ". " + getstatus($contact[i])
        end
      sel = Select.new(selt,true,0,"Wybierz kontakt")
      loop do
loop_update
        sel.update if $contact.size > 0
        if escape
          $focus = true
                    return(nil)
        end
        if enter and $contact.size > 0
          $focus = true
          play("list_select")
                    return($contact[sel.index])
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
              if @index < @fields.size - 1
              @index += 1
            else
              play("border")
            end
          else
            if @index > 0
              @index -= 1
            else
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
                
                def userinfo(user)
                  usrinf = []
                                                      uit = srvproc("userinfo","name=#{$name}\&token=#{$token}\&searchname=#{user}")
                                    if uit[0].to_i < 0
                    speech("Błąd")
                    return -1
                  end
                  if uit[1].to_i > 1000000000 and uit[1].to_i < 2000000000
                    begin                  
                    uitt = Time.at(uit[1].to_i)
                  rescue Exception
                    retry
                    end
                  usrinf[0] = sprintf("%04d-%02d-%02d %02d:%02d",uitt.year,uitt.month,uitt.day,uitt.hour,uitt.min)
                else
                  usrinf[0] = "Konto nie zostało aktywowane."
                  end
                  if uit[2].to_i == 1
                    usrinf[1] = true
                  else
                    usrinf[1] = false
                  end
usrinf[2] = uit[3].to_i
usrinf[3] = uit[4].to_i
fp = srvproc("forum_posts","name=#{$name}\&token=#{$token}\&cat=3\&searchname=#{user}")
if fp[0].to_i == 0
usrinf[4] = fp[1].to_i
end
return usrinf
end

def bufferer(data)
  msg = ""
  msg += $name
  msg += "\r\n"
  msg += $token
  msg += "\r\n"
  bufid = rand(2147483)+1
  msg += bufid.to_s
  msg += "\r\n"
  msg += data.size.to_s
  msg += "\r\n"
  msg += data.to_s
  connect($srv,2431,msg)
  return bufid
end

def delay(time=0)
  if time == 0
  sec = Graphics.frame_rate
  for i in 1..sec.to_f*0.75
    Graphics.update
    break if Win32API.new("user32","GetAsyncKeyState",'i','i').call(0xd) == 0 and Win32API.new("user32","GetAsyncKeyState",'i','i').call(0x20) == 0 and i > 10
  end
  for i in 1..255
    $keyms[i] = 70
    $key[i] = false
    end
  else
  for i in 1..Graphics.frame_rate*time
    Graphics.update
    end
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
      
      def readini(file,group,key,default="\0")
        default = default.to_s if default.is_a?(Integer)
        r = "\0" * 16384
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call(group,key,default,r,r.size,utf8(file))
    r.delete!("\0")
    return r.to_s    
  end
  
  def writeini(file,group,key,value)
    iniw = Win32API.new('kernel32','WritePrivateProfileString','pppp','i')
                iniw.call(group,key,value,file)
              end
              
  def visitingcard(user=$name)
    prtemp = srvproc("getprivileges","name=#{$name}\&token=#{$token}\&searchname=#{user}")
        vc = srvproc("visitingcard","name=#{$name}\&token=#{$token}\&searchname=#{user}")
    err = vc[0].to_i
    case err
    when -1
      speech("Błąd połączenia się z bazą danych.")
      speech_wait
      return -1
      when -2
        speech("Klucz sesji wygasł.")
        speech_wait
        return -2
      end
      dialog_open
      text = ""
if prtemp[1].to_i > 0
  text += "Betatester, "
end
if prtemp[2].to_i > 0
  text += "Moderator, "
end
if prtemp[3].to_i > 0
  text += "Administrator mediów, "
end
if prtemp[4].to_i > 0
  text += "Tłumacz, "
end
if prtemp[5].to_i > 0
  text += "Programista, "
end
text += "Użytkownik: #{user} \r\n"
text += getstatus(user)
text += "\r\n"
pr = srvproc("profile","name=#{$name}\&token=#{$token}\&get=1\&searchname=#{user}")
fullname = ""
gender = -1
birthdateyear = 0
birthdatemonth = 0
birthdateday = 0
location = ""
if pr[0].to_i == 0
  fullname = pr[1].delete("\r\n")
        gender = pr[2].delete("\r\n").to_i
        birthdateyear = pr[3].delete("\r\n")
        birthdatemonth = pr[4].delete("\r\n")
        birthdateday = pr[5].delete("\r\n")
        location = pr[6].delete("\r\n")
        text += fullname+"\r\n"
        text+="Płeć: "
        if gender == 0
          text += "kobieta\r\n"
        else
          text += "mężczyzna\r\n"
        end
        age = Time.now.year-birthdateyear.to_i
if Time.now.month < birthdatemonth.to_i
  age -= 1
elsif Time.now.month == birthdatemonth.to_i
  if Time.now.day < birthdateday.to_i
    age -= 1
    end
  end
  age -= 2000 if age > 2000      
  text += "Wiek: #{age.to_s}\r\n"
  end
  ui = userinfo(user)
if ui != -1
if gender == -1
  text += "Widzian(y/a): "
elsif gender == 0
  text += "Widziana: "
elsif gender == 1
  text += "Widziany: "
  end
text+= ui[0] + "\r\n"
text += "Użytkownik "
text += "nie " if ui[1] == false
text += "posiada bloga.\r\n"
text += "Zna użytkowników: " + ui[2].to_s + "\r\n"
if gender == -1
text += "Znan(y/a)"
elsif gender == 0
  text += "Znana"
elsif gender == 1
  text += "Znany"
end
text += " przez użytkowników: " + ui[3].to_s + "\r\n"
text += "Wpisy na forum: " + ui[4].to_s + "\r\n"
end
text += "\r\n\r\n"
      for i in 1..vc.size - 1
        text += vc[i]
      end
      inptr = Edit.new("Wizytówka: #{user}","READONLY|MULTILINE",text)
      loop do
        loop_update
        inptr.update
        break if escape
      end
      loop_update
      $focus = true if $scene.is_a?(Scene_Main) == false
      dialog_close
      return 0
    end
    
    def asendfile(file)
      fl = read(file)
      msg = "#{$name}\r\n#{$token}\r\n#{fl.size.to_s}\r\n#{fl}"
      filedir = false
      begin
        filedir = connect($srv,2442,msg) if filedir == false
      rescue SystemExit
        Graphics.update
        retry
      end
return filedir
end

def speedtest
    tm = Time.now
startms = tm.usec
starts = tm.to_i
  i = srvproc("active","name=#{$name}\&token=#{$token}")
  tm = Time.now
  stopms = tm.usec
  stops = tm.to_i
time = -1
    time = (stopms - startms) / 1000
    time = 1000 - time if time < 0
    time += (stops - starts)*1000
  speech("Czas potwierdzenia sesji: #{time.to_s} milisekund.")
    speech_wait
return time
end

def strbyline(str)
  byline = []
  index = 0
  byline[index] = ""
  for i in 0..str.size - 1
    if str[i..i] != "\n" and str[i..i] != "\r"
    byline[index] += str[i..i]
  elsif str[i..i] == "\n"
    index += 1
    byline[index] = ""
    end
  end
  return byline
end

def readfile(file,maxsize=1048576)
createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(utf8(file),1,1|2|4,nil,4,0,0)
if handler < 64
raise(RuntimeError)
end
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
b = "\0" * maxsize
bp = "\0" * maxsize
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
b.rdelete!("\0")
bp.delete!("\0")
return b
end

def user_exist(usr)
  ut = srvproc("user_exist","name=#{$name}\&token=#{$token}\&searchname=#{usr}")
    if ut[0].to_i < 0
    speech("Błąd")
    speech_wait
    return false
  end
  ret = false
  ret = true if ut[1].to_i == 1
  return ret
end

def getdirectory(type)
  dr = "\0" * 1024
  Win32API.new("shell32","SHGetFolderPath",'iiiip','i').call(0,type,0,0,dr)
  dr.delete!("\0")
  return futf8(dr)
end

def preproc(string,dir=".")
  cdc = string.strbyline
for i in 0..cdc.size - 1
  if cdc[i].size > 0
    if cdc[i][0..8] == "#include "
      fl = cdc[i][9..cdc[i].size-1].delete("\r\n")
      if FileTest.exists?(fl) or FileTest.exists?(dir+"/"+fl)
        a = IO.readlines(fl) if FileTest.exists?(fl)
        a = IO.readlines(dir+"/"+fl) if FileTest.exists?(dir+"/"+fl)
        b = ""
        for j in 0..a.size-1
          b += a[j]
          end
        c = preproc(b,dir)
                cdc[i] = c
        end
      end
    if cdc[i][0..0] == "*"
    s = ""
    a = 0
    for j in 1..cdc[i].size-1
      s += cdc[i][j..j] if cdc[i][j..j] != " "
      a += 1
      break if cdc[i][j..j] == " "
          end
    if eval("defined?(#{s})") != nil
      prm = ""
      for j in a+1..cdc[i].size-1
        prm += cdc[i][j..j]
      end
      prm.gsub!("\"","\\\"")
      cdc[i] = "#{s}(\"#{prm}\")"
      end
    end
  end
  end
    r = ""
for i in 0..cdc.size - 1
    r += cdc[i] + "\r\n"
end
return r
  end

  def codeeval(string , binding , filename ,lineno)  
  eval(string , binding , filename ,lineno)
end

def versioninfo
  download($url + "/bin/elten.ini",$bindata + "\\newest.ini")
        nversion = "\0" * 16
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Elten","Version","0",nversion,nversion.size,$bindata + "\\newest.ini")
    nversion.delete!("\0")
    nversion = nversion.to_f
            nbeta = "\0" * 16
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Elten","Beta","0",nbeta,nbeta.size,$bindata + "\\newest.ini")
    nbeta.delete!("\0")
    nbeta = nbeta.to_i
        $nbeta = nbeta
    $nversion = nversion
    if $nversion > $version or $nbeta > $beta
      $scene = Scene_Update_Confirmation.new
    else
      speech("Brak dostępnych aktualizacji.")
      speech_wait
    end
  end
  
  def srvproc(mod,param,output=0)
    url = $url + mod + ".php?" + hexspecial(param)
        return ["-1"] if download(url,"tmp") != 0
        case output
    when 0
    r = IO.readlines("tmp")
    when 1
      r = read("tmp")
      when 2
        r = readlines("tmp")
      end
    File.delete("tmp") if $DEBUG == false
            return r
          end
          
          def hexspecial(t)
            if $interface_hexspecial == 1
            t = t.gsub("ą","%C4%85")
            t = t.gsub("ć","%C4%87")
            t = t.gsub("ę","%C4%99")
            t = t.gsub("ł","%C5%82")
            t = t.gsub("ń","%C5%84")
            t = t.gsub("ó","%C3%B3")
            t = t.gsub("ś","%C5%9B")
            t = t.gsub("ź","%C5%BA")
            t = t.gsub("ż","%C5%BC")
            t = t.gsub("Ą","%C4%84")
            t = t.gsub("Ć","%C4%86")
            t = t.gsub("Ę","%C4%98")
            t = t.gsub("Ł","%C5%81")
            t = t.gsub("Ń","%C5%83")
            t = t.gsub("Ó","%C3%B2")
            t = t.gsub("Ś","%C5%9A")
            t = t.gsub("Ź","%C5%B9")
            t = t.gsub("Ż","%C5%BB")
            end
            return t
          end
          
          def hexstring(stri)
            stro = ""
t = 0
            for i in 0..stri.size-1
              t = t + 1
              if t > 10000
                loop_update
                play("list_focus")
                t = 0
                end
              stro += "%" + stri[i].to_s(16)
              end
            return stro
          end
          
          def hexsendfile(file)
            str = read(file)
            play("list_focus")
            loop_update
                        s = str.urlenc
                        play("list_focus")
                        loop_update
                                                return buffer_post(s)
                                              end
                                            
                                              
                               def signature(user)
                                 sg = srvproc("signature","name=#{$name}\&token=#{$token}\&get=1\&searchname=#{user}")
                                 if sg[0].to_i < 0
                                   speech("Błąd")
                                   speech_wait
                                   return ""
                                 end
                                 text = ""
                                                                  for i in 1..sg.size-1
                                   text += sg[i]
                                 end
                                 return "" if text.size < 4                                 
                                 return text.gsub("\004LINE\004","\r\n").chop.chop
                               end
                               
                               def sendfile(file)
      speech("Proszę czekać, to może potrwać kilka minut...")
                              data = ""
            begin
            data = read(file).urlenc if data == ""
          rescue Exception
            retry
          end
                        data = "data="+data
  host = $url.sub("https://","")
  host.delete!("/")
  length = data.size
  q = "POST /uploads_mod.php?add=1\&filename=#{File.basename(file).urlenc}\&name=#{$name}\&token=#{$token} HTTP/1.1\r\nHost: #{host}\r\nUser-Agent: Elten #{$version.to_s}\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: pl,en-US;q=0.7,en;q=0.3\r\nAccept-Encoding: identity\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: #{length}\r\n\r\n#{data}"
a = connect(host,80,q)
a.delete!("\0")
for i in 0..a.size - 1
  if a[i..i+3] == "\r\n\r\n"
    s = i+4
    break
    end
  end
  if s == nil
    speech("Błąd")
    return nil
  end
  sn = a[s..a.size - 1]
  a = nil
        bt = strbyline(sn)
err = bt[0].to_i
            speech_wait
                        if err < 0
      speech("Błąd")
    speech_wait
      else
      return bt[1].delete("\r\n")
    end
        return nil
      end
  
    class Reset < Exception

    end
    
    module EltenAPI
    end
    
    def license(omit=false)
if $language == "PL_PL"
    @license = "Elten

Regulamin użytkowania oraz umowa licencyjna

Poniższe warunki są umową licencyjną oprogramowania Elten oraz sieci Elten Network.
Użytkownicy programu zobowiązują się do przestrzegania poniższych postanowień lub zaprzestania użytkowania programu.

I. Postanowienia ogólne
1. Autorem programu jest Dawid Pieper. Jest właścicielem zarówno oprogramowania, jak i danych i to on udziela licencji na użytkowanie aplikacji, jak długo Elten jest przez niego wspierany.
2. Elten jest oprogramowaniem o otwartym kodzie źródłowym (Open-Source) podlegającym pod licencjonowanie Open Public License. Zabrania się tworzenia niezależnych od Eltena dystrybucji i kopii, jak długo Elten jest wspierany przez autora. Zabrania się również jakiegokolwiek celowego szkodliwego działania na rzecz serwera, zarówno w sposób pośredni, jak i bezpośredni.
3. Wszelkie testy bezpieczeństwa, głównie testy penetracyjne, są dozwolone za poinformowaniem autora o ich przeprowadzaniu oraz o ich wynikach. Zabrania się wykorzystywania jakichkolwiek odnalezionych błędów w zabezpieczeniach.
4. Elten może być rozwijany przez każdego programistę, jednak żadna z dopisanych funkcji nie może szkodzić użytkownikom lub ich prywatności. Nowe zmiany ostatecznie zatwierdza lub odrzuca autor programu.
5. Użytkownicy publikujący swoje prace w serwisie pozostają autorami tych prac, nie zrzekają się praw własności ani praw autorskich na żadnego z innych użytkowników ani autora. Dają jednak autorowi prawo do dystrybuowania tych prac w celu możliwości umieszczania ich na łamach portalu Elten.

II. Rejestracje
1. Użytkownikiem Eltena może zostać każda osoba, która ukończyła trzynasty rok życia.
2. Autor lub moderacja mogą nie udzielić zgody na rejestrację w szczególnych wypadkach, gdy rada starszych programu uzna, że osoba chcąca się zarejestrować nie ma prawa do dokonania tej czynności.
3. W przypadku łamania postanowień niniejszego regulaminu, użytkownik może zostać pozbawiony (okresowo lub trwale) dostępu do swojego konta. Decyzję o tym podejmują moderatorzy lub autor.
4. Podanie prawdziwego adresu e-mail jest obowiązkowe. W szczególnych wypadkach może on zostać użyty w celu weryfikacji tożsamości użytkownika.

III. Blogi i prywatne wiadomości
1. Zarówno blogi, jak i prywatne wiadomości należą do użytkownika.
2. Nie mniej jednak, za obrażanie społeczności poprzez wysyłanie do nieznanych ludzi masowych wiadomości o charakterze obraźliwym będzie karane.
3. Autor programu nie ponosi odpowiedzialności za treści umieszczane na blogach i w prywatnych wiadomościach.

IV. Forum
1. Na forum należy przestrzegać zasad netykiety. Zabrania się wyzywania czy  obrażania innych użytkowników, jak również nadużywania określeń uważanych powszechnie za wulgarne.
2. Każdy na forum ma prawo do własnego zdania w danych kwestiach.
3. Za utrzymanie porządku na forum odpowiadają moderatorzy, mając prawo do:
A. Ostrzegania użytkownika,
B. Usuwania wątków lub wpisów stojących w niezgodzie z niniejszym regulaminem,
C. Przenoszenia wpisów,
D. W szczególnych wypadkach, gdy uznana zostanie taka konieczność, edycji wpisów,
E. Pozbawiania użytkownika dostępu do jego konta.
4. Moderatorzy mają prawo do edycji wpisów w ypadku:
A. Niecelowego ujawnienia danych prywatnych innych osób bez zgody tych osób, na wniosek osoby poszkodowanej,
B. W wypadku wątków o specyficznym sposobie lub zakresie wypowiedzi, w celu dostosowania wpisu do szablonu lub charakteru wątku.
5. Użytkownik, umieszczając daną treść na forum, oświadcza, że ma prawo do jej publikacji.
6. Na forum należy przestrzegać zasad ułatwiających łatwe przeglądanie wpisów, unikać mieszania tematów, zakładania ich na niewłaściwych forach lub tworzenia tematów odbiegających całkowicie od zadanego tytułu.

V. Rada starszych
1. Użytkownik otrzymuje lub zostaje pozbawiony specjalnych praw przez autora programu.
2. Należenie do rady starszych nie zwalnia z obowiązku przestrzegania niniejszego regulaminu.
3. Użytkownik może otrzymać następujące tytuły w radzie starszych:
A. Betatester,
B. Moderator,
C. Tłumacz,
D. Administrator mediów,
E. Programista.
4. W przypadku braku aktywności w programie lub w pełnionej funkcji, użytkownik zostaje pozbawiony członkowstwa w radzie.
5. Niezależnie od rady starszych, użytkownicy mogą otrzymać tytuły specjalne, honorowe, za różnego rodzaju działalność. Tytuły te są nadawane w celu odznaczenia danego osiągnięcia użytkownika. O nadanie takiego tytułu dla siebie lub innych użytkowników może wnioskować każdy użytkownik.
6. Lista tytułów specjalnych jest ustalana przez autora.
7. Zabrania się nadużywania lub przekraczania swoich uprawnień w radzie starszych.

VI. Udostępniane pliki (w tym awatary)
1. Za udostępniane przez siebie pliki odpowiedzialny jest każdy udostępniający je użytkownik.
2. Zabrania się udostępniania materiałów szkodliwych lub potencjalnie niechcianego oprogramowania, jeśli nie jest charakter pliku podkreślony w nazwie, a plik nie jest wysyłany w celach analizy lub szkolenia.
3. Zabrania się celowego wysyłania dużej ilości plików w celach wyczerpania miejsca na serwerze.

VII. Pozostałe
1. W wypadku nie uwzględnienia danej sytuacji w tym regulaminie, decyzję o poprawności lub niepoprawności czynu podejmuje autor.
2. Użytkownik korzystający z programu oświadcza, że zna i rozumie niniejszy regulamin.
3. Dowolny użytkownik może zgłosić niejasność lub wątpliwość co do poprawności dowolnego punktu w niniejszym regulaminie.
4. Autor ma prawo w każdej chwili zmienić lub anulować regulamin."
else
  @license = "Elten terms of use and license agreement the following terms are software license agreement of Elten and Elten Network.

I. General
1. Dawid Pieper is The author of the program and the owner of both the software and the data. He grants you a license to use this application, as long as Elten is supported by him.
2. Elten is an open source software licensed under Open Public License. It is forbidden to create independent distribution and copies of Elten, as long as Elten is supported by the developer. Also any deliberate malicious action on the server, both indirectly and directly, are forbidden.
3. any safety tests, mainly penetration tests, are allowed, but the condition is to inform the author of their carrying out and about their results. It is prohibited to use any found errors.
4. the Elten can be developed by any programmer, however, none of the written-in feature may not harm the users or their privacy. The new changes ultimately approves or rejects the author of the program.
5. Users publishing their work are the authors of these works, do not waive any ownership or copyrights on any of the other users or the author. However, they give to the author the right to distribute these works in order to place them on the sites of Portal Elten.

II. Registration
1. Elten user can be any person who is thirteenth years old or older.
2. the author or moderation may refuse the registration request in special occassions.
3. in the case of breaches of the provisions of these terms, the user can be deprived (temporarily or permanently) of access his/her account. The decision shall be taken the moderators or the author.
4. Entering a real e-mail address is required. In special cases, it may be used to verify the identity of the user.

III. the Blogs and private messaging
1. Both blogs, and private messages belong to the user writing them.
2. Sending to unknown people mass offensive messages will be punished.
3. the Author is not responsible for the content posted on the blogs and in private messages.

IV. The Forum
1. The users have to follow the rules of Netiquette. It is forbidden to insult other users, as well as abuse of the words that are vulgar.
2. Everyone has the right to his/her own opinion.
3. Moderators have rights to:
A. Warning the user,
B. Removing threads or posts standing in conflict with these terms and conditions,
C. Moving posts,
D. In special cases, when considered as necessary, edit posts,
E. Ban users.
4. the Moderators have the right to edit entries, when:
A. Disclosure of the private data of other people without their consent, at the request of the injured person,
B. In special threads where posts must be adapted to common templates.
5. the user by placing the content on the forum, declares that he/she has the right to publicate it.

V. Administration
1. The user receive or is deprived of special rights by the author of the program.
2. the Belongings to the administration does not release from the obligation to comply with these terms.
3. the user may receive the following titles:
A. Betatester
B. Moderator,
C. Translator,
D. Media Administrator,
E. Developer.

VI. Other
1. In the case do not take in these terms and conditions, the decision about the correctness or incorrectness of an act takes the author.
2. User declares that he/she knows and understands these terms and conditions.
3. Any user may report the ambiguity or doubt as to the correctness of any point in these terms and conditions.
4. the author shall have the right at any time to change or cancel the terms and conditions."
end
form = Form.new([Edit.new("Umowa licencyjna oraz regulamin użytkowania programu Elten oraz sieci Elten Network","MULTILINE|READONLY",@license,true),Button.new("Akceptuję"),Button.new("Nie akceptuję, zamknij program")])
loop do
  loop_update
  form.update
  if (enter or space) and form.index == 2
    exit
  end
  if (space or enter) and form.index == 1
    break
  end
  if escape
    if omit == true
      break
      else
    q = simplequestion("Czy akceptujesz umowę licencyjną oprogramowania Elten?")
    if q == 0
      exit
    else
      break
      end
    end
    end
  end
  end
#Copyright (C) 2014-2016 Dawid Pieper