<?php
require("init.php");
if(isset($_GET['step'])==false) {
$error=-2;
$mail="";
$q = mquery("SELECT `name`, `mail` FROM `users`");
$mail=$_GET['mail'];
while ($wiersz = mysql_fetch_row($q)) {
if($wiersz[0] == $_GET['name'] and $wiersz[1] == $_GET['mail']) {
$name=$wiersz[0];
$mail=$wiersz[1];
$error = 0;
}
}
if($error!=0)
die($error);
$password=random_str(64);
mquery("UPDATE `users` SET `resetpassword`='".$password."' WHERE `name`='".$_GET['name']."'");
$head = "MIME-Version: 1.0\r\nContent-Type: text/html; charset=utf-8\r\nContent-Transfer-Encoding: 8bit\r\nFrom: Elten Support <support@elten-net.eu>\r\n";
$body = "
You receive this e-mail, because the password reset has been requested.
You can login once to your account, using the below password.
Note, this password can be used only one time, so please use it only for the password change.
If you didn't request password change, you can use your old password, after login with your normal password, this special password will be deleted.
Password: " . $password . "\r\n
\r\n\r\n
Otrzymujesz tą wiadomość, ponieważ zarządano zresetowania hasła do tego konta.
Poniższe hasło jest hasłem jednokrotnego użytku, należy go użyć jedynie do zalogowania do konta w celu zmiany hasła.
Jeśli nie zarządałeś zmiany hasła, możesz zalogować się z użyciem twojego starego hasła.
W takim wypadku poniższe hasło zostanie unieważnione.
Hasło: " . $password . "\r\n
\r\n\r\n
Pozdrawiamy / Best Regards !\r\n
Administracja Elten / Elten Support
";
mail($mail, "=?ISO8859-2?B?" . base64_encode("Elten - Forgot Password!") . "?=", $body, $head);
echo "0\r\n".$name."\r\n".$mail;
}
if($_GET['step']==1) {
$q = mquery("SELECT `name`, `mail` FROM `users`");
$suc=false;
while ($r = mysql_fetch_row($q)){
if($r[0] == $_GET['name'] and $r[1] == $_GET['mail']) {
$name=$wiersz[0];
$mail=$wiersz[1];
$suc=true;
}
}
if($suc==false)
die("-2");
$password=random_str(64);
mquery("UPDATE `users` SET `resetpassword`='".$password."' WHERE `name`='".$_GET['name']."'");
$head = "MIME-Version: 1.0\r\nContent-Type: text/html; charset=utf-8\r\nContent-Transfer-Encoding: 8bit\r\nFrom: Elten Support <support@elten-net.eu>\r\n";
$body = "
You receive this e-mail, because the password reset has been requested.<br>
TO proceed, please go to the Password Reset Menu and paste the following code.<br>
Code: <br>" . $password . "<br>
<br><br>
Otrzymujesz tą wiadomość, ponieważ zarządano zresetowania hasła do tego konta.<br>
Aby kontynuować, wprowadź poniższy kod w menu resetowania hasła.<br>
Kod:<br>" . $password . "<br>
<br><br>
Pozdrawiamy / Best Regards !<br>
Administracja Elten / Elten Support
";
mail($_GET['mail'], "=?ISO8859-2?B?" . base64_encode("Elten - Password Reset!") . "?=", $body, $head);
echo "0";
}
if($_GET['step']==2) {
$q=mquery("select name,mail,resetpassword from users");
$suc=false;
while($r=mysql_fetch_row($q)) {
if($r[0]==$_GET['name'] and $r[1]==$_GET['mail'] and $r[2]==$_GET['key'] and $_GET['key']!=null and $_GET['key']!="")
$suc=true;
}
if($suc==false)
die("-2");
if($_GET['change']==1) {
mquery("update authentications set actived=0 where name='{$_GET['name']}'");
mquery("update users set password='".$_GET['newpassword']."', resetpassword=null where name='".$_GET['name']."' and mail='".$_GET['mail']."' and resetpassword='".$_GET['key']."'");
}
echo "0";
}
?>