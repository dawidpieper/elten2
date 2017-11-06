<?php
require("header.php");
if($_GET['list']==1) {
if($_GET['user']==NULL)
$q=mquery("SELECT id,name,description,enname,endescription from honors");
else
if($_GET['main']==NULL)
$q=mquery("SELECT id,name,description,enname,endescription from honors WHERE id in (SELECT `honor` FROM `users_honors` WHERE `user`='".$_GET['user']."')");
else
$q=mquery("SELECT id,name,description,enname,endescription from honors WHERE id in (SELECT `honor` FROM `users_honors` WHERE main=1 and `user`='".$_GET['user']."')");
$t="";
$c=mysql_num_rows($q);
while($r=mysql_fetch_row($q)) {
$t.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4];
}
echo "0\r\n".$c.$t;
}
if($_GET['user']==1) {
$q=mquery("SELECT honor from users_honors WHERE `user`='".$_GET['searchname']."'");
$t="";
$c=mysql_num_rows($q);
while($r=mysql_fetch_row($q)) {
$t.="\r\n".$r[0];
}
echo "0\r\n".$c.$t;
}
if($_GET['setmain']==1) {
mquery("UPDATE users_honors set main=0 where user='".$_GET['name']."'");
mquery("UPDATE users_honors set main=1 where user='".$_GET['name']."' AND `honor`=".$_GET['honor']);
echo "0";
}
if($_GET['getmain']==1) {
$q=mquery("SELECT `honor` from `users_honors` where `user`='".$_GET['searchname']."' AND `main`=1");
if(mysql_num_rows($q)==0)
echo "0\r\n0";
else
echo "0\r\n".mysql_fetch_row($q)[0];
}
if($_GET['award']==1) {
$moderator=getprivileges($_GET['name'])[1];
if($moderator==0) {
echo "-3";
die;
}
mquery("INSERT INTO `users_honors` (id,user,honor) VALUES ('','".$_GET['user']."',".$_GET['honor'].")");
//mquery("INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent) VALUES ('', 'elten', '".$_GET['user']."', 'You were awarded', 'we are pleased to announce, that you were awarded!\r\nYour new honor:" . mysql_fetch_row(mquery("SELECT name from honors where id=".$_GET['honor']))[0] . "\r\nRegards!\r\nElten Support Team', '" . date("d.m.Y H:i") . "',0,0)");
echo "0";
}
if($_GET['addhonor']==1) {
$moderator=getprivileges($_GET['name'])[1];
if($moderator==0) {
echo "-3";
die;
}
mquery("INSERT INTO `honors` (id,name,description,enname,endescription) VALUES ('','".$_GET['honorname']."','".$_GET['honordescription']."','".$_GET['honorenname']."','".$_GET['honorendescription']."')");
echo "0";
}
?>