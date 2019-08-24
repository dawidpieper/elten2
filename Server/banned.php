<?php
require("header.php");
$error = 0;
$q = mquery("SELECT `name`, `todate` FROM `banned`");
echo "0";
while ($wiersz = mysql_fetch_row($q)){
$name = $wiersz[0];
$date = $wiersz[1];
if($date > $cdate) {
echo "\r\n" . $name;
}
}
?>