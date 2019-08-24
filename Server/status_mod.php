<?php
require("header.php");
$q = mysql_query("SELECT `name`, `status` FROM `statuses`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['name']) {
$suc = true;
$status = $wiersz[1];
}
}
if($suc == true) {
mquery("DELETE FROM `statuses` WHERE `name`='" . $_GET['name'] . "'");
}
mquery("INSERT INTO `statuses` (`name`,`status`) VALUES ('" . $_GET['name'] . "','" . mysql_real_escape_string($_GET['text']) . "')");
echo "0";
if($suc == true)
echo "\r\n*";
?>