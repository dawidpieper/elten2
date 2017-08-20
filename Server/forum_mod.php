<?php
require("header.php");
$moderator=getprivileges($_GET['name'])[1];
if($_GET['delete'] == 1) {
if($moderator == 0) {
echo "-3";
die;
}
mquery("DELETE FROM `forum_threads` WHERE `id`=" . $_GET['threadid'] . " AND `forum`='".$_GET['forumname']."'");
mquery("INSERT INTO `forum_posts_deleted` SELECT * FROM `forum_posts` WHERE `thread`=" . $_GET['threadid']);
mquery("DELETE FROM `forum_posts` WHERE `thread`=" . $_GET['threadid']);
mquery("UPDATE `cache` SET `expiredate`=".time()." WHERE id=0 OR `forumname`='".$_GET['forumname']."'");
mquery("DELETE FROM `followedthreads` WHERE `thread`=" . $_GET['threadid']);
}
if($_GET['delete'] == 2) {
if($moderator == 0) {
echo "-3";
die;
}
mquery("INSERT INTO `forum_posts_deleted` SELECT * FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'] . " AND `id`=" . $_GET['postid']);
mquery("DELETE FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'] . " AND `id`=" . $_GET['postid']);
mquery("UPDATE `cache` SET `expiredate`=".time()." WHERE id=0 OR `forumname`='".$_GET['forumname']."'");
mquery("UPDATE `forum_read` SET `posts`=`posts`-1 WHERE `thread`=" . $_GET['threadid']);
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
echo "0";
?>