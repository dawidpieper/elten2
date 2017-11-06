<?php
require("header.php");
if(mysql_num_rows(mquery("SELECT name FROM banned WHERE name='".$_GET['name']."' AND totime<".time()))>0)
die(-3);
$suc = false;
if($_GET['forumname']=="") {
$suc=true;
mquery("UPDATE `forum_threads` SET `lastpostdate` = '" . time() . "' WHERE `id`=" . $_GET['threadid']);
if($_GET['buffer'] == 0)
if($_GET['audio']==0)
$post = $_GET['post'];
else {
if(strlen($_POST['post']) < 8) {
echo "-1";
die;
}
$filename=random_str(24);
$fp = fopen("audioforums/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
$post="\004AUDIO\004/audioforums/posts/".$filename."\004AUDIO\004\r\n";
}
else {
$post=buffer_get($_GET['buffer']);
}
mquery("INSERT INTO `forum_posts` (id, thread, author, date, post) VALUES ('','" . $_GET['threadid'] . "','" . $_GET['name'] . "','" . date("d.m.Y H:i") . "','" . $post . "')");
mquery("UPDATE `cache` SET `expiredate`=".time());
mquery("UPDATE `forum_read` SET `posts`=`posts`+1 WHERE `thread`=".$_GET['threadid']." AND `owner`='".$_GET['name']."'");
echo "0";
die;
}
$moderator=getprivileges($_GET['name'])[1];
$error = 0;
$q = mquery("SELECT `id` FROM `forum_threads`");
$suc = false;
$threadid = $_GET['threadid'];
while ($r = mysql_fetch_row($q)){
if($r[0] == $_GET['threadid'])
$suc = true;
}
$error = 0;
if($suc == false or $_GET['threadname']!=NULL or $_POST['threadname']!=NULL) {
$q = mquery("SELECT `id` FROM `forum_threads` ORDER BY `id` DESC");
$threadid = mysql_fetch_row($q)[0]+1;
$q = mquery("SELECT `name`, `id` FROM `forums`");
while ($r = mysql_fetch_row($q)){
if($r[0] == $_GET['forumname']) {
$name = $r[0];
$id = $r[1];
}
}
if($name == null) {
echo "-1";
die;
}
if($_GET['audio']==0)
$threadname = $_GET['threadname'];
else {
if(strlen($_POST['threadname']) < 8) {
echo "-1";
die;
}
$filename=random_str(24);
$fp = fopen("audioforums/titles/".$filename,"w");
fwrite($fp,$_POST['threadname']);
fclose($fp);
$threadname="\004AUDIO\004/audioforums/titles/".$filename."\004AUDIO\004";
}
mquery("INSERT INTO `forum_threads` (id, name, lastpostdate, forum) VALUES ('" . $threadid . "','" . $threadname . "'," . Time() . ",'".$_GET['forumname']."')");
mquery("INSERT INTO `forum_read` (id, owner, forum, thread, posts) VALUES ('','".$_GET['name']."','" . $_GET['forumname'] . "','" . $threadid . "'," . 1 . ")");
}
$posts = 0;
$q = mquery("SELECT `name`, `id` FROM `forum_threads`");
while ($r = mysql_fetch_row($q)) {
if($r[1] == $threadid) {
$name = $r[0];
$id = $r[1];
}
}
mquery("UPDATE `forum_threads` SET `name` = '" . $name . "', `lastpostdate` = '" . time() . "' WHERE `id`=" . $id);
if($_GET['buffer'] == 0)
if($_GET['audio']==0)
$post = $_GET['post'];
else {
if(strlen($_POST['post']) < 8) {
echo "-1";
die;
}
$filename=random_str(24);
$fp = fopen("audioforums/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
$post="\004AUDIO\004/audioforums/posts/".$filename."\004AUDIO\004\r\n";
}
else {
$post=buffer_get($_GET['buffer']);
}
$asname = $_GET['name'];
if(($_GET['uselore'] == 1 and $_GET['lore'] != NULL) and ($moderator == 1 or $developer == 1))
$asname .= "".$_GET['lore'];
mquery("INSERT INTO `forum_posts` (id, thread, author, date, post) VALUES ('','" . $threadid . "','" . $asname . "','" . date("d.m.Y H:i") . "','" . $post . "')");
mquery("UPDATE `cache` SET `expiredate`=".time()." WHERE id=0 OR forumname='".$_GET['forumname']."'");
mquery("UPDATE `forum_read` SET `posts`=`posts`+1 WHERE `thread`=".$_GET['threadid']." AND `owner`='".$_GET['name']."'");
echo "0";
?>