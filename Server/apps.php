<?php
require("header.php");
if($_GET['list'] == 1) {
$zapytanie = "Select `name`, `version`, `description`, `file` FROM `apps`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$ile = 0;
$text = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$ile = $ile + 1;
$text .= $wiersz[3] . "\r\n" . $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2] . "\r\nEND\r\n";
}
$zapytanie = "Select `name`, `version`, `description`, `file` FROM `apps_paid_" . $_GET['name'] . "`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania != false) {
while ($wiersz = mysql_fetch_row($idzapytania)){
$ile = $ile + 1;
$text .= $wiersz[3] . "\r\n" . $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2] . "\r\n潤\r\n";
}
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>