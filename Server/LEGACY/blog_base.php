<?php
require("secret.php");
function wp_close() {
global $wpch;
if(isset($wpch) and $wpch!=null) {
curl_close($wpch);
$wpch=null;
}
}
function wp_query($method, $cat, $blog="", $body="", &$headers=null, $fail=true) {
global $wpch, $wp_pass;
if(!isset($wpch) or $wpch==null) {
$wpch = curl_init();
curl_setopt_array($wpch, array(
CURLOPT_RETURNTRANSFER => true,
CURLOPT_ENCODING => "",
CURLOPT_TIMEOUT => 5,
CURLOPT_FOLLOWLOCATION => true,
CURLOPT_HTTPHEADER => array(
"Cache-Control: no-cache",
"Accept: application/json",
"Content-Type: application/json",
),
));
register_shutdown_function('wp_close');
}
$domain="elten.blog";
if($blog!="") $domain=wp_domainize($blog);
if(!wp_iseltenblog($blog)) {
if(!wp_iswordpresscom($domain))
$url="https://".$domain."/wp-json?rest_route=".$cat;
else
$url = "https://public-api.wordpress.com/wp/v2/sites/".$domain.str_replace("/wp/v2/", "/", $cat);
}
else {
$url="https://".$domain."/wp-json?rest_route=".$cat;
}
curl_setopt($wpch, CURLOPT_CUSTOMREQUEST, $method);
if($method!="GET" || (wp_iseltenblog($blog) || wp_iswordpresscom($domain)))
curl_setopt($wpch, CURLOPT_POSTFIELDS, json_encode($body));
else {
foreach($body as $k=>$v) {
$url.="&".urlencode($k)."=".urlencode($v);
}
}
curl_setopt($wpch, CURLOPT_URL, $url);
if(!is_array($headers)) $headers=array();
if(wp_iseltenblog($blog)) {
$ps="admin:".$wp_pass;
curl_setopt($wpch, CURLOPT_USERPWD, $ps);
curl_setopt($wpch, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);
}
curl_setopt($wpch, CURLOPT_HEADERFUNCTION,
function($curl, $header) use (&$headers) {
$len = strlen($header);
$header = explode(':', $header, 2);
if (count($header) < 2) // ignore invalid headers
return $len;
$headers[strtolower(trim($header[0]))] = trim($header[1]);
return $len;
});
$response = curl_exec($wpch);
$err = curl_error($wpch);
if($err) {
if($fail) die("-1");
else return false;
}
$j=json_decode($response, true);
return $j;
}
function wp_domainize($blog) {
global $wp_domainized;
$q=mquery("select domain from blogs_mapping where blog='".mysql_real_escape_string($blog)."'");
if(mysql_num_rows($q)>0) return mysql_fetch_row($q)[0];
if($blog[0]=="[" && $blog[1]=="*" && strpos($blog, "/")===false) {
$r=substr($blog, 2, -1);
return $r;
}
if(!isset($wp_domainized)) $wp_domainized=array();
if(!isset($wp_domainized[$blog])) {
$d = transliterator_transliterate('Any-Latin;Latin-ASCII;', str_replace(".","",str_replace(" ","",strtolower($blog))));
if(strpos($d, "[")===0)
$d=substr($d, 1, -1).".s.elten.blog";
else
$d.=".elten.blog";
$wp_domainized[$blog]=$d;
}
else $d = $wp_domainized[$blog];
if(strpos($d, ".")===0) return "elten.blog";
return($d);
}

function wp_dedomainize($domain) {
$q=mquery("select blog from blogs_mapping where domain='".mysql_real_escape_string($domain)."'");
if(mysql_num_rows($q)>0) return mysql_fetch_row($q)[0];
$s = strpos($domain, ".s.elten.blog");
if($s===strlen($domain)-strlen(".s.elten.blog")) return "[".substr($domain, 0, $s)."]";
$s = strpos($domain, ".elten.blog");
if($s===strlen($domain)-strlen(".elten.blog")) {
$u = substr($domain, 0, $s);
$q=mquery("select name from users");
while($r=mysql_fetch_row($q)) {
$d = transliterator_transliterate('Any-Latin;Latin-ASCII;', str_replace(".","",str_replace(" ","",strtolower($r[0]))));
if($domain==$d.".elten.blog") return $r[0];
}
}
return "[*".$domain."]";
}

function wp_domain() {
return "elten.blog";
}

function blogowners($blog) {
if(strpos($blog, "[")===false) return array($blog);
else {
$owners=array();
$blogs = wp_query("GET", "/elten/blogs");
foreach($blogs as $b) {
if($b['domain'] == wp_domainize($blog)) {
foreach($b['users'] as $u) array_push($owners, $u['elten']);
}
}
return $owners;
}
}
function wp_userid($user, $create=false) {
$userid=0;
$users=wp_query("GET", "/elten/allusers");
foreach($users as $u) if($u['elten']==$user) $userid=$u['id'];
if($userid==0 and $create==true) {
$name = transliterator_transliterate('Any-Latin;Latin-ASCII;', strtolower($user));
$password=random_str(24);
$j=array('username'=>$user, 'name'=>$user, 'email'=>$user."@elten-net.eu", 'nickname'=>$user, 'password'=>$password, 'elten_user'=>$user);
$w = wp_query("POST", "/wp/v2/users", "", $j);
$userid=$w['id'];
}
return($userid);
}

function wp_doesblogexist($blog) {
$d = wp_domainize($blog);
$w = wp_query("GET", "/elten/blogs", "", array('filter_domains'=>array($d)));
if(count($w)>0) return true;
else return false;
}

function wp_doeshaveblog($user) {
$w = wp_query("GET", "/elten/blogs", "", array('filter_users'=>wp_userid($user)));
if(count($w)>0) return true;
else return false;
}

function parse_content($html) {
$doc = new DOMDocument();
$doc->loadHTML($html);
for($i=1; $i<=6; ++$i) {
$result = $doc->getElementsByTagName("h".$i);
while(count($result)>0) {
$node=$result[0];
$fragment = $doc->createDocumentFragment();
$heading="";
for($j=1; $j<=$i; ++$j) $heading.="#";
$fragment->appendChild($doc->createTextNode($heading." "));
while( $node->childNodes->length > 0) $fragment->appendChild($node->childNodes->item(0));
$node->parentNode->replaceChild($fragment, $node);
}
}
$result = $doc->getElementsByTagName("a");
while(count($result)>0) {
$node=$result[0];
$fragment = $doc->createDocumentFragment();
$fragment->appendChild($doc->createTextNode(" ["));
while( $node->childNodes->length > 0) $fragment->appendChild($node->childNodes->item(0));
$fragment->appendChild($doc->createTextNode("]"));
$fragment->appendChild($doc->createTextNode("(".$node->getAttribute("href").") "));
$node->parentNode->replaceChild($fragment, $node);
}
$result = $doc->getElementsByTagName("iframe");
while(count($result)>0) {
$node=$result[0];
$src=$node->getAttribute("src");
$text=$src;
$matches = array();
if(preg_match("/https\:\/\/(www\.)?youtube\.com\/embed\/([a-zA-Z0-9\_\-]+)/", $src, $matches)) {
$text="https://youtu.be/".$matches[2];
}
$newnode = $doc->createTextNode($text);
$node->parentNode->replaceChild($newnode, $node);
}
$preamble="";
$result = $doc->getElementsByTagName('source');
while(count($result)>0) {
$node=$result[0];
$type=$node->getAttribute("type");
$src=$node->getAttribute("src");
if(strpos($type, "audio")!==false) {
$path=$src;
$pattern = '/https\:\/\/s\.elten\-net\.eu\/b\/([a-zA-Z0-9]+)\.([\_\?\=a-zA-Z0-9]+)/i';
$path = preg_replace($pattern, "/audioblogs/posts/$1", $path);
if(strpos($path, "/")===0) {
$preamble .= "\004AUDIO\004{$path}\004AUDIO\004\r\n";
$text="";
}
else
$text=$path."\r\n";
$newnode = $doc->createTextNode($text);
$node->parentNode->replaceChild($newnode, $node);
}
}
$content = utf8_decode($doc->saveHTML($doc->documentElement));
$content = wp_htmldecode(strip_tags($content));
return($preamble.$content);
}

function wp_iseltenblog($blog) {
return $blog[0]!="[" || $blog[1]!="*";
}

function wp_iswordpresscom($r) {
return strpos($r, ".wordpress.com")===(strlen($r)-strlen(".wordpress.com"));
}

function wp_htmldecode($text) {
return html_entity_decode($text, ENT_QUOTES | ENT_XML1);
}
?>