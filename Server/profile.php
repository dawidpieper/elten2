<?php
require("header.php");
if($_GET['mod'] == 1) {
$zapytanie = "SELECT `name` FROM `profiles` WHERE `name`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
if(mysql_num_rows($idzapytania) <= 0) {
$zapytanie = "INSERT INTO `profiles` (name) VALUES ('".$_GET['name']."')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
}
$zapytanie = "UPDATE `profiles` SET `fullname`='".$_GET['fullname']."', `gender`='".$_GET['gender']."', `birthdateyear`='".$_GET['birthdateyear']."', `birthdatemonth`='".$_GET['birthdatemonth']."', `birthdateday`='".$_GET['birthdateday']."', `location`='".$_GET['location']."', `publicprofile`='".$_GET['publicprofile']."', `publicmail`='".$_GET['publicmail']."' WHERE `name`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
echo "0";
}
if($_GET['public'] == 1) {
$zapytanie = "SELECT `name`, `publicprofile`, `publicmail` FROM `profiles` WHERE `name`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$publicmail = 0;
$publicprofile = -1;
if(mysql_num_rows($idzapytania) > 0) {
$wiersz = mysql_fetch_row($idzapytania);
$publicprofile = $wiersz[1];
$publicmail = $wiersz[2];
}
echo "0\r\n".$publicprofile."\r\n".$publicmail;
}
if($_GET['get'] == 1) {
$zapytanie = "SELECT `name`, `publicprofile`, `publicmail` FROM `profiles` WHERE `name`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$publicmail = 0;
$publicprofile = -1;
if(mysql_num_rows($idzapytania) > 0) {
$wiersz = mysql_fetch_row($idzapytania);
$publicprofile = $wiersz[1];
$publicmail = $wiersz[2];
}
else
echo "-4";
if($publicprofile == 1) {
$zapytanie = "SELECT `user` FROM `contacts` WHERE `owner`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
if(mysql_num_rows($idzapytania) <= 0 and $_GET['name'] != $_GET['searchname']) {
echo "-3";
die;
}
}
$zapytanie = "SELECT `name`, `fullname`, `gender`, `birthdateyear`, `birthdatemonth`, `birthdateday`, `location`, `publicprofile`, `publicmail` FROM `profiles` WHERE `name`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$wiersz = mysql_fetch_row($idzapytania);
echo "0\r\n".$wiersz[1]."\r\n".$wiersz[2]."\r\n".$wiersz[3]."\r\n".$wiersz[4]."\r\n".$wiersz[5]."\r\n".$wiersz[6]."\r\n".$wiersz[7];
}
?>