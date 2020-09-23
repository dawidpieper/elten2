<?php
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
require("blog_base.php");
if($_GET['stateonly']==0)
$lastseen = mysql_fetch_row(mquery("SELECT max(date) FROM `actived` where name='".mysql_real_escape_string($_GET['searchname'])."'"))[0];
$hasblog=(int)wp_doeshaveblog($_GET['searchname']);
if($_GET['stateonly']==0)
$knows = mysql_fetch_row(mquery("SELECT count(*) FROM `contacts` WHERE `owner`='".mysql_real_escape_string($_GET['searchname'])."'"))[0];
if($_GET['stateonly']==0)
$knownby = mysql_fetch_row(mquery("SELECT count(*) FROM `contacts` WHERE `user`='".mysql_real_escape_string($_GET['searchname'])."'"))[0];
if($_GET['stateonly']==0)
$version = mysql_fetch_row(mquery("SELECT version FROM `logins` where version>0 and `name`='".mysql_real_escape_string($_GET['searchname'])."' order by id desc limit 1"))[0];
$polls = mysql_fetch_row(mquery("SELECT count(DISTINCT `poll`) FROM `polls_answers` WHERE `author`='".mysql_real_escape_string($_GET['searchname'])."'"))[0];
if($_GET['stateonly']==0) {
$registered = mysql_fetch_row(mquery("SELECT min(`time`) FROM `logins` WHERE `name`='".mysql_real_escape_string($_GET['searchname'])."'"))[0];
if($registered==0) {
$q = mquery("SELECT `id`,`date` FROM `forum_posts` WHERE `author`='".mysql_real_escape_string($_GET['searchname'])."' ORDER BY `id` ASC limit 1");
if(mysql_num_rows($q)>0)
$fregistered=date("U",strtotime(mysql_fetch_row($q)[1]));
$mregistered = mysql_fetch_row(mquery("SELECT min(date) FROM `messages` WHERE `sender`='".mysql_real_escape_string($_GET['searchname'])."' OR `receiver`='".mysql_real_escape_string($_GET['searchname'])."' and date>0 and concat('',date * 1) = date"))[0];
if(($mregistered<$registered or $registered==0) and $mregistered>0)
$registered=$mregistered;
if(($fregistered<$registered or $registered==0) and $fregistered>0)
$registered=$fregistered;
}
}
if($_GET['stateonly']==0)
$forumposts = mysql_fetch_row(mquery("select count(*) from forum_posts where author='".mysql_real_escape_string($_GET['searchname'])."'"))[0];
if($_GET['name']=="guest")
$incontacts=0;
else
$incontacts=mysql_fetch_row(mquery("select count(*) from contacts where user='".mysql_real_escape_string($_GET['searchname'])."' and owner='".mysql_real_escape_string($_GET['name'])."'"))[0];
$hasavatar=((int)file_exists("avatars/".$_GET['searchname']));
$isbanned=mysql_fetch_row(mquery("select count(*) from banned where name='".mysql_real_escape_string($_GET['searchname'])."' and totime>unix_timestamp()"))[0];
$honors=mysql_fetch_row(mquery("select count(*) from users_honors where user='".mysql_real_escape_string($_GET['searchname'])."'"))[0];
echo "0\r\n".$lastseen."\r\n".$hasblog."\r\n".$knows."\r\n".$knownby."\r\n".$version."\r\n".$registered."\r\n".$polls."\r\n".$forumposts."\r\n".$incontacts."\r\n".$hasavatar."\r\n".$isbanned."\r\n".$honors;
?>