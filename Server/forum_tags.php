<?php
require("header.php");
if(!isset($_GET['forum'])) die;
$q = mquery("select g.id, m.role from forums f left join forum_groups g on f.groupid=g.id left join forum_groups_members m on m.groupid=g.id and m.user='".mysql_real_escape_string($_GET['name'])."' where f.name='".mysql_real_escape_string($_GET['forum'])."'");
if(mysql_num_rows($q)==0) die("-4");
$gr=mysql_fetch_row($q);
if($_GET['ac']=="get") {
$q=mquery("select id, label, taglist from forum_tags where forum='".mysql_real_escape_string($_GET['forum'])."'");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2];
}
elseif($_GET['ac']=="add") {
if($gr[1]!=2) die("-3");
$taglist = $_GET['taglist'];
if(isset($_GET['buffer'])) $taglist=buffer_get($_GET['buffer']);
mquery("insert into forum_tags (forum, label, taglist) values ('".mysql_real_escape_string($_GET['forum'])."', '".mysql_real_escape_string(str_replace("\n", "", $_GET['label']))."', '".mysql_real_escape_string(str_replace("\n", "", $taglist))."')");
echo "0";
}
elseif($_GET['ac']=="del") {
if($gr[1]!=2) die("-3");
mquery("delete from forum_tags where forum='".mysql_real_escape_string($_GET['forum'])."' and id=".(int)$_GET['tagid']);
echo "0";
}
?>