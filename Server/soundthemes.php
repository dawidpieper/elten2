<?php
require("header.php");
echo "0";
foreach(glob('soundthemes/inis/*.ini', GLOB_BRACE) as $file)
echo "\r\n" . $file;
?>