<?php
function elten_footer(){
echo "<p><a href=\"https://elten-net.eu\">Elten Network</a></p>";
}
add_action( 'wp_footer', 'elten_footer', 5 );
?>