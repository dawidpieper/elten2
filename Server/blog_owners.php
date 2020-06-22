<?php
require("init.php");
require("blog_base.php");
$blogs = wp_query("GET", "/elten/blogs");
$a=array();
foreach($blogs as $b) {
$s=explode(".",$b['domain']);
if($s[1]=="s") $d="[".$s[0]."]";
else $d=$b['users'][0]['elten'];
if((isset($_GET['owner']) and $d!=$_GET['owner']) or strpos($d, "[")===false) continue;
$a[$d]=array();
foreach($b['users'] as $u)
array_push($a[$d], $u['elten']);
}
echo "0\r\n".count($a);
foreach($a as $k=>$v)
foreach($v as $u)
echo "\r\n".$k."\r\n".$u;
?>