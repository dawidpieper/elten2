<?php
if($_GET['name']=="guest" and $_GET['token']=="guest")
die("0\r\n".time());
require("header.php");
mquery("INSERT INTO `actived` (name, date, shown, actived) VALUES ('" . $_GET['name'] . "','" . time() . "', ".(int)$shown.",1) ON DUPLICATE KEY UPDATE name=VALUES(name),date=VALUES(DATE),shown=VALUES(shown),actived=values(actived)");
if(mysql_num_rows(($q=mquery("select name from actived where date>unix_timestamp()-10")))>mysql_fetch_row(mquery("select max(score) from onlinescores"))[0]) {
$users=array();
while($r=mysql_fetch_row($q)) array_push($users,$r[0]);
mquery("insert into onlinescores (time,score,users) values (".time().",".mysql_num_rows($q).",'".mysql_real_escape_string(implode(",",$users))."')");
}
echo "0\r\n".time();
?>