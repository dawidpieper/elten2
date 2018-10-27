<?php
require("init.php");
$files=scandir("avatars");
foreach($files as $file)
if($file!=".." and $file!=".")
$avatar[$file]=filemtime("avatars/".$file);
arsort($avatar);
echo "0";
foreach($avatar as $user=>$time)
echo "\r\n".$user."\r\n".$time;
?>