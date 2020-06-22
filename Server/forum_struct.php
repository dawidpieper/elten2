<?php
if($_GET['name']=="guest")
require("init.php");
else
require("header.php");
$ret=forum_getstruct($_GET['name'], (int)$_GET['useflags']);
echo "0\r\n";
$t="";
foreach($ret as $k=>$c) {
$t.="{$k}\r\n";
$t.=sizeof($c)."\r\n";
$t.=sizeof(array_values($c)[0])."\r\n";
foreach($c as $b)
foreach($b as $a)
$t.=str_replace("\n","\004LINE\004",str_replace("\r\n","\n",$a))."\r\n";
}
if($_GET['gz']==1)
echo gzcompress(str_replace("\r\n", "\r", $t), 9);
else
echo $t;
?>