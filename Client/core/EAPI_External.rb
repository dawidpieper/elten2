#Elten Code
#Copyright (C) 2014-2016 Dawid Pieper
#All rights reserved.


#Open Public License is used to licensing this app!

module EltenAPI
  module External
                            def gtranslate(from,to,text)
                         
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
   
   def translate(from,to,text,quiet=false)
     text="" if text==nil
     text=text.gsub("\004LINE\004","\r\n")
     text.gsub!("\r\n"," \r\n")
     text=text.urlenc
     to = to[0..1]
     if from == 0
       download("https://translate.yandex.net/api/v1.5/tr.json/detect?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}","temp/trans")
       a = read("temp/trans")
File.delete("temp/trans")
 b = a.gsub("\":","\"=>")
c = eval(b)
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
c = eval(b)
if c['code']!=200
  speech("Wystąpił błąd podczas tłumaczenia") if quiet==false
  return c['code']
end
r = ""
for l in c['text']
  r += l
end
return r
     end
   


def translator(text)
  dialog_open
  download("https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&ui=#{$language[0..1]}","temp/trans")
  a = read("temp/trans")
 File.delete("temp/trans")
 b = a.gsub("\":","\"=>")
 c = eval(b)
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
ef = translate(lfrom,lto,text)
lfrom = "AUTO" if lfrom==0
dialog_open
input_text("Tłumaczenie z #{lfrom} na #{lto}","MULTILINES|READONLY",ef)
loop_update
dialog_close
end
end
def youtubesearch(query=nil)
if query == nil
  query = input_text("Przeszukaj Youtube","ACCEPTESCAPE")
  return -1 if query == "\004ESCAPE\004"
  end
  download("https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{(query).urlenc}&type=video&maxResults=50&key=AIzaSyDHzxuKr4G6bENMzQLbUbC1FcWwzyrgr1M","yttemp")
  x=read("yttemp")
  File.delete("yttemp")
  e = eval(x.gsub("\": ","\"=>"))
  if e['error'] != nil or e['errors'] != nil
    speech("Błąd")
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
  $ytch=[]
  $ytcs=[]
  if $interface_ytbuffering == 1
  bgdwn = Thread.new do
      for di in 0..ids.size-1
                if $ytds[di]==nil
        h=$ytdh
    destination = "temp/"+e['items'][di]['snippet']['title'].delspecial+".mp3"
    if FileTest.exists?(destination+"_org.tmp")
      $ytds[di]=2
      else
    h[di] = run("bin\\youtube-dl.exe -x -o \"#{destination}_org.tmp\" https://youtube.com/watch?v=#{ids[di]}",true)
    $ytdh=h
$ytds[di]=1
loop do
        sleep(0.25)
        x="\0"*1024
        Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h[di],x)
x.delete!("\0")
if x != "\003\001"
  $ytdh=h
$ytds[di]=2
  break
  end
end
end
    end
  end
  end
  bgcnv = Thread.new do
      for ci in 0..ids.size-1
        destination = "temp/"+e['items'][ci]['snippet']['title'].delspecial+".mp3"
        if FileTest.exists?(destination)
          $ytcs[ci]=2
          else
        if $ytcs[ci]==nil
                    loop do
          break if $ytds[ci] == 2
          sleep(1)
                                                                end
                              h=$ytch
                h[ci] = run("bin\\ffmpeg.exe -y -i \"#{destination}_org.tmp\" -b:a 192K \"#{destination}\"",true)
                        $ytch=h
            $ytcs[ci]=1
                        loop do
        sleep(0.5)
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h[ci],x)
x.delete!("\0")
if x != "\003\001"
  if FileTest.exists?(destination)
    $yrs=0
    begin
      File.delete(destination+"_org.tmp") if $yrs==1
    rescue Exception
      $yrs=1
      retry
      end
    end
  $ytcs[ci]=2
break
  end
    end
  end
  end
end
end  
end
dialog_open
  sel = Select.new(o,true,0,"Wyniki wyszukiwania")
loop do
  loop_update
  sel.update
  if escape
        bgdwn.exit if bgdwn!=nil
    bgcnv.exit if bgcnv!=nil
    dialog_close
    return 0
        break
  end
  if enter
       destination = "temp/"+e['items'][sel.index]['snippet']['title'].delspecial+".mp3"
          suc=false
   if FileTest.exists?(destination+"_org.tmp") and $ytds[sel.index]==2
        suc=true
     else
      $ytdh[sel.index]=1  
   h = run("bin\\youtube-dl.exe -x -o \"#{destination}_org.tmp\" https://youtube.com/watch?v=#{ids[sel.index]}",true)
      t = 0
      tmax = 300
      speech("Łączenie z serwerem, proszę czekać...")
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
  return -1
  break
  end
        end
   $ytdh[sel.index]=h
   $ytds[sel.index]=2
 end
 t=0
  while t < 10000
    delay(0.001)
    t+=1
    break if FileTest.exists?(destination)
        end
   if FileTest.exists?(destination) and $ytcs[sel.index]==2
               else
  if $ytcs[sel.index]==1
      speech("Proszę czekać, trwa przetwarzanie pliku...")
  loop do
    loop_update
    break if $ytcs[sel.index]==2
  end
    elsif FileTest.exists?(destination+"_org.tmp") and $ytcs[sel.index]!=1
  h = run("bin\\ffmpeg.exe -y -i \"#{destination}_org.tmp\" -b:a 192K \"#{destination}\"",true)
      t = 0
      tmax = File.size(destination+"_org.tmp")/10000.0
      speech("Proszę czekać, trwa przetwarzanie pliku...")
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
  return -1
  break
end
end
$ytch[sel.index]=h
$ytcs[sel.index]=2
else
  suc=-1
  end
suc = true if suc != -1
suc=false if suc==-1
end
if suc == true
        case selector(["Odtwarzaj","Dodaj do playlisty","Ustaw jako awatar","Pobierz","Skopiuj adres URL do schowka","Anuluj"],e['items'][sel.index]['snippet']['title'],0,5,1)
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
fl = input_text("Podaj ścieżkę, w której chcesz zapisać ten plik","",getdirectory(5))
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
          fl += "\\"+e['items'][sel.index]['snippet']['title'].delspecial+".mp3"
Win32API.new("kernel32","CopyFile",'ppi','i').call(destination,fl,0)
  speech("Zapisano")      
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
  speech("Nie można odtworzyć tego pliku.")
  speech_wait
  end
speech_wait
sel.focus
        end
  end
  end
end
#Copyright (C) 2014-2016 Dawid Pieper