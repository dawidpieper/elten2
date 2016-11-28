<?php
require("header.php");
$error = 0;
$zapytanie = "SELECT `name`, `totime` FROM `banned`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
while ($wiersz = mysql_fetch_row($idzapytania)){
$name = $wiersz[0];
$date = $wiersz[1];
if($date > $cdate and $name == $_GET['searchname']) {
$isbanned = true;
}
}
if($isbanned == true)
echo "0\r\n1";
else
echo "0\r\n0";
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>