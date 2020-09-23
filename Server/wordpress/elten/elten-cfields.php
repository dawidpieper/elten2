<?php
add_action( 'rest_api_init', 'add_custom_fields' );
function add_custom_fields() {
register_rest_field(
'post', 
'elten_commentscount',
array(
'get_callback'    => 'get_commentscount',
'description' => 'Comments count',
'type' => 'int',
'context' => array('view')
)
);

register_rest_field(
'user', 
'elten_user',
array(
'get_callback'    => 'get_eltenuser',
'update_callback'    => 'update_eltenuser',
'description' => 'Elten username',
'type' => 'string',
'context' => array('view')
)
);

register_rest_field(
'category', 
'elten_postscount',
array(
'get_callback'    => 'get_postscountincategory',
'description' => 'Posts count',
'type' => 'int',
'context' => array('view')
)
);
}
function get_commentscount($post, $field_name, $request) {
$comments_by_type = &separate_comments(get_comments('status=approve&post_id=' . (int)$post['id']));
$c=count($comments_by_type['comment']);
return($c);
}
function get_eltenuser($user, $field_name, $request) {
return(get_user_meta($user['id'], "elten_user", true));
}
function update_eltenuser($value, $user) {
update_user_meta($user->ID, "elten_user", $value);
return(true);
}
function get_postscountincategory($category, $field_name, $request) {
return(count(get_posts(array('numberposts'=>-1, 'category__in'=>$category['id'], 'post_status'=>array('publish', 'private'), 'suppress_filters'=>false, 'fields'=>'id'))));
}