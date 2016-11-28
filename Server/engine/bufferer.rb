#encoding: utf-8

$stderr.reopen("bufferer_error.log", "w")
$outer = IO.new(0)
$outer.reopen("bufferer.log","w")

require("socket")
require("mysql")
begin
include Socket::Constants
class StartClass
def aputs(text)
$stdout.puts(text)
$outer.puts(text)
end
def initialize
$sock = Socket.new(AF_INET, :STREAM)
$sock.bind(Addrinfo.tcp("5.196.225.236",2431))
$mysql = Mysql.new("localhost","dbuser","dbpass","dbname")
tm = Time.now
aputs("INFO: Bufferer Started   |   " + tm.getlocal.to_s)
main
end
def main
begin
loop do
$sock.listen(128)
begin
$clientsock, clientaddr = $sock.accept_nonblock
tm = Time.now
aputs("INFO: client connected to server   |   " + tm.getlocal.to_s)
rescue IO::WaitReadable, Errno::EINTR
IO.select([$sock])
retry
end
name = ($clientsock.readline).to_s.delete!("\r\n")
token = ($clientsock.readline).to_s.delete!("\r\n")
id = ($clientsock.readline).to_i
size = ($clientsock.readline).to_i
size = 1048576*1024 if size > 1048576*1024
$suc = true
buf = $clientsock.read(size)
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
q = "INSERT INTO buffers (id,data,owner) VALUES (#{id},'"
for i in 0..buf.size - 1
q += "\\" + buf[i..i]
end
q += "','#{name}')"
$mysql.query(q)
tm = Time.now
aputs("INFO: Buffer from #{name} added (size: #{buf.size.to_s}; id: #{id.to_s})    |   " + tm.getlocal.to_s)
$clientsock.write("0")
elsif $suc == false
tm = Time.now
aputs("Error: can't receive data    |   " + tm.getlocal.to_s)
$clientsock.write("-1")
elsif suc == false
tm = Time.now
aputs("Error: bad token: #{token} for user #{name}    |   " + tm.getlocal.to_s)
$clientsock.write("-2")
end
rescue Exception
$suc = false
retry
end
tm = Time.now
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
