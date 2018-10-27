<?php
require("header.php");
$zapytanie = "SELECT `id` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['id']){
$suc = true;
}
}
if($suc == true) {
sleep(1);
$zapytanie = "DELETE FROM `buffers` WHERE `id`='" . $_GET['id'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
$zapytanie = "INSERT INTO `buffers` (id, data, owner, date) VALUES ('" . $_GET['id'] . "', '" . mysql_escape_string($_POST['data']) . "','" . $_GET['name'] . "',".time().")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
?>