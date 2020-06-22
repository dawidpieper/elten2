<?php
require("init.php");
require("blog_base.php");
$q = mquery("SELECT owner FROM `blogs_followed` where blog='".mysql_real_escape_string($_GET['searchname'])."' order by owner");
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q))
echo "\r\n".$r[0];
?>