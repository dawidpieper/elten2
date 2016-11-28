<?php
require("header.php");
if($_GET['get'] == 1) {
$zapytanie = "SELECT `player`, `chessboard`, `id`, `color` FROM `chess`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$t = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[2] == $_GET['id']) {
$t = "0\r\n".$wiersz[0]."\r\n".$wiersz[3]."\r\n".$wiersz[1];
}
}
echo $t;
}
if($_GET['set'] == 1) {
$opponent = "";
$zapytanie = "SELECT `player`, `chessboard`, `id`, `player1`, `player2`, `color` FROM `chess`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
$color = 0;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[2] == $_GET['id'])
if($wiersz[0] == $_GET['name']) {
$suc = true;
$color = $wiersz[5];
if($wiersz[3] == $_GET['name'])
$opponent = $wiersz[4];
else
$opponent = $wiersz[3];
}
}
if($suc == true) {
$newcolor = 0;
if($color == 1)
$newcolor = -1;
else
$newcolor = 1;
$zapytanie = "UPDATE `chess` SET `player`='".$opponent."', `color`=".$newcolor.", `chessboard`='".$_GET['chessboard']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
else {
echo "-3";
die;
}
}
if($_GET['new'] == 1) {
$zapytanie = "INSERT INTO `chess` (`id`, `player1`, `player2`, `player`, `color`, `chessboard`) VALUES (".$_GET['id'].",'".$_GET['name']."','".$_GET['opponent']."','".$_GET['name']."',1,'".$_GET['chessboard']."')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>