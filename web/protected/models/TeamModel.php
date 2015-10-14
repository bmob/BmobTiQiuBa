<?php
class TeamModel extends BaseModel
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
		$this->bmobObj = new BmobObject("Team");
		return $this->bmobObj;
	}


	/**
	 * @desc 根据球队id找到对应的球队
	 * @param $objectId
	 * @return mixed
	 */
	public function findTeamByObjectId($objectId){
		$res = $this->bmobObj->get("",array('where={"objectId":"'.$objectId.'"}','include=captain'));
		return $res->results;
	}

	/**
	 * @desc 找到队长所管理的球队
	 */
	public function findTeamsByCaptain($captainId){
		$res = $this->bmobObj->get("",array('where={"captain":"'.$captainId.'"}'));
		return $res->results;
	}


	/**
	 * @desc 模糊查询名字包含查询关键字的球队
	 */
	public function findTeamsByName($name){

		$res = $this->bmobObj->get("",array('where={"name":{"$regex":"'.$name.'"}}','limit=10'));

		$userModel = new BmobUser();
		foreach($res->results as $team){
			try{
				$capt = $userModel->get($team->captain->objectId);
				//找到队长的名字
				if(isset($capt) && !empty($capt)){
					if(empty($capt->nickname)){
						$team->captName = '匿名';
					}else{
						$team->captName = $capt->nickname;
					}
				}
			}catch(Exception $e){

			}

		}

		return $res->results;
	}

	/**
	 * @desc 查找某几支球队
	 */
	public function findServeralTeams($cityCode,$limit){

		$res = $this->bmobObj->get("",array('where={"city":"'.$cityCode.'"}','limit='.$limit,'include=captain'));
		return $res->results;

	}

	/**
	 * @desc 查找联赛球队
	 */
	public function findLeagueTeams($leagueTable,$leagueId){

		$leagueTeams = $this->findRowsByRelation('teams',$leagueTable,$leagueId);
		$regLeagueTeams = $this->findRowsByRelation('regTeams',$leagueTable,$leagueId);

		foreach($leagueTeams as &$leagueTeam){
			$leagueTeam->isRegister = false;
			foreach($regLeagueTeams as $regLeagueTeam){
				if($leagueTeam->name == $regLeagueTeam->name){
					$leagueTeam->isRegister = true;
				}
			}
		}

		return $leagueTeams;
	}

	/**
	 * 查找联赛中所有成员的成员，结果是个对象数组
	 * @param unknown_type $leagueId
	 */
	public function findMembers( $leagueId ){
		
		$teamModel = new TeamModel();
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);
		
		if( $leagueTeams  && count($leagueTeams)==2 ){
			$team1=$leagueTeams[0];
			$team2=$leagueTeams[1];
			
			$userModel=new UserModel();
		 	$res=$userModel->getUserByTeam( $team1->objectId, $team2->objectId );
		 	if( $res ){
		 		return $res;
		 	}
		}
		
		return array();
	}

}


