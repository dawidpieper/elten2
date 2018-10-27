<?php
require("header.php");
if(file_exists("cache/messages_".$_GET['name'].".dat")) unlink("cache/messages_".$_GET['name'].".dat");
$zapytanie = "SELECT `id`, `read`, `receiver` FROM `messages` where `receiver`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[2] == $_GET['name']) {
$wzapytanie = "UPDATE `messages` SET `read`=".Time()." WHERE `id`='".$wiersz[0]."'";
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1";
die;
}
}
}
echo "0";
?>