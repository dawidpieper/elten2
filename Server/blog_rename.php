<?php
require("header.php");
$zapytanie = "update `blogs` set name='" . $_GET['blogname'] . "' where `owner`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
?>