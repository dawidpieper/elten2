<?php
require("header.php");
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if($_GET['add'] == 1) {
$id=((int) mysql_fetch_row(mquery("select id from blog_categories order by id desc"))[0])+1;
mquery("INSERT INTO `blog_categories` (id, owner, name) VALUES (".$id.",'".$searchname."','" . mysql_real_escape_string($_GET['categoryname']) . "')");
die("0\r\n".$id);
}
if($_GET['del'] == 1) {
$q = mquery("DELETE FROM `blog_assigning` WHERE `categoryid`='".$_GET['categoryid']."' AND `owner`='".$searchname."'");
$q = mquery("DELETE FROM `blog_categories` WHERE `id`='".$_GET['categoryid']."' AND `owner`='".$searchname."'");
}
if($_GET['rename'] == 1) {
$q = mquery("UPDATE `blog_categories` SET `name`='".mysql_real_escape_string($_GET['categoryname'])."' WHERE `id`='".$_GET['categoryid']."' AND `owner`='".$searchname."'");
}
echo "0";
?>