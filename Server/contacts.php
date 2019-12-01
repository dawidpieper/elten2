<?php
require("header.php");
$qr="SELECT `user` FROM `contacts` WHERE `owner`='".$_GET['name']."' ";
if($_GET['birthday']>=1)
$qr.="and user in (select name from profiles where birthdateday=".(int) date("d")." and birthdatemonth=".date("m").")";
$qr.=" ORDER BY `user` COLLATE utf8_polish_ci";
$q=mquery($qr);
echo "0";
while ($wiersz = mysql_fetch_row($q)){
$name = $wiersz[0];
echo "\r\n" . $name;
}
if($_GET['birthday']==2)
mquery("update contacts set birthdaynotice=".date("Ymd")." where owner='".$_GET['name']."'");
?>