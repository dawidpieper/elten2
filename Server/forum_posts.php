<?php
require("header.php");
if($_GET['cat'] == 0) {
$zapytanie = "SELECT `name` FROM `forums`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$tekst = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
$tekst .= "\r\n" . $wiersz[0] . "\r\n";
$zapytanie2 = "SELECT `id` FROM `forum_threads` WHERE `forum`='" . $wiersz[0] . "'";
$idzapytania2 = mysql_query($zapytanie2);
if($idzapytania2 == false) {
echo "-1\r\n".$zapytanie2;
die;
}
$tekst .= mysql_num_rows($idzapytania2);
$tekst .= "\r\n";
$zapytanie2 = "SELECT `id` FROM `forum_threads` WHERE `forum`='".$wiersz[0]."'";
$idzapytania2 = mysql_query($zapytanie2);
if($idzapytania2 == false) {
echo "-1\r\n".$zapytanie2;
die;
}
$posts = 0;
while($wiersz2 = mysql_fetch_row($idzapytania2)) {
$zapytanie3 = "SELECT `id` FROM `forum_posts` WHERE `thread`=".$wiersz2[0];
$idzapytania3 = mysql_query($zapytanie3);
if($idzapytania3 == false) {
echo "-1\r\n".$zapytanie3;
die;
}
$posts = $posts + mysql_num_rows($idzapytania3);
}
$tekst .= $posts;
}
echo "0" . $tekst;
}
if($_GET['cat'] == 1) {
$forumname = NULL;
$forumname = $_GET['forumname'];
if($forumname != NULL)
$zapytanie = "SELECT `id` FROM `forum_threads` WHERE `forum`='" . $_GET['forumname'] . "' ORDER BY `lastpostdate` DESC";
else
$zapytanie = "SELECT `id` FROM `forum_threads` WHERE `id` in (SELECT `thread` FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "') ORDER BY `lastpostdate` DESC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$tekst = "";
while($wiersz = mysql_fetch_row($idzapytania)) {
$tekst .= "\r\n" . $wiersz[0] . "\r\n";
$zapytanie2 = "SELECT `id` FROM `forum_posts` WHERE `thread`=" . $wiersz[0];
$idzapytania2 = mysql_query($zapytanie2);
if($idzapytania2 == false) {
echo "-1";
die;
}
$tekst .= mysql_num_rows($idzapytania2);
}
echo "0" . $tekst;
}
if($_GET['cat'] == 2) {
$zapytanie = "SELECT `forum`, `thread`, `posts` FROM `forum_read` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$posts = 0;
$tekst = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$tekst .= "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2];
}
echo "0" . $tekst;
}
if($_GET['cat'] == 3) {
$zapytanie = "SELECT `id` FROM `forum_posts` WHERE `author`='".$_GET['searchname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0\r\n".mysql_num_rows($idzapytania);
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>