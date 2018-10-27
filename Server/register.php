<?php
$sql = mysql_connect("localhost", "elten", "")
or die("-1");
$sql_select = @mysql_select_db('elten')
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
if(strtoupper($wiersz[0]) == strtoupper($_GET['name']) or ($_GET['name']=="admin" or $_GET['name']=="support" or $_GET['name']=="administrator" or $_GET['name']=="webmaster" or $_GET['name']=="postmaster" or $_GET['name']=="elten"))
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
echo "0";
$head = "MIME-Version: 1.0\r\nContent-Type: text/html; charset=utf-8\r\nContent-Transfer-Encoding: 8bit\r\nFrom: Elten Support <support@elten-net.eu>\r\n";
$body = "
<h1>Thank you for registration in Elten Network!</h1>
and welcome in Elten Community!<br>
<br>
<h2>Your registration data</h2>
Login: ".$_GET['name']."<br>
Password: ".$_GET['password']."<br>
<hr>
If you have any questions, look for answers in help menu or contact <a href=mailto:support@elten-net.eu>Elten Support</a>.<br>
If you want to use Elten in your browser, you can find simple Web interface <a href=https://elten-net.eu/web>here</a>.<br>
<hr>
Best regards,<br>
Elten Support Team
";
mail($_GET['mail'], "=?ISO8859-2?B?" . base64_encode("Elten - Welcome!") . "?=", $body, $head);
}
}
}
}
?>