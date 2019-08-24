<?php
require("header.php");
if($_GET['add']==1) {
if(strlen($_POST['data']) > 134217728*3) {
echo "-3";
die;
}
$filename=random_str(24);
mquery("INSERT INTO `uploads` (filename,file,owner) VALUES ('".mysql_real_escape_string($_GET['filename'])."','".$filename."','".$_GET['name']."')");
$fp = fopen("uploads/".$filename,"w");
fwrite($fp,$_POST['data']);
fclose($fp);
echo "0\r\n".$filename;
}
if($_GET['del'] == 1) {
$q = mquery("SELECT `file` FROM `uploads` WHERE `owner`='".$_GET['name']."' AND `file`='".mysql_real_escape_string($_GET['file'])."'");
if(mysql_num_rows($q)==0) {
echo "-4";
die;
}
mquery("DELETE FROM `uploads` WHERE `owner`='".$_GET['name']."' AND `file`='".mysql_real_escape_string($_GET['file'])."'");
unlink("uploads/".$_GET['file']);
echo "0";
}
?>