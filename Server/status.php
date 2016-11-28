<?php
require("header.php");
$zapytanie = "SELECT `name`, `status` FROM `statuses`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$status = $wiersz[1];
}
}
if($suc == false) {
echo "0\r\n     ";
die;
}
echo "0\r\n" . $status;
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>