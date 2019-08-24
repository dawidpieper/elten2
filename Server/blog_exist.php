<?php
require("init.php");
$q = mquery("SELECT `owner`, `name` FROM `blogs`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname'])
$suc = true;
}
echo "0\r\n";
if($suc == false)
echo "0";
else
echo "1";
?>