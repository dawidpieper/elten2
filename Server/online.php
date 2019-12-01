<?php
require("init.php");
$period=90;
if($_GET['period']!=NULL)
$period=$_GET['period'];
$error = 0;
$qt = "SELECT `name`, `date` FROM `actived`";
if($period==90)
$qt.=" ORDER BY `name` COLLATE utf8_polish_ci";
else
$qt.=" ORDER BY `date` DESC";
$q = mysql_query($qt);
if($q == false) {
echo "-1\r\n" . $qt;
die;
}
echo "0";
while ($wiersz = mysql_fetch_row($q)){
$name = $wiersz[0];
$date = $wiersz[1];
if($date + $period >= $cdate) {
echo "\r\n" . $name;
}
}
?>