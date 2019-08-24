<?php
require("header.php");
if(mysql_num_rows(mquery("select name,password from users where name='".$_GET['name']."' and password='".mysql_real_escape_string($_GET['password'])."'"))==0)
die("-3");
$q=mquery("select date,ip,computer from autologins where name='".$_GET['name']."'");
echo "0";
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2];
?>