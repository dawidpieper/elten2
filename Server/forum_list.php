<?php
$groups=array();
$forums=array();
$threads=array();
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
if(file_exists("cache/forumlist.dat")==false or $_GET['newcache']==1) {
$qgroups=mquery("select id, name from forum_groups");
$qforums=mquery("select name,fullname,groupid,type from forums");
$qthreads=mquery("select id,name,forum,lastpostdate from forum_threads order by lastpostdate desc");
$qposts=mquery("select thread,author from forum_posts order by id asc");
while($r=mysql_fetch_row($qgroups))
$groups[$r[0]]=[$r[0],$r[1],0,0,0,0];
while($r=mysql_fetch_row($qforums)) {
$forums[$r[0]]=[$r[0],$r[1],$r[2],$r[3],0,0,0,0];
++$groups[$r[2]][2];
}
while($r=mysql_fetch_row($qthreads)) {
$threads[$r[0]]=[$r[0],$r[1],$r[2],0,"",0,0,$r[3]];
++$forums[$r[2]][4];
++$groups[$forums[$r[2]][2]][3];
}
while($r=mysql_fetch_row($qposts)) {
++$threads[$r[0]][3];
++$forums[$threads[$r[0]][2]][5];
++$groups[$forums[$threads[$r[0]][2]][2]][4];
if($threads[$r[0]][4]=="")
$threads[$r[0]][4]=$r[1];
}
$list['groups']=$groups;
$list['forums']=$forums;
$list['threads']=$threads;
$fp=fopen("cache/forumlist.dat","w");
fwrite($fp,serialize($list));
fclose($fp);
}
else {
$fp=fopen("cache/forumlist.dat","r");
$list=unserialize(fread($fp,filesize("cache/forumlist.dat")));
$groups=$list['groups'];
$forums=$list['forums'];
$threads=$list['threads'];
fclose($fp);
}
if($_GET['name']!="guest") {
$qreads=mquery("select thread,posts from forum_read where owner='{$_GET['name']}'");
while($r=mysql_fetch_row($qreads)) {
$threads[$r[0]][5]=$r[1];
$forums[$threads[$r[0]][2]][6]+=$r[1];
$groups[$forums[$threads[$r[0]][2]][2]][5]+=$r[1];
}
$qfollowed=mquery("select thread from followedthreads where owner='{$_GET['name']}'");
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