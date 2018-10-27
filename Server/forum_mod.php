<?php
require("header.php");
if(file_exists("cache/forumlist.dat")) unlink("cache/forumlist.dat");
if(file_exists("cache/forumthread".$_GET['threadid'].".dat")) unlink("cache/forumthread".$_GET['threadid'].".dat");
$moderator=getprivileges($_GET['name'])[1];
if($_GET['delete'] == 1) {
if($moderator == 0) {
echo "-3";
die;
}
mquery("DELETE FROM `forum_threads` WHERE `id`=" . ((int) $_GET['threadid']));
mquery("INSERT INTO `forum_posts_deleted` SELECT * FROM `forum_posts` WHERE `thread`=" . $_GET['threadid']);
mquery("DELETE FROM `forum_posts` WHERE `thread`=" . $_GET['threadid']);
mquery("UPDATE `cache` SET `expiredate`=".time()." WHERE id=0 OR `forumname`='".$_GET['forumname']."'");
mquery("DELETE FROM `followedthreads` WHERE `thread`=" . $_GET['threadid']);
mquery("DELETE FROM forum_read WHERE `thread`=" . $_GET['threadid']);
}
if($_GET['delete'] == 2) {
if($moderator == 0) {
echo "-3";
die;
}
$posts = (int) mysql_fetch_row(mquery("select count(*) from forum_posts where thread=".((int) $_GET['threadid'])))[0];
mquery("INSERT INTO `forum_posts_deleted` SELECT * FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'] . " AND `id`=" . $_GET['postid']);
mquery("DELETE FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'] . " AND `id`=" . $_GET['postid']);
mquery("UPDATE `cache` SET `expiredate`=".time()." WHERE id=0 OR `forumname`='".$_GET['forumname']."'");
mquery("UPDATE `forum_read` SET `posts`=`posts`-1 WHERE `thread`=" . $_GET['threadid']." and posts=".$posts);
}
if($_GET['edit'] == 1) {
$q = mquery("SELECT `id`, `author` FROM `forum_posts` WHERE `id`=".$_GET['postid']);
$suc = false;
while($r = mysql_fetch_row($q)) {
if($r[0] == $_GET['postid']) {
$suc = true;
if($r[1] != $_GET['name'] and $moderator == 0) {
echo "-3";
die;
}
}
}
if($suc == false) {
echo "-4";
die;
}
$post = "";
if($_GET['buffer'] == 0)
$post = $_GET['post'];
else {
$post=buffer_get($_GET['buffer']);
}
if($post == "") {
echo "-1\r\n".$zapytanie;
die;
}
mquery("UPDATE `forum_posts` SET `post`='".$post."' WHERE `thread`=".$_GET['threadid']." AND`id`='".$_GET['postid']."'");
}
if($_GET['move'] == 1) {
if($moderator==0) {
echo "-3";
die;
}
mquery("UPDATE forum_threads SET forum='".$_GET['destination']."' WHERE `id`=".$_GET['threadid']);
}
if($_GET['move'] == 2) {
if($moderator==0) {
echo "-3";
die;
}
if(file_exists("cache/forumthread".((int) $_GET['destination']).".dat")) unlink("cache/forumthread".((int) $_GET['destination']).".dat");
mquery("UPDATE forum_posts SET thread=".((int) $_GET['destination'])." WHERE `id`=".$_GET['postid']);
mquery("UPDATE `forum_read` SET `posts`=`posts`-1 WHERE `thread`=" . $_GET['threadid']);
}
if($_GET['rename'] == 1) {
if($moderator==0) {
echo "-3";
die;
}
mquery("UPDATE forum_threads SET name='".$_GET['threadname']."' WHERE `id`=".$_GET['threadid']);
}
if($_GET['move']==3) {
if($moderator==0) {
echo "-3";
die;
}
$tempid=mysql_fetch_row(mquery("select id from forum_posts order by id desc limit 0,1"))[0]+rand(100,10000);
$srcthread=mysql_fetch_row(mquery("select thread from forum_posts where id=".(int)$_GET['source']))[0];
$dstthread=mysql_fetch_row(mquery("select thread from forum_posts where id=".(int)$_GET['destination']));
if(file_exists("cache/forumthread".$dstthread.".dat")) unlink("cache/forumthread".$dstthread.".dat");
if(file_exists("cache/forumthread".$srcthread.".dat")) unlink("cache/forumthread".$srcthread.".dat");
mquery("update forum_posts set id={$tempid} where id=".(int)$_GET['source']);
mquery("update forum_posts set id=".(int)$_GET['source']." where id=".(int)$_GET['destination']);
mquery("update forum_posts set id=".(int)$_GET['destination']." where id={$tempid}");
}
echo "0";
?>