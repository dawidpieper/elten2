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
mquery("UPDATE `users` SET `password`='" . mysql_real_escape_string($_GET['password']) . "' WHERE name='" . mysql_real_escape_string($_GET['name']) . "'");
mquery("UPDATE users SET `resetpassword`=NULL where `name`='".mysql_real_escape_string($_GET['name'])."'");
mail_notify($_GET['name'],'Your password has been changed');
echo "0";
}
if($_GET['changemail'] == 1) {
if(mysql_num_rows(mquery("select name from users where name='{$_GET['name']}' and verified=1 and events=1"))>0) die("-7");
mquery("UPDATE `users` SET `mail`='" . mysql_real_escape_string($_GET['mail']) . "', verified=0 WHERE name='" . mysql_real_escape_string($_GET['name']) . "'");
echo "0";
}
?>