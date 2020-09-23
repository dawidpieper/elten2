<?php
require("init.php");
$q = mquery("SELECT `name`, `status` FROM `statuses`");
$suc = false;
$text = "";
while ($wiersz = mysql_fetch_row($q)){
$text .= "\r\n" . $wiersz[0] . "\r\n" . $wiersz[1] . "\r\nEND";
}
echo "0" . $text;
?>