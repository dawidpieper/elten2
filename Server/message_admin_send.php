<?php
require("header.php");
$zapytanie = "SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name']) {
$suc = true;
$name = $wiersz[0];
$tester = $wiersz[1];
$moderator = $wiersz[2];
$media_administrator = $wiersz[3];
$translator = $wiersz[4];
$developer = $wiersz[5];
}
}
if($suc == false) {
$moderator = 0;
$tester = 0;
$developer = 0;
$translator = 0;
$media_administrator = 0;
}
if($moderator == 0 and $developer == 0) {
echo "-3";
die;
}
$date = time();
$text = $_GET['text'];
if($_GET['buffer'] != null) {
$zapytanie = "SELECT `id`, `data`, `owner` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\nbuf";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['buffer'] and $wiersz[2] == $_GET['name'])
$text = $wiersz[1];
}
if($text == null) {
echo "-1\r\nnull";
die;
}
$text = mysql_escape_string($text);
}
$zapytanie = "INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent) VALUES ('', '" . 'elten' . "', '" . $_GET['to'] . "', '" . $_GET['subject'] . "', '" . $text . "', '" . $date . "',0,0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
?>