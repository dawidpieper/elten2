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
$zapytanie = "SELECT `name`, `mail` FROM `users`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1\r\n" . $zapytanie;
else
{
$error = -2;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] != $_GET['name'] or $wiersz[1] != $_GET['mail'])
$error = 0;
}
if($error < 0)
echo $error;
else
{
srand((double)microtime()*1000000);
for($i=0;$i<rand(8,60);$i++) {
$znak=chr(rand(48,122));
if (eregi("[0-9a-zA-Z]",$znak)) $password .= $znak;
else $i--;
};
$zapytanie = "UPDATE `users` SET `password`='".$password."' WHERE `name`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-3\r\n".$zapytanie;
else
{
$head =
"MIME-Version: 1.0\r\n" .
"Content-Type: text/plain; charset=ISO8859-2\r\n" .
"Content-Transfer-Encoding: 8bit\r\n" . "From: dawidpieper@o2.pl\r\n";
$body = "
Elten\r\n\r\n
Your password has been reset...\r\n
New login data:\r\n
Login: " . $_GET['name'] . "\r\n
Password: " . $password . "\r\n
\r\n\r\n
Twoje hasło zostało zresetowane...\r\n
Nowe dane dostępowe:\r\n
Login: " . $_GET['name'] . "\r\n
Hasło: " . $password . "\r\n
Pozdrawiamy / Best Regards !\r\n
Administracja Elten / Elten Support
";
mail($_GET['mail'], "=?ISO8859-2?B?" . base64_encode("Elten - your password has been reset / twoje hasło zostało zresetowane") . "?=", $body, $head);
echo "0";
}
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>