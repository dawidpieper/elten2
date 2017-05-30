<?php
require("header.php");
$zapytanie = "UPDATE `messages` SET `read`=".Time()." WHERE `id`='".$_GET['id']."' and receiver='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
?>