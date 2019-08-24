<?php
require("header.php");
mquery("update `blogs` set name='" . mysql_real_escape_string($_GET['blogname']) . "' where `owner`='".$_GET['name']."'");
echo "0";
?>