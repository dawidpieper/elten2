<?php
require("header.php");
if(strlen($_POST['avatar']) > 33554432*3) {
echo "-1";
die;
}
if(strpos($_GET['name'],"/") !== false) die("-1");
if(strpos($_GET['name'],".php") !== false) die("-1");
$fp = fopen("avatars/".$_GET['name'],"w");
fwrite($fp,$_POST['avatar']);
fclose($fp);
echo "0";
?>