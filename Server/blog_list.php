<?php
if($_GET['orderby']>2)
require("header.php");
else
require("init.php");
require("blog_base.php");
$q=mquery("select blog from blogs_followed where owner='".mysql_real_escape_string($_GET['name'])."'");
$followed=array();
while($r=mysql_fetch_row($q)) array_push($followed, wp_domainize($r[0]));
$result=array();
$blogs = wp_query("GET", "/elten/blogs");
if(isset($_GET['user'])) {
foreach($blogs as $b)
foreach($b['users'] as $u)
if($u['elten']==$_GET['user']) array_push($result, $b);
}
else {
$orderby = 0;
$orderby = $_GET['orderby'];
switch($orderby) {
case 0:
foreach($blogs as $b) if($b['cnt_posts']>0 && $b['lastpost']!=null) array_push($result, $b);
usort($result, function ($a, $b) {
return (strtotime($b['lastpost']) <=> strtotime($a['lastpost']));
});
break;
case 1:
foreach($blogs as $b) if($b['cnt_posts']>0 && strtotime($b['lastpost'])>=time()-86400*30) array_push($result, $b);
usort($result, function ($a, $b) {
return $b['cnt_posts'] <=> $a['cnt_posts'];
});
break;
case 2:
foreach($blogs as $b) if($b['cnt_posts']>20 && strtotime($b['lastpost'])>time()-86400*60) array_push($result, $b);
usort($result, function ($a, $b) {
return $b['mediana_comments']<=>$a['mediana_comments'];
});
break;
case 3:
foreach($blogs as $b) {
if(in_array($b['domain'], $followed)) array_push($result, $b);
}
usort($result, function ($a, $b) {
return (strtotime($b['lastpost']) <=> strtotime($a['lastpost']));
});
break;
case 4:
foreach($blogs as $b) if($b['cnt_posts']>0) array_push($result, $b);
usort($result, function ($a, $b) {
return $b['cnt_posts'] <=> $a['cnt_posts'];
});
break;
case 5:
foreach($blogs as $b)
foreach($b['users'] as $u)
if($u['elten']==$_GET['name']) array_push($result, $b);
usort($result, function ($a, $b) {
return $b['cnt_posts'] <=> $a['cnt_posts'];
});
break;
}
}
echo "0\r\n".count($result);
foreach($result as $b) {
$s=explode(".",$b['domain']);
if($s[1]=="s") $d="[".$s[0]."]";
else $d=$b['users'][0]['elten'];
echo "\r\n".$d."\r\n".wp_htmldecode($b['name']);
if(isset($_GET['details']) && $_GET['details']==1)
echo "\r\n".$b['cnt_posts']."\r\n".$b['cnt_comments']."\r\nhttps://".$b['domain'].$b['path']."\r\n".strtotime($b['lastpost'])."\r\n".wp_htmldecode(strip_tags(str_replace("\n","",$b['description'])))."\r\n".((in_array($b['domain'], $followed))?"1":"0");
}
?>