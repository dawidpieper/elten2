<?php
require("header.php");
if(!isset($_GET['shared']) or $_GET['shared']==0) {
mquery("INSERT INTO `blogs` (owner, name) VALUES ('" . $_GET['name'] . "','" . mysql_real_escape_string($_GET['blogname']) . "')");
echo "0";
}
else {
$blog="[".random_str(62)."]";
mquery("INSERT INTO `blogs` (owner, name) VALUES ('" . $blog . "','" . mysql_real_escape_string($_GET['blogname']) . "')");
mquery("insert into blog_owners (blog,owner) values ('{$blog}','{$_GET['name']}')");
echo "0";
}
?>