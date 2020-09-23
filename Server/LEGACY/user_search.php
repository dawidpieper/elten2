<?php
require("init.php");
$search=strtoupper($_GET['search']);
$q=mquery("SELECT name from users");
while($r=mysql_fetch_row($q)) {
$usr[$r[0]]=levenshtein($search,strtoupper($r[0]));
}
asort($usr);
$results=array();
foreach($usr as $user=>$similarity) {
if($similarity<=strlen($user)*2/5)
$results[]=$user;
}
echo "0\r\n".count($results)."\r\n".implode("\r\n",$results);
?>