<?php
require("header.php");
$error = 0;
$zapytanie = "SELECT `name`, `date` FROM `actived` ORDER BY `name`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
while ($wiersz = mysql_fetch_row($idzapytania)){
$name = $wiersz[0];
$date = $wiersz[1];
if($date + 90 >= $cdate) {
echo "\r\n" . $name;
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>