<?php
require("header.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
mquery("update `blogs` set name='" . mysql_real_escape_string($_GET['blogname']) . "' where `owner`='".$searchname."'");
echo "0";
?>