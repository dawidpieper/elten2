<?php
require("header.php");
$zapytanie = "SELECT `owner`, `name` FROM `blogs` ORDER BY `lastupdate` DESC";
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
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>