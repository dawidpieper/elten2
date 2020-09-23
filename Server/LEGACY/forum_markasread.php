<?php
require("header.php");
if(isset($_GET['forum'])) {
$q=mquery("select thread, count(thread) from forum_posts where thread in (select id from forum_threads where forum='".mysql_real_escape_string($_GET['forum'])."') group by thread");
while($r=mysql_fetch_row($q)) {
mquery("INSERT INTO `forum_read` (owner, thread, posts) VALUES ('" . $_GET['name'] . "',".$r[0].",".$r[1].") ON DUPLICATE KEY UPDATE owner=VALUES(owner),thread=VALUES(thread),posts=VALUES(posts)");
}
echo "0";
}
if(isset($_GET['groupid'])) {
$q=mquery("select thread, count(thread) from forum_posts where thread in (select id from forum_threads where forum in (select name from forums where groupid=".(int)$_GET['groupid'].")) group by thread");
while($r=mysql_fetch_row($q)) {
mquery("INSERT INTO `forum_read` (owner, thread, posts) VALUES ('" . $_GET['name'] . "',".$r[0].",".$r[1].") ON DUPLICATE KEY UPDATE owner=VALUES(owner),thread=VALUES(thread),posts=VALUES(posts)");
}
echo "0";
}
?>