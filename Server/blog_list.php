<?php
if($_GET['orderby']>2)
require("header.php");
else
require("init.php");
$orderby = 0;
$orderby = $_GET['orderby'];
switch($orderby) {
case 0:
$qt = "SELECT `owner`, `name` FROM `blogs` where owner in (select owner from blog_posts) ORDER BY `lastupdate` DESC";
break;
case 1:
$qt = "SELECT b.owner, b.name, (SELECT COUNT(*) AS cnt FROM blog_posts p WHERE p.owner = b.owner AND p.posttype = 0 and p.date>(unix_timestamp()-86400*30)) AS order_col FROM blogs b where lastupdate>(unix_timestamp()-86400*3) ORDER BY order_col DESC";
break;
case 2:
$qt = "SELECT b.owner, b.name, (select (select count(*) from blog_posts c where c.owner=b.owner and c.posttype=1 and c.date>unix_timestamp()-30*86400) / (select count(*) from blog_posts p where p.owner=b.owner and p.posttype=0 and p.date>unix_timestamp()-30*86400) as cnt) AS order_col FROM blogs b where b.owner in (SELECT owner FROM blog_posts where posttype=0 GROUP BY owner HAVING count(owner) > 10) ORDER BY order_col DESC";
break;
case 3:
$qt = "SELECT `owner`, `name` FROM `blogs` WHERE `owner` IN (SELECT `author` FROM `followedblogs` WHERE `owner`='".$_GET['name']."') ORDER BY `lastupdate` DESC";
break;
case 4:
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
$q=mquery("select author,owner from blog_read where owner in (select user from contacts where owner='".mysql_real_escape_string($_GET['name'])."')");
while($r=mysql_fetch_row($q)) {
if($blogs[$r[0]]==null) $blogs[$r[0]]=0;
if(!in_array($r[1],$followers) and $r[1]!=$_GET['name']) $blogs[$r[0]]+=30.0/($blogposts[$r[0]]);
}
$res=$blogs;
arsort($res);
$qt="select owner,name from blogs where owner in ('".implode("','",array_keys($res))."') order by field(owner,'".implode("','",array_keys($res))."')";
break;
}
$idzapytania = mysql_query($qt);
if($idzapytania == false) {
echo "-1";
die;
}
$text = "";
$wiersze = 0;
while ($wiersz = mysql_fetch_row($idzapytania)){
$wiersze = $wiersze + 1;
$text .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n";
}
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>