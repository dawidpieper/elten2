<?php
require("header.php");
if($_GET['get'] == 1) {
$q = mquery("SELECT `forum`, `thread` FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "'");
$text = "";
$ile = 0;
while ($r = mysql_fetch_row($q)){
$ile = $ile + 1;
$text .= $r[0] . "\r\n" . $r[1] . "\r\n";
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
if($_GET['add'] == 1) {
$q = mquery("SELECT `forum`, `thread` FROM `followedthreads` where `owner`='" . $_GET['name'] . "'");
$suc = false;
while ($r = mysql_fetch_row($q)){
if($r[1] == $_GET['thread'])
$suc = true;
}
if($suc == true) {
echo "-3";
die;
}
mquery("INSERT INTO `followedthreads` (owner, forum, thread) VALUES ('".$_GET['name']."','" . mysql_real_escape_string($_GET['forum']) . "','" . (int)$_GET['thread'] . "')");
echo "0";
}
if($_GET['remove'] == 1) {
mquery("DELETE FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "' AND `thread`='" . (int)$_GET['thread'] . "'");
echo "0";
}
if($_GET['get'] == 2) {
$q = mquery("SELECT `forum` FROM `followedforums` WHERE `owner`='" . $_GET['name'] . "'");
$text = "";
$ile = 0;
while ($r = mysql_fetch_row($q)){
$ile = $ile + 1;
$text .= $r[0] . "\r\n";
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
if($_GET['add'] == 2) {
$q = mquery("SELECT `forum` FROM `followedforums` where `owner`='" . $_GET['name'] . "'");
$suc = false;
while ($r = mysql_fetch_row($q)){
if($r[0] == $_GET['forum'])
$suc = true;
}
if($suc == true) {
echo "-3";
die;
}
mquery("INSERT INTO `followedforums` (owner, forum) VALUES ('".$_GET['name']."','" . mysql_real_escape_string($_GET['forum']) . "')");
echo "0";
}
if($_GET['remove'] == 2) {
mquery("DELETE FROM `followedforums` WHERE `owner`='" . $_GET['name'] . "' AND `forum`='" . mysql_real_escape_string($_GET['forum']) . "'");
echo "0";
}
?>