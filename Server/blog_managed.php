<?php
require("init.php");
require("blog_base.php");
$managed = array();
$blogs = wp_query("GET", "/elten/blogs");
foreach($blogs as $b)
foreach($b['users'] as $u)
if($u['elten']==$_GET['searchname'])
array_push($managed, $b);
echo "0\r\n".count($managed);
foreach($managed as $b) {
$s=explode(".",$b['domain']);
if($s[1]=="s") $d="[".$s[0]."]";
else $d=$b['users'][0]['elten'];
echo "\r\n".$d."\r\n".$b['name'];
}
?>