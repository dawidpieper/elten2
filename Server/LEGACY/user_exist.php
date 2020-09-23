<?php
require("init.php");
$q = mquery("SELECT `name`, `mail` FROM `users`");
$suc = false;
$esuc=false;
while ($r = mysql_fetch_row($q)){
if($r[0] == $_GET['searchname'])
$suc = true;
if(isset($_GET['searchmail']) and $r[0]==$_GET['searchname'] and $r[1] == $_GET['searchmail'])
$esuc=true;
}
echo "0\r\n";
if($suc == false)
echo "0";
else
echo "1";
if(isset($_GET['searchmail']))
if($esuc == false)
echo "\r\n0";
else
echo "\r\n1";
?>