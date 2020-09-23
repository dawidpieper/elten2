<?php
require("header.php");
if(mysql_num_rows(mquery("SELECT name FROM banned WHERE name='".$_GET['name']."' AND totime<".time()))>0) die(-3);
if($_GET['recv'] == 1) {
$q = mquery("SELECT `name`, `date` FROM `chat_actived`");
$suc = false;
while ($r=mysql_fetch_row($q))
if($r[0] == $_GET['name']) {
$name = $r[0];
$date_t = $r[1];
$suc = true;
}
if($suc == false)
mquery("INSERT INTO `chat_actived` (name, date) VALUES ('" . $_GET['name'] . "','" . $cdate . "')");
else
mquery("UPDATE `chat_actived` SET `name` = '" . $_GET['name'] . "', `date` ='" . $cdate . "'  WHERE `name`='" . $_GET['name'] . "'");
$q=mquery("SELECT sender,message from chat order by id desc");
$r=mysql_fetch_row($q);
echo "0\r\n".$r[0].": ".$r[1];
}
if($_GET['send'] == 1) {
if($_GET['text']==NULL)
$message=buffer_get($_GET['buffer']);
else
$message=$_GET['text'];
mquery("INSERT INTO chat (sender,time,message) VALUES ('".$_GET['name']."',".(microtime(true)*1000000).",'".mysql_real_escape_string($message)."')");
$message=str_replace("\r\n"," ",$message);
echo "0";
}
if($_GET['hst']==1) {
$q=mquery("SELECT sender,message from chat where `time`>".(time()-3600)." order by id asc");
$cnt=0;
$text="";
while($r=mysql_fetch_row($q))
$text.="\r\n".$r[0].": ".$r[1];
echo "0".$text;
}
?>