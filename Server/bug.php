<?php
require("init.php");
$buginfo = $_GET['buginfo'];
if($_GET['buffer'] != null)
$buginfo=buffer_get($_GET['buffer']);
if(strlen($buginfo)>32768) die("-1");
$buginfo = str_replace("LINE","\n",$buginfo);
$body="{$_GET['name']}, {$_SERVER['REMOTE_ADDR']}
" . $buginfo;
message_send("elten", "pajper", "Zgłoszenie błędu", $body);
echo "0\r\n" . $_GET['buginfo'];
?>