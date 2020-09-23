<?php
require("init.php");
echo "0\r\n".implode("\r\n",getprivileges($_GET['searchname']));
?>