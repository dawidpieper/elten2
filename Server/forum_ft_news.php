<?php
require("header.php");
if($_GET['get'] == 1) {
$zapytanie = "SELECT `forum`, `thread` FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$text = "";
$ile = 0;
while ($wiersz = mysql_fetch_row($idzapytania)) {
$postsinthread = 0;
$readpostsinthread = 0;
$wzapytanie = "SELECT `id`, `thread`, `posts` FROM `forum_read` WHERE `owner`='".$_GET['name']."' AND `thread`='".$wiersz[1]."'";
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1\r\n".$wzapytanie;
die;
}
$wwiersz = mysql_fetch_row($widzapytania);
$readpostsinthread = $wwiersz[2];
$wzapytanie = "SELECT `id` FROM `forum_posts` WHERE `thread`=".$wiersz[1];
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1\r\n".$wzapytanie;
die;
}
$postsinthread = mysql_num_rows($widzapytania);
if($readpostsinthread < $postsinthread) {
$ile = $ile + 1;
$text .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n".$postsinthread."\r\n";
}
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
?>