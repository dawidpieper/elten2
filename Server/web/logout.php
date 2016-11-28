<?php
session_start();
session_destroy();
require("header.php");
echo "<h2>Wylogowanie powiodło się</h2>Zostałeś wylogowany.<br><a href=login.php>Zaloguj się ponownie</a><br>";
require("footer.php");

//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>