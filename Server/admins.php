<?php
require("init.php");
if($_GET['cat']=="developers")
$q = mquery("SELECT `name` FROM `privileges` where developer=1");
elseif($_GET['cat']=="moderators") {
$q=mquery("select id,name,founder from forum_groups where recommended=1");
echo "0";
while($r=mysql_fetch_row($q)) {
echo "\r\n".$r[0]."\r\n".$r[1]."\r\n".$r[2];
$q2=mquery("select user from forum_groups_members where groupid={$r[0]} and role=2 and user!='{$r[2]}'");
echo "\r\n".mysql_num_rows($q2);
while($r2=mysql_fetch_row($q2))
echo "\r\n".$r2[0];
}
die;
}
elseif($_GET['cat']=="administrators") {
$q=mquery("select lang,founder from forum_groups where recommended=1 group by lang order by id");
echo "0";
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0]."\r\n".$r[1];
die;
}
else
$q = mquery("SELECT `name` FROM `privileges` where moderator=1");
echo "0";
while ($wiersz = mysql_fetch_row($q)){
$name = $wiersz[0];
echo "\r\n" . $name;
}
?>