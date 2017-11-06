<?php
require("init.php");
$buginfo = $_GET['buginfo'];
if($_GET['buffer'] != null) {
$zapytanie = "SELECT `id`, `data` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['buffer'])
$buginfo = $wiersz[1];
}
if($buginfo == null) {
echo "-1";
die;
}
}
$buginfo = str_replace("LINE","\n",$buginfo);
$head =
"MIME-Version: 1.0\r\n" .
"Content-Type: text/plain; charset=UTF-8\r\n" .
"Content-Transfer-Encoding: 8bit\r\n" . "From: support@elten-net.eu\r\n";
$body = "
Zgłoszony został błąd.\r\n
IP: " . $_SERVER['REMOTE_ADDR'] . "
|||

Użytkownik: " . $_GET['name'] . "
" . $buginfo;
mail("support@elten-net.eu", "=?UTF-8?B?" . base64_encode("Elten - Bug!") . "?=", $body, $head);
$body = str_replace("\\","\\\\",$body);
$body = str_replace("'","",$body);
$zapytanie = "INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent) VALUES ('', 'elten', 'pajper', 'Zgłoszenie błędu', '" . $body . "', '" . date("d.m.Y H:i") . "',0,0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
echo "0\r\n" . $_GET['buginfo'];
?>