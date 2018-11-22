<?php
require("header.php");
if(!isset($_GET['sp'])) {
if(!isset($_GET['user'])) {
if(isset($_GET['limit']))
$limit=$_GET['limit'];
else
$limit=1000;
$q=mquery("select if(sender='{$_GET['name']}',receiver,sender) as user, sender, date, subject, if((if(sender='{$_GET['name']}',receiver,sender) in (select sender from messages where receiver='{$_GET['name']}' and `read` is null)), 0, 1) as r, id from messages where id in (select max(id) from messages group by IF(sender > receiver, sender,receiver),         IF(sender > receiver, receiver,sender)) and ((sender='{$_GET['name']}' and deletedfromsent=0) OR (receiver='{$_GET['name']}' and deletedfromreceived=0)) group by user order by date desc limit 0,".((int)($limit+1)));
$cnt=0;
$txt="\r\n".((mysql_num_rows($q)>$limit)?1:0);
while($r=mysql_fetch_row($q) and $cnt<$limit)
if($r[0]!="") {
$cnt++;
$txt .= "\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5];
}
echo "0\r\n".$cnt.$txt;
}
elseif(isset($_GET['user']) and (!isset($_GET['subj']) and !isset($_GET['id']))) {
if(isset($_GET['limit']))
$limit=$_GET['limit'];
else
$limit=1000;
$q=mquery("select replace(lower(subject),'re: ','') as subject, sender, date, if(`read` is not null,1,0), id from messages where id in (select max(id) from messages where (sender='".mysql_real_escape_string($_GET['user'])."' and receiver='".mysql_real_escape_string($_GET['name'])."') or (receiver='".mysql_real_escape_string($_GET['user'])."' and sender='".mysql_real_escape_string($_GET['name'])."') group by replace(lower(subject), 're: ', '')) and ((sender='".mysql_real_escape_string($_GET['user'])."' and receiver='".mysql_real_escape_string($_GET['name'])."') or (receiver='".mysql_real_escape_string($_GET['user'])."' and sender='".mysql_real_escape_string($_GET['name'])."')) group by replace(lower(subject), 're: ', '') order by id desc limit ".((int)($limit+1)));
$cnt=0;
$txt=((mysql_num_rows($q)>$limit)?1:0)."\r\n";
if(mysql_num_rows(mquery("select name from users where name='".mysql_real_escape_string($_GET['user'])."'"))>0)
$txt.="1";
else
$txt.="0";
while($r=mysql_fetch_row($q) and $cnt<$limit) {
$txt.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4];
++$cnt;
}
echo "0\r\n".$cnt."\r\n".$txt;
}
elseif(isset($_GET['user']) and (isset($_GET['subj']) or isset($_GET['id']))) {
if(isset($_GET['subj']))
$subj=$_GET['subj'];
else
$subj=mysql_fetch_row(mquery("select replace(lower(subject), 're: ', '') from messages where id='".(int)$_GET['id']."'"))[0];
if(isset($_GET['limit']))
$limit=$_GET['limit'];
else
$limit=1000;
$q=mquery("select id, sender, subject, date, if(`read` is not null, 1, 0), marked, attachments, message from messages where ((sender='".mysql_real_escape_string($_GET['user'])."' and receiver='".mysql_real_escape_string($_GET['name'])."' and deletedfromreceived=0) or (receiver='".mysql_real_escape_string($_GET['user'])."' and sender='".mysql_real_escape_string($_GET['name'])."') and deletedfromsent=0) and replace(lower(subject), 're: ', '')=lower('".mysql_real_escape_String($subj)."') order by id desc limit 0,".((int)($limit+1)));
$txt="\r\n".((mysql_num_rows($q)>$limit)?1:0)."\r\n";
if(mysql_num_rows(mquery("select name from users where name='".mysql_real_escape_string($_GET['user'])."'"))>0)
$txt.="1";
else
$txt.="0";
$cnt=0;
while($r=mysql_fetch_row($q) and $cnt<$limit) {
$txt.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5]."\r\n".$r[6]."\r\n".$r[7]."\r\n\004END\004";
++$cnt;
}
echo "0\r\n".$cnt.$txt;
mquery("update messages set `read`=".time()." where `read` is null and sender='".mysql_real_escape_string($_GET['user'])."' and receiver='".mysql_real_escape_string($_GET['name'])."' and replace(lower(subject), 're: ', '')=lower('".mysql_real_escape_String($subj)."')");
}
}
else {
switch($_GET['sp']) {
case "new": {
$q=mquery("select replace(lower(subject),'re: ','') as subject, sender, date, 0, id from messages where id in (select max(id) from messages where (receiver='".mysql_real_escape_string($_GET['name'])."') and `read` is null group by replace(lower(subject), 're: ', ''),sender) and ((receiver='".mysql_real_escape_string($_GET['name'])."')) group by replace(lower(subject), 're: ', ''),sender order by id desc");
$txt="0\r\n";
$txt.="0";
$cnt=0;
while($r=mysql_fetch_row($q)) {
$txt.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4];
++$cnt;
}
echo "0\r\n".$cnt."\r\n".$txt;
break;
}
case "flagged": {
$q=mquery("select id, sender, subject, date, if(`read` is not null, 1, 0), marked, attachments, message from messages where receiver='".mysql_real_escape_string($_GET['name'])."' and deletedfromreceived=0 and marked=1 order by id desc");
$txt="\r\n0\r\n";
$txt.="0";
$cnt=0;
while($r=mysql_fetch_row($q)) {
$txt.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5]."\r\n".$r[6]."\r\n".$r[7]."\r\n\004END\004";
++$cnt;
}
echo "0\r\n".$cnt.$txt;
mquery("update messages set `read`=".time()." where `read` is null and receiver='".mysql_real_escape_string($_GET['name'])."' and marked=1");
}
case "search": {
$q=mquery("select id, sender, subject, date, if(`read` is not null, 1, 0), marked, attachments, message from messages where receiver='".mysql_real_escape_string($_GET['name'])."' and deletedfromreceived=0 and lower(message) like '%".mysql_real_escape_string($_GET['search'])."%' order by id desc limit 0,100");
$txt="\r\n0\r\n";
$txt.="0";
$cnt=0;
while($r=mysql_fetch_row($q)) {
$txt.="\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5]."\r\n".$r[6]."\r\n".$r[7]."\r\n\004END\004";
++$cnt;
}
echo "0\r\n".$cnt.$txt;
mquery("update messages set `read`=".time()." where `read` is null and receiver='".mysql_real_escape_string($_GET['name'])."' and lower(message) like '%".mysql_real_escape_string($_GET['search'])."%' order by id desc limit 100");
}
}
}
?>