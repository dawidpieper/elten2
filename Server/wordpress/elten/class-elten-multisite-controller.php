<?php
if (!defined('ABSPATH')) { exit; }
require_once ABSPATH . 'wp-admin/includes/ms.php';

class Elten_Multisite_Controller {

public $namespace = 'elten';

public function __construct() {
if ( ! is_multisite() ) exit();

$this->register_routes();
}

private function get_blogmeta($arr) {
$r = array();
$allowed = array('public', 'archived', 'mature', 'spam', 'deleted', 'lang_id');
foreach($allowed as $a) if(isset($arr[$a])) $r[$a]=$arr[$a];
return($r);
}

private function extract_site( array $params ) {
if ( array_key_exists( 'id', $params ) && is_numeric( $params['id'] ) )
$site = get_blog_details( $params['id'] );
elseif ( array_key_exists( 'slug', $params ) && is_string( $params['slug'] ) )
$site = get_blog_details( $params['slug'] );
else wp_die(new WP_Error( 'no_site', 'No blog id nor slug', array( 'status' => 400 ) ));
if ( ! $site ) wp_die(new WP_Error( 'no_site', 'Site not found', array( 'status' => 404 ) ));
return $site;
}

private function register_routes() {
register_rest_route( $this->namespace, '/blogs', array(
'methods' => 'POST',
'callback' => array($this, 'command_blog_create'),
));

register_rest_route( $this->namespace, '/blogs', array(
'methods' => 'GET',
'callback' => array($this, 'command_blog_list'),
));

register_rest_route( $this->namespace, '/blog/(?P<id>[\d]+)', array(
'methods' => 'POST',
'callback' => array($this, 'command_blog_edit'),
));

register_rest_route( $this->namespace, '/blog/(?P<id>[\d]+)', array(
'methods' => 'DELETE',
'callback' => array($this, 'command_blog_delete'),
));

register_rest_route( $this->namespace, '/blog/(?P<id>[\d]+)', array(
'methods' => 'PUT',
'callback' => array($this, 'command_blog_edit'),
));

register_rest_route( $this->namespace, '/allusers', array(
'methods' => 'GET',
'callback' => array($this, 'command_blog_allusers'),
));

register_rest_route( $this->namespace, '/allposts', array(
'methods' => 'GET',
'callback' => array($this, 'command_blog_allposts'),
));

register_rest_route( $this->namespace, '/blogoptions', array(
'methods' => 'GET',
'callback' => array($this, 'command_blog_options'),
));

register_rest_route( $this->namespace, '/blogoptions', array(
'methods' => 'POST',
'callback' => array($this, 'command_blog_options_edit'),
));

register_rest_route( $this->namespace, '/languages', array(
'methods' => 'GET',
'callback' => array($this, 'command_languages'),
));

register_rest_route( $this->namespace, '/timezones', array(
'methods' => 'GET',
'callback' => array($this, 'command_timezones'),
));

register_rest_route( $this->namespace, '/profile/(?P<user>[\d]+)', array(
'methods' => 'GET',
'callback' => array($this, 'command_profile'),
));

register_rest_route( $this->namespace, '/profile/(?P<user>[\d]+)', array(
'methods' => 'POST',
'callback' => array($this, 'command_profile_edit'),
));

register_rest_route( $this->namespace, '/password/(?P<user>[\d]+)', array(
'methods' => 'POST',
'callback' => array($this, 'command_password_edit'),
));
}

public function command_blog_create( WP_REST_Request $request ) {
if(!is_super_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
$params = $request->get_params();
if(!isset($params['domain']) || !isset($params['admin']) || !isset($params['title'])) return((new WP_Error( 'no_params', 'Required parameters not provided', array( 'status' => 400 ) )));
$site = get_current_site();
$domain = $params['domain'];

$path = '/';
$title  = $params['title'];
$admin  = $params['admin'];
if ( ! is_numeric( $admin ) )  $admin = get_user_by( 'login', $params['admin'] )->id;

$result = wpmu_create_blog($domain, $path, $title, $admin, $meta);

if ( is_numeric( $result ) ) {
switch_to_blog($result);
if(isset($params['description']))
update_option( 'blogdescription', $params['description']);
update_option( 'comments_notify', null);
update_option( 'moderation_notify', null);
update_option( 'comment_whitelist', null);
update_option( 'comment_order', 'desc');
update_option( 'blog_public', 1);
update_option( 'siteurl', 'https://'.$domain);
update_option( 'home', 'https://'.$domain);
restore_current_blog();
$meta = $this->get_blogmeta($params);
foreach($meta as $k=>$v) update_blog_option($params['id'], $k, $v);
$r=array();
if(isset($params['editors']))
foreach($params['editors'] as $user)
add_user_to_blog($result, $user, 'editor' );
$r['status']=200;
$r['id']=$result;
$r['domain']=$domain;
return $r;
} else return $result;
}

public function command_blog_list( WP_REST_Request $request ) {
$params = $request->get_params();
if(isset($params['filter_domains']) && !is_array($params['filter_domains'])) $params['filter_domains']=explode(",",$params['filter_domains']);
if(isset($params['filter_users']) && !is_array($params['filter_users'])) $params['filter_users']=explode(",",$params['filter_users']);
$sites = get_sites(array('number'=>1000000));
$arr=array();
foreach($sites as $site) {
if((int)($site->blog_id)<10) continue;
$users = get_users(array('blog_id' => $site->blog_id, 'role__in'=>array('administrator', 'editor', 'author')));
if(isset($params['filter_domains']) || isset($params['filter_users'])) {
$suc=false;
if(isset($params['filter_domains']) && in_array($site->domain, $params['filter_domains'])) $suc=true;
if(isset($params['filter_users'])) {
foreach($users as $u)
if(in_array($u->id, $params['filter_users'])) $suc=true;
}
if(!$suc) continue;
}
$o=array('id'=>$site->blog_id, 'domain'=>$site->domain, 'path'=>$site->path);
switch_to_blog($site->blog_id);
$o['users'] = array();
usort($users, function ($a, $b) {
if(in_array('administrator', $a->roles) && !in_array('administrator', $b->roles))
return -1;
if(in_array('administrator', $b->roles) && !in_array('administrator', $a->roles))
return 1;
else
return 0;
});
foreach($users as $user) {
$u=array('id'=>$user->id, 'user'=>$user->user_login, 'name'=>$user->display_name, 'elten'=>get_user_meta($user->id, "elten_user", true));
array_push($o['users'], $u);
}
$o['name']=get_bloginfo("name");
$o['description']=get_bloginfo("description");
$posts = get_posts(array('numberposts'=>-1, 'order'=>'desc', 'orderby'=>'date', 'post_status'=>array('private', 'publish'), 'ignore_sticky_posts'=>true));
$cntc=array();
$commentscount=0;
foreach($posts as $p) {
$cnt=$p->comment_count;
array_push($cntc, $cnt);
$commentscount+=$cnt;
}
$o['cnt_comments'] = $commentscount;
sort($cntc);
if(count($cntc)%2==1) $mediana=$cntc[count($cntc)/2];
else $mediana=($cntc[count($cntc)/2]+$cntc[count($cntc)/2])/2;
$o['mediana_comments']=$mediana;
$lasttime = str_replace(" ","T",$posts[0]->post_date_gmt."+0000");
$firsttime = str_replace(" ","T",$posts[count($posts)-1]->post_date_gmt."+0000");
$o['lastpost'] = $lasttime;
$o['firstpost'] = $firsttime;
$o['cnt_posts'] = count($posts);
restore_current_blog();
array_push($arr, $o);
}
return($arr);
}

public function command_blog_delete( WP_REST_Request $request ) {
if(!is_super_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
$params = $request->get_params();
wpmu_delete_blog($params['id'], true);
return array();
}

public function command_blog_edit( WP_REST_Request $request ) {
if(!is_super_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
$params = $request->get_params();
$meta = $this->get_blogmeta($params);
$r=array();
foreach($meta as $k=>$v)
if(update_blog_option($params['id'], $k, $v))
$r[$k]=$v;
if(isset($params['users_add'])) {
if(!is_array($params['users_add'])) $params['users_add'] = explode(",", $params['users_add']);
foreach($params['users_add'] as $u)
add_user_to_blog($params['id'], $u, 'editor' );
}
if(isset($params['users_remove'])) {
if(!is_array($params['users_remove'])) $params['users_remove'] = explode(",", $params['users_remove']);
foreach($params['users_remove'] as $u)
remove_user_from_blog($u, $params['id']);
}
if(isset($params['name'])) {
update_blog_option($params['id'], "blogname", $params['name']);
}
return($r);
}

public function command_blog_allusers( WP_REST_Request $request ) {
$u=get_users();
$r=array();
foreach($u as $k=>$v) {
$d=$v->to_array();
$a=array('id'=>$d['ID'], 'username'=>$d['user_login'], 'name'=>$d['display_name']);
$a['elten'] = $found = get_user_meta($d['ID'], 'elten_user', true);
if($a['elten']==null) continue;
array_push($r, $a);
}
return $r;
}

public function command_blog_allposts( WP_REST_Request $request ) {
$params = $request->get_params();
if(isset($params['filter_domains']) && !is_array($params['filter_domains'])) $params['filter_domains']=explode(",",$params['filter_domains']);
if(isset($params['filter_users']) && !is_array($params['filter_users'])) $params['filter_users']=explode(",",$params['filter_users']);
$blogs = array();
$sites = get_sites(array('number'=>1000000));
foreach($sites as $site) {
if($site->blog_id<10) continue;
$users = get_users(array('blog_id' => $site->blog_id, 'role__in'=>array('administrator', 'editor', 'author')));
if(isset($params['filter_domains']) || isset($params['filter_users'])) {
$suc=false;
if(isset($params['filter_domains']) && in_array($site->domain, $params['filter_domains'])) $suc=true;
if(isset($params['filter_users'])) {
foreach($users as $u)
if(in_array($u->id, $params['filter_users'])) $suc=true;
}
if(!$suc) continue;
}

switch_to_blog($site->blog_id);
$blogs[$site->domain] = array();
$posts = get_posts(array('numberposts'=>-1, "post_status"=>array("publish", "private")));
foreach($posts as $post) {
if(!isset($params['column']) || $params['column']=="commentscount") {
$comments_by_type = &separate_comments(get_comments('status=approve&post_id=' . (int)$post->ID));
$val=count($comments_by_type['comment']);
}
elseif($params['column']=="title") $val = $post->post_title;
elseif($params['column']=="all") {
$ptime = strtotime($post->post_date_gmt."+00:00");
$c = get_comments(array('order'=>'desc', 'post_id'=>$post->ID, 'status'=>'approve'));
$ctime=0;
if(count($c)>0)
$ctime = strtotime($c[0]->comment_date_gmt."+00:00");
$val = array('cnt_comments'=>(int)count($c), 'title'=>$post->post_title, 'time'=>$ptime, 'commenttime'=>$ctime);
}
$blogs[$site->domain][(string)$post->ID]=$val;
}
}
restore_current_blog();
return($blogs);
}

public function command_blog_options( WP_REST_Request $request ) {
if(!is_super_admin() && !is_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
$options = array("blogname", "blogdescription", "WPLANG", "blog_public", "comment_whitelist", "comment_moderation", "comment_registration", "posts_per_page", "close_comments_for_old_posts", "close_comments_days_old", "thread_comments", "thread_comments_depth", "comment_order", "use_smilies", "page_comments", "comments_per_page", "date_format", "time_format", "gmt_offset", "timezone_string", "default_comments_page", "start_of_week", "posts_per_rss", "rss_use_excerpt", "permalink_structure", );
$j=array();
foreach($options as $opt)
$j[$opt]=get_option($opt);
return $j;
}

public function command_blog_options_edit( WP_REST_Request $request ) {
$params = $request->get_params();
if(!is_super_admin() && !is_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
$options = array("blogname", "blogdescription", "WPLANG", "blog_public", "comment_whitelist", "comment_moderation", "comment_registration", "posts_per_page", "close_comments_for_old_posts", "close_comments_days_old", "thread_comments", "thread_comments_depth", "comment_order", "use_smilies", "page_comments", "comments_per_page", "date_format", "time_format", "gmt_offset", "timezone_string", "default_comments_page", "start_of_week", "posts_per_rss", "rss_use_excerpt", "permalink_structure", );
foreach($options as $opt)
if(isset($params[$opt]))
update_option($opt, $params[$opt]);
return array();
}

public function command_languages( WP_REST_Request $request ) {
if(!is_super_admin() && !is_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
require_once ABSPATH . 'wp-admin/includes/translation-install.php';
$languages = get_available_languages();
$translations = wp_get_available_translations();
$j=array(''=>array('language'=>'', 'english_name'=>"English (US)", 'native_name'=>'English (US)'));
foreach($translations as $k=>$v) {
if(in_array($k, $languages)) {
$j[$k]=$v;
}
}
return $j;
}

public function command_timezones( WP_REST_Request $request ) {
static $mo_loaded = false, $locale_loaded = null;
$r=array();
$continents = array( 'Africa', 'America', 'Antarctica', 'Arctic', 'Asia', 'Atlantic', 'Australia', 'Europe', 'Indian', 'Pacific' );
if ( ! $mo_loaded || $locale !== $locale_loaded ) {
$locale_loaded = $locale ? $locale : get_locale();
$mofile = WP_LANG_DIR . '/continents-cities-' . $locale_loaded . '.mo';
unload_textdomain( 'continents-cities' );
load_textdomain( 'continents-cities', $mofile );
$mo_loaded = true;
}
$zonen = array();
foreach ( timezone_identifiers_list() as $zone ) {
$zone = explode( '/', $zone );
if ( ! in_array( $zone[0], $continents ) ) {
continue;
}
$exists = array(
0 => ( isset( $zone[0] ) && $zone[0] ),
1 => ( isset( $zone[1] ) && $zone[1] ),
2 => ( isset( $zone[2] ) && $zone[2] ),
);
$exists[3] = ( $exists[0] && 'Etc' !== $zone[0] );
$exists[4] = ( $exists[1] && $exists[3] );
$exists[5] = ( $exists[2] && $exists[3] );
$zonen[] = array(
'continent' => ( $exists[0] ? $zone[0] : '' ),
'city' => ( $exists[1] ? $zone[1] : '' ),
'subcity' => ( $exists[2] ? $zone[2] : '' ),
't_continent' => ( $exists[3] ? translate( str_replace( '_', ' ', $zone[0] ), 
'continents-cities' ) : '' ),
't_city' => ( $exists[4] ? translate( str_replace( '_', ' ', $zone[1] ), 
'continents-cities' ) : '' ),
't_subcity' => ( $exists[5] ? translate( str_replace( '_', ' ', $zone[2] ), 
'continents-cities' ) : '' ),
);
}
usort( $zonen, '_wp_timezone_choice_usort_callback' );
$structure = array();
foreach ( $zonen as $key => $zone ) {
$value = array( $zone['continent'] );
if ( empty( $zone['city'] ) ) {
$display = $zone['t_continent'];
} else {
if ( ! isset( $zonen[ $key - 1 ] ) || $zonen[ $key - 1 ]['continent'] !== $zone[
'continent'] ) {
$label = $zone['t_continent'];
$structure[] = '<optgroup label="' . esc_attr( $label ) . '">';
}
$value[] = $zone['city'];
$display = $zone['t_city'];
if ( ! empty( $zone['subcity'] ) ) {
$value[] = $zone['subcity'];
$display .= ' - ' . $zone['t_subcity'];
}
}
$value = join( '/', $value );
$r[$value]=$display;
}
return $r;
}

public function command_profile( WP_REST_Request $request ) {
$params = $request->get_params();
$userid=$params['user'];
$user = get_user_by('id', $userid);
$j=array();
$j['user_login'] = $user->user_login;
$j['display_name'] = $user->display_name;
$j['first_name'] = get_user_meta($userid, "first_name", true);
$j['last_name'] = get_user_meta($userid, "last_name", true);
$j['nickname'] = get_user_meta($userid, "nickname", true);
$j['description'] = get_user_meta($userid, "description", true);
return $j;
}

public function command_profile_edit( WP_REST_Request $request ) {
if(!is_super_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
$params = $request->get_params();
$userid=$params['user'];
$user = get_user_by('id', $userid);
if(isset($params['display_name'])) {
$user->display_name = $params['display_name'];
wp_update_user($user);
}
if(isset($params['first_name'])) update_user_meta($userid, "first_name", $params['first_name']);
if(isset($params['last_name'])) update_user_meta($userid, "last_name", $params['last_name']);
if(isset($params['nickname'])) update_user_meta($userid, "nickname", $params['nickname']);
if(isset($params['description'])) update_user_meta($userid, "description", $params['description']);
return array();
}

public function command_password_edit( WP_REST_Request $request ) {
if(!is_super_admin()) return((new WP_Error( 'no_permissions', 'You have no permissions to do this', array( 'status' => 403 ) )));
$params = $request->get_params();
if(isset($params['password'])) {
$params = $request->get_params();
wp_set_password($params['password'], $params['user']);
}
return array();
}
}
?>