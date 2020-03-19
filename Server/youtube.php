<?php
require("init.php");
$url="https://www.googleapis.com/youtube/v3/{$_GET['sect']}?key={$googlekey}";
foreach($_GET as $k=>$v)
if($k!='name' and $k!='token' and $k!='sect')
$url.="&".$k."=".urlencode($v);
$q=mquery("select response from youtube where url='".mysql_real_escape_string($url)."' and time>unix_timestamp()-3600 order by time desc");
if(mysql_num_rows($q)>0)
$json=mysql_fetch_row($q)[0];
else {
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, 0);
$json = curl_exec($ch);
if(json_decode($json,true)['error']==null and (json_last_error() == JSON_ERROR_NONE))
mquery("
insert into youtube
(user, url, time, response)
values
('".mysql_real_escape_string($_GET['name'])."', '".mysql_real_escape_string($url)."', ".time().", '".mysql_real_escape_string($json)."')
");
}
header("Content-Type: application/json");
echo $json;
?>