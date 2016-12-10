<?php
session_start();
$sql = mysql_connect("localhost", "dbuser", "dbpass")
or die("Błąd połączenia się z bazą danych.");
$sql_select = @mysql_select_db('dbname')
or die("Błąd połączenia się z bazą danych.");
if(mysql_query("SET NAMES utf8") == false) {
echo "Błąd";
die;
}
$cdate = time();
$_SESSION['ses_ok'] = 1;
?>