<?php
require("header.php");
if($_GET['ac']=="list") {
$qt="select id,description,thread,post from forum_bookmarks where owner='".$_GET['name']."'";
if(isset($_GET['threadid'])) $qt.=" and thread=".(int)$_GET['threadid'];
$q=mquery($qt);
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3];
}
if($_GET['ac']=="delete") {
mquery("delete from forum_bookmarks where owner='".$_GET['name']."' and id=".(int)$_GET['bookmark']);
echo "0";
}
if($_GET['ac']=="create") {
mquery("insert into forum_bookmarks (owner, description, thread, post, time) values ('".$_GET['name']."', '".mysql_real_escape_string($_GET['description'])."', ".(int)$_GET['thread'].", ".(int)$_GET['post'].", unix_timestamp())");
echo "0";
}
?>