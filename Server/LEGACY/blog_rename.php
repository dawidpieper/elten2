<?php
require("header.php");
require("blog_base.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
$blogs = wp_query("GET", "/elten/blogs");
$d=wp_domainize($searchname);
$id=0;
foreach($blogs as $b)
if($b['domain']==$d) $id=$b['id'];
if($id==0) die("-1");
$j=array("name"=>$_GET['blogname']);
$w=wp_query("POST", "/elten/blog/".$id, $searchname, $j);
echo "0";
?>