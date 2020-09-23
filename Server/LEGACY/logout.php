<?php
require("header.php");
mquery("update actived set actived=0 where name='".mysql_real_escape_string($_GET['name'])."'");
if($_GET['global']==0 or $_GET['global']==NULL) {
mquery("DELETE FROM `tokens` WHERE `token`='".$_GET['token']."'");
if(isset($_GET['autotoken']))
mquery("delete from autologins where token='".mysql_real_escape_string($_GET['autotoken'])."' and name='".$_GET['name']."'");
if(isset($_GET['computer']))
mquery("delete from autologins where computer='".mysql_real_escape_string($_GET['computer'])."' and name='".$_GET['name']."'");
}
else {
if(mysql_num_rows(mquery("select name,password from users where name='".$_GET['name']."' and password='".mysql_real_escape_string($_GET['password'])."'"))==0)
die("-3");
mquery("delete from autologins where name='".$_GET['name']."'");
mquery("delete from tokens where name='".$_GET['name']."'");
}
echo "0";
?>