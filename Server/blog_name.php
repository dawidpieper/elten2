<?php
require("init.php");
$zapytanie = "SELECT `owner`, `name` FROM `blogs`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$name = $wiersz[1];
}
}
if($suc == false)
echo "-4";
else
echo "0\r\n" . $name;
?>