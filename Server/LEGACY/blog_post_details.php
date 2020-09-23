<?php
require("init.php");//require("header.php");
require("blog_base.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
$post=wp_query("GET", "/wp/v2/posts/".(int)$_GET['postid'], $searchname, array("context"=>"edit"));
echo "0\r\n";
echo str_replace("\n", "", str_replace("\r", "", $post['title']['raw']))."\r\n";
echo (($post['status']=="publish")?0:1)."\r\n";
echo (($post['comment_status']=="open")?"1":"0")."\r\n";
echo implode(",",$post['categories'])."\r\n";
echo implode(",",$post['tags'])."\r\n";
echo "0\r\n";
echo "0\r\n";
echo "0\r\n";
echo "0\r\n";
echo "0\r\n";
echo str_replace("\004END\004", "", $post['content']['raw'])."\r\n\004END\004";

?>