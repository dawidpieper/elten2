<?php
require("init.php");
if($_GET['cat'] == 0) {
$q = mquery("SELECT `updatedate`, `expiredate`, `content` FROM `cache` WHERE id=0");
$tekst = "";
$r = mysql_fetch_row($q);
if($r[0] > $r[1] AND $_GET['details'] == 2)
$tekst = $r[2];
else {
$qr = "SELECT `name`, `groupid`, `fullname`, `type` FROM `forums`";
if($_GET['details']<2)
$qr .= " WHERE `type`=0";
$q = mquery($qr);
$tekst = "";
while($r = mysql_fetch_row($q)) {
$tekst .= "\r\n" . $r[0] . "\r\n";
if($_GET['details']>=1) {
$tekst .= $r[2] . "\r\n";
$tekst .= mysql_fetch_row(mquery("SELECT `name` FROM `forum_groups` WHERE `id`=".$r[1]))[0] . "\r\n";
}
$q2 = mquery("SELECT `id` FROM `forum_threads` WHERE `forum`='" . $r[0] . "'");
$tekst .= mysql_num_rows($q2);
$tekst .= "\r\n";
$q2 = mquery("select id from forum_posts where thread in (select id from forum_threads where forum='".$r[0]."')");
$tekst .= mysql_num_rows($q2);
if($_GET['details']==2)
$tekst.="\r\n".$r[3];
}
if($_GET['details']==2) {
mquery("UPDATE `cache` SET `updatedate`=".time().", `content`='".$tekst."' WHERE id=0");
}
}
echo "0" . $tekst;
}
if($_GET['cat'] == 1) {
$forumname = NULL;
$forumname = $_GET['forumname'];
$q = mquery("SELECT `updatedate`, `expiredate`, `content` FROM `cache` WHERE `forumname`='".$forumname."'");
$tekst = "";
$r = mysql_fetch_row($q);
if($r[0] > $r[1] AND $forumname!=NULL and $forumname[0]!="*" and $_GET['details']==1)
$tekst = $r[2];
else {
if($forumname != NULL and $forumname[0]!="*")
$qr = "SELECT `id` FROM `forum_threads` WHERE `forum`='" . $_GET['forumname'] . "' ORDER BY `lastpostdate` DESC";
elseif($forumname[0]=="*") {
$f=str_replace("\\","\\\\",$forumname);
$f=ltrim(str_replace("'","\\'",$f),"*");
$qr = "SELECT DISTINCT `thread` FROM `forum_posts` WHERE LOWER(`post`) LIKE LOWER('%".$f."%')";
}
else
$qr = "SELECT `id` FROM `forum_threads` WHERE `id` in (SELECT `thread` FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "') ORDER BY `lastpostdate` DESC";
$q = mysql_query($qr);
$tekst = "";
while($r = mysql_fetch_row($q)) {
$tekst .= "\r\n" . $r[0] . "\r\n";
if($forumname[0]=="*") {
$f=str_replace("\\","\\\\",$_GET['forumname']);
$f=ltrim(str_replace("'","\\'",$f),"*");
$q2 = mquery("SELECT `id`,`author` FROM `forum_posts` WHERE `thread`=" . $r[0]." AND `post` LIKE '%".$f."%'");
}
else
$q2 = mquery("SELECT `id`,`author` FROM `forum_posts` WHERE `thread`=" . $r[0]);
$tekst .= mysql_num_rows($q2);
if($_GET['details']==1)
$tekst .= "\r\n".mysql_fetch_row($q2)[1];
}
if($forumname!=NULL and $forumname[0]!="*" and $_GET['details']==1) {
mquery("UPDATE `cache` SET `updatedate`=".time().", `content`='".$tekst."' WHERE `forumname`='".$forumname."'");
}
}
echo "0" . $tekst;
}
if($_GET['cat'] == 2 and $_GET['name']!="guest") {
$zapytanie = "SELECT `forum`, `thread`, `posts` FROM `forum_read` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$posts = 0;
$tekst = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$tekst .= "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2];
}
echo "0" . $tekst;
}
if($_GET['cat'] == 3) {
$zapytanie = "SELECT `id` FROM `forum_posts` WHERE `author`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0\r\n".mysql_num_rows($idzapytania);
}
?>