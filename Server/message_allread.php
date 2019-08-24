<?php
require("header.php");
if(file_exists("cache/messages_".$_GET['name'].".dat")) unlink("cache/messages_".$_GET['name'].".dat");
mquery("update messages set `read`=".time()." where (`read` is null or `read`=0) and `receiver`='".$_GET['name']."'");
echo "0";
?>