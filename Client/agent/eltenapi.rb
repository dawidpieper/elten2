require("./bass.rb")

def cryptmessage(msg)
buf="\0"*(msg.bytesize+18)
begin
$cryptmessage.call(msg,buf,buf.bytesize)
return buf
rescue Exception
return ""
end
end

def unicode(str)
return nil if str==nil
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
def readconfig(group, key, val="")
  r=readini($eltendata+"\\elten.ini", group, key, val.to_s)
  return r.to_i if val.is_a?(Integer)
  return r
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
$http.on(:error) { |error| init if error.is_a?(Errno::ECONNRESET) or error.is_a?(SocketError) }
end

def erequest(mod, param, post=nil, headers={}, data=nil, ign=false, &b)
headers={} if headers==nil
headers['User-Agent']="Elten #{$version} agent"
init if $http==nil
tries=0
$lastrep||=Time.now.to_i
init if $lastrep<Time.now.to_i-20
$equeue||=[]
id=($equeue.max||0)+1
begin
return if ign and ($eropened!=nil and $eropened>Time.now.to_f-15)
$equeue.push(id) if !ign
sleep(0.01) while $eropened!=nil and $eropened>Time.now.to_f-15 and (!ign or $equeue.first!=id)
$eropened=Time.now.to_f
if !ign and ((t=Time.now).min%15==14 and t.sec==59)
sleep(60-t.sec+2)
end
if post==nil
request = $http.prepare_request(:get, "/srv/#{mod}.php?#{param}", headers: headers)
else
request = $http.prepare_request(:post, "/srv/#{mod}.php?#{param}", body: post, headers: headers)
end
body=""
request.on(:body_chunk) {|ch| body+=ch}
request.on(:close) {$eropened=nil;$lastrep=Time.now.to_i;$equeue.delete(id) if !ign;b.call(body,data)}
request.on(:error) {$eropened=nil;$equeue.delete(id) if !ign;b.call(:error,data)}
$http.call_async request
rescue Exception
init
$equeue.delete(id) if id!=nil
retry
end
end

def play(file, looper=false)
begin
if file[0..3]!="http"
f=($soundthemepath||"Audio")+"\\SE\\#{file}.ogg"
f="Audio/SE/#{file}.ogg" if FileTest.exists?(f)==false
f="Audio/BGS/#{file}.ogg" if FileTest.exists?(f)==false
else
f=file
end
$plid||=0
$players||=[]
$plid=($plid+1)%128
plid=$plid
begin
pl=Bass::Sound.new(f, 1, looper)
pl.volume=($volume.to_f/100.0)
pl.play
if looper
$bgplayer.close if $bgplayer!=nil
$bgplayer=pl
else
$players[plid].close if $players[plid]!=nil
$players[plid]=pl
end
rescue Exception
begin
Bass.init($hwnd||0)
rescue Exception
end
end
rescue Exception
end
end

def log(level,msg)
STDOUT.binmode.write((Marshal.dump({'func'=>'log', 'level'=>level, 'msg'=>msg, 'time'=>Time.now.to_f})))
STDOUT.flush
end

def decrypt(data,code=nil)
        pin=[data.size,data].pack("ip")
pout=[0,nil].pack("ip")
pcode=nil
pcode=[code.size,code].pack("ip") if code!=nil
$cryptunprotectdata.call(pin,nil,pcode,nil,nil,0,pout)
s,t = pout.unpack("ii")
m="\0"*s
$rtlmovememory.call(m,t,s)
$localfree.call(t)  
return m
          end

def crypt(data,code=nil)
        pin=[data.size,data].pack("ip")
pout=[0,nil].pack("ip")
pcode=nil
pcode=[code.size,code].pack("ip") if code!=nil
$cryptprotectdata.call(pin,nil,pcode,nil,nil,0,pout)
s,t = pout.unpack("ii")
m="\0"*s
$rtlmovememory.call(m,t,s)
$localfree.call(t)  
return m
          end