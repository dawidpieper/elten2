<?php
require("header.php");
$error = 0;
$q = mquery("SELECT `name`, `date` FROM `chat_actived` ORDER BY `name`");
echo "0";
while ($wiersz = mysql_fetch_row($q)){
$name = $wiersz[0];
$date = $wiersz[1];
if($date + 5 >= $cdate) {
echo "\r\n" . $name;
}
}
?>