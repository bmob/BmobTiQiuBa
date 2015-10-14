<?php
class LineupModel extends BaseModel
{
	public $name;
	public $bmobObj;

	/**
	 * Declares the validation rules.
	 * The rules state that username and password are required,
	 * and password needs to be authenticated.
	 */
	public function rules()
	{
		return array(
			// username and password are required
			array('name', 'required'),

		);
	}

	/**
	 * Declares attribute labels.
	 */
	public function attributeLabels()
	{
		return array(
			'name'=>'名称',
		);
	}


	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("Lineup");
		return $this->bmobObj;
	}


	/**
	 * @desc 根据阵容id找到对应的球队
	 * @param $objectId
	 * @return mixed
	 */
	public function findLineupByObjectId($objectId){
		$res = $this->bmobObj->get("",array('where={"objectId":"'.$objectId.'"}','include=team,goalkeeper'));
		return $res->results;
	}

	/**
	 * @desc 根据球队id找到对应的球队
	 * @param $objectId
	 * @return mixed
	 */
	public function findLineupByTeamId($teamId){
		$res = $this->bmobObj->get("",array('where={"team":"'.$teamId.'"}','include=team,goalkeeper'));
		return $res->results;
	}

}


