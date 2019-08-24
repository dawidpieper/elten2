<?php
require("init.php");
$zapytanie = "SELECT `code`, `language`, `file` FROM `languages`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$text = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$text .= "\r\n" . $wiersz[2];
}
echo "0" . $text;
?>