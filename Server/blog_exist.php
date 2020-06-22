<?php
require("init.php");
require("blog_base.php");
if($_GET['searchname'][0]!="[" || $_GET['searchname'][1]!="*") {
$blogs = wp_query("GET", "/elten/blogs");
$suc=false;
foreach($blogs as $b) {
$s=explode(".",$b['domain']);
if($s[1]=="s") $d="[".$s[0]."]";
else $d=$b['users'][0]['elten'];
if($d==$_GET['searchname']) {
$suc=true;
break;
}
}
} else {
$suc=false;
$headers=array();
$w=wp_query("GET", "/", $_GET['searchname'], "", $headers, false);
if($w!=false && ((isset($w['name']) && isset($w['url'])) || isset($w['routes'])))
$suc=true;
}
echo "0\r\n".(($suc==true)?"1":"0");
?>