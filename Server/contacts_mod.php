<?php
require("header.php");
$error = 0;
if($_GET['delete'] == 1) {
$zapytanie = "SELECT `id`,`user` FROM `contacts` where `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
$cid = 0;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[1] == $_GET['searchname']) {
$suc = true;
$cid = $wiersz[0];
}
}
if($suc == false) {
echo "-3";
die;
}
$zapytanie = "DELETE FROM `contacts` where id=" . $cid;
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
}
if($_GET['insert'] == 1) {
$zapytanie = "SELECT `user` FROM `contacts` where owner='" . $_GET['name'] . "'";
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
echo "-3";
die;
}
$searchname = $_GET['searchname'];
$zapytanie = "INSERT INTO `contacts` (id, owner, user) values ('','" . $_GET['name'] . "','" . $searchname . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
}
if($_GET['delete'] == 0 and $_GET['insert'] == 0) {
$zapytanie = "SELECT `user` FROM `contacts` WHERE owner='" . $_GET['name'] . "'";
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
echo "-3";
die;
}
echo "0";
}
?>