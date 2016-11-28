<?php
require("header.php");
$zapytanie = "SELECT `name`, `messages`, `posts`, `blogposts` FROM `whatsnew`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['name']) {
$name = $wiersz[0];
$messages = $wiersz[1];
$posts = $wiersz[2];
$blogposts = $wiersz[3];
$suc = true;
}
}
if($suc == false) {
$zapytanie = "INSERT INTO `whatsnew` (name, messages, posts, blogposts) VALUES ('" . $_GET['name'] . "',0,0,0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$name = $_GET['name'];
$messages = 0;
$posts = 0;
$blogposts = 0;
}
if($_GET['get'] == 1) {
$zapytanie = "SELECT * FROM `messages` WHERE `deletedfromreceived`=0 and `receiver`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$emessages = mysql_num_rows($idzapytania);
$eposts = 0;
$zapytanie = "SELECT `id`, `forum`, `thread` FROM `followedthreads` WHERE `owner`='".$_GET['name']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
$wzapytanie = "SELECT `id` FROM `forum_posts` WHERE `thread`=".$wiersz[2];
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1\r\n".$wzapytanie;
die;
}
$eposts = $eposts + mysql_num_rows($widzapytania);
$wzapytanie = "SELECT `posts` FROM `forum_read` WHERE `owner`='".$_GET['name']."' AND `thread`='".$wiersz[2]."'";
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$wwiersz = mysql_fetch_row($widzapytania);
$eposts = $eposts - $wwiersz[0];
}
$zapytanie = "SELECT `author` FROM `followedblogs` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if ($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
$eblogposts = 0;
while ($wiersz = mysql_fetch_row($idzapytania)) {
$wzapytanie = "SELECT `postid` from `blog_assigning` WHERE `owner`='".$wiersz[0]."'";
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "-1\r\n".$wzapytanie;
die;
}
while($wwiersz = mysql_fetch_row($widzapytania)) {
$wwzapytanie = "SELECT `postid`, `name` FROM `blog_posts` WHERE `owner`='".$wiersz[0]."' AND `postid`=".$wwiersz[0];
$wwidzapytania = mysql_query($wwzapytanie);
if($wwidzapytania == false) {
echo "-1\r\n".$wwzapytanie;
die;
}
while($wwwiersz = mysql_fetch_row($wwidzapytania)) {
$wwwwzapytanie = "SELECT `id` FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".$wiersz[0]."' AND `post`=".$wwwiersz[0];
$wwwwidzapytania = mysql_query($wwwwzapytanie);
if($wwwwidzapytania == false) {
echo "-1";
die;
}
if(mysql_num_rows($wwwwidzapytania) == 0) {
$eblogposts = $eblogposts + 1;
}
}
}
}
$nblogposts = $eblogposts - $blogposts;
$nposts = $eposts - $posts;
$nmessages = $emessages - $messages;
echo "0\r\n" . $nmessages . "\r\n" . $nposts . "\r\n" . $nblogposts;
}
if($_GET['set'] == 1) {
$nmessages = $_GET['messages'];
$nposts = $_GET['posts'];
if($_GET['blogposts'] != NULL)
$nblogposts = $_GET['blogposts'];
else
$nblogposts = -1;
if($nposts == -1)
$nposts = $posts;
if($nmessages == -1)
$nmessages = $messages;
if($nblogposts == -1)
$nblogposts = $blogposts;
$zapytanie = "UPDATE `whatsnew` SET `messages`=".$nmessages.", `posts`=".$nposts.", `blogposts`=".$nblogposts." WHERE `name`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n".$zapytanie;
die;
}
echo "0";
}
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>