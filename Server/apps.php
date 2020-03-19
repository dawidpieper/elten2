<?php
require("init.php");
if($_GET['list'] == 1) {
$zapytanie = "Select `name`, `version`, `description`, `file` FROM `apps`";
$idzapytania = mquery($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$ile = 0;
$text = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$ile = $ile + 1;
$text .= $wiersz[3] . "\r\n" . $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2] . "\r\nEND\r\n";
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
?>