<?php
require("header.php");
require("blog_base.php");
$j=array();
$j['title']=$_GET['blogname'];
$j['admin']=wp_userid($_GET['name'], true);
if(!isset($_GET['shared']) or $_GET['shared']==0) {
$j['domain']=wp_domainize($_GET['name']);
}
else {
$blogs=wp_query("GET", "/elten/blogs");
$domains=array(wp_domain());
foreach($blogs as $b) array_push($domains, $b['domain']);
$words = explode(" ", $_GET['blogname']);
$domain="";
for($i=0; $i<count($words); ++$i) {
$domain.=$words[$i];
if(!in_array(wp_domainize('['.$domain.']'), $domains)) break;
}
if($domain=="") $domain="blog";
if(in_array(wp_domainize('['.$domain.']'), $domains) || $domain=="blog") {
$nd=$domain;
$ind=1;
while(in_array(wp_domainize('['.$nd.']'), $domains) || $nd=="blog") {
++$index;
$nd=$domain.$index;
}
$domain=$nd;
}
$d=wp_domainize('['.$domain.']');
$j['domain']=$d;
}
if($j['title']=="") $j['title']="blog";
$j['description'] = "Blog of user ".$_GET['name'];
$w=wp_query("POST", "/elten/blogs", "", $j);
print_r($w);
echo "0";
?>