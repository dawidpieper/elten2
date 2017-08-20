<?php
function random_str($length, $keyspace = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
{
    $str = '';
    $max = mb_strlen($keyspace, '8bit') - 1;
    for ($i = 0; $i < $length; ++$i) {
        $str .= $keyspace[random_int(0, $max)];
    }
    return $str;
}
$sql = mysql_connect("localhost", "elten", "")
or die("-1");
$sql_select = @mysql_select_db('elten')
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
if($wiersz[1] == $_GET['password'] or crypt($wiersz[1],$wiersz[0])==$_GET['crp'])
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
$haslo=random_str(64);
$zapytanie = "INSERT INTO `tokens` (`token`, `name`, `time`) VALUES ('" . $haslo . "','" . $_GET['name'] . "', '" . date("dmY") . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1";
else
{
$loginsp = "\r\n" . $_GET['name'] . "|" . $_SERVER['REMOTE_ADDR'] . "|" . date("d.m.Y H:i:s") . "|" . $_GET['version'] . "|" . $_GET['beta'];
$fp = fopen("logins.txt","a");
fwrite($fp,$loginsp);
fclose($fp);
$zapytanie = "INSERT INTO `logins` (`id`,`name`,`ip`,`time`,`version`,`versiontype`,`beta`) VALUES ('','".$_GET['name']."','".$_SERVER['REMOTE_ADDR']."','".time()."','".explode(" ",$_GET['version'])[0]."','".explode(" ",$_GET['version'])[1]."','".$_GET['beta']."')";
$idzapytania=mysql_query($zapytanie);
if($idzapytania==false) {
echo "-1";
die;
}
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
$zapytanie = "SELECT `text` FROM `greetings` WHERE `name`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
if(mysql_num_rows($idzapytania) > 0)
$mes = mysql_fetch_row($idzapytania)[0];
else
$mes = "";
if($event > 0)
echo "0\r\n" . $haslo . "\r\n" . $event."\r\n".$mes;
else
echo "0\r\n" . $haslo."\r\n0\r\n".$mes;
}
}
}
}
?>