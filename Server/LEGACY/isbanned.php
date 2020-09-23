<?php
require("header.php");
$error = 0;
$idzapytania = mquery("SELECT `name`, `totime`, `reason` FROM `banned`");
echo "0";
$totime="";
$reason="";
while ($wiersz = mysql_fetch_row($idzapytania)){
$name = $wiersz[0];
$date = $wiersz[1];
if($date > $cdate and $name == $_GET['searchname']) {
$totime=$wiersz[1];
$reason=$wiersz[2];
$isbanned = true;
}
}
if($isbanned == true)
echo "0\r\n1\r\n".$totime."\r\n".$reason;
else
echo "0\r\n0";
?>