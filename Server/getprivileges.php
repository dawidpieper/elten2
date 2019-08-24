<?php
require("header.php");
$q = mquery("SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$name = $wiersz[0];
$tester = $wiersz[1];
$moderator = $wiersz[2];
$media_administrator = $wiersz[3];
$translator = $wiersz[4];
$developer = $wiersz[5];
}
}
if($suc == false) {
echo "0\r\n0\r\n0\r\n0\r\n0\r\n0";
die;
}
echo "0\r\n" . $tester . "\r\n" . $moderator . "\r\n" . $media_administrator . "\r\n" . $translator . "\r\n" . $developer;
?>