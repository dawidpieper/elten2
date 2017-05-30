<?php
require("header.php");
if($_GET['get'] == 1) {
$zapytanie = "SELECT `author` FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1";
die;
}
$text = "";
$ile = 0;
while ($wiersz = mysql_fetch_row($idzapytania)){
$ile = $ile + 1;
$text .= $wiersz[0] . "\r\n";
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
if($_GET['add'] == 1) {
$zapytanie = "SELECT `author` FROM `followedblogs` where `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname'])
$suc = true;
}
if($suc == true) {
echo "-3";
die;
}
$zapytanie = "INSERT INTO `followedblogs` (id, owner, author) VALUES ('','".$_GET['name']."','" . $_GET['searchname'] . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['remove'] == 1) {
$zapytanie = "DELETE FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "' AND `author`='" . $_GET['searchname'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['check'] == 1) {
$zapytanie = "SELECT `author` FROM `followedblogs` where `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname'])
$suc = true;
}
echo "0\r\n";
if($suc == true)
echo "1";
else
echo "0";
}
?>