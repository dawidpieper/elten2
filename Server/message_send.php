<?php
require("header.php");
$date = date("d.m.Y H:i");
$text = $_GET['text'];
if($_GET['buffer'] != null) {
$zapytanie = "SELECT `id`, `data`, `owner` FROM `buffers`";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\nbuf";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0] == $_GET['buffer'] and $wiersz[2] == $_GET['name'])
$text = $wiersz[1];
}
if($text == null) {
echo "-1\r\nnull";
die;
}
$text = mysql_escape_string($text);
}
if($_GET['audio']==1) {
if(strlen($_POST['data']) < 8) {
echo "-1";
die;
}
$filename=random_str(24);
$fp = fopen("audiomessages/".$filename,"w");
fwrite($fp,$_POST['data']);
fclose($fp);
$text="\004AUDIO\004/audiomessages/".$filename."\004AUDIO\004\r\n";
}
$zapytanie = "INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent) VALUES ('', '" . $_GET['name'] . "', '" . $_GET['to'] . "', '" . $_GET['subject'] . "', '" . $text . "', '" . $date . "',0,0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
?>