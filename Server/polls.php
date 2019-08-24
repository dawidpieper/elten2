<?php
if($_GET['create']!=1 and $_GET['voted']!=1 and $_GET['del']!=1 and $_GET['answer']!=1)
require("init.php");
else
require("header.php");
if($_GET['list']==1) {
$qs="SELECT `id`,`name`,`author`,`created`,`description` FROM `polls` ";
if($_GET['byme']==1)
$qs.=" where author='{$_GET['name']}' ";
$qs.=" ORDER BY ID DESC";
$q=mquery($qs);
$t='';
while($r=mysql_fetch_row($q)) {
$t.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\nEND";
}
echo "0\r\n".mysql_num_rows($q).$t;
}
if($_GET['create']==1) {
if($_GET['qbuffer']==NULL)
$questions=$_GET['questions'];
else
$questions=buffer_get($_GET['qbuffer']);
if($_GET['dbuffer']==NULL)
$description=$_GET['description'];
else
$description=buffer_get($_GET['dbuffer']);
mquery("INSERT INTO `polls` (`name`,`author`,`created`,`description`,`questions`) VALUES ('".mysql_real_escape_string($_GET['pollname'])."','".$_GET['name']."',".time().",'".mysql_real_escape_string($description)."','".mysql_real_escape_string($questions)."')");
echo "0";
}
if($_GET['answer']==1) {
if($_GET['buffer']==NULL)
$answ=$_GET['answers'];
else
$answ=buffer_get($_GET['buffer']);
$answers=explode("\r\n",$answ);
foreach($answers as $a) {
$param=explode(":",$a);
mquery("INSERT INTO `polls_answers` (`author`,`poll`,`question`,`answer`) VALUES ('".$_GET['name']."',".(int)$_GET['poll'].",".(int)$param[0].",'".mysql_real_escape_string($param[1])."')");
}
echo "0";
}
if($_GET['results']==1) {
$c=mysql_num_rows(mquery("SELECT DISTINCT `author` FROM `polls_answers` WHERE `poll`=".(int)$_GET['poll']));
$q=mquery("SELECT `question`,`answer` FROM `polls_answers` WHERE `poll`=".(int)$_GET['poll']);
$t='';
while($r=mysql_fetch_row($q)) {
$t.="\r\n".$r[0].":".$r[1];
}
echo "0\r\n".$c.$t;
}
if($_GET['voted']==1) {
$q=mquery("SELECT `author` FROM `polls_answers` WHERE `author`='".$_GET['name']."' AND `poll`=".mysql_real_escape_string($_GET['poll']));
echo "0\r\n";
if(mysql_num_rows($q)>0)
echo "1";
else
echo "0";
}
if($_GET['get']==1) {
$q=mquery("SELECT `id`,`name`,`author`,`created`,`questions`,`description` FROM `polls` WHERE `id`=".(int)$_GET['poll']);
$r=mysql_fetch_row($q);
echo "0\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5];
}
if($_GET['del']==1) {
if(getprivileges($_GET['name'])[0]==1 or $_GET['name']==mysql_fetch_row(mquery("select author from polls where id=".(int)$_GET['id']))[0]) {
mquery("DELETE FROM `polls` WHERE `id`=".(int)$_GET['id']);
mquery("DELETE FROM `polls_answers` WHERE `poll`=".(int)$_GET['id']);
}
echo "0";
}
?>