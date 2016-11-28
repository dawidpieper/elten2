<?php
require("header.php");
$zapytanie = "SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name']) {
$suc = true;
$name = $wiersz[0];
$tester = $wiersz[1];
$moderator = $wiersz[2];
$media_administrator = $wiersz[3];
$translator = $wiersz[4];
$developer = $wiersz[5];
}
}
if($suc == false) {
$moderator = 0;
$tester = 0;
$developer = 0;
$translator = 0;
$media_administrator = 0;
}
$zapytanie = "SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$dname = $wiersz[0];
$dtester = $wiersz[1];
$dmoderator = $wiersz[2];
$dmedia_administrator = $wiersz[3];
$dtranslator = $wiersz[4];
$ddeveloper = $wiersz[5];
}
}
if($suc == false) {
$dmoderator = 0;
$dtester = 0;
$ddeveloper = 0;
$dtranslator = 0;
$dmedia_administrator = 0;
}
if($moderator <= 0) {
echo "-3";
die;
}
if($_GET['ban'] == 1) {
if($dmoderator <= 0 and $ddeveloper <= 0) {
$zapytanie = "SELECT `name` FROM `banned`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$searchname = $wiersz[0];
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `banned` WHERE name='" . $searchname . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
$zapytanie = "INSERT INTO `banned` (name, totime) VALUES ('" . $_GET['searchname'] . "'," . $_GET['totime'] . ")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
}
else {
echo "-3";
die;
}
}
if($_GET['unban'] == 1) {
$zapytanie = "SELECT `name` FROM `banned`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$searchname = $wiersz[0];
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `banned` WHERE name='" . $searchname . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
else {
echo "-4";
die;
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>