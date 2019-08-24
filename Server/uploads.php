<?php
require("header.php");
$q = mquery("SELECT `filename`, `file` FROM `uploads` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."' ORDER BY `filename`");
$ile=0;
$tekst = "";
while($wiersz = mysql_fetch_row($q)) {
$ile = $ile + 1;
$tekst.="\r\n".$wiersz[0]."\r\n".$wiersz[1];
}
echo "0\r\n".$ile.$tekst;
?>