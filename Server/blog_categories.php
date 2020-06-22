<?php
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
require("blog_base.php");
echo "0";
if($_GET['details']==1) {
$w = wp_query("GET", "/", $_GET['searchname']);
echo "\r\n".wp_htmldecode($w['name']);
}
$page=0;
$categories = array();
$head=array();
do {
++$page;
$c = wp_query("GET", "/wp/v2/categories", $_GET['searchname'], array('per_page'=>100, 'page'=>$page));
$categories = array_merge($categories, $c);
} while($page<(int)$head['x-wp-totalpages']);
echo "\r\n".count($categories);
foreach($c as $a) {
echo "\r\n".$a['id']."\r\n".$a['name'];
if($_GET['details']==1) {
$count=$a['elten_postscount'];
if($count==null) $count=$a['count'];
echo "\r\n".$a['parent']."\r\n".$count."\r\n".$a['link'];
}
}
?>