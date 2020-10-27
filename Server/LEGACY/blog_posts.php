<?php
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
require("blog_base.php");
function get_posts($blog, $category=0, $paginate=false, $paginaterequest=false, $page=0, &$nextpage=0) {
$posts = array();
$page-=1;
do {
++$page;
if($page<1) $page=1;
$args = array('page'=>$page, 'per_page'=>100);
if(isset($category) and $category>0 and $category!="NEW" and $category!="FOLLOWED" and $category!="NEWFOLLOWED") $args['categories']=$category;
if(wp_iseltenblog($blog)) {
$args['status'] = array('private', 'publish');
$args['fields'] = 'id,title.rendered,format,categories,elten_commentscount,date_gmt,link,author';
}
if(!wp_iseltenblog($blog) && $paginaterequest==1) {
if($page<1) $page=1;
$args['per_page']=25;
$args['page']=$page;
}
$w = wp_query("GET", "/wp/v2/posts", $blog, $args, $head);
if($paginate) {
if($page<(int)$head['x-wp-totalpages']) $nextpage=1;
else $nextpage=0;
}
$posts = array_merge($posts, $w);
} while($page<(int)$head['x-wp-totalpages'] && $paginate==false);
foreach($posts as $k=>$p) $posts[$k]['__blog']=$blog;
return $posts;
}
$re=0;
$t="";
$ordertype="DESC";
if($_GET['reverse']==1) $ordertype="ASC";
$page=$_GET['page'];
$paginaterequested=$_GET['paginate'];
$posts=array();
$head=array();
$paginate=false;
if(isset($_GET['paginate']) && $_GET['paginate']==1) {
if(!wp_iseltenblog($_GET['searchname']))
$paginate=true;
else
$t.="0\r\n";
}
$fpblogs=array();
$q=mquery("select blog, postid from blogs_postsfollowed where owner='".mysql_real_escape_string($_GET['name'])."'");
while($r=mysql_fetch_row($q)) {
if(!isset($fpblogs[$r[0]])) $fpblogs[$r[0]]=array();
array_push($fpblogs[$r[0]], $r[1]);
}
$postsread=array();
if($_GET['name']!="guest") {
$q=mquery("select blog, postid, postsread from blogs_postsread where owner='".mysql_real_escape_string($_GET['name'])."'");
while($r=mysql_fetch_row($q)) {
if(!isset($postsread[$r[0]])) $postsread[$r[0]]=array();
$postsread[$r[0]][(int)$r[1]]=(int)$r[2];
}
}
if(($_GET['categoryid']!='NEW' and $_GET['categoryid']!='FOLLOWED' and $_GET['categoryid']!='NEWFOLLOWED') or $_GET['details']==0) {
$nextpage=0;
$posts = get_posts($_GET['searchname'], $_GET['categoryid'], $paginate, $paginaterequested, $page, $nextpage);
if($paginate) $t.=$nextpage."\r\n";
}
elseif($_GET['categoryid']=='NEW') {
$postsread=array();
$posts = array();
$blogs = wp_query("GET", "/elten/blogs");
foreach($blogs as $b)
foreach($b['users'] as $u)
if($u['elten']==$_GET['name']) {
$d=wp_dedomainize($b['domain']);
$postsread[$d]=array();
if($_GET['name']!="guest") {
$q=mquery("select postid, postsread from blogs_postsread where owner='".mysql_real_escape_string($_GET['name'])."' and blog='".mysql_real_escape_string($d)."'");
while($r=mysql_fetch_row($q)) {
$postsread[$d][(int)$r[0]]=(int)$r[1];
}
}
$nextpage=0;
$newposts = get_posts($d, $_GET['categoryid'], $paginate, $paginaterequested, $page);
$posts = array_merge($posts, $newposts);
}
} elseif($_GET['categoryid']=='FOLLOWED' or $_GET['categoryid']=='NEWFOLLOWED') {
$posts = array();
$blogs = wp_query("GET", "/elten/blogs");
foreach($fpblogs as $b=>$a) {
$suc=false;
foreach($blogs as $bl) if($bl['domain']==wp_domainize($b)) $suc=true;
if($suc==false) continue;
$nextpage=0;
$newposts = get_posts($b, $_GET['categoryid'], $paginate, $paginaterequested, $page);
foreach($newposts as $n)
if(in_array($n['id'], $a)) array_push($posts, $n);
}
}
$auts = wp_query("GET", "/elten/allusers");
foreach($posts as $p) {
$title = wp_htmldecode(strip_tags($p['title']['rendered']));
$head=array();
$counter = 1;
$counter+=(int)$p['elten_commentscount'];
if($p['id']==100) {
}
if(($_GET['categoryid']=="NEW" or $_GET['categoryid']=="NEWFOLLOWED") and $postsread[$p['__blog']][$p['id']]>=$counter) continue;
$re += 1;
$t .= $p['id'] . "\r\n" . str_replace("\r\n", "", $title) . "\r\n";
if($_GET['assignnew']==1 or $_GET['details']>=1) {
if($_GET['categoryid']!="NEW") {
if($postsread[$p['__blog']][$p['id']]<$counter)
$t.="1\r\n";
else
$t.="0\r\n";
}
else
$t.="0\r\n";
}
if($_GET['details']>=1) {
$t .= $p['__blog']."\r\n";
$t.=(($p['format']=="audio")?"1":"0")."\r\n";
$t .= strtotime($p['date_gmt']."+0000")."\r\n";
$t .= $p['link']."\r\n";
}
if($_GET['details']>=2) {
if(!wp_iswordpresscom(wp_domainize($_GET['searchname']))) {
foreach($auts as $aut)
if($aut['id']==$p['author']) {
$author = $aut['elten'];
if($author=="") $author=$aut['name'];
break;
}
if($author=="") $author=substr($_GET['searchname'], 2, -1);
} else {
$author=substr($_GET['searchname'], 2, -1-1*strlen(".wordpress.com"));
}
$t .= $author."\r\n";
$t.=$p['elten_commentscount']."\r\n";
}
if($_GET['details']>=3) {
$t.=(in_array($p['id'], $fpblogs[$p['__blog']])?"1":"0")."\r\n";
}
if($_GET['listcategories']==1) {
foreach($post['categories'] as $c)
$t.=$c.",";
$t.="\r\n";
}
}
echo "0\r\n" . $re . "\r\n" . $t;
?>