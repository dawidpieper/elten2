<?php
if($_GET['name']=="guest")
echo "0\r\n0\r\n0\r\n0\r\n0";
require("header.php");
$q = mquery("SELECT `name`, `messages`, `posts`, `blogposts`, `blogcomments` FROM `whatsnew`");
$suc = false;
while ($r = mysql_fetch_row($q)) {
if($r[0] == $_GET['name']) {
$name = $r[0];
$messages = $r[1];
$posts = $r[2];
$blogposts = $r[3];
$blogcomments = $r[4];
$suc = true;
}
}
if($suc == false) {
mquery("INSERT INTO `whatsnew` (name, messages, posts, blogposts, blogcomments) VALUES ('" . $_GET['name'] . "',0,0,0,0)");
$name = $_GET['name'];
$messages = 0;
$posts = 0;
$blogposts = 0;
$blogcomments = 0;
}
if($_GET['get'] == 1) {
$q = mquery("SELECT * FROM `messages` WHERE `deletedfromreceived`=0 and `receiver`='".$_GET['name']."'");
$emessages = mysql_num_rows($q);
$eposts = 0;
$q = mquery("SELECT `id`, `forum`, `thread` FROM `followedthreads` WHERE `owner`='".$_GET['name']."'");
while($r = mysql_fetch_row($q)) {
$wq = mquery("SELECT `id` FROM `forum_posts` WHERE `thread`=".$r[2]);
$eposts = $eposts + mysql_num_rows($wq);
$wq = mquery("SELECT `posts` FROM `forum_read` WHERE `owner`='".$_GET['name']."' AND `thread`='".$r[2]."'");
$wr = mysql_fetch_row($wq);
$eposts = $eposts - $wr[0];
}
$eblogposts = mysql_fetch_row(mquery("SELECT COUNT(*) `postid` FROM `blog_posts` bp where `posttype`=0 and NOT EXISTS (SELECT 1 FROM `blog_read` br WHERE `owner`='".$_GET['name']."' and bp.postid = br.post and br.author=bp.owner) and author in (select `author` from `followedblogs` where owner='".$_GET['name']."')"))[0];
$eblogcomments = mysql_num_rows(mquery("SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['name']."'"))-(mysql_fetch_row(mquery("SELECT SUM(`posts`) FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".$_GET['name']."' AND `post` IN (SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['name']."')"))[0]);
$nblogposts = $eblogposts - $blogposts;
$nblogcomments = $eblogcomments - $blogcomments;
$nposts = $eposts - $posts;
$nmessages = $emessages - $messages;
if($nmessages==-1) {
$nmessages = 0;
mquery("UPDATE `whatsnew` SET `messages`=0 WHERE `name`=".$_GET['name']);
}
echo "0\r\n" . $nmessages . "\r\n" . $nposts . "\r\n" . $nblogposts . "\r\n" . $nblogcomments;
}
if($_GET['set']>0) {
$nmessages = (int)$_GET['messages'];
if($_GET['set']==2)
$nmessages=mysql_num_rows(mquery("SELECT `id` FROM `messages` WHERE `receiver`='".$_GET['name']."' AND `deletedfromreceived`=0"))-$nmessages;
$nposts = (int)$_GET['posts'];
if($_GET['blogposts'] != NULL)
$nblogposts = (int)$_GET['blogposts'];
else
$nblogposts = -1;
if($_GET['blogcomments'] != NULL)
$nblogcomments = (int)$_GET['blogcomments'];
else
$nblogcomments = -1;
if($nposts == -1)
$nposts = $posts;
if($nmessages == -1)
$nmessages = $messages;
if($nblogposts == -1)
$nblogposts = $blogposts;
if($nblogcomments == -1)
$nblogcomments = $blogcomments;
mquery("UPDATE `whatsnew` SET `messages`=".(int)$nmessages.", `posts`=".(int)$nposts.", `blogposts`=".(int)$nblogposts.", `blogcomments`=".(int)$nblogcomments." WHERE `name`='" . $_GET['name'] . "'");
echo "0";
}
?>