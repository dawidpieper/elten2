<?php
require("init.php");
$wiersze=0;
$text="";
$ordertype="DESC";
if($_GET['reverse']==1)
$ordertype="ASC";
if($_GET['categoryid']=="NEW") {
$reads=array();
$posts=array();
$q=mquery("select post,posts from blog_read where owner='{$_GET['name']}' and author='{$_GET['name']}'");
while($r=mysql_fetch_row($q))
$reads[$r[0]]=$r[1];
$q=mquery("select postid,count(postid) as cnt from blog_posts where owner='{$_GET['name']}' group by postid");
while($r=mysql_fetch_row($q))
$posts[$r[0]]=$r[1];
$qr = "SELECT `postid`, `name` FROM blog_posts WHERE owner='".$_GET['name']."' and posttype=0 AND postid in (";
$counter=0;
foreach($posts as $post =>$count)
if($count>$reads[$post]) {
if($counter>0)
$qr.=",";
++$counter;
$qr.=$post;
}
if($counter==0)
$qr.="null";
$qr.=") ORDER BY `postid` ".$ordertype;
}
elseif($_GET['categoryid']>0)
$qr = "SELECT `postid`, `name` FROM `blog_posts` WHERE posttype=0 AND owner='".mysql_real_escape_string($_GET['searchname'])."' AND postid in (SELECT `postid` FROM `blog_assigning` WHERE `categoryid`=".(int)$_GET['categoryid']." AND `owner`='".mysql_real_escape_string($_GET['searchname'])."') ORDER BY `postid` ".$ordertype;
else
$qr = "SELECT `postid`, `name` FROM `blog_posts` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."' AND `posttype`=0 ORDER BY `postid` ".$ordertype;
$qi = mquery($qr);
$cposts[]=0;
$nposts[]=0;
if($_GET['categoryid']!="NEW") {
$q=mquery("SELECT `postid`, count(postid) as cnt FROM `blog_posts` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."' group by postid");
while($r=mysql_fetch_row($q))
$cposts[$r[0]]=$r[1];
$q=mquery("SELECT `post`,`posts` FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".mysql_real_escape_string($_GET['searchname'])."'");
while($r=mysql_fetch_row($q))
$nposts[$r[0]]=$r[1];
}
while($wiersz = mysql_fetch_row($qi)) {
$wiersze += 1;
$text .= $wiersz[0] . $addtmp . "\r\n" . $wiersz[1] . "\r\n";
if($_GET['assignnew']==1) {
if($_GET['categoryid']!="NEW") {
if($cposts[$wiersz[0]]>$nposts[$wiersz[0]]) {
$text.="1\r\n";
}
else
$text.="0\r\n";
}
else
$text.="0\r\n";
}
if($_GET['listcategories']==1) {
$cq=mquery("SELECT `categoryid` FROM `blog_assigning` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."' AND `postid`=".$wiersz[0]);
while($cr=mysql_fetch_row($cq))
$text.=$cr[0].",";
$text.="\r\n";
}
}
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>