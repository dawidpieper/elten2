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
if($_GET['ac']=='listusers') {
$q = mquery("select user from messages_groups_members where groupid='".mysql_real_escape_string($_GET['groupid'])."'");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0];
}
if($_GET['ac']=='edit') {
if(mysql_num_rows(mquery("select id from messages_groups_members where user='".mysql_real_escape_string($_GET['name'])."' and groupid='".mysql_real_escape_string($_GET['groupid'])."'"))==0) die("-3");
mquery("update messages_groups set name='".mysql_real_escape_string($_GET['groupname'])."' where id='".mysql_real_escape_string($_GET['groupid'])."'");
$users=explode(",",$_GET['addusers']);
foreach(array_unique($users) as $user) {
if($user=="") continue;
mquery("insert into messages_groups_members (groupid, user) values ('".mysql_real_escape_string($_GET['groupid'])."','".mysql_real_escape_string($user)."')");
}
message_send('elten',$_GET['groupid'],"Group notifications","Group {$_GET['groupname']} has been modified by {$_GET['name']}.");
echo "0";
}
if($_GET['ac']=="mute") {
mquery("insert into messages_muted (owner, user, totime) values ('".mysql_real_escape_string($_GET['name'])."', '".mysql_real_escape_string($_GET['groupid'])."', ".(int)$_GET['totime'].") on duplicate key update totime=values(totime)");
echo "0";
}
if($_GET['ac']=="unmute") {
mquery("delete from messages_muted where owner='".mysql_real_escape_string($_GET['name'])."' and user='".mysql_real_escape_string($_GET['groupid'])."'");
echo "0";
}
?>