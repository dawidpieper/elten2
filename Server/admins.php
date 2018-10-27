<?php
require("init.php");
$error = 0;
$zapytanie = "SELECT `name` FROM `privileges` where moderator=1";
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