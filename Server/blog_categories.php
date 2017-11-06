<?php
require("init.php");
$zapytanie = "SELECT `id`, `name` FROM `blog_categories` WHERE `owner`='" . $_GET['searchname'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$wiersze = 0;
$text = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$wiersze += 1;
$text .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n";
}
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>