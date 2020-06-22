<?php
require("header.php");
require("blog_base.php");
function isJson($string) {
json_decode($string);
return (json_last_error() == JSON_ERROR_NONE);
}
function utf8ize($d) {
    if (is_array($d)) 
        foreach ($d as $k => $v) 
            $d[$k] = utf8ize($v);

     else if(is_object($d))
        foreach ($d as $k => $v) 
            $d->$k = utf8ize($v);
     else if (is_string ($d))
return mb_convert_encoding($d, "UTF-8");

    return $d;
}
$searchname=$_GET['name'];
if(isset($_GET['searchname'])) {
$searchname=$_GET['searchname'];
if(!in_array($_GET['name'],blogowners($searchname))) die("-3");
}
if($_GET['ac']=="get") {
$options = wp_query("GET", "/elten/blogoptions", $searchname);
$languages = wp_query("GET", "/elten/languages", $searchname);
$timezones = wp_query("GET", "/elten/timezones", $searchname);
echo "0\r\n".json_encode(utf8ize($options), JSON_INVALID_UTF8_IGNORE|JSON_UNESCAPED_UNICODE )."\r\n".json_encode(utf8ize($languages), JSON_INVALID_UTF8_IGNORE|JSON_UNESCAPED_UNICODE )."\r\n".json_encode(utf8ize($timezones), JSON_INVALID_UTF8_IGNORE|JSON_UNESCAPED_UNICODE );
}
elseif($_GET['ac']=="set") {
$js="";
if(isset($_GET['buffer'])) $js=buffer_get($_GET['buffer']);
if(!isJson($js)) die("-3");
$j = json_decode($js, true);
wp_query("POST", "/elten/blogoptions", $searchname, $j);
echo "0";
}
?>