<?php
$sql = mysql_connect("localhost", "dbuser", "dbpass")
or die("-1");
$sql_select = @mysql_select_db('dbname')
or die("-1");
foreach($_GET as $value) {
$value = str_replace("\\","\\\\",$value);
$value = str_replace("\'","\\\'",$value);
}
if(mysql_query("SET NAMES utf8") == false) {
echo "-1";
die;
}
$ctime = time();
if($_GET['login'] == "1")
{
$zapytanie = "SELECT `name`, `password` FROM `users`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1";
else
{
$error = -2;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name'])
if($wiersz[1] == $_GET['password'])
$error = "0";
else
$error = -2;
}
if($error < 0)
echo $error;
else
{
$zapytanie = "SELECT `name`, `totime` FROM `banned`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name']) {
$totime = $wiersz[1];
$suc = true;
}
}
if($suc == true) {
if($ctime < $totime) {
echo "-3";
die;
}
}
$min=24;
$max=64;
srand((double)microtime()*1000000);
for($i=0;$i<rand($min,$max);$i++) {
$znak=chr(rand(48,122));
if (eregi("[0-9a-zA-Z]",$znak)) $haslo .= $znak;
else $i--;
};
$zapytanie = "INSERT INTO `tokens` (`token`, `name`, `time`) VALUES ('" . $haslo . "','" . $_GET['name'] . "', '" . date("dmY") . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1";
else
{
$zapytanie = "SELECT `id`,`fromtime`,`totime` FROM `events`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$event = 0;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[1] < time() and $wiersz[2] > time()) {
$event = $wiersz[0];
}
}
if($event > 0)
echo "0\r\n" . $haslo . "\r\n" . $event;
else
echo "0\r\n" . $haslo;
}
}
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>