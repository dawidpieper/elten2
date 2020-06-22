<?php
require("header.php");
require("blog_base.php");
$q = mquery("select postid from blogs_postsread where blog='".mysql_real_escape_string($_GET['user'])."' and owner='".mysql_real_escape_string($_GET['name'])."'");
$known = array();
while($r=mysql_fetch_row($q)) {
array_push($known, $r[0]);
}
$page=0;
$head=array();
do {
++$page;
$ps= wp_query("GET", "/wp/v2/posts", $_GET['user'], array('fields'=>'id,title.rendered', 'status'=>array('private', 'publish'), 'page'=>$page, 'per_page'=>100, 'exclude'=>$known), $head);
foreach($ps as $p)
if(!in_array($p['id'], $known)) {
mquery("insert into blogs_postsread (owner,blog,postid,postsread) values ('".mysql_real_escape_string($_GET['name'])."','".mysql_real_escape_string($_GET['user'])."',".$p['id'].",0)");
}
} while($page<(int)$head['x-wp-totalpages']);
echo "0";
?>