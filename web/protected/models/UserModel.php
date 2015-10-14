<?php

class UserModel extends BaseModel
{
	public $bmobObj;

	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobUser();
		return $this->bmobObj;
	}


	/**
	 * @desc 根据用户名查找用户信息
	 * @param $username
	 * @return mixed
	 */
	public function getUserByUsername($username){
		$res = $this->bmobObj->getByCondition(array('where={"username":"'.$username.'"}'));
		return $res->results;
	}

	/**
	 * @desc 根据用户id查找用户信息
	 * @param $objectId
	 * @return mixed
	 */
	public function getByObjectId($objectId){
		$res = $this->bmobObj->get($objectId);
		return $res;
	}

	/**
	 * @desc 查询某条记录关联到某个表的所有数据
	 */
	public function findRowsByRelation($colName,$table,$relId){
		$res = $this->bmobObj->getByCondition(array('where={"$relatedTo":{"object":{"__type":"Pointer","className":"'.$table.'","objectId":"'.$relId.'"},"key":"'.$colName.'"}}'));
		return $res->results;
	}

	/**
	 * @desc 获取参数两只球队的所有的成员信息
	 */
	public function getUserByTeam($teamId1, $teamId2) {
		$res = $this->bmobObj->getByCondition(array('where={"$or":[{"$relatedTo":{"object":{"__type":"Pointer","className":"Team","objectId":"'.$teamId1.'"},"key":"footballer"}},{"$relatedTo":{"object":{"__type":"Pointer","className":"Team","objectId":"'.$teamId2.'"},"key":"footballer"}}]}'));
		return $res->results;		
	}
	
	/**
	 * @desc 获取参数两只球队的所有的成员信息
	 */
	public function getTeamMember($teamId) {
		$res = $this->bmobObj->getByCondition(array('where={"$relatedTo":{"object":{"__type":"Pointer","className":"Team","objectId":"'.$teamId.'"},"key":"footballer"}}'));
		return $res->results;		
	}	

}