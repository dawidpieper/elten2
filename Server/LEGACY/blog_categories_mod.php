<?php
require("header.php");
require("blog_base.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if($_GET['add'] == 1) {
$j = array("name"=>$_GET['categoryname']);
$w = wp_query("POST", "/wp/v2/categories", $searchname, $j);
if($w['data']['status']>=400) die("-1");
die("0\r\n".$w['id']);
}
if($_GET['del'] == 1) {
$w = wp_query("DELETE", "/wp/v2/categories/".(int)$_GET['categoryid'], $searchname, array('force'=>true));
if($w['data']['status']>=400) die("-1");
die("0");
}
if($_GET['rename'] == 1) {
$j = array("name"=>$_GET['categoryname']);
$w = wp_query("POST", "/wp/v2/categories/".(int)$_GET['categoryid'], $searchname, $j);
if($w['data']['status']>=400) die("-1");
die("0\r\n".$w['id']);

}
echo "0";
?>