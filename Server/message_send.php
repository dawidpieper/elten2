<?php
require("header.php");
if(file_exists("cache/messages_".$_GET['name'].".dat")) unlink("cache/messages_".$_GET['name'].".dat");
if(file_exists("cache/messages_".$_GET['to'].".dat")) unlink("cache/messages_".$_GET['to'].".dat");
$text = $_GET['text'];
if($_GET['buffer'] != null)
$text=buffer_get($_GET['buffer']);
if($_GET['audio']==1) {
if(strlen($_POST['data']) < 8) {
die("-1");
}
$filename=random_str(24);
if(substr($_POST['data'],0,4)=="OggS") {
$fp = fopen("audiomessages/".$filename,"w");
fwrite($fp,$_POST['data']);
fclose($fp);
}
else {
$fp = fopen("audiomessages/tmp_".$filename,"w");
fwrite($fp,$_POST['data']);
fclose($fp);
shell_exec("/usr/bin/ffmpeg -i \"audiomessages/tmp_".$filename."\" -f opus -b:a 96k \"audiomessages/{$filename}\" 2>&1");
unlink("audiomessages/tmp_".$filename);
}
$text="\004AUDIO\004/audiomessages/".$filename."\004AUDIO\004\r\n";
}
$attachments=$_GET['attachments'];
if($_GET['bufatt']!=NULL)
$attachments=buffer_get($_GET['bufatt']);
$mth='/^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}$/';
if(preg_match($mth, $_GET['to'])) {
$fromname=$_GET['name'];
$q=mquery("SELECT `fullname` FROM `profiles` WHERE `name`='".$_GET['name']."'");
if(mysql_num_rows($q)>0)
$fromname=mysql_fetch_row($q)[0];
$uid = md5(uniqid(time()));
$version=mysql_fetch_row(mquery("select version from tokens where token='".$_GET['token']."'"))[0];
$head = "MIME-Version: 1.0\r\nContent-Type: multipart/mixed; boundary=\"".$uid."\"\r\nFrom: {$fromname} <{$_GET['name']}@elten-net.eu>\r\nUser-Agent: Elten {$version}\r\n\r\n";
$body = "--".$uid."\r\nContent-type:text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: 8bit\r\n\r\n".str_replace("\004LINE\004","\r\n",$text)."\r\n\r\n";
$att=explode(",",$attachments);
foreach($att as $attach) {
if($attach != NULL) {
$filename=mysql_fetch_row(mquery("SELECT name FROM attachments WHERE id='".$attach."'"))[0];
$body .= "--".$uid."\r\nContent-Type: application/octet-stream; name=\"".$filename."\"\r\nContent-Transfer-Encoding: base64\r\nContent-Disposition: attachment; filename=\"".$filename."\"\r\n\r\n";
$content = file_get_contents("/var/www/html/attachments/".$attach);
$body.=chunk_split(base64_encode($content))."\r\n\r\n";
}
}
$body .= "--".$uid."--";
mail($_GET['to'], "=?UTF-8?B?" . base64_encode($_GET['subject']) . "?=", $body, $head,"-f{$_GET['name']}@elten-net.eu");
mquery("INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent,`read`,attachments) VALUES ('', '" . $_GET['name'] . "', '" . $_GET['to'] . "', '" . $_GET['subject'] . "', '" . $text . "', '" . time() . "',0,0,".time().",'".$attachments."')");
}
else {
if(mysql_num_rows(mquery("select user from blacklist where owner='".$_GET['to']."' and user='".$_GET['name']."'"))>0)
die("-3");
if(mysql_num_rows(mquery("select name from users where name='".$_GET['to']."'"))==0)
die("-4");
mquery("INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, deletedfromreceived, deletedfromsent, attachments) VALUES ('', '" . $_GET['name'] . "', '" . $_GET['to'] . "', '" . $_GET['subject'] . "', '" . $text . "', '" . time() . "',0,0,'".$attachments."')");
}
echo "0";
?>