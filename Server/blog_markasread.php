<?php
require("header.php");
$q=mquery("select postid from blog_posts where owner='".$_GET['user']."' and postid not in (select post from blog_read where author='".$_GET['user']."' and owner='".$_GET['name']."')");
while($r=mysql_fetch_row($q)) {
mquery("insert into blog_read (id,owner,author,post,posts) values ('','".$_GET['name']."','".$_GET['user']."',".$r[0].",0)");
}
echo "0";
?>