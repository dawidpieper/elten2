<?php
require("header.php");
if(isset($_GET['forum'])) {
$q=mquery("select thread, count(thread) from forum_posts where thread in (select id from forum_threads where forum='".$_GET['forum']."') group by thread");
mquery("delete from forum_read where owner='".$_GET['name']."' and thread in (select id from forum_threads where forum='".$_GET['forum']."')");
while($r=mysql_fetch_row($q)) {
mquery("INSERT INTO `forum_read` (owner, thread, posts) VALUES ('" . $_GET['name'] . "',".$r[0].",".$r[1].") ON DUPLICATE KEY UPDATE owner=VALUES(owner),thread=VALUES(thread),posts=VALUES(posts)");
}
echo "0";
}
?>