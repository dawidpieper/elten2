<?php
require("header.php");
if(mysql_num_rows(mquery("select id from forum_posts where id=".(int)$_GET['postid']))==0) die("-4");
if($_GET['ac']=="liking") {
if($_GET['like']==1) {
if(mysql_num_rows(mquery("select id from forum_posts_likes where user='".$_GET['name']."' and post=".(int)$_GET['postid']))>0) die("-5");
mquery("insert into forum_posts_likes (user, post) values ('".$_GET['name']."', ".(int)$_GET['postid'].")");
echo "lala";
}
else
mquery("delete from forum_posts_likes where user='".$_GET['name']."' and post=".(int)$_GET['postid']);
echo "0";
}
if($_GET['ac']=='likes') {
$q=mquery("select user from forum_posts_likes where post='".(int)$_GET['postid']."'");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0];
}
if($_GET['ac']=="getorig") {
$r=mysql_fetch_row(mquery("select id, public from forum_groups where id in (select groupid from forums where name in (select forum from forum_threads where id=".(int)$_GET['threadid']."))"));
$groupid=$r[0];
if($r[1]==0 and ($_GET['name']=="guest"||(mysql_num_rows(mquery("select user from forum_groups_members where user='".$_GET['name']."' and groupid=".$groupid))==0))) die("-3");
$q=mquery("select origpost from forum_posts where thread=".(int)$_GET['threadid']." and id=".(int)$_GET['postid']);
echo "0\r\n".mysql_fetch_row($q)[0];
}
?>