<?php

class GroupModel extends BaseModel
{
	public $bmobObj;

	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("Group");
		return $this->bmobObj;
	}

	/**
	 * @dese 查找某联赛的所有分组
	 */
	public function findByLeagueId($leagueId,$limit = ''){
		if($limit){
			$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','order=name','limit='.$limit));
		}else{
			$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','order=name'));
		}
		return $res->results;
	}

	/**
	 * @desc 查找某联赛中某个分组
	 */
	public function findLeagueGroupByName($leagueId,$name){
		$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'","name":"'.$name.'"}'));
		return $res->results;
	}


	/**
	 * @desc 查找小组中的球队信息
	 */
	public function findGroupTeamsByLeague($leagueId){

		$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','include=teams','order=name'));
		return $res->results;
	}

	/**
	 * @desc 创建一条记录
	 * @param $arr
	 * @return bool|mixed
	 */
	public function save($arr){
		foreach($arr as $k => $v){
			if($k == 'name'){
				$arr[$k] = (String)$v;
			}

			if($k == 'league'){
			//	$table = $v["table"];
				$leagueId = $v["reltoleagueid"];
				$arr[$k] = array(
						"__type" => "Pointer",
						"className" => "Team",
						"objectId" => "$leagueId"
					);
				//var_dump($arr);exit;
			}
		}

		return $this->bmobObj->create($arr); //添加对象
	}

	/**
	 * @desc 批量创建记录
	 */
	public function saveBatch($arrBatch){
		$arrEdit = array();
		foreach($arrBatch as $arr){
			foreach($arr as $k => $v){
				if($k == 'name'){
					$arr[$k] = (String)$v;
				}

				if($k == 'league'){
					//	$table = $v["table"];
					$leagueId = $v["reltoleagueid"];
					$arr[$k] = array(
						"__type" => "Pointer",
						"className" => "Team",
						"objectId" => "$leagueId"
					);
					//var_dump($arr);exit;
				}
			}

			$newArr = array(
				"method" => "POST",
            	"path" => "/1/classes/Group",
				"body" => $arr
			);

			array_push($arrEdit,$newArr);
		}

		$saveArr = array(
			"requests" => $arrEdit
		);

		return $this->bmobObj->createBatch($saveArr);

	}

	/**
	 * @desc 更新某条数据
	 */
	public function update($objectId,$arr){
		foreach($arr as $k => $v){
			if($k == 'name'){
				$arr[$k] = (String)$v;
			}
		}
		$res = $this->bmobObj->update("$objectId", $arr);
		return $res;

	}


	/**
	 * @desc 添加一条关联数据
	 */
	public function createRelation($colName,$table,$relId,$relToId){

		$defaultType = array("__type"=>"Pointer","className"=>"$table","objectId"=>"$relToId");

		//$dataJson = json_encode($defaultType);

		$data = array(
			"$colName" => array(
				"__op"=>"AddRelation",
				"objects"=>array($defaultType)
				//"objects"=>'[{"__type":"Pointer","className":"'.$table.'","objectId":"'.$teamid.'"}]'
			)
		);

		$res = $this->bmobObj->update($relId,$data);

		return $res;

	}

	/**
	 * @desc 一次创建多条关联数据
	 */
	public function createRelationBatch($colName,$relationArr,$relId){

		$saveArr = array();
		foreach($relationArr as $arr){
			$tempArr = array("__type"=>"Pointer","className"=>$arr['table'],"objectId"=>$arr['reltoid']);
			array_push($saveArr,$tempArr);
		}

		//$defaultType = array("__type"=>"Pointer","className"=>"$table","objectId"=>"$relToId");

		//$dataJson = json_encode($defaultType);

		$data = array(
			"$colName" => array(
				"__op"=>"AddRelation",
				"objects"=>$saveArr
				//"objects"=>'[{"__type":"Pointer","className":"'.$table.'","objectId":"'.$teamid.'"}]'
			)
		);

		$res = $this->bmobObj->update($relId,$data);

		return $res;

	}

	/**
	 * @desc 删除一条关联数据
	 */
	public function removeRelation($colName,$table,$relId,$relToId){

		$defaultType = array("__type"=>"Pointer","className"=>"$table","objectId"=>"$relToId");

		//$dataJson = json_encode($defaultType);
		$data = array(
			"$colName" => array(
				"__op"=>"RemoveRelation",
				"objects"=>array($defaultType)
			)
		);

		$res = $this->bmobObj->update($relId,$data);

		return $res;

	}

	/**
	 * @desc 创建某个数据列的指针对象
	 * @param $colName
	 * @param $table
	 * @param $relId
	 * @param $relToId
	 * @return bool|mixed
	 */
	public function createPointer($colName,$table,$relId,$relToId){

	//	$defaultType = {"game":{"__type":"Pointer","className":"Game","objectId":"DdUOIIIW"}};

		$data = array(
			"$colName" => array(
				"__type" => "Pointer",
				"className" => "$table",
				"objectId" => "$relToId"
			)
		);

		$res = $this->bmobObj->update($relId,$data);

		return $res;

	}

}