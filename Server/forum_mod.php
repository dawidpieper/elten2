<?php
require("header.php");
$zapytanie = "SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['name']) {
$suc = true;
$name = $wiersz[0];
$tester = $wiersz[1];
$moderator = $wiersz[2];
$media_administrator = $wiersz[3];
$translator = $wiersz[4];
$developer = $wiersz[5];
}
}
if($suc == false) {
$name = $_GET['name'];
$tester = 0;
$moderator = 0;
$media_administrator = 0;
$translator = 0;
$developer = 0;
}
if($_GET['delete'] == 1) {
if($moderator == 0) {
echo "-3";
die;
}
$zapytanie = "DELETE FROM `forum_threads` WHERE `id`=" . $_GET['threadid'] . " AND `forum`='".$_GET['forumname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$zapytanie = "DELETE FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
if($_GET['delete'] == 2) {
if($moderator == 0) {
echo "-3";
die;
}
$zapytanie = "DELETE FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'] . " AND `id`=" . $_GET['postid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
if($_GET['edit'] == 1) {
$zapytanie = "SELECT `id`, `author` FROM `forum_posts` WHERE `thread`=".$_GET['threadid']."`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['postid']) {
$suc = true;
if($wiersz[1] != $_GET['name'] and $moderator == 0) {
echo "-3";
die;
}
}
}
if($suc == false) {
echo "-4";
die;
}
$post = "";
if($_GET['buffer'] == 0)
$post = $_GET['post'];
else {
$zapytanie = "SELECT `id`, `data`, `owner` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['buffer'] and $wiersz[2] == $_GET['name'])
$post = $wiersz[1];
}
if($post == null) {
echo "-1";
die;
}
$post = str_replace("\\","\\\\",$post);
$post = str_replace("'","\\'",$post);
}
if($post == "") {
echo "-1";
die;
}
$zapytanie = "UPDATE `forum_posts` SET `post`='".$post."' WHERE `thread`=".$_GET['threadid']." AND`id`='".$_GET['postid']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>