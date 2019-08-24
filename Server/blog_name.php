<?php
require("init.php");
$q = mquery("SELECT `owner`, `name` FROM `blogs` where owner='".mysql_real_escape_string($_GET['searchname'])."'");
if(mysql_num_rows($q)==0)
echo "-4";
else
echo "0\r\n" . mysql_fetch_row($q)[1];
?>