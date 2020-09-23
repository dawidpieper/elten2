<?php
if($_GET['name']=='guest')
require("init.php");
else
require("header.php");
require("blog_base.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if($_GET['ac']=="list") {
$status='approve';
if($_GET['type']=="hold") $status="hold";
elseif($_GET['type']=="spam") $status="spam";
$head=array();
$page=0;
$comments=array();
do {
++$page;
$comments = array_merge($comments, wp_query("GET", "/wp/v2/comments", $searchname, array('status'=>$status, 'order'=>'asc', 'per_page'=>100, 'page'=>$page), $head));
} while($page<$head['x-wp-totalpages']);
echo "0\r\n".count($comments);
foreach($comments as $c) {
$content = parse_content($c['content']['rendered']);
$author="";
if($c['author']>0) {
$aut = wp_query("GET", "/wp/v2/users/".(int)$c['author']);
$author = $aut['elten_user'];
}
if($author=="") $author="guest ".$c['author_name'];
$pst = wp_query("GET", "/wp/v2/posts/".(int)$c['post'], $searchname);
$post = html_entity_decode($pst['title']['rendered']);
echo "\r\n".$c['id']."\r\n".$author."\r\n".$post."\r\n".str_replace("\004END\004","",$content)."\r\n\004END\004";
}
}
elseif($_GET['ac']=="assign") {
$status="approve";
if($_GET['type']=="hold") $status="hold";
if($_GET['type']=="spam") $status="spam";
wp_query("POST", "/wp/v2/comments/".(int)$_GET['comment'], $searchname, array('status'=>$status));
echo "0";
}
elseif($_GET['ac']=="delete") {
wp_query("DELETE", "/wp/v2/comments/".(int)$_GET['comment'], $searchname, array('force'=>true));
echo "0";
}
?>