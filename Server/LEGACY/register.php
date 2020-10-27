<?php
require("init.php");
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

sleep(1);
if($_GET['register'] == "1") {

if(strpos($_GET['name'], ' ') !== false)
die("-2");
if(strpos($_GET['name'], '[') !== false)
die("-2");
if(strpos($_GET['name'], ']') !== false)
die("-2");
if(strpos($_GET['name'], ':') !== false)
die("-2");
if(strpos($_GET['name'], '@') !== false)
die("-2");

$q = mquery("SELECT `name` FROM `users`");
while ($wiersz = mysql_fetch_row($q)){
if(strtoupper($wiersz[0]) == strtoupper($_GET['name']) or ($_GET['name']=="admin" or $_GET['name']=="support" or $_GET['name']=="administrator" or $_GET['name']=="webmaster" or $_GET['name']=="postmaster" or $_GET['name']=="elten") and strpos("'",$_GET['name'])===false and strpos("<",$_GET['name'])===false and strpos("[",$_GET['name'])===false and strpos("@",$_GET['name'])===false and strpos(" ",$_GET['name'])===false and strpos("%",$_GET['name'])===false and strpos(":",$_GET['name'])===false and strpos("\"",$_GET['name'])===false)
die("-2");
}
mquery("INSERT INTO `users` (`name`, `password`, `mail`) VALUES ('" . mysql_real_escape_string($_GET['name']) . "', '" . mysql_real_escape_string($_GET['password']) . "', '" . mysql_real_escape_string($_GET['mail']) . "')");
echo "0";
$body = "
<h1>Thank you for registration in Elten Network!</h1>
and welcome in Elten Community!<br>
<br>
<h2>Your registration data</h2>
Login: ".$_GET['name']."<br>
Password: Selected during registration<br>
<hr>
If you have any questions, look for answers in help menu or contact <a href=mailto:support@elten-net.eu>Elten Support</a>.<br>
If you want to use Elten in your browser, you can find simple Web interface <a href=https://elten-net.eu/web>here</a>.<br>
<hr>
Best regards,<br>
Elten Support Team
";
$mail = new PHPMailer();
$mail->CharSet = 'UTF-8';
$mail->isHTML(true);
$mail->XMailer = ' ';
$mail->isSMTP();
$mail->Host       = 'elten-net.eu';
$mail->setFrom('support@elten-net.eu', "Elten Support Team");
$mail->addAddress($_GET['mail']);
$mail->Subject = "Elten - Welcome!";
$mail->Body = $body;
$mail->send();
}
?>