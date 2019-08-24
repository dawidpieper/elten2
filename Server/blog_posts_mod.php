<?php
require("header.php");
if($_GET['add'] == 1){
$postid=1;
$q = mquery("SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['name']."'");
while($wiersz = mysql_fetch_row($q)) {
if($wiersz[0]>=$postid)
$postid = $wiersz[0]+1;
}
$post = $_GET['post'];
if($_GET['audio']==1) {
if(strlen($_POST['post']) < 8) {
echo "-1";
die;
}
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
$post="\004AUDIO\004/audioblogs/posts/".$filename."\004AUDIO\004";
}
if($_GET['buffer'] != null) {
$post = buffer_get($_GET['buffer']);
}
mquery("INSERT INTO `blog_posts` (`owner`,`author`,`postid`,`posttype`,`name`,`post`,`date`,`privacy`) VALUES ('" . $_GET['name'] . "','".$_GET['name']."'," . (int)$postid . ",0,'".mysql_real_escape_string($_GET['postname'])."','" . mysql_real_escape_string($post) . "',".time().",".((int)$_GET['privacy']).")");
mquery("INSERT INTO `blog_read` (`owner`,`author`,`post`,`posts`) VALUES ('" . $_GET['name'] . "','".$_GET['name']."'," . (int)$postid . ",1)");
$cats = explode(",",$_GET['categoryid']);
$i = 0;
while($i<count($cats)) {
if($cats[$i]>0 AND $cats[$i] != NULL) {
mquery("INSERT INTO `blog_assigning` (owner,categoryid,postid) VALUES ('".$_GET['name']."',".(int)$cats[$i].",".(int)$postid.")");
}
$i=$i+1;
}
mquery("UPDATE `blogs` SET `lastupdate`=".time()." WHERE `owner`='".$_GET['name']."'");
}
if($_GET['del'] == 1){
mquery("DELETE FROM `blog_posts` WHERE `postid`=" . (int)$_GET['postid'] . " AND `owner`='".$_GET['name']."'");
mquery("DELETE FROM `blog_assigning` WHERE `owner`='".$_GET['name']."' AND `postid`=".(int)$_GET['postid']);
mquery("DELETE FROM `blog_read` WHERE `author`='".$_GET['name']."' AND `post`=".(int)$_GET['postid']);
}
if($_GET['mod'] == 1){
$post = $_GET['post'];
if($_GET['audio']==1) {
if(strlen($_POST['post']) < 8) {
echo "-1";
die;
}
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
$post="\004AUDIO\004/audioblogs/posts/".$filename."\004AUDIO\004";
}
if($_GET['buffer'] != null)
$post=buffer_get($_GET['buffer']);
if($post==NULL)
$post=mysql_real_escape_string(mysql_fetch_row(mquery("select post from blog_posts where owner='".$_GET['name']."' and postid=".(int)$_GET['postid']." and posttype=0"))[0]);
mquery("UPDATE `blog_posts` SET `post`='" . mysql_real_escape_string($post) . "', `moddate`=".time()." WHERE `postid`=".(int)$_GET['postid']." AND `posttype`=0 AND `owner`='".$_GET['name']."'");
}
if($_GET['addassigning'] == 1) {
$q = mquery("SELECT `postid` FROM `blog_assigning` WHERE `postid`=".(int)$_GET['postid']." AND `categoryid`=".(int)$_GET['categoryid']." AND `owner`='".$_GET['name']."'");
if(mysql_num_rows($q)>0) {
echo "-3";
die;
}
$zapytanie = "SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['name']."' AND `postid`=".$_GET['postid'];
$q = mysql_query($zapytanie);
if($q == false) {
echo "-1";
die;
}
if(mysql_num_row($q)==0) {
echo "-4";
die;
}
$zapytanie = "INSERT INTO `blog_assigning` (owner, postid, categoryid) VALUES ('".$_GET['name']."',".$_GET['postid'].",".$_GET['categoryid'].")";
$q = mysql_query($zapytanie);
if($q == false) {
echo "-1";
die;
}
}
if($_GET['removeassigning']==1) {
$zapytanie = "DELETE FROM `blog_assigning` WHERE `postid`=".$_GET['postid']." AND `categoryid`=".$_GET['categoryid']." AND `owner`='".$_GET['name']."'";
if($q == false) {
echo "-1";
die;
}
}
if($_GET['edit'] == 1) {
$post = $_GET['post'];
if($_GET['audio']==1) {
if(strlen($_POST['post']) < 8) {
echo "-1";
die;
}
$filename=random_str(24);
$fp = fopen("audioblogs/posts/".$filename,"w");
fwrite($fp,$_POST['post']);
fclose($fp);
$post="\004AUDIO\004/audioblogs/posts/".$filename."\004AUDIO\004";
}
if($_GET['buffer'] != null)
$post=buffer_get($_GET['buffer']);
if($post==NULL)
$post=mysql_real_escape_string(mysql_fetch_row(mquery("select post from blog_posts where owner='".$_GET['name']."' and postid=".(int)$_GET['postid']." and posttype=0"))[0]);
mquery("UPDATE `blog_posts` SET `moddate`=".time().", `post`='" . mysql_real_escape_string($post) . "', `name`='".mysql_real_escape_string($_GET['postname'])."', `privacy`='".((int) $_GET['privacy'])."' WHERE `postid`=".(int)$_GET['postid']." AND `posttype`=0 AND `owner`='".$_GET['name']."'");
$categories = [];
$cats = explode(",",$_GET['categoryid']);
$zapytanie = "DELETE FROM `blog_assigning` WHERE `postid`=".$_GET['postid']." AND `owner`='".$_GET['name']."'";
$q = mysql_query($zapytanie);
if($q == false) {
echo "-1";
die;
}
$i = 0;
while($i<count($cats)) {
if($cats[$i]>0 AND $cats[$i] != NULL) {
$zapytanie = "INSERT INTO `blog_assigning` (owner,categoryid,postid) VALUES ('".$_GET['name']."',".$cats[$i].",".$_GET['postid'].")";
$q = mysql_query($zapytanie);
if($q == false) {
echo "-1";
die;
}
}
$i=$i+1;
}
}
if($_GET['recategorize']==1) {
$data='';
if($_GET['buffer'] != NULL)
$data=buffer_get($_GET['buffer']);
else
$data=$_GET['data'];
mquery("DELETE FROM `blog_assigning` WHERE `owner`='".$_GET['name']."'");
$posts=explode('|',$data);
foreach($posts as $post) {
$tmp=explode(":",$post);
$postid=$tmp[0];
$cats=explode(",",$tmp[1]);
foreach($cats as $cat) {
if($cat!=NULL and $cat!="")
mquery("INSERT INTO `blog_assigning` (owner,categoryid,postid) VALUES ('".$_GET['name']."',".(int)$cat.",".$postid.")");
}
}
}
echo "0";
?>