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
$configdata=$eltendata+"\\config"
$soundthemesdata=$eltendata+"\\soundthemes"
$bindata=$eltendata+"\\bin"
if !FileTest.exists?($configdata+"\\appid.dat")
$appid = ""
  chars = ("A".."Z").to_a+("a".."z").to_a+("0".."9").to_a
  64.times { $appid += chars[rand(chars.length)] }
IO.write($configdata+"\\appid.dat",$appid)
else
$appid=IO.read($configdata+"\\appid.dat")
end
if $*.include?("/autostart")
$name=readini($configdata+"\\login.ini","Login","Name","")
erequest("login","login=1\&name=#{$name}\&token=#{readini($configdata+"\\login.ini","Login","Token","")}\&version=#{readini("elten.ini","Elten","Version","")}+agent\&beta=#{readini("elten.ini","Elten","Beta","")}\&appid=#{$appid}\&crp=#{Base64.urlsafe_encode64(cryptmessage(JSON.generate({'name'=>$name,'time'=>Time.now.to_i})))}") {|ans|
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
loop do
if ($li%20)==0
exit if $*.include?("/autostart") and $findwindow.call("RGSS PLAYER","ELTEN")!=0
if $hwnd
exit if !$iswindow.call($hwnd)
if ($phwnd=$getforegroundwindow.call)!=$hwnd and $getparent.call($phwnd)!=$hwnd
$shown=false
if $hidewindow == 1
if $tray != true and FileTest.exists?("bin/elten_tray.bin") and FileTest.exists?("temp/agent_disabletray.tmp") == false
play("minimize")
run("bin\\elten_tray.bin")
$showwindow.call($hwnd,0)
STDOUT.binmode.write((Marshal.dump({'func'=>'tray'})))
STDOUT.flush
$tray=true
end
end
else
$shown = true
$tray = false if FileTest.exists?("temp/agent_tray.tmp") == false
end
end
end
while STDIN.ready? and ($istream==nil||$istream.eof?)
#for i in 0..0#until $istream.eof?
data=Marshal.load(STDIN)
if data['func']=='srvproc'
erequest(data['mod'],data['param']) {|resp|
if resp==nil
data['resp']=resp
else
data['resp']=resp.force_encoding("utf-8")
end
STDOUT.binmode.write((Marshal.dump(data)))
STDOUT.flush
}
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
#end
end
$msg||=0
if $li==0
$lasttime||=Time.now.to_i
$lastvoice=$voice
$lastrate=$rate
$lastvolume=$volume
$voice=readini($configdata+"\\sapi.ini","Sapi","Voice","-1").to_i
$rate=readini($configdata+"\\sapi.ini","Sapi","Rate","50").to_i
$sapisetvoice.call($voice) if $voice>=0 and $lastvoice!=$voice
$sapisetrate.call(readini($configdata+"\\sapi.ini","Sapi","Rate","50").to_i) if $lastrate!=$rate
$hidewindow = readini($configdata + "\\interface.ini","Interface","HideWindow","0").to_i
$refreshtime = readini($configdata + "\\advanced.ini","Advanced","AgentRefreshTime","1").to_i
$volume = readini($configdata + "\\interface.ini","Interface","MainVolume","80").to_i
$soundthemespath = readini($configdata + "\\soundtheme.ini","SoundTheme","Path","")
if $soundthemespath.size > 0
$soundthemepath = $soundthemesdata + "\\" + $soundthemespath
else
$soundthemepath = "Audio"
end
pr="name=#{$name}\&token=#{$token}\&agent=1\&gz=1\&lasttime=#{$wnlasttime||0}"
pr+="\&shown=1" if $shown==true
pr+="\&chat=1" if $chat==true
pr+="\&upd=1" if ($updlasttime||0)<Time.now.to_i-60
erequest("wn_agent",pr) {|ans|
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
end
end
}
q=Notifications.queue
if q.size>10
play 'new'
else
2.times {$getasynckeystate.call(0x11)}
if $wn_agent!=1
q.each do |n|
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
$saytimeperiod = readini($configdata + "\\interface.ini","Interface","SayTimePeriod","1").to_i
$saytimetype = readini($configdata + "\\interface.ini","Interface","SayTimeType","1").to_i
$synctime = readini($configdata + "\\advanced.ini","Advanced","SyncTime","1").to_i
if (($saytimeperiod>0 and m==0) or ($saytimeperiod>1 and m==30) or ($saytimeperiod>=2 and (m==15 or m==45)))
play("clock") if $saytimetype==1 or $saytimetype==3
speech(sprintf("%02d:%02d",tim.hour,tim.min)) if $saytimetype==1 or $saytimetype==2
end
alarms=[]
 if FileTest.exists?($configdata+"\\alarms.dat")
alarms=Marshal.load(IO.binread($configdata+"\\alarms.dat"))
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
IO.binwrite($configdata+"\\alarms.dat",Marshal.dump(alarms))
end
@alarmplaying=true
bgplay("alarm")
IO.write("temp/agent_alarm.tmp",asc.to_s)
end
$timelastsay=tim.hour*60+tim.min
end
if @alarmplaying == true and FileTest.exists?("temp/agent_alarm.tmp") == false
@alarmplaying=false
bgstop
end

end
rescue Interrupt
rescue SystemExit
rescue Exception
STDOUT.binmode.write((Marshal.dump({'func'=>'error','msg'=>$!.to_s,'loc'=>$@.to_s})))
end
$sslsock.close if $sslsock!=nil and !$sslsock.closed?