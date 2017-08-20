<?php
require("header.php");
if($_GET['add']==1) {
if(strlen($_POST['data']) > 134217728*3) {
echo "-3";
die;
}
$filename=random_str(24);
$zapytanie = "INSERT INTO `uploads` (filename,file,owner) VALUES ('".str_replace("\'","",$_GET['filename'])."','".$filename."','".$_GET['name']."')";
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
?>