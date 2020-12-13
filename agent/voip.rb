# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 

class VoIP

class MessageType
Audio=1
Text=2
end

attr_reader :connected
def initialize
@tcp=nil
@udp=nil
@lasttimesend=0.0
@lasttimereceive=0.0
@uid=nil
@secret=nil
@chid=0
@connected=false
@cipher_mutex=Mutex.new
@cipher=OpenSSL::Cipher::AES256.new :CTR
@channel_secrets=[]
@received={}
@tcp_mutex = Mutex.new
@receive_hooks=[]
@params_hooks=[]
end
def connect(username, token)
tcp=TCPSocket.new("elten-net.eu",8133)
ctx = OpenSSL::SSL::SSLContext.new()
@tcp = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
@tcp.sync_close=true
@tcp.connect
resp=command("login", {'login'=>username, 'token'=>token})
if resp!=false
@uid=resp['id']
@secret=Base64.strict_decode64(resp['secret'])
@tcpthread.exit if @tcpthread!=nil
@tcpthread=Thread.new {
loop {
sleep(1)
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
def create_channel(name, public=true, framesize=60, bitrate=64, password=nil)
command("create", {'name'=>name, 'public'=>public, 'framesize'=>framesize, 'bitrate'=>bitrate, 'password'=>password})
end
def join_channel(id, password=nil)
leave_channel if @chid!=0
r=command("join", {'channel'=>id, 'password'=>password})
update
return r!=false && r['status']=='success'
end
def leave_channel
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
@chid=resp['channel']
@stamp=resp['channel_stamp']
@index=1
@channel_secrets[@stamp]=Base64.strict_decode64(resp['channel_secret']) if resp['channel_secret']!=nil
@received={}
if resp['params']!=nil
@params_hooks.each{|h|Thread.new {h.call(resp['params'])}}
end
end
end
def disconnect
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
def send(type, message, pos_x=7, pos_y=7)
return if @chid==0
pos_x=7 if pos_x<0 || pos_x>15
pos_y=7 if pos_y<0 || pos_y>15
pos=pos_x+pos_y*16
message=message+""
return false if @channel_secrets[@stamp]==nil
crc=Zlib.crc32(message)
bytes=[@uid%256, @uid/256, @stamp%256, (@stamp/256)%256, @stamp/256/256, @index%256, @index/256, type, pos, 0, 0, 0, crc%256, (crc/256)%256, (crc/256/256)%256, crc/256/256/256]
@index+=1
data=("\0"*16).b
for i in 0...16
return false if bytes[i]>255
data.setbyte(i, bytes[i])
end
@cipher_mutex.synchronize {
@cipher.encrypt
@cipher.key=@channel_secrets[@stamp]
@cipher.iv=data
data+=@cipher.update(message.b).b+@cipher.final.b
}
@udp.send(data, 0, "elten-net.eu", 8133)
@lasttimesend=Time.now.to_f
return true
end
def on_params(&block)
@params_hooks.push(block) if block!=nil
end
def on_receive(&block)
@receive_hooks.push(block) if block!=nil
end
private
def connect_udp
@udpthread.exit if @udpthread!=nil
@udp=UDPSocket.new()
@udp.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVBUF, 16777216)
@udp.send(@secret, 0, "elten-net.eu", 8133)
@udpthread = Thread.new {
@lasttimesend=0.0
@lasttimereceive=0.0
loop {
begin
data, addr = @udp.recvfrom_nonblock(65536)
if @chid!=0
@lasttimereceive=Time.now.to_f
receive(data)
end
rescue IO::EWOULDBLOCKWaitReadable
IO.select([@udp], nil, nil, 0.01)
rescue IO::EWOULDBLOCKWaitWritable
IO.select(nil, [@udp], nil, 0.01)
rescue Exception
end
if @lasttimesend-@lasttimereceive>3 && @lasttimesend>0 && @lasttimereceive>0
Thread.new {connect_udp}
break
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
data=data+""
data=data.b
userid, stamp, index, type = extract(data)
@received[userid]||=[]
return if @received[userid].include?(index)
@received[userid].push(index)
message = ""
crc=data.getbyte(12)+data.getbyte(13)*256+data.getbyte(14)*256**2+data.getbyte(15)*256**3
pos=data.getbyte(8)
pos_x=pos%16
pos_y=pos/16
@cipher_mutex.synchronize {
@cipher.decrypt
@cipher.iv=data.byteslice(0...16)
@cipher.key=@channel_secrets[stamp]||@channel_secrets[@stamp]
message=@cipher.update(data.byteslice(16..-1)).b+@cipher.final
}
@receive_hooks.each{|h|h.call(userid, type, message, pos_x, pos_y)} if Zlib.crc32(message)==crc
rescue Exception
end
def executecommand(cmd, params={})
return false if @tcp==false
json={':command'=>cmd}
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
@tcp.write(txt.b+"\n")
rescue Exception
rec=true
end
}
return rec
end
def command(cmd, params={})
executecommand(cmd, params)
rec=false
begin
ans=@tcp.readline
rescue Exception
rec=true
end
if rec==false
json = JSON.load(ans)
return false if json['status']!='success'
return json
else
disconnect
return false
end
end
end