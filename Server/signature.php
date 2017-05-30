<?php
require("header.php");
if($_GET['set'] == 1) {
$zapytanie = "SELECT `name`, `signature` FROM `signatures`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name']) {
$suc = true;
$signature = $wiersz[1];
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `signatures` WHERE `name`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
$text = $_GET['text'];
if($_GET['buffer'] != null) {
$zapytanie = "SELECT `id`, `data`, `owner` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['buffer'] and $wiersz[2] == $_GET['name'])
$text = $wiersz[1];
}
if($text == null) {
echo "-1";
die;
}
$text = str_replace("\\","\\\\",$text);
$text = str_replace("'","\\'",$text);
}
$zapytanie = "INSERT INTO `signatures` (`name`,`signature`) VALUES ('" . $_GET['name'] . "','" . $text . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
if($suc == true)
echo "\r\n*";
}
if($_GET['get'] == 1) {
$zapytanie = "SELECT `name`, `signature` FROM `signatures`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$signature = $wiersz[1];
}
}
if($suc == false) {
echo "0\r\n     ";
die;
}
echo "0\r\n" . $signature;
}
?>