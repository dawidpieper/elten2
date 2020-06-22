<?php
require("init.php");
function isJson($string) {
json_decode($string);
return (json_last_error() == JSON_ERROR_NONE);
}
if($_GET['ac']=="verify") {
if(isset($_GET['msg'])) $msg=base64_decode($_GET['msg']);
else $msg=trim(file_get_contents("php://input"));
$rsa = openssl_pkey_get_private($elten_rsakey);
$jn="";
openssl_private_decrypt($msg, $jn, $rsa);
if(isJson($jn)) {
$j=json_decode($jn, true);
if($j['time']<time()-60) die;
$r=array();
$r['time']=microtime(true);
$r['text']="";
for($i=strlen($j['text'])-1; $i>=0; --$i) $r['text'].=$j['text'][$i];
$r['rnd']=random_str(32);
$str=json_encode($r);
openssl_private_encrypt($str, $res, $rsa);
echo $res;
}
}
?>