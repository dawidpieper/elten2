<?php
require("header.php");
require("blog_base.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
$userid = wp_userid($_GET['user'], true);
$blogid = 0;
$blogs = wp_query("GET", "/elten/blogs");
foreach($blogs as $b)
if($b['domain']==wp_domainize($searchname)) $blogid=$b['id'];
if($_GET['ac']=="add") {
if(in_array($_GET['user'],blogowners($searchname))) die("-1");
$j = array('users_add'=>$userid);
$w=wp_query("POST", "/elten/blog/".(int)$blogid, "", $j);
echo "0";
}
if($_GET['ac']=="release") {
$j = array('users_remove'=>$userid);
$w=wp_query("POST", "/elten/blog/".(int)$blogid, "", $j);
echo "0";
}
if($_GET['ac']=="leave") {
$userid = wp_userid($_GET['name'], true);
$j = array('users_remove'=>$userid);
$w=wp_query("POST", "/elten/blog/".(int)$blogid, "", $j);
echo "0";
}
?>