<?php
$mail="";
function random_str($length, $keyspace = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
{
    $str = '';
    $max = mb_strlen($keyspace, '8bit') - 1;
    for ($i = 0; $i < $length; ++$i) {
        $str .= $keyspace[random_int(0, $max)];
    }
    return $str;
}
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
$error = -2;
$mail=$_GET['mail'];
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name'] and $wiersz[1] == $_GET['mail']) {
$name=$wiersz[0];
$mail=$wiersz[1];
$error = 0;
}
}
if($error < 0)
echo $error;
else
{
$password=random_str(64);
$zapytanie = "UPDATE `users` SET `resetpassword`='".$password."' WHERE `name`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-3\r\n".$zapytanie;
else
{
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
}
?>