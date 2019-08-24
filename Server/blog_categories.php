<?php
require("init.php");
$q = mquery("SELECT `id`, `name` FROM `blog_categories` WHERE `owner`='" . mysql_real_escape_string($_GET['searchname']) . "'");
$wiersze = 0;
$text = "";
while ($wiersz = mysql_fetch_row($q)){
$wiersze += 1;
$text .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n";
}
echo "0\r\n" . $wiersze . "\r\n" . $text;
?>