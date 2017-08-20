<?php
$sql = mysql_connect("localhost", "elten", "")
or die("-1\r\nsql");
$sql_select = @mysql_select_db('elten')
or die("-1\r\nsql");
if(mysql_query("SET NAMES utf8") == false) {
echo "-1\r\nutf";
die;
}
$cdate = time();
foreach($_GET as $key => $value) {
$v = str_replace("\\","\\\\",$value);
$g[$key] = str_replace("'","\\'",$v);
}
$_GET=$g;
if($_GET['test']==1) {
print_r($g);
print_r($_GET);
}
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
$q=mquery("SELECT `id`, `data`, `owner` FROM `buffers`");
while($r = mysql_fetch_row($q)) {
if($r[0] == $bufid and $r[2] == $_GET['name'])
$ret = $r[1];
}
if($ret == null) {
echo "-1";
die;
}
$ret = str_replace("\\","\\\\",$ret);
$ret = str_replace("'","\\'",$ret);
return $ret;
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
$q=mquery("SELECT `token`, `name`, `time` FROM `tokens`");
$error = -1;
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['token'])
if($wiersz[1] == $_GET['name']) {
if($wiersz[2] == date("dmY")) {
$error = "0";
$suc = true;
}
else {
$error = -2;
if($wiersz[2] == date("dmY",time()-3600)) {
mquery("UPDATE `tokens` SET `time`='".date("dmY")."' WHERE `token`='".$_GET['token']."'");
$error = 0;
$suc = true;
}
}
}
else
$error = -2;
else
$error = -2;
}
if($suc == false) {
echo $error;
die;
}
?>