<?php
require("header.php");
if($_GET['get']==1) {
$q=mquery("select user from blacklist where owner='".$_GET['name']."'");
$text="";
while($r=mysql_fetch_row($q))
$text.="\r\n".$r[0];
echo "0".$text;
}
if($_GET['del']==1) {
mquery("delete from blacklist where owner='".$_GET['name']."' and user='".mysql_real_escape_string($_GET['user'])."'");
echo "0";
}
if($_GET['add']==1) {
if(mysql_num_rows(mquery("select name from users where name='".mysql_real_escape_string($_GET['user'])."'"))==0) die("-5");
if(mysql_num_rows(mquery("select name from privileges where moderator=1 and name='".mysql_real_escape_string($_GET['user'])."'"))>0) die("-3");
if(mysql_num_rows(mquery("select user from blacklist where owner='".$_GET['name']."' and user='".mysql_real_escape_string($_GET['user'])."'"))>0) die("-4");
mquery("insert into blacklist (owner,user) values ('".$_GET['name']."','".mysql_real_escape_string($_GET['user'])."')");
echo "0";
}
?>