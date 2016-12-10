<?php
require("init.php");
if($_GET['login'] == "1")
{
$name = $_POST['login'];
$zapytanie = "SELECT `name`, `password` FROM `users`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "Błąd połączenia się z bazą danych...";
else
{
$error = "Błędny login lub hasło";
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_POST['login'])
if($wiersz[1] == $_POST['password'])
$error = "";
}
if($error != "")
echo $error;
else
{
$zapytanie = "SELECT `name`, `totime` FROM `banned`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd połączenia się z bazą danych.";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $name) {
$totime = $wiersz[1];
$suc = true;
}
}
if($suc == true) {
if($ctime < $totime) {
echo "Nie masz uprawnień do wykonania tej operacji.";
die;
}
}
$min=24;
$max=64;
srand((double)microtime()*1000000);
for($i=0;$i<rand($min,$max);$i++) {
$znak=chr(rand(48,122));
if (eregi("[0-9a-zA-Z]",$znak)) $haslo .= $znak;
else $i--;
};
$zapytanie = "INSERT INTO `tokens` (`token`, `name`, `time`) VALUES ('" . $haslo . "','" . $_POST['login'] . "', '" . date("d") . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false)
echo "Nie masz uprawnień do wykonania tej operacji.";
else
{
$_SESSION['login'] = $name;
$_SESSION['token'] = $haslo;
echo "Zostałeś zalogowany.<br>";
}
}
}
}
require("header.php");
if($_SESSION['login'] == null) {
echo "<h2>Logowanie</h2>";
echo "
Aby się zalogować, użyj poniższego formularza.<BR>
<form action=?login=1 method=\"POST\">
<label for=login>Login:</label>
<input id=login name=login><BR>
<label for=password>Hasło:</label>
<input id=password name=password type=password><BR>
<input type=submit value=\"Zaloguj się\">
</form>
";
}
require("footer.php")
?>