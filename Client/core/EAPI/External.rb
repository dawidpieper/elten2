#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  # Functions using external APIs
  module External
    # Translates a string to another language using Yandex
    #
    # @param from [String]
    # @param to [String]
    # @param text [String]
    # Uses Google Api GTX Translate API to translate a text
    #
    # @param from [String] an input language code
    # @param to [String] an output language code
    # @param text [String] a text to translate
    # @return [String] a translated text
    def gtranslate(from,to,text)
                  from="auto" if from==0
                  textc = "q=" + text.to_s.urlenc
                  if textc.size>5000
                                        plc=[]
res=""
ind=0
places=[]
textct=textc[2..textc.size]
until textct.empty?
places << textct.slice!(0..4990)
i=places.size-1
pl=places[i]
  if pl[pl.size-1]==37
  places[i]+=textct[0..1]
  textct[0..1]=""
         elsif pl[pl.size-2]==37
  places[i]+=textct[0..0]
  textct[0..0]=""
      end
end
    for pl in places
res+=gtranslate(from,to,pl.urldec)+"\r\n"
end
return res
                    end
                                                    data = "POST /translate_a/single?client=gtx\&sl=#{from}\&tl=#{to}\&dt=t\&ie=utf-8\&oe=utf-8\&dt=bd HTTP/1.1\r\nAccept-Encoding: identity\r\nContent-Length: #{textc.size.to_s}\r\nHost: www.google.com\r\nContent-Type: application/x-www-form-urlencoded\r\nConnection: close\r\nUser-Agent: Elten/#{$version.to_s}\r\n\r\n#{textc}"
                          tt = connect("translate.google.com",80,data,1024+(4*textc.size))
        errc=200
        if (/HTTP\/1.1 (\d\d\d)/=~tt)!=nil
          errc=$1.to_i
        end
        if errc!=200
                    return ""
          end
                          r = ""
    tt = [] if tt == nil
    ind = 0
        for i in 3..tt.size - 1
      ind += 1
      break if tt[i-3..i] == "\r\n\r\n"
    end
    ind += 1
    r=""
    for i in ind..tt.size - 1
                      r += tt[i..i]
            end
     null=nil
     begin
       e=eval(r)
       t=""
              for l in e[0]
                  t+=l[0]+"\r\n"
         end
         t.chop! if t[t.size-1..t.size-1]==" "
         return t
        rescue Exception
          return ""
          end
   end
   
   # Translates a string to another language using Yandex
    #
    # @param from [String] source language code (if 0, the language autodetection is used)
    # @param to [String] destination language code
    # @param text [String] a text to translate
    # @return [String] the translation result
   def ytranslate(from,to,text,quiet=false)
     text="" if text==nil
     text=text.to_s
          text=text.gsub("\004LINE\004","\r\n")
     text.gsub!("\r\n"," \r\n")
     text.gsub!("\004","")
text.gsub!("-"," ")
     text=text.urlenc
               to = to[0..1]
               text[0]=0 if text[0..0]=="+"
               text.delete!("\0")
                              if from == 0
       download("https://translate.yandex.net/api/v1.5/tr.json/detect?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}","temp/trans")
               a = read("temp/trans")
File.delete("temp/trans")
 b = a.gsub("\":","\"=>")
c = eval(b,nil,"trns")
return "" if c==nil
if c['code']!=200
  speech("Wystąpił błąd podczas tłumaczenia") if quiet==false
  return c['code']
end
from = c['lang']       
end
to=to.downcase
download("https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}\&lang=#{from}-#{to}","temp/trans")
          a =  read("temp/trans")
     File.delete("temp/trans")
     b = a.gsub("\":","\"=>")
c = eval(b,nil,"trns")
if c.is_a?(Hash)
if c['code']!=200
  speech("Wystąpił błąd podczas tłumaczenia") if quiet==false
  return c['code']
end
r = ""
for l in c['text']
  r += l
end
return r
else
  return ""
  end
     end
   # Translates a string to another language using selected API
    #
    # @param from [String] source language code (if 0, the language autodetection is used)
    # @param to [String] destination language code
    # @param text [String] a text to translate
    # @param api [Int] 0=AUTO, 1=GOOGLE, 2=YANDEX
    # @return [String] the translation result
def translatetext(from,to,text,api=0)
  case api
  when 0
    t=gtranslate(from,to,text)
        t=ytranslate(from,to,text) if t == "" or t == nil
    return t
  when 1
    return gtranslate(from,to,text)
    when 2
      return ytranslate(from,to,text)
  end
  end

# Opens a translator dialog
#
# @param text [String] a text to translate
     def translator(text)
  dialog_open
  download("https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&ui=#{$language[0..1]}","temp/trans")
  a = read("temp/trans")
 File.delete("temp/trans")
 b = a.gsub("\":","\"=>")
 c = eval(b,nil,"trns")
 langs=c['langs']
  from=Select.new(["Wykryj język automatycznie"]+langs.values,true,0,"Język źródłowy",true)
 ind=0
 for i in 0..langs.keys.size-1
   ind=i if $language[0..1].downcase==langs.keys[i].downcase
   end
 to=Select.new(langs.values,true,ind,"Język docelowy",true)
 submit=Button.new("Tłumacz")
 cancel=Button.new("Anuluj")
 form=Form.new([from,to,submit,cancel])
loop do
  loop_update
  form.update
  if escape or ((space or enter) and form.index==3)
    dialog_close
    loop_update
    return -1
  end
  if (space or enter) and form.index == 2
    break
    end
end
dialog_close
lfrom=0
if from.index==0
  lfrom=0
else
  lfrom=langs.keys[from.index-1]
end
lto=langs.keys[to.index]
ef = translatetext(lfrom,lto,text)
lfrom = "AUTO" if lfrom==0
dialog_open
input_text("Tłumaczenie z #{lfrom} na #{lto}","MULTILINES|READONLY",ef)
loop_update
dialog_close
end
end

# Opens a youtube search dialog
#
# @param query [String] a value to search for
def youtubesearch(query=nil)
  h=nil
if query == nil
  query = input_text("Przeszukaj Youtube","ACCEPTESCAPE")
  return -1 if query == "\004ESCAPE\004"
  end
  download("https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{(query).urlenc}&type=video&maxResults=50&key=AIzaSyDHzxuKr4G6bENMzQLbUbC1FcWwzyrgr1M","temp/yttemp")
  x=read("temp/yttemp")
  File.delete("temp/yttemp")
  e = eval(x.gsub("\#\$","\\\#\\\$").gsub("\": ","\"=>"),nil,"YT")
  if e['error'] != nil or e['errors'] != nil
    speech("Błąd")
    speech_wait
    return
  end
  o=[]
  ids=[]
    for i in 0..e['items'].size-1
    o.push(e['items'][i]['snippet']['title']+" .\r\n"+e['items'][i]['snippet']['channelTitle']+" .\r\n"+e['items'][i]['snippet']['description'])
    ids.push(e['items'][i]['id']['videoId'])
  end
  $ytdh=[]
  $ytds=[]
      dialog_open
  sel = Select.new(o,true,0,"Wyniki wyszukiwania")
loop do
  loop_update
  sel.update
  if escape
                dialog_close
    return 0
        break
  end
  if enter
    waiting
    if e==nil
      speech("Błąd")
      speech_wait
      $scene=Scene_Main.new
      return
      end
    destination = "temp/"+e['items'][sel.index]['snippet']['title'].delspecial+"."+$advanced_ytformat
          suc=false
   if FileTest.exists?(destination) and $ytds[sel.index]==2
        suc=true
     else
      $ytdh[sel.index]=1  
      statustempfile="temp/yts"+rand(36**2).to_s(36)+".tmp"
            h = run("cmd /c bin\\youtube-dl.exe -f bestaudio --extract-audio --audio-format #{$advanced_ytformat} -o \"#{destination.gsub("."+$advanced_ytformat,".mp4")}\" \"https://youtube.com/watch?v=#{ids[sel.index]}\" 1> #{statustempfile} 2>\&1",true)
            speech("Łączenie z serwerem, proszę czekać...")
      prc=0
      starttm=Time.now.to_i
      lastcheck=Time.now.to_i
      yst=""
      loop do
        loop_update
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
yst=read(statustempfile)
if yst != nil and yst != ""
  yst.gsub(/\[download\]( *)(\d+.\d)%/,'')
prc=$2.to_f
end
if yst.include?("[ffmpeg]") and prc==100 and FileTest.exists?(destination)
  a=AudioFile.new(destination)
    if a.position <360000
    a.close
  break
else
  a.close
  end
  end
  if Time.now.to_i>lastcheck+5
    lastcheck=Time.now.to_i
    speech(prc.round.to_s+"%") if prc<100
    end
  if x != "\003\001"
  yst=read(statustempfile)
    break
  end
end
executeprocess("bin\\youtube-dl -o \"#{destination.gsub($advanced_ytformat,"mp4")}\" https://youtube.com/watch?v=#{ids[sel.index]}",true) if FileTest.exists?(destination.gsub($advanced_ytformat,"mp4")) == false and FileTest.exists?(destination) == false
executeprocess("bin\\ffmpeg -y -i \"#{destination.gsub($advanced_ytformat,"mp4")}\" \"#{destination}\"",true) if FileTest.exists?(destination.gsub($advanced_ytformat,"mp4")) and FileTest.exists?(destination) == false
   $ytdh[sel.index]=h
   $ytds[sel.index]=2
 end

 if FileTest.exists?(destination)
               suc = true
               else
suc=false
end
waiting_end
if suc == true
        ind=selector(["Odtwarzaj","Dodaj do playlisty","Ustaw jako awatar","Pobierz","Skopiuj adres URL do schowka","Anuluj"],e['items'][sel.index]['snippet']['title'],0,5,1)
        if ind==2 or ind==3
           x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
if x=="\003\001"
  waiting
  speech("Proszę czekać")
  loop do
    x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
break if x!="\003\001"
end
  waiting_end
  end
          end
        case ind
    when 0
player(destination,e['items'][sel.index]['snippet']['title'],false)
when 1
  $playlist.push(destination)
speech("Dodano do playlisty")
when 2
  avatar_set(destination)
when 3
  type = selector(["Pobierz jako video","Pobierz jako audio","Anuluj"],"Jak chcesz pobrać ten plik?",0,0,1)
  if type < 2
fl = ""
fl = getfile("Gdzie zapisać ten plik?",getdirectory(40)+"\\",true,"Documents")
if fl!=""
if type == 0
fl += "\\"+e['items'][sel.index]['snippet']['title'].delspecial+".mp4"
    h = run("bin\\youtube-dl.exe -o \"#{fl}\" https://youtube.com/watch?v=#{ids[sel.index]}",true)
      t = 0
      tmax = 600
      speech("Pobieranie, proszę czekać...")
      loop do
        loop_update
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
if x != "\003\001"
  break
  end
t += 10.0/Graphics.frame_rate
if t > tmax
  speech("błąd")
  speech_wait
  return -1
  break
  end
        end
    speech("Zapisano.")
        elsif type == 1
          fl += "\\"+e['items'][sel.index]['snippet']['title'].delspecial+"."+$advanced_ytformat
                    Win32API.new("kernel32","CopyFile",'ppi','i').call(destination,fl,0)
  speech("Zapisano")      
      end
    end
    end
when 4
  url="https://youtube.com/watch?v=#{ids[sel.index]}"
  Win32API.new($eltenlib,"CopyToClipboard",'pi','i').call(url,url.size+1)
  speech("Skopiowano do schowka.")
  speech_wait
    when 5
end
else
 
  if FileTest.exists?(destination.gsub($advanced_ytformat,"mp4"))
       if simplequestion("Wystąpił błąd podczas przechwytywania ścieżki audio. Czy chcesz wysłać raport o błędzie? Może on pomóc rozwiązać problem ") == 1
         bug(true,yst)
         end
    else
  if simplequestion("Nie można odtworzyć tego pliku. Czy chcesz wysłać raport o tym błędzie? Może to pomóc naprawić napotkany problem.") == 1
    bug(true,yst)
    end
  end
  speech_wait
end
speech_wait
sel.focus
end
  end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper