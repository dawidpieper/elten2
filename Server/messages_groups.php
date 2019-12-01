<?php
require("header.php");
if($_GET['ac']=='create') {
$id="[".random_str(62)."]";
mquery("insert into messages_groups (id, name, founder, created) values ('".$id."', '".mysql_real_escape_string($_GET['groupname'])."', '".$_GET['name']."', ".time().")");
$users=array($_GET['name'])+explode(",",$_GET['users']);
foreach(array_unique($users) as $user)
mquery("insert into messages_groups_members (groupid, user) values ('".$id."','".mysql_real_escape_string($user)."')");
message_send('elten',$id,"Group notifications","Group {$_GET['groupname']} has been created by {$_GET['name']}.");
echo "0";
}
if($_GET['ac']=='name') {
$q=mquery("select id,name from messages_groups where id in (select groupid from messages_groups_members where user='".mysql_real_escape_string($_GET['name'])."')");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q)) {
echo "\r\n".$r[0]."\r\n".$r[1];
}
}
if($_GET['ac']=='leave') {
mquery("delete from messages_groups_members where groupid='".mysql_real_escape_string($_GET['groupid'])."' and user='".mysql_real_escape_string($_GET['name'])."'");
echo "0";
}
?>