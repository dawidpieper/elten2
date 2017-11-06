<?php
require("header.php");
$q = mquery("SELECT `name`, `password`, `resetpassword` FROM `users`");
$suc = false;
while ($r = mysql_fetch_row($q)){
if($r[0] == $_GET['name'])
if(($r[1] == $_GET['oldpassword']) or (($r[2] != NULL) and ($r[2]==$_GET['oldpassword'])))
$suc = true;
else
$error = -2;
}
if($suc == false) {
echo "-6";
die;
}
if($_GET['changepassword'] == 1) {
mquery("UPDATE `users` SET `password`='" . $_GET['password'] . "' WHERE name='" . $_GET['name'] . "'");
mquery("UPDATE users SET `resetpassword`=NULL where `name`='".$_GET['name']."'");
echo "0";
}
if($_GET['changemail'] == 1) {
mquery("UPDATE `users` SET `mail`='" . $_GET['mail'] . "' WHERE name='" . $_GET['name'] . "'");
echo "0";
}
?>