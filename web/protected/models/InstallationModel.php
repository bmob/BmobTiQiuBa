<?php

class InstallationModel extends BaseModel
{
	public $bmobObj;

	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("_Installation");
		return $this->bmobObj;
	}

	/**
	 * @dese 查找某个用户的设备信息
	 */
	public function findByUid($uid){

		$res = $this->bmobObj->get("",array('where={"uid":"'.$uid.'"}'));
		return $res->results;

	}

}