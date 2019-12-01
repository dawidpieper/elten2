<?php
require("init.php");
$qt="select blog,owner from blog_owners";
if($_GET['owner']!=null)
$qt.=" where owner='".mysql_real_escape_string($_GET['owner'])."'";
$q=mquery($qt);
echo "0\r\n".mysql_num_rows($q);
while($r=mysql_fetch_row($q)) {
echo "\r\n".$r[0]."\r\n".$r[1];
}
?>