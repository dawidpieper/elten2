<?php
function elten_sc_blogslist($atts) {
global $paged;
if(!isset($paged) || $paged==0) $paged=1;
$sites = get_sites(array('number'=>1000000));
$sitescount = count($sites);
$perpage=20;
$arr=array();
foreach($sites as $site) {
$o=array('id'=>$site->blog_id, 'domain'=>$site->domain, 'path'=>$site->path);
$users = get_users_of_blog($site->blog_id);
$o['users'] = array();
foreach($users as $user) {
$u=array('id'=>$user->user_id, 'user'=>$user->user_login, 'name'=>$user->display_name, 'elten'=>get_user_meta($user->user_id, "elten_user", true));
array_push($o['users'], $u);
}
switch_to_blog($site->blog_id);
$o['name']=get_bloginfo("name");
$o['description']=get_bloginfo("description");
$o['url']=get_bloginfo("url");
$w=wp_count_posts();
$o['cnt_posts']=$w->private+$w->publish;
$o['cnt_comments']=wp_count_comments()->all;
$o['lastpost'] = get_lastpostdate("gmt");
restore_current_blog();
if($o['id']>1 && $o['cnt_posts']>0 && $o['lastpost']!=null)
array_push($arr, $o);
}
usort($arr, function ($a, $b) {
return (strtotime($b['lastpost']."+0000") <=> strtotime($a['lastpost']."+0000"));
});


$locale = get_locale();
$str_header="Recently updated blogs";
$str_blogname="Blog name";
$str_lastupdate = "Last update";
$str_postscount = "Posts count";
$str_commentscount = "Comments count";
if($locale=='pl_PL') {
$str_header="Ostatnio aktualizowane blogi";
$str_blogname="Nazwa bloga";
$str_lastupdate = "Ostatnia aktualizacja";
$str_postscount = "Liczba wpisów";
$str_commentscount = "Liczba komentarzy";
}

$t= '
<h1>'.$str_header.'</h1>
<table class="widefat fixed" cellspacing="0">
<thead>
<tr>
<th id="columnname" class="manage-column column-columnname" scope="col">'.$str_blogname.'</th>
<th id="columnname" class="manage-column column-columnname" scope="col">'.$str_lastupdate.'</th>
            <th id="columnname" class="manage-column column-columnname num" scope="col">'.$str_postscount.'</th>
            <th id="columnname" class="manage-column column-columnname num" scope="col">'.$str_commentscount.'</th>
</tr>
</thead>
<tbody>
';
$i=0;
foreach($arr as $a) {
++$i;
if($i<=($paged-1)*$perpage) continue;
if($i>($paged)*$perpage) continue;
$t.= '
<tr class="alternate">
<th class="check-column" scope="row">
<a href="https://'.$a['domain'].$a['path'].'">'.$a['name'].'</a>
</th>

<td class="column-columnname">
'.$a['lastpost'].'
</td>

<td class="column-columnname">
'.$a['cnt_posts'].'
</td>

<td class="column-columnname">
'.$a['cnt_comments'].'
</td>
</tr>
';
}
$t.= '
</tbody>
</table>
';

$pages = $sitescount/$perpage;

$t.= paginate_links( array(
'total' => $pages
) );

return $t;
}
add_shortcode('eltenblogslist', 'elten_sc_blogslist' );
?>