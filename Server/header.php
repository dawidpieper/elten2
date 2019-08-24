<?php
require("init.php");
$q=mquery("SELECT `token`, `name`, `time` FROM `tokens` where token='".mysql_real_escape_string($_GET['token'])."' and name='".mysql_real_escape_string($_GET['name'])."'");
$error = -1;
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['token'])
if($wiersz[1] == $_GET['name']) {
if($wiersz[2] == date("dmY")) {
$error = "0";
$suc = true;
}
else {
$error = -2;
if($wiersz[2] == date("dmY",time()-86400)) {
mquery("UPDATE `tokens` SET `time`='".date("dmY")."' WHERE `token`='".mysql_real_escape_string($_GET['token'])."'");
$error = 0;
$suc = true;
}
}
}
else
$error = -2;
else
$error = -2;
}
if($suc == false) {
echo $error;
die;
}
?>