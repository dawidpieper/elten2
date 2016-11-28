<?php
require("header.php");
$zapytanie = "SELECT `forum`, `thread`, `posts` FROM `forum_read` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$posts = 0;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[1] == $_GET['threadid'])
$posts = $wiersz[2];
}
echo "0\r\n" . $posts;
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>