<?php
require("header.php");
function isJson($string) {
json_decode($string);
return (json_last_error() == JSON_ERROR_NONE);
}
function utf8ize($d) {
    if (is_array($d)) 
        foreach ($d as $k => $v) 
            $d[$k] = utf8ize($v);

     else if(is_object($d))
        foreach ($d as $k => $v) 
            $d->$k = utf8ize($v);
     else if (is_string ($d))
return mb_convert_encoding($d, "UTF-8");

    return $d;
}
$q = mquery("SELECT `name` FROM `profiles` WHERE `name`='".$_GET['name']."'");
if(mysql_num_rows($q) <= 0) mquery("INSERT INTO `profiles` (name) VALUES ('".$_GET['name']."')");
$maps = array(
'profiles' => array(
'__id'=>'name',
'fullname'=>array('fullname', 0),
'gender'=>array('gender', 1),
'birthdateyear' => array('birthdateyear', 1),
'birthdatemonth' => array('birthdatemonth', 1),
'birthdateday' => array('birthdateday', 1),
'location' => array('location', 0),
'languages' => array('languages', 0),
'mainlanguage' => array('mainlanguage', 0),
'publicprofile' => array('publicprofile', 1),
'publicmail' => array('publicmail', 1)
),
'visitingcards' => array(
'__id' => 'name',
'visitingcard' => array('text', 0)
),
'statuses' => array(
'__id' => 'name',
'status' => array('status', 0)
),
'signatures' => array(
'__id' => 'name',
'signature' => array('signature', 0)
),
'greetings' => array(
'__id' => 'name',
'greeting' => array('text', 0)
),
'whatsnew_config' => array(
'__id' => 'owner',
'wn_messages' => array('messages', 1),
'wn_followedthreads' => array('followedthreads', 1),
'wn_followedblogs' => array('followedblogs', 1),
'wn_blogcomments' => array('blogcomments', 1),
'wn_followedforums' => array('followedforums', 1),
'wn_followedforumsthreads' => array('followedforumsthreads', 1),
'wn_friends' => array('friends', 1),
'wn_birthday' => array('birthday', 1),
'wn_mentions' => array('mentions', 1),
'wn_followedblogposts' => array('followedblogposts', 1)
)
);
if($_GET['ac']=="get") {
$j=array();
foreach($maps as $section=>$values) {
if($values['__hide']==1) continue;
$qt="select ";
$c=array();
foreach($values as $k=>$v) {
if($k=="__id") continue;
if(count($c)>0) $qt.=", ";
$qt.="`".$v[0]."`";
array_push($c, $k);
}
$qt.=" from ".$section." where ".$values['__id']."='".mysql_real_escape_string($_GET['name'])."'";
$q=mquery($qt);
$r=mysql_fetch_row($q);
for($i=0; $i<count($c); ++$i) $j[$c[$i]]=str_replace("\004LINE\004", "\n", $r[$i]);
}
echo "0\r\n".json_encode(utf8ize($j), JSON_INVALID_UTF8_IGNORE|JSON_UNESCAPED_UNICODE );
}
elseif($_GET['ac']=="set") {
$js="";
if(isset($_GET['buffer'])) $js=buffer_get($_GET['buffer']);
if(!isJson($js)) die("-3");
$j = json_decode($js, true);
foreach($maps as $section=>$values) {
$c=0;
$qt="update ".$section." set";
foreach($values as $k=>$v)
if(isset($j[$k])) {
if($c>0) $qt.=",";
$qt.=" `".$v[0]."`=";
if($v[1]==0)
$qt.="'".mysql_real_escape_string($j[$k])."'";
else
$qt.=(int)$j[$k];
++$c;
}
$qt.=" where ".$values['__id']."='".mysql_real_escape_string($_GET['name'])."'";
mquery($qt);
}
echo "0";
}
?>