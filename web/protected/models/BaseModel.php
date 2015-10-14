<?php
class BaseModel extends CModel{

	public  $bmobObj;

	public function __construct(){

	}


	/**
	 * Returns the static model of the specified AR class.
	 * @return User the static model class
	 */
	public static function model($className = __CLASS__)
	{
		return new $className();
//        return parent::model($className);
	}



	public function attributeNames()
	{

	}


	/**
	 * @desc 查找某条记录
	 */
	public function findByObjectId($objectId){

		$res = $this->bmobObj->get("",array('where={"objectId":"'.$objectId.'"}','include=home_court,opponent,league'));
		return $res->results;

	}

	/**
	 * @desc 查询某条记录关联到某个表的所有数据
	 */
	public function findRowsByRelation($colName,$table,$relId){
		$res = $this->bmobObj->get("",array('where={"$relatedTo":{"object":{"__type":"Pointer","className":"'.$table.'","objectId":"'.$relId.'"},"key":"'.$colName.'"}}'));
		return $res->results;
	}

	/**
	 * @desc 更新数据
	 * @param $objectId
	 * @param $arr
	 * @return mixed
	 */
	public function update($objectId,$arr){

		$res = $this->bmobObj->update($objectId,$arr);
		return $res;

	}

	/**
	 * @desc 更新时间类型的数据
	 */
	public function updateDate($objectId,$colName,$date){

		$data = array(
			"$colName" => array(
				"__type" => "Date",
				"iso" => $date
			)
		);

		$res = $this->bmobObj->update($objectId,$data);

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