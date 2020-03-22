Encoding.default_internal=Encoding::UTF_8
$VERBOSE = nil
require "json/pure"
require "digest"
require "digest/sha1"
require "digest/sha2"
require "digest/md5"
require "digest/rmd160"
require "digest/bubblebabble"
require "net-http2"
require "fiddle"
require "zlib"
require "./dlls.rb"
require("./eltenapi.rb")

class Notification
attr_accessor :alert, :sound, :id
def initialize(alert=nil,sound=nil, id="nocat".rand(10**16).to_s)
@alert, @sound, @id =alert, sound, id
end
end

$sigids=[]

module Notifications
class <<self
def notifications
@notifications||={}
end
def notids
@notids||=[]
end
def join(alert,sound=nil,id='jn_'+rand(10**10).to_s)
push Notification.new(alert,sound,id)
end
def push(n)
if !notids.include?(n.id)
notifications[n.id]=n
notids.push(n.id)
return true
else
return false
end
end
def queue
arr=notifications.values.dup
notifications.clear
return arr
end
end
end

begin
$setcurrentdirectory.call("..") if FileTest.exists?("../elten.ini") and !FileTest.exists?("elten.ini")
$setcurrentdirectory.call("..\\..") if FileTest.exists?("../../elten.ini") and !FileTest.exists?("elten.ini")
$setdlldirectory.call(".")
$eltendata=getdirectory(26)+"\\elten"
$eltendata=".\\eltendata" if readini("elten.ini","Elten","Portable","0").to_i.to_i!=0
$soundthemesdata=$eltendata+"\\soundthemes"
$bindata=$eltendata+"\\bin"
$tempdir=$eltendata+"\\temp"
if !FileTest.exists?($eltendata+"\\appid.dat")
$appid = ""
  chars = ("A".."Z").to_a+("a".."z").to_a+("0".."9").to_a
  64.times { $appid += chars[rand(chars.length)] }
IO.write($eltendata+"\\appid.dat",$appid)
else
$appid=IO.read($eltendata+"\\appid.dat")
end
$version=readini("./elten.ini","Elten","Version","").to_f
if $*.include?("/autostart")
$name=readconfig("Login","Name","")
token=readconfig("Login","Token","")
tokenenc = readconfig("Login","TokenEncrypted","-1").to_i
token=decrypt(Base64.strict_decode64(token)) if tokenenc==1
if tokenenc==2
$messagebox.call(0,"Cannot start Elten automatically, because the autologin token is protected with a pin code","Elten autostart failed",16)
exit
end
erequest("login","login=1\&name=#{$name}\&token=#{token}\&version={$version}+agent\&beta=#{readini("elten.ini","Elten","Beta","")}\&appid=#{$appid}\&crp=#{Base64.urlsafe_encode64(cryptmessage(JSON.generate({'name'=>$name,'time'=>Time.now.to_i})))}") {|ans|
if ans!=nil
d=ans.split("\r\n")
if d[0].to_i==0
$token=d[1]
run("bin\\elten_tray.bin /autostart")
else
exit
end
end
}
sleep(0.1) while !$token
else
$name||=STDIN.gets.delete("\r\n")
$token||=STDIN.gets.delete("\r\n")
$hwnd||=STDIN.gets.delete("\r\n").to_i
end
Bass.init($hwnd||0)
$upd={}
$upd['version']=readini("./elten.ini","Elten","Version","0").to_f
$upd['alpha']=readini("./elten.ini","Elten","Alpha","0").to_i
$upd['beta']=readini("./elten.ini","Elten","Beta","0").to_i
$upd['isbeta']=readini("./elten.ini","Elten","IsBeta","0").to_i
$wn={}
$li=0
$soundcard=nil
log(0, "Agent initialized")
loop do
if ($li%20)==0
exit if $*.include?("/autostart") and $findwindow.call("RGSS PLAYER","ELTEN")!=0
if $hwnd
exit if !$iswindow.call($hwnd)
if ($phwnd=$getforegroundwindow.call)!=$hwnd and $getparent.call($phwnd)!=$hwnd
log(0, "Elten window minimized") if $shown==true
$shown=false
if $hidewindow == 1
if $tray != true and FileTest.exists?("bin/elten_tray.bin")
play("minimize")
run("bin\\elten_tray.bin")
$showwindow.call($hwnd,0)
STDOUT.binmode.write((Marshal.dump({'func'=>'tray'})))
STDOUT.flush
$tray=true
end
end
else
log(0, "Elten window restored") if $shown==false
$shown = true
$tray = false
end
end
end
while STDIN.ready? and ($istream==nil||$istream.eof?)
data=Marshal.load(STDIN)
if data['func']=='srvproc'
data['reqtime']=Time.now.to_f
erequest(data['mod'],data['param'],data['post'],data['headers'],data) {|resp,d|
if resp==:error
log(2,"Request error: #{d['func']}")
d['resptime']=Time.now.to_f
d['resp']='-4'
else
d['resp']=(resp||"").force_encoding("utf-8")
d['resptime']=Time.now.to_f
STDOUT.binmode.write((Marshal.dump(d)))
STDOUT.flush
end
}
elsif data['func']=="alarm_stop"
$alarmstop=true
elsif data['func']=="chat_open"
$chat=true
elsif data['func']=="chat_close"
$chat = false
elsif data['func']=='relogin'
$name=data['name']
$token=data['token']
elsif data['func']=='msg_suppress'
$msg_suppress=true
end
end
$msg||=0
if $li==0
$lasttime||=Time.now.to_i
$lastvoice=$voice
$lastrate=$rate
$lastvolume=$volume
$lastsoundcard=$soundcard
$voice=readconfig("Voice","Voice","-1").to_i
$rate=readconfig("Voice","Rate","50").to_i
$sapisetvoice.call($voice) if $voice>=0 and $lastvoice!=$voice
$sapisetrate.call(readconfig("Voice","Rate","50").to_i) if $lastrate!=$rate
$hidewindow = readconfig("Interface","HideWindow","0").to_i
$refreshtime = readconfig("Advanced","AgentRefreshTime","1").to_i
$volume = readconfig("Interface","MainVolume","70").to_i
$soundcard = readconfig("SoundCard","SoundCard",nil)
$soundcard=nil if $soundcard==""
if $lastsoundcard!=$soundcard
log(0, "SoundCard changed: #{$soundcard}")
Bass.set_card($soundcard, $hwnd||0)
end
$soundthemespath = readconfig("Interface","SoundTheme","")
if $soundthemespath.size > 0
$soundthemepath = $soundthemesdata + "\\" + $soundthemespath
else
$soundthemepath = "Audio"
end
pr="name=#{$name}\&token=#{$token}\&agent=1\&gz=1\&lasttime=#{$wnlasttime||0}"
pr+="\&shown=1" if $shown==true
pr+="\&chat=1" if $chat==true
pr+="\&upd=1" if ($updlasttime||0)<Time.now.to_i-60
begin
erequest("wn_agent",pr, nil,nil,nil, true) {|ans|
if ans!=nil
begin
rsp=JSON.load(Zlib.inflate(ans))
$wnlasttime=rsp['time'] if rsp['time'].is_a?(Integer)
$updlasttime=rsp['time'] if rsp['time'].is_a?(Integer) and rsp['upd']!=nil
$ag_msg||=rsp['msg'].to_i
if $ag_msg<(rsp['msg'].to_i||0)
$ag_msg=rsp['msg'].to_i
STDOUT.binmode.write((Marshal.dump({'func'=>'msg','msgs'=>$ag_msg})))
STDOUT.flush
end
if rsp['signals'].is_a?(Array)
for sig in rsp['signals']
if !$sigids.include?(sig['id'])
STDOUT.binmode.write((Marshal.dump({'func'=>'sig','appid'=>sig['appid'],'time'=>sig['time'],'packet'=>sig['packet'],'sender'=>sig['sender'], 'id'=>sig['id']})))
STDOUT.flush
$sigids.push(sig['id'])
end
end
end
begin
if rsp['upd'].is_a?(Hash)
if rsp['upd']['version'].to_f>$upd['version'].to_f
Notifications.join('Elten '+rsp['upd']['version'].to_s,'new','upd_'+rsp['upd']['version'].to_s)
elsif rsp['upd']['beta'].to_f>$upd['beta'].to_f and $upd['isbeta']==1
Notifications.join('Elten '+$upd['version'].to_s+" beta "+rsp['upd']['beta'].to_s,'new','upd_'+rsp['upd']['beta'].to_s)
end
end
end
if rsp['wn'].is_a?(Array)
rsp['wn'].each do |n|
Notifications.join(n['alert'],n['sound'],n['id'])
end
end
if (rsp['wn']||[]).size==0
$wn_agent||=2
else
$wn_agent||=1
end
rescue JSON::ParserError => e
log(2, "JSON Parse Error")
end
end
}
end
q=Notifications.queue
if q.size>10
play 'new'
else
2.times {$getasynckeystate.call(0x11)}
if $wn_agent!=1
q.each do |n|
log(0, "New notification: #{n.id.to_s}, #{n.alert.to_s}")
speech n.alert
play n.sound if n.sound!=nil
while speech_actived
speech_stop if $getasynckeystate.call(0x11)!=0 and $voice>=0 and Time.now.to_f-($speech_lasttime||0)>0.1
sleep 0.01
end
end
else
$wn_agent=2
end
end
end
sleep(0.02)
$li+=1
$li=0 if $li>=$refreshtime*50
$tm=$wnlasttime if $wnlasttime!=nil
$tm=Time.now.to_i if $synctime==0 or $tm==nil
tim=Time.at($tm)
m=tim.min
if $timelastsay!=tim.hour*60+tim.min
$saytimeperiod = readconfig("Clock","SayTimePeriod","1").to_i
$saytimetype = readconfig("Clock","SayTimeType","1").to_i
$synctime = readconfig("Advanced","SyncTime","1").to_i
if (($saytimeperiod>0 and m==0) or ($saytimeperiod>1 and m==30) or ($saytimeperiod>=2 and (m==15 or m==45)))
play("clock") if $saytimetype==1 or $saytimetype==3
speech(sprintf("%02d:%02d",tim.hour,tim.min)) if $saytimetype==1 or $saytimetype==2
end
alarms=[]
 if FileTest.exists?($eltendata+"\\alarms.dat")
alarms=Marshal.load(IO.binread($eltendata+"\\alarms.dat"))
end
asc=nil
for i in 0..alarms.size-1
a=alarms[i]
if tim.hour==a[0] and tim.min==a[1]
asc=i
end
end
if asc != nil
a=alarms[asc]
if a[2]==0
alarms.delete_at(asc)
IO.binwrite($eltendata+"\\alarms.dat",Marshal.dump(alarms))
end
@alarmplaying=true
play("alarm",true)
STDOUT.binmode.write((Marshal.dump({'func'=>'alarm'})))
STDOUT.flush
end
$timelastsay=tim.hour*60+tim.min
end
if @alarmplaying == true and $alarmstop==true
$alarmstop=false
@alarmplaying=false
if $bgplayer!=nil
$bgplayer.close
$bgplayer=nil
end
end

end
rescue Interrupt
rescue SystemExit
rescue Exception
STDOUT.binmode.write((Marshal.dump({'func'=>'error','msg'=>$!.to_s,'loc'=>$@.to_s})))
end
$sslsock.close if $sslsock!=nil and !$sslsock.closed?