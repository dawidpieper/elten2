<?php
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
$r=mysql_fetch_row(mquery("select id, public from forum_groups where id in (select groupid from forums where name in (select forum from forum_threads where id=".(int)$_GET['thread']."))"));
$groupid=$r[0];
if($r[1]==0 and ($_GET['name']=="guest"||(mysql_num_rows(mquery("select user from forum_groups_members where user='".$_GET['name']."' and groupid=".$groupid))==0))) die("-3");
$qposts=mquery("select id, author, post, date, polls, attachments from forum_posts where thread=". (int) $_GET['thread']."");
$qsignatures=mquery("select name, signature from signatures");
while($r=mysql_fetch_row($qsignatures))
$signatures[$r[0]]=$r[1];
if(mysql_num_rows(mquery("select * from notes where note like '%dawajmikoty%' and author='{$_GET['name']}'"))>0)
foreach($signatures as $o=>$s)
$signatures[$o]='koty zawsze dwa';
while($r=mysql_fetch_row($qposts))
if(!isset($_GET['atts']) or $_GET['atts']==0)
$posts[$r[0]]=[$r[0],$r[1],$r[2],$r[3],$signatures[$r[1]]];
else
$posts[$r[0]]=[$r[0],$r[1],$r[2],$r[3],$r[4],$r[5], $signatures[$r[1]]];
$readposts=count($posts);
if($_GET['name']!="guest") {
$readposts= (int) mysql_fetch_row(mquery("select posts from forum_read where thread=".(int) $_GET['thread']." and owner='".$_GET['name']."'"))[0];
if($readposts!=count($posts))
if($readposts==0)
mquery("insert into forum_read (owner,thread,posts) values ('".$_GET['name']."',".((int) $_GET['thread']).",".count($posts).")");
else
mquery("update forum_read set posts=".count($posts)." where owner='".$_GET['name']."' and thread=".((int) $_GET['thread']));
}
echo "0\r\n".time()."\r\n".count($posts)."\r\n".$readposts."\r\n";
if($_GET['name']=="guest")
echo "0\r\n";
else {
$q=mquery("select thread from followedthreads where owner='".$_GET['name']."' and thread=".(int) $_GET['thread']);
if(mysql_num_rows($q)==0)
echo "0\r\n";
else
echo "1\r\n";
}
foreach($posts as $col)
if(!isset($_GET['atts']) or $_GET['atts']==0)
echo $col[0]."\r\n".$col[1]."\r\n".$col[2]."\r\n\004END\004\r\n".$col[3]."\r\n".$col[4]."\r\n\004END\004\r\n";
else
echo $col[0]."\r\n".$col[1]."\r\n".$col[2]."\r\n\004END\004\r\n".$col[3]."\r\n".$col[4]."\r\n".$col[5]."\r\n".$col[6]."\r\n\004END\004\r\n";
?>