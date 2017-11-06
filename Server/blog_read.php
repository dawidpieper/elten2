<?php
require("init.php");
$zapytanie = "SELECT `postid`, `author`, `post` FROM `blog_posts` WHERE `owner`='" . $_GET['searchname'] . "' AND `postid`=" . $_GET['postid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$wiersze = 0;
$text = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$wiersze += 1;
$text .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2] . "\r\nEND\r\n";
}
$zapytanie = "SELECT `id`, `author`, `post` FROM `blog_read` WHERE `owner`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$suc = false;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[1] == $_GET['searchname'] AND $wiersz[2] == $_GET['postid']) {
$suc = true;
}
}
if($_GET['name']!="guest")
if($suc == true)
mquery("UPDATE `blog_read` SET `posts`=".$wiersze." WHERE `owner`='".$_GET['name']."' AND `author`='".$_GET['searchname']."' AND `post`=".$_GET['postid']);
else
mquery("INSERT INTO `blog_read` (id, owner, author, post, posts) VALUES ('','".$_GET['name']."','".$_GET['searchname']."',".$_GET['postid'].",".$wiersze.")");
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>