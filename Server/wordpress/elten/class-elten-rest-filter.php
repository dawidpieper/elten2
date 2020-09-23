<?php

class REST_Api_Filter_Fields {

public function __construct(){
add_action('rest_api_init',array($this,'init'),20);
}


public function init(){

$post_types = get_post_types(array('public' => true), 'objects');

foreach ($post_types as $post_type) {

$show_in_rest = ( isset( $post_type->show_in_rest ) && $post_type->show_in_rest ) ? true : false;
if($show_in_rest) {

$post_type_name = $post_type->name;


add_filter('rest_prepare_'.$post_type_name,array($this,'filter_magic'),20,3);
}

}

$tax_types = get_taxonomies(array('public' => true), 'objects');

foreach ($tax_types as $tax_type) {

$show_in_rest = ( isset( $tax_type->show_in_rest ) && $tax_type->show_in_rest ) ? true : false;
if($show_in_rest) {

$tax_type_name = $tax_type->name;


add_filter('rest_prepare_'.$tax_type_name,array($this,'filter_magic'),20,3);
}

}

add_filter('rest_prepare_comment',array($this,'filter_magic'),20,3);
add_filter('rest_prepare_taxonomy',array($this,'filter_magic'),20,3);
add_filter('rest_prepare_term',array($this,'filter_magic'),20,3);
add_filter('rest_prepare_category',array($this,'filter_magic'),20,3);
add_filter('rest_prepare_user',array($this,'filter_magic'),20,3);
}


public function filter_magic( $response, $post, $request ){
$fields = $request->get_param('fields');
if($fields){

$filtered_data = array();

$data = $response->data;

if(isset( $_GET['_embed'] )){
$rest_server = rest_get_server();
$data = $rest_server->response_to_data($response,true);
} else {
$data['_links'] = $response->get_links();
}

$filters = explode(',',$fields);

if(empty($filters) || count($filters) == 0)
return $response;

$singleFilters = array_filter($filters,array($this,'singleValueFilterArray'));

foreach ($data as $key => $value) {
if (in_array($key, $singleFilters)) {
$filtered_data[$key] = $value;
}
}

$childFilters = array_filter($filters,array($this,'childValueFilterArray'));

foreach ($childFilters as $childFilter) {
$val = $this->array_path_value($data,$childFilter);
if($val != null){
$this->set_array_path_value($filtered_data,$childFilter,$val);
}
}

}

if (isset($filtered_data) && count($filtered_data) > 0) {
$newResp = rest_ensure_response($filtered_data);
return $newResp;
}

return $response;
}

function singleValueFilterArray($var){
return (strpos($var,'.') ===false);
}

function childValueFilterArray($var){
return (strpos($var,'.') !=false);
}

function array_path_value(array $array, $path, $default = null)
{
$delimiter = '.';

if (empty($path)) {
throw new Exception('Path cannot be empty');
}

$path = trim($path, $delimiter);

$value = $array;

$parts = explode($delimiter, $path);

foreach ($parts as $part) {
if (isset($value[$part])) {
$value = $value[$part];
} elseif('first' == $part && is_array($value)){
$value = $value[0];
} else {
return $default;
}
}

return $value;
}

function set_array_path_value(array &$array, $path, $value)
{
if (empty($path)) {
throw new Exception('Path cannot be empty');
}

if (!is_string($path)) {
throw new Exception('Path must be a string');
}

$delimiter = '.';

$path = trim($path, $delimiter);

$parts = explode($delimiter, $path);

$pointer =& $array;

foreach ($parts as $part) {
if (empty($part)) {
throw new Exception('Invalid path specified: ' . $path);
}

if (!isset($pointer[$part])) {
$pointer[$part] = array();
}

$pointer =& $pointer[$part];
}

$pointer = $value;
}
}
new REST_Api_Filter_Fields();