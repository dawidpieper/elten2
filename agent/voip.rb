# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class VoIP

CommandAliases = {'update'=>1}
ResponseAliases={'success'=>0,'error'=>1}

class MessageType
Audio=1
Text=2
Whisper=3
Reemit=201
Ping=251
Pong=252
end

attr_reader :connected, :latency, :uid
def initialize
@latency=0
@sendtimes={}
@receivetimes={}
@sendbytes=0
@receivedbytes=0
@cur_rx_packets=0
@cur_lostpackets=0
@starttime=Time.now.to_f
@key = OpenSSL::PKey::RSA.new(2048)
@tcp=nil
@udp=nil
@uid=nil
@secret=nil
@chid=0
@connected=false
@cipher_mutex=Mutex.new
@cipher=OpenSSL::Cipher::AES256.new :CTR
@channel_secrets=[]
@received={}
@pings={}
@tcp_mutex = Mutex.new
@receive_hooks=[]
@params_hooks=[]
@status_hooks=[]
@ping_hooks=[]
end
def connect(username, token)
tcp=TCPSocket.new("conferencing.elten.link",8133)
ctx = OpenSSL::SSL::SSLContext.new()
@tcp = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
@tcp.sync_close=true
@tcp.connect
command("session_encodings", {'encodings'=>['deflate','xz']})
command("session_aliasversion", {'version'=>1})
resp=command("login", {'login'=>username, 'token'=>token, 'publickey'=>Base64.strict_encode64(@key.public_key.to_der)})
if resp!=false
@uid=resp['id']
@secret=Base64.strict_decode64(resp['secret'])
@tcpthread.exit if @tcpthread!=nil
@tcpthread=Thread.new {
loop {
sleep(0.5)
update
}
}
connect_udp
@connected=true
else
return false
end
return true
rescue Exception
return false
end
def create_channel(name, public=true, framesize=60, bitrate=64, password=nil, spatialization=0, channels=2, lang='', width=15, height=15, key_len=256, waiting_type=0)
st=command("create", {'name'=>name, 'public'=>public, 'framesize'=>framesize, 'bitrate'=>bitrate, 'password'=>password, 'spatialization'=>spatialization, 'channels'=>channels, 'lang'=>lang, 'width'=>width, 'height'=>height, 'key_len'=>key_len, 'waiting_type'=>waiting_type})
log(-1, "Conference: created channel of id #{st['id']}")
return st
end
def edit_channel(id, name, public=true, framesize=60, bitrate=64, password=nil, spatialization=0, channels=2, lang='', width=15, height=15, key_len=256, changePassword=false)
prm={'channel'=>id, 'name'=>name, 'public'=>public, 'framesize'=>framesize, 'bitrate'=>bitrate, 'spatialization'=>spatialization, 'channels'=>channels, 'lang'=>lang, 'width'=>width, 'height'=>height, 'key_len'=>key_len}
prm['password']=password if changePassword
st=command("edit", prm)
log(-1, "Conference: edited channel of id #{id}")
return st
end
def join_channel(id, password=nil)
log(-1, "Conference: joining channel #{id}")
r=command("join", {'channel'=>id, 'password'=>password})
update
st=r!=false && r['status']=='success'
if st==true
log(-1, "Conference: joined channel #{id}")
else
log(-1, "Conference: failed to join channel #{id}")
end
return st
end
def leave_channel
log(-1, "Conference: leaving channel")
r=command("leave")
update
return r!=false && r['status']=='success'
end
def list_channels
cmd=command('list')
return {} if cmd==false
return cmd['channels']
end
def update
resp=command("update")
if resp.is_a?(Hash) && resp['updated']
log(-1, "Conference: updating parameters")
@chid=resp['channel']
@stamp=resp['channel_stamp']
@cur_rx_packets=0
@cur_lostpackets=0
@index=1
@channel_secrets[@stamp]=Base64.strict_decode64(resp['channel_secret']) if resp['channel_secret']!=nil
@received={}
if resp['params']!=nil
@params_hooks.each{|h|Thread.new {h.call(resp['params'])}}
end
end
end
def disconnect
log(0, "Conference: disconnecting from server")
if @udpthread!=nil
@udpthread.exit
@udpthread=nil
end
if @tcpthread!=nil
@tcpthread.exit
@tcpthread=nil
end
if @tcp!=nil
executecommand("close")
@tcp.close
end
@cipher_mutex.synchronize {
@tcp_mutex.synchronize {
@tcp=@udp=nil
}
}
@connected=false
end
def send(type, message, p1=0, p2=0)
return if @chid==0
return if (message=="" && type<100) || !message.is_a?(String)
message=message+""
return false if @channel_secrets[@stamp]==nil
crc=Zlib.crc32(message)
bytes=[@uid%256, @uid/256, @stamp%256, (@stamp/256)%256, @stamp/256/256, @index%256, @index/256, type, p1, p2, 0, 0, crc%256, (crc/256)%256, (crc/256/256)%256, crc/256/256/256]
@index+=1
data=("\0"*16).b
for i in 0...16
return false if bytes[i]>255
data.setbyte(i, bytes[i])
end
@cipher_mutex.synchronize {
if message!=""
if @stamp!=0 && @channel_secrets[@stamp]!=nil && @channel_secrets[@stamp].bytesize!=0
key=@channel_secrets[@stamp]
if @cipher.key_len!=key.bytesize
case key.bytesize
when 16
@cipher=OpenSSL::Cipher::AES128.new :CTR
when 24
@cipher=OpenSSL::Cipher::AES192.new :CTR
when 32
@cipher=OpenSSL::Cipher::AES256.new :CTR
end
end
@cipher.encrypt
@cipher.key=key
@cipher.iv=data
data+=@cipher.update(message.b).b+@cipher.final.b
else
data+=message.b
end
end
}
@sendtimes[@index-1]=Time.now.to_f
@sendbytes+=data.bytesize
@udp.send(data, 0, "conferencing.elten.link", 8133)
return true
end
def on_params(&block)
@params_hooks.push(block) if block!=nil
end
def on_receive(&block)
@receive_hooks.push(block) if block!=nil
end
def on_status(&block)
@status_hooks.push(block) if block!=nil
end
def on_ping(&block)
@ping_hooks.push(block) if block!=nil
end
def mute(user)
log(-1, "Conference: muting user #{user}")
command("mute", {'user'=>user})
end
def unmute(user)
log(-1, "Conference: unmuting user #{user}")
command("unmute", {'user'=>user})
end
def kick(userid)
log(-1, "Conference: kicking user #{userid}")
command("kick", {'userid'=>userid})
end
def ban(username)
log(-1, "Conference: banning user #{username}")
command("ban", {'username'=>username})
end
def unban(username)
log(-1, "Conference: unbanning user #{username}")
command("unban", {'username'=>username})
end
def admin(username)
log(-1, "Conference: granting administration to user #{username}")
command("admin", {'username'=>username})
end
def public_key(userid)
c=command("publickey", {'userid'=>userid})
return nil if c==false
return nil if c['publickey']==nil || c['publickey']==""
return OpenSSL::PKey::RSA.new(Base64.strict_decode64(c['publickey']))
rescue Exception
log("Conference: public_key error: #{$!.to_s}")
return nil
end
def object_add(resid, name, x, y)
return command("object_add", {'resid'=>resid, 'name'=>name, 'x'=>x, 'y'=>y})['id']
end
def object_remove(id)
command("object_remove", {'id'=>id})
end
def ping
r=0
r=rand(16777216) while @pings.keys.include?(r) || r==0
@pings[r]=Time.now
t=@pings[r].sec*1000+@pings[r].usec/1000
message=[r].pack("I")
send(251, message, t%256, t/256)
end
def pong(message)
t=Time.now.sec*1000+Time.now.usec/1000
send(252, message, t%256, t/256)
end
def diceroll(t=6)
log(-1, "Conference: rolling #{t}-sided dice")
send(101, "", t, 0)
end
def deck_add(type)
command("deck_add", {'type'=>type})!=false
end
def deck_reset(deck)
send(114, "", deck)
end
def deck_remove(deck)
command("deck_remove", {'deck'=>deck})!=false
end
def cards
resp=command("cards")
if resp!=false
return resp['cards']
else
return nil
end
end
def decks
resp=command("decks")
if resp!=false
return resp['decks']
else
return nil
end
end
def card_pick(deck, cid=0)
cid=0 if !cid.is_a?(Numeric)
send(111, "", deck, cid)
end
def card_change(deck, cid)
send(112, "", deck, cid)
end
def card_place(deck, cid)
send(113, "", deck, cid)
end
def key
@key
end
private
def connect_udp
log(0, "Conference: connecting to server")
@udpthread.exit if @udpthread!=nil
@udp=UDPSocket.new()
@udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVBUF, 16777216)
@udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, 16777216)
@sendbytes+=@secret.bytesize
@udp.send(@secret, 0, "conferencing.elten.link", 8133)
@udpthread = Thread.new {
loop {
begin
data, addr = @udp.recvfrom_nonblock(1500)
@receivedbytes+=data.bytesize
if @chid!=0
receive(data)
end
rescue IO::EWOULDBLOCKWaitReadable
IO.select([@udp], nil, nil, 0.1)
rescue IO::EWOULDBLOCKWaitWritable
IO.select(nil, [@udp], nil, 0.1)
rescue Exception
log(2, "VoIP UDP: "+$!.to_s+" "+$@.to_s)
end
}
}
end
def extract(data)
userid=data.getbyte(0)+data.getbyte(1)*256
stamp=data.getbyte(2)+data.getbyte(3)*256+data.getbyte(4)*256**2
index=data.getbyte(5)+data.getbyte(6)*256
type=data.getbyte(7)
return [userid, stamp, index, type]
end
def receive(data)
receiveTime=Time.now
data=data+""
data=data.b
userid, stamp, index, type = extract(data)
@received[userid]||=[]
@cur_rx_packets+=1
if index>10
cr=index-(@received[userid].max||0)-1
@cur_lostpackets+=cr if cr>0 && cr<5
end
return if userid!=0 && @received[userid].include?(index)
@received[userid].push(index) if userid!=0
message = ""
crc=data.getbyte(12)+data.getbyte(13)*256+data.getbyte(14)*256**2+data.getbyte(15)*256**3
p1=data.getbyte(8)
p2=data.getbyte(9)
if data.bytesize>16
@cipher_mutex.synchronize {
key=@channel_secrets[stamp]||@channel_secrets[@stamp]
if stamp!=0 && key!=nil && key.bytesize!=0
if @cipher.key_len!=key.bytesize
case key.bytesize
when 16
@cipher=OpenSSL::Cipher::AES128.new :CTR
when 24
@cipher=OpenSSL::Cipher::AES192.new :CTR
when 32
@cipher=OpenSSL::Cipher::AES256.new :CTR
end
end
@cipher.decrypt
@cipher.iv=data.byteslice(0...16)
@cipher.key=key
message=@cipher.update(data.byteslice(16..-1)).b+@cipher.final.b
else
message=data.byteslice(16..-1).b
end
}
end
if userid==@uid
@receivetimes[index]=Time.now.to_f
if @receivetimes.size>50
s=0
r=0
c=0
for ind in @receivetimes.keys
if @sendtimes[ind]!=nil
r+=@receivetimes[ind]
s+=@sendtimes[ind]
c+=1
end
end
@receivetimes.clear
@sendtimes.clear
@latency=(r-s)/c.to_f
end
end
if Time.now.to_f-(@statustime||0)>5
@status_hooks.each{|h| h.call(@latency, @sendbytes, @receivedbytes, @cur_lostpackets, @cur_rx_packets, Time.now.to_f-@starttime)}
@statustime=Time.now.to_f
end
if type<200
if Zlib.crc32(message)==crc || crc==0
@receive_hooks.each{|h|h.call(userid, type, message, p1, p2)}
end
else
case type
when 251
pong(message)
when 252
return if message.bytesize<4
m=message.unpack("I").first
if @pings.include?(m)
lt=@pings[m]
@pings.delete(m)
rt=receiveTime
t=rt-lt
@ping_hooks.each{|h|h.call(t.to_f)}
end
end
end
rescue Exception
log(2, "VoIP Receive: "+$!.to_s+" "+$@.to_s)
end
def executecommand(cmd, params={})
return false if @tcp==false
json={':command'=>cmd}
if CommandAliases[cmd].is_a?(Numeric)
json[':c']=CommandAliases[cmd]
json.delete(":command")
end
for k in params.keys
json[k]=params[k]
end
for k in json.keys
if json[k].is_a?(String)
json[k]=json[k]+""
json[k].force_encoding("UTF-8")
end
end
ans=nil
rec=false
txt=JSON.generate(json)
@tcp_mutex.synchronize {
begin
if txt.bytesize>64 && txt.bytesize<128
z=Zlib::Deflate.deflate(txt.b)
s="d"+z.bytesize.to_s(36)+"\n"+z
@tcp.write(s)
@tcp.flush
@sendbytes+=s.bytesize
elsif txt.bytesize>=128
z=XZ.compress(txt.b)
s="x"+Base62.encode(z.bytesize)+"\n"+z
@tcp.write(s)
@tcp.flush
@sendbytes+=s.bytesize
else
s=txt+"\n"
@tcp.write(s)
@tcp.flush
@sendbytes+=s.bytesize
end
rescue Exception
rec=true
end
}
return rec
end
def command(cmd, params={})
@cmd_mutex||=Mutex.new
rec=false
ans=nil
@cmd_mutex.synchronize {
executecommand(cmd, params)
begin
ans=@tcp.readline
@receivedbytes+=ans.bytesize
rescue Exception
rec=true
end
}
if rec==false
if ans!=nil && ans.getbyte(0)=="d".getbyte(0)
ns=ans
size=ns.byteslice(1...-1).to_i(36)
a=@tcp.read(size)
@receivedbytes+=size
ans=Zlib::Inflate.inflate(a)
elsif ans!=nil && ans.getbyte(0)=="x".getbyte(0)
ns=ans
size=Base62.decode(ns.byteslice(1...-1))
a=@tcp.read(size)
@receivedbytes+=size
ans=XZ.decompress(a)
end
json = JSON.load(ans)
json['status'] = ResponseAliases.key(json[':s']) if json.is_a?(Hash) && json[':s'].is_a?(Numeric) && ResponseAliases.key(json[':s']).is_a?(String)
return false if json['status']!='success'
return json
else
disconnect
return false
end
end
end