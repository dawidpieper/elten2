<?php
require("init.php");
if(!isset($_GET['listfiles'])) {
echo "0";
if($_GET['type']==1) {
foreach(glob('soundthemes/*', GLOB_BRACE) as $p)
if(file_exists($p."/__name.txt")) {
echo "\r\n" . str_replace("soundthemes/","",$p);
echo "\r\n".str_replace("\r\n","",str_replace("\n","",file_get_contents($p."/__name.txt")));
}
}
else {
foreach(glob('soundthemes/inis/*.ini', GLOB_BRACE) as $file)
echo "\r\n" . $file;
}
}
else {
function list_files($d) {
$ret=array();
foreach(glob($d.'/BGS/*.ogg', GLOB_BRACE) as $file)
array_push($ret, str_replace($d."/","",$file));
foreach(glob($d.'/SE/*', GLOB_BRACE) as $file)
array_push($ret, str_replace($d."/","",$file));
if(file_exists($d."/__name.txt")) array_push($ret,"__name.txt");
return $ret;
}
$d="soundthemes/".str_replace("/","",str_replace("\\","",$_GET['listfiles']));
echo "0";
foreach(list_files($d) as $f)
echo "\r\n".$_GET['listfiles']."/".$f;
}
?>