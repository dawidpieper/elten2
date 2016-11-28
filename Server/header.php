<?php
$sql = mysql_connect("localhost", "dbuser", "dbpass")
or die("-1");
$sql_select = @mysql_select_db('dbname')
or die("-1");
if(mysql_query("SET NAMES utf8") == false) {
echo "-1";
die;
}
$cdate = time();
foreach($_GET as $value) {
$value = str_replace("\\","\\\\",$value);
$value = str_replace("\'","\\\'",$value);
}
$zapytanie = "SELECT `token`, `name`, `time` FROM `tokens`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
else
{
$error = -1;
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['token'])
if($wiersz[1] == $_GET['name']) {
if($wiersz[2] == date("dmY")) {
$error = "0";
$suc = true;
}
else {
$error = -2;
if($wiersz[2] == date("dmY",time()-3600)) {
$zapytanie = "UPDATE `tokens` SET `time`='".date("dmY")."' WHERE `token`='".$_GET['token']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$error = 0;
$suc = true;
}
}
}
else
$error = -2;
else
$error = -2;
}
if($suc == false) {
echo $error;
die;
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>