#Elten Code
#Copyright (C) 2014-2020 Dawid Pieper
#All rights reserved.

  class Scene_Youtube
  def main
  query = input_text(p_("Youtube","Search Youtube"),"ACCEPTESCAPE")
  if query == "\004ESCAPE\004"
    $scene=Scene_Main.new
    return
  end
          @o=[]
  @ids=[]
  @durations=[]
  @items=[]
  @token=search(query)
  $ytdh=[]
  $ytds=[]
      dialog_open
      o=@o.deep_dup
      o.push(p_("Youtube", "Load more")) if @token!=nil
  sel = Select.new(o,true,0,p_("Youtube","Search results"),true)
  dete=Edit.new(p_("Youtube","Details"),"READONLY|MULTILINE","",true)
  form=Form.new([sel,dete])
details=[]
previewed=false
preview=nil
urls=[]
loop do
  loop_update
  if $key[0x9] and sel.index<@items.size
    if details[sel.index]==nil
    vid=@ids[sel.index]
    ve=ytquery("videos", {"part"=>"id,snippet,contentDetails", "id"=>vid})
      details[sel.index]=ve
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
text=details[sel.index]['items'][0]['snippet']['title']+"\r\n#{p_("Youtube","Duration")}: "+sprintf("%02d:%02d:%02d",h,m,s)+"\r\n#{p_("Youtube","Published on")}: "+pat+"\r\n#{p_("Youtube","Keywords")}: "+details[sel.index]['items'][0]['snippet']['tags'].join(", ")+"\r\n\r\n"+details[sel.index]['items'][0]['snippet']['description']
dete.settext(text)
elsif $key[0x9]
  dete.settext("")
  end
  form.update
  if $key[0x11] and $key[68] and sel.index<@items.size
    if details[sel.index]==nil
    vid=@ids[sel.index]
    ve=ytquery("videos", {"part"=>"id,snippet,contentDetails", "id"=>vid})
      details[sel.index]=ve
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
    return main
        break
  end
  if space and form.index==0 and FileTest.exists?($extrasdata+"\\youtube-dl.exe") and sel.index<@items.size
    if previewed==sel.index
      preview.close
      preview=nil
      previewed=false
      else
    if urls[sel.index]==nil
        waiting
    if @items.size==0
      alert(_("Error"))
      $scene=Scene_Main.new
      return
      end
          suc=false
      statustempfile=$tempdir+"/ytp"+rand(36**2).to_s(36)+".tmp"
            h = run("cmd /c #{$extrasdata}\\youtube-dl.exe --ffmpeg-location bin -g -f bestaudio --extract-audio \"https://youtube.com/watch?v=#{@ids[sel.index]}\" 1> #{statustempfile} 2>\&1",true)
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
  if enter and form.index==0
    if sel.index<@items.size
    preview.close if preview!=nil
    ytfile(@items[sel.index])
    speech_wait
sel.focus
else
  @token=search(query,@token)
  o=@o.deep_dup
      o.push(p_("Youtube", "Load more")) if @token!=nil
  sel.commandoptions=o
  speak(sel.commandoptions[sel.index])
  end
end
end
  
$scene = Scene_Main.new
end
def search(query, token=nil)
  prm={"part"=>"snippet", "q"=>query, "type"=>"video", "maxResults"=>50}
  prm['pageToken']=token if token!=nil
  e=ytquery("search", prm)
  $e=e
          if e==nil or e['error'] != nil or e['errors'] != nil
    alert(_("Error"))
    return
  end
    for i in 0..e['items'].size-1
      @items.push(e['items'][i])
    @o.push(e['items'][i]['snippet']['title']+" .\r\n"+e['items'][i]['snippet']['channelTitle']+" .\r\n"+e['items'][i]['snippet']['description'])
    @o.last.gsub!(/\&[\w]+\;/,"")
    @ids.push(e['items'][i]['id']['videoId'])
  end
  if e['pageInfo']['totalResults']>@items.size
    return e['nextPageToken']
  else
    return nil
    end
    end
  end