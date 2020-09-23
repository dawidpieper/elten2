<?php
require("header.php");
if($_GET['get'] == 1) {
$q = mquery("SELECT `forum`, `thread` FROM `followedthreads` WHERE `owner`='" . $_GET['name'] . "'");
$text = "";
$ile = 0;
while ($wiersz = mysql_fetch_row($q)) {
$postsinthread = 0;
$readpostsinthread = 0;
$wq = mquery("SELECT `id`, `thread`, `posts` FROM `forum_read` WHERE `owner`='".$_GET['name']."' AND `thread`='".$wiersz[1]."'");
$wwiersz = mysql_fetch_row($wq);
$readpostsinthread = $wwiersz[2];
$wq = mquery("SELECT `id` FROM `forum_posts` WHERE `thread`=".$wiersz[1]);
$postsinthread = mysql_num_rows($wq);
if($readpostsinthread < $postsinthread) {
$ile = $ile + 1;
$text .= $wiersz[0] . "\r\n" . $wiersz[1] . "\r\n".$postsinthread."\r\n";
}
}
echo "0\r\n" . $ile . "\r\n" . $text;
}
?>