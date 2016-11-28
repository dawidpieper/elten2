#encoding: utf-8

$stderr.reopen("importer_error.log", "w")
$outer = IO.new(0)
$outer.reopen("importer.log","w")

require("socket")
require("mysql")
def recvline(sock)
r = ""
loop do
s = sock.recv(1)
r += s
break if s == "\n" or s == nil or s == ""
s = nil
end
return r
end
begin
include Socket::Constants
class StartClass
def aputs(text)
$stdout.puts(text)
$outer.puts(text)
end
def initialize
$sock = Socket.new(AF_INET, :STREAM)
$sock.bind(Addrinfo.tcp("5.196.225.236",2442))
$mysql = Mysql.new("localhost","dbuser","dbpass","dbname")
tm = Time.now
aputs("INFO: Importer Started   |   " + tm.getlocal.to_s)
main
end
def main
begin
loop do
$sock.listen(1)
begin
$clientsock, clientaddr = $sock.accept_nonblock
tm = Time.now
aputs("INFO: client connected to server   |   " + tm.getlocal.to_s)
rescue IO::WaitReadable, Errno::EINTR
IO.select([$sock])
retry
end
Thread.new do
clientsock = $clientsock
name = (recvline(clientsock)).to_s.delete!("\r\n")
token = (recvline(clientsock)).to_s.delete!("\r\n")
size = (recvline(clientsock)).to_i
size = 1048576*1024 if size > 1048576*1024
$suc = true
buf = ""
tm = Time.now
for i in 1..size
r = clientsock.recv(1)
if r != nil and r != ""
buf += r
else
if Time.now.to_i > tm.to_i + 1
break
$suc = false
suc = false
end
end
end
rs = $mysql.query("SELECT `token`, `name`, `time` FROM `tokens`")
suc = false
rs.each_hash do |row|
if name == row['name']
if token == row['token']
tm = Time.now
ttm = ""
tttm = tm.day.to_s
ttm += "0" if tttm.size == 1
ttm += tttm
tttm = tm.month.to_s
ttm += "0" if tttm.size == 1
ttm += tttm
ttm += tm.year.to_s
if row['time'] == ttm
suc = true
end
end
end
end
begin
if $suc == true and suc == true
tm = Time.now
filename = "#{name}_#{token}_#{tm.to_i.to_s}_#{(rand(0xffffffffff)).to_s(16)}"
IO.write("importer/#{filename}",buf)
aputs("INFO: file from #{name} added (size: #{buf.size.to_s}; name: #{filename.to_s})    |   " + tm.getlocal.to_s)
clientsock.write(File.realpath("importer/#{filename}"))
elsif $suc == false
tm = Time.now
aputs("Error: can't receive data    |   " + tm.getlocal.to_s)
clientsock.write("-1")
elsif suc == false
tm = Time.now
aputs("Error: bad token: #{token} for user #{name}    |   " + tm.getlocal.to_s)
clientsock.write("-2")
end
rescue Exception
$suc = false
retry
end
tm = Time.now
end
end
rescue Exception
tm = Time.now
aputs("Error: " + $!.to_s + "   |   " + tm.getlocal.to_s)
retry
end
end
end
StartClass.new
rescue Exception
tm = Time.now
puts("Fatal error   |   " + tm.to_s)
retry
end
