<?php
if (!defined('ABSPATH')) { exit; }
function elten_allow_hyphenated_usernames( $result ) {
$error_name = $result[ 'errors' ]->get_error_message( 'user_name' );
if ( ! empty ( $error_name ) 
&& $error_name == __( 'Usernames can only contain lowercase letters (a-z) and numbers.' ) 
&& $result['user_name'] == $result['orig_username'] 
&& ! preg_match( '/[^-_.a-z0-9]/', $result['user_name'] ) 
)
unset ( $result[ 'errors' ]->errors[ 'user_name' ] );
if ( ! empty ( $error_name ) 
&& $result['user_name'] == $result['orig_username'] 
&& $error_name == __( 'Username must be at least 4 characters.' ) 
)
unset ( $result[ 'errors' ]->errors[ 'user_name' ] );
$error_name = $result[ 'errors' ]->get_error_message( 'email' );
if ( ! empty ( $error_name ) 
&& $error_name == __( 'Invalid email address.' ) 
&& strpos($result['email'], '@elten-net.eu')>0
)
unset ( $result[ 'errors' ]->errors[ 'email' ] );
return $result;
}
add_filter( 'wpmu_validate_user_signup', 'elten_allow_hyphenated_usernames' );


function elten_wpmu_remove_default_content($blog_id, $user_id, $domain, $path, $site_id, $meta) {
if(!current_user_can('manage_network')) return;
switch_to_blog($blog_id);
wp_delete_post(1, true);
wp_delete_post(2, true);
wp_delete_comment( 1, true );
restore_current_blog();
}
add_action( 'wpmu_new_blog', 'elten_wpmu_remove_default_content', 10, 6);
?>