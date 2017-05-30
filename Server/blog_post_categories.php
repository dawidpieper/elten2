<?php
require("header.php");
$zapytanie = "SELECT `categoryid` FROM `blog_assigning` WHERE `postid`=".$_GET['postid']." AND `owner`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$wiersze=0;
$tekst="";
while($wiersz = mysql_fetch_row($idzapytania)) {
$wiersze = $wiersze + 1;
$tekst .= "\r\n".$wiersz[0];
}
$zapytanie = "SELECT `name` FROM `blog_posts` WHERE `owner`='".$_GET['searchname']."' AND `postid`=".$_GET['postid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0\r\n".mysql_fetch_row($idzapytania)[0]."\r\n".$wiersze.$tekst;
?>