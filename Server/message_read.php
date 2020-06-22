<?php
require("header.php");
if(file_exists("cache/messages_".$_GET['name'].".dat")) unlink("cache/messages_".$_GET['name'].".dat");
$q = mquery("UPDATE `messages` SET `read`=".Time()." WHERE `id`='".(int)$_GET['id']."' and receiver='".$_GET['name']."'");
echo "0";
?>