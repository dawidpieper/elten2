<?php
require("header.php");
$date = date("d.m.Y H:i");
$zapytanie = "SELECT `id`, `sender`, `receiver`, `subject`, `message`, `date` FROM `messages` where `receiver`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
if($_GET['delete'] == 1) {
$zapytanie = "UPDATE `messages` SET `deletedfromreceived`=1 WHERE id=" . $_GET['id']." and receiver='".$_GET['name']."'";
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