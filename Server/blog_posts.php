<?php
require("init.php");
$wiersze=0;
$text="";
$ordertype="DESC";
if($_GET['reverse']==1)
$ordertype="ASC";
if($_GET['categoryid']=="NEW")
$zapytanie = "SELECT `post` FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".$_GET['name']."' AND `posts`<(SELECT COUNT(*) FROM `blog_posts` WHERE blog_posts.owner=blog_read.author AND blog_posts.postid=blog_read.post) ORDER BY `post` ".$ordertype;
elseif($_GET['categoryid']>0)
$zapytanie = "SELECT `postid` FROM `blog_assigning` WHERE `categoryid`=".$_GET['categoryid']." AND `owner`='".$_GET['searchname']."' ORDER BY `postid` ".$ordertype;
else
$zapytanie = "SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['searchname']."' AND `posttype`=0 ORDER BY `postid` ".$ordertype;
$idzapytania = mquery($zapytanie);
$cposts[]=0;
$nposts[]=0;
if($_GET['categoryid']!="NEW") {
$q=mquery("SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['searchname']."'");
while($r=mysql_fetch_row($q)) {
if($cposts[$r[0]] == NULL)
$cposts[$r[0]]=0;
++$cposts[$r[0]];
}
$q=mquery("SELECT `post`,`posts` FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".$_GET['searchname']."'");
while($r=mysql_fetch_row($q)) {
$nposts[$r[0]]=$r[1];
}
}
while($wiersz = mysql_fetch_row($idzapytania)) {
$widzapytania = mquery("SELECT `postid`, `name` FROM `blog_posts` WHERE `owner`='" . $_GET['searchname'] . "' AND `postid`=" . $wiersz[0]);
$wwiersz = mysql_fetch_row($widzapytania);
$wiersze += 1;
$text .= $wwiersz[0] . $addtmp . "\r\n" . $wwiersz[1] . "\r\n";
if($_GET['assignnew']==1) {
if($_GET['categoryid']!="NEW") {
if($cposts[$wwiersz[0]]>$nposts[$wwiersz[0]]) {
$text.="1\r\n";
}
else
$text.="0\r\n";
}
else
$text.="0\r\n";
}
if($_GET['listcategories']==1) {
$cq=mquery("SELECT `categoryid` FROM `blog_assigning` WHERE `owner`='".$_GET['searchname']."' AND `postid`=".$wwiersz[0]);
while($cr=mysql_fetch_row($cq))
$text.=$cr[0].",";
$text.="\r\n";
}
}
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>