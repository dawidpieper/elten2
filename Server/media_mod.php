<?php
require("header.php");
if($_GET['set'] == NULL) {
$zapytanie = "SELECT `id` FROM `media_categories`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
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
echo "-1\r\n".$zapytanie;
die;
}
echo "0";
}
if($_GET['set'] != NULL) {
$zapytanie = "SELECT `id` FROM `media`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$maxid = 0;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] > $maxid)
$maxid = $wiersz[0];
}
$zapytanie = "INSERT INTO media_data (fid, id, url, name, description, addedby, category) VALUES ('',".($maxid+1).",'".$_GET['fileurl']."','".$_GET['filename']."','".$_GET['filedescription']."','".$_GET['name']."',".$_GET['set'].")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$zapytanie = "INSERT INTO media (id, object) VALUES ('',".($maxid+1).")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
echo "0";
}
if($_GET['delcategory'] != NULL) {
$zapytanie = "DELETE FROM media_categories WHERE `id`='".$_GET['del']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$zapytanie = "DELETE FROM media_data WHERE `category`=".$_GET['del'];
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
echo "0";
}
if($_GET['delfile'] != NULL) {
$zapytanie = "DELETE FROM media_data WHERE `category`=".$_GET['category']." AND `fid`='".$_GET['del']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
echo "0";
}
?>