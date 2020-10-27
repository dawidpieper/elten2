#!/usr/bin/ruby
# encoding: utf-8


require 'mysql2'
require 'apnotic'
require 'base64'
require 'net/http'
require 'net/https'
require 'active_support'

if FileTest.exists?("/run/eltennotic.pid")
pid=IO.binread("/run/eltennotic.pid")
system("kill -9 #{pid.to_s}")
File.delete("/run/eltennotic.pid")
end
exit if $*.include?("-s")

if !$*.include?("-nd")
Process.daemon
IO.write("/run/eltennotic.pid",Process.pid.to_s)
end

def getsql
sqlindex=0
$sqlindex_mutex.synchronize {
sqlindex=$sqlindex
$sqlindex=($sqlindex+1)%$sqls.size
}
sql=$sqls[sqlindex]
sql_mutex=$sql_mutexes[sqlindex]
return sql, sql_mutex
end
def mquery(q)
sql, sql_mutex = getsql
r=nil
sql_mutex.synchronize {
r = sql.query(q)
}
return r
end

module Notifications
class Notification
attr_accessor :receiver, :text, :sound, :cat
def initialize(receiver, text, sound, cat)
text=text[0..60]+"..." if text.size>64
@receiver, @text, @sound, @cat = receiver, text, sound, cat
end
end
Queue=[]
Queued=[]
class <<self
include Notifications
@@mutex = Mutex.new
def add(uid, receiver, text, sound, cat, filter=nil)
if filter!=nil && $config.is_a?(Hash)
$config[receiver] = {'messages'=>0, 'followedthreads'=>0, 'followedblogs'=>0, 'blogcomments'=>0, 'followedforums'=>0, 'followedforumthreads'=>2, 'friends'=>0, 'birthday'=>0, 'mentions'=>0, 'followedblogposts'=>0} if $config[receiver]==nil
return if ($config[receiver][filter]||0).to_i>1
end
@@mutex.synchronize {
if uid==nil || !Queued.include?([uid, receiver])
Queued.push([uid, receiver])
Queued.delete_at(0) while Queued.size>131072
n=Notification.new(receiver, text, sound, cat)
Queue.push(n)
end
}
end
def send
@@mutex.synchronize {
if Queue.size>0
apns = get_apns
sql, sql_mutex = getsql
sql_mutex.synchronize {
stmt = sql.prepare("insert into notifications (receiver, notification, sound, cat, date) values (?, ?, ?, ?, unix_timestamp())")
for n in Queue
stmt.execute(n.receiver, n.text, n.sound, n.cat)
if apns[n.receiver]!=nil && apns[n.receiver].size>0
apns[n.receiver].each{|t| apns_send(t, n)}
end
end
stmt.close
Queue.clear
}
end
}
end
end
public
def get_apns
devtokens = {}
q=mquery("select name,devicetoken from apns")
for e in q.entries
devtokens[e['name']]||=[]
devtokens[e['name']].push(e['devicetoken'])
end
return devtokens
end
def apns_send(token, n)
return if $apns==nil
token=Base64.decode64(token).each_byte.map { |b| b.to_s(16).rjust(2,'0') }.join
notification       = Apnotic::Notification.new(token)
notification.sound = "audio/#{n.sound}.m4a"
notification.alert=n.text
notification.badge=1
notification.topic='eu.elten-net.eltenmobile'
c=$apns.prepare_push(notification)
$apns.push_async(c)
end
end

begin
$sqlindex=0
$sqls=[]
$sql_mutexes=[]
5.times do
sql=Mysql2::Client.new(reconnect: true)
sql.select_db 'elten'
sql_mutex = Mutex.new
sql.query("SET NAMES utf8mb4")
$sqls.push(sql)
$sql_mutexes.push(sql_mutex)
end
$sqlindex_mutex = Mutex.new
$apns = Apnotic::Connection.new(
auth_method: :token,
cert_path: "/home/dpieper/AuthKey_VDC47Q6Y5R.p8",
key_id: "VDC47Q6Y5R",
team_id: "YC6NP473J2",
url: "https://api.development.push.apple.com:443"
)

$lasttime=[0]+[Time.now.to_i]*10
iter=0
loop do
tms=Time.now.to_f
if iter%5==0
$config={}
q=mquery("select owner,messages,followedthreads,followedblogs,blogcomments,followedforums,followedforumsthreads,friends,birthday,mentions,followedblogposts from whatsnew_config")
for e in q.entries
$config[e['owner']]=e.dup
end
end
threads=[]
threads.push(Thread.new {
mmuted={}
q=mquery("select owner,user from messages_muted where totime=0 or totime>unix_timestamp()")
for e in q.entries
mmuted[e['owner']]||=[]
mmuted[e['owner']].push(e['user'])
end
mgroups={}
q=mquery("select groupid,user from messages_groups_members")
for e in q.entries
mgroups[e['groupid']]||=[]
mgroups[e['groupid']].push(e['user'])
end
q=mquery("select id,sender,receiver,subject,message from messages where date>=#{$lasttime[1]} and (receiver in (select name from actived) or receiver in (select id from messages_groups))")
for e in q.entries
if mgroups[e['receiver']].is_a?(Array)
q2=mquery("select user from messages_read where message=#{e['id'].to_i}")
readers=q2.entries.map{|m|m['user']}
for user in mgroups[e['receiver']]
if !readers.include?(user)
muted = (mmuted[user]!=nil && mmuted[user].include?(e['receiver']))
Notifications.add("msg_#{e['id']}", user, e['sender']+": "+e['subject'], "notification_message", "message", "messages") if !muted
end
end
else
muted = (mmuted[e['receiver']]!=nil && mmuted[e['receiver']].include?(e['sender']))
Notifications.add("msg_#{e['id']}", e['receiver'], e['sender']+": "+e['subject'], "notification_message", "message", "messages") if !muted
end
end
})
if iter%2==0
threads.push(Thread.new {
q=mquery("select t.lastpostdate, t.id, t.name, f.owner, p.author from followedthreads f inner join forum_threads t on t.id=f.thread inner join (select thread, count(thread) as cnt from forum_posts group by thread) s on s.thread=t.id inner join (select pp.thread, pp.author from forum_posts pp inner join (select thread, max(id) as d from forum_posts group by thread) pp2 on pp.id=pp2.d) p on p.thread=f.thread left join forum_read r on r.owner=f.owner and r.thread=f.thread where (s.cnt>r.posts or r.posts is null) and t.lastpostdate>=#{$lasttime[2]}")
for e in q.entries
Notifications.add("ft_#{e['id']}_#{e['lastpostdate']}", e['owner'], e['author']+": "+e['name'], "notification_followedthread", "followedthread", "followedthreads")
end
})
end
if iter%5==0
threads.push(Thread.new {
q=mquery("select t.lastpostdate, t.id, t.name, f.owner, if(t.creationdate=t.lastpostdate, 1, 0) as firstpost from followedforums f join forum_threads t on t.forum=f.forum inner join (select thread, count(thread) as cnt from forum_posts group by thread) s on s.thread=t.id left join forum_read r on r.owner=f.owner and r.thread=t.id where (s.cnt>r.posts or r.posts is null) and t.lastpostdate>=#{$lasttime[5]}")
for e in q.entries
if e['firstpost'].to_i==0
Notifications.add("#ffp_{e['id']}_#{e['lastpostdate']}", e['owner'], e['name'], "notification_followedforumpost", "followedforumpost", "followedforumsthreads")
else
Notifications.add("fft_#{e['id']}_#{e['lastpostdate']}", e['owner'], e['name'], "notification_followedforum", "followedforum", "followedforums")
end
end
})
end
threads.push(Thread.new {
q=mquery("select id, user, author, message from mentions where noticed is null and time>=#{$lasttime[1]}")
for e in q.entries
Notifications.add("mnt_#{e['id']}", e['user'], e['author']+": "+e['message'], "notification_mention", "mention", "mentions")
end
})
if iter%10==0
threads.push(Thread.new {
q=mquery("select id, owner, user from contacts where noticed is null and time>=#{$lasttime[10]}")
for e in q.entries
Notifications.add("cnt_#{e['id']}", e['user'], e['owner'], "notification_friend", "friend", "friends")
end
})
end
if iter%5==0
allposts = {}
blogs={}
mappings = {}
pread={}
followers = {}
pfollowers={}
t1=Thread.new {
allposts = JSON.load(Net::HTTP.get(URI.parse("https://elten.blog/wp-json/elten/allposts?column=all")))
}
t2 = Thread.new {
blogs = JSON.load(Net::HTTP.get(URI.parse("https://elten.blog/wp-json/elten/blogs")))
}
t3 = Thread.new {
q=mquery("select blog, domain from blogs_mapping")
for e in q.entries
mappings[e['blog']]=e['domain']
end
q=mquery("select owner, blog, postid, postsread from blogs_postsread")
for e in q.entries
owner=e['owner']
b=e['blog']
next if b[0..1]=="[*"
d=nil
if mappings[b]!=nil
d=mappings[b]
else
d=I18n.transliterate(b).downcase.delete(" ").delete(".")
if d[0..0]=="["
d=d[1...-1]+".s.elten.blog"
else
d=d+".elten.blog"
end
mappings[b]=d
end
pread[owner]={} if pread[owner]==nil
pread[owner][d]={} if pread[owner][d]==nil
pread[owner][d][e['postid'].to_i]=e['postsread'].to_i
end
}
t4 = Thread.new {
q=mquery("select owner, blog from blogs_followed")
for e in q.entries
b=e['blog']
o=e['owner']
followers[b]=[] if followers[b]==nil
followers[b].push(o)
end
}
t5 = Thread.new {
q=mquery("select owner, blog, postid from blogs_postsfollowed")
for e in q.entries
b=e['blog']
o=e['owner']
t=e['postid']
pfollowers[b]={} if pfollowers[b]==nil
pfollowers[b][t]=[] if pfollowers[b][t]==nil
pfollowers[b][t].push(o)
end
}
t1.join
t2.join
t3.join
t4.join
t5.join
threads.push(Thread.new {
for f in followers.keys
d=mappings[f]
next if d==nil
for u in followers[f]
next if pread[u]==nil || pread[u][d]==nil || !allposts[d].is_a?(Hash)
for ps in allposts[d].keys
next if allposts[d][ps]['time'].to_i<$lasttime[10]
if !pread[u][d].keys.include?(ps.to_i)
Notifications.add("blg_#{f}_#{ps}", u, allposts[d][ps]['title'], "notification_followedblog", "followedblog", "followedblogs")
end
end
end
end
})
threads.push(Thread.new {
for b in blogs
d=b['domain']
for ue in b['users']
u=ue['elten']
next if pread[u]==nil || pread[u][d]==nil || !allposts[d].is_a?(Hash)
for ps in allposts[d].keys
next if allposts[d][ps]['commenttime'].to_i<$lasttime[10]
cs=(pread[u][d][ps.to_i]||1)-1
cc=allposts[d][ps]['cnt_comments'].to_i
if cs<cc
Notifications.add("blc_#{d}_#{ps}_#{cc}", u, allposts[d][ps]['title'], "notification_blogcomment", "blogcomment", "blogcomments")
end
end
end
end
})
threads.push(Thread.new {
for b in pfollowers.keys
d=mappings[b]
for t in pfollowers[b].keys
for u in pfollowers[b][t]
next if pread[u]==nil || pread[u][d]==nil || !allposts[d].is_a?(Hash)
for ps in allposts[d].keys
next if allposts[d][ps]['commenttime'].to_i<$lasttime[10]
cs=(pread[u][d][ps.to_i]||1)-1
cc=allposts[d][ps]['cnt_comments'].to_i
if cs<cc
Notifications.add("fbp_#{d}_#{ps}_#{cc}", u, allposts[d][ps]['title'], "notification_followedblogpost", "followedblogpost", "followedblogposts")
end
end
end
end
end
})
end
threads.each{|h|h.join}
for i in 1..10
if iter%i==0
$lasttime[i]=tms.to_i
end
end
Notifications.send
p Time.now.to_f-tms
iter+=1
sleep(1)
end
rescue SystemExit
rescue Interrupt
rescue Exception
p $!
p $@
sleep(1)
retry
end
puts