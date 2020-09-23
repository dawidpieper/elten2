<?php
require("header.php");
$q = mquery("SELECT `id` FROM `buffers`");
$suc = false;
while($wiersz = mysql_fetch_row($q))
if($wiersz[0] == $_GET['id'])
$suc = true;
if($suc == true) {
sleep(1);
mquery("DELETE FROM `buffers` WHERE `id`='" . (int)$_GET['id'] . "'");
}
mquery("INSERT INTO `buffers` (id, data, owner, date) VALUES ('" . (int)$_GET['id'] . "', '" . mysql_real_escape_string(($_POST['data'])) . "','" . $_GET['name'] . "',".time().")");
echo "0\r\n".strlen($_POST['data']);
?>