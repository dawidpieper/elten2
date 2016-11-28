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
if($wiersz[0] == $_GET['name']) {
$suc = true;
$status = $wiersz[1];
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `statuses` WHERE `name`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
$zapytanie = "INSERT INTO `statuses` (`name`,`status`) VALUES ('" . $_GET['name'] . "','" . $_GET['text'] . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
if($suc == true)
echo "\r\n*";
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>