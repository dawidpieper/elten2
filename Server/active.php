<?php
if($_GET['name']=="guest" and $_GET['token']=="guest")
die("0\r\n".time());
require("header.php");
mquery("INSERT INTO `actived` (name, date, shown, actived) VALUES ('" . $_GET['name'] . "','" . time() . "', ".(int)$shown.",1) ON DUPLICATE KEY UPDATE name=VALUES(name),date=VALUES(DATE),shown=VALUES(shown),actived=values(actived)");
echo "0\r\n".time();
?>