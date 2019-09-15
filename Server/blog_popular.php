<?php
require("header.php");
if($_GET['type']=='blogs') {
$followers=array();
$blogs=array();
$blogposts=array();
$q=mquery("select owner, count(owner) from blog_posts where posttype=0 group by owner");
while($r=mysql_fetch_row($q))
$blogposts[$r[0]]=$r[1];
$q=mquery("select author,owner from followedblogs where owner in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."')");
while($r=mysql_fetch_row($q)) {
if($blogs[$r[0]]==null) $blogs[$r[0]]=0;
if($r[1]!=$_GET['name']) $blogs[$r[0]]+=50;
array_push($followers,$r[1]);
}
$q=mquery("select owner,author,postid from blog_posts where author!=owner and posttype=1 and author in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."') group by owner,author,postid");
while($r=mysql_fetch_row($q)) {
if($blogs[$r[0]]==null) $blogs[$r[0]]=0;
if($r[1]!=$_GET['name']) $blogs[$r[0]]+=100.0/($blogposts[$r[0]]);
}
$q=mquery("select author,owner from blog_read where owner in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."') group by author,owner");
while($r=mysql_fetch_row($q)) {
if($blogs[$r[0]]==null) $blogs[$r[0]]=0;
if(!in_array($r[1],$followers) and $r[1]!=$_GET['name']) $blogs[$r[0]]+=10;
}
$res=$blogs;
arsort($res);
echo "0";
$i=0;
foreach($res as $k=>$v) {
if($i>=200 or ($i>=5 and $v<$res[array_key_first($res)]/10)) break;
echo "\r\n".$k;
++$i;
}

}
?>