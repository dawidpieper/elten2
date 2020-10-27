<?php
require("header.php");
require("blog_base.php");
if($_GET['client']==1)
//mquery("delete from notifications where receiver='{$_GET['name']}'");
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
$wq=mquery("select owner,messages,followedthreads,followedblogs,blogcomments,followedforums,followedforumsthreads,friends,birthday,mentions,followedblogposts from whatsnew_config where owner='".$_GET['name']."'");
$wnc=[$_GET['name'],0,0,0,0,0,2,0,0,0,0];
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
if((($_GET['client']==1 and $wnc[3]==0) or ($_GET['client']!=1 and $wnc[3]<2))) {
$n=0;
$q = mquery("select blog, postid, postsread from blogs_postsread where owner='".mysql_real_escape_string($_GET['name'])."'");
$known = array();
while($r=mysql_fetch_row($q)) {
if(!wp_iseltenblog($r[0])) continue;
$d=wp_domainize($r[0]);
if(!isset($known[$d])) $known[$d]=array();
$c=(int)($r[2]-1);
if($c<0) $c=0;
$known[$d][(int)$r[1]]=$c;
}
$followed=array();
$q = mquery("select blog from blogs_followed where owner='".mysql_real_escape_string($_GET['name'])."'");
while($r=mysql_fetch_row($q)) {
$d = wp_domainize($r[0]);
array_push($followed, $d);
}
$allposts = wp_query("GET", "/elten/allposts", "", array('filter_domains'=>$followed, 'filter_users'=>wp_userid($_GET['name'])));
$q = mquery("select blog from blogs_followed where owner='".mysql_real_escape_string($_GET['name'])."'");
foreach($followed as $d) {
foreach($allposts[$d] as $id=>$cnt)
if(!isset($known[$d][$id])) ++$n;
}
$ret.=$n."\r\n";
}
else
$ret.="0\r\n";
if((($_GET['client']==1 and $wnc[4]==0) or ($_GET['client']!=1 and $wnc[4]<2))) {
$n=0;
if(!isset($allposts)) $allposts = wp_query("GET", "/elten/allposts", "", array('filter_users'=>wp_userid($_GET['name'])));
$blogs = wp_query("GET", "/elten/blogs", "", array('filter_users'=>wp_userid($_GET['name'])));
$domains = array();
foreach($blogs as $b) array_push($domains, $b['domain']);
if(!isset($known)) {
$q = mquery("select blog, postid, postsread from blogs_postsread where owner='".mysql_real_escape_string($_GET['name'])."'");
$known = array();
while($r=mysql_fetch_row($q)) {
if(!wp_iseltenblog($r[0])) continue;
$d=wp_domainize($r[0]);
if(!isset($known[$d])) $known[$d]=array();
$known[$d][(int)$r[1]]=(int)($r[2]-1);
}
}
foreach($domains as $d)
foreach($allposts[$d] as $p=>$c) {
$e=$c-($known[$d][$p]);
if($e>0) $n+=$e;
}
$ret.=$n."\r\n";
}
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[5]==0) or ($_GET['client']!=1 and $wnc[5]<2))
$ret.=mysql_num_rows(mquery("select id from forum_threads where forum in (select forum from followedforums where owner='".$_GET['name']."') and id not in (select thread from forum_read where owner='".$_GET['name']."')"))."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[6]==0) or ($_GET['client']!=1 and $wnc[6]<2))
$ret.=(int)mysql_fetch_row(mquery("select (select count(*) from forum_posts where thread in (select id from forum_threads where forum in (select forum from followedforums where owner='{$_GET['name']}')))-(select sum(posts) from forum_read where thread in (select id from forum_threads where forum in (select forum from followedforums where owner='{$_GET['name']}')) and owner='{$_GET['name']}')"))[0]."\r\n";
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
$ret.=mysql_num_rows(mquery("select id from mentions where noticed is null and user='".$_GET['name']."'  and thread in (select id from forum_threads where forum in (select name from forums where groupid in (select groupid from forum_groups_members where (role=1 or role=2) and user='".$_GET['name']."') or groupid in (select id from forum_groups where public=1)))"))."\r\n";
else
$ret.="0\r\n";
if(($_GET['client']==1 and $wnc[9]==0) or ($_GET['client']!=1 and $wnc[10]<2)) {
foreach($blogs as $b) array_push($domains, $b['domain']);
if(!isset($known)) {
$n=0;
$q = mquery("select blog, postid, postsread from blogs_postsread where owner='".mysql_real_escape_string($_GET['name'])."'");
$known = array();
while($r=mysql_fetch_row($q)) {
if(!wp_iseltenblog($r[0])) continue;
$d=wp_domainize($r[0]);
if(!isset($known[$d])) $known[$d]=array();
$known[$d][(int)$r[1]]=(int)($r[2]-1);
}
}
$fpblogs=array();
$fdomains=array();
$q=mquery("select blog, postid from blogs_postsfollowed where owner='".mysql_real_escape_string($_GET['name'])."'");
while($r=mysql_fetch_row($q)) {
if(!isset($fpblogs[$r[0]])) {
$fpblogs[$r[0]]=array();
array_push($fdomains, wp_domainize($r[0]));
}
array_push($fpblogs[$r[0]], $r[1]);
}
$posts = array();
$fallposts = wp_query("GET", "/elten/allposts", "", array('filter_domains'=>$fdomains));
foreach($fpblogs as $b=>$a) {
$suc=false;
foreach($fallposts as $bl=>$cl) if($bl==wp_domainize($b)) $suc=true;
if($suc==false) continue;
foreach($a as $p) {
$c=$fallposts[wp_domainize($b)][$p]-$known[wp_domainize($b)][$p];
if($c>0) $n+=$c;
}
}
$ret.=$n."\r\n";
}
else
$ret.="0\r\n";
echo $ret;
?>