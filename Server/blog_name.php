<?php
require("init.php");
require("blog_base.php");
$j = wp_query("GET", "/", $_GET['searchname']);
echo "0\r\n".$j['name'];
?>