<?php
require("header.php");
$orderby = 0;
$orderby = $_GET['orderby'];
switch($orderby) {
case 0:
$zapytanie = "SELECT `owner`, `name` FROM `blogs` ORDER BY `lastupdate` DESC";
break;
case 1:
$zapytanie = "SELECT b.owner, b.name, (SELECT COUNT(*) AS cnt FROM blog_posts p WHERE p.owner = b.owner AND p.posttype = 0) AS order_col FROM blogs b ORDER BY order_col DESC";
break;
case 2:
$zapytanie = "SELECT b.owner, b.name, (SELECT COUNT(*) AS cnt FROM blog_posts p WHERE p.owner = b.owner AND p.posttype = 1) AS order_col FROM blogs b ORDER BY order_col DESC";
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