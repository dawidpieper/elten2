<?php
if($_GET['mod']==1)
require("header.php");
else
require("init.php");
if($_GET['mod'] == 1) {
$q = mquery("SELECT `name` FROM `profiles` WHERE `name`='".$_GET['name']."'");
if(mysql_num_rows($q) <= 0) mquery("INSERT INTO `profiles` (name) VALUES ('".$_GET['name']."')");
mquery("UPDATE `profiles` SET `fullname`='".mysql_real_escape_string($_GET['fullname'])."', `gender`=".(int)$_GET['gender'].", `birthdateyear`=".(int)$_GET['birthdateyear'].", `birthdatemonth`=".(int)$_GET['birthdatemonth'].", `birthdateday`=".(int)$_GET['birthdateday'].", `location`='".mysql_real_escape_string($_GET['location'])."', `publicprofile`=".(int)$_GET['publicprofile'].", `publicmail`=".(int)$_GET['publicmail']." WHERE `name`='".$_GET['name']."'");
echo "0";
}
if($_GET['public'] == 1) {
$q = mquery("SELECT `name`, `publicprofile`, `publicmail` FROM `profiles` WHERE `name`='".mysql_real_escape_string($_GET['searchname'])."'");
$publicmail = 0;
$publicprofile = -1;
if(mysql_num_rows($q) > 0) {
$r = mysql_fetch_row($q);
$publicprofile = $r[1];
$publicmail = $r[2];
}
echo "0\r\n".$publicprofile."\r\n".$publicmail;
}
if($_GET['get'] == 1) {
$q = mquery("SELECT `name`, `publicprofile`, `publicmail` FROM `profiles` WHERE `name`='".mysql_real_escape_string($_GET['searchname'])."'");
$publicmail = 0;
$publicprofile = -1;
if(mysql_num_rows($q) > 0) {
$r = mysql_fetch_row($q);
$publicprofile = $r[1];
$publicmail = $r[2];
}
else
echo "-4";
if($publicprofile == 1) {
$q = mquery("SELECT `user` FROM `contacts` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."'");
if(mysql_num_rows($q) <= 0 and $_GET['name'] != $_GET['searchname']) {
echo "-3";
die;
}
}
$q = mquery("SELECT `name`, `fullname`, `gender`, `birthdateyear`, `birthdatemonth`, `birthdateday`, `location`, `publicprofile`, `publicmail` FROM `profiles` WHERE `name`='".mysql_real_escape_string($_GET['searchname'])."'");
$r = mysql_fetch_row($q);
echo "0\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5]."\r\n".$r[6]."\r\n".$r[7];
}
?>