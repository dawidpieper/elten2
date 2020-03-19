<?php
function isJson($string) {
json_decode($string);
return (json_last_error() == JSON_ERROR_NONE);
}
function isBase64($s) {
return (bool) preg_match('/^[a-zA-Z0-9\/+]*={0,2}$/', $s);
}

require("header.php");
if($_GET['ac']=="dbcreate") {
$id=0;
while($id==0 or mysql_num_rows(mquery("select id from apps_db_ids where id=".(int)$id))>0) $id=rand(1000,2000000000);
mquery("insert into apps_db_ids (id,creator,description,date) values (".(int)$id.", '".mysql_real_escape_string($_GET['name'])."', '".mysql_real_escape_string($_GET['description'])."', unix_timestamp())");
die("0\r\n".$id);
}
if($_GET['ac']=="dblist") {
$q=mquery("select id,description from apps_db_ids where creator='".mysql_real_escape_string($_GET['name'])."' order by date");
$t="0";
while($r=mysql_fetch_row($q))
$t.="\r\n".$r[0]."\r\n".str_replace("\r\n","",$r[1]);
die($t);
}
if($_GET['ac']=="dbrename") {
if(mysql_num_rows(mquery("select id from apps_db_ids where creator='".mysql_real_escape_string($_GET['name'])."' and id=".(int)$_GET['appid']))==0) die("-3");
mquery("update apps_db_ids set description='".mysql_real_escape_string($_GET['description'])."' where creator='".mysql_real_escape_string($_GET['name'])."' and id=".(int)$_GET['appid']);
die("0");
}
if($_GET['ac']=="dbdelete") {
if(mysql_num_rows(mquery("select name from users where name='".mysql_real_escape_string($_GET['name'])."' and password='".mysql_real_escape_string($_GET['password'])."'"))==0) die("-3");
if(mysql_num_rows(mquery("select id from apps_db_ids where creator='".mysql_real_escape_string($_GET['name'])."' and id=".(int)$_GET['appid']))==0) die("-3");
mquery("delete from apps_db where appid=".(int)$_GET['appid']);
mquery("delete from apps_db_ids where id=".(int)$_GET['appid']);
echo "0";
}
if($_GET['ac']=="dbflush") {
if(mysql_num_rows(mquery("select name from users where name='".mysql_real_escape_string($_GET['name'])."' and password='".mysql_real_escape_string($_GET['password'])."'"))==0) die("-3");
if(mysql_num_rows(mquery("select id from apps_db_ids where creator='".mysql_real_escape_string($_GET['name'])."' and id=".(int)$_GET['appid']))==0) die("-3");
mquery("delete from apps_db where appid=".(int)$_GET['appid']);
echo "0";
}

if(!isset($_GET['table']) or !isset($_GET['appid'])) die("-2");
if(mysql_num_rows(mquery("select id from apps_db_ids where id=".(int)$_GET['appid']))==0) die("-3");
$db=0;
if(isset($_GET['db'])) $db=$_GET['db'];
if($db<-3||$db>3||$db==0) die("-1");
if($_GET['ac']=="get") {
$qt="select id, creator, val from apps_db where appid=".(int)$_GET['appid']." and table_name='".mysql_real_escape_string($_GET['table'])."' and db=".(int)$db;
if($db==2||$db==-2)
$qt.=" and creator='".mysql_real_escape_string($_GET['name'])."'";
if($db==3||$db==-3)
$qt.=" and (creator='".mysql_real_escape_string($_GET['name'])."' or id in (select db_id from apps_db_shared where user='".mysql_real_escape_string($_GET['name'])."'))";
$q=mquery($qt);
$t="0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
$t.="\r\n".$r[0]."\r\n".$r[1]."\r\n".str_replace("\r\n","",$r[2]);
echo $t;
}
if($_GET['ac']=="set") {
if($db<0) die("-2");
$val="";
if(isset($_GET['val'])) $val=$_GET['val'];
if(isset($_GET['buf'])) $val=buffer_get($_GET['buf']);
if(!isJson($val)) die("-1");
$qt="update apps_db set moddate=unix_timestamp(), val='".mysql_real_escape_string($val)."' where id=".(int)$_GET['entry']." and appid=".(int)$_GET['appid']." and table_name='".mysql_real_escape_string($_GET['table'])."' and db=".(int)$db;
if($db==2||$db==-2)
$qt.=" and creator='".mysql_real_escape_string($_GET['name'])."'";
if($db==3||$db==-3)
$qt.=" and (creator='".mysql_real_escape_string($_GET['name'])."' or id in (select db_id from apps_db_shared where user='".mysql_real_escape_string($_GET['name'])."'))";
mquery($qt);
echo "0";
}
if($_GET['ac']=="push") {
$val="";
if(isset($_GET['val'])) $val=$_GET['val'];
if(isset($_GET['buf'])) $val=buffer_get($_GET['buf']);
if(!isJson($val)) die("-1");
$qt="insert into apps_db (appid, table_name, creator, date, moddate, db, val) values ('".(int)$_GET['appid']."', '".mysql_real_escape_string($_GET['table'])."', '".mysql_real_escape_string($_GET['name'])."', unix_timestamp(), unix_timestamp(), ".(int)$db.", '".mysql_real_escape_string($val)."')";
mquery($qt);
$id=(int)mysql_fetch_row(mquery("select LAST_INSERT_ID()"))[0];
echo "0\r\n".$id;
}
if($_GET['ac']=="addfields") {
if($_GET['count']>=131072) die("-3");
$nl="('".(int)$_GET['appid']."', '".mysql_real_escape_string($_GET['table'])."', '".mysql_real_escape_string($_GET['name'])."', unix_timestamp(), unix_timestamp(), ".(int)$db.", '".json_encode(null)."')";
$qt="insert into apps_db (appid, table_name, creator, date, moddate, db, val) values";
for($i=0; $i<$_GET['count']; ++$i) {
if($i>0)$qt.=",";
$qt.=$nl;
}
mquery($qt);
$id=(int)mysql_fetch_row(mquery("select LAST_INSERT_ID()"))[0];
echo "0";
for($i=0; $i<$_GET['count']; ++$i)
echo "\r\n".($id+$i);
}
if($_GET['ac']=="delete") {
if($db<0) die("-2");
$qt="delete from apps_db where id=".(int)$_GET['entry']." and appid=".(int)$_GET['appid']." and table_name='".mysql_real_escape_string($_GET['table'])."' and db=".(int)$db;
if($db==2||$db==-2)
$qt.=" and creator='".mysql_real_escape_string($_GET['name'])."'";
if($db==3||$db==-3)
$qt.=" and (creator='".mysql_real_escape_string($_GET['name'])."' or id in (select db_id from apps_db_shared where user='".mysql_real_escape_string($_GET['name'])."'))";
mquery($qt);
echo "0";
}
if($_GET['ac']=="share") {
if($db!=2) die("-3");
$qt="select id from apps_db where id=".(int)$_GET['entry']." and appid=".(int)$_GET['appid']." and table_name='".mysql_real_escape_string($_GET['table'])."' and db=".(int)$db;
if($db==2||$db==-2)
$qt.=" and creator='".mysql_real_escape_string($_GET['name'])."'";
if($db==3||$db==-3)
$qt.=" and (creator='".mysql_real_escape_string($_GET['name'])."' or id in (select db_id from apps_db_shared where user='".mysql_real_escape_string($_GET['name'])."'))";
$q=mquery($qt);
if(mysql_num_rows($q)==0) die("-2");
if(mysql_num_rows(mquery("select name from users where name='".mysql_real_escape_string($_GET['user'])."'"))==0) die("-4");
if(mysql_num_rows(mquery("select user from apps_db_shared where user='".mysql_real_escape_string($_GET['user'])."' and db_id=".(int)$_GET['entry']))>0) die("-3");
mquery("insert into apps_db_shared (db_id, user) values (".(int)$_GET['entry'].", '".mysql_real_escape_string($_GET['user'])."')");
echo "0";
}
?>