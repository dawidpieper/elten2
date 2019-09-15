<?php
require("header.php");
if($_GET['type']=='threads') {
$threads=array();
$q=mquery("select thread,owner from followedthreads where owner in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."')");
while($r=mysql_fetch_row($q)) {
if($threads[$r[0]]==null) $threads[$r[0]]=0;
if($r[1]!=$__GET['name']) $threads[$r[0]]+=15;
}
$q=mquery("select thread,author from forum_posts where author in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."') group by author,thread");
while($r=mysql_fetch_row($q)) {
if($threads[$r[0]]==null) $threads[$r[0]]=0;
if($r[1]!=$__GET['name']) $threads[$r[0]]+=10;
}
$q=mquery("select thread,owner from forum_read where owner in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."')");
while($r=mysql_fetch_row($q)) {
if($threads[$r[0]]==null) $threads[$r[0]]=0;
if($r[1]!=$__GET['name']) $threads[$r[0]]+=1;
}

$q=mquery("select id from forum_threads where lastpostdate>unix_timestamp()-(30*86400) and closed=0 and forum in (select name from forums where groupid in (select id from forum_groups where (open=1 and public=1) or id in (select groupid from forum_groups_members where (role=1 or role=2) and user='".mysql_real_escape_string($_GET['name'])."'))) and id not in (select thread from followedthreads where owner='".mysql_real_escape_string($_GET['name'])."')");
$res=array();
while($r=mysql_fetch_row($q))
$res[$r[0]]=$threads[$r[0]];
arsort($res);
echo "0";
$i=0;
foreach($res as $k=>$v) {
if($i>=200 or ($i>=5 and $v<$res[array_key_first($res)]/10)) break;
if($k!=0) {
echo "\r\n".$k;
++$i;
}
}
}

if($_GET['type']=='groups') {
$groups=array();
$q=mquery("select groupid,user from forum_groups_members where groupid not in (select groupid from forum_groups_members where user='".mysql_real_escape_string($_GET['name'])."') and (role=1 or role=2) and user in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."')");
while($r=mysql_fetch_row($q)) {
if($groups[$r[0]]==null) $groups[$r[0]]=0;
if($r[1]!=$_GET['name']) $groups[$r[0]]+=1;
}
$res=$groups;
arsort($res);
echo "0";
foreach($res as $k=>$v)
if($v>1) echo "\r\n".$k;
}
?>