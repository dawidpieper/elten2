<?php
require("header.php");
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

$q=mquery("select name,password,mail,code,verified,events from users where name='".$_GET['name']."' and password='".mysql_real_escape_string($_GET['password'])."'");
if(mysql_num_rows($q)==0)
die("-3");
$r=mysql_fetch_row($q);
if($_GET['ac']=='check') {
echo "0\r\n".$r[4]."\r\n".$r[5];
}
elseif($_GET['ac']=='verify') {
if(!isset($_GET['code'])) {
$code=random_str(16);
mquery("update users set code='".$code."' where name='".$_GET['name']."'");
$body = "
You receive this mail, because Mail verification has been started on your account.<br>
If it was you, please put the below verification code in Elten.<br>
Otherwise it is likely that someone has hacked your account. In such case, please contact Elten administration immediately!<br>
<h2>Your verification code is:</h2>
<h3>".$code."</h3>
<hr>
If you have any questions, look for answers in help menu or contact <a href=mailto:support@elten-net.eu>Elten Support</a>.<br>
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
$mail->addAddress($r[2]);
$mail->Subject = "Elten Mail Verification";
$mail->Body = $body;
$mail->AltBody = strip_tags($body);
$mail->send();
echo "0";
}
else {
if($_GET['code']==$r[3] and $_GET['code']!="") {
mquery("update users set code='', verified=1 where name='".$_GET['name']."'");
echo "0";
}
else
echo "-3";
}
}
elseif($_GET['ac']=='events') {
if(!isset($_GET['code']) and $_GET['enable']==0) {
$code=random_str(16);
mquery("update users set code='".$code."' where name='".$_GET['name']."'");
$body = "
You receive this mail, because you are disabling mail events reporting.<br>
If it was you, please put the below verification code in Elten.<br>
Otherwise it is likely that someone has hacked your account. In such case, please contact Elten administration immediately!<br>
<h2>Your verification code is:</h2>
<h3>".$code."</h3>
<hr>
If you have any questions, look for answers in help menu or contact <a href=mailto:support@elten-net.eu>Elten Support</a>.<br>
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
$mail->addAddress($r[2]);
$mail->Subject = "Elten Mail Reporting Disabling";
$mail->Body = $body;
$mail->AltBody = strip_tags($body);
echo $mail->body;
$mail->send();
echo "0";
}
else {
if($_GET['enable']==1 or $r[3]==$_GET['code']) {
mquery("update users set code='', events=".(int)$_GET['enable']." where name='".$_GET['name']."'");
echo "0";
}
else
echo "-3";
}
}
?>