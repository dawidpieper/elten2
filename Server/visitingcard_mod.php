<?php
require("header.php");
$zapytanie = "SELECT `name`, `text` FROM `visitingcards`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name']) {
$suc = true;
$visitingcard = $wiersz[1];
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `visitingcards` WHERE `name`='" . $_GET['name'] . "'";
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
$zapytanie = "INSERT INTO `visitingcards` (`name`,`text`) VALUES ('" . $_GET['name'] . "','" . $text . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
if($suc == true)
echo "\r\n*";
?>