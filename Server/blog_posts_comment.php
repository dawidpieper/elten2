<?php
require("header.php");
$post = $_GET['post'];
if($_GET['buffer'] != null) {
$idzapytania = mquery("SELECT `id`, `data`, `owner` FROM `buffers`");
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['buffer'] and $wiersz[2] == $_GET['name'])
$post = $wiersz[1];
}
if($post == null) {
echo "-1";
die;
}
$post = str_replace("\\","\\\\",$post);
$post = str_replace("'","\\'",$post);
}
$postid=$_GET['postid'];
mquery("INSERT INTO `blog_posts` (`id`, `owner`, `author`, `postid`, `posttype`, `post`, `date`) VALUES ('','".$_GET['searchname']."','".$_GET['name']."',".$postid.",1,'" . $post . "',".time().")");
$idzapytania = mquery("SELECT `name` FROM `blog_posts` WHERE `owner`='".$_GET['searchname']."' AND `postid`=".$postid." AND `posttype`=0");
$postname = mysql_fetch_row($idzapytania)[0];
if($_GET['name'] != $_GET['searchname']) {
$msg = "User ".$_GET['name']." has commented post on your blog: ".$postname.".\r\nComment:\r\n".$post."\r\n\r\nNote, this message has been sent automatically.\r\nGreetings,\r\nElten Support";
$date = date("d.m.Y H:i");
//mquery("INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, `deletedfromreceived`, `deletedfromsent`) VALUES ('', 'elten', '".$_GET['searchname']."', 'New comment on your blog', '" . $msg . "', '" . $date . "',0,0)");
}
echo "0";
?>