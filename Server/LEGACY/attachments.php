<?php
require("header.php");
if($_GET['add']==1) {
if(strlen($_POST['data']) > 134217728*3) {
echo "-3";
die;
}
$filename=random_str(128);
mquery("INSERT INTO `attachments` (id,name,uploadtime) VALUES ('".$filename."','".str_replace("\'","",mysql_real_escape_string($_GET['filename']))."',".time().")");
$fp = fopen("attachments/".$filename,"w");
fwrite($fp,$_POST['data']);
fclose($fp);
echo "0\r\n".$filename;
}
if($_GET['info'] == 1) {
$r=mysql_fetch_row(mquery("SELECT `id`,`name` FROM `attachments` WHERE `id`='".mysql_real_escape_string($_GET['id'])."'"));
echo "0\r\n".$r[0]."\r\n".$r[1]."\r\n";
}
?>