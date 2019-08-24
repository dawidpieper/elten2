<?php
require("init.php");
$q = mquery("SELECT `name` FROM `privileges` where moderator=1");
echo "0";
while ($wiersz = mysql_fetch_row($q)){
$name = $wiersz[0];
echo "\r\n" . $name;
}
?>