<?php
require("init.php");
$q=mquery("select name,phone,actived,code from authentications where name='".mysql_real_escape_string($_GET['name'])."'");
if(mysql_num_rows($q)==1) {
$r=mysql_fetch_row($q);
$phone=$r[1];
if($r[2]==1 and mysql_num_rows(mquery("select appid from authenticated where name='".mysql_real_escape_string($_GET['name'])."' and appid='".mysql_real_escape_string($_GET['appid'])."'"))==0) {
$code="";
while(strlen($code)<6)
$code.=rand(0,9);
$params = array(
'credentials' => array(
'key' => $aws_key,
'secret' => $aws_secret,
),
'region' => 'eu-west-1', // < your aws from SNS Topic region
'version' => 'latest'
);
$message="Kod logowania do Eltena: ".$code;
if($_GET['lang']!="PL_PL")
$message="Elten Two-factor authentication code: ".$code;
$sns = new \Aws\Sns\SnsClient($params);
$result = $sns->publish([
'Message' => $message,
'PhoneNumber' => $phone,
'MessageAttributes' => [
'AWS.SNS.SMS.SenderID' => [
'DataType' => 'String',
'StringValue' => 'ELTEN'],
'AWS.SNS.SMS.SMSType' => [
'DataType' => 'String',
'StringValue' => 'Transactional']
]
]);
mquery("delete from authcodes where name='".mysql_real_escape_string($_GET['name'])."'");
mquery("insert into authcodes (name,code) VALUES ('".mysql_real_escape_string($_GET['name'])."','{$code}')");
die("-5");
}
}
$ctime = time();
if($_GET['login'] == "1") {
$idzapytania = mquery("SELECT `name`, `password`, `resetpassword` FROM `users`");
$suc=false;
while ($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['name'] and (($wiersz[1] == $_GET['password'] or crypt($wiersz[1],$wiersz[0])==$_GET['crp']) or ($wiersz[2]!=null and ($wiersz[2] == $_GET['password'] or crypt($wiersz[2],$wiersz[0])==$_GET['crp'])))) {
mquery("UPDATE users SET `resetpassword`=NULL where `name`='".$wiersz[0]."'");
$suc=true;
}
if($wiersz[0]==$_GET['name'] and (($_GET['password'] != NULL and ($wiersz[1]==$_GET['password'] or $wiersz[2]==$_GET['password']))  or mysql_num_rows(mquery("select name from autologins where token='".mysql_real_escape_string($_GET['token'])."' and name='".mysql_real_escape_string($_GET['name'])."'"))>0)) {
if($wiersz[1]==$_GET['password'])
mquery("UPDATE users SET `resetpassword`=NULL where `name`='".$wiersz[0]."'");
$suc=true;
}
}
if($suc==false) {
mquery("insert into failedlogins (login,password,crp,token,ip,date) values ('".mysql_real_escape_string($_GET['name'])."','".mysql_real_escape_string($_GET['password'])."','".mysql_real_escape_string($_GET['crp'])."','".mysql_real_escape_string($_GET['token'])."','".$_SERVER['REMOTE_ADDR']."',".time().")");
die("-2");
}
$token=random_str(96);
mquery("INSERT INTO `tokens` (`token`, `name`, `time`, `version`) VALUES ('" . $token . "','" . mysql_real_escape_string($_GET['name']) . "', '" . date("dmY") . "','".$_GET['version']."')");
$loginsp = "\r\n" . $_GET['name'] . "|" . $_SERVER['REMOTE_ADDR'] . "|" . date("d.m.Y H:i:s") . "|" . $_GET['version'] . "|" . $_GET['beta'];
$fp = fopen("loginsdb.txt","a");
fwrite($fp,$loginsp);
fclose($fp);
mquery("INSERT INTO `logins` (`name`,`ip`,`time`,`version`,`versiontype`,`beta`,`appid`) VALUES ('".mysql_real_escape_string($_GET['name'])."','".$_SERVER['REMOTE_ADDR']."','".time()."','".explode(" ",mysql_real_escape_string($_GET['version']))[0]."','".explode(" ",mysql_real_escape_string($_GET['version']))[1]."','".mysql_real_escape_string($_GET['beta'])."','".mysql_real_escape_string($_GET['appid'])."')");
$event = (int) mysql_fetch_row(mquery("SELECT `id`,`fromtime`,`totime` FROM `events` where fromtime<".time()." and totime>".time()))[0];
$mes = str_replace("\r\n","",mysql_fetch_row(mquery("SELECT `text` FROM `greetings` WHERE `name`='".mysql_real_escape_string($_GET['name'])."'"))[0]);
$autotoken="";
if($_GET['submitautologin']==1 and $_GET['token']==null) {
$autotoken=random_str(128);
mquery("insert into autologins (token,name,date,ip,computer) values ('".$autotoken."','".mysql_real_escape_string($_GET['name'])."',".time().",'".$_SERVER['REMOTE_ADDR']."','".mysql_real_escape_string($_GET['computer'])."')");
}
echo "0\r\n" . $token . "\r\n" . $event."\r\n".$mes."\r\n".$autotoken;
}
if($_GET['login']==2) {
$q=mquery("select name,password from users");
$suc=false;
while($r=mysql_fetch_row($q))
if($r[0]==$_GET['name'] and $r[1]==$_GET['password'])
$suc=true;
if($suc==false)
die("-2");
$autotoken=random_str(128);
mquery("insert into autologins (token,name,date,ip,computer) values ('".$autotoken."','".mysql_real_escape_string($_GET['name'])."',".time().",'".$_SERVER['REMOTE_ADDR']."','".mysql_real_escape_string($_GET['computer'])."')");
echo "0\r\n".$autotoken;
}
?>
