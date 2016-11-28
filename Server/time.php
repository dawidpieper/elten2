<?php
$dateformat = $_GET['dateformat'];
if($_GET['dateformat'] == null)
$dateformat = "H:i:s";
$datetime = $_GET['datetime'];
if($_GET['datetime'] == null)
$datetime = time();
echo date($dateformat,$datetime);
//Elten Server
//Copyright (2014-2016) Dawid Pieper
//All rights reserved
?>