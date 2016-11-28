<?php
require("header.php");
if($_GET['set'] == NULL) {
$zapytanie = "SELECT `id` FROM `media_categories`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$maxid = 0;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] > $maxid)
$maxid = $wiersz[0];
}
$zapytanie = "INSERT INTO media_categories (id, name, description) VALUES (".($maxid+1).",'".$_GET['categoryname']."','".$_GET['categorydescription']."')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$zapytanie = "CREATE TABLE media_".($maxid+1)." (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, url VARCHAR(1024), name VARCHAR(1024), description VARCHAR(8192), addedby VARCHAR(64))";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['set'] != NULL) {
$zapytanie = "SELECT `id` FROM `media`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$maxid = 0;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] > $maxid)
$maxid = $wiersz[0];
}
$zapytanie = "INSERT INTO media_".$_GET['set']." (id, url, name, description, addedby) VALUES (".($maxid+1).",'".$_GET['fileurl']."','".$_GET['filename']."','".$_GET['filedescription']."','".$_GET['name']."')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$zapytanie = "INSERT INTO media (id, object) VALUES ('',".($maxid+1).")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['delcategory'] != NULL) {
$zapytanie = "DELETE FROM media_categories WHERE `id`='".$_GET['del']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$zapytanie = "TRUNCATE TABLE media_".$_GET['del'];
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
if($_GET['delfile'] != NULL) {
$zapytanie = "DELETE FROM media_".$_GET['categoryid']." WHERE `id`='".$_GET['del']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>