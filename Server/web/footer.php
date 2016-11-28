<?php
if($_SESSION['login'] != NULL) {
$zapytanie = "SELECT `name`, `date` FROM `actived`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd!";
die;
}
$suc = false;
while ($wiersz = mysql_fetch_row($idzapytania)){
if($wiersz[0] == $_SESSION['login']) {
$name = $wiersz[0];
$date_t = $wiersz[1];
$suc = true;
}
}
if($suc == false) {
$zapytanie = "INSERT INTO `actived` (name, date) VALUES ('" . $_SESSION['login'] . "','" . time() . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "błąd\r\n" . $zapytanie;
die;
}
}
else {
$zapytanie = "UPDATE `actived` SET `name` = '" . $_SESSION['login'] . "', `date` ='" . time() . "'  WHERE `name`='" . $_SESSION['login'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "błąd\r\n" . $zapytanie;
die;
}
}
}
echo "<br>";
echo "
<h1>Menu</h1>
<a href=forum.php?".SID.">Forum</a><br>
<a href=messages.php?".SID.">Wiadomości</a><br>
";
echo "
<div id=\"update\">
</div>
";
if($_SESSION['noads'] == NULL)
echo '<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- elten -->
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-5150103439381094"
     data-ad-slot="6718381563"
     data-ad-format="auto"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>';
echo "<br></body><foot>Copyright Dawid Pieper</body></html>";

//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>