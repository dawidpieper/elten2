<?php
require("header.php");
if($_GET['owner'] == NULL) {
echo "<h2>Blogi</h2>";
if($_SESSION['login'] != NULL)
echo "<a href=?owner=".$_SESSION['login'].">Mój blog</a>";
echo "<h3>Lista blogów</h3>";
$q = mysql_query("SELECT `name`, `owner`, `lastupdate` FROM `blogs` ORDER BY `lastupdate` DESC");
if($q == false) {
echo "błąd";
die;
}
while($r=mysql_fetch_row($q)) {
echo "<h4><a href=?owner=".$r[1].">".$r[0]."</a></h4>Autor: ".$r[1]."<br>Liczba wpisów: ".mysql_num_rows(mysql_query("SELECT `postid` FROM `blog_posts` WHERE `owner`='".$r[1]."' AND `posttype`=0"))."<br>";
if($r[2] > 0)
echo "Ostatni wpis: ".date("Y-m-d H:i:s",$r[2]);
}
}
if($_GET['owner'] != NULL) {
echo "<a href=?>Blogi</a>\\".$_GET['owner']."<br>";
if($_POST['create'] == 1) {
$q = mysql_query("INSERT INTO `blogs` (owner, name) VALUES ('".$_SESSION['login']."','".$_POST['blogtitle']."')");
if($q == false) {
echo "Błąd";
die;
}
echo "Blog został założony.<br>";
}
if($_POST['comment'] == 1) {
$post = str_replace("\r\n","LINE",$_POST['comment']);
$zapytanie = "INSERT INTO `blog_posts` (`id`, `owner`, `author`, `postid`, `posttype`, `post`) VALUES ('','".$_GET['owner']."','".$_SESSION['login']."',".$_POST['postid'].",1,'" . $post . "\r\n\r\n" . date("Y-m-d H:i:s") . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd";
die;
}
if($_GET['owner'] != $_SESSION['login']) {
$msg = "User ".$_SESSION['login']." has commented post on your blog: ".mysql_query(mysql_fetch_row("SELECT `name` FROM `blog_posts` WHERE `owner`='".$_GET['owner']."' AND `postid`='".$_POST['postid']."'"))[0].".\r\nComment:\r\n".$post."\r\n\r\nNote, this message has been sent automatically.\r\nGreetings,\r\nElten Support";
$date = date("d.m.Y H:i");
$zapytanie = "INSERT INTO `messages` (`id`, `sender`, `receiver`, `subject`, `message`, `date`, `deletedfromreceived`, `deletedfromsent`) VALUES ('', 'elten', '".$_GET['owner']."', 'New comment on your blog', '" . $msg . "', '" . $date . "',0,0)";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "Błąd";
die;
}
}
echo "Komentarz został dodany.<BR>";
}
if($_POST['postadd'] == 1) {
$post = str_replace("\r\n","LINE",$_POST['post']);
$postid=1;
$zapytanie = "SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_SESSION['login']."'";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "-1";
die;
}
while($wiersz = mysql_fetch_row($idzapytania)) {
if($wiersz[0]>=$postid)
$postid = $wiersz[0]+1;
}
$zapytanie = "INSERT INTO `blog_posts` (`id`,`owner`,`author`,`postid`,`posttype`,`name`,`post`) VALUES ('','" . $_SESSION['login'] . "','".$_SESSION['login']."'," . $postid . ",0,'".$_POST['postname']."','" . $post . "\r\n\r\n" . date("Y-m-d H:i:s") . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "BŁĄD";
die;
}
$qc = mysql_query("SELECT `id`, `name` FROM `blog_categories` WHERE `owner`='".$_GET['owner']."'");
while($rc = mysql_fetch_row($qc)) {
if($_POST['postcategory'.$rc[0]] == on) {
$zapytanie = "INSERT INTO `blog_assigning` (id,owner,categoryid,postid) VALUES ('','".$_SESSION['login']."',".$rc[0].",".$postid.")";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "BŁĄD";
die;
}
}
}
echo "Post został dodany.<BR>";
}
if($_POST['categoryadd'] == 1) {
$zapytanie = "INSERT INTO `blog_categories` (id, owner, name) VALUES ('','".$_SESSION['login']."','" . $_POST['categoryname'] . "')";
$idzapytania = mysql_query($zapytanie);
if($idzapytania == false) {
echo "BŁĄD";
die;
}
echo "Kategoria została utworzona.<BR>";
}
if($_GET['owner'] == $_SESSION['login'] AND mysql_num_rows(mysql_query("SELECT `name` FROM `blogs` WHERE `owner`='".$_SESSION['login']."'")) == 0)
echo "<h3>Nie posiadasz bloga.</h3>Aby go utworzyć, użyj poniższego formularza.<br><form action=?owner=".$_SESSION['login']." method=POST><input type=hidden name=create value=1><label for=blogtitle>Tytuł bloga: </label><input id=blogtitle name=blogtitle><br><input type=submit value=\"Załóż bloga\"></form>";
else {
$q = mysql_query("SELECT `name` FROM `blogs` WHERE `owner`='".$_GET['owner']."'");
if($q == false) {
echo "Bloga nie znaleziono.";
die;
}
echo "<h2>".mysql_fetch_row($q)[0]."</h2>";
$q = mysql_query("SELECT `id`, `name` FROM `blog_categories` WHERE `owner`='".$_GET['owner']."'");
if($q == false) {
echo "błąd";
die;
}
if($_GET['category']==0)
echo "<H3>Wszystkie wpisy</h3>";
else
echo mysql_fetch_row(mysql_query("SELECT `name` FROM `blog_categories` WHERE `id`=".$_GET['category']))[0];
echo "<a href=?owner=".$_GET['owner']."&category=0>Wszystkie wpisy</a><br>";
while($r = mysql_fetch_row($q)) {
echo "<a href=?owner=".$_GET['owner']."&category=".$r[0].">".$r[1]."</a>";
}
$ass = mysql_query("SELECT `postid` FROM `blog_posts` WHERE `owner`='".$_GET['owner']."' AND `posttype`=0 ORDER BY `postid` DESC");
if($_GET['category'] > 0) {
$ass = mysql_query("SELECT `postid` FROM `blog_assigning` WHERE `owner`='".$_GET['owner']."' AND `categoryid`=".$_GET['category']." ORDER BY `postid` DESC");
}
if($ass == false) {
echo "błąd";
die;
}
while($asr = mysql_fetch_row($ass)) {
$postid = $asr[0];
$q = mysql_query("SELECT `author`, `post`, `posttype` FROM `blog_posts` WHERE `owner`='".$_GET['owner']."' AND `postid`=".$postid);
if($q == false) {
echo "BŁĄD";
die;
}
echo "<h4>".mysql_fetch_row(mysql_query("SELECT `name` FROM `blog_posts` WHERE `owner`='".$_GET['owner']."' AND `postid`=".$postid))[0]."</h4>";
while($r = mysql_fetch_row($q)) {
if($r[2] != 0)
echo "<h5>".$r[0]."</h5>";
$post = str_replace("LINE","<br>",$r[1]);
echo $post;
}
if($_SESSION['login'] != NULL) {
if($_GET['category'] != 0)
$category = $_GET['category'];
else
$category = 0;
echo "<h5>Skomentuj</h5><form action=?owner=".$_GET['owner']."&category=".$category." method=POST><input type=hidden name=comment value=1><input type=hidden name=postid value=".$postid.">Twój komentarz: <textarea cols=100 rows=20 name=comment></textarea><input type=submit value=\"Dodaj komentarz...\"></form>";
}
}
if($_SESSION['login'] == $_GET['owner']) {
if($_GET['category'] != 0)
$category = $_GET['category'];
else
$category = 0;
echo "<h3>Nowy wpis</h3><form action=?owner=".$_GET['owner']."&category=".$category." method=POST>";
echo "<input type=hidden name=postadd value=1>";
echo "<label for=postname>Tytuł wpisu: </label><input id=postname name=postname><br>";
echo "<label for=post>Treść wpisu: </label><textarea cols=100 rows=20 id=post name=post></textarea>";
echo "Dodaj do kategorii:<br>";
$qc = mysql_query("SELECT `id`, `name` FROM `blog_categories` WHERE `owner`='".$_GET['owner']."'");
while($rc = mysql_fetch_row($qc)) {
echo "<input type=checkbox id=postcategory".$rc[0]." name=postcategory".$rc[0]." ";
if($rc[0] == $category)
echo "checked";
echo "><label for=postcategory".$rc[0].">".$rc[1]."</label><br>";
}
echo "<input type=submit value=\"Dodaj wpis...\">";
echo "</form>";
echo "<h3>Nowa kategoria</h3><form action=?owner=".$_GET['owner']." method=POST><input type=hidden name=categoryadd value=1><label for=categoryname>Nazwa kategorii: </label><input id=categoryname name=categoryname><br><input type=submit value=\"Dodaj kategorię...\"></form>";
}

}
}
require("footer.php");
?>