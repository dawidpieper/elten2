<?php
if($_GET['create']!=1 and $_GET['voted']!=1 and $_GET['del']!=1 and $_GET['answer']!=1)
require("init.php");
else
require("header.php");
function isJson($string) {
json_decode($string);
return (json_last_error() == JSON_ERROR_NONE);
}
function canmodvote() {
if(time()>=1601848800) return false;
$posts = mysql_num_rows(mquery("select id from forum_posts where date not like '%2020%' and author='".mysql_real_escape_string($_GET['name'])."' and thread in (select id from forum_threads where forum in (select name from forums where groupid in (select id from forum_groups where recommended=1 and lower(lang)='pl')))"));
if($posts>50) return true;
else return false;
}
if($_GET['list']==1) {
$qs="SELECT distinct p.id, p.name, p.author, p.created, p.description, p.language, if(v.id is not null, 1, 0), a.counter, p.expirydate, p.hideresults FROM polls p left join polls_answers as v on p.id=v.poll and v.author='".mysql_real_escape_string($_GET['name'])."' left join (select poll, count(distinct author) as counter from polls_answers group by poll) a on p.id=a.poll";
if($_GET['byme']==1)
$qs.=" where p.author='{$_GET['name']}' ";
else
$qs.=" where p.hidden=0 or p.author='{$_GET['name']}' ";
$qs.=" ORDER BY p.ID DESC";
$q=mquery($qs);
$t='';
while($r=mysql_fetch_row($q)) {
$cv=$r[6];
if($r[0]==323 && !canmodvote()) $cv=1;
if($r[8]>0 && $r[8]<time()) $cv=1;
if($_GET['details']==2)
$t.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[5]."\r\n".$cv."\r\n".$r[7]."\r\n".$r[4]."\r\nEND";
elseif($_GET['details']==1)
$t.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[5]."\r\n".$cv."\r\n".$r[4]."\r\nEND";
else
$t.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\nEND";
}
echo "0\r\n".mysql_num_rows($q).$t;
}
if($_GET['create']==1) {
if($_GET['qbuffer']==NULL)
$questions=$_GET['questions'];
else
$questions=buffer_get($_GET['qbuffer']);
if(!isJson($questions)) die("-1");
if($_GET['dbuffer']==NULL)
$description=$_GET['description'];
else
$description=buffer_get($_GET['dbuffer']);
$hidden=0;
if(isset($_GET['hidden'])) $hidden=$_GET['hidden'];
mquery("INSERT INTO `polls` (`name`,`author`,`created`,`description`,`questions`,`hidden`,`language`,`expirydate`,`hideresults`) VALUES ('".mysql_real_escape_string($_GET['pollname'])."','".$_GET['name']."',".time().",'".mysql_real_escape_string($description)."','".mysql_real_escape_string($questions)."',".(int)$hidden.", '".mysql_real_escape_string($_GET['lng'])."', ".(int)$_GET['expirydate'].", ".(int)$_GET['hideresults'].")");
echo "0";
}
if($_GET['answer']==1) {
if(mysql_num_rows(mquery("select id from polls_answers where author='".mysql_real_escape_string($_GET['name'])."' and poll=".(int)$_GET['poll']))>0) die("-3");
if(mysql_num_rows(mquery("select id from polls where expirydate<unix_timestamp() and expirydate>0 and id=".(int)$_GET['poll']))>0) die("-3");
if($_GET['poll']==323 && !canmodvote()) die("-3");
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
if(mysql_num_rows(mquery("select id from polls where expirydate>unix_timestamp() and expirydate>0 and hideresults=1 and id=".(int)$_GET['poll']))>0) die("0\r\n0");
$q=mquery("SELECT DISTINCT `author` FROM `polls_answers` WHERE `poll`=".(int)$_GET['poll']);
$authors=array();
while($r=mysql_fetch_row($q))
array_push($authors, $r[0]);
$c=mysql_num_rows($q);
$q=mquery("SELECT `question`,`answer`,`author` FROM `polls_answers` WHERE `poll`=".(int)$_GET['poll']);
$t='';
while($r=mysql_fetch_row($q)) {
$t.="\r\n";
if($_GET['details']==1)
$t.=array_search($r[2], $authors).":";
$t.=$r[0].":".$r[1];
}
echo "0\r\n".$c.$t;
}
if($_GET['voted']==1) {
$q=mquery("SELECT `author` FROM `polls_answers` WHERE `author`='".$_GET['name']."' AND `poll`=".mysql_real_escape_string($_GET['poll']));
echo "0\r\n";
if(mysql_num_rows($q)>0)
echo "1";
elseif($_GET['poll']==323 and !canmodvote())
echo "1";
elseif(mysql_num_rows(mquery("select id from polls where id=".(int)$_GET['poll']." and expirydate>0 and expirydate<unix_timestamp()"))>0)
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