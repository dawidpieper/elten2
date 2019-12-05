#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

# encoding: utf-8
module EltenAPI
  # Speech related functions
  module Speech
    
    def alert(text, wait=true)
      speak(text)
      NVDA.braille_alert(text) if NVDA.check
      speech_wait if wait
      end
    
      # Says a text
  #
  # @param text [String] a text to speak
  # @param method [Numeric] 0 - wait for the previous message to say, 1 - abord the previous message, 2 - use synthesizer config
    def speak(text,method=1,usedict=true,id=nil,closethr=true)
      if closethr and $speechindexedthr!=nil
        $speechindexedthr.exit
        $speechindexedthr=nil
        end
      id=rand(2**32) if id==nil
      $speechid=id
      swait=false
                  if $speech_wait==true
      method=0
      $speech_wait=false
      swait=true
      speech_wait if $voice!=-1
    end
            Win32API.new("bin\\screenreaderapi","sapiSetPaused",'i','i').call(0) if text!=nil and text!="" and method!=0
          if $speechaudio!=nil
    $speechaudiothread.kill if $speechaudiothread!=nil
    $speechaudio.close
    $speechaudio=nil
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
    speak(_("EAPI_Speech:chr_space"))
    end
    return if speechaudio==""
  end
  if text == "\n"
    play("edit_endofline")
    return if speechaudio==""
  end
  if text.size!=0
      if ((l=text.split("")).size==1) and l[0].bigletter
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
        text = char_dict(text) if text.split("").size==1
    text = text.gsub("_"," ")
text.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
text=((($interface_soundthemeactivation==1)?"":($1+" "))+text).gsub(/\004INFNEW\{([^\}]+)\}\004/,"\004NEW\004")
}
  text.gsub!("\004NEW\004") {
  play("list_new")
  ""
  }
  text.gsub!("\004CLOSED\004") {
  play("list_closed")
  ""
  }
  text.gsub!("\004PINNED\004") {
  play("list_pinned")
  ""
  }
  text.gsub!("\004ATTACHMENT\004") {
  play("list_attachment")
  ""
  }
  func = "sapiSayString"
func = "sayString" if $voice == -1
text_d = text
text_d.gsub!("\r\n\r\n","\004SLINE\004")
text_d.gsub!("\r\n"," ")
text_d.gsub!("\004SLINE\004","\r\n\r\n")
if $voice==-1 && NVDA.check
  NVDA.stop   if !swait
  NVDA.speak(text_d)
                    else
buf=unicode(text_d)
            Win32API.new("bin\\screenreaderapi",func+"W",'pi','i').call(buf,method) if $password != true
end
$speech_lasttext = text_d
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
Win32API.new("bin\\screenreaderapi","sapiSayString",'pi','i').call(" ",1) if $voice == -1
end
end
text_d = text if text_d == nil
return text_d
end

alias speech speak

# Determines if the speech is used
#
# @param ignoreaudio [Boolean] ignores the played speechaudio
# @return [Boolean] if the speech is ued, returns true, otherwise the return value is false
def speech_actived(ignoreaudio=false)
    func = "sapiIsSpeaking"
        return true if $speechaudio!=nil and ignoreaudio==false
          if Win32API.new("bin\\screenreaderapi",func,'','i').call() == 0
    return(false)
  else
    return(true)
  end
  end

  # Stops the speech
  def speech_stop(audio=true)
        $speech_wait=false
    if $speechaudio!=nil and audio
    $speechaudiothread.exit if $speechaudiothread!=nil
    $speechaudio.close
    $speechaudio=nil
  end
      if $speechindexedthr!=nil
      $speechindexedthr.exit
      $speechindexedthr=nil
      end
    func = "sapiStopSpeech"
    if $voice==-1
    func = "stopSpeech"
    if $voice==-1 && NVDA.check
      NVDA.stop
      return
      end
        end
    Win32API.new("bin\\screenreaderapi",func,'','i').call()
  end
  
  # Waits for a speech to finish reading of the previous message
      def speech_wait
        if $voice!=-1
    while speech_actived == true
loop_update
end
else
  $speech_wait = true
  end
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
    r=_("EAPI_Speech:chr_dot")
    when ","
      r=_("EAPI_Speech:chr_comma")
      when "/"
        r=_("EAPI_Speech:chr_slash")
        when ";"
          r=_("EAPI_Speech:chr_semi")
          when "'"
            r=_("EAPI_Speech:chr_tick")
            when "["
              r=_("EAPI_Speech:chr_leftbracket")
              when "]"
                r=_("EAPI_Speech:chr_rightbracket")
                when "\\"
                  r=_("EAPI_Speech:chr_backslash")
                  when "-"
                    r=_("EAPI_Speech:chr_minus")
                    when "="
                      r=_("EAPI_Speech:chr_equals")
                      when "`"
                        r=_("EAPI_Speech:chr_accent")
                        when "<"
                          r=_("EAPI_Speech:chr_less")
                          when ">"
                            r=_("EAPI_Speech:chr_greater")
                            when "?"
                              r=_("EAPI_Speech:chr_question")
                              when ":"
                                r=_("EAPI_Speech:chr_colon")
                                when "\""
                                  r=_("EAPI_Speech:chr_quote")
                                  when "{"
                                    r=_("EAPI_Speech:chr_leftbrace")
                                    when "}"
                                      r=_("EAPI_Speech:chr_rightbrace")
                                      when "|"
                                        r=_("EAPI_Speech:chr_bar")
                                        when "_"
                                          r=_("EAPI_Speech:chr_underline")
                                          when "+"
                                            r=_("EAPI_Speech:chr_plus")
                                            when "!"
                                              r=_("EAPI_Speech:chr_exclamation")
                                              when "@"
                                                r=_("EAPI_Speech:chr_at")
                                                when "#"
                                                  r=_("EAPI_Speech:chr_hash")
                                                  when "$"
                                                    r=_("EAPI_Speech:chr_dollar")
                                                    when "%"
                                                      r=_("EAPI_Speech:chr_percent")
                                                      when "^"
                                                        r=_("EAPI_Speech:chr_caret")
                                                        when "\&"
                                                          r=_("EAPI_Speech:chr_and")
                                                          when "*"
                                                            r=_("EAPI_Speech:chr_star")
                                                            when "("
                                                              r=_("EAPI_Speech:chr_leftparen")
                                                              when ")"
                                                                r=_("EAPI_Speech:chr_rightparen")
                                                                when "ü"
                                                                                                                                    r="u umlaut" if $language=="pl_PL"
                                                                  when "Ü"
                                                                    r="U umlaut" if $language=="pl_PL"
                                                                    when "ä"
                                                                      r="a umlaut" if $language=="pl_PL"
                                                                      when "Ä"
                                                                 r="A umlaut" if $language=="pl_PL"
                                                                 when "ö"
                                                                   r="o umlaut" if $language=="pl_PL"
                                                                   when "Ö"
                                                                     r="O umlaut" if $language=="pl_PL"
when "ß"
                                                                     r="długie s" if $language=="pl_PL"
                                                                     when "´"
                                                                     r="ostry akcent" if $language=="pl_PL"
                                                                                         end
                      if r==""
                        return(text)
                      else
                        return(r)
                        end
                      end
                      
                      # Toggles the speech pause
     def speech_togglepause
  if Win32API.new("bin\\screenreaderapi","sapiIsPaused",'','i').call==0
  Win32API.new("bin\\screenreaderapi","sapiSetPaused",'i','i').call(1)
    else
  Win32API.new("bin\\screenreaderapi","sapiSetPaused",'i','i').call(0)
  end
  end

  def speak_indexed(h,id=nil)
    id=rand(10**24) if id==nil
    $speechindexedthr.exit if $speechindexedthr!=nil
        return if !h.is_a?(Hash)
    if $voice==-1 && !NVDA.check
      txt=""
      h.keys.sort.each {|i| txt+=h[i]+"\r\n"}
      return speak(txt)
    end
    if $voice==-1
            $speechindexedthr=Thread.new do
                  NVDA.stop if !$speech_wait
                  stp=10+rand(100)
                                                        texts=[]
      indexes=[]
      h.keys.sort.each {|k|
      texts.push(h[k])
      indexes.push(k+stp)
      }
            NVDA.speakindexed(texts, indexes, id)
              sleep(0.01) until NVDA.getindex[1]==id
            loop {
      ind,indid=NVDA.getindex
            $speechid=indid
      break if indid!=id || (ind||0)<stp || (id!=nil && $speechid!=id)
      $speechindex=ind-stp
      sleep(0.1)
      }
    sleep(1)
      play 'signal'
      $speechindexedthr=nil
          end
    return
      end
        speech_stop
            $speechindex=nil
    $speechindexedthr=Thread.new {
    lst=""
    h.keys.sort.each {|i|
        next if h[i]=="\n" or h[i]==" "
    $speechindex=i
    lc=""
    for j in 1..(lst.size)
      lc=lst[(lst.size-j)..(lst.size-j)]
      break if lc!="\r" and lc!="\n" and lc!=" "
    end
    if lc=="."
      sleep(0.25)
    elsif "\"-,)".include?(lc)
      sleep(0.05)
      end
      lst=h[i] if h[i]!=nil  
      speak(h[i],1,true,id,false)
        sleep(0.01) while speech_actived
   }
   }
    end
end
end
#Copyright (C) 2014-2019 Dawid Pieper