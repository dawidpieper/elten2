<?php
require("header.php");
if($_GET['get'] == 1) {
$q = mquery("SELECT `author` FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "'");
echo "0\r\n".mysql_num_rows($q);
while ($r = mysql_fetch_row($q))
echo "\r\n".$r[0];
}
if($_GET['add'] == 1) {
if(mysql_num_rows(mquery("SELECT `author` FROM `followedblogs` where `author`='".mysql_real_escape_string($_GET['searchname'])."' and `owner`='" . $_GET['name'] . "'"))>0)
die("-3");
mquery("INSERT INTO `followedblogs` (owner, author) VALUES ('".$_GET['name']."','" . mysql_real_escape_string($_GET['searchname']) . "')");
echo "0";
}
if($_GET['remove'] == 1) {
mquery("DELETE FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "' AND `author`='" . mysql_real_escape_string($_GET['searchname']) . "'");
echo "0";
}
if($_GET['check'] == 1) {
$c = mysql_num_rows(mquery("SELECT `author` FROM `followedblogs` where `owner`='" . $_GET['name'] . "' and author='".mysql_real_escape_string($_GET['searchname'])."'"));
echo "0\r\n".$c;
}
?>