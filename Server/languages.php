<?php
$sql = mysql_connect("localhost", "elten", "PPdiwaD99")
or die("-1");
$sql_select = @mysql_select_db('elten')
or die("-1");
if(mysql_query("SET NAMES utf8") == false) {
echo "-1";
die;
}
$cdate = time();
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