<?php
require("header.php");
$wiersze=0;
$text="";
if($_GET['categoryid']>0)
$zapytanie = "SELECT `postid` FROM `blog_assigning` WHERE `categoryid`=".$_GET['categoryid']." AND `owner`='".$_GET['searchname']."' ORDER BY `postid` DESC";
else
$zapytanie = "SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['searchname']."' AND `posttype`=0 ORDER BY `postid` DESC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
$wzapytanie = "SELECT `postid`, `name` FROM `blog_posts` WHERE `owner`='" . $_GET['searchname'] . "' AND `postid`=" . $wiersz[0];
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1\r\n".$wzapytanie;
die;
}
$wwiersz = mysql_fetch_row($widzapytania);
$wiersze += 1;
$text .= $wwiersz[0] . "\r\n" . $wwiersz[1] . "\r\n";
}
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>