<?php
require("init.php");
$orderby = 0;
$orderby = $_GET['orderby'];
switch($orderby) {
case 0:
$zapytanie = "SELECT `owner`, `name` FROM `blogs` where owner in (select owner from blog_posts) ORDER BY `lastupdate` DESC";
break;
case 1:
$zapytanie = "SELECT b.owner, b.name, (SELECT COUNT(*) AS cnt FROM blog_posts p WHERE p.owner = b.owner AND p.posttype = 0 and p.date>(unix_timestamp()-86400*30)) AS order_col FROM blogs b where lastupdate>(unix_timestamp()-86400*3) ORDER BY order_col DESC";
break;
case 2:
$zapytanie = "SELECT b.owner, b.name, (select (select count(*) from blog_posts c where c.owner=b.owner and c.posttype=1 and c.date>unix_timestamp()-30*86400) / (select count(*) from blog_posts p where p.owner=b.owner and p.posttype=0 and p.date>unix_timestamp()-30*86400) as cnt) AS order_col FROM blogs b where b.owner in (SELECT owner FROM blog_posts where posttype=0 GROUP BY owner HAVING count(owner) > 10) ORDER BY order_col DESC";
break;
case 3:
$zapytanie = "SELECT `owner`, `name` FROM `blogs` WHERE `owner` IN (SELECT `author` FROM `followedblogs` WHERE `owner`='".$_GET['name']."') ORDER BY `lastupdate` DESC";
break;
}
$idzapytania = mysql_query($zapytanie);
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