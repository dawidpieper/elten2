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
if(($open==0&&$public==0)&&(mysql_num_rows(mquery("select id from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=5"))==0)) die("-3");
$status=1;
if(($open==0&&$public==1)||($open==1&&$public==0)) $status=4;
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
$type=mysql_fetch_row(mquery("select open, recommended, name, founder from forum_groups where id=".(int)$_GET['groupid']));
$open=$type[0];
$recommended=$type[1];
$groupname=$type[2];
$founder = $type[3];
if($_GET['name']==$founder) die("-3");
mquery("delete from forum_groups_members where user='".$_GET['name']."' and groupid=".(int)$_GET['groupid']);
if($recommended==0) {
$q=mquery("select user from forum_groups_members where role=2 and groupid=".(int)$_GET['groupid']);
while($r=mysql_fetch_row($q))
message_send('elten', $r[0], 'One of members has left '.$groupname, "{$_GET['name']} has just left {$groupname}.");
}
echo "0";
}

if($_GET['ac']=='privileges') {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name']) die("-3");
$uq=mquery("select id, user, role from forum_groups_members where user='".mysql_real_escape_string($_GET['user'])."' and groupid=".(int)$_GET['groupid']);
if(mysql_num_rows($uq)==0) die("-4");
$u=mysql_fetch_row($uq);
if($_GET['pr']=="moderationgrant")
mquery("update forum_groups_members set role=2 where id=".(int)$u[0]);
elseif($_GET['pr']=="moderationdeny")
mquery("update forum_groups_members set role=1 where id=".(int)$u[0]);
elseif($_GET['pr']=="passadmin") {
if($u[2]==2)
mquery("update forum_groups set founder='".mysql_real_escape_string($_GET['user'])."' where id=".(int)$_GET['groupid']);
else
die("-3");
}
echo "0";
}

if($_GET['ac']=='user') {
if(!isset($_GET['groupid'])) die("-4");
$gr=mysql_fetch_row(mquery("select founder, recommended, name from forum_groups where id=".(int)$_GET['groupid']));
if($gr[0]!=$_GET['name'] and mysql_num_rows(mquery("select user from forum_groups_members where groupid=".(int)$_GET['groupid']." and user='".mysql_real_escape_string($_GET['name'])."' and role=2"))==0 and !($gr[1]==1 and getprivileges($_GET['name'])[1]==1)) die("-3");
$uq=mquery("select id, user, role from forum_groups_members where user='".mysql_real_escape_string($_GET['user'])."' and groupid=".(int)$_GET['groupid']);
if(mysql_num_rows($uq)==0) die("-4");
$u=mysql_fetch_row($uq);
if($_GET['user']==$gr[0] or $u[2]==2) die("-3");
if($_GET['pr']=="ban")
mquery("update forum_groups_members set role=3 where id=".(int)$u[0]);
elseif($_GET['pr']=="unban")
mquery("update forum_groups_members set role=1 where id=".(int)$u[0]);
elseif($_GET['pr']=="kick") {
message_send("elten",$_GET['user'],"You were kicked out of the group","You were kicked out of {$gr[2]}.");
mquery("delete from forum_groups_members where id=".(int)$u[0]);
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
?>