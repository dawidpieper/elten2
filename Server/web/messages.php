<?php
require("header.php");
if($_POST['delete'] == 1) {
$zapytanie = "DELETE FROM `messages` WHERE id=" . $_POST['id']." and `receiver`='".$_SESSION['login']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd!";
die;
}
echo "Wiadomość została usunięta!<br>";
}
if($_POST['text'] != NULL) {
$date = date("d.m.Y H:i");
$text = $_POST['text'];
$text = str_replace("\r\n","LINE",$text);
$zapytanie = "INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`,`deletedfromreceived`,`deletedfromsent`) VALUES ('', '" . $_SESSION['login'] . "', '" . $_POST['to'] . "', '" . $_POST['subject'] . "', '" . $text . "', '" . $date . "',0,0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd!";
die;
}
echo "Wiadomość zostałą wysłana.<br>";
}
if($_SESSION['login'] != NULL) {
$date = date("d.m.Y H:i");
$zapytanie = "SELECT `id`, `sender`, `subject`, `message`, `date` FROM `messages` where `receiver`='" . $_SESSION['login'] . "' ORDER BY `id` DESC";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd połączenia z bazą danych!";
die;
}
$ile = 0;
$messages = "";
while ($wiersz = mysql_fetch_row($idzapytania)){
$ile = $ile + 1;
$suc = false;
$wiersz[3] = str_replace("LINE","<br>",$wiersz[3]);
$messages .= "<h3>".$wiersz[2]." od ".$wiersz[1]." <form action=messages.php method=POST>(<input type=hidden name=delete value=1><input type=hidden name=id value=".$wiersz[0]."><input type=submit value=Usuń>)</form></h3>".$wiersz[3]."<br>".$wiersz[4];
}
$zapytanie = "SELECT `name`, `messages`, `posts` FROM `whatsnew`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_SESSION['login']) {
$name = $wiersz[0];
$wmessages = $wiersz[1];
$posts = $wiersz[2];
$suc = true;
}
}
if($suc == false) {
$zapytanie = "INSERT INTO `whatsnew` (name, messages, posts) VALUES ('" . $_SESSION['login'] . "',0,0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd";
die;
}
$name = $_SESSION['login'];
$wmessages = 0;
$posts = 0;
}
$nmessages = $ile;
$nposts = -1;
if($nposts == -1)
$nposts = $posts;
if($nmessages == -1)
$nmessages = $wmessages;
$zapytanie = "UPDATE `whatsnew` SET `messages`=" . $nmessages . ", `posts`=" . $nposts . " WHERE `name`='" . $_SESSION['login'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd";
die;
}
echo "<h2>Wiadomości</h2>
".$messages."
";
echo "
<h3>Napisz wiadomość</h3>
<form action=messages.php method=POST>
<label for=to>Odbiorca:</label><br>
<input id=to name=to><br>
<label for=subject>Temat:</label><br>
<input id=subject name=subject><br>
<label for=text>Treść:</label>
<textarea rows=20 cols=100 id=text name=text></textarea><br>
<input type=submit value=Wyślij>
</form>
<br>
";
}
else {
echo "Musisz się <a href=login.php>zalogować</a>, aby korzystać z tej funkcji.<br>";
}
require("footer.php");
?>