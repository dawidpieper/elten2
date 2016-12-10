<?php
require("init.php");
foreach($_GET as $value) {
$value = str_replace("\\","\\\\",$value);
$value = str_replace("\'","\\\'",$value);
}
foreach($_POST as $value) {
$value = str_replace("\\","\\\\",$value);
$value = str_replace("\'","\\\'",$value);
}
$name = $_SESSION['login'];
echo "
<html>
<head>
";
if($_GET['title'] != NULL)
echo "<title>".$_GET['title']." - Elten Network</title>";
else
echo "<title>Elten Network</title>";
echo "
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf8\" />
";
if($_GET['title'] != NULL)
echo "<h1>".$_GET['title']." - <a href=http://elten-net.eu>ELTEN NETWORK</a></h1>";
else
echo "<h1><a href=http://elten-net.eu>ELTEN NETWORK</a></h1>";
echo "
<script src=\"http://code.jquery.com/jquery-latest.js\"></script>
<script type=\"text/javascript\">
setInterval(\"autoupdater();\",1000);
function autoupdater(){
$('#update').load('updater.php #refresh');
}
</script>
<script language=\"JavaScript\">
function toggle(obj) {
	var el = document.getElementById(obj);
	if ( el.style.display != 'none' ) {
		el.style.display = 'none';
	}
	else {
		el.style.display = '';
	}
}
</script>
";
if($name != NULL) {
$zapytanie = "SELECT `token`, `name`, `time` FROM `tokens`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd połączenia się z bazą danych.";
die;
}
else
{
$error = "Błąd połączenia się z bazą danych.";
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_SESSION['token']) {
if($wiersz[2] == date("d")) {
if($wiersz[1] == $name) {
$error = "0";
$suc = true;
}
else {
$error = "Klucz sesji: " . $_SESSION['token'] . " dla użytkownika " . $name . " wygasł, <a href=login.php>zaloguj się ponownie</a>.";
$_SESSION['login'] = NULL;
}
}
else {
$error = "Klucz sesji: " . $_SESSION['token'] . " dla użytkownika " . $name . " wygasł, <a href=login.php>zaloguj się ponownie</a>.";
$_SESSION['login'] = null;
}
}
else {
$error = "Klucz sesji: " . $_SESSION['token'] . " dla użytkownika " . $name . " wygasł, <a href=login.php>zaloguj się ponownie</a>.";
$_SESSION['login'] = null;
}
}
if($suc == false) {
echo $error;
die;
}
$_SESSION['login'] = $name;
}
}
$name = $_SESSION['login'];
if($name != NULL)
echo "<h2>Zalogowany jako: " . $name . "</h2><a href=logout.php>(Wyloguj się)</a>";
else
echo "<h2>Zalogowany jako: gość</h2><a href=login.php>(Zaloguj się)</a>";
echo "<br>";
echo "
</head>
<body>
";
?>