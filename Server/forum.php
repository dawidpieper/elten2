<?php
require("header.php");
$error = 0;
if($_GET['forum'] == 0)
{
$zapytanie = "SELECT `name` FROM `forums`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1";
else
{
$wiersze = 0;
$tekst = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$tekst .= $wiersz[0] . "\r\n";
$wiersze = $wiersze + 1;
}
echo "0\r\n" . $wiersze . "\r\n" . $tekst;
}
}
if($_GET['forum'] == 1)
{
$forumname = NULL;
$forumname = $_GET['forumname'];
if($forumname != NULL)
$zapytanie = "SELECT `id`, `name` FROM `forum_threads` WHERE `forum`='".$_GET['forumname']."' ORDER BY `lastpostdate` DESC";
else
$zapytanie = "SELECT `id`, `name` FROM `forum_threads` WHERE `id` in (SELECT `thread` FROM `followedthreads` WHERE `owner`='".$_GET['name']."')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1";
else
{
$wiersze = 0;
$tekst = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$tekst .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n";
$wiersze = $wiersze + 1;
}
echo "0\r\n" . $wiersze . "\r\n" . $tekst;
}
}
if($_GET['forum'] == 2)
{
$zapytanie = "SELECT `id`, `author`, `date`, `post` FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-4";
else
{
$wiersze = 0;
$tekst = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
if($_GET['nb'] == 0)
$tekst .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[3] . "\r\n";
$wzapytanie = "SELECT `name`, `signature` FROM `signatures` WHERE `name`='".$wiersz[1]."'";
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1";
die;
}
if(mysql_num_rows($widzapytania) > 0)
$tekst .= mysql_fetch_row($widzapytania)[1]."\r\n";
$tekst .= "\r\n".$wiersz[2]."\r\n"."END\r\n";
$wiersze = $wiersze + 1;
}
if($_GET['nb'] == 0) {
$zapytanie = "SELECT `thread` FROM `forum_read` where `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['threadid']) {
$suc = true;
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `forum_read` where `owner`='" . $_GET['name'] . "' AND `thread`='" . $_GET['threadid'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
$zapytanie = "INSERT INTO `forum_read` (id, owner, thread, posts) VALUES ('','".$_GET['name']."','" . $_GET['threadid'] . "'," . $wiersze . ")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
echo "0\r\n" . $wiersze . "\r\n" . $tekst;
}
if($_GET['forum'] == 3)
{
$zapytanie = "SELECT `id`, `author`, `date`, `post` FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-4";
else
{
$text = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['postid'])
$text = $wiersz[3] . "\r\n" . $wiersz[1] . "\r\n" . $wiersz[2];
}
}
echo "0\r\n" . $text;
}
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>