<?php
require("header.php");
if(file_exists("cache/forumlist.dat")) unlink("cache/forumlist.dat");
if(file_exists("cache/forumthread".$_GET['threadid'].".dat")) unlink("cache/forumthread".$_GET['threadid'].".dat");
if(mysql_num_rows(mquery("SELECT name FROM banned WHERE name='".$_GET['name']."' AND totime>".time()))>0) die("-3");
$moderator=getprivileges($_GET['name'])[1];
$q = mquery("SELECT `id` FROM `forum_threads` where id=".((int) $_GET['threadid']));
$threadid=-1;
if(mysql_num_rows($q)==0 or $_GET['threadname']!=NULL or $_POST['threadname']!=NULL) {
$q = mquery("SELECT `id` FROM `forum_threads` ORDER BY `id` DESC");
$threadid = mysql_fetch_row($q)[0]+1;
$q = mquery("SELECT `name`, `id` FROM `forums`");
if(mysql_num_rows(mquery("select name from forums where name='".$_GET['forumname']."'"))==0) die("-1\r\nnoforum");
if($_GET['audio']==0)
$threadname = $_GET['threadname'];
else {
$filename=random_str(24);
if($_GET['audio']==1) {
if(isset($_POST['threadname']))
$threadname=$_POST['threadname'];
else
$threadname=$_GET['threadname'];
}
elseif($_GET['audio']==2) {
$tempName = $_FILES['threadname']['tmp_name'];
session_start();
$_SESSION['forumnewthread']=$threadid;
$threadname=$_POST['threadname'];
}
}
if(file_exists("cache/forumthread".$threadid.".dat")) unlink("cache/forumthread".$threadid.".dat");
mquery("INSERT INTO `forum_threads` (id, name, lastpostdate, forum) VALUES ('" . $threadid . "','" . $threadname . "'," . Time() . ",'".$_GET['forumname']."')");
mquery("delete from forum_read where thread=".$threadid);
if($_GET['follow']==1)
mquery("INSERT INTO `followedthreads` (id, thread, owner) VALUES ('','" . $threadid . "','" . $_GET['name'] . "')");
}
if($threadid==-1)
if(mysql_num_rows(mquery("select id from forum_threads where id=".((int) $_GET['threadid'])))>0)
$threadid=$_GET['threadid'];
if($threadid==-1) die("-4");
mquery("UPDATE `forum_threads` SET `lastpostdate` = '" . time() . "' WHERE `id`=" . $threadid);
if(!isset($_GET['buffer']))
if(!isset($_GET['audio']))
$post = $_GET['post'];
else {
$filename=random_str(24);
if($_GET['audio']==1) {
if(strlen($_POST['post']) < 8)
die("-1\r\nstrlen");
if(substr($_POST['post'],0,4)=="OggS") {
$fp = fopen("audioforums/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
}
else {
$fp = fopen("audioforums/posts/tmp_".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
shell_exec("/usr/bin/ffmpeg -i \"audioforums/posts/tmp_".$filename."\" -f opus -b:a 96k \"audioforums/posts/{$filename}\" 2>&1");
unlink("audioforums/posts/tmp_".$filename);
}
}
elseif($_GET['audio']==2) {
$tempName = $_FILES['post']['tmp_name'];
shell_exec("/usr/bin/ffmpeg -i \"{$tempName}\" -f opus -b:a 96k \"audioforums/posts/{$filename}\" 2>&1");
session_start();
$_SESSION['forumnewpost']=1;
if(file_exists("audioforums/posts/".$filename)==false) die("-1\r\nnofile");
}
$post="\004AUDIO\004/audioforums/posts/".$filename."\004AUDIO\004\r\n";
}
elseif(isset($_GET['buffer'])) {
$post=buffer_get($_GET['buffer']);
}
$asname = $_GET['name'];
if(($_GET['uselore'] == 1 and $_GET['lore'] != NULL) and ($moderator == 1 or $developer == 1))
$asname .= "".$_GET['lore'];
mquery("INSERT INTO `forum_posts` (id, thread, author, date, post) VALUES ('','" . $threadid . "','" . $asname . "','" . date("d.m.Y H:i") . "','" . $post . "')");
mquery("UPDATE `cache` SET `expiredate`=".time()." WHERE id=0 OR forumname='".$_GET['forumname']."'");
if(mysql_num_rows(mquery("select thread from forum_read where thread=".$threadid." and owner='".$_GET['name']."'"))>0)
mquery("UPDATE `forum_read` SET `posts`=`posts`+1 WHERE `thread`=".$threadid." AND `owner`='".$_GET['name']."'");
else
mquery("insert into `forum_read` (id,owner,forum,thread,posts) values ('','".$_GET['name']."','".$_GET['forumname']."',".$threadid.",1)");
echo "0";
?>