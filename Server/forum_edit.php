<?php
require("header.php");
$zapytanie = "SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$suc = false;
if($_GET['forumname']=="") {
$suc=true;
$zapytanie = "UPDATE `forum_threads` SET `lastpostdate` = '" . time() . "' WHERE `id`=" . $_GET['threadid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
if($_GET['buffer'] == 0)
if($_GET['audio']==0)
$post = $_GET['post'];
else {
if(strlen($_POST['post']) < 8) {
echo "-1";
die;
}
$min=6;
$max=24;
srand((double)microtime()*1000000);
for($i=0;$i<rand($min,$max);$i++) {
$znak=chr(rand(48,122));
if (eregi("[0-9a-zA-Z]",$znak)) $haslo .= $znak;
else $i--;
}
$filename=$haslo;
$fp = fopen("audioforums/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
$post="\004AUDIO\004/audioforums/posts/".$filename."\004AUDIO\004\r\n";
}
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
$zapytanie = "INSERT INTO `forum_posts` (id, thread, author, date, post) VALUES ('','" . $_GET['threadid'] . "','" . $_GET['name'] . "','" . date("d.m.Y H:i") . "','" . $post . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$zapytanie = "UPDATE `cache` SET `expiredate`=".time();
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
die;
}
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
$error = 0;
$zapytanie = "SELECT `id` FROM `forum_threads` WHERE `forum`='".$_GET['forumname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "-1\r\n" . $zapytanie;
else
{
$suc = false;
$threadid = $_GET['threadid'];
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['threadid'])
$suc = true;
}
$error = 0;
if($suc == false) {
$zapytanie = "SELECT `id` FROM `forum_threads` ORDER BY `id` DESC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania==false) {
echo "-1\r\n".$zapytanie;
die;
}
$threadid = mysql_fetch_row($idzapytania)[0]+1;
$zapytanie = "SELECT `name`, `id` FROM `forums`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
$error = "-1";
$error = -1;
echo $error . "\r\n" . $zapytanie;
die;
}
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['forumname']) {
$name = $wiersz[0];
$id = $wiersz[1];
}
}
if($name == null) {
echo "-1";
die;
}
if($_GET['audio']==0)
$threadname = $_GET['threadname'];
else {
if(strlen($_POST['threadname']) < 8) {
echo "-1";
die;
}
$min=6;
$max=24;
srand((double)microtime()*1000000);
for($i=0;$i<rand($min,$max);$i++) {
$znak=chr(rand(48,122));
if (eregi("[0-9a-zA-Z]",$znak)) $haslo .= $znak;
else $i--;
}
$filename=$haslo;
$fp = fopen("audioforums/titles/".$filename,"w");
fwrite($fp,$_POST['threadname']);
fclose($fp);
$threadname="\004AUDIO\004/audioforums/titles/".$filename."\004AUDIO\004";
}
$zapytanie = "INSERT INTO `forum_threads` (id, name, lastpostdate, forum) VALUES ('" . $threadid . "','" . $threadname . "'," . Time() . ",'".$_GET['forumname']."')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$zapytanie = "INSERT INTO `forum_read` (id, owner, forum, thread, posts) VALUES ('','".$_GET['name']."','" . $_GET['forumname'] . "','" . $_GET['threadid'] . "'," . 1 . ")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
$posts = 0;
$zapytanie = "SELECT `thread`, `posts` FROM `forum_read` WHERE `owner`='" . $_GET['name'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['threadid']) {
$suc = true;
$posts = $wiersz[2] + 1;
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `forum_read` where `owner`='" . $_GET['name'] . "' AND `thread`='" . $_GET['threadid'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
$zapytanie = "INSERT INTO `forum_read` (id, owner, thread, posts) VALUES ('','".$_GET['name']."','" . $_GET['threadid'] . "'," . $posts . ")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
else
$posts = 1;
}
else {
$zapytanie = "UPDATE `forum_read` SET `posts`=".$posts." WHERE `owner`='".$_GET['name']."' AND `thread`='".$_GET['threadid']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
}
$zapytanie = "SELECT `name`, `id` FROM `forum_threads` WHERE `forum`='" . $_GET['forumname'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
while ($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[1] == $threadid) {
$name = $wiersz[0];
$id = $wiersz[1];
}
}
$zapytanie = "UPDATE `forum_threads` SET `name` = '" . $name . "', `lastpostdate` = '" . time() . "' WHERE `id`=" . $id;
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
if($_GET['buffer'] == 0)
if($_GET['audio']==0)
$post = $_GET['post'];
else {
if(strlen($_POST['post']) < 8) {
echo "-1";
die;
}
$min=6;
$max=24;
srand((double)microtime()*1000000);
for($i=0;$i<rand($min,$max);$i++) {
$znak=chr(rand(48,122));
if (eregi("[0-9a-zA-Z]",$znak)) $haslo .= $znak;
else $i--;
}
$filename=$haslo;
$fp = fopen("audioforums/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
$post="\004AUDIO\004/audioforums/posts/".$filename."\004AUDIO\004\r\n";
}
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
$asname = $_GET['name'];
if(($_GET['uselore'] == 1 and $_GET['lore'] != NULL) and ($moderator == 1 or $developer == 1))
$asname .= "".$_GET['lore'];
$zapytanie = "INSERT INTO `forum_posts` (id, thread, author, date, post) VALUES ('','" . $threadid . "','" . $asname . "','" . date("d.m.Y H:i") . "','" . $post . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
$zapytanie = "UPDATE `cache` SET `expiredate`=".time()." WHERE id=0 OR forumname='".$_GET['forumname']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
echo "0";
}
?>