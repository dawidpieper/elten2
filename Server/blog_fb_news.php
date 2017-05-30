<?php
require("header.php");
$zapytanie = "SELECT `author` FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$text = "";
$ile = 0;
while ($wiersz = mysql_fetch_row($idzapytania)) {
$wzapytanie = "SELECT `postid`, `name` FROM `blog_posts` WHERE `owner`='".$wiersz[0]."' AND `posttype`=0";
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1\r\n".$wzapytanie;
die;
}
while($wwiersz = mysql_fetch_row($widzapytania)) {
$wwwzapytanie = "SELECT `id` FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".$wiersz[0]."' AND `post`=".$wwiersz[0];
$wwwidzapytania = mysql_query($wwwzapytanie);
if($wwwidzapytania == false) {
echo "-1\r\n".$wwwzapytanie;
die;
}
if(mysql_num_rows($wwwidzapytania) == 0) {
$ile = $ile + 1;
$tekst .= "\r\n".$wiersz[0]."\r\n0\r\n".$wwiersz[0]."\r\n".$wwiersz[1];
}
}
}
echo "0\r\n" . $ile . $tekst;
?>