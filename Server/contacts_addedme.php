<?php
require("header.php");
$error = 0;
$qr="SELECT `owner` FROM `contacts` WHERE `user`='".$_GET['name']."' ";
if($_GET['new']>=1)
$qr.=" and noticed is null ";
$qr.=" ORDER BY `owner` ASC";
$q = mquery($qr);
echo "0";
while ($wiersz = mysql_fetch_row($q)){
$name = $wiersz[0];
echo "\r\n" . $name;
}
if($_GET['new']==2)
mquery("update contacts set noticed=".time()." where user='".$_GET['name']."'");
?>