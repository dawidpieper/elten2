<?php
require("header.php");
$q = mquery("INSERT INTO `blogs` (owner, name) VALUES ('" . $_GET['name'] . "','" . mysql_real_escape_string($_GET['blogname']) . "')");
if($q == false) {
echo "-1";
die;
}
echo "0";
?>