<?php
require("header.php");
if(file_exists("cache/messages_".$_GET['name'].".dat")) unlink("cache/messages_".$_GET['name'].".dat");
if(file_exists("cache/messages_".$_GET['to'].".dat")) unlink("cache/messages_".$_GET['to'].".dat");
$text = $_GET['text'];
if($_GET['buffer'] != null)
$text=buffer_get($_GET['buffer']);
if($_GET['audio']==1)
$text=$_POST['data'];
$attachments=$_GET['attachments'];
if($_GET['bufatt']!=NULL)
$attachments=buffer_get($_GET['bufatt']);
echo message_send($_GET['name'], $_GET['to'], $_GET['subject'], $text, $_GET['audio'], $attachments);
?>