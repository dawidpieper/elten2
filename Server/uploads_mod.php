<?php
require("header.php");
if($_GET['add']==1) {
if(strlen($_POST['data']) > 16777216*3) {
echo "-3";
die;
}
$min=8;
$max=16;
srand((double)microtime()*1000000);
for($i=0;$i<rand($min,$max);$i++) {
$znak=chr(rand(48,122));
if (eregi("[0-9a-zA-Z]",$znak)) $haslo .= $znak;
else $i--;
}
$filename=$haslo;
$zapytanie = "INSERT INTO `uploads` (filename,file,owner) VALUES ('".$_GET['filename']."','".$filename."','".$_GET['name']."')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$fp = fopen("uploads/".$filename,"w");
fwrite($fp,$_POST['data']);
fclose($fp);
echo "0\r\n".$filename;
}
if($_GET['del'] == 1) {
$zapytanie = "SELECT `file` FROM `uploads` WHERE `owner`='".$_GET['name']."' AND `file`='".$_GET['file']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
if(mysql_num_rows($idzapytania)==0) {
echo "-4";
die;
}
$zapytanie = "DELETE FROM `uploads` WHERE `owner`='".$_GET['name']."' AND `file`='".$_GET['file']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
unlink("uploads/".$_GET['file']);
echo "0";
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>