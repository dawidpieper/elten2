<?php
require("init.php");
$q = mquery("SELECT owner,name FROM `blogs` where owner in (select blog from blog_owners where owner='".mysql_real_escape_string($_GET['searchname'])."')");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0]."\r\n".$r[1];
?>