<?php
require("header.php");
$zapytanie = "SELECT `filename`, `file` FROM `uploads` WHERE `owner`='".$_GET['searchname']."' ORDER BY `filename`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$ile=0;
$tekst = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
$ile = $ile + 1;
$tekst.="\r\n".$wiersz[0]."\r\n".$wiersz[1];
}
echo "0\r\n".$ile.$tekst;
?>