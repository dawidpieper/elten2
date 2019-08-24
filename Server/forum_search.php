<?php
require("init.php");
$q=mquery("select thread, count(thread) from forum_posts where lower(post) like lower('%".str_replace("%","\\%",mysql_real_escape_string($_GET['query']))."%') group by thread order by thread");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0]."\r\n".$r[1];
?>