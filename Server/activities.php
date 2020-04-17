<?php
require("header.php");
if($_GET['ac']=="register") {
$ac=$_GET['activity'];
$contentType = isset($_SERVER["CONTENT_TYPE"]) ? trim($_SERVER["CONTENT_TYPE"]) : '';
if(strcasecmp($contentType, 'application/json') == 0) {
$ac = trim(file_get_contents("php://input"));
}
mquery("insert into activities (time, user, activities) values (unix_timestamp(), '".mysql_real_escape_string($_GET['name'])."', '".mysql_real_escape_string($ac)."')");
echo "0";
}
?>