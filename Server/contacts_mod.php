<?php
require("header.php");
$error = 0;
if($_GET['delete'] == 1) {
$q = mquery("SELECT `id`,`user` FROM `contacts` where `owner`='" . $_GET['name'] . "'");
$suc = false;
$cid = 0;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[1] == $_GET['searchname']) {
$suc = true;
$cid = $wiersz[0];
}
}
if($suc == false) {
echo "-3";
die;
}
mquery("DELETE FROM `contacts` where id=" . $cid);
echo "0";
}
if($_GET['insert'] == 1) {
$q = mquery("SELECT `user` FROM `contacts` where owner='" . $_GET['name'] . "'");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$searchname = $wiersz[0];
}
}
if($suc == true) {
echo "-3";
die;
}
$searchname = $_GET['searchname'];
$q = mquery("INSERT INTO `contacts` (owner, user) values ('" . $_GET['name'] . "','" . mysql_real_escape_string($searchname) . "')");
if($q == false) {
echo "-1\r\n" . $zapytanie;
die;
}
echo "0";
}
if($_GET['delete'] == 0 and $_GET['insert'] == 0) {
$q = mquery("SELECT `user` FROM `contacts` WHERE owner='" . $_GET['name'] . "'");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname']) {
$suc = true;
$searchname = $wiersz[0];
}
}
if($suc == true) {
echo "-3";
die;
}
echo "0";
}
?>