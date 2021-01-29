# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

module EltenAPI
  module Speech
    @@speechaudio=nil
    @@speechaudiothread=nil
    @@speechaudiofile=nil
    private
  # Speech related functions
    
    def alert(text, wait=true)
      Programs.emit_event(:speech_alert)
      speak(text)
      NVDA.braille_alert(text) if NVDA.check
      speech_wait if wait
      end
    
      # Says a text
  #
  # @param text [String] a text to speak
  # @param method [Numeric] 0 - wait for the previous message to say, 1 - abord the previous message, 2 - use synthesizer config
    def speak(text,method=1,usedict=true,id=nil,closethr=true, pos=50)
      Programs.emit_event(:speech_speak)
      if closethr and $speechindexedthr!=nil
        $speechindexedthr.exit
        $speechindexedthr=nil
      end
      spelling=false
      id=rand(2**32) if id==nil
      $speechid=id
      swait=false
                  if $speech_wait==true
      method=0
      $speech_wait=false
      swait=true
      speech_wait if Configuration.voice!="NVDA"
    end
            Win32API.new($eltenlib,"SapiSetPaused",'i','i').call(0) if text!=nil and text!="" and method!=0 and Configuration.voice!="NVDA"
          if @@speechaudio!=nil
    @@speechaudiothread.kill if @@speechaudiothread!=nil
    @@speechaudio.close
    @@speechaudio=nil
    end
  text = text.to_s
  speechaudio  =""
  text = text.gsub("\004LINE\004", "\n")
pre=""
prei=0
    rx=/\004AUDIO\004(\*?[A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+\=_\n]+)\004AUDIO\004/
      txt=text+""
        txt.gsub(rx) do
          pre=""
      prei=0
      for i in 0..text.size-1
        pre+=text[i..i] if text[i..i+6]!="\004AUDIO\004"
        prei=i-1
        break if text[i..i+6]=="\004AUDIO\004"
      end
      speak(pre)
(0..prei).each{|i| text[i]=0 }
            text.delete!("\0")
    end
    rx=/\004AUDIO\004(\*?[A-Za-z0-9 -._ąćęłńóśźżĄĆĘŁŃÓŚŹŻ:,\/\%()\\!\&\+\=_\n]+)\004AUDIO\004/
      text.gsub!(rx) do
        s=$1
        if s[0..0]!="*"
                                if s[0..0]=="/"
   s[0]=0
   s.delete!("\0")
   s=$url+s
            end
        if FileTest.exists?(s) or s[0..3].downcase=="http"
        speechaudio=s.to_s
      end
    else
      speechaudio=s.to_s
      end
      ""
      end
  if text == " "
    if Configuration.soundthemeactivation != 0
    play("editbox_space")
  else
    speak(p_("EAPI_Speech", "Space"))
    end
    return if speechaudio==""
  end
  if text == "\n"
    play("editbox_endofline")
    return if speechaudio==""
  end
  if text.size!=0 and ((l=text.split("")).size==1) and l[0].bigletter
      play("editbox_bigletter")
              end
    if speechaudio!=""
      @@speechaudiofile=speechaudio
  @@speechaudiotext=text
      if @@speechaudio!=nil
      @@speechaudiothread.kill if @@speechaudiothread!=nil
      @@speechaudio.close
      end
      @@speechaudio.close if @@speechaudio!=nil
      if @@speechaudiofile[0..0]!="*"
      speechaudio=Bass::Sound.new(@@speechaudiofile)    
    else
      speechaudio=Bass::Sound.new(nil, 1, false, false, Base64.strict_decode64(@@speechaudiofile[1...-1]))    
      end
      @@speechaudiothread=Thread.new do
             @@speechaudiofile            
                                                  @@speechaudio.close if @@speechaudio!=nil and @@speechaudio.closed==false
                         @@speechaudio=speechaudio
      while speech_actived(true)
        sleep(0.01)
        end
      speechaudio.play
              speechaudio.wait
                              speechaudio.close
                          @@speechaudio=nil
        speak(text)
              end
      return
    end
  if text != ""
        spelling=true if text.chrsize==1
    text = text.gsub("_"," ")
text.gsub(/\004INFNEW\{([^\}]+)\}\004/) {
text=(((Configuration.soundthemeactivation==1)?"":($1+" "))+text).gsub(/\004INFNEW\{([^\}]+)\}\004/,"\004NEW\004")
}
  text.gsub!("\004NEW\004") {
  play("listbox_itemnew", 100, 100, pos)
  ""
  }
  text.gsub!("\004CLOSED\004") {
  play("listbox_itemclosed", 100, 100, pos)
  ((Configuration.soundthemeactivation==1)?"":(" "+p_("EAPI_Speech", "Closed")+" "))
  }
  text.gsub!("\004FUTURE\004") {
  play("listbox_itemfuture", 100, 100, pos)
  ((Configuration.soundthemeactivation==1)?"":(" "+p_("EAPI_Speech", "Future")+" "))
  }
  text.gsub!("\004ONLINE\004") {
  play("user_online", 100, 100, pos)
  ((Configuration.soundthemeactivation==1)?"":(" "+p_("EAPI_Speech", "Online")+" "))
  }
  text.gsub!("\004SPONSOR\004") {
  play("user_sponsor", 100, 100, pos)
  ((Configuration.soundthemeactivation==1)?"":(" "+p_("EAPI_Speech", "Sponsor")+" "))
  }
  text.gsub!("\004PINNED\004") {
  play("listbox_itempinned", 100, 100, pos)
  ((Configuration.soundthemeactivation==1)?"":(" "+p_("EAPI_Speech", "Pinned")+" "))
  }
  text.gsub!("\004ATTACHMENT\004") {
  play("listbox_itemattachment", 100, 100, pos)
  ""
  }
  text_d = text
text_d.gsub!("\r\n\r\n","\004SLINE\004")
text_d.gsub!("\r\n"," ")
text_d.gsub!("\004SLINE\004","\r\n\r\n")
text_d=text_d.split("")[0...50000].join("") if text_d.size>50000
if spelling and Configuration.usevoicedictionary==0
    text_d = char_dict(text_d)  
    spelling=false
    end
if Configuration.voice=="NVDA" && NVDA.check
  NVDA.stop   if !swait
  if spelling==false
  NVDA.speak(text_d)
else
  NVDA.speakspelling(text_d)
  end
else
    if Win32API.new("bin\\nvdaHelperRemote", "nvdaController_testIfRunning", '', 'i').call!=0
    Configuration.voice=""
    end
                      if Configuration.voice == "NVDA"
                        if spelling
    text_d = char_dict(text_d)  
    spelling=false
    end
                        buf=unicode(text_d)
                                                       Win32API.new("bin\\nvdaHelperRemote","nvdaController_speakText",'pi','i').call(buf,method)
                             else
                                                                                                                           ssml="<pitch absmiddle=\"#{(((Configuration.voicepitch||50)/5.0)-10.0).to_i}\"/>"
                                                                                                                           if !spelling
                                                                                                                           ssml+=text_d.gsub("<","&lt;").gsub(">","&gt;").gsub("\\","\\\\")
                                                                                                                         else
                                                                                                                           ssml+="<spell>"+text_d.gsub("<","&lt;").gsub(">","&gt;").gsub("\\","\\\\")+"</spell>"
                                                                                                                           end
                                                              buf=unicode(ssml)
                               Win32API.new($eltenlib,"SapiSpeakSSML",'p','i').call(buf)
                               end
end
$speech_lasttext = text_d
if text.size>=5
  if Thread::current==$mainthread
if @@speechaudiothread!=nil
  @@speechaudiothread.kill
  if @@speechaudio!=nil
    if @@speechaudio.closed==false
  @@speechaudio.close
end
end
end
end
end
end
text_d = text if text_d == nil
return text_d
end

alias speech speak

def speakindexed(texts, indexes, indid=nil)
  $speechid=id
    ssml="<pitch absmiddle=\"#{((Configuration.voicepitch/5.0)-10.0).to_i}\"/>"
  for i in 0...texts.size
    mark=""
    if indid!=nil
      mark=":"+indid.to_s+":"
    end
    mark+=(indexes[i]||"").to_s
    ssml+="<bookmark mark=\"#{mark}\"/>"
    ssml+=texts[i].gsub("<","&lt;").gsub(">","&gt;").gsub("\\","\\\\")
  end
                                                                    buf=unicode(ssml)
                               Win32API.new($eltenlib,"SapiSpeakSSML",'p','i').call(buf)
                             end
                             
                             def speech_getindex
                               nd=Win32API.new($eltenlib, "SapiGetBookmark", '', 'i').call
                               return nil if nd==0
                               siz=Win32API.new("msvcrt", "wcslen", 'i', 'i').call(nd)
                               bk="\0"*2*(siz+1)
                               Win32API.new("msvcrt", "wcscpy", 'pi', 'i').call(bk, nd)
                               return deunicode(bk)
                               end

# Determines if the speech is used
#
# @param ignoreaudio [Boolean] ignores the played speechaudio
# @return [Boolean] if the speech is ued, returns true, otherwise the return value is false
def speech_actived(ignoreaudio=false)
            return true if @@speechaudio!=nil and ignoreaudio==false
          if Win32API.new($eltenlib,"SapiIsSpeaking",'','i').call() == 0
    return(false)
  else
    return(true)
  end
  end

  # Stops the speech
  def speech_stop(audio=true)
    Programs.emit_event(:speech_stop)
        $speech_wait=false
    if @@speechaudio!=nil and audio
    @@speechaudiothread.exit if @@speechaudiothread!=nil
    @@speechaudio.close
    @@speechaudio=nil
  end
      if $speechindexedthr!=nil
      $speechindexedthr.exit
      $speechindexedthr=nil
      end
    func = "sapiStopSpeech"
    if Configuration.voice=="NVDA"
    func = "stopSpeech"
    if Configuration.voice=="NVDA" && NVDA.check
      NVDA.stop
      return
    else
      Win32API.new("bin\\nvdaHelperRemote","nvdaController_cancelSpeech",'','i').call()
      end
    else
      Win32API.new($eltenlib,"SapiStop",'','i').call()
        end
  
  end
  
  # Waits for a speech to finish reading of the previous message
      def speech_wait
        if Configuration.voice!="NVDA"
    while speech_actived == true
loop_update(false)
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
def char_dict(text, abs=false)
  r=""
  case text
  when "."
    r=p_("EAPI_Speech", "dot")
    when ","
      r=p_("EAPI_Speech", "comma")
      when "/"
        r=p_("EAPI_Speech", "slash")
        when ";"
          r=p_("EAPI_Speech", "semi")
          when "'"
            r=p_("EAPI_Speech", "tick")
            when "["
              r=p_("EAPI_Speech", "left bracket")
              when "]"
                r=p_("EAPI_Speech", "right bracket")
                when "\\"
                  r=p_("EAPI_Speech", "backslash")
                  when "-"
                    r=p_("EAPI_Speech", "dash")
                    when "="
                      r=p_("EAPI_Speech", "equals")
                      when "`"
                        r=p_("EAPI_Speech", "graav")
                        when "<"
                          r=p_("EAPI_Speech", "less")
                          when ">"
                            r=p_("EAPI_Speech", "greater")
                            when "?"
                              r=p_("EAPI_Speech", "question")
                              when ":"
                                r=p_("EAPI_Speech", "colon")
                                when "\""
                                  r=p_("EAPI_Speech", "quote")
                                  when "{"
                                    r=p_("EAPI_Speech", "left brace")
                                    when "}"
                                      r=p_("EAPI_Speech", "right brace")
                                      when "|"
                                        r=p_("EAPI_Speech", "bar")
                                        when "_"
                                          r=p_("EAPI_Speech", "line")
                                          when "+"
                                            r=p_("EAPI_Speech", "plus")
                                            when "!"
                                              r=p_("EAPI_Speech", "bang")
                                              when "@"
                                                r=p_("EAPI_Speech", "at")
                                                when "#"
                                                  r=p_("EAPI_Speech", "hash")
                                                  when "$"
                                                    r=p_("EAPI_Speech", "dollar")
                                                    when "%"
                                                      r=p_("EAPI_Speech", "percent")
                                                      when "^"
                                                        r=p_("EAPI_Speech", "caret")
                                                        when "\&"
                                                          r=p_("EAPI_Speech", "and")
                                                          when "*"
                                                            r=p_("EAPI_Speech", "star")
                                                            when "("
                                                              r=p_("EAPI_Speech", "left paren")
                                                              when ")"
                                                                r=p_("EAPI_Speech", "right paren")
                                                                when "ü"
                                                                                                                                    r="u umlaut" if Configuration.language=="pl-PL"
                                                                  when "Ü"
                                                                    r="U umlaut" if Configuration.language=="pl-PL"
                                                                    when "ä"
                                                                      r="a umlaut" if Configuration.language=="pl-PL"
                                                                      when "Ä"
                                                                 r="A umlaut" if Configuration.language=="pl-PL"
                                                                 when "ö"
                                                                   r="o umlaut" if Configuration.language=="pl-PL"
                                                                   when "Ö"
                                                                     r="O umlaut" if Configuration.language=="pl-PL"
when "ß"
                                                                     r="długie s" if Configuration.language=="pl-PL"
                                                                     when "´"
                                                                     r="ostry akcent" if Configuration.language=="pl-PL"
                                                                   end
                                                                   if abs and text==" "
                                                                     r=p_("EAPI_Speech", "Space")
                                                                     end
                      if r==""
                        return(text)
                      else
                        return(r)
                        end
                      end
                      
                      # Toggles the speech pause
     def speech_togglepause
       Programs.emit_event(:speech_toggle)
  if Win32API.new($eltenlib,"SapiIsPaused",'','i').call==0
  Win32API.new($eltenlib,"SapiSetPaused",'i','i').call(1)
    else
  Win32API.new($eltenlib,"SapiSetPaused",'i','i').call(0)
  end
  end

  def speak_indexed(h,id=nil)
    Programs.emit_event(:speech_speak)
    id=rand(10**24) if id==nil
    $speechindexedthr.exit if $speechindexedthr!=nil
        return if !h.is_a?(Hash)
    if Configuration.voice=="NVDA" && !NVDA.check
      txt=""
      h.keys.sort.each {|i| txt+=h[i]+"\r\n"}
      return speak(txt)
    end
    if Configuration.voice=="NVDA" or true
            $speechindexedthr=Thread.new do
              begin
              if Configuration.voice=="NVDA"
              NVDA.stop if !$speech_wait
            else
              speech_stop
              end
                  stp=10+rand(100)
                                                        texts=[]
      indexes=[]
      h.keys.sort.each {|k|
      texts.push(h[k])
      indexes.push(k+stp)
      }
                        if Configuration.voice=="NVDA"
                          NVDA.speakindexed(texts, indexes, id)
            loop {
            n=NVDA.getindex
            next if n==nil and NVDA.check==true
            break if n==nil and NVDA.check==false
            break if n[0].to_i>=stp and n[1]==id
            sleep(0.1)
            }
          else
                        speakindexed(texts, indexes, id)
            loop {
                        break if !speech_actived
            sleep(0.01)
            }
          end
          sleep(0.05)
                      loop {
      if Configuration.voice=="NVDA"
            ind,indid=NVDA.getindex
          else
            nd=speech_getindex
                        if nd!=nil && nd[0..0]==":"
              indid,ind=nd[1..-1].split(":").map{|n|n.to_i}
                          else
              indid=ind=nil
              end
            end
            $speechid=indid
      break if indid!=id || (ind||0)<stp || (id!=nil && $speechid!=id)
      $speechindex=ind-stp
      sleep(0.1)
      }
    sleep(1)
      play 'signal'
      $speechindexedthr=nil
    rescue Exception
      Log.error("Speech indexer: "+$!.to_s+" "+$@.to_s)
    end
    end
    return
      end
 end

 class SapiVoice
   attr_accessor :id, :name, :language, :age, :gender, :vendor
   def voiceid
     return "" if @id==nil
     return @id.split("\\").last
     end
   end
 
          def listsapivoices
            sz=Win32API.new($eltenlib, "SapiListVoices", 'pi', 'i').call(nil, 0)
a=([nil,nil,nil,nil,nil,nil]*sz).pack('pppppp'*sz)
Win32API.new($eltenlib, "SapiListVoices", 'pi', 'i').call(a, sz)
mems=a.unpack("iiiiii"*sz)
voices=[]
wcslen=Win32API.new("msvcrt", "wcslen", 'i', 'i')
wcscpy=Win32API.new("msvcrt", "wcscpy", 'pi', 'i')
for i in 0...mems.size/6
  ms=mems[i*6...i*6+6]
  voice=SapiVoice.new
  for j in 0...6
    m=ms[j]
    next if m==0
len=wcslen.call(m)
ptr="\0"*2*(len+1)
wcscpy.call(ptr, m)
val=deunicode(ptr)
case j
when 0
  voice.id=val
  when 1
    voice.name=val
    when 2
      voice.language=val
      when 3
        voice.age=val
        when 4
          voice.gender=val
        when 5
          voice.vendor=val
end
end
voices.push(voice)
end
Win32API.new($eltenlib, "SapiFreeVoices", 'pi', 'i').call(a, sz)
return voices
end

def listsapidevices
            sz=Win32API.new($eltenlib, "SapiListDevices", 'pi', 'i').call(nil, 0)
a=([nil]*sz).pack('p'*sz)
Win32API.new($eltenlib, "SapiListDevices", 'pi', 'i').call(a, sz)
mems=a.unpack("i"*sz)
devices=[]
wcslen=Win32API.new("msvcrt", "wcslen", 'i', 'i')
wcscpy=Win32API.new("msvcrt", "wcscpy", 'pi', 'i')
for m in mems
len=wcslen.call(m)
ptr="\0"*2*(len+1)
wcscpy.call(ptr, m)
devices.push(deunicode(ptr))
end
Win32API.new($eltenlib, "SapiFreeDevices", 'pi', 'i').call(a, sz)
return devices
            end
 end
 include Speech
end