<?php
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
$ret=array();
$groupids=array();
$ret['groups']=array();
$q=mquery("select g.id, g.name, g.founder, g.description, g.lang, g.recommended, g.open, g.public, m.role, count(distinct p.author) from forum_groups g left join forum_groups_members as m on g.id=m.groupid and m.user='".mysql_real_escape_string($_GET['name'])."' left join forums f on g.id=f.groupid left join forum_threads t on t.forum=f.name left join forum_posts p on p.thread=t.id group by g.id");
while($r=mysql_fetch_row($q)) {
$g=array('id'=>(int)$r[0], 'name'=>$r[1], 'founder'=>$r[2], 'description'=>$r[3], 'lang'=>$r[4], 'recommended'=>(int)$r[5], 'open'=>(int)$r[6], 'public'=>(int)$r[7], 'role'=>(int)$r[8], 'cnt_forums'=>0, 'cnt_threads'=>0, 'cnt_posts'=>0, 'cnt_readposts'=>0, 'acmembers'=>(int)($r[9]));
$ret['groups'][$g['id']]=$g;
if($g['role']>0 or $g['public']==1) array_push($groupids,$g['id']);
}
$ret['forums']=array();
$forumids=array();
$q=mquery("select name, fullname, type, groupid, description from forums where groupid in (".implode(',',$groupids).")");
while($r=mysql_fetch_row($q)) {
$f=array('id'=>$r[0], 'name'=>$r[1], 'type'=>$r[2], 'groupid'=>$r[3], 'description'=>$r[4], 'followed'=>0, 'cnt_threads'=>0, 'cnt_posts'=>0, 'cnt_readposts'=>0);
$ret['forums'][$f['id']]=$f;
++$ret['groups'][$f['groupid']]['cnt_forums'];
array_push($forumids,$r[0]);
}
$ret['threads']=array();
$threadids=array();
$q=mquery("select id, name, forum, pinned, closed from forum_threads where forum in ('".implode("','",$forumids)."') order by lastpostdate desc");
while($r=mysql_fetch_row($q)) {
$t=array('id'=>(int)$r[0], 'name'=>$r[1], 'author'=>null, 'forumid'=>$r[2], 'followed'=>0, 'cnt_posts'=>0, 'cnt_readposts'=>0, 'pinned'=>$r[3], 'closed'=>$r[4]);
$t['type']=$ret['forums'][$t['forumid']]['type'];
++$ret['forums'][$t['forumid']]['cnt_threads'];
++$ret['groups'][$ret['forums'][$t['forumid']]['groupid']]['cnt_threads'];
array_push($threadids,$t['id']);
$ret['threads'][$r[0]]=$t;
}
$q=mquery("select thread, count(thread), author as cnt from forum_posts where thread in (".implode(",",$threadids).") group by thread");
while($r=mysql_fetch_row($q)) {
$ret['threads'][$r[0]]['cnt_posts']+=$r[1];
$ret['threads'][$r[0]]['author']=$r[2];
$ret['forums'][$ret['threads'][$r[0]]['forumid']]['cnt_posts']+=$r[1];
$ret['groups'][$ret['forums'][$ret['threads'][$r[0]]['forumid']]['groupid']]['cnt_posts']+=$r[1];
}
$q=mquery("select thread, posts from forum_read where owner='".mysql_real_escape_string($_GET['name'])."' and thread in (".implode(",",$threadids).")");
while($r=mysql_fetch_row($q)) {
$ret['threads'][$r[0]]['cnt_readposts']+=$r[1];
$ret['forums'][$ret['threads'][$r[0]]['forumid']]['cnt_readposts']+=$r[1];
$ret['groups'][$ret['forums'][$ret['threads'][$r[0]]['forumid']]['groupid']]['cnt_readposts']+=$r[1];
}
$q=mquery("select thread from followedthreads where owner='".mysql_real_escape_string($_GET['name'])."' and thread in (".implode(",",$threadids).")");
while($r=mysql_fetch_row($q))
$ret['threads'][$r[0]]['followed']=1;
$q=mquery("select forum from followedforums where owner='".mysql_real_escape_string($_GET['name'])."' and forum in ('".implode("','",$forumids)."')");
while($r=mysql_fetch_row($q))
$ret['forums'][$r[0]]['followed']=1;
echo "0\r\n";
foreach($ret as $k=>$c) {
echo "{$k}\r\n";
echo sizeof($c)."\r\n";
echo sizeof(array_values($c)[0])."\r\n";
foreach($c as $b)
foreach($b as $a)
echo str_replace("\r\n","$",$a)."\r\n";
}
?>