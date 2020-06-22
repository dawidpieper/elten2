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
if($_GET['ac']=="get") {
$profile = wp_query("GET", "/elten/profile/".(int)wp_userid($_GET['name']));
echo "0\r\n".json_encode(utf8ize($profile), JSON_INVALID_UTF8_IGNORE|JSON_UNESCAPED_UNICODE );
}
elseif($_GET['ac']=="set") {
$js="";
if(isset($_GET['buffer'])) $js=buffer_get($_GET['buffer']);
if(!isJson($js)) die("-3");
$j = json_decode($js, true);
wp_query("POST", "/elten/profile/".wp_userid($_GET['name']), "", $j);
echo "0";
}
elseif($_GET['ac']=="changepassword") {
if(mysql_num_rows(mquery("select name from users where name='".mysql_real_escape_string($_GET['name'])."' and password='".mysql_real_escape_string($_GET['eltenpassword'])."'"))==0) die("-3");
print_r(wp_query("POST", "/elten/password/".wp_userid($_GET['name']), "", array('password'=>$_GET['wppassword'])));
echo "0";
}
?>