<?php
if($_GET['name']=='guest')
require("init.php");
else
require("header.php");
if(!isset($_GET['ac'])) die("-3");

if($_GET['ac']=='members') {
if(!isset($_GET['groupid'])) die("-4");
$q=mquery("select user, role from forum_groups_members where groupid=".(int)$_GET['groupid']." order by field(role,2,1,3,5,4), user");
$t="0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
$t.="\r\n".$r[0]."\r\n".$r[1];
echo $t;
}

if($_GET['ac'] == "join") {
if(!isset($_GET['groupid'])) die("-4");
$type=mysql_fetch_row(mquery("select open, recommended, public, name from forum_groups where id=".(int)$_GET['groupid']));
$open=$type[0];
$recommended=$type[1];
$public=$type[2];
$groupname=$type[3];
$status=0;
if(($open==0&&$public==0)&&(mysql_num_rows(mquery("select id from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=5"))==0))
die("-3");
if(mysql_num_rows(mquery("select id from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=5"))>0)
$status=1;
if($status==0 && (($open==0&&$public==1)||($open==1&&$public==0))) $status=4;
if($status==0) $status=1;
mquery("delete from forum_groups_members  where user='".$_GET['name']."' and groupid=".(int)$_GET['groupid']);
mquery("insert into forum_groups_members (user,groupid,role,joined) values ('".$_GET['name']."', ".(int)$_GET['groupid'].", ".(int)$status.", ".time().")");
if($recommended==0) {
$q=mquery("select user from forum_groups_members where role=2 and groupid=".(int)$_GET['groupid']);
while($r=mysql_fetch_row($q))
if($status==1)
message_send('elten', $r[0], 'New member of '.$groupname, "{$_GET['name']} has just joined {$groupname}.");
else
message_send('elten', $r[0], 'New user wants to join '.$groupname, "{$_GET['name']} wants to join {$groupname}.");
}
echo "0";
}

if($_GET['ac'] == "leave") {
if(!isset($_GET['groupid'])) die("-4");
$type=mysql_fetch_row(mquery("select open, public, recommended, name, founder from forum_groups where id=".(int)$_GET['groupid']));
$open=$type[0];
$public=$type[1];
$recommended=$type[2];
$groupname=$type[3];
$founder = $type[4];
if($_GET['name']==$founder) die("-3");
mquery("delete from forum_groups_members where user='".$_GET['name']."' and groupid=".(int)$_GET['groupid']);
if($open==0 && $public==0) {
mquery("delete from followedthreads where owner='".mysql_real_escape_string($_GET['name'])."' and thread in (select id from forum_threads where forum in (select name from forums where groupid=".(int)$_GET['groupid']."))");
mquery("delete from followedforums where owner='".mysql_real_escape_string($_GET['name'])."' and forum in (select name from forums where groupid=".(int)$_GET['groupid'].")");
}
if($recommended==0) {
$q=mquery("select user from forum_groups_members where role=2 and groupid=".(int)$_GET['groupid']);
while($r=mysql_fetch_row($q))
message_send('elten', $r[0], 'One of members has left '.$groupname, "{$_GET['name']} has just left {$groupname}.");
}
echo "0";
}

if($_GET['ac']=='privileges') {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder, id, name from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name']) die("-3");
$uq=mquery("select id, user, role from forum_groups_members where (role=1 or role=2) and user='".mysql_real_escape_string($_GET['user'])."' and groupid=".(int)$_GET['groupid']);
if(mysql_num_rows($uq)==0) die("-4");
$u=mysql_fetch_row($uq);
if($_GET['pr']=="moderationgrant") {
message_send("elten",$_GET['user'],"You were granted moderation permissions","{$_GET['name']} has granted you moderation permissions in group {$gr[2]}.");
mquery("update forum_groups_members set role=2 where id=".(int)$u[0]);
}
elseif($_GET['pr']=="moderationdeny") {
message_send("elten",$_GET['user'],"You were denied moderation permissions","{$_GET['name']} has denied you moderation permissions in group {$gr[2]}.");
mquery("update forum_groups_members set role=1 where id=".(int)$u[0]);
}
elseif($_GET['pr']=="passadmin") {
if($u[2]==2) {
mquery("update forum_groups set founder='".mysql_real_escape_string($_GET['user'])."' where id=".(int)$_GET['groupid']);
message_send("elten",$_GET['user'],"You were granted administration permissions","{$_GET['name']} has passed administration permissions in group {$gr[2]} to you.");
}
else
die("-3");
}
echo "0";
}

if($_GET['ac']=='user') {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder, recommended, name, public from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name'] and mysql_num_rows(mquery("select user from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=2"))==0 and !($gr[1]==1 and getprivileges($_GET['name'])[1]==1)) die("-3");
$uq=mquery("select id, user, role from forum_groups_members where user='".mysql_real_escape_string($_GET['user'])."' and groupid=".(int)$_GET['groupid']);
if(mysql_num_rows($uq)==0) die("-4");
$u=mysql_fetch_row($uq);
if($_GET['user']==$gr[0] or $u[2]==2) die("-3");
if($_GET['pr']=="ban") {
message_send("elten",$_GET['user'],"You have been banned in group","You have been banned in group {$gr[2]}.");
mquery("update forum_groups_members set role=3 where id=".(int)$u[0]);
}
elseif($_GET['pr']=="unban") {
message_send("elten",$_GET['user'],"You have been unbanned in group","You have been unbanned in group {$gr[2]}.");
mquery("update forum_groups_members set role=1 where id=".(int)$u[0]);
}
elseif($_GET['pr']=="kick") {
message_send("elten",$_GET['user'],"You were kicked out of the group","{$_GET['name']} has kicked you out of {$gr[2]}.");
mquery("delete from forum_groups_members where id=".(int)$u[0]);
if($gr[3]==0) {
mquery("delete from followedthreads where owner='".mysql_real_escape_string($_GET['user'])."' and thread in (select id from forum_threads where forum in (select name from forums where groupid=".(int)$_GET['groupid']."))");
mquery("delete from followedforums where owner='".mysql_real_escape_string($_GET['user'])."' and forum in (select name from forums where groupid=".(int)$_GET['groupid'].")");
}
}
elseif($_GET['pr']=="accept") {
message_send("elten",$_GET['user'],"Your request has been accepted","You have just joined {$gr[2]}.");
mquery("update forum_groups_members set role=1 where id=".(int)$u[0]);
}
elseif($_GET['pr']=="refuse") {
message_send("elten",$_GET['user'],"Your request has been refused","You have just left {$gr[2]}.");
mquery("delete from forum_groups_members where id=".(int)$u[0]);
}
echo "0";
}

if($_GET['ac']=='forumdelete') {
$q=mquery("select groupid from forums where name='".mysql_real_escape_string($_GET['forum'])."'");
if(mysql_num_rows($q)==0)
die("-4");
$groupid=mysql_fetch_row($q)[0];
$g=mysql_fetch_row(mquery("select id, recommended, founder from forum_groups where id=".(int)$groupid));
$qr=mquery("select user,role from forum_groups_members where user='".$_GET['name']."' and groupid=".(int)$groupid);
if(mysql_num_rows($qr)>0)
$role=mysql_fetch_row($qr)[1];
if($_GET['name']!=$_GET['founder'] and $role!=2 and !(getprivileges($_GET['name'])[1]==1 and $g[1]==1)) die("-3");
mquery("delete from forum_posts where thread in (select id from forum_threads where forum='".mysql_real_escape_string($_GET['forum'])."')");
mquery("delete from forum_read where thread in (select id from forum_threads where forum='".mysql_real_escape_string($_GET['forum'])."')");
mquery("delete from followedthreads where thread in (select id from forum_threads where forum='".mysql_real_escape_string($_GET['forum'])."')");
mquery("delete from mentions where thread in (select id from forum_threads where forum='".mysql_real_escape_string($_GET['forum'])."')");
mquery("delete from forum_threads where forum='".mysql_real_escape_string($_GET['forum'])."'");
mquery("delete from forums where name='".mysql_real_escape_string($_GET['forum'])."'");
mquery("delete from followedforums where forum='".mysql_real_escape_string($_GET['forum'])."'");
echo "0";
}

if($_GET['ac'] == 'forumcreate') {
if(!isset($_GET['groupid'])) die("-4");
$g=mysql_fetch_row(mquery("select id, recommended, founder, lang from forum_groups where id=".(int)$_GET['groupid']));
$qr=mquery("select user,role from forum_groups_members where user='".$_GET['name']."' and groupid=".(int)$_GET['groupid']);
if(mysql_num_rows($qr)>0)
$role=mysql_fetch_row($qr)[1];
if($_GET['name']!=$_GET['founder'] and $role!=2 and !(getprivileges($_GET['name'])[1]==1 and $g[1]==1)) die("-3");
$forumid=strtoupper($g[3])."_G_".$_GET['groupid']."_".time()."_".random_str(16);
$description=$_GET['forumdescription'];
if(isset($_GET['bufforumdescription'])) $description=buffer_get($_GET['bufforumdescription']);
mquery("insert into forums (name, fullname, description, type, groupid) values ('".mysql_real_escape_string($forumid)."', '".mysql_real_escape_string($_GET['forumname'])."', '".mysql_real_escape_string($description)."', ".(int)$_GET['forumtype'].", ".(int)$_GET['groupid'].")");
echo "0";
}

if($_GET['ac']=='forumedit') {
$q=mquery("select groupid from forums where name='".mysql_real_escape_string($_GET['forum'])."'");
if(mysql_num_rows($q)==0)
die("-4");
$groupid=mysql_fetch_row($q)[0];
$g=mysql_fetch_row(mquery("select id, recommended, founder from forum_groups where id=".(int)$groupid));
$qr=mquery("select user,role from forum_groups_members where user='".$_GET['name']."' and groupid=".(int)$groupid);
if(mysql_num_rows($qr)>0)
$role=mysql_fetch_row($qr)[1];
if($_GET['name']!=$_GET['founder'] and $role!=2 and !(getprivileges($_GET['name'])[1]==1 and $g[1]==1)) die("-3");
$description=$_GET['forumdescription'];
if(isset($_GET['bufforumdescription'])) $description=buffer_get($_GET['bufforumdescription']);
mquery("update forums set fullname='".mysql_real_escape_string($_GET['forumname'])."', description='".mysql_real_escape_string($description)."' where name='".mysql_real_escape_string($_GET['forum'])."'");
echo "0";
}

if($_GET['ac'] == 'forumchangepos') {
//die("-1");
$q=mquery("select groupid,id from forums where name='".mysql_real_escape_string($_GET['forum'])."'");
if(mysql_num_rows($q)==0)
die("-4");
$t=mysql_fetch_row($q);
$groupid=$t[0];
$fid=$t[1];
$g=mysql_fetch_row(mquery("select id, recommended, founder from forum_groups where id=".(int)$groupid));
$qr=mquery("select user,role from forum_groups_members where user='".$_GET['name']."' and groupid=".(int)$groupid);
if(mysql_num_rows($qr)>0)
$role=mysql_fetch_row($qr)[1];
if($_GET['name']!=$_GET['founder'] and $role!=2 and !(getprivileges($_GET['name'])[1]==1 and $g[1]==1)) die("-3");
$q=mquery("select id from forums where groupid=".(int)$groupid);
$ids=array();
while($r=mysql_fetch_row($q))
array_push($ids,$r[0]);
$dest=$ids[$_GET['position']];
$swaps=0;
$orig=null;
$oids=$ids;
while(($ids[$_GET['position']]!=$fid or $ids[$_GET['position']+1]!=$orig) and $swaps<100) {
++$swaps;
$i=array_search($fid,$ids);
if($orig==null) {
$orig=$ids[$_GET['position']];
}
$swap=array($oids[$i]);
$t=$ids[$i];
if($i>=$_GET['position']) {
$ids[$i]=$ids[$i-1];
$ids[$i-1]=$t;
$swap[1]=$oids[$i-1];
}
else {
$ids[$i]=$ids[$i+1];
$ids[$i+1]=$t;
$swap[1]=$oids[$i+1];
}
if($swap[0]==null or $swap[1]==null) break;
while(mysql_num_rows(mquery("select id from forums where id=0"))>0) sleep(0.2);
mquery("update forums set id=0 where id=".$swap[0]."");
mquery("update forums set id=".$swap[0]." where id=".$swap[1]);
mquery("update forums set id=".$swap[1]." where id=0");
}
echo "0";
}

if($_GET['ac']=="delete") {
if(!isset($_GET['groupid'])) die("-4");
$grq=mquery("select recommended, founder, name from forum_groups where id=".(int)$_GET['groupid']);
if(mysql_num_rows($grq)==0) die("-4");
$gr=mysql_fetch_row($grq);
if($_GET['name']!=$gr[1]) die("-3");
if(mysql_fetch_row(mquery("select count(*) from forums where groupid=".(int)$_GET['groupid']))[0]>0) die("-3");
mquery("delete from forum_groups_members where groupid=".(int)$_GET['groupid']);
mquery("delete from forum_groups where id=".(int)$_GET['groupid']);
echo "0";
}

if($_GET['ac'] == "create") {
$desc="";
if(isset($_GET['bufdescription']))
$desc=buffer_get($_GET['bufdescription']);
$groupid=(int)mysql_fetch_row(mquery("select max(id) from forum_groups"))[0]+1;
if($groupid<=1000) $groupid=1001;
mquery("insert into forum_groups (id,name,founder,description,lang,open,public,created) values (".(int)$groupid.", '".mysql_real_escape_string($_GET['groupname'])."', '".mysql_real_escape_string($_GET['name'])."', '".mysql_real_escape_string($desc)."', '".mysql_real_escape_string($_GET['lang'])."', ".(int)$_GET['open'].", ".(int)$_GET['public'].", ".(int)time().")");
mquery("insert into forum_groups_members (user,groupid,role,joined) values ('".mysql_real_escape_string($_GET['name'])."', ".(int)$groupid.", 2, ".(int)time().")");
echo "0";
}

if($_GET['ac'] == "invite") {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder, recommended from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name'] and mysql_num_rows(mquery("select user from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=2"))==0 and !($gr[1]==1 and getprivileges($_GET['name'])[1]==1)) die("-3");
$uq=mquery("select id, user, role from forum_groups_members where user='".mysql_real_escape_string($_GET['user'])."' and groupid=".(int)$_GET['groupid']);
if(mysql_num_rows($uq)>0) die("-5");
$type=mysql_fetch_row(mquery("select name from forum_groups where id=".(int)$_GET['groupid']));
$groupname=$type[0];
mquery("insert into forum_groups_members (user,groupid,role,joined) values ('".$_GET['user']."', ".(int)$_GET['groupid'].", 5, ".time().")");
message_send('elten', $_GET['user'], 'You have been invited to '.$groupname, "{$_GET['name']} has just invited you to {$groupname}.");
echo "0";
}

if($_GET['ac'] == "edit") {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name']) die("-3");
$desc="";
if(isset($_GET['bufdescription']))
$desc=buffer_get($_GET['bufdescription']);
mquery("update forum_groups set name='".mysql_real_escape_string($_GET['groupname'])."', description='".mysql_real_escape_string($desc)."', open=".(int)$_GET['open'].", public=".(int)$_GET['public']." where id=".(int)$_GET['groupid']);
}

if($_GET['ac'] == "size") {
$ausize=0;
$atsize=0;
$tsize=0;
$q=mquery("select post,attachments from forum_posts where thread in (select id from forum_threads where forum in (select name from forums where groupid=".(int)$_GET['groupid']."))");
while($r=mysql_fetch_row($q)) {
if(strpos($r[0],"\004AUDIO\004")===0)
$ausize+=filesize(preg_replace("~\004AUDIO\004/audioforums/posts/([a-zA-Z0-9\/]+)\004AUDIO\004~","audioforums/posts/$1",$r[0]));
if($r[1]!="")
foreach(explode(",", $r[1]) as $at)
$atsize+=filesize("attachments/".$at);
$tsize+=strlen($r[0]);
}
echo "0\r\n".$ausize."\r\n".$atsize."\r\n".$tsize;
}

if($_GET['ac']=="mostactive") {
$mc=date("m.Y");
$mp=date("m.Y",time()-30*86400);
$q=mquery("select author, count(author) as cnt from forum_posts where length(post)>50 and (date like '%$mc %' or date like '%$mp %') and thread in (select id from forum_threads where forum in (select name from forums where groupid=".(int)$_GET['groupid'].")) group by author order by cnt desc limit 0,10");
echo "0";
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0];
}

if($_GET['ac']=="regulations") {
if(!isset($_GET['groupid'])) die("-4");
$q=mquery("select regulations from forum_groups where id=".(int)$_GET['groupid']);
echo "0\r\n";
echo mysql_fetch_row($q)[0];
}

if($_GET['ac']=="editregulations") {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder, recommended, name from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name'] and mysql_num_rows(mquery("select user from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=2"))==0 and !($gr[1]==1 and getprivileges($_GET['name'])[1]==1)) die("-3");
$regulations=$_GET['regulations'];
if(isset($_GET['buf'])) $regulations=buffer_get($_GET['buf']);
mquery("update forum_groups set regulations='".mysql_real_escape_string($regulations)."' where id=".(int)$_GET['groupid']);
echo "0";
}

if($_GET['ac']=="motd") {
if(!isset($_GET['groupid'])) die("-4");
$q=mquery("select motd from forum_groups where id=".(int)$_GET['groupid']);
if($_GET['name']!="guest")
mquery("update forum_groups_members set motd_time=unix_timestamp() where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."'");
echo "0\r\n";
echo mysql_fetch_row($q)[0];
}

if($_GET['ac']=="editmotd") {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder, recommended, name from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name'] and mysql_num_rows(mquery("select user from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=2"))==0 and !($gr[1]==1 and getprivileges($_GET['name'])[1]==1)) die("-3");
$motd=$_GET['motd'];
if(isset($_GET['buf'])) $motd=buffer_get($_GET['buf']);
mquery("update forum_groups set motd='".mysql_real_escape_string($motd)."', motd_time=unix_timestamp() where id=".(int)$_GET['groupid']);
echo "0";
}
?>