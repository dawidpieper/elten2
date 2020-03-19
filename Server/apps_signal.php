<?php
require("header.php");
function isJson($string) {
json_decode($string);
return (json_last_error() == JSON_ERROR_NONE);
}
if($_GET['ac']=="create") {
$packet=$_GET['packet'];
if(isset($_GET['buf'])) $packet=buffer_get($_GET['buf']);
if(!isJson($packet)) die("-3");
mquery("insert into apps_signals
(appid, sender, receiver, time, packet)
values
(".(int)$_GET['appid'].", '".mysql_real_escape_string($_GET['name'])."', '".mysql_real_escape_string($_GET['user'])."', unix_timestamp(), '".mysql_real_escape_string($packet)."')
");
echo "0";
}
?>