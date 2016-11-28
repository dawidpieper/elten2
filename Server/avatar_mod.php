<?php
require("header.php");
if(strlen($_POST['avatar']) > 16777216*3) {
echo "-1";
die;
}
$fp = fopen("avatars/".$_GET['name'],"w");
fwrite($fp,$_POST['avatar']);
fclose($fp);
echo "0";
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>