#Elten Code
#Copyright (C) 2014-2019 Dawid Pieper
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
       e=JSON.load(r)
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
 c = JSON.load(a)
return "" if c==nil
if c['code']!=200
  speech(_("EAPI_External:error_translation")) if quiet==false
  return c['code']
end
from = c['lang']       
end
to=to.downcase
download("https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}\&lang=#{from}-#{to}","temp/trans")
          a =  read("temp/trans")
     File.delete("temp/trans")
     c = JSON.load(a)
if c.is_a?(Hash)
if c['code']!=200
  speech(_("EAPI_External:error_translation")) if quiet==false
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
  c = JSON.load(a)
 langs=c['langs']
  from=Select.new([_("EAPI_External:opt_langdetection")]+langs.values,true,0,_("EAPI_External:head_langsrc"),true)
 ind=0
 for i in 0..langs.keys.size-1
   ind=i if $language[0..1].downcase==langs.keys[i].downcase
   end
 to=Select.new(langs.values,true,ind,_("EAPI_External:head_langdst"),true)
 submit=Button.new(_("EAPI_External:btn_translate"))
 cancel=Button.new(_("General:str_cancel"))
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
  lfrom=0
  if from.index==0
      lfrom=0
    else
        lfrom=langs.keys[from.index-1]
      end
      lto=langs.keys[to.index]
      ef = translatetext(lfrom,lto,text)
      lfrom = "AUTO" if lfrom==0
      input_text("#{lfrom} - #{lto}","MULTILINES|READONLY",ef)
      loop_update
    dialog_close
  end


# Opens a youtube search dialog
#
# @param query [String] a value to search for
def youtubesearch(query=nil)
  h=nil
if query == nil
  query = input_text(_("EAPI_External:type_ytsearch"),"ACCEPTESCAPE")
  return -1 if query == "\004ESCAPE\004"
  end
  download("https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{(query).urlenc}&type=video&maxResults=50&key=AIzaSyDHzxuKr4G6bENMzQLbUbC1FcWwzyrgr1M","temp/yttemp")
    x=read("temp/yttemp")
  File.delete("temp/yttemp")
  e = JSON.load(x)
      if e['error'] != nil or e['errors'] != nil
    speech(_("General:error"))
    speech_wait
    return
  end
  o=[]
  ids=[]
  durations=[]
    for i in 0..e['items'].size-1
    o.push(e['items'][i]['snippet']['title']+" .\r\n"+e['items'][i]['snippet']['channelTitle']+" .\r\n"+e['items'][i]['snippet']['description'])
    ids.push(e['items'][i]['id']['videoId'])
  end
  $ytdh=[]
  $ytds=[]
      dialog_open
  sel = Select.new(o,true,0,_("EAPI_External:head_ytsearchresults"),true)
  dete=Edit.new(_("EAPI_External:read_Details"),"READONLY|MULTILINE","",true)
  form=Form.new([sel,dete])
details=[]
previewed=false
preview=nil
urls=[]
loop do
  loop_update
  if $key[0x9]
    if details[sel.index]==nil
    vid=ids[sel.index]
    download("https://www.googleapis.com/youtube/v3/videos?part=id,snippet,contentDetails&id=#{vid}&key=AIzaSyDHzxuKr4G6bENMzQLbUbC1FcWwzyrgr1M","temp/yttemp")
    vx=read("temp/yttemp")
  File.delete("temp/yttemp")
  details[sel.index]=ve = JSON.load(vx)
  end
  di=details[sel.index]['items'][0]['contentDetails']['duration']
h=0
m=0
s=0
if (/(\d{1,2})H/=~di) != nil
  h=$1.to_i
end
if (/(\d{1,2})M/=~di) != nil
  m=$1.to_i
end
if (/(\d{1,2})S/=~di) != nil
  s=$1.to_i
end
pat=details[sel.index]['items'][0]['snippet']['publishedAt'].gsub("T"," ").gsub(/\.\d\d\dZ/,"")
text=details[sel.index]['items'][0]['snippet']['title']+"\r\n#{_("EAPI_External:txt_phr_ytduration")}: "+sprintf("%02d:%02d:%02d",h,m,s)+"\r\n#{_("EAPI_External:txt_phr_ytpublishtime")}: "+pat+"\r\n#{_("EAPI_External:txt_phr_ytkeywords")}: "+details[sel.index]['items'][0]['snippet']['tags'].join(", ")+"\r\n\r\n"+details[sel.index]['items'][0]['snippet']['description']
dete.settext(text)
  end
  form.update
  if $key[0x11] and $key[68]
    if details[sel.index]==nil
    vid=ids[sel.index]
    download("https://www.googleapis.com/youtube/v3/videos?part=id,snippet,contentDetails&id=#{vid}&key=AIzaSyDHzxuKr4G6bENMzQLbUbC1FcWwzyrgr1M","temp/yttemp")
    download("https://www.googleapis.com/youtube/v3/videos?part=id,snippet,contentDetails&id=#{vid}&key=AIzaSyDHzxuKr4G6bENMzQLbUbC1FcWwzyrgr1M","temp/yttemp")
    vx=read("temp/yttemp")
  File.delete("temp/yttemp")
  details[sel.index]=ve = JSON.load(vx)
  end
di=details[sel.index]['items'][0]['contentDetails']['duration']
h=0
m=0
s=0
if (/(\d{1,2})H/=~di) != nil
  h=$1.to_i
end
if (/(\d{1,2})M/=~di) != nil
  m=$1.to_i
end
if (/(\d{1,2})S/=~di) != nil
  s=$1.to_i
end
speech(sprintf("%02d:%02d:%02d",h,m,s))
    end
      if escape
        preview.close if preview!=nil
                dialog_close
    return 0
        break
  end
  if space and form.index==0
    if previewed==sel.index
      preview.close
      preview=nil
      previewed=false
      else
    if urls[sel.index]==nil
        waiting
    if e==nil
      speech(_("General:error"))
      speech_wait
      $scene=Scene_Main.new
      return
      end
          suc=false
      statustempfile="temp/ytp"+rand(36**2).to_s(36)+".tmp"
            h = run("cmd /c bin\\youtube-dl.exe -g -f bestaudio --extract-audio \"https://youtube.com/watch?v=#{ids[sel.index]}\" 1> #{statustempfile} 2>\&1",true)
                  prc=0
      starttm=Time.now.to_i
      lastcheck=Time.now.to_i
      yst=""
      loop do
        loop_update
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
yst=IO.readlines(statustempfile) if FileTest.exists?(statustempfile)
              if x != "\003\001"
  yst=IO.readlines(statustempfile)
    break
  end
end
waiting_end
for l in yst
  urls[sel.index]=l.delete("\r\n") if l[0..3]=="http"
end
end
url=urls[sel.index]
previewed=sel.index
preview.close if preview!=nil
preview=Bass::Sound.new(url,1)
preview.play
  end  
end
  if enter and form.index==0 and e!=nil
    preview.close if preview!=nil
    ytfile(e['items'][sel.index])
    speech_wait
sel.focus
end
end
end
  
def ytfile(url,upd=false)
    e=url if url.is_a?(Hash)
    id=e['id']
    id=id['videoId'] if id.is_a?(Hash)
    waiting
    destination = "temp/"+e['snippet']['title'].delspecial+"_"+e['snippet']['channelTitle'].delspecial+".tmp"
          suc=false
          d=Dir.entries("temp")
  for f in d
    if destination.gsub(File.extname(destination),"")=="temp/"+f.gsub(File.extname(f),"")
            ext=File.extname(f).downcase
                  if ext != ".part" and ext!=".tmp"
        suc=true
        destination="temp\\"+f
              end
                                end
end
if suc == true
  suc = true
else
            statustempfile="temp/yts"+rand(36**2).to_s(36)+".tmp"
            h = run("cmd /c bin\\youtube-dl.exe --no-check-certificate -f bestaudio --extract-audio -o \"#{destination}\" \"https://youtube.com/watch?v=#{id}\" 1> #{statustempfile} 2>\&1",true)
                        speech(_("EAPI_External:wait_connecting"))
      prc=0
      starttm=Time.now.to_i
      lastcheck=Time.now.to_i
      yst=""
      sil=false
      loop do
        loop_update
        if space
          if sil==false
            sil=true
            speech(_("EAPI_External:info_donotreadprogress"))
          else
            sil=false
            speech(_("EAPI_External:info_readprogress"))
          end
          end
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
yst=read(statustempfile)
if yst != nil and yst != ""
  yst.gsub(/\[download\]( *)(\d+.\d)%/,'')
prc=$2.to_f
end
            if Time.now.to_i>lastcheck+5
    lastcheck=Time.now.to_i
    speech(prc.round.to_s+"%") if prc<100 and sil==false
    end
  if x != "\003\001"
  yst=read(statustempfile)
    break
  end
end
  d=Dir.entries("temp")
  suc=false
  for f in d
    if destination.gsub(File.extname(destination),"")=="temp/"+f.gsub(File.extname(f),"")
            ext=File.extname(f).downcase
                  if ext != ".part" and ext!=".tmp"
        suc=true
        destination="temp\\"+f
              end
                                end
end
                                       end
 if FileTest.exists?(destination)
               suc = true
               else
suc=false
end
waiting_end
if suc == true
        ind=selector([_("EAPI_External:btn_play"),_("EAPI_External:opt_addtopls"),_("EAPI_External:opt_avatar"),_("EAPI_External:opt_download"),_("EAPI_External:opt_copyurl"),_("General:str_cancel")],e['snippet']['title'],0,5,1)
        case ind
    when 0
      player(destination,e['snippet']['title'],false,true,false)
when 1
  $playlist.push(destination)
speech(_("EAPI_External:info_addedtopls"))
when 2
  avatar_set(destination)
when 3
  type = selector([_("EAPI_External:opt_downloadvideo"),_("EAPI_External:opt_downloadaudio"),_("General:str_cancel")],_("EAPI_External:head_downloadtype"),0,0,1)
  if type < 2
fl = ""
fl = getfile(_("EAPI_External:head_dst"),getdirectory(40)+"\\",true,"Documents")
if fl!=""
if type == 0
fl += "\\"+e['snippet']['title'].delspecial+".mp4"
    h = run("bin\\youtube-dl.exe -o \"#{fl}\" \"https://youtube.com/watch?v=#{id}\"",true)
      t = 0
      tmax = 600
      speech(_("EAPI_External:wait_downloading"))
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
  speech(_("General:error"))
  speech_wait
  return -1
  break
  end
        end
    speech(_("General:info_saved"))
        elsif type == 1
          fl += "\\"+destination.sub("temp\\","")
          formats=[File.extname(destination).delete("."),"mp3","wav","ogg"]
          dialog_open
          format=selector(formats,_("EAPI_External:head_saveformat"),0,-1,1)
          dialog_close
          if format!=-1
            if format==0        
            Win32API.new("kernel32","CopyFile",'ppi','i').call(destination,fl,0)
          else
            fl.gsub!(File.extname(fl),"."+formats[format])
            waiting
            speech(_("EAPI_External:wait"))
            executeprocess("bin/ffmpeg -y -i \"#{destination}\" \"#{fl}\"",true)
            waiting_end
            end
  speech(_("General:info_saved"))      
  end
      end
    end
    end
when 4
  url="https://youtube.com/watch?v=#{id}"
  Win32API.new($eltenlib,"CopyToClipboard",'pi','i').call(url,url.size+1)
  speech(_("EAPI_External:info_copiedtoclip"))
  speech_wait
    when 5
end
else
 if upd==false
   speech(_("EAPI_External:wait_youtubedl"))
   waiting
      executeprocess("bin\\youtube-dl.exe -U",true)
      delay(1)
      if FileTest.exists?("bin\\youtube-dl.exe.new")
        Win32API.new("kernel32","DeleteFile",'p','i').call("bin\\youtube-dl.exe")
        Win32API.new("kernel32","MoveFile",'pp','i').call(".\\bin\\youtube-dl.exe.new",".\\bin\\youtube-dl.exe") 
        end
   waiting_end
   ytfile(url,true)
   else
  if FileTest.exists?(destination.gsub($advanced_ytformat,"mp4"))
       if simplequestion(_("EAPI_External:alert_audioreport")) == 1
         bug(true,yst)
         end
    else
  if simplequestion(_("EAPI_External:alert_ytreport")) == 1
    bug(true,yst)
  end
  end
  end
end
end

def ytlist(ids)
  ids=[ids] if ids.is_a?(String)
  download("https://www.googleapis.com/youtube/v3/videos?part=snippet&id=#{ids.join(",")}&key=AIzaSyDHzxuKr4G6bENMzQLbUbC1FcWwzyrgr1M","temp/yttemp")
    x=read("temp/yttemp")
  File.delete("temp/yttemp")
  e = JSON.load(x)
      if e['error'] != nil or e['errors'] != nil
    speech(_("General:error"))
    speech_wait
    return {'items'=>[]}
  end
  return e
end

end
end
#Copyright (C) 2014-2019 Dawid Pieper