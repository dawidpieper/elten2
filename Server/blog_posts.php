<?php
require("header.php");
$wiersze=0;
$text="";
if($_GET['categoryid']=="NEW")
$zapytanie = "SELECT `post` FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".$_GET['name']."' AND `posts`<(SELECT COUNT(*) FROM `blog_posts` WHERE blog_posts.owner=blog_read.author AND blog_posts.postid=blog_read.post) ORDER BY `post` DESC";
elseif($_GET['categoryid']>0)
$zapytanie = "SELECT `postid` FROM `blog_assigning` WHERE `categoryid`=".$_GET['categoryid']." AND `owner`='".$_GET['searchname']."' ORDER BY `postid` DESC";
else
$zapytanie = "SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['searchname']."' AND `posttype`=0 ORDER BY `postid` DESC";
$idzapytania = mquery($zapytanie);
while($wiersz = mysql_fetch_row($idzapytania)) {
$widzapytania = mquery("SELECT `postid`, `name` FROM `blog_posts` WHERE `owner`='" . $_GET['searchname'] . "' AND `postid`=" . $wiersz[0]);
$wwiersz = mysql_fetch_row($widzapytania);
$wiersze += 1;
$text .= $wwiersz[0] . "\r\n" . $wwiersz[1] . "\r\n";
}
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>