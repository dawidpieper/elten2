<?php
require("init.php");
$q = mquery("SELECT `name`, `text` FROM `visitingcards`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$visitingcard = $wiersz[1];
}
}
if($suc == false) {
echo "0\r\n     ";
die;
}
echo "0\r\n" . $visitingcard;
?>