<?php
require("header.php");
if($_GET['searchname']!=$_GET['name']&&mysql_num_rows(mquery("SELECT name FROM banned WHERE name='".$_GET['name']."' AND totime>".time()))>0) die("-3");
$post = $_GET['post'];
if($_GET['buffer'] != null)
$post=buffer_get($_GET['buffer']);
$postid=$_GET['postid'];
mquery("INSERT INTO `blog_posts` (`owner`, `author`, `postid`, `posttype`, `post`, `date`) VALUES ('".mysql_real_escape_string($_GET['searchname'])."','".$_GET['name']."',".(int)$postid.",1,'" . mysql_real_escape_string($post) . "',".time().")");
$q = mquery("SELECT `name` FROM `blog_posts` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."' AND `postid`=".(int)$postid." AND `posttype`=0");
$postname = mysql_fetch_row($q)[0];
if($_GET['name'] != $_GET['searchname']) {
$msg = "User ".$_GET['name']." has commented post on your blog: ".$postname.".\r\nComment:\r\n".$post."\r\n\r\nNote, this message has been sent automatically.\r\nGreetings,\r\nElten Support";
$date = date("d.m.Y H:i");
}
echo "0";
?>