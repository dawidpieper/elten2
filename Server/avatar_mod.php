<?php
require("header.php");
if(strlen($_POST['avatar']) > 33554432*3) {
echo "-1";
die;
}
$fp = fopen("avatars/".$_GET['name'],"w");
fwrite($fp,$_POST['avatar']);
fclose($fp);
echo "0";
?>