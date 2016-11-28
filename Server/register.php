<?php
$sql = mysql_connect("localhost", "dbuser", "dbpass")
or die("-1");
$sql_select = @mysql_select_db('dbname')
or die("-1");
if(mysql_query("SET NAMES utf8") == false) {
echo "-1";
die;
}
foreach($_GET as $value) {
$value = str_replace("\\","\\\\",$value);
$value = str_replace("\'","\\\'",$value);
}
if($_GET['register'] == "1")
{
$zapytanie = "SELECT `name` FROM `users`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1\r\n" . $zapytanie;
else
{
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name'])
$error = -2;
}
if($error < 0)
echo $error;
else
{
$zapytanie = "INSERT INTO `users` (`name`, `password`, `mail`) VALUES ('" . $_GET['name'] . "', '" . $_GET['password'] . "', '" . $_GET['mail'] . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-3";
else
{
$zapytanie = "CREATE TABLE contacts_" . $_GET['name'] . " (user VARCHAR(64) NOT NULL PRIMARY KEY)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$zapytanie = "CREATE TABLE followedthreads_" . $_GET['name'] . " (id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, forum VARCHAR(128), thread VARCHAR(256))";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$zapytanie = "CREATE TABLE forum_read_" . $_GET['name'] . " (id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, forum VARCHAR(128), thread VARCHAR(256), posts INT)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
$head =
"MIME-Version: 1.0\r\n" .
"Content-Type: text/plain; charset=ISO8859-2\r\n" .
"Content-Transfer-Encoding: 8bit\r\n" . "From: dawidpieper@o2.pl\r\n";
$body = "
Elten
Witamy w serwisie Elten!\r\n
Możesz się zalogować, używając podanych danych:\r\n
Login: " . $_GET['name'] . "\r\n
Hasło: " . $_GET['password'] . "\r\n
Pozdrawiamy!\r\n
Administracja Elten
";
mail($_GET['mail'], "=?ISO8859-2?B?" . base64_encode("Elten - Witamy!") . "?=", $body, $head);
}
}
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>