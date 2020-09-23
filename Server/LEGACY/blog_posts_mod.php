<?php
require("header.php");
require("blog_base.php");
function md_convert($text) {
if($_GET['type']=="source") return $text;
$content = htmlspecialchars($text);
function her($matches) {
$l = strlen($matches[1]);
$o="<h".$l.">";
$c="</h".$l.">";
return $o.$matches[2].$c;
}
$content = preg_replace_callback('/(\#{1,6}) ([^\n]+)/m', 'her', $content);
function aer($matches) {
$l = strlen($matches[1]);
$o="<a href=\"".$matches[2]."\">";
$c="</a>";
return $o.$matches[1].$c;
}
$content = preg_replace_callback('/\[([^\]]+)\]\(([^\)]+)\)/m', 'aer', $content);
function stronger($matches) {
if(strlen($matches[1])<3) return $matches[0];
return " <strong>".$matches[1]."</strong>";
}
$content = preg_replace_callback('/ \*\*([^\*]+)\*\*/m', 'stronger', $content);
function mer($matches) {
if(strlen($matches[1])<3) return $matches[0];
return " <m>".$matches[1]."</m>";
}
$content = preg_replace_callback('/ \*([^\*]+)\*/m', 'mer', $content);
return $content;
}
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if($_GET['add'] == 1){
$postid=1;
$comments=1;
if(isset($_GET['comments'])) $comments=$_GET['comments'];
$post = $_GET['post'];
if($_GET['audio']==1) {
if(strlen($_POST['post']) < 8) die("-1");
$filename=random_str(24);
if(substr($_POST['post'],0,4)=="OggS") {
$fp = fopen("audioblogs/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
}
else {
$fp = fopen("audioblogs/posts/tmp_".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
shell_exec("/usr/bin/ffmpeg -i \"audioblogs/posts/tmp_".$filename."\" -f opus -b:a 128k \"audioblogs/posts/{$filename}\" 2>&1");
unlink("audioblogs/posts/tmp_".$filename);
}
$post="[audio src=\"https://s.elten-net.eu/b/".$filename.".mp3\"][/audio]";
}
if($_GET['buffer'] != null) {
$post = buffer_get($_GET['buffer']);
}
$post = str_replace("\004LINE\004", "\n", $post);
$author=0;
$users=wp_query("GET", "/elten/allusers");
foreach($users as $u) if($u['elten']==$_GET['name']) $author=$u['id'];
$j = array('author'=>$author, 'title'=>$_GET['postname'], 'content'=>$post, 'categories'=>array(), 'tags'=>array());
if(strpos($post, "[audio")===false) {
$j['format']="standard";
$j['content'] = md_convert($post);
}
else $j['format']="audio";
$cats = explode(",",$_GET['categoryid']);
for($i=0; $i<count($cats); ++$i)
if($cats[$i]>0) array_push($j['categories'], (int)$cats[$i]);
$tgs = explode(",",$_GET['tags']);
for($i=0; $i<count($tgs); ++$i)
if($tgs[$i]>0) array_push($j['tags'], (int)$tgs[$i]);
if($comments==1) $j['comment_status']="open";
else $j['comment_status']="closed";
if($_GET['privacy']==0) $j['status']="publish";
else $j['status']="private";
$w=wp_query("POST", "/wp/v2/posts", $searchname, $j);
mquery("INSERT INTO `blogs_postsread` (`owner`,`blog`,`postid`,`postsread`) VALUES ('" . $_GET['name'] . "','".$searchname."'," . (int)$w['id'] . ",1)");
}
if($_GET['del'] == 1){
mquery("delete from blogs_postsread where blog='".mysql_real_escape_string($searchname)."' and postid=".(int)$_GET['postid']."");
$w=wp_query("DELETE", "/wp/v2/posts/".(int)$_GET['postid'], $searchname, array('force'=>true));
}
if($_GET['mod'] == 1){
$post = $_GET['post'];
if($_GET['audio']==1) {
if(strlen($_POST['post']) < 8) die("-1");
$filename=random_str(24);
if(substr($_POST['post'],0,4)=="OggS") {
$fp = fopen("audioblogs/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
}
else {
$fp = fopen("audioblogs/posts/tmp_".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
shell_exec("/usr/bin/ffmpeg -i \"audioblogs/posts/tmp_".$filename."\" -f opus -b:a 128k \"audioblogs/posts/{$filename}\" 2>&1");
unlink("audioblogs/posts/tmp_".$filename);
}
$post="[audio src=\"https://s.elten-net.eu/b/".$filename.".mp3\"][/audio]";
}
if($_GET['buffer'] != null)
$post=buffer_get($_GET['buffer']);
$j = array('author'=>$author, 'title'=>$_GET['postname']);
if($post!=null) {
$post = str_replace("\004LINE\004", "\n", $post);
$j['content']=$post;
if(strpos($post, "[audio")===false) {
$j['format']="standard";
$j['content'] = md_convert($post);
}
else $j['format']="audio";
}
$w=wp_query("POST", "/wp/v2/posts/".(int)$_GET['postid'], $searchname, $j);
}
if($_GET['addassigning'] == 1) {
$w=wp_query("GET", "/wp/v2/posts/".(int)$_GET['postid'], $searchname);
if($w['data']['status']>=400) die("-1");
$categories=$w['categories'];
array_push($categories, $_GET['categoryid']);
$j = array('categories' => $categories);
$w=wp_query("POST", "/wp/v2/posts/".(int)$_GET['postid'], $searchname, $j);
}
if($_GET['removeassigning']==1) {
$w=wp_query("GET", "/wp/v2/posts/".(int)$_GET['postid'], $searchname);
if($w['data']['status']>=400) die("-1");
$categories=$w['categories'];
if(($key=array_search($_GET['categoryid'], $categories)) !== false)  unset($categories[$key]);
$j = array('categories' => $categories);
$w=wp_query("POST", "/wp/v2/posts/".(int)$_GET['postid'], $searchname, $j);
}
if($_GET['edit'] == 1) {
$post = $_GET['post'];
$comments=1;
if(isset($_GET['comments'])) $comments=$_GET['comments'];
if($_GET['audio']==1) {
if(strlen($_POST['post']) < 8) die("-1");
$filename=random_str(24);
$fp = fopen("audioblogs/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
$post="[audio src=\"https://s.elten-net.eu/b/".$filename.".mp3\"][/audio]";
}
if($_GET['buffer'] != null)
$post=buffer_get($_GET['buffer']);
$j = array('author'=>$author, 'title'=>$_GET['postname']);
if($post!=null) {
$post = str_replace("\004LINE\004", "\n", $post);
$j['content']=$post;
if(strpos($post, "[audio")===false) {
$j['format']="standard";
$j['content'] = md_convert($post);
}
else $j['format']="audio";
}
if($comments==1) $j['comment_status']="open";
else $j['comment_status']="closed";
if($_GET['privacy']==0) $j['status']="publish";
else $j['status']="private";
$j['categories']=array();
$cats = explode(",",$_GET['categoryid']);
for($i=0; $i<count($cats); ++$i)
if($cats[$i]>0) array_push($j['categories'], (int)$cats[$i]);
$j['tags']=array();
$tgs = explode(",",$_GET['tags']);
for($i=0; $i<count($tgs); ++$i)
if($tgs[$i]>0) array_push($j['tags'], (int)$tgs[$i]);
$w=wp_query("POST", "/wp/v2/posts/".(int)$_GET['postid'], $searchname, $j);
}
if($_GET['recategorize']==1) {
$data='';
if($_GET['buffer'] != NULL)
$data=buffer_get($_GET['buffer']);
else
$data=$_GET['data'];
mquery("DELETE FROM `blog_assigning` WHERE `owner`='".$searchname."'");
$posts=explode('|',$data);
foreach($posts as $post) {
$tmp=explode(":",$post);
$postid=$tmp[0];
$cats=explode(",",$tmp[1]);
wp_query("POST", "/wp/v2/posts/".(int)$post, $searchname, array('categories'=>$cats));
}
}
if($_GET['delcomments'] == 1){
$comments = wp_query("GET", "/wp/v2/comments", $searchname, array("post"=>$_GET['postid'], 'per_page'=>100));
while(count($comments)>0) {
foreach($comments as $c)
wp_query("DELETE", "/wp/v2/comments/".$c['id'], $searchname, array("force"=>true));
$comments = wp_query("GET", "/wp/v2/comments", $searchname, array("post"=>$_GET['postid'], 'per_page'=>100));
}
mquery("update `blogs_postsread` set postsread=1 WHERE `blog`='".$searchname."' AND `postid`=".(int)$_GET['postid']);
}
if($_GET['delcomment'] == 1){
$id=0;
$page=0;
$comments=array();
do {
++$page;
$comments = array_merge($comments, wp_query("GET", "/wp/v2/comments", $_GET['searchname'], array('post'=>$_GET['postid'], 'order'=>'asc', 'per_page'=>100, 'page'=>$page), $head));
} while($page<$head['x-wp-totalpages']);
$i=0;
foreach($comments as $c) {
++$i;
if($i==$_GET['commentnumber']) $id=$c['id'];
}
if($id>0) wp_query("DELETE", "/wp/v2/comments/".$id, $searchname, array("force"=>true));
}
echo "0";
?>