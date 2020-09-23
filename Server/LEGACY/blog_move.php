<?php
require("header.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if(!isset($_GET['destination'])) die("-3");
if(!in_array($_GET['name'],blogowners($_GET['destination']))) die("-3");
$newpostid=mysql_fetch_row(mquery("select max(postid) from blog_posts where owner='".mysql_real_escape_string($_GET['destination'])."'"))[0]+1;
mquery("update blog_posts set owner='".mysql_real_escape_string($_GET['destination'])."', postid=".(int)$newpostid." where owner='".mysql_real_escape_string($searchname)."' and postid=".(int)$_GET['postid']);
mquery("update blog_read set author='".mysql_real_escape_string($_GET['destination'])."', post=".(int)$newpostid." where author='".mysql_real_escape_string($searchname)."' and post=".(int)$_GET['postid']);
mquery("delete from blog_assigning where owner='".mysql_real_escape_string($searchname)."' and postid=".(int)$_GET['postid']);
if($_GET['movetype']==1) {
mquery("delete from blog_posts where posttype!=0 and owner='".mysql_real_escape_string($_GET['destination'])."' and postid=".(int)$newpostid);
mquery("update blog_read set posts=1 where owner='".mysql_real_escape_string($_GET['destination'])."' and post=".(int)$newpostid);
}
echo "0";
?>