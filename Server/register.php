<?php
require("init.php");
if($_GET['register'] == "1") {

$q = mquery("SELECT `name` FROM `users`");
while ($wiersz = mysql_fetch_row($q)){
if(strtoupper($wiersz[0]) == strtoupper($_GET['name']) or ($_GET['name']=="admin" or $_GET['name']=="support" or $_GET['name']=="administrator" or $_GET['name']=="webmaster" or $_GET['name']=="postmaster" or $_GET['name']=="elten") and strpos("'",$_GET['name'])===false)
die("-2");
}
mquery("INSERT INTO `users` (`name`, `password`, `mail`) VALUES ('" . mysql_real_escape_string($_GET['name']) . "', '" . mysql_real_escape_string($_GET['password']) . "', '" . mysql_real_escape_string($_GET['mail']) . "')");
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
?>