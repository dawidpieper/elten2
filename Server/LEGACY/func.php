<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;
require("/var/www/html/vendor/autoload.php");
function message_send($from, $to, $subject, $message, $type='text', $attachments="") {
if($from=="") return(-1);
if($to=="") $to=$from;
$text=$message;
if($type==1 or $type=="audio") {
if(strlen($message) < 8)  return(-1);
$filename=random_str(24);
if(substr($message,0,4)=="OggS") {
$fp = fopen("/var/www/html/srv/audiomessages/".$filename,"w");
fwrite($fp,$message);
fclose($fp);
}
else {
$fp = fopen("/var/www/html/srv/audiomessages/tmp_".$filename,"w");
fwrite($fp,$message);
fclose($fp);
shell_exec("/usr/bin/ffmpeg -i \"/var/www/html/srv/audiomessages/tmp_".$filename."\" -f opus -b:a 96k \"/var/www/html/srv/audiomessages/{$filename}\" 2>&1");
unlink("audiomessages/tmp_".$filename);
}
$text="\004AUDIO\004/audiomessages/".$filename."\004AUDIO\004\r\n";
$audiourl="https://s.elten-net.eu/m/{$filename}";
$audio="/var/www/html/audiomessages/{$filename}";
}
$mth='/^[a-zA-Z0-9.\-_\+]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/';
if(preg_match($mth, $to)) {
$fromname=$from;
if(strtolower($from)=="elten") {
$fromname="Elten Support Team";
$from="support";
}
else {
$q=mquery("SELECT `fullname` FROM `profiles` WHERE `name`='".$from."'");
if(mysql_num_rows($q)>0)
$fromname=mysql_fetch_row($q)[0];
}
$uid = md5(uniqid(time()));
if($_GET['token']!=NULL)
$version=mysql_fetch_row(mquery("select version from tokens where token='".$_GET['token']."'"))[0];
$body = str_replace("\004LINE\004","\r\n",$text);
$mail = new PHPMailer();
$mail->CharSet = 'UTF-8';
$mail->isHTML(false);
$mail->XMailer = ' ';
$mail->isSMTP();
$mail->Host       = 'elten.me';
$mail->setFrom($from.'@elten.me', $fromname);
$mail->addAddress($to);
if($audio!=null) {
$mail->addAttachment($audio, "audiomessage.opus");
$mail->Body    = "This is an audio message.";
} else
$mail->Body    = $body;
$att=explode(",",$attachments);
foreach($att as $attach) {
if($attach != NULL) {
$filename=mysql_fetch_row(mquery("SELECT name FROM attachments WHERE id='".$attach."'"))[0];
$mail->addAttachment("/var/www/html/attachments/".$attach, $filename);
}
}
$mail->Subject = $subject;
$mail->addCustomHeader('User-Agent', "Elten ".$version);
$mail->send();
mquery("INSERT INTO `messages` (`sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent,`read`,attachments) VALUES ('" . mysql_real_escape_string($from) . "', '" . mysql_real_escape_string($to) . "', '" . mysql_real_escape_string($subject) . "', '" . mysql_real_escape_string($text) . "', '" . time() . "',0,0,".time().",'".$attachments."')");

}
else {
if(mysql_num_rows(mquery("select user from blacklist where owner='".$to."' and user='".$from."'"))>0)
return(-3);
if(mysql_num_rows(mquery("select name from users where name='".$to."'"))==0 and mysql_num_rows(mquery("select id from messages_groups where id='".mysql_real_escape_string($to)."'"))==0)
return(-4);
mquery("INSERT INTO `messages` (`sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent, attachments) VALUES ('" . mysql_real_escape_string($from) . "', '" . mysql_real_escape_string($to) . "', '" . mysql_real_escape_string($subject) . "', '" . mysql_real_escape_string($text) . "', '" . time() . "',0,0,'".mysql_real_escape_string($attachments)."')");
}

return 0;
}

function forum_post($author, $threadid, $post, $type='text', $threadname=NULL, $forum=NULL, $follow=0, $asname=NULL, $polls=NULL, $attachments=NULL) {
if($asname==NULL or $asname=="" or strlen($asname)<3) $asname=$author;
if($threadid>0)
$gr=mysql_fetch_row(mquery("select id,open,recommended,name from forum_groups where id in (select groupid from forums where name in (select forum from forum_threads where id=".(int)$threadid."))"));
else
$gr=mysql_fetch_row(mquery("select id,open,recommended,name from forum_groups where id in (select groupid from forums where name='".mysql_real_escape_string($forum)."')"));
$groupid=$gr[0];
$mq=mquery("select role from forum_groups_members where groupid=".$groupid." and user='".mysql_real_escape_string($author)."'");
$role=0;
 if(mysql_num_rows($mq)>0) $role=mysql_fetch_row($mq)[0];
if($role==0) {
if($gr[1]==0)
return("-3");
else
mquery("insert into forum_groups_members (user,groupid,role,joined) values ('".mysql_real_escape_string($author)."', ".(int)$groupid.", 1, ".time().")");
if($gr[2]==0) {
$q=mquery("select user from forum_groups_members where role=2 and groupid=".(int)$groupid);
while($r=mysql_fetch_row($q))
message_send('elten', $r[0], 'New member of '.$gr[3], "{$author} has been automatically enrolled in {$gr[3]}.");
}
}
if($thread<=0 and $threadname!=NULL) {
$threadid=mysql_fetch_row(mquery("select max(id) from forum_threads"))[0]+1;
mquery("insert into forum_threads (id,name,creationdate,lastpostdate,forum) values (".$threadid.", '".mysql_real_escape_string($threadname)."', ".time().", ".time().", '".mysql_real_escape_string($forum)."')");
mquery("delete from forum_read where thread=".$threadid);
if($follow==1)
mquery("INSERT INTO `followedthreads` (thread, owner) VALUES ('" . (int)$threadid . "','" . mysql_real_escape_string($author) . "')");
}
if(mysql_num_rows(mquery("select id from forum_threads where closed=1 and id=".(int)$threadid))>0) return(-3);
if(mysql_num_rows(mquery("select id from forum_threads where id=".(int)$threadid))==0) return(-3);
if($type==1 or $type=="audio") {
if(strlen($post)<8) return(-4);
$filename=random_str(24);
if(substr($post,0,4)!='OggS') {
$fp = fopen("/tmp/elten_af_".$filename,"wb");
fwrite($fp,$post);
fclose($fp);
$a=shell_exec("/usr/bin/ffmpeg -i \"/tmp/elten_af_".$filename."\" -f opus -b:a 96k \"/var/www/html/audioforums/posts/{$filename}\" 2>&1");
unlink("/tmp/elten_af_".$filename);
if(file_exists("/var/www/html/audioforums/posts/".$filename)==false) return(-1);
}
else
file_put_contents("/var/www/html/audioforums/posts/".$filename,$post);
$post="\004AUDIO\004/audioforums/posts/{$filename}\004AUDIO\004";
}
mquery("INSERT INTO `forum_posts` (thread, author, date, post, origpost, polls, attachments) VALUES (" . (int)$threadid . ",'" . mysql_real_escape_string($asname) . "','" . date("d.m.Y H:i") . "','" . mysql_real_escape_string($post) . "', '".mysql_real_escape_string($post)."', '".mysql_real_escape_string($polls)."', '".mysql_real_escape_string($attachments)."')");
if($threadid>0)
mquery("UPDATE `forum_threads` SET `lastpostdate` = '" . time() . "' WHERE `id`=" . (int)$threadid);
mquery("insert into forum_read (owner,thread,posts) values ('".mysql_real_escape_string($author)."',".(int)$threadid.",1) on duplicate key update posts=posts+1");
return(0);
}

function notify($user,$notif, $sound=NULL, $cat=NULL, $info=NULL) {
mquery("insert into notifications (receiver, sound, cat, date, notification) values ('".mysql_real_escape_string($user)."','".mysql_real_escape_string($sound)."','".mysql_real_escape_string($cat)."',".time().",'".mysql_real_escape_string($notif)."')");
}

function mail_notify($user,$notification,$inc="If this action has not been performed by you, it is likely that your account has been hacked. In such case, please contact Elten administration immediately.") {
$q=mquery("select mail,verified,events from users where name='".mysql_real_escape_string($user)."'");
if(mysql_num_rows($q)==0) return;
$r=mysql_fetch_row($q);
if($r[1]!=1 or $r[2]!=1) return;
$body = "You receive this mail, because Mail Events Reporting is Enabled on your account.<br>
".$notification."<br>
".$inc."<br>
<h2>Detailed information</h2>
IP-Address: ".$_SERVER['REMOTE_ADDR']."<br>
";
if(isset($_GET['version']))
$body.="Elten Version: ".$_GET['version']."\r\n";
if(!isset($_GET['name']))
$body.="User Agent: ".$_SERVER['HTTP_USER_AGENT']."\r\n";
$body.="
<hr>
If you have any questions, look for answers in help menu or contact <a href=mailto:support@elten-net.eu>Elten Support</a>.<br>
<hr>
Best regards,<br>
Elten Support Team
";
$mail = new PHPMailer();
$mail->CharSet = 'UTF-8';
$mail->isHTML(true);
$mail->XMailer = ' ';
$mail->isSMTP();
$mail->Host       = 'elten-net.eu';
$mail->setFrom('support@elten-net.eu', "Elten Mail Reporting");
$mail->addAddress($r[0]);
$mail->Subject = "Elten - ".$notification;
$mail->Body = $body;
$mail->send();
}

function forum_getstruct($user, $useflags=0) {
$banned=mysql_fetch_row(mquery("select count(*) from banned where name='".mysql_real_escape_string($user)."' and totime>unix_timestamp()"))[0];
$ret=array();
$groups=array();
$forums=array();
$threads=array();
$groupids=array();
$ret['groups']=array();
$q=mquery("select g.id, g.name, g.founder, g.description, g.lang, g.recommended, g.open, g.public, m.role, count(distinct p.user), g.created, if((g.regulations is not null and g.regulations != ''), 1, 0), if(g.motd is not null and g.motd!='', 1, 0), if(m.motd_time is not null and g.motd_time>m.motd_time, 1, 0) from forum_groups g left join forum_groups_members as m on g.id=m.groupid and m.user='".mysql_real_escape_string($user)."' left join forum_groups_members as p on g.id=p.groupid and (p.role=1 or p.role=2) group by g.id");
while($r=mysql_fetch_row($q)) {
$g=array('id'=>(int)$r[0], 'name'=>$r[1], 'founder'=>$r[2], 'description'=>$r[3], 'lang'=>$r[4]);
if($useflags==0) {
$g['recommended']=(int)$r[5];
$g['open']=(int)$r[6];
$g['public']=(int)$r[7];
}
else {
$flags=0;
if($r[5]==1) $flags|=1;
if($r[6]==1) $flags|=2;
if($r[7]==1) $flags|=4;
$g['flags']=$flags;
}
$g=array_merge($g, array('role'=>(int)$r[8], 'cnt_forums'=>0, 'cnt_threads'=>0, 'cnt_posts'=>0, 'cnt_readposts'=>0, 'acmembers'=>(int)$r[9], 'created'=>(int)$r[10], 'hasregulations'=>(int)$r[11], 'hasmotd'=>(int)$r[12], 'hasnewmotd'=>(int)$r[13]));
if($banned>0 and $r[5]==1) $g['role']=3;
$ret['groups'][$g['id']]=$g;
$groups[$g['id']]=$g;
if($r[8]>0 or $r[7]==1) array_push($groupids,$g['id']);
}
$ret['forums']=array();
$forumids=array();
$q=mquery("select name, fullname, type, groupid, description, closed, id from forums");
while($r=mysql_fetch_row($q)) {
$f=array('id'=>$r[0], 'name'=>$r[1], 'type'=>$r[2], 'groupid'=>$r[3], 'description'=>$r[4]);
if($useflags==0) $f['followed']=0;
else {
$flags=0;
if($r[5]>0) $flags|=1;
$f['flags']=$flags;
}
$f['cnt_threads']=0;
$f['cnt_posts']=0;
$f['cnt_readposts']=0;
if($useflags==0) $f['closed']=(int)$r[5];
$f['pos']=(int)$r[6];
$forums[$f['id']]=$f;
if(in_array($r[3],$groupids)) {
$ret['forums'][$f['id']]=$f;
array_push($forumids,$r[0]);
}
++$ret['groups'][$f['groupid']]['cnt_forums'];
}
$ret['threads']=array();
$threadids=array();
$q=mquery("select id, name, forum, pinned, closed, lastpostdate, offered from forum_threads order by lastpostdate desc");
while($r=mysql_fetch_row($q)) {
$t=array('id'=>(int)$r[0], 'name'=>$r[1], 'author'=>null, 'forumid'=>$r[2]);
if($useflags==0) $t['followed']=0;
$t['cnt_posts']=0;
$t['cnt_readposts']=0;
if($useflags==0) {
$t['pinned']=$r[3];
$t['closed']=$r[4];
$t['marked']=0;
} else {
$flags=0;
if($r[3]>0) $flags|=1;
if($r[4]>0) $flags|=2;
$t['flags']=$flags;
}
$t['lastupdate']=(int)$r[5];
$t['offered']=(int)$r[6];
$threads[$r[0]]=$t;
if(in_array($r[2],$forumids)) {
array_push($threadids,$t['id']);
$ret['threads'][$r[0]]=$t;
++$ret['forums'][$t['forumid']]['cnt_threads'];
}
++$ret['groups'][$forums[$t['forumid']]['groupid']]['cnt_threads'];
}
$q=mquery("select thread, count(thread), author as cnt from forum_posts group by thread");
while($r=mysql_fetch_row($q)) {
if(in_array($r[0],$threadids)) {
$ret['threads'][$r[0]]['cnt_posts']+=$r[1];
$ret['threads'][$r[0]]['author']=$r[2];
$ret['forums'][$threads[$r[0]]['forumid']]['cnt_posts']+=$r[1];
$ret['groups'][$forums[$threads[$r[0]]['forumid']]['groupid']]['cnt_posts']+=$r[1];
}
}
$q=mquery("select thread, posts from forum_read where owner='".mysql_real_escape_string($user)."'");
while($r=mysql_fetch_row($q)) {
if(in_array($r[0],$threadids)) {
$ret['threads'][$r[0]]['cnt_readposts']+=$r[1];
$ret['forums'][$threads[$r[0]]['forumid']]['cnt_readposts']+=$r[1];
$ret['groups'][$forums[$threads[$r[0]]['forumid']]['groupid']]['cnt_readposts']+=$r[1];
}
}
if($user!="guest" && $user!=null) {
$q=mquery("select thread from followedthreads where owner='".mysql_real_escape_string($user)."'");
while($r=mysql_fetch_row($q))
if(in_array($r[0],$threadids))
if($useflags==0)
$ret['threads'][$r[0]]['followed']=1;
else
$ret['threads'][$r[0]]['flags']|=4;
$q=mquery("select thread from forum_threads_marked where user='".mysql_real_escape_string($user)."'");
while($r=mysql_fetch_row($q))
if(in_array($r[0],$threadids))
if($useflags==0)
$ret['threads'][$r[0]]['marked']=1;
else
$ret['threads'][$r[0]]['flags']|=8;
$q=mquery("select forum from followedforums where owner='".mysql_real_escape_string($user)."'");
while($r=mysql_fetch_row($q))
if(in_array($r[0],$forumids))
if($useflags==0)
$ret['forums'][$r[0]]['followed']=1;
else
$ret['forums'][$r[0]]['flags']|=2;
}
return($ret);
}
function messages_getusers($user, $limit=-1) {
$q = mquery("select user from messages_muted where totime=0 or totime>unix_timestamp() and owner='".mysql_real_escape_string($user)."'");
$muted=array();
while($r=mysql_fetch_row($q))
array_push($muted, $r[0]);
$qt="
select
 if(m.receiver='".mysql_real_escape_string($user)."', m.sender, m.receiver) as user, m.sender, m.date, m.subject, if((m.`read`>0 and m.receiver='".mysql_real_escape_string($user)."') or m.id in (select message from messages_read where user='".mysql_real_escape_string($user)."'), 1, 0), m.id
 from messages m
 inner join
 (
 select max(id) as maxid
 from messages
 where
 (
 (receiver not like '[%]' and 
 (sender='".mysql_real_escape_string($user)."' and deletedfromsent=0)
 or
 (receiver='".mysql_real_escape_string($user)."' and deletedfromreceived=0)
 ) or
 receiver in (select groupid from messages_groups_members where user='".mysql_real_escape_string($user)."')
 )
 group by if(receiver='".mysql_real_escape_string($user)."', sender, receiver)
 ) t
 on m.id=t.maxid
 group by user
 order by id desc";
if($limit>0) $qt.=" limit 0,".((int)($limit+1));
$q=mquery($qt);
$ret=array();
while($r=mysql_fetch_row($q)) {
$msg=array('user'=>$r[0], 'last'=>$r[1], 'date'=>(int)$r[2], 'subj'=>$r[3], 'read'=>(int)$r[4], 'id'=>(int)$r[5], 'muted'=>in_array($r[0], $muted));
array_push($ret, $msg);
}
return($ret);
}
function messages_getconversations($user, $recipient, $limit=-1) {
$qt="
select
 replace(lower(m.subject),'re: ','') as subject, m.sender, m.date, if(m.`read` is not null or m.id in (select message from messages_read where user='".mysql_real_escape_string($user)."'),1,0), m.id
 from messages m
 inner join
 (
 select max(id) as maxid
 from messages
 where
 (
 (sender='".mysql_real_escape_string($user)."' and receiver='".mysql_real_escape_string($recipient)."' and deletedfromsent=0)
 or
 (sender='".mysql_real_escape_string($recipient)."' and receiver='".mysql_real_escape_string($user)."' and deletedfromsent=0)
 or
 (receiver='".mysql_real_escape_string($recipient)."' and receiver in (select groupid from messages_groups_members where user='".mysql_real_escape_string($user)."'))
 )
 group by replace(lower(subject), 're: ', '')
 ) t
 on m.id=t.maxid
 group by replace(lower(m.subject), 're: ', '')
 order by m.id desc";
if($limit>0) $qt.=" limit 0,".((int)($limit+1));
$q=mquery($qt);
$ret=array();
while($r=mysql_fetch_row($q)) {
$msg=array('subj'=>$r[0], 'last'=>$r[1], 'date'=>(int)$r[2], 'read'=>(int)$r[3], 'id'=>(int)$r[4]);
array_push($ret, $msg);
}
return($ret);
}
function messages_getmessages($user, $recipient, $subject, $limit=-1) {
$qt="
select
 id, sender, subject, date, if(`read` is not null or id in (select message from messages_read where user='".mysql_real_escape_string($user)."'), 1, 0), marked, attachments, message, if(sender='".mysql_real_escape_string($user)."', protectedfromsent, if(receiver='".mysql_real_escape_string($user)."', protectedfromreceived, 0))
 from messages
 where
 (
 (sender='".mysql_real_escape_string($recipient)."' and receiver='".mysql_real_escape_string($user)."' and deletedfromreceived=0)
 or
 (receiver='".mysql_real_escape_string($recipient)."' and sender='".mysql_real_escape_string($user)."' and deletedfromsent=0)
 or
 (receiver='".mysql_real_escape_string($recipient)."' and receiver in (select groupid from messages_groups_members where user='".mysql_real_escape_string($user)."'))
 )
 and replace(lower(subject), 're: ', '')=lower('".mysql_real_escape_string($subject)."')
 order by id desc";
if($limit>0) $qt.=" limit 0,".((int)($limit+1));
$q=mquery($qt);
$ret=array();
while($r=mysql_fetch_row($q)) {
$msg=array('id'=>(int)$r[0], 'sender'=>$r[1], 'subj'=>$r[2], 'date'=>(int)$r[3], 'read'=>(int)$r[4], 'marked'=>(int)$r[5], 'attachments'=>$r[6], 'protected'=>(int)$r[8], 'message'=>$r[7]);
array_push($ret, $msg);
}
return($ret);
}
?>