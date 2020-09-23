<?php
require("header.php");
require("blog_base.php");
if(!wp_iseltenblog($_GET['searchname'])) die("-1");
if($_GET['searchname']!=$_GET['name']&&mysql_num_rows(mquery("SELECT name FROM banned WHERE name='".$_GET['name']."' AND totime>".time()))>0) die("-3");
$post = $_GET['post'];
if($_GET['buffer'] != null)
$post=buffer_get($_GET['buffer']);
$post = htmlspecialchars(str_replace("\004LINE\004", "\n", $post));
$postid=$_GET['postid'];
$author = wp_userid($_GET['name'], true);
$j = array('author'=>$author, 'author_name'=>$_GET['name'], 'content'=>$post, 'post'=>$postid, 'status'=>'approved');
$w = wp_query("POST", "/wp/v2/comments", $_GET['searchname'], $j);
if($w['data']['status']>=400) die("-1");
mquery("update blogs_postsread set postsread=postsread+1 where owner='".mysql_real_escape_string($_GET['name'])."' and blog='".mysql_real_escape_string($_GET['searchname'])."' and postid=".(int)$postid);
echo "0";
?>