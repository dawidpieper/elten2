<?php
if($_GET['int']==NULL) {
$dateformat = $_GET['dateformat'];
if($_GET['dateformat'] == null)
$dateformat = "H:i:s";
$datetime = $_GET['datetime'];
if($_GET['datetime'] == null)
$datetime = time();
echo date($dateformat,$datetime);
}
else
echo time();
?>