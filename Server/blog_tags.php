<?php
require("init.php");
require("blog_base.php");
if($_GET['ac']=="get") {
$page=0;
$tags=array();
do {
++$page;
$tags = array_merge($tags, wp_query("GET", "/wp/v2/tags", $_GET['searchname'], array('per_page'=>100, 'page'=>$page), $head));
} while($page<$head['x-wp-totalpages']);
echo "0\r\n".count($tags);
foreach($tags as $tag)
echo "\r\n".$tag['id']."\r\n".$tag['name'];
}
elseif($_GET['ac']=="add") {
if(!in_array($_GET['name'],blogowners($_GET['searchname']))) die("-3");
$j=array('name'=>$_GET['tagname']);
$w=wp_query("POST", "/wp/v2/tags", $_GET['searchname'], $j);
if(!isset($w['id'])) die("-1");
echo "0\r\n".$w['id'];
}
elseif($_GET['ac']=="delete") {
if(!in_array($_GET['name'],blogowners($_GET['searchname']))) die("-3");
wp_query("DELETE", "/wp/v2/tags/".(int)$_GET['tagid'], $_GET['searchname'], array("force"=>true));
echo "0";
}
?>