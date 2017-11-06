<?php
require("init.php");
$period=90;
if($_GET['period']!=NULL)
$period=$_GET['period'];
$error = 0;
$zapytanie = "SELECT `name`, `date` FROM `actived`";
if($period==90)
$zapytanie.=" ORDER BY `name`";
else
$zapytanie.=" ORDER BY `date` DESC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
while ($wiersz = mysql_fetch_row($idzapytania)){
$name = $wiersz[0];
$date = $wiersz[1];
if($date + $period >= $cdate) {
echo "\r\n" . $name;
}
}
?>