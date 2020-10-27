<?php
require("header.php");
require("blog_base.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if(!isset($_GET['destination'])) die("-3");
if(!in_array($_GET['name'],blogowners($_GET['destination']))) die("-3");
$post=wp_query("GET", "/wp/v2/posts/".$_GET['postid'], $searchname, array('context'=>'edit'));
$head=array();
$page=0;
$comments=array();
do {
++$page;
$comments = array_merge($comments, wp_query("GET", "/wp/v2/comments", $_GET['searchname'], array('post'=>$_GET['postid'], 'context'=>'edit', 'order'=>'asc', 'per_page'=>100, 'page'=>$page), $head));
} while($page<$head['x-wp-totalpages']);
unset($post['guid']);
unset($post['id']);
unset($post['link']);
unset($post['modified']);
unset($post['modified_gmt']);
unset($post['slug']);
unset($post['type']);
unset($post['permalink_template']);
unset($post['generated_slug']);
unset($post['date']);
unset($post['categories']);
unset($post['tags']);
unset($post['meta']);
unset($post['featured_media']);
unset($post['_links']);
$post['content']=$post['content']['raw'];
$post['title']=$post['title']['raw'];
$post['excerpt']=$post['excerpt']['raw'];
$w=wp_query("POST", "/wp/v2/posts", $_GET['destination'], $post);
$newpostid=(int)$w['id'];
mquery("update blogs_postsread set blog='".mysql_real_escape_string($_GET['destination'])."', postid=".(int)$newpostid." where blog='".mysql_real_escape_string($searchname)."' and postid=".(int)$_GET['postid']);
mquery("update blogs_postsfollowed set blog='".mysql_real_escape_string($_GET['destination'])."', postid=".(int)$newpostid." where blog='".mysql_real_escape_string($searchname)."' and postid=".(int)$_GET['postid']);
if($_GET['movetype']==0) {
foreach($comments as $comment) {
unset($comment['id']);
unset($comment['parent']);
unset($comment['link']);
unset($comment['date']);
unset($comment['meta']);
unset($comment['_links']);
$comment['content']=$comment['content']['raw'];
$comment['post']=$newpostid;
$w=wp_query("POST", "/wp/v2/comments", $_GET['destination'], $comment);
}
}
else
mquery("update blogs_postsread set postsread=1 where blog='".mysql_real_escape_string($_GET['destination'])."' and postid=".(int)$newpostid);
wp_query("DELETE", "/wp/v2/posts/".$_GET['postid'], $searchname, array('force'=>1));
echo "0";
?>