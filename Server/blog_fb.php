<?php
require("header.php");
if($_GET['get'] == 1) {
$q = mquery("SELECT `author` FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "'");
$text = "";
$ile = 0;
while ($wiersz = mysql_fetch_row($q)){
$ile = $ile + 1;
$text .= $wiersz[0] . "\r\n";
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
if($_GET['add'] == 1) {
$q = mquery("SELECT `author` FROM `followedblogs` where `owner`='" . $_GET['name'] . "'");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname'])
$suc = true;
}
if($suc == true) {
echo "-3";
die;
}
$q = mquery("INSERT INTO `followedblogs` (owner, author) VALUES ('".$_GET['name']."','" . mysql_real_escape_string($_GET['searchname']) . "')");
echo "0";
}
if($_GET['remove'] == 1) {
$q = mysql_query("DELETE FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "' AND `author`='" . mysql_real_escape_string($_GET['searchname']) . "'");
echo "0";
}
if($_GET['check'] == 1) {
$q = mquery("SELECT `author` FROM `followedblogs` where `owner`='" . $_GET['name'] . "'");
if ($q == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
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