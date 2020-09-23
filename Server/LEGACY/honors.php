<?php

function isJson($string) {
json_decode($string);
return (json_last_error() == JSON_ERROR_NONE);
}
require("header.php");
if($_GET['list']>=1) {
if($_GET['user']==NULL)
$q=mquery("SELECT h.id,h.name,h.description,h.enname,h.endescription,h.levels,h.enlevels, 0 from honors h");
else
if($_GET['main']==NULL)
$q=mquery("SELECT h.id,h.name,h.description,h.enname,h.endescription,h.levels,h.enlevels,u.level from honors h left join users_honors u on u.honor=h.id WHERE u.user='".$_GET['user']."'");
else
$q=mquery("SELECT h.id,h.name,h.description,h.enname,h.endescription,h.levels,h.enlevels,u.level from honors h left join users_honors u on u.honor=h.id WHERE u.main=1 and u.user='".$_GET['user']."'");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q)) {
echo "\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4];
if($_GET['list']==2)
echo "\r\n".$r[5]."\r\n".$r[6]."\r\n".(int)$r[7];
}
}
if($_GET['users']==1) {
$q=mquery("SELECT user,level from users_honors where honor=".(int)$_GET['honor']);
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0]."\r\n".(int)$r[1];
}
if($_GET['user']==1) {
$q=mquery("SELECT honor from users_honors WHERE `user`='".mysql_real_escape_string($_GET['searchname'])."'");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0];
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
if($_GET['delhonor']==1) {
if(getprivileges($_GET['name'])[1]==0) die("-3");
mquery("delete from users_honors where honor=".(int)$_GET['honor']);
mquery("delete from honors where id=".(int)$_GET['honor']);
echo "0";
}
if($_GET['award']==1) {
if(getprivileges($_GET['name'])[1]==0)
die("-3");
mquery("INSERT INTO `users_honors` (user,honor) VALUES ('".mysql_real_escape_string($_GET['user'])."',".(int)$_GET['honor'].")");
echo "0";
}
if($_GET['addhonor']==1) {
if(getprivileges($_GET['name'])[1]==0)
die("-3");
mquery("INSERT INTO `honors` (name,description,enname,endescription) VALUES ('".mysql_real_escape_string($_GET['honorname'])."','".mysql_real_escape_string($_GET['honordescription'])."','".mysql_real_escape_string($_GET['honorenname'])."','".mysql_real_escape_string($_GET['honorendescription'])."')");
echo "0";
}
if($_GET['sethonorlevels']==1) {
if(getprivileges($_GET['name'])[1]==0)
die("-3");
mquery("INSERT INTO `honors` (name,description,enname,endescription) VALUES ('".mysql_real_escape_string($_GET['honorname'])."','".mysql_real_escape_string($_GET['honordescription'])."','".mysql_real_escape_string($_GET['honorenname'])."','".mysql_real_escape_string($_GET['honorendescription'])."')");
echo "0";
}
if($_GET['setlevels']==1) {
$levels=buffer_get($_GET['buf_levels']);
$enlevels=buffer_get($_GET['buf_enlevels']);
if($levels!="" and !isJson($levels)) die("-1");
if($enlevels!="" and !isJson($enlevels)) die("-1");
mquery("update honors set levels='".mysql_real_escape_string($levels)."', enlevels='".mysql_real_escape_string($enlevels)."' where id=".(int)$_GET['honor']);
echo "0";
}

?>