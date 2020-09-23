<?php
require("header.php");
if($_GET['set'] == 1) {
$q = mquery("SELECT `name`, `text` FROM `greetings`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['name']) {
$suc = true;
$greeting = $wiersz[1];
}
}
if($suc == true) {
$q = mquery("DELETE FROM `greetings` WHERE `name`='" . $_GET['name'] . "'");
}
$text = $_GET['text'];
if($_GET['buffer'] != null)
$text=buffer_get($_GET['buffer']);
$q = mquery("INSERT INTO `greetings` (`name`,`text`) VALUES ('" . $_GET['name'] . "','" . mysql_real_escape_string($text) . "')");
echo "0";
if($suc == true)
echo "\r\n*";
}
if($_GET['get'] == 1) {
$q = mquery("SELECT `name`, `text` FROM `greetings`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$text = $wiersz[1];
}
}
if($suc == false) {
echo "0\r\n     ";
die;
}
echo "0\r\n" . $text;
}
?>