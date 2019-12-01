<?php
require("init.php");
$q = mquery("SELECT owner FROM `followedblogs` where author='".mysql_real_escape_string($_GET['searchname'])."' order by owner COLLATE utf8_polish_ci");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0];
?>