<?php
require("header.php");
$zapytanie = "SELECT `name`, `password` FROM `users`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytaniedie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name'])
if($wiersz[1] == $_GET['oldpassword'])
$suc = true;
else
$error = -2;
}
if($suc == false) {
echo "-6";
die;
}
if($_GET['changepassword'] == 1) {
$zapytanie = "UPDATE `users` SET `password`='" . $_GET['password'] . "' WHERE name='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
}
if($_GET['changemail'] == 1) {
$zapytanie = "UPDATE `users` SET `mail`='" . $_GET['mail'] . "' WHERE name='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>