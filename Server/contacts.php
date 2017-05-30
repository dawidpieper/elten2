<?php
require("header.php");
$error = 0;
$zapytanie = "SELECT `user` FROM `contacts` WHERE `owner`='".$_GET['name']."' ORDER BY `user` ASC";
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