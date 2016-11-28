<?php
require("header.php");
$zapytanie = "DELETE FROM `tokens` WHERE `token`='".$_GET['token']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>