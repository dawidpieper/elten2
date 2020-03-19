#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

module EltenAPI
  module External
    private
# Functions using external APIs
   
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
       download("https://translate.yandex.net/api/v1.5/tr.json/detect?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}",$tempdir+"/trans")
               a = readfile($tempdir+"/trans")
File.delete($tempdir+"/trans")
 c = JSON.load(a)
return "" if c==nil
if c['code']!=200
  alert(p_("EAPI_External", "An error occurred while translating.")) if quiet==false
  return c['code']
end
from = c['lang']       
end
to=to.downcase
download("https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&text=#{text}\&lang=#{from}-#{to}",$tempdir+"/trans")
          a =  readfile($tempdir+"/trans")
     File.delete($tempdir+"/trans")
     c = JSON.load(a)
if c.is_a?(Hash)
if c['code']!=200
  alert(p_("EAPI_External", "An error occurred while translating.")) if quiet==false
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
            t=ytranslate(from,to,text)
    return t
  when 1
    return ""
    when 2
      return ytranslate(from,to,text)
  end
  end

# Opens a translator dialog
#
# @param text [String] a text to translate
     def translator(text)
  dialog_open
  download("https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=trnsl.1.1.20170205T212436Z.cab9897db2f3bef5.c7e3bc4a3455b315735941dff2da96fbba97a8a8\&ui=#{$language[0..1]}",$tempdir+"/trans")
  a = readfile($tempdir+"/trans")
 File.delete($tempdir+"/trans")
  c = JSON.load(a)
 langs=c['langs']
  from=Select.new([p_("EAPI_External", "recognize automatically")]+langs.values,true,0,p_("EAPI_External", "source language"),true)
 ind=0
 for i in 0..langs.keys.size-1
   ind=i if $language[0..1].downcase==langs.keys[i].downcase
   end
 to=Select.new(langs.values,true,ind,p_("EAPI_External", "destination language"),true)
 submit=Button.new(p_("EAPI_External", "Translate"))
 cancel=Button.new(_("Cancel"))
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


def ytfile(url,upd=false)
  if !FileTest.exists?($extrasdata+"\\youtube-dl.exe")
    confirm(p_("EAPI_External", "To play Youtube videos, Elten uses external Youtube-DL library. Do you want to download it now?")) {
    waiting
    begin
download("http://youtube-dl.org/downloads/latest/youtube-dl.exe", $extrasdata+"\\youtube-dl.exe")
rescue Exception
  retry
end
waiting_end
    }
    end
  return if !FileTest.exists?($extrasdata+"\\youtube-dl.exe")
    e=url if url.is_a?(Hash)
    id=e['id']
    id=id['videoId'] if id.is_a?(Hash)
    waiting
    fname=e['snippet']['title'].delspecial+"_"+e['snippet']['channelTitle'].delspecial+".tmp"
    fname.gsub!(/\&[\w]+\;/,"")
    destination = $tempdir+"/"+fname
          suc=false
          d=Dir.entries($tempdir)
  for f in d
    if fname.gsub(File.extname(fname),"")==f.gsub(File.extname(f),"")
            ext=File.extname(f).downcase
                              if ext != ".part" and ext!=".tmp"
        suc=true
        destination=$tempdir+"\\"+f
      end
                                end
end
if suc == true
  suc = true
else
            statustempfile=$tempdir+"/yts"+rand(36**2).to_s(36)+".tmp"
            h = run("cmd /c #{$extrasdata}\\youtube-dl.exe --no-check-certificate --ffmpeg-location bin -f bestaudio --extract-audio -o \"#{destination}\" \"https://youtube.com/watch?v=#{id}\" 1> #{statustempfile} 2>\&1",true)
                        speak(p_("EAPI_External", "Connecting to server, please wait..."))
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
            alert(p_("EAPI_External", "Do not read progress bar changes."))
          else
            sil=false
            alert(p_("EAPI_External", "Read progress bar changes."))
          end
          end
        x="\0"*1024
Win32API.new("kernel32","GetExitCodeProcess",'ip','i').call(h,x)
x.delete!("\0")
yst=readfile(statustempfile)
if yst != nil and yst != ""
  yst.gsub(/\[download\]( *)(\d+.\d)%/,'')
prc=$2.to_f
end
            if Time.now.to_i>lastcheck+5
    lastcheck=Time.now.to_i
    speech(prc.round.to_s+"%") if prc<100 and sil==false
    end
  if x != "\003\001"
  yst=readfile(statustempfile)
    break
  end
end
  d=Dir.entries($tempdir+"")
  suc=false
  for f in d
    if destination.gsub(File.extname(destination),"")==$tempdir+"/"+f.gsub(File.extname(f),"")
            ext=File.extname(f).downcase
                  if ext != ".part" and ext!=".tmp"
        suc=true
        destination=$tempdir+"\\"+f
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
        ind=selector([p_("EAPI_External", "Play"),p_("EAPI_External", "Add to playlist"),p_("EAPI_External", "Download"),p_("EAPI_External", "Copy URL to the clipboard"),_("Cancel")],e['snippet']['title'].gsub(/\&[\w]+\;/,""),0,5,1)
        case ind
    when 0
      player(destination,e['snippet']['title'].gsub(/\&[\w]+\;/,""),false,true,false)
when 1
  $playlist.push(destination)
alert(p_("EAPI_External", "Added to playlist"))
when 2
  type = selector([p_("EAPI_External", "Download as video"),p_("EAPI_External", "Download as audio"),_("Cancel")],p_("EAPI_External", "How do you want to download this file?"),0,0,1)
  if type < 2
fl = ""
fl = getfile(p_("EAPI_External", "Where you want to save this file?"),getdirectory(40)+"\\",true,"Documents")
if fl!=""
if type == 0
fl += "\\"+e['snippet']['title'].delspecial.gsub(/\&[\w]+\;/)+".mp4"
    h = run("#{$extrasdata}\\youtube-dl.exe --ffmpeg-location bin -o \"#{fl}\" \"https://youtube.com/watch?v=#{id}\"",true)
      t = 0
      tmax = 600
      speak(p_("EAPI_External", "Downloading, please wait..."))
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
  alert(_("Error"))
  return -1
  break
  end
        end
    alert(_("Saved"))
        elsif type == 1
          fl += "\\"+destination.sub($tempdir+"\\","")
          formats=[File.extname(destination).delete("."),"mp3","wav","ogg"]
          dialog_open
          format=selector(formats,p_("EAPI_External", "Select the format"),0,-1,1)
          dialog_close
          if format!=-1
            if format==0        
            Win32API.new("kernel32","CopyFile",'ppi','i').call(destination,fl,0)
          else
            fl.gsub!(File.extname(fl),"."+formats[format])
            waiting
            alert(p_("EAPI_External", "Please wait..."))
            executeprocess("bin/ffmpeg -y -i \"#{destination}\" \"#{fl}\"",true)
            waiting_end
            end
  alert(_("Saved"))      
  end
      end
    end
    end
when 3
  url="https://youtube.com/watch?v=#{id}"
  Clipboard.set_data(url)
  alert(p_("EAPI_External", "Copied to clipboard."))
    when 4
end
else
 if upd==false
   speak(p_("EAPI_External", "Please wait, downloadingYoutubeDL..."))
   waiting
      executeprocess("#{$extrasdata}\\youtube-dl.exe -U",true)
      delay(1)
      if FileTest.exists?("#{$extrasdata}\\youtube-dl.exe.new")
        File.delete("#{$extrasdata}\\youtube-dl.exe")
        Win32API.new("kernel32","MoveFile",'pp','i').call("#{$extrasdata}\\youtube-dl.exe.new","#{$extrasdata}\\youtube-dl.exe") 
        end
   waiting_end
   ytfile(url,true)
   else
  if FileTest.exists?(destination)
       if confirm(p_("EAPI_External", " An error occurred while audiotrack capturing. Do you want to send a bug report?  It may help us solve the problem.")) == 1
         bug(true,yst)
         end
    else
  if confirm(p_("EAPI_External", " The file cannot be played. Do you want to report this bug? It may help us fix the  issue.")) == 1
    bug(true,yst)
  end
  end
  end
end
end

def ytquery(sect, query)
  q=query.deep_dup
  q['sect']=sect
  y=srvproc("youtube", q, 1)
  return JSON.load(y)
rescue Exception
  return nil
  end

def ytlist(ids)
  ids=[ids] if ids.is_a?(String)
  e = ytquery("videos", {"part"=>"snippet", "id"=>ids.join(",")})
            if e==nil or e['error'] != nil or e['errors'] != nil
    alert(_("Error"))
    return {'items'=>[]}
  end
  return e
end


def convert_book(src,dst)
  if src[-3..-1].downcase=="txt" and dst[-3..-1].downcase=="txt"
    r=readfile(src)
        writefile(dst,r)
    end
  if !FileTest.exists?($extrasdata+"\\Calibre Portable\\Calibre\\ebook-convert.exe")
    s=confirm(p_("EAPI_External", "The file you're trying to open was saved in format that Elten does not support. Do you want to download and install Calibre Library that will allow Elten to read Ebooks?"))
    if s==1
      downloadfile("http://download.calibre-ebook.com/3.46.0/calibre-portable-installer-3.46.0.exe",$tempdir+"\\calibre.exe",p_("EAPI_External", "Please wait, downloading Calibre..."))
      return if !FileTest.exists?($tempdir+"\\calibre.exe") or File.size($tempdir+"\\calibre.exe")<1048576
      speak(p_("EAPI_External", "Please wait, extracting Calibre..."))
      waiting
      executeprocess($tempdir+"\\calibre.exe \".\"",true,0,true,"C:\\")
      copydir("C:\\Calibre Portable",$extrasdata+"/Calibre Portable")
      deldir("C:\\Calibre Portable")
      waiting_end
      File.delete($tempdir+"\\calibre.exe")
    else
      return
    end
    end
    executeprocess("\""+$extrasdata+"\\Calibre Portable\\Calibre\\ebook-convert.exe"+"\" \"#{src}\" \"#{dst}\"",true)
    
  end
end
end