<?php
require("init.php");
$q = mquery("SELECT `categoryid` FROM `blog_assigning` WHERE `postid`=".(int)$_GET['postid']." AND `owner`='".mysql_real_escape_string($_GET['searchname'])."'");
$wiersze=0;
$tekst="";
while($wiersz = mysql_fetch_row($q)) {
$wiersze = $wiersze + 1;
$tekst .= "\r\n".$wiersz[0];
}
$q = mquery("SELECT `name` FROM `blog_posts` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."' AND `postid`=".(int)$_GET['postid']);
if($q == false) {
echo "-1";
die;
}
echo "0\r\n".mysql_fetch_row($q)[0]."\r\n".$wiersze.$tekst;
?>