require 'openssl'
require "socket"
require "securerandom"
require "io/wait"
require 'json'
require 'base64'

class MessageType
Audio=1
Text=2
end

$channels=[]
$users=[]
$users_mutex = Mutex.new
$channels_mutex = Mutex.new

class Channel
attr_accessor :name, :public, :bitrate, :framesize, :password
attr_reader :id
def initialize(id, name, public, bitrate, framesize, password)
@id, @name, @public, @bitrate, @framesize, @password = id, name, public, bitrate, framesize, password
@stamp = 0
update
end
def update
pr=@secret
@secret = SecureRandom.random_bytes(32) while @secret==nil or @secret.getbyte(0)==0 or @secret.getbyte(-1)==0 or @secret==pr
restamp
users = get_users_inchannel(self)
users.each{|u| u.update}
end
def restamp
pr=@stamp
@stamp=rand(256**3) while @stamp==pr || @stamp<65536
end
def secret
@secret+""
end
def stamp
@stamp
end
end
def add_channel(name, public, bitrate, framesize, password)
name="Channel" if !name.is_a?(String)
public=true if public!=false
bitrate=32 if !bitrate.is_a?(Integer)
framesize=60 if !framesize.is_a?(Integer)
password=nil if !password.is_a?(String)
ch=nil
$channels_mutex.synchronize {
ids = $channels.map{|ch|ch.id}
id=(ids.max||0)+1
ch = Channel.new(id, name, public, bitrate, framesize, password)
$channels.push(ch)
}
return ch
end
class User
attr_reader :id, :name, :secret
attr_accessor :channel, :udp, :updated
def initialize(id, name)
@id, @name = id, name
@channel=0
@updated=false
@secret = SecureRandom.bytes(256)
end
def update
@updated=true
end
end
def add_user(name)
usr=nil
$users_mutex.synchronize {
ids = $users.map{|usr|usr.id}
id=(ids.max||0)+1
usr = User.new(id, name)
$users.push(usr)
}
return usr
end
def delete_user(user)
leave_channel(user) if user.channel>0
$users_mutex.synchronize {
$users.delete(user)
}
end

def get_channel_byid(id)
ch=nil
$channels_mutex.synchronize {
$channels.each { |c| ch=c if c.id==id}
}
return ch
end
def get_user_byid(id)
usr=nil
$users_mutex.synchronize {
$users.each { |u| usr=u if u.id==id}
}
return usr
end
def get_user_bysecret(secret)
usr=nil
$users_mutex.synchronize {
$users.each { |u| usr=u if u.secret==secret}
}
return usr
end
def get_users_inchannel(channel)
users=[]
$users_mutex.synchronize {
$users.each {|u|
users.push(u) if u.channel==channel.id
}
}
return users
end
def get_user_byudp(udp)
user=nil
$users_mutex.synchronize {
$users.each {|u| user=u if u.udp==udp}
}
return user
end
def leave_channel(user)
if user.channel>0
channel = get_channel_byid(user.channel)
if channel!=nil
user.channel=0
channel.update
user.update
end
end
end

def join_channel(user, id, password)
id=0 if !id.is_a?(Integer)
channel = get_channel_byid(id)
return nil if channel==nil || channel.password!=password
leave_channel(user) if user.channel!=0
user.channel=channel.id
channel.update
return channel.id
end

def transmit(sender, data)
if verify(sender, data)
users = get_users_inchannel(get_channel_byid(sender.channel))
for u in users
$udp.send(data,0,u.udp[3],u.udp[1])
end
end
end

def extract(data)
userid=data.getbyte(0)+data.getbyte(1)*256
stamp=data.getbyte(2)+data.getbyte(3)*256+data.getbyte(4)*256**2
index=data.getbyte(5)+data.getbyte(6)*256+data.getbyte(7)*256**2
type=data.getbyte(8)
return [userid, stamp, index, type]
end

def verify(sender, data)
return false if data.bytesize<16
userid, stamp, index, type = extract(data)
return false if userid!=sender.id
return true
end

def udp_proc(s)
loop do
data, addr = s.recvfrom(65536)
Thread.new do
u=get_user_byudp(addr)
if u==nil
p u=get_user_bysecret(data)
if u==nil
Thread.exit
end
u.udp=addr
Thread.exit
end
if u.is_a?(User)
transmit(u, data)
end
end
end
end

def tcp_proc(s)
loop do
begin
Thread.start(s.accept) { |c| tcp_session(c) }
rescue Exception
end
end
end

class Session
attr_accessor :user, :time
def initialize
@user=nil
@time=0
end
end

def tcp_session(c)
print("New Session: ")
p c
session=Session.new
session.time=Time.now.to_f
loop do
s=tcp_proceed(c, session) if ((c.ready?)!=false) and (c.ready?)!=nil
break if s==true
break if Time.now.to_f-session.time>60
end
#rescue Exception
#ensure
c.close
delete_user(session.user) if session.user!=nil
p 'finito'
end

def tcp_proceed(socket, session)
user=session.user
suc=true
begin
command = JSON.load(socket.readline)
rescue Exception
suc=false
end
suc=false if suc && !command.is_a?(Hash)
suc=false if suc && command[":command"]==nil
session.time=Time.now.to_i if user!=nil
response = {'status'=>'success'}
if suc
case command[":command"]
when "login"
if command['login']!=nil
delete_user(session.user) if session.user!=nil
user=session.user = add_user(command['login'])
response['id']=user.id
response['login']=command['login']
response['secret']=Base64.strict_encode64(user.secret).delete("\n")
else
suc=false
end
when "join"
if user!=nil
suc=false if join_channel(user, command['channel'], command['password'])==nil
else
suc=false
end
when "leave"
if user!=nil
leave_channel(user)
else
suc=false
end
when "create"
if user!=nil
ch=add_channel(command['name'], command['public'], command['bitrate'], command['framesize'], command['password'])
response['id']=ch.id
response['name']=ch.name
response['bitrate']=ch.bitrate
response['framesize']=ch.framesize
response['public']=ch.public
response['password']=ch.password
else
user=nil
end
when "list"
channels=[]
$channels_mutex.synchronize {
channels=$channels.dup
}
response['channels']=[]
for ch in channels
c={'id'=>ch.id, 'name'=>ch.name, 'bitrate'=>ch.bitrate, 'framesize'=>ch.framesize, 'users'=>[]}
users = get_users_inchannel(ch)
for u in users
c['users'].push({'id'=>u.id, 'name'=>u.name})
end
response['channels'].push(c)
end
when "update"
if user.updated
response['updated']=true
ch=get_channel_byid(user.channel)
if ch!=nil
response['channel']=ch.id
response['channel_secret']=Base64.strict_encode64(ch.secret).delete("\n")
response['channel_stamp']=ch.stamp
response['channel_users']=[]
users=get_users_inchannel(ch)
for u in users
response['channel_users'].push({'id'=>u.id, 'name'=>u.name})
end
end
user.updated=false
else
response['updated']=false
end
when "close"
return true
else
suc=false
end
end
if !suc
response = {'status'=>'error'}
end
begin
socket.write(JSON.generate(response)+"\n")
rescue Exception
end
return false
end

begin
$channels=[]
$users=[]
$clients=[]
ctx = OpenSSL::SSL::SSLContext.new
ctx.key = OpenSSL::PKey::RSA.new(File.read("/etc/ssl/private/elten-net.eu.key"))
ctx.cert = OpenSSL::X509::Certificate.new(File.read("/etc/ssl/private/elten-net.eu.pem"))
tcp = TCPServer.open(nil, 8133)
$tcp = OpenSSL::SSL::SSLServer.new tcp, ctx
$tcp=tcp
$udp = UDPSocket.new
$udp.bind("elten-net.eu", 8133)
Thread.new {udp_proc($udp)}
Thread.new {tcp_proc($tcp)}
sleep
end