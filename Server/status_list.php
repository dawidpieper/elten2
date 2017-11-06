<?php
require("init.php");
$zapytanie = "SELECT `name`, `status` FROM `statuses`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
$text = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$text .= "\r\n" . $wiersz[0] . "\r\n" . $wiersz[1] . "\r\nEND";
}
echo "0" . $text;
?>