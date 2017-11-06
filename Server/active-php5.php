<?php
require("header.php");
$zapytanie = "SELECT `name`, `date` FROM `actived`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name']) {
$name = $wiersz[0];
$date_t = $wiersz[1];
$suc = true;
}
}
if($suc == false) {
$zapytanie = "INSERT INTO `actived` (name, date) VALUES ('" . $_GET['name'] . "','" . $cdate . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0\r\n";
}
else {
$zapytanie = "UPDATE `actived` SET `name` = '" . $_GET['name'] . "', `date` ='" . $cdate . "'  WHERE `name`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0\r\n";
}
echo "0";
?>