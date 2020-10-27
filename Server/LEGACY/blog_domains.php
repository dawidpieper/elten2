<?php
require("init.php");
//require("header.php");
require("blog_base.php");

if($_GET['ac'] == "propers") {
echo "0\r\nelten.blog\r\n".gethostbyname("elten.blog");
}
elseif($_GET['ac']=="check") {
echo "0\r\n";
$h=gethostbyname($_GET['domain']);
if(gethostbyname("elten.blog") == $h)
echo "1";
else
echo "0";
echo "\r\n".$h;
}
elseif($_GET['ac']=="getblogdomain") {
echo "0\r\n".wp_domainize($_GET['searchname']);
}
?>