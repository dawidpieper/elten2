<?php
require("header.php");
$moderator=getprivileges($_GET['name'])[1];
$dmoderator=getprivileges($_GET['searchname'])[1];
if($moderator==0 or $dmoderator==1)
die("-3");
if($_GET['ban'] == 1) {
mquery("DELETE FROM `banned` WHERE name='" . $searchname . "'");
mquery("update forum_groups_members set role=1 where role=2 and user='".mysql_real_escape_string($searchname)."' and groupid in (select id from forum_groups where recommended=1)");
$q=mquery("select id from forum_groups where recommended=1 and founder='".mysql_real_escape_string($searchname)."'");
while($r=mysql_fetch_row($q)) {
$q2=mquery("select user from forum_groups_members where role=2 and groupid=".$r[0]);
if(mysql_num_rows($q2)>0) {
$n=mysql_fetch_row($q2)[0];
mquery("update forum_groups set founder='".mysql_real_escape_string($n)."' where id=".$r[0]);
}
}
$reason=$_GET['reason'];
$info=buffer_get($_GET['info']);
mquery("INSERT INTO `banned` (name, totime, reason) VALUES ('" . mysql_real_escape_string($_GET['searchname']) . "'," . (int)$_GET['totime'] . ",'".mysql_real_escape_string($reason)."') on duplicate key update totime=values(totime), reason=values(reason)");
message_send("elten", $_GET['searchname'], "You have been banned", "You have been banned.\r\nReason: ".$reason."\r\nBanned until: ".date("Y-m-d H:i:s",$_GET['totime'])."\r\n\r\n".$info);
$q=mquery("SELECT name from privileges where administrator=1");
while($r=mysql_fetch_row($q))
message_send("elten", $r[0], "User ".$_GET['searchname']." has been banned by ".$_GET['name'], "User ".$_GET['searchname']." has been banned by ".$_GET['name'].".\r\nReason: ".$reason."\r\nBanned until: ".date("Y-m-d H:i:s",$_GET['totime'])."\r\nRegards,\r\nElten Support");
echo "0";
}
if($_GET['unban'] == 1) {
$q = mquery("SELECT `name` FROM `banned`");
$suc = false;
while ($r = mysql_fetch_row($q)){
if($r[0] == $_GET['searchname']) {
$suc = true;
$searchname = $r[0];
}
}
if($suc == true) {
$reason=$_GET['reason'];
mquery("DELETE FROM `banned` WHERE name='" . mysql_real_escape_string($searchname) . "'");
message_send("elten", $_GET['searchname'], "You have been unbanned", "Your ban has been cancelled.\r\nReason: ".$reason."\r\n\r\nRegards,\r\nElten Support");
$q=mquery("SELECT name from privileges where administrator=1");
while($r=mysql_fetch_row($q))
message_send("elten", $r[0], "User ".$_GET['searchname']." has been unbanned by ".$_GET['name'], "The ban of user ".$_GET['searchname']." has been cancelled by ".$_GET['name'].".\r\nReason: ".$reason."\r\nRegards,\r\nElten Support");
echo "0";
}
else
die("-4");
}
?>