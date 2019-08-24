<?php
require("init.php");
$q = mquery("SELECT `postid`, `author`, `post`, `date`, `moddate`, `privacy` FROM `blog_posts` WHERE `owner`='" . mysql_real_escape_string($_GET['searchname']) . "' AND `postid`=" . (int)$_GET['postid']);
$re = 0;
$text = "";
$rq = mquery("SELECT `id`, `author`, `post`, `posts` FROM `blog_read` WHERE `owner`='".$_GET['name']."'");
$suc = false;
$knownposts=0;
while($rr = mysql_fetch_row($rq)) {
if($rr[1] == $_GET['searchname'] AND $rr[2] == $_GET['postid']) {
$suc = true;
$knownposts=$rr[3];
}
}
if($_GET['name']!="guest") {
if($suc == true)
mquery("UPDATE `blog_read` SET `posts`=".mysql_num_rows($q)." WHERE `owner`='".$_GET['name']."' AND `author`='".mysql_real_escape_string($_GET['searchname'])."' AND `post`=".(int)$_GET['postid']);
else
mquery("INSERT INTO `blog_read` (owner, author, post, posts) VALUES ('".$_GET['name']."','".mysql_real_escape_string($_GET['searchname'])."',".(int)$_GET['postid'].",".mysql_num_rows($q).")");
}
if($_GET['details']==1)
$text=$knownposts."\r\n";
while ($r = mysql_fetch_row($q)){
$re += 1;
if($_GET['details']==3)
$text .= $r[0] . "\r\n" . $r[1] . "\r\n" . $r[3] . "\r\n" . $r[4] . "\r\n" . $r[5] . "\r\n" . $r[2] . "\r\nEND\r\n";
elseif($_GET['details']==2)
$text .= $r[0] . "\r\n" . $r[1] . "\r\n" . $r[3] . "\r\n" . $r[4] . "\r\n" . $r[2] . "\r\nEND\r\n";
else
$text .= $r[0] . "\r\n" . $r[1] . "\r\n" . $r[2] . "\r\n" . date("Y-m-d H:i:s",$r[3]) . "\r\n" . "\r\n" . "\r\nEND\r\n";
}
echo "0\r\n" . $re . "\r\n" . $text;
?>