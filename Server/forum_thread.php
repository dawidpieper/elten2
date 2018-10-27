<?php
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
if(file_exists("cache/forumthread".$_GET['thread'].".dat")==false or $_GET['newcache']==1) {
$qposts=mquery("select id, author, post, date from forum_posts where thread=". (int) $_GET['thread']."");
$qsignatures=mquery("select name, signature from signatures");
while($r=mysql_fetch_row($qsignatures))
$signatures[$r[0]]=$r[1];
while($r=mysql_fetch_row($qposts))
$posts[$r[0]]=[$r[0],$r[1],$r[2],$r[3],$signatures[$r[1]]];
$fp=fopen("cache/forumthread".$_GET['thread'].".dat","w");
fwrite($fp,serialize($posts));
fclose($fp);
}
else {
$fp=fopen("cache/forumthread".$_GET['thread'].".dat","r");
$posts=unserialize(fread($fp,filesize("cache/forumthread".$_GET['thread'].".dat")));
fclose($fp);
}
$readposts=count($posts);
if($_GET['name']!="guest") {
$readposts= (int) mysql_fetch_row(mquery("select posts from forum_read where thread=".(int) $_GET['thread']." and owner='".$_GET['name']."'"))[0];
if($readposts!=count($posts))
if($readposts==0)
mquery("insert into forum_read (id,owner,thread,posts) values ('','".$_GET['name']."',".((int) $_GET['thread']).",".count($posts).")");
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
echo $col[0]."\r\n".$col[1]."\r\n".$col[2]."\r\n\004END\004\r\n".$col[3]."\r\n".$col[4]."\r\n\004END\004\r\n";
?>