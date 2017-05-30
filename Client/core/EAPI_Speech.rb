#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module Speech
  def speech(text,method=1)
        if $speech_waiter==true
      method=0
      $speech_waiter=false
      end
  Win32API.new("screenreaderAPI","sapiSetPaused",'i','i').call(0) if text!=nil and text!="" and method!=0
  if $speech_wait == true
    speech_wait
    $speech_wait = false
    end
  text = text.to_s
  speechaudio  =""
  text = text.gsub("\004LINE\004") {"\r\n"}
pre=""
prei=0
  text.gsub(/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/) do
  pre=""
      prei=0
      for i in 0..text.size-1
        pre+=text[i..i] if text[i..i+6]!="\004AUDIO\004"
        prei=i-1
        break if text[i..i+6]=="\004AUDIO\004"
      end
      speech(pre)
      for i in 0..prei
        text[i]=0
      end
      text.delete!("\0")  
  end
      text.gsub!(/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/) do
        s=$1
                                if s[0..0]=="/"
   s[0]=0
   s.delete!("\0")
   s=$url+s
            end
        if FileTest.exists?(s) or s[0..3].downcase=="http"
        speechaudio=s.to_s
      end
      ""
      end
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
    return if speechaudio==""
  end
  if text == "\n"
    play("edit_endofline")
    return if speechaudio==""
  end
  if text.size == 1
    if text[0..0].bigletter  or text[0..1].bigletter
      play("edit_bigletter")
      end
    end
  if $password == true
    speech_stop
    play("edit_password_char")
    return
  end
    if speechaudio!=""
      $speechaudiofile=speechaudio
  $speechaudiotext=text
      if $speechaudio!=nil
      $speechaudiothread.kill if $speechaudiothread!=nil
      $speechaudio.close
      end
          $speechaudiothread=Thread.new do
             $speechaudiofile            
            $speechaudio=AudioFile.new($speechaudiofile)
      while speech_actived(true)
        sleep(0.01)
        end
      $speechaudio.play
      loop do
        pos=$speechaudio.position
        sleep(0.1)
        if $speechaudio.position==pos and $speechaudio.playing? == true
          $speechaudio.close
          break
          end
        end
        $speechaudio=nil
        speech(text)
      end
      return
    end
  if text != ""
  text = char_dict(text)
  text = dict(text) if $language != "PL_PL" and $language != nil
  text = text.gsub("_"," ")
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
if text.size>=5
  if Thread::current==$mainthread
if $speechaudiothread!=nil
  $speechaudiothread.kill
  if $speechaudio!=nil
    if $speechaudio.closed==false
  $speechaudio.close
end
end
end
end
  sleep(0.02)
Win32API.new("screenreaderapi","sapiSayString",'pi','i').call(" ",1) if $voice == -1
end
end
text_d = text if text_d == nil
return text_d
end

def speech_actived(ignoreaudio=false)
  polecenie = "sapiIsSpeaking"
    #if $voice != -1
    return true if $speechaudio!=nil and ignoreaudio==false
  if Win32API.new("screenreaderapi",polecenie,'v','i').call() == 0
    return(false)
  else
    return(true)
  end
#else
  #i = 0
  #loop do
    #i += 1
   #Graphics.update
   #Input.update
   #key_update
   #break if $key[0x11] or i > $speech_lasttext.size * 5
 #end
  #return false
  #end
  end
  
  def speech_stop
    if $speechaudio!=nil
    $speechaudiothread.kill if $speechaudiothread!=nil
    $speechaudio.close
    $speechaudio=nil
    end
    polecenie = "sapiStopSpeech"
    polecenie = "stopSpeech" if $voice == -1
    Win32API.new("screenreaderapi",polecenie,'v','i').call()
  end
      def speech_wait
  #if $voice >= 0
  while speech_actived == true
loop_update
end
#else
  #speech_actived
  #end
  $speech_waiter = true if $voice == -1
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
     def speech_togglepause
  if Win32API.new("screenreaderAPI","sapiIsPaused",'v','i').call==0
  Win32API.new("screenreaderAPI","sapiSetPaused",'i','i').call(1)
    else
  Win32API.new("screenreaderAPI","sapiSetPaused",'i','i').call(0)
  end
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
end
end
#Copyright (C) 2014-2016 Dawid Pieper