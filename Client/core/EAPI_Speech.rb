#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

# encoding: utf-8
module EltenAPI
  # Speech related functions
  module Speech
  # Says a text
  #
  # @param text [String] a text to speak
  # @param method [Numeric] 0 - wait for the previous message to say, 1 - abord the previous message, 2 - use synthesizer config
    def speech(text,method=1,usedict=true)
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
  text.encode!(Encoding::UTF_8) if $ruby == true
  rx=/\004AUDIO\004([A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+]+)\004AUDIO\004/
  txt=text+""  
  txt.gsub(rx) do
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
  if text.size!=0
  if text.size==1 or (text.size<=2 and text[0]>100)
    if text[0..0].bigletter or text[0..1].bigletter
      play("edit_bigletter")
      end
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
      $speechaudio.close if $speechaudio!=nil
      speechaudio=Bass::Sound.new($speechaudiofile)    
      $speechaudiothread=Thread.new do
             $speechaudiofile            
                                                                                                    if true
                                                  $speechaudio.close if $speechaudio!=nil and $speechaudio.closed==false
                         $speechaudio=speechaudio
      while speech_actived(true)
        sleep(0.01)
        end
      speechaudio.play
              speechaudio.wait
                              speechaudio.close
                          $speechaudio=nil
        speech(text)
        end
      end
      return
    end
  if text != ""
        text = dict(char_dict(text)) if text.split("").size==1
  text = dict(text) if $language != "PL_PL" and $language != nil and usedict==true
  text = text.gsub("_"," ")
text.gsub(/\004INFNEW\{([a-zA-Z0-9 \-\/:_=.,]+)\}\004/) {
text=($1+" "+text).gsub(/\004INFNEW\{([a-zA-Z0-9 \-\/:_=.,]+)\}\004/,"\004NEW\004")
}
  text.gsub!("\004NEW\004") {
  play("list_new")
  ""
  }
  text.gsub!("\004ATTACHMENT\004") {
  play("list_attachment")
  ""
  }
  polecenie = "sapiSayString"
polecenie = "sayString" if $voice == -1
text_d = text
text_d = utf8(text) if $speech_to_utf == true
$speech_lasttext = text_d
text_d.gsub!("\r\n\r\n","\004SLINE\004")
text_d.gsub!("\r\n"," ")
text_d.gsub!("\004SLINE\004","\r\n\r\n")
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

# Determines if the speech is used
#
# @param ignoreaudio [Boolean] ignores the played speechaudio
# @return [Boolean] if the speech is ued, returns true, otherwise the return value is false
def speech_actived(ignoreaudio=false)
    polecenie = "sapiIsSpeaking"
        return true if $speechaudio!=nil and ignoreaudio==false
  if Win32API.new("screenreaderapi",polecenie,'','i').call() == 0
    return(false)
  else
    return(true)
  end
  end

  # Stops the speech
  def speech_stop
    if $speechaudio!=nil
    $speechaudiothread.kill if $speechaudiothread!=nil
    $speechaudio.close
    $speechaudio=nil
    end
    polecenie = "sapiStopSpeech"
    polecenie = "stopSpeech" if $voice == -1
    Win32API.new("screenreaderapi",polecenie,'','i').call()
  end
  
  # Waits for a speech to finish reading of the previous message
      def speech_wait
    while speech_actived == true
loop_update
end
  $speech_waiter = true if $voice == -1
  return
end

# Returns the character dictionary name
#
# @param text [String] a character you want to search dictionary for
# @return [String] a dictionary name of the character
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
              r="lewy kwadratowy"
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
                                                                when "ü"
                                                                                                                                    r="u umlaut" if $language=="PL_PL"
                                                                  when "Ü"
                                                                    r="U umlaut" if $language=="PL_PL"
                                                                    when "ä"
                                                                      r="a umlaut" if $language=="PL_PL"
                                                                      when "Ä"
                                                                 r="A umlaut" if $language=="PL_PL"       
                                                                 when "ö"
                                                                   r="o umlaut" if $language=="PL_PL"
                                                                   when "Ö"
                                                                     r="O umlaut" if $language=="PL_PL"
when "ß"
                                                                     r="długie s" if $language=="PL_PL"
                                                                     when "´"
                                                                     r="ostry akcent" if $language=="PL_PL"
                                                                                         end
                      if r==""
                        return(text)
                      else
                        return(r)
                        end
                      end
                      
                      # Toggles the speech pause
     def speech_togglepause
  if Win32API.new("screenreaderAPI","sapiIsPaused",'','i').call==0
  Win32API.new("screenreaderAPI","sapiSetPaused",'i','i').call(1)
    else
  Win32API.new("screenreaderAPI","sapiSetPaused",'i','i').call(0)
  end
  end

  # Searches the translation dictionary for a message
  #
  # @param text [String] a text to search for
  # @return [String] the dictionary translation of the text, if none found, the original text is returned
  def dict(text)
  text="" if text==nil
  return text if $language == nil or $language == "PL_PL"
  for i in 0..$lang_src.size-1
    src=$lang_src[i]
    if src==text or src.include?("%%")
    dst=$lang_dst[i].delete("\r\n")
    re=Regexp.new(src.gsub("(","\\(").gsub(")","\\)").gsub("%%",""))
                text=text.gsub(re,dst.sub("%%",$1.to_s).sub("%%",$2.to_s).sub("%%",$3.to_s).sub("%%",$4.to_s).sub("%%",$5.to_s))
          end
          end
return text
  text = "" if text == nil
  if $lang_src != nil and $lang_dst != nil
for i in 3..$lang_src.size - 1
  if $lang_src[i] == text
    r = $lang_dst[i]
    r.chop! if r[r.size-1..r.size-1]=="\n"
    r.chop! if r[r.size-1..r.size-1]=="\r"
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
text.delete!("\r")
return(text)
end                   
end
end
#Copyright (C) 2014-2016 Dawid Pieper