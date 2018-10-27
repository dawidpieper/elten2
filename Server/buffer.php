<?php
require("header.php");
if($_GET['ac'] == 1) {
$zapytanie = "SELECT `id` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['id']){
$suc = true;
}
}
if($suc == true) {
sleep(1);
$zapytanie = "DELETE FROM `buffers` WHERE `id`='" . $_GET['id'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
$zapytanie = "INSERT INTO `buffers` (id, data, owner, date) VALUES ('" . $_GET['id'] . "', '" . $_GET['data'] . "','" . $_GET['name'] . "',".time().")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
if($_GET['ac'] == 2) {
$zapytanie = "SELECT `id`, `data`, `owner` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
$data = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['id']){
$suc = true;
$data = $wiersz[1];
$owner = $wiersz[2];
}
}
if($suc == false) {
echo "-1\r\n" . $zapytanie;
die;
}
if($owner == $_GET['name']) {
$zapytanie = "DELETE FROM `buffers` WHERE `id`='" . $_GET['id'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$zapytanie = "INSERT INTO `buffers` (id, data, owner, date) VALUES ('" . $_GET['id'] . "', '" . $data . $_GET['data'] . "','" . $_GET['name'] . "',".time().")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
else {
echo "-2";
die;
}
}
echo "0";
?>