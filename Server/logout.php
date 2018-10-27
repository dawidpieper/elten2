<?php
require("header.php");
if($_GET['global']==0 or $_GET['global']==NULL) {
if($_GET['autologin']==NULL or $_GET['autologin']==0)
mquery("DELETE FROM `tokens` WHERE `token`='".$_GET['token']."'");
else
mquery("delete from autologins where token='".$_GET['autotoken']."' and name='".$_GET['name']."'");
}
else {
if(mysql_num_rows(mquery("select name,password from users where name='".$_GET['name']."' and password='".$_GET['password']."'"))==0)
die("-3");
mquery("delete from autologins where name='".$_GET['name']."'");
mquery("delete from tokens where name='".$_GET['name']."'");
}
echo "0";
?>