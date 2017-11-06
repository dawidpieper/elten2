<?php
require("header.php");
if($_GET['get']==1) {
$q=mquery("SELECT id,name,author,created,modified,note from notes where author='".$_GET['name']."' OR id in (SELECT note from notes_shared where user='".$_GET['name']."')");
$t='';
while($r=mysql_fetch_row($q)) {
$t.=$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5]."\r\nEND\r\n";
}
$c=mysql_num_rows($q);
echo "0\r\n".$c."\r\n".$t;
}
if($_GET['edit']==1) {
//if(mysql_num_rows(mquery("SELECT id,name,author,created,modified,note from notes where id=".$_GET['noteid']." and (author='".$_GET['name']."' OR id in (SELECT note from notes_shared where user='".$_GET['name']."'))"))==0) {
//echo "-3";
//die;
//}
$text=$_GET['text'];
if($_GET['buffer']!=NULL)
$text=buffer_get($_GET['buffer']);
mquery("UPDATE notes SET note='".$text."', modified=".time()." WHERE id=".$_GET['noteid']);
echo "0";
}
if($_GET['create']==1) {
$text=$_GET['text'];
if($_GET['buffer']!=NULL)
$text=buffer_get($_GET['buffer']);
mquery("INSERT INTO notes (id,author,name,created,modified,note) VALUES ('','".$_GET['name']."','".$_GET['notename']."',".time().",".time().",'".$text."')");
echo "0";
}
if($_GET['addshare']==1) {
if(mysql_num_rows(mquery("SELECT id,name,author,created,modified,note from notes where id=".$_GET['noteid']." and (author='".$_GET['user']."' OR id in (SELECT note from notes_shared where user='".$_GET['user']."'))"))>0) {
echo "-3";
die;
}
if(mysql_num_rows(mquery("SELECT id,name,author,created,modified,note from notes where id=".$_GET['noteid']." and author='".$_GET['name']."'"))==0) {
echo "-3";
die;
}
mquery("INSERT INTO notes_shared (id,note,user) VALUES ('',".$_GET['noteid'].",'".$_GET['user']."')");
echo "0";
}
if($_GET['delshare']==1) {
if(mysql_num_rows(mquery("SELECT id,name,author,created,modified,note from notes where id=".$_GET['noteid']." and author='".$_GET['name']."'"))==0) {
echo "-3";
die;
}
mquery("DELETE FROM notes_shared WHERE note=".$_GET['noteid']." AND user='".$_GET['user']."'");
echo "0";
}
if($_GET['delete']==1) {
if(mysql_num_rows(mquery("SELECT id,name,author,created,modified,note from notes where id=".$_GET['noteid']." and author='".$_GET['name']."'"))==0) {
echo "-3";
die;
}
mquery("DELETE FROM notes_shared WHERE note=".$_GET['noteid']);
mquery("DELETE FROM notes WHERE id=".$_GET['noteid']);
echo "0";
}
if($_GET['getshares']==1) {
$q=mquery("SELECT user FROM notes_shared WHERE note=".$_GET['noteid']);
$t="";
while($r=mysql_fetch_row($q)) {
$t.=$r[0]."\r\n";
}
echo "0\r\n".$t;
}
?>