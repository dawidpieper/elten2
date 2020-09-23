<?php
require("init.php");
require("blog_base.php");
$w = wp_query("GET", "/wp/v2/posts/".(int)$_GET['postid'], $_GET['searchname'], array("context"=>"edit"));
if($w['data']['status']>=400) die("-1");
echo "0\r\n".$w['title']['raw']."\r\n".count($w['categories'])."\r\n".implode("\r\n",$w['categories']);
?>