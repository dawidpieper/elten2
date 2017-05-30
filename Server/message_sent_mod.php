<?php
require("header.php");
$date = date("d.m.Y H:i");
$zapytanie = "SELECT `id`, `sender`, `receiver`, `subject`, `message`, `date` FROM `messages` where `sender`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
if($_GET['delete'] == 1) {
$zapytanie = "UPDATE `messages` SET `deletedfromsent`=1 WHERE id=" . $_GET['id']." and sender='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
}
?>