<?php
require("init.php");
if(strpos("/",$_GET['searchname']) !== false) die;
if(strpos("\\",$_GET['searchname']) !== false) die;
if(file_exists("avatars/".$_GET['searchname']) == false) {
echo "-4";
die;
}
if($_GET['checkonly'] != 1) {
$fpa = fopen("avatars/".$_GET['searchname'],"r");
$avatar = fread($fpa,FileSize("avatars/".$_GET['searchname']));
fclose($fpa);
echo "0\r\n" . $avatar;
}
else
echo "0";
?>