<?php
require("init.php");
$q = mquery("SELECT `name`, `date` FROM `actived` where name='".$_GET['searchname']."' ORDER BY `date` ASC");
$lastseen = 0;
while($wiersz = mysql_fetch_row($q)) {
if($wiersz[0] == $_GET['searchname'])
$lastseen = $wiersz[1];
}
$q = mquery("SELECT `owner`, `name` FROM `blogs`");
$suc = false;
while ($wiersz = mysql_fetch_row($q)){
if($wiersz[0] == $_GET['searchname'])
$suc = true;
}
$hasblog = 0;
if($suc == false)
$hasblog =  0;
else
$hasblog =  1;
$q = mquery("SELECT `user` FROM `contacts` WHERE `owner`='".$_GET['searchname']."'");
$knows = 0;
$knows = mysql_num_rows($q);
$q = mquery("SELECT `owner` FROM `contacts` WHERE `user`='".$_GET['searchname']."'");
$knownby = 0;
$knownby = mysql_num_rows($q);
$q = mquery("SELECT `version`,`versiontype`,`beta` FROM `logins` WHERE `versiontype`!='WEB' AND versiontype!='API' AND `name`='".$_GET['searchname']."' ORDER BY `time` DESC");
$r=mysql_fetch_row($q);
$version = $r[0];
if($r[1]!="")
$version.=" ".$r[1]." ".$r[2];
$q = mquery("SELECT DISTINCT `poll` FROM `polls_answers` WHERE `author`='".$_GET['searchname']."'");
$polls=mysql_num_rows($q);
$q = mquery("SELECT `id`,`time` FROM `logins` WHERE `name`='".$_GET['searchname']."' and time!='' ORDER BY `id` ASC");
$registered=0;
if(mysql_num_rows($q)>0)
$registered=mysql_fetch_row($q)[1];
$q = mquery("SELECT `id`,`date` FROM `forum_posts` WHERE `author`='".$_GET['searchname']."' ORDER BY `id` ASC");
if(mysql_num_rows($q)>0)
$fregistered=date("U",strtotime(mysql_fetch_row($q)[1]));
$q = mquery("SELECT `id`,`date` FROM `messages` WHERE `sender`='".$_GET['searchname']."' OR `receiver`='".$_GET['searchname']."' ORDER BY `id` ASC");
if(mysql_num_rows($q)>0)
$mregistered=mysql_fetch_row($q)[1];
if(($mregistered<$registered or $registered==0) and $mregistered>0)
$registered=$mregistered;
if(($fregistered<$registered or $registered==0) and $fregistered>0)
$registered=$fregistered;

echo "0\r\n".$lastseen."\r\n".$hasblog."\r\n".$knows."\r\n".$knownby."\r\n".$version."\r\n".$registered."\r\n".$polls;
?>