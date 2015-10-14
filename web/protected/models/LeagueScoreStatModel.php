<?php
class LeagueScoreStatModel extends BaseModel
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
		$this->bmobObj = new BmobObject("LeagueScoreStat");
		return $this->bmobObj;
	}


	public function findTeamByObjectId($objectId){
		$res = $this->bmobObj->get("",array('where={"objectId":"'.$objectId.'"}'));
		return $res->results;
	}

	/**
	 * @desc 查找联赛中的球队的一些统计信息
	 * @param $leagueId
	 * @return mixed
	 */
	public function findTeamByLeagueId($leagueId){
		$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','include=league','order=-points,-goalDifference,-goals'));
		return $res->results;
	}


	/**
	 * @desc 模糊查询名字包含查询关键字的球队
	 */
	public function findTeamsByName($name){

		$res = $this->bmobObj->get("",array('where={"name":{"$regex":"'.$name.'"}}','limit=10'));

		$userModel = new BmobUser();
		foreach($res->results as $team){
			$capt = $userModel->get($team->captain->objectId);
			//找到队长的名字
			if(empty($capt->nickname)){
				$team->captName = '匿名';
			}else{
				$team->captName = $capt->nickname;
			}
		}

		return $res->results;
	}

	/**
	 * @desc 查找某几支球队
	 */
	public function findServeralTeams($limit){

		$res = $this->bmobObj->get("",array('limit='.$limit,'include=captain'));
		return $res->results;

	}



}


