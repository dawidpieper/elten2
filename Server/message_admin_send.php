<?php
require("header.php");
$q = mquery("SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
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
$q = mysql_query("SELECT `id`, `data`, `owner` FROM `buffers`");
if($q == false) {
echo "-1\r\nbuf";
die;
}
while($wiersz = mysql_fetch_row($q)) {
if($wiersz[0] == $_GET['buffer'] and $wiersz[2] == $_GET['name'])
$text = $wiersz[1];
}
if($text == null) {
echo "-1\r\nnull";
die;
}
}
message_send('elten', $_GET['to'], $_GET['subject'], $text);
echo "0";
?>