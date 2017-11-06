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
if($_GET['get'] == 1) {
$zapytanie = "SELECT `id`, `question`, `answer` from `faq` where accepted=1";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$text = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
$text .= "\r\n".$wiersz[0] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2] . "\r\nEND";
}
echo "0".$text;
}
if($_GET['get'] == 2) {
$zapytanie = "SELECT `id`, `question` from `faq` where accepted=0";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$text = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
$text .= "\r\n".$wiersz[0] . "\r\n" . $wiersz[1];
}
echo "0".$text;
}
if($_GET['add'] == 1) {
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
$zapytanie = "INSERT INTO faq (id, question, answer, accepted) values ('','".$text."','',0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['answer'] == 1)
if($moderator == 0 and $developer == 0) {
echo "-3";
die;
}
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
$zapytanie = "UPDATE faq set `answer`='".$text."',`accepted`=1 WHERE `id`=".$_GET['id']."";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['unanswer'] == 1) {
if($moderator == 0 and $developer == 0) {
echo "-3";
die;
}
$zapytanie = "UPDATE `faq` SET `answered`=0 WHERE `id`=".$_GET['id'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['del'] == 1) {
if($moderator == 0 or $developer == 0) {
echo "-3";
die;
}
$zapytanie = "DELETE FROM `faq` WHERE `id`=".$_GET['id'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
?>