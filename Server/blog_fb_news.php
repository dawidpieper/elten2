<?php
require("header.php");
$ile=0;
$tekst="";
$q=mquery("SELECT `owner`,`postid`,`name` FROM `blog_posts` bp where `posttype`=0 and NOT EXISTS (SELECT 1 FROM `blog_read` br WHERE `owner`='".$_GET['name']."' and bp.postid = br.post and br.author=bp.owner) and owner in (select `author` from `followedblogs` where owner='".$_GET['name']."') ORDER BY `id` DESC");
while($r=mysql_fetch_row($q)) {
++$ile;
$tekst.="\r\n".$r[0]."\r\n0\r\n".$r[1]."\r\n".$r[2];
}
echo "0\r\n" . $ile . $tekst;
?>