<?php
if($_GET['name']=="guest" and $_GET['token']=="guest")
die("0\r\n".time());
require("header.php");
mquery("INSERT INTO `actived` (name, date) VALUES ('" . $_GET['name'] . "','" . $cdate . "') ON DUPLICATE KEY UPDATE name=VALUES(name),date=VALUES(DATE)");
echo "0\r\n".time();
?>