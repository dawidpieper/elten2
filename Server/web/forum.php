<?php
require("header.php");
if($_POST['post'] != NULL) {
$_POST['post'] = str_replace("\r\n","LINE",$_POST['post']);
$error = 0;
$zapytanie = "SELECT `id` FROM `forum_threads` WHERE `forum`='" . $_GET['forumname'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "Błąd bazy danych";
else
{
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['threadid'])
$suc = true;
}
$error = 0;
if($suc == false) {
$zapytanie = "SELECT `name`, `id` FROM `forums`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
$error = "-1";
echo "Błąd odczytu bazy danych!";
die;
}
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['forumname']) {
$name = $wiersz[0];
$id = $wiersz[1];
}
}
if($name == null) {
echo "Błąd odczytu bazy danych!";
die;
}
$zapytanie = "INSERT INTO `forum_threads` (id, forum, name, lastpostdate) VALUES (" . $_GET['threadid'] . ",'".$_GET['forumname']."','" . $_POST['threadname'] . "'," . Time() . ")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Wystąpił błąd bazy danych!";
die;
}
$zapytanie = "INSERT INTO `forum_read` (id, owner, forum, thread, posts) VALUES ('','".$_SESSION['login']."','" . $_GET['forumname'] . "','" . $_GET['threadid'] . "'," . 1 . ")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Krytyczny błąd bazy danych!";
die;
}
}
$zapytanie = "SELECT `name`, `id` FROM `forum_threads` WHERE `forum`='" . $_GET['forumname'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd bazy danych";
die;
}
while ($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[1] == $_GET['threadid']) {
$name = $wiersz[0];
$id = $wiersz[1];
}
}
$zapytanie = "UPDATE `forum_threads` SET `name`='" . $name . "', `lastpostdate`='" . time() . "' WHERE `forum`='".$_GET['forumname']."' AND `id`=" . $id;
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd bazy danych!!!";
die;
}
$post = $_POST['post'];
if($post == null) {
echo "Błąd danych!";
die;
}
}
$zapytanie = "INSERT INTO `forum_posts` (id, thread, author, date, post) VALUES ('',".$_GET['threadid'].",'" . $_SESSION['login'] . "','" . date("d.m.Y H:i") . "','" . $post . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd zapisu do bazy danych!";
die;
}
echo "Wpis został dodany.<br><br><br>";
}
if($_GET['forum'] == 0)
{
$zapytanie = "SELECT `name` FROM `forums`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "Błąd połączenia się z bazą danych";
else
{
$wiersze = 0;
$tekst = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$tekst .= "<a href=forum.php?forum=1&forumname=" . $wiersz[0] . ">" . $wiersz[0] . "</a><br>";
$wiersze = $wiersze + 1;
}
echo "Liczba dostępnych forów: " . $wiersze . "<br>Kliknij forum, które chcesz otworzyć:<br>" . $tekst;
}
}
if($_GET['forum'] == 1)
{
$zapytanie = "SELECT `id`, `name` FROM `forum_threads` WHERE `forum`='" . $_GET['forumname'] . "' ORDER BY `lastpostdate` DESC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "Błąd połączenia się z bazą danych.";
else
{
$wiersze = 0;
$tekst = "";
$maxid = 0;
while ($wiersz = mysql_fetch_row($idzapytania)){
$tekst .= "<h3><a href=\"forum.php?forum=2&threadid=" . $wiersz[0]."\">" . $wiersz[1] . "</a></h3>";
$wzapytanie = "SELECT `id`, `date`, `author`, `post` FROM `forum_posts` WHERE `thread`=".$wiersz[0];
$widzapytania = mysql_query($wzapytanie);
if($widzapytania == false) {
echo "BŁĄD";
die;
}
$wwiersz = mysql_fetch_row($widzapytania);
$wwiersz[3] = htmlspecialchars($wwiersz[3]);
$wwiersz[3] = str_replace("LINE","<br>",$wwiersz[3]);
$tekst .= "Rozpoczęty przez: ".$wwiersz[2]."; wpisy: ".mysql_num_rows($widzapytania)."<br>".$wwiersz[3]."<br>";
$wiersze = $wiersze + 1;
if($maxid < $wiersz[0])
$maxid = $wiersz[0];
}
echo "<a href=forum.php?>Forum</a>\\".$_GET['forumname']."<br>";
echo "Wątki: " . $wiersze . "<br>Kliknij wątek, który chcesz przeczytać:<br>" . $tekst . "<br>";
$maxid = mysql_fetch_row(mysql_query("SELECT `id` FROM `forum_threads` ORDER BY `id` DESC"))[0];
if($_SESSION['login'] != NULL)
echo "<h3>Nowy temat</h3><form action=forum.php?forum=".$_GET['forum']."&forumname=".$_GET['forumname']."&threadid=".($maxid+1)." method=POST><label for=threadname>Tytuł wątku:</label><br><input id=threadname name=threadname><br><label for=post>Treść pierwszego wpisu:</label><br><textarea id=post name=post cols=100 rows=20></textarea><input type=submit value=Dodaj></form>";
}
}
if($_GET['forum'] == 2)
{
$zapytanie = "SELECT `id`, `author`, `date`, `post` FROM `forum_posts` WHERE `thread`=" . $_GET['threadid'];
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "Brak uprawnień!";
else
{
$wiersze = 0;
$tekst = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
if($_GET['nb'] == 0)
$wiersz[3] = htmlspecialchars($wiersz[3]);
$wiersz[3] = str_replace("LINE","<br>",$wiersz[3]);
$tekst .= "<h3>" . $wiersz[1] . "</h3>" . $wiersz[3] . "<br>" . $wiersz[2] . "<br>";
$wiersze = $wiersze + 1;
}
if($_GET['nb'] == 0 and $_SESSION['login'] != null) {
$zapytanie = "SELECT `forum`, `thread` FROM `forum_read` WHERE `owner`='" . $_SESSION['login'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd połączenia się z bazą danych.";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_GET['forumname'] and $wiersz[1] == $_GET['threadid']) {
$suc = true;
}
}
if($suc == true) {
$zapytanie = "DELETE FROM `forum_read` WHERE `owner`='" . $_SESSION['login'] . "' AND `forum`='" . $_GET['forumname'] . "' AND `thread`='" . $_GET['threadid'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd połączenia się z bazą danych.";
die;
}
}
$zapytanie = "INSERT INTO `forum_read` (id, owner, forum, thread, posts) VALUES ('','".$_SESSION['login']."','" . $_GET['forumname'] . "','" . $_GET['threadid'] . "'," . $wiersze . ")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd połączenia się z bazą danych.";
die;
}
}
$zapytanie = "SELECT `id`, `name`, `forum` FROM `forum_threads`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd podczas odpytywania bazy danych!";
die;
}
$threadname = "";
$forumname = "";
while($wiersz=mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['threadid']) {
$threadname = $wiersz[1];
$forumname = $wiersz[2];
}
}
echo "<a href=forum.php?>Forum</a>\\<a href=forum.php?forum=1&forumname=".$forumname.">".$forumname."</a>\\".$threadname."<br>";
echo "Liczba wpisów: " . $wiersze . "<br>" . $tekst . "<br>";
if($_SESSION['login'] != NULL)
echo "<h3>Nowy wpis</h3><form action=forum.php?forum=".$_GET['forum']."&forumname=".$_GET['forumname']."&threadid=".$_GET['threadid']." method=POST><label for=post>Treść wpisu:</label><br><textarea for=post name=post cols=100 rows=20></textarea><input type=submit value=Dodaj></form>";
}
}
require("footer.php");
?>