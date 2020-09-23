<?php
if($_GET['name']=='guest')
require("init.php");
else
require("header.php");
require("blog_base.php");
$text="";
$re=1;
$p = wp_query("GET", "/wp/v2/posts/".(int)$_GET['postid'], $_GET['searchname']);
$content = parse_content($p['content']['rendered']);
if(!wp_iswordpresscom(wp_domainize($_GET['searchname']))) {
$aut = wp_query("GET", "/wp/v2/users/".(int)$p['author'], $_GET['searchname']);
$author = $aut['elten_user'];
if($author=="") $author=$aut['name'];
if($author=="") $author=substr($_GET['searchname'], 2, -1);
} else {
$author=substr($_GET['searchname'], 2, -1-1*strlen(".wordpress.com"));
}
if($_GET['details']==4)
$text .= $p['id'] . "\r\n" . $author . "\r\n" . strtotime($p['date_gmt']."+0000") . "\r\n" . strtotime($p['modified_gmt']."+0000") . "\r\n" . (($p['status']=="publish")?0:1) . "\r\n" . (($p['comment_status']=="open")?1:0) . "\r\n" . $content . "\r\nEND\r\n";
elseif($_GET['details']==3)
$text .= $p['id'] . "\r\n" . $author . "\r\n" . strtotime($p['date_gmt']."+0000") . "\r\n" . strtotime($p['modified_gmt']."+0000") . "\r\n" . (($p['status']=="publish")?0:1) . "\r\n" . $content . "\r\nEND\r\n";
elseif($_GET['details']==2)
$text .= $p['id'] . "\r\n" . $author . "\r\n" . strtotime($p['date_gmt']."+0000") . "\r\n" . $content . "\r\nEND\r\n";
else {
if($_GET['details']==5) $text.=(($p['comment_status']=="open")?1:0)."\r\n";
$text .= $p['id'] . "\r\n" . $author . "\r\n" . $content . "\r\n" . date("Y-m-d H:i:s", strtotime($p['date'])) . "\r\n\r\n\r\nEND\r\n";
}
$head=array();
$page=0;
$comments=array();
do {
++$page;
if(!wp_iseltenblog($_GET['searchname']) && $page>5) break;
$comments = array_merge($comments, wp_query("GET", "/wp/v2/comments", $_GET['searchname'], array('post'=>$_GET['postid'], 'order'=>'asc', 'per_page'=>100, 'page'=>$page), $head));
} while($page<$head['x-wp-totalpages']);
foreach($comments as $c) {
++$re;
$content = parse_content($c['content']['rendered']);
$author="";
if($c['author']>0) {
$aut = wp_query("GET", "/wp/v2/users/".(int)$c['author']);
$author = $aut['elten_user'];
}
if($author=="") $author="guest ".$c['author_name'];
if($_GET['details']==4)
$text .= $c['id'] . "\r\n" . $author . "\r\n" . strtotime($c['date_gmt']."+0000") . "\r\n" . strtotime($c['date_gmt']."+0000") . "\r\n0\r\n0\r\n" . $content . "\r\nEND\r\n";
elseif($_GET['details']==3)
$text .= $c['id'] . "\r\n" . $author . "\r\n" . strtotime($c['date_gmt']."+0000") . "\r\n" . strtotime($c['date_gmt']."+0000") . "\r\n0\r\n" . $content . "\r\nEND\r\n";
elseif($_GET['details']==2)
$text .= $c['id'] . "\r\n" . $author . "\r\n" . strtotime($c['date_gmt']."+0000") . "\r\n" . $content . "\r\nEND\r\n";
else {
$text .= $c['id'] . "\r\n" . $author . "\r\n" . $content . "\r\n" . date("Y-m-d H:i:s", strtotime($c['date'])) . "\r\n\r\n\r\nEND\r\n";
}
}
$knownposts=0;
$suc=false;
$q=mquery("select postsread from blogs_postsread where owner='".mysql_real_escape_string($_GET['name'])."' and blog='".mysql_real_escape_string($_GET['searchname'])."' and postid=".(int)$_GET['postid']);
if(mysql_num_rows($q)>0) {
$knownposts=mysql_fetch_row($q)[0];
$suc=true;
}
if($suc == true)
mquery("UPDATE `blogs_postsread` SET `postsread`=".$re." WHERE `owner`='".$_GET['name']."' AND `blog`='".mysql_real_escape_string($_GET['searchname'])."' AND `postid`=".(int)$_GET['postid']);
else
mquery("INSERT INTO `blogs_postsread` (owner, blog, postid, postsread) VALUES ('".$_GET['name']."','".mysql_real_escape_string($_GET['searchname'])."',".(int)$_GET['postid'].",".$re.")");
if($_GET['details']==1 or $_GET['details']==5)
$text=$knownposts."\r\n".$text;
echo "0\r\n" . $re . "\r\n" . $text;
?>