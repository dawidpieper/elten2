<?php
require("init.php");
$zapytanie = "SELECT `name` FROM `users`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['searchname'])
$suc = true;
}
echo "0\r\n";
if($suc == false)
echo "0";
else
echo "1";
?>