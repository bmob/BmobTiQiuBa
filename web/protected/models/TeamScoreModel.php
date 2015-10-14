<?php
class TeamScoreModel extends BaseModel
{
	public $name;
	public $bmobObj;


	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("TeamScore");
		return $this->bmobObj;
	}


	/**
	 * @desc 根据id查找球队
	 * @param $objectId
	 * @return mixed
	 */
	public function findTeamByObjectId($objectId){
		$res = $this->bmobObj->get("",array('where={"objectId":"'.$objectId.'"}'));
		return $res->results;
	}

	/**
	 * @desc 查找某支球队在某场比赛的数据
	 * @param $competition
	 * @param $team
	 * @return mixed
	 */
	public function findByCompetitionTeam($competition,$team){
		$res = $this->bmobObj->get("",array('where={"competition":"'.$competition.'","team":"'.$team.'"}'));
		return $res->results;
	}


	/**
	 * @desc 查找某个联赛中的某支球队的积分信息
	 * @param $leagueId
	 * @return mixed
	 */
	public function findTeamsByLeagueId($leagueId){
		$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}'));
		return $res->results;
	}


	/**
	 * @desc 新增一条记录
	 * @param $arr
	 * @return bool|mixed
	 */
	public function save($arr){
		foreach($arr as $k => $v){
			if($k == 'goals' || $k == 'goals_against' || $k == 'goal_difference' || $k == 'score'){
				$arr[$k] = intval($v);
			}
		}
		return $this->bmobObj->create($arr); //添加对象
	}


	/**
	 * @desc 更新一条记录
	 */
	public function update($id,$arr){
		foreach($arr as $k => $v){
			if($k == 'goals' || $k == 'goals_against' || $k == 'goal_difference' || $k == 'score'){
				$arr[$k] = intval($v);
			}
		}
		return $this->bmobObj->update($id,$arr);
	}


}


