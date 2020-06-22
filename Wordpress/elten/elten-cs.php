<?php
defined( 'ABSPATH' ) or die( 'No script kiddies please!' );

if(defined("elten_hideblogs")) {
function elten_cs_redirect() {
if(!is_feed()) {
if ( !is_user_logged_in()  ) {
display_cs_page();
}
}
}

add_action('init','elten_cs_get_preview');

function elten_cs_get_preview () {
if (  (isset($_GET['get_preview']) && $_GET['get_preview'] == 'true') ) {
display_cs_page();
}
}

add_action('init','elten_cs_skip_redirect_on_login');

function elten_cs_skip_redirect_on_login () {
global $currentpage;
if ('wp-login.php' == $currentpage || 'login' == $currentpage) {
return;
} else {
add_action( 'template_redirect', 'elten_cs_redirect' );
}
}

function display_cs_page() {
if(isset($_GET['q']) && $_GET['q']=="/login") return;
echo "This site is still under construction and will be available soon. If you are Elten user, please <a href=\"https://{$_SERVER['HTTP_HOST']}/wp-login.php?redirect_to=".urlencode("https://{$_SERVER['HTTP_HOST']}")."&reauth=1\">login to your Wordpress account</a>.";
exit();
}
}
?>