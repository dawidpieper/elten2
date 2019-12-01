<?php
require("header.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if($searchname==$_GET['name']) die("-1");
if($_GET['ac']=="add") {
if(in_array($_GET['user'],blogowners($searchname))) die("-1");
mquery("insert into blog_owners (blog,owner) values ('".mysql_real_escape_string($_GET['searchname'])."','".mysql_real_escape_string($_GET['user'])."')");
echo "0";
}
if($_GET['ac']=="release") {
mquery("delete from blog_owners where owner!='{$_GET['name']}' and owner='".mysql_real_escape_string($_GET['user'])."' and blog='".mysql_real_escape_string($_GET['searchname'])."'");
echo "0";
}
?>