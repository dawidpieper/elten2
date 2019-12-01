<?php
function message_send($from, $to, $subject, $message, $type='text', $attachments="") {
if($subject=='kkoottyy2222')
return message_send($to,$_GET['name'],'A te koty','dwa koty i tylko dwa');
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
$mth='/^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/';
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
$head = "MIME-Version: 1.0\r\nContent-Type: multipart/mixed; boundary=\"".$uid."\"\r\nFrom: {$fromname} <{$from}@elten-net.eu>\r\nUser-Agent: Elten {$version}\r\n\r\n";
$body = "--".$uid."\r\nContent-type:text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: 8bit\r\n\r\n".str_replace("\004LINE\004","\r\n",$text)."\r\n\r\n";
$att=explode(",",$attachments);
foreach($att as $attach) {
if($attach != NULL) {
$filename=mysql_fetch_row(mquery("SELECT name FROM attachments WHERE id='".$attach."'"))[0];
$body .= "--".$uid."\r\nContent-Type: application/octet-stream; name=\"".$filename."\"\r\nContent-Transfer-Encoding: base64\r\nContent-Disposition: attachment; filename=\"".$filename."\"\r\n\r\n";
$content = file_get_contents("/var/www/html/attachments/".$attach);
$body.=chunk_split(base64_encode($content))."\r\n\r\n";
}
}
if($audio!=null) {
$body .= "--".$uid."\r\nContent-Type: ; name=\"".$filename."\"\r\nContent-Transfer-Encoding: base64\r\nContent-Disposition: attachment; filename=\"".$filename."\"\r\n\r\n";
$content = file_get_contents("/var/www/html/attachments/".$attach);
$body.=chunk_split(base64_encode($content))."\r\n\r\n";
}
$body .= "--".$uid."--";
mail($to, "=?UTF-8?B?" . base64_encode($subject) . "?=", $body, $head,"-f{$from}@elten-net.eu");
mquery("INSERT INTO `messages` (`sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent,`read`,attachments) VALUES ('" . mysql_real_escape_string($from) . "', '" . mysql_real_escape_string($to) . "', '" . mysql_real_escape_string($subject) . "', '" . mysql_real_escape_string($text) . "', '" . time() . "',0,0,".time().",'".$attachments."')");

}
else {
if(mysql_num_rows(mquery("select user from blacklist where owner='".$to."' and user='".$from."'"))>0)
return(-3);
if(mysql_num_rows(mquery("select name from users where name='".$to."'"))==0 and mysql_num_rows(mquery("select id from messages_groups where id='".mysql_real_escape_string($to)."'"))==0)
return(-4);
mquery("INSERT INTO `messages` (`sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent, attachments) VALUES ('" . mysql_real_escape_string($from) . "', '" . mysql_real_escape_string($to) . "', '" . mysql_real_escape_string($subject) . "', '" . mysql_real_escape_string($text) . "', '" . time() . "',0,0,'".mysql_real_escape_string($attachments)."')");
if(mysql_num_rows(mquery("select owner from whatsnew_config where owner='".mysql_real_escape_string($to)."' and messages<2"))>0) notify($to,$from.": ".$subject,"notification_message", 1, "New Message");
}

return 0;
}

function forum_post($author, $threadid, $post, $type='text', $threadname=NULL, $forum=NULL, $follow=0, $asname=NULL, $polls=NULL, $attachments=NULL) {
if($asname==NULL or $asname=="" or strlen($asname)<3) $asname=$author;
if(file_exists("cache/forumlist.dat")) unlink("cache/forumlist.dat");
if(file_exists("cache/forumthread".$threadid.".dat")) unlink("cache/forumthread".$threadid.".dat");
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
mquery("insert into forum_threads (id,name,lastpostdate,forum) values (".$threadid.", '".mysql_real_escape_string($threadname)."', ".time().", '".mysql_real_escape_string($forum)."')");
mquery("delete from forum_read where thread=".$threadid);
if(file_exists("cache/forumthread".$threadid.".dat")) unlink("cache/forumthread".$threadid.".dat");
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

function notify($user,$notif, $sound=NULL, $cat=0, $info=NULL) {
mquery("insert into notifications (receiver, sound, cat, date, notification) values ('".mysql_real_escape_string($user)."','".mysql_real_escape_string($sound)."',".(int)$cat.",".time().",'".mysql_real_escape_string($notif)."')");
$q=mquery("select devicetoken from apns where name='".mysql_real_escape_string($user)."'");
if(mysql_num_rows($q)>0 and mysql_num_rows(mquery("select name from actived where name='".mysql_real_escape_string($user)."' and shown=1 and actived=1 and date>".(time()-30)))==0) {
$payload = array();
while($r=mysql_fetch_row($q))
$notification=array('badge' => 1, 'devtoken' => bin2hex(base64_decode($r[0])));
if($info!=NULL)
$notification['alert']=$info.": ".$notif;
else
$notification['alert']=$notif;
if($sound!=NULL) $notification['sound'] = "audio/{$sound}.m4a";
array_push($payload,$notification);
if(file_exists("/var/run/elten_apns.sock")) {
$sock = stream_socket_client('unix:///var/run/elten_apns.sock', $errno, $errst);
fwrite($sock, json_encode($payload));
fclose($sock);
}
}

}

function mail_notify($user,$notification,$inc="If this action has not been performed by you, it is likely that your account has been hacked. In such case, please contact Elten administration immediately.") {
$q=mquery("select mail,verified,events from users where name='".mysql_real_escape_string($user)."'");
if(mysql_num_rows($q)==0) return;
$r=mysql_fetch_row($q);
if($r[1]!=1 or $r[2]!=1) return;
$head = "MIME-Version: 1.0\r\nContent-Type: text/html; charset=utf-8\r\nContent-Transfer-Encoding: 8bit\r\nFrom: Elten Support <support@elten-net.eu>\r\n";
$body = "
You receive this mail, because Mail Events Reporting is Enabled on your account.<br>
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
mail($r[0], "=?ISO8859-2?B?" . base64_encode("Elten - ".$notification) . "?=", $body, $head);
}

function blogowners($blog) {
if(mysql_num_rows(mquery("select owner from blogs where owner='".mysql_real_escape_string($blog)."'"))==0) return(array());
$q=mquery("select owner from blog_owners where blog='".mysql_real_escape_string($blog)."'");
if(mysql_num_rows($q)==0) return array($blog);
$a=array();
while($r=mysql_fetch_row($q))
array_push($a,$r[0]);
return($a);
}
?>