<?php
require("init.php");
$buginfo = $_GET['buginfo'];
if($_GET['buffer'] != null)
$buginfo=buffer_get($_GET['buffer']);
$buginfo = str_replace("LINE","\n",$buginfo);
$body = "
Zgłoszony został błąd.\r\n
IP: " . $_SERVER['REMOTE_ADDR'] . "
|||

Użytkownik: " . $_GET['name'] . "
" . $buginfo;
message_send("elten", "pajper", "Zgłoszenie błędu", $body);
echo "0\r\n" . $_GET['buginfo'];
?>