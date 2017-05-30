<?php
require("header.php");
if($_GET['add'] == 1) {
$zapytanie = "INSERT INTO `blog_categories` (id, owner, name) VALUES ('','".$_GET['name']."','" . $_GET['categoryname'] . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
if($_GET['del'] == 1) {
$zapytanie = "DELETE FROM `blog_assigning` WHERE `categoryid`='".$_GET['categoryid']."' AND `owner`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$zapytanie = "DELETE FROM `blog_categories` WHERE `id`='".$_GET['categoryid']."' AND `owner`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
if($_GET['rename'] == 1) {
$zapytanie = "UPDATE `blog_categories` SET `name`='".$_GET['categoryname']."' WHERE `id`='".$_GET['categoryid']."' AND `owner`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
echo "0";
?>