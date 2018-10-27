<?php
require("header.php");
if($_GET['get']==1) {
$q=mquery("select owner, messages, followedthreads, followedblogs, blogcomments, followedforums, followedforumsthreads, friends, birthday, mentions from whatsnew_config where owner='".$_GET['name']."'");
if(mysql_num_rows($q)>0) {
$r=mysql_fetch_row($q);
echo "0\r\n".$r[1]."\r\n".$r[2]."\r\n".$r[3]."\r\n".$r[4]."\r\n".$r[5]."\r\n".$r[6]."\r\n".$r[7]."\r\n".$r[8]."\r\n".$r[9];
}
else
echo "0\r\n0\r\n0\r\n0\r\n0\r\n0\r\n2\r\n0\r\n0\r\n0";
}
if($_GET['set']==1) {
mquery("insert into whatsnew_config (owner,messages,followedthreads,followedblogs,blogcomments,followedforums,followedforumsthreads,friends,birthday,mentions) values ('".$_GET['name']."',".((int) $_GET['messages']).",".((int) $_GET['followedthreads']).",".((int) $_GET['followedblogs']).",".((int) $_GET['blogcomments']).",".((int) $_GET['followedforums']).",".((int) $_GET['followedforumsthreads']).",".((int) $_GET['friends']).",".((int) $_GET['birthday']).",".((int) $_GET['mentions']).") on duplicate key update owner=values(owner), messages=values(messages), followedthreads=values(followedthreads), followedblogs=values(followedblogs), blogcomments=values(blogcomments), followedforums=values(followedforums), followedforumsthreads=values(followedforumsthreads), friends=values(friends), birthday=values(birthday), mentions=values(mentions)");
echo "0";
}
?>