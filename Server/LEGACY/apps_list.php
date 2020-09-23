<?php
require("init.php");
if(!isset($_GET['listfiles'])) {
echo "0";
foreach(glob('apps/*', GLOB_BRACE) as $p)
if(file_exists($p."/__app.ini")) {
$c=parse_ini_file($p."/__app.ini",true);
$a=explode("\n", $c,true);
echo "\r\n" . str_replace("apps/","",$p);
echo "\r\n".$c['App']['Name'];
echo "\r\n".$c['App']['Version'];
echo "\r\n".$c['App']['Author'];
echo "\r\n".$c['App']['File'];
}
}
else {
function list_files($d) {
$ret=array();
foreach(glob($d.'/*', GLOB_BRACE) as $file)
if(is_dir($file)) {
$r=list_files($file);
foreach($r as $v)
array_push($ret,$v);
}
else
array_push($ret, ltrim($file,"/"));
return $ret;
}
$d="apps/".str_replace("/","",str_replace("\\","",$_GET['listfiles']));
$sz=0;
$t="";
$l=list_files($d);
foreach($l as $f)
if(file_exists($f)) {
$t.="\r\n".str_replace($d."/","",$f)."\r\n".$f;
$sz+=filesize($f);
}
echo "0\r\n".$sz.$t;
}
?>