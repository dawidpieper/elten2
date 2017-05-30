<?php
require("header.php");
$zapytanie = "SELECT `name`, `date` FROM `actived` ORDER BY `date` ASC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$lastseen = 0;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['searchname'])
$lastseen = $wiersz[1];
}
$zapytanie = "SELECT `owner`, `name` FROM `blogs`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname'])
$suc = true;
}
$hasblog = 0;
if($suc == false)
$hasblog =  0;
else
$hasblog =  1;
$zapytanie = "SELECT `user` FROM `contacts` WHERE `owner`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$knows = 0;
$knows = mysql_num_rows($idzapytania);
$zapytanie = "SELECT `owner` FROM `contacts` WHERE `user`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$knownby = 0;
$knownby = mysql_num_rows($idzapytania);
echo "0\r\n".$lastseen."\r\n".$hasblog."\r\n".$knows."\r\n".$knownby;
?>