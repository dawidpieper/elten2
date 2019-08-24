<?php
require("header.php");
if($_GET['ac'] == 1) {
$q = mquery("SELECT `id` FROM `buffers`");
$suc = false;
while($wiersz = mysql_fetch_row($q)) {
if($wiersz[0] == $_GET['id']){
$suc = true;
}
}
if($suc == true) {
sleep(1);
mquery("DELETE FROM `buffers` WHERE `id`='" . (int)$_GET['id'] . "'");
}
mquery("INSERT INTO `buffers` (id, data, owner, date) VALUES ('" . (int)$_GET['id'] . "', '" . mysql_real_escape_string($_GET['data']) . "','" . $_GET['name'] . "',".time().")");
}
if($_GET['ac'] == 2) {
$q = mquery("SELECT `id`, `data`, `owner` FROM `buffers`");
$suc = false;
$data = "";
while($wiersz = mysql_fetch_row($q)) {
if($wiersz[0] == $_GET['id']){
$suc = true;
$data = $wiersz[1];
$owner = $wiersz[2];
}
}
if($suc == false) {
echo "-1\r\n" . $zapytanie;
die;
}
if($owner == $_GET['name']) {
mquery("DELETE FROM `buffers` WHERE `id`='" . (int)$_GET['id'] . "'");
mquery("INSERT INTO `buffers` (id, data, owner, date) VALUES ('" . (int)$_GET['id'] . "', '" . mysql_real_escape_string($data . $_GET['data']) . "','" . $_GET['name'] . "',".time().")");
}
else {
echo "-2";
die;
}
}
echo "0";
?>