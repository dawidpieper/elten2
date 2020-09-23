<?php
if($_GET['ac']=='stats')
require("init.php");
else
require("header.php");
if(mysql_num_rows(mquery("select id from forum_threads where id=".(int)$_GET['threadid']))==0) die("-4");
if($_GET['ac']=="stats") {
$followers=mysql_fetch_row(mquery("select count(*) from followedthreads where thread=".(int)$_GET['threadid']))[0];
$mentions=mysql_fetch_row(mquery("select count(*) from mentions where thread=".(int)$_GET['threadid']))[0];
$authors=mysql_fetch_row(mquery("select count(distinct author) from forum_posts where thread=".(int)$_GET['threadid']))[0];
$readers=mysql_fetch_row(mquery("select count(*) from forum_read where thread=".(int)$_GET['threadid']))[0];
$posts=mysql_fetch_row(mquery("select count(*) from forum_posts where thread=".(int)$_GET['threadid']))[0];
$m50readers=mysql_fetch_row(mquery("select count(*) from forum_read where posts<".round($posts*0.5)." and thread=".(int)$_GET['threadid']))[0];
$p90readers=mysql_fetch_row(mquery("select count(*) from forum_read where posts>=".round($posts*0.9)." and thread=".(int)$_GET['threadid']))[0];
$p100readers=mysql_fetch_row(mquery("select count(*) from forum_read where posts=".$posts." and thread=".(int)$_GET['threadid']))[0];
echo "0\r\n{$followers}\r\n{$mentions}\r\n{$authors}\r\n{$readers}\r\n{$m50readers}\r\n{$p90readers}\r\n{$p100readers}";
}
if($_GET['ac']=="marking") {
if($_GET['mark']==1) {
if(mysql_num_rows(mquery("select id from forum_threads_marked where user='".$_GET['name']."' and thread=".(int)$_GET['threadid']))>0) die("-5");
mquery("insert into forum_threads_marked (user, thread) values ('".$_GET['name']."', ".(int)$_GET['threadid'].")");
}
else
mquery("delete from forum_threads_marked where user='".$_GET['name']."' and thread=".(int)$_GET['threadid']);
echo "0";
}
?>