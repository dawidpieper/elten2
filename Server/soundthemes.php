<?php
require("header.php");
echo "0";
foreach(glob('soundthemes/inis/*.ini', GLOB_BRACE) as $file)
echo "\r\n" . $file;
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>