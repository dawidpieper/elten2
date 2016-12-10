<?php
require("header.php");
if($_SESSION['login'] != NULL) {
$zapytanie = "SELECT `name`, `date` FROM `actived`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "B³¹d!";
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
echo "-1\r\n" . $zapytanie;
die;
}
}
else {
$zapytanie = "UPDATE `actived` SET `name` = '" . $_SESSION['login'] . "', `date` ='" . time() . "'  WHERE `name`='" . $_SESSION['login'] . "'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
}
}
?>
<?php
echo "
<div id=\"refresh\">
".date("H:i:s")."
</div>
";
require("footer.php");
?>