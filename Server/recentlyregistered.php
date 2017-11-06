<?php
require("init.php");
$q=mquery("SELECT name,time from logins");
$users=array();
while($r=mysql_fetch_row($q)) {
if($users[$r[0]]==NULL)
$users[$r[0]]=$r[1];
}
asort($users);
$users=array_reverse($users);
$res=array();
foreach($users as $user=>$date)
$res[]=$user;
echo "0\r\n".implode("\r\n",$res);
?>