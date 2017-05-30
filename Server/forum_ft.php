<?php
require("header.php");
if($_GET['get'] == 1) {
$zapytanie = "SELECT `forum`, `thread` FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1";
die;
}
$text = "";
$ile = 0;
while ($wiersz = mysql_fetch_row($idzapytania)){
$ile = $ile + 1;
$text .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n";
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
if($_GET['add'] == 1) {
$zapytanie = "SELECT `forum`, `thread` FROM `followedthreads` where `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[1] == $_GET['thread'])
$suc = true;
}
if($suc == true) {
echo "-3";
die;
}
$zapytanie = "INSERT INTO `followedthreads` (id, owner, forum, thread) VALUES ('','".$_GET['name']."','" . $_GET['forum'] . "','" . $_GET['thread'] . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['remove'] == 1) {
$zapytanie = "DELETE FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "' AND `thread`='" . $_GET['thread'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
?>