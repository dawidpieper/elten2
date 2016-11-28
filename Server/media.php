<?php
require("header.php");
if($_GET['get'] == NULL) {
$zapytanie = "SELECT `id`, `name`, `description` FROM `media_categories`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$txt = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
$txt .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2] . "\r\nEND\r\n";
}
echo "0\r\n".$txt;
}
if($_GET['get'] != NULL) {
$zapytanie = "SELECT `id`, `object` FROM `media`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$txt = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
$wzapytanie = "SELECT `id`, `url`, `name`, `description` FROM `media_".$_GET['get']."`";
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1";
die;
}
while($rwiersz = mysql_fetch_row($widzapytania)) {
if($wiersz[1] == $rwiersz[0])
$txt .= $rwiersz[0] . "\r\n" . $rwiersz[1] . "\r\n" . $rwiersz[2] . "\r\n" . $rwiersz[3] . "\r\nEND\r\n";
}
}
echo "0\r\n".$txt;
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>