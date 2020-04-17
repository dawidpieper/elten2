<?php
require("header.php");
if($_GET['client']==1)
mquery("delete from notifications where receiver='{$_GET['name']}'");
$shown=0;
if($_GET['shown']==1) $shown=1;
mquery("INSERT INTO `actived` (name, date, shown, actived) VALUES ('" . $_GET['name'] . "','" . time() . "', ".(int)$shown.",1) ON DUPLICATE KEY UPDATE name=VALUES(name),date=VALUES(DATE),shown=VALUES(shown),actived=values(actived)");
$ret="0\r\n";
$ret.=time()."\r\n";
$versionini=parse_ini_file("/var/www/html/srv/bin/elten.ini");
$ret.=$versionini['Version']."\r\n".$versionini['Beta']."\r\n".$versionini['Alpha']."\r\n";
$q=mquery("select fullname, gender from profiles where name='".$_GET['name']."'");
if(mysql_num_rows($q)>0) {
$r=mysql_fetch_row($q);
$ret.=$r[0]."\r\n".$r[1]."\r\n";
}
else
$ret.="\r\n-1\r\n";
if($_GET['chat']==1) {
mquery("INSERT INTO `chat_actived` (name, date) VALUES ('" . $_GET['name'] . "','".time()."') ON DUPLICATE KEY UPDATE name=VALUES(name),date=VALUES(DATE)");
$q=mquery("SELECT sender,message from chat order by id desc limit 0,1");
$r=mysql_fetch_row($q);
$ret.=$r[0].": ".$r[1]."\r\n";
}
else
$ret.="\r\n";
$wq=mquery("select owner,messages,followedthreads,followedblogs,blogcomments,followedforums,followedforumsthreads,friends,birthday,mentions from whatsnew_config where owner='".$_GET['name']."'");
$wnc=[$_GET['name'],0,0,0,0,0,2,0,0,0];
if(mysql_num_rows($wq)>0)
$wnc=mysql_fetch_row($wq);
if(($_GET['client']==1 and $wnc[1]==0) or ($_GET['client']!=1 and $wnc[1]<2))
$ret.=mysql_fetch_row(mquery("select count(*) from messages where deletedfromreceived!=1 and ((receiver='".$_GET['name']."' and `read` is null) or (receiver in (select groupid from messages_groups_members where user='".mysql_real_escape_string($_GET['name'])."') and id not in (select message from messages_read where user='".mysql_real_escape_string($_GET['name'])."'))) and noticed is null"))[0]."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[2]==0) or ($_GET['client']!=1 and $wnc[2]<2))
$ret.=mysql_fetch_row(mquery("select (select count(*) from forum_posts where thread in (select thread from followedthreads where thread in (select id from forum_threads where forum in (select name from forums where groupid in (select groupid from forum_groups_members where (role=1 or role=2) and user='{$_GET['name']}') or groupid in (select id from forum_groups where public=1))) and owner='{$_GET['name']}'))-(select sum(posts) from forum_read where thread in (select id from forum_threads where forum in (select name from forums where groupid in (select groupid from forum_groups_members where (role=1 or role=2) and user='{$_GET['name']}') or groupid in (select id from forum_groups where public=1))) and thread in (select thread from followedthreads where owner='{$_GET['name']}') and owner='{$_GET['name']}')"))[0]."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[3]==0) or ($_GET['client']!=1 and $wnc[3]<2))
$ret.=mysql_fetch_row(mquery("select(
select count(*) from blog_posts where owner in (select author from followedblogs where owner='{$_GET['name']}') and posttype=0
)-(
select count(*) from blog_read where owner='{$_GET['name']}' and author in (select author from followedblogs where owner='{$_GET['name']}')
)"))[0]."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[4]==0) or ($_GET['client']!=1 and $wnc[4]<2))
$ret.=mysql_fetch_row(mquery("select (SELECT count(*) FROM `blog_posts` WHERE `owner`='".$_GET['name']."')-(SELECT SUM(`posts`) FROM `blog_read` WHERE `owner`='".$_GET['name']."' AND `author`='".$_GET['name']."' AND `post` IN (SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['name']."'))"))[0]."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[5]==0) or ($_GET['client']!=1 and $wnc[5]<2))
$ret.=mysql_num_rows(mquery("select id from forum_threads where forum in (select forum from followedforums where owner='".$_GET['name']."') and id not in (select thread from forum_read where owner='".$_GET['name']."')"))."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[6]==0) or ($_GET['client']!=1 and $wnc[6]<2))
$ret.=mysql_fetch_row(mquery("select (select count(*) from forum_posts where thread in (select id from forum_threads where forum in (select forum from followedforums where owner='{$_GET['name']}')))-(select sum(posts) from forum_read where thread in (select id from forum_threads where forum in (select forum from followedforums where owner='{$_GET['name']}')) and owner='{$_GET['name']}')"))[0]."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[7]==0) or ($_GET['client']!=1 and $wnc[7]<2))
$ret.=mysql_num_rows(mquery("select owner from contacts where user='".$_GET['name']."' and noticed is null"))."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[8]==0) or ($_GET['client']!=1 and $wnc[8]<2))
$ret.=mysql_num_rows(mquery("select name from profiles where name in (select user from contacts where (birthdaynotice is null or birthdaynotice!=".date("Ymd").") and owner='".$_GET['name']."') and birthdatemonth=".(int) date("m")." and birthdateday=".(int) date("d")))."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[9]==0) or ($_GET['client']!=1 and $wnc[9]<2))
$ret.=mysql_num_rows(mquery("select id from mentions where noticed is null and user='".$_GET['name']."'  and thread in (select id from forum_threads where forum in (select name from forums where groupid in (select groupid from forum_groups_members where (role=1 or role=2) and user='".$_GET['name']."') or groupid in (select id from forum_groups where public=1)))"));
else
$ret.="0\r\n";
echo $ret;
?>