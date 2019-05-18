require("./bass.rb")

def unicode(str)
buf="\0"*$multibytetowidechar.call(65001,0,str,str.bytesize,nil,0)*2
$multibytetowidechar.call(65001,0,str,str.bytesize,buf,buf.bytesize/2)
return buf    <<"\0"
end
  def deunicode(str)
return "" if str==nil
str<<"\0\0"
buf="\0"*$widechartomultibyte.call(65001,0,str,-1,nil,0,0,nil)
$widechartomultibyte.call(65001,0,str,-1,buf,buf.bytesize,nil,nil)
return buf[0..buf.index("\0")-1]
end
def readini(file,group,key,default="")
        r = "\0" * 16384
sz=$getprivateprofilestring.call(unicode(group),unicode(key),unicode(default),r,r.bytesize,unicode(file))
    return deunicode(r[0..(sz*2)]).delete("\0")
  end
def speech(text,method=0)
  text = text.to_s
    text = text.gsub("\004LINE\004") {"\r\n"}
$speech_lasttext = text
(($voice!=-1)?$sapisaystring:$saystring).call(unicode(text),method)
$speech_lasttime=Time.now.to_f
return text
end
def speech_stop
(($voice!=-1)?$sapistopspeech:$stopspeech).call
end
def speech_actived
($voice==-1)?false:(($sapiisspeaking.call==1)?true:false)
end
def speech_wait
sleep 0.01 while speech_actived
end
def run(file,hide=false)
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0] if hide
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
        pr = $createprocess.call(0, (file), 0, 0, 0, 0, 0, 0, startinfo, procinfo)
            procinfo[0,4].unpack('L').first # pid
            return procinfo.unpack('llll')[0]
          end
def getdirectory(type)
  dr = "\0" * 520
$shgetfolderpath.call(0,type,0,0,dr)
  fdr=deunicode(dr)
      return fdr[0..fdr.index("\0")||-1]
end

def init
$http = NetHttp2::Client.new("https://elten-net.eu", connect_timeout: 5)
$http.on(:error) { |error|
init if error.is_a?(Errno::ECONNRESET) or error.is_a?(SocketError)
}
end

def erequest(mod, param, data=nil, &b)
init if $http==nil
tries=0
$lastrep||=Time.now.to_i
init if $lastrep<Time.now.to_i-10
begin
request = $http.prepare_request(:get, "/srv/#{mod}.php?#{param}")
body=""
request.on(:body_chunk) {|ch| body+=ch}
request.on(:close) {$lastrep=Time.now.to_i; b.call(body)}
$http.call_async request
rescue Exception
sleep(1)
init
sleep(0.5)
retry if tries<3
end
end

def play(file)
f=$soundthemepath+"\\SE\\#{file}.ogg"
f="Audio/SE/#{file}.ogg" if FileTest.exists?(f)==false
#begin
$plid||=0
$players||=[]
$plid=($plid+1)%128
plid=$plid
$players[plid].close if $players[plid]!=nil
$players[plid]=Bass::Sound.new(f)
$players[plid].volume=($volume.to_f/100.0)
$players[plid].play
#rescue Exception
#end
end

def bgplay(file)
begin
@bgplayer.close if @bgplayer
@bgplayer=Bass::Sound.new($soundthemespath+"\\SE\\#{file}.ogg",1,true)
@bgplayer.play
rescue Exception
end
end

def bgstop
if @bgplayer!=nil
@bgplayer.close
@bgplayer=nil
end
end