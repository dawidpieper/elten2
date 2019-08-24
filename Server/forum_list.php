<?php
$groups=array();
$forums=array();
$threads=array();
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
$qgroups=mquery("select id, name from forum_groups where id<100 and recommended=1");
$groupids = array(0);
while($r=mysql_fetch_row($qgroups)) {
$groups[$r[0]]=[$r[0],$r[1],0,0,0,0];
array_push($groupids,$r[0]);
}
$groups[5]=[5,'Tymczasowo',0,0,0,0];
$qtforums="select name,fullname,if(groupid>100,5,groupid),type from forums where groupid in (".implode(",",$groupids).") or groupid in (select id from forum_groups where open=1 and recommended=1)";
$qforums=mquery($qtforums);
$forumnames=array('');
while($r=mysql_fetch_row($qforums)) {
$forums[$r[0]]=[$r[0],$r[1],$r[2],$r[3],0,0,0,0];
array_push($forumnames,$r[0]);
if(isset($groups[$r[2]])) ++$groups[$r[2]][2];
}
$qtthreads="select id,name,forum,lastpostdate from forum_threads where forum in ('".implode("','",$forumnames)."')";
$qtthreads.=" order by pinned desc, lastpostdate desc";
$qthreads=mquery($qtthreads);
$threadids=array(0);
while($r=mysql_fetch_row($qthreads)) {
$threads[$r[0]]=[$r[0],$r[1],$r[2],0,"",0,0,$r[3]];
array_push($threadids,$r[0]);
if(isset($forums[$r[2]]))++$forums[$r[2]][4];
if(isset($groups[$forums[$r[2]][2]])) ++$groups[$forums[$r[2]][2]][3];
}
$qposts=mquery("select thread,author from forum_posts where thread in (".implode(",",$threadids).") order by id asc");
while($r=mysql_fetch_row($qposts)) {
if(isset($threads[$r[0]])) ++$threads[$r[0]][3];
if(isset($forums[$threads[$r[0]][2]])) ++$forums[$threads[$r[0]][2]][5];
if(isset($groups[$forums[$threads[$r[0]][2]][2]])) ++$groups[$forums[$threads[$r[0]][2]][2]][4];
if($threads[$r[0]][4]=="")
$threads[$r[0]][4]=$r[1];
}
if($_GET['name']!="guest") {
$qreads=mquery("select thread,posts from forum_read where thread in (".implode(",",$threadids).") and owner='{$_GET['name']}'");
while($r=mysql_fetch_row($qreads)) {
if(isset($threads[$r[0]])) $threads[$r[0]][5]=$r[1];
if(isset($forums[$threads[$r[0]][2]])) $forums[$threads[$r[0]][2]][6]+=$r[1];
if(isset($groups[$forums[$threads[$r[0]][2]][2]])) $groups[$forums[$threads[$r[0]][2]][2]][5]+=$r[1];
}
$qfollowed=mquery("select thread from followedthreads where owner='{$_GET['name']}' and thread in (".implode(",",$threadids).")");
while($r=mysql_fetch_row($qfollowed))
$threads[$r[0]][6]=1;
}
$qfollowedforums=mquery("select forum from followedforums where owner='{$_GET['name']}'");
while($r=mysql_fetch_row($qfollowedforums))
$forums[$r[0]][7]=1;
echo "0\r\n".time()."\r\n\004GROUPS\004\r\n";
foreach($groups as $val)
foreach($val as $cnt)
echo $cnt."\r\n";
flush;
echo "\004FORUMS\004\r\n";
foreach($forums as $val)
foreach($val as $cnt)
echo $cnt."\r\n";
flush;
echo "\004THREADS\004\r\n";
foreach($threads as $val)
foreach($val as $cnt)
echo $cnt."\r\n";
?>