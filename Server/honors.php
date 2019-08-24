<?php
require("header.php");
if($_GET['list']==1) {
if($_GET['user']==NULL)
$q=mquery("SELECT id,name,description,enname,endescription from honors");
else
if($_GET['main']==NULL)
$q=mquery("SELECT id,name,description,enname,endescription from honors WHERE id in (SELECT `honor` FROM `users_honors` WHERE `user`='".mysql_real_escape_string($_GET['user'])."')");
else
$q=mquery("SELECT id,name,description,enname,endescription from honors WHERE id in (SELECT `honor` FROM `users_honors` WHERE main=1 and `user`='".mysql_real_escape_string($_GET['user'])."')");
$t="";
$c=mysql_num_rows($q);
while($r=mysql_fetch_row($q)) {
$t.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4];
}
echo "0\r\n".$c.$t;
}
if($_GET['user']==1) {
$q=mquery("SELECT honor from users_honors WHERE `user`='".mysql_real_escape_string($_GET['searchname'])."'");
$t="";
$c=mysql_num_rows($q);
while($r=mysql_fetch_row($q)) {
$t.="\r\n".$r[0];
}
echo "0\r\n".$c.$t;
}
if($_GET['setmain']==1) {
mquery("UPDATE users_honors set main=0 where user='".$_GET['name']."'");
mquery("UPDATE users_honors set main=1 where user='".$_GET['name']."' AND `honor`=".(int)$_GET['honor']);
echo "0";
}
if($_GET['getmain']==1) {
$q=mquery("SELECT `honor` from `users_honors` where `user`='".mysql_real_escape_string($_GET['searchname'])."' AND `main`=1");
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
mquery("INSERT INTO `users_honors` (user,honor) VALUES ('".mysql_real_escape_string($_GET['user'])."',".(int)$_GET['honor'].")");
echo "0";
}
if($_GET['addhonor']==1) {
$moderator=getprivileges($_GET['name'])[1];
if($moderator==0) {
echo "-3";
die;
}
mquery("INSERT INTO `honors` (name,description,enname,endescription) VALUES ('".mysql_real_escape_string($_GET['honorname'])."','".mysql_real_escape_string($_GET['honordescription'])."','".mysql_real_escape_string($_GET['honorenname'])."','".mysql_real_escape_string($_GET['honorendescription'])."')");
echo "0";
}
?>