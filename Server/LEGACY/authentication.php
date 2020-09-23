<?php
if($_GET['enable']==1 or $_GET['disable']==1 or $_GET['verify']==1 or $_GET['generatebackup']==1)
require("header.php");
else
require("init.php");
if($_GET['state']==1) {
$q=mquery("select name,phone,actived,code from authentications where name='{$_GET['name']}'");
if(mysql_num_rows($q)==0)
die("0\r\n0");
$r=mysql_fetch_row($q);
if($r[2]==0)
die("0\r\n0");
else
die("0\r\n1");
}
if($_GET['enable']==1) {
if(mysql_fetch_row(mquery("select password from users where name='{$_GET['name']}'"))[0]!=$_GET['password'])
die("-2");
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
$message="Kod aktywujący dwuskładnikowe uwierzytelnianie w Eltenie: ".$code;
if($_GET['lang']!="pl_PL")
$message="Elten Two-factor authentication activation code: ".$code;
$sns = new \Aws\Sns\SnsClient($params);
$result = $sns->publish([
'Message' => $message,
'PhoneNumber' => $_GET['phone'],
'MessageAttributes' => [
'AWS.SNS.SMS.SenderID' => [
'DataType' => 'String',
'StringValue' => 'ELTEN'],
'AWS.SNS.SMS.SMSType' => [
'DataType' => 'String',
'StringValue' => 'Transactional']
]
]);
mquery("delete from authentications where name='{$_GET['name']}'");
mquery("insert into authentications (name,actived,phone,code) VALUES ('{$_GET['name']}',0,'".mysql_real_escape_string($_GET['phone'])."','{$code}')");
echo "0";
}
if($_GET['verify']==1) {
$q=mquery("select name,phone,actived,code,tries from authentications where name='{$_GET['name']}'");
if(mysql_num_rows($q)==0)
die("-4");
$r=mysql_fetch_row($q);
$code=$r[3];
$tries=$r[4];
if($code==$_GET['code'] and $tries<3) {
mquery("update authentications set actived=1 where name='{$_GET['name']}'");
if(mysql_num_rows(mquery("select * from authenticated where name='{$_GET['name']}' and appid='".mysql_real_escape_string($_GET['appid'])."'"))==0)
mquery("insert into authenticated (name,appid,date) values ('".$_GET['name']."','".mysql_real_escape_string($_GET['appid'])."',".time().")");
echo "0";
}
else {
mquery("update authentications set tries=tries+1 where name='{$_GET['name']}'");
echo "-3";
}
}
if($_GET['disable']==1) {
if(mysql_fetch_row(mquery("select password from users where name='{$_GET['name']}'"))[0]!=$_GET['password'])
die("-2");
mail_notify($_GET['name'], "Two-factor authentication has been disabled on your account");
mquery("update authentications set actived=0 where name='{$_GET['name']}'");
echo "0";
}
if($_GET['authenticate']==1) {
if($_GET['code']==NULL)
die("-3");
$suc=false;
if(mysql_num_rows(mquery("select id from authentications_altcodes where user='".mysql_real_escape_string($_GET['name'])."' and code='".mysql_real_escape_string($_GET['code'])."'"))>0) {
mquery("delete from authentications_altcodes where user='".mysql_real_escape_string($_GET['name'])."' and code='".mysql_real_escape_string($_GET['code'])."'");
$suc=true;
}
if($suc==false) {
$code=mysql_fetch_row(mquery("select code from authcodes where name='".mysql_real_escape_string($_GET['name'])."'"))[0];
if($_GET['code']==$code) {
$tries=mysql_fetch_row(mquery("select tries from authcodes where name='{$_GET['name']}'"))[0];
if($tries>3)
die("-3");
else {
mquery("delete from authcodes where name='{$_GET['name']}'");
$suc=true;
}
}
else {
mquery("update authcodes set tries=tries+1 where name='{$_GET['name']}'");
die("-3");
}
}
if($suc==true) {
mquery("insert into authenticated (name,appid,date) values ('{$_GET['name']}','".mysql_real_escape_string($_GET['appid'])."',".time().")");
echo "0";
}
}
if($_GET['generatebackup']==1) {
if(mysql_fetch_row(mquery("select password from users where name='{$_GET['name']}'"))[0]!=$_GET['password'])
die("-2");
mquery("delete from authentications_altcodes where user='".mysql_real_escape_string($_GET['name'])."'");
$codes=array();
for($i=0; $i<10; ++$i) {
$code = random_str(16);
mquery("insert into authentications_altcodes (user, code) values ('".mysql_real_escape_string($_GET['name'])."', '".$code."')");
array_push($codes, $code);
}
echo "0";
foreach($codes as $c)
echo "\r\n".$c;
}
?>