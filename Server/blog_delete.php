<?php
require("header.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
mquery("delete from blog_read where author='".mysql_real_escape_string($searchname)."'");
mquery("delete from followedblogs where author='".mysql_real_escape_string($searchname)."'");
mquery("delete from blog_assigning where owner='".mysql_real_escape_string($searchname)."'");
mquery("delete from blog_posts where owner='".mysql_real_escape_string($searchname)."'");
mquery("delete from blog_categories where owner='".mysql_real_escape_string($searchname)."'");
mquery("delete from blog_owners where blog='".mysql_real_escape_string($searchname)."'");
mquery("delete from blogs where owner='".mysql_real_escape_string($searchname)."'");
echo "0";
?>