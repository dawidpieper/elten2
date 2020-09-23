<?php
require("init.php");//require("header.php");
require("blog_base.php");
$q = mquery("select blog, postid from blogs_postsread where owner='".mysql_real_escape_string($_GET['name'])."'");
$unread = array();
$known = array();
while($r=mysql_fetch_row($q)) {
$d=wp_domainize($r[0]);
if(!isset($known[$d])) $known[$d]=array();
array_push($known[$d], $r[1]);
}
$posts=array();
$q = mquery("select blog from blogs_followed where owner='".mysql_real_escape_string($_GET['name'])."'");
while($r=mysql_fetch_row($q)) {
$d = wp_domainize($r[0]);
$page=0;
$posts[$d]=array();
$head=array();
do {
++$page;
$ps= wp_query("GET", "/wp/v2/posts", $r[0], array('fields'=>'id,title.rendered,date_gmt', 'status'=>array('private', 'publish'), 'page'=>$page, 'per_page'=>100, 'exclude'=>$known[$d]), $head);
foreach($ps as $p)
if(!in_array($p['id'], $known[$d])) {
$p['__eltenauthor']=$r[0];
array_push($unread, $p);
}
} while($page<(int)$head['x-wp-totalpages']);
}
usort($unread, function ($a, $b) {
return (strtotime($b['date_gmt']."+0000") <=> strtotime($a['date_gmt']."+0000"));
});
echo "0\r\n".count($unread);
foreach($unread as $u) {
echo "\r\n".$u['__eltenauthor']."\r\n0\r\n".$u['id']."\r\n".strip_tags(html_entity_decode($u['title']['rendered']));
}
?>