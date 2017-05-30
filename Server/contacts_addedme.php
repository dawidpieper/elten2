<?php
require("header.php");
$error = 0;
$zapytanie = "SELECT `owner` FROM `contacts` WHERE `user`='".$_GET['name']."' ORDER BY `owner` ASC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
while ($wiersz = mysql_fetch_row($idzapytania)){
$name = $wiersz[0];
echo "\r\n" . $name;
}
?>