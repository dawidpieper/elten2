<?php
class mysqli_db
	{
	public function __construct($host, $user, $password, $dbname)
		{
		IF(!$this->mysqli = new mysqli($host, $user, $password))
			{
			$this->error = true;
			throw new Exception("-1\r\nMySQL Connection Error - ".$this->mysqli->error, $this->mysqli->errno);
			}
		IF(!$this->mysqli->select_db($dbname))
			{
			$this->error = true;
			throw new Exception("-1\r\nMySQL Selection Error - ".$this->mysqli->error, $this->mysqli->errno);
			}
		$this->mysqli->autocommit(false);
		$this->mysqli->query('SET AUTOCOMMIT = 0');
		$this->mysqli->query('BEGIN');
		}
	public function query($query)
		{
		IF(!ereg('SELECT', $query) and !$this->error)
			{
			IF(!$result = $this->mysqli->query($query))
				{
				$this->error = true;
				throw new Exception("-1\r\nQuery - (".$query.') - '.$this->mysqli->error, $this->mysqli->errno);
				}
			else
				{
				return true;
				}
			}
		}
	public function query_select($query)
		{
		IF(!$this->error)
			{
			IF(!$result = $this->mysqli->query($query))
				{
				$this->error = true;
				throw new Exception("-1\r\nSelect Query - (".$query.') - '.$this->mysqli->error, $this->mysqli->errno);
				}
			while($row = $result->fetch_assoc())
				{
				$return[] = $row;
				}
			unset($result);
			unset($row);
			return $return;
			}
		}
	public function insert_id()
		{
		return $this->mysqli->insert_id;
		}
	public function escape($string)
		{
		return  $this->mysqli->real_escape_string($string);
		}
	public function __destruct()
		{
		IF(!$this->error)
			{
			$this->mysqli->query('COMMIT');
			}
		else
			{
			$this->mysqli->query('ROLLBACK');
			}
		unset($this->mysqli);
		unset($this->error);
		}
	}
$ms = new mysqli_db('localhost', 'dbuser', 'dbpass', 'dbname');
$cdate = time();
function mquery($query) {
return $ms->query($query);
}
function buffer_get($bufid) {
$ret='';
$q=$ms->query_select("SELECT `id`, `data`, `owner` FROM `buffers`");
foreach($q as $r) {
if($r['id'] == $bufid and $r['owner'] == $_GET['name'])
$ret = $r['data'];
}
if($ret == null) {
echo "-1";
die;
}
$ret = str_replace("\\","\\\\",$ret);
$ret = str_replace("'","\\'",$ret);
return $ret;
}
function getprivileges($searchname) {
$q = $ms->query_select("SELECT `name`, `tester`, `moderator`, `media_administrator`, `translator`, `developer` from `privileges`");
$suc = false;
foreach($q as $r){
if($r['name'] == $searchname) {
$suc = true;
$name = $r['name'];
$tester = $r['tester'];
$moderator = $r['moderator'];
$media_administrator = $r['media_administrator'];
$translator = $r['translator'];
$developer = $r['developer'];
}
}
if($suc == false) {
return([0,0,0,0,0]);
}
return([$tester,$moderator,$media_administrator,$translator,$developer]);
}
function random_str($length, $keyspace = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
{
    $str = '';
    $max = mb_strlen($keyspace, '8bit') - 1;
    for ($i = 0; $i < $length; ++$i) {
        $str .= $keyspace[random_int(0, $max)];
    }
    return $str;
}
$q=$ms->query_select("SELECT `token`, `name`, `time` FROM `tokens`");
$error = -1;
$suc = false;
foreach($q as $r){
if($r['token'] == $_GET['token'])
if($r['name'] == $_GET['name']) {
if($r['time'] == date("dmY")) {
$error = "0";
$suc = true;
}
else {
$error = -2;
if($r['time'] == date("dmY",time()-86400)) {
mquery("UPDATE `tokens` SET `time`='".date("dmY")."' WHERE `token`='".$_GET['token']."'");
$error = 0;
$suc = true;
}
}
}
else
$error = -2;
else
$error = -2;
}
if($suc == false) {
echo $error;
die;
}
?>