<?php
require("header.php");
if(mysql_num_rows(mquery("SELECT name FROM banned WHERE name='".$_GET['name']."' AND totime>".time()))>0) die("-3");
$moderator=getprivileges($_GET['name'])[1];
$post="";
if(!isset($_GET['buffer'])) {
if(!isset($_GET['audio']))
$post = $_GET['post'];
elseif($_GET['audio']==1)
$post=$_POST['post'];
elseif($_GET['audio']==2) {
$tempName = $_FILES['post']['tmp_name'];
$post=file_get_contents($tempname);
session_start();
$_SESSION['forumnewpost']=1;
}
}
elseif(isset($_GET['buffer'])) {
$post=buffer_get($_GET['buffer']);
}
$asname = $_GET['name'];
if(($_GET['uselore'] == 1 and $_GET['lore'] != NULL) and $moderator == 1)
$asname .= "".$_GET['lore'];
$atts=NULL;
if(isset($_GET['bufatt']))
$atts=buffer_get($_GET['bufatt']);
echo forum_post($_GET['name'],$_GET['threadid'],$post,((int)$_GET['audio']==0)?'text':'audio',$_GET['threadname'],$_GET['forumname'],$_GET['follow'],$asname, $_GET['polls'], $atts);
?>