<?php
require("header.php");
require("blog_base.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
$id=0;
$blogs=wp_query("GET", "/elten/blogs");
foreach($blogs as $b) if($b['domain']==wp_domainize($searchname)) $id=$b['id'];
$w=wp_query("DELETE", "/elten/blog/".$id);
echo "0";
?>