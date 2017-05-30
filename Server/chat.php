<?php
require("header.php");
if($_GET['recv'] == 1) {
$fp = fopen("chat.txt","r");
$message = fread($fp,8192);
fclose($fp);
echo "0\r\n" . $message;
}
if($_GET['send'] == 1) {
$fp = fopen("chat.txt","w");
$message = $_GET['name'] . " : " . $_GET['text'];
fwrite($fp,$message);
fclose($fp);
echo "0";
}
?>