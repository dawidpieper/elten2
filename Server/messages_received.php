<?php
require("header.php");
$date = date("d.m.Y H:i");
$zapytanie="SELECT `id`, `sender`, `subject`, `message`, `date`, `read` FROM `messages` where receiver='" . $_GET['name'] . "' and deletedfromreceived=0";
if($_GET['new']==1)
$zapytanie.=" AND `read` IS NULL";
$idzapytania = mquery($zapytanie);
$ile = 0;
$text = "";
if($_GET['hash']==1)
$text="[";
while ($wiersz = mysql_fetch_row($idzapytania)){
$ile = $ile + 1;
if($wiersz[5] == NULL)
$wiersz[5] = "0";
if($_GET['hash']==1)
$text .= "[".$wiersz[0].",".$wiersz[5].",\"".str_replace("\"","\\\"",str_replace("\\","\\\\",$wiersz[2])) . "\",\"" . $wiersz[1] . "\",\"" . $wiersz[4] . "\",\"" . str_replace("\"","\\\"",str_replace("\\","\\\\",$wiersz[3]))."\"],";
else
$text .= $wiersz[5]."\r\n".$wiersz[2] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[0] . "\r\n" . $wiersz[3] . "\r\n" . $wiersz[4] . "\r\nEND\r\n";
}
if($_GET['hash']==1) {
$text.="]";
$text=str_replace("\n","\\n",$text);
}
echo "0\r\n" . $ile . "\r\n" . $text;
?>