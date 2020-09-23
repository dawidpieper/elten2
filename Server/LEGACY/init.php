<?php
require("/var/www/html/srv/func.php");

$sus=array("../",".php");
$msgsus=false;
foreach($_GET as $k=>$v) {
foreach($sus as $s)
if(strpos(strtolower($v),$s) !== false)
$msgsus=true;
}

/*
if(!isset($_GET['name'])) {
$ch = curl_init();
$ipServeur = $_SERVER['SERVER_ADDR'];
$ipUser = $_SERVER['REMOTE_ADDR'];
if($_SERVER['HTTPS'] == "")
$portServeur = 80 ;
else
$portServeur = 443 ;
curl_setopt($ch, CURLOPT_URL, "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=" . $ipServeur . "&port=" . $portServeur);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$output = curl_exec($ch);
if(strlen($output) != 0){
if(strpos($output, $ipUser)){
die;
}else{

}
}else{

}
curl_close($ch);
}
*/
require("secret.php");
$sql = mysql_connect("localhost", "elten", $db_pass)
or die("-1\r\nsql");
$sql_select = @mysql_select_db('elten')
or die("-1\r\nsql");
if(mysql_query("SET NAMES utf8mb4") == false) {
echo "-1\r\nutf";
die;
}
$cdate = time();
function mquery($query) {
$queryid = mysql_query($query);
if($queryid == false) {
echo "-1\r\n" . $query;
die;
}
return $queryid;
}
function buffer_get($bufid) {
$ret='';
$q=mquery("SELECT `id`, `data`, `owner` FROM `buffers` where owner='".mysql_real_escape_string($_GET['name'])."' and id=".(int)$bufid);
if(mysql_num_rows($q)==0) die("-1");
return mysql_fetch_row($q)[1];
}
function getprivileges($searchname) {
$q = mquery("SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`");
$suc = false;
while ($r = mysql_fetch_row($q)){
if($r[0] == $searchname) {
$suc = true;
$name = $r[0];
$tester = $r[1];
$moderator = $r[2];
$media_administrator = $r[3];
$translator = $r[4];
$developer = $r[5];
}
}
if($suc == false) {
return([0,0,0,0,0]);
}
return([$tester,$moderator,$media_administrator,$translator,$developer]);
}
function random_str($length, $keyspace = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
{
    $str = '';
    $max = mb_strlen($keyspace, '8bit') - 1;
    for ($i = 0; $i < $length; ++$i) {
        $str .= $keyspace[random_int(0, $max)];
    }
    return $str;
}
//if($msgsus==true)
//message_send("elten","pajper","Suspicious Request",json_encode(array('srv'=>$_SERVER, 'get'=>$_GET)));
?>