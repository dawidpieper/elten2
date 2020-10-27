<?php
require("header.php");
if($_GET['list']>=1) {
$qt="select id,author,thread,post,message,time from mentions where user='".$_GET['name']."'";
if($_GET['list']==1)
$qt.=" and noticed is null";
$q=mquery($qt);
echo "0";
while($r=mysql_fetch_row($q)) {
echo "\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".str_replace("\n","",$r[4]);
if($_GET['details']==1)
echo "\r\n".$r[5];
}
}
if($_GET['add']==1) {
if(mysql_num_rows(mquery("select owner from contacts where owner='".mysql_real_escape_string($_GET['user'])."' and user='".$_GET['name']."'"))==0)
die("-3");
mquery("insert into mentions (author,user,type,thread,post,message,`time`) values ('".$_GET['name']."','".mysql_real_escape_string($_GET['user'])."',0,".(int) $_GET['thread'].",".(int) $_GET['post'].",'".mysql_real_escape_string($_GET['message'])."',".time().")");
echo "0";
}
if($_GET['notice']==1) {
mquery("update mentions set noticed=".time()." where user='".$_GET['name']."' and id=".(int) $_GET['id']);
echo "0";
}
?>