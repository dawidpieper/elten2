<?php
require("header.php");
$error = 0;
if($_GET['delete'] == 1) {
mquery("DELETE FROM `contacts` where owner='".$_GET['name']."' and user='".mysql_real_escape_string($_GET['searchname'])."'");
echo "0";
}
if($_GET['insert'] == 1) {
if(mysql_num_rows(mquery("SELECT `user` FROM `contacts` where user='".mysql_real_escape_string($_GET['searchname'])."' and owner='" . $_GET['name'] . "'"))>0)
die("-3");
mquery("INSERT INTO `contacts` (owner, user, time) values ('" . $_GET['name'] . "','" . mysql_real_escape_string($_GET['searchname']) . "', unix_timestamp())");
echo "0";
}
if($_GET['delete'] == 0 and $_GET['insert'] == 0) {
if(mysql_num_rows(mquery("SELECT `user` FROM `contacts` where user='".mysql_real_escape_string($_GET['searchname'])."' and owner='" . $_GET['name'] . "'"))>0)
echo "-3";
else
echo "0";
}
?>