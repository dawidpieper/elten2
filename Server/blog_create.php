<?php
require("header.php");
$zapytanie = "INSERT INTO `blogs` (owner, name) VALUES ('" . $_GET['name'] . "','" . $_GET['blogname'] . "')";
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