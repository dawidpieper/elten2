<?php
require("header.php");
if(file_exists("cache/messages_".$_GET['name'].".dat")) unlink("cache/messages_".$_GET['name'].".dat");
$date = date("d.m.Y H:i");
$q = mquery("SELECT `id`, `sender`, `receiver`, `subject`, `message`, `date` FROM `messages` where `receiver`='" . $_GET['name'] . "'");
if($_GET['delete'] == 1) {
mquery("UPDATE `messages` SET `deletedfromreceived`=1 WHERE id=" . (int)$_GET['id']." and receiver='".$_GET['name']."'");
echo "0";
}
?>