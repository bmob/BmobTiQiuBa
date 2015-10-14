<?php
class PlayerScoreModel extends BaseModel
{

	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("PlayerScore");
		return $this->bmobObj;
	}


	/**
	 * @desc 找到某支球队在某场比赛中的进球队员
	 */
	public function findScorePlayer($gameId,$teamId){

		$res = $this->bmobObj->get("",array('where={"competition":"'.$gameId.'","team":"'.$teamId.'"}','include=player,team'));
		return $res->results;

	}

	/**
	 * @desc 找到某支球队在某场比赛中的进球队员
	 */
	public function findByLeague($leagueId,$limit=''){

		if(empty($limit)){
			$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','include=player,competition,team,league'));
		}else{
			$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','include=player,competition,team,league','limit='.$limit));
		}

		return $res->results;

	}

	/**
	 * @desc 找到某场比赛某球员的数据
	 * @param $playerId
	 * @param $gameId
	 */
	public function findCompetitionPlayerScore($playerId,$gameId,$limit=''){

		if(empty($limit)){
			$res = $this->bmobObj->get("",array('where={"competition":"'.$gameId.'","player":"'.$playerId.'"}','include=player,competition'));
		}else{
			$res = $this->bmobObj->get("",array('where={"competition":"'.$gameId.'","player":"'.$playerId.'"}','include=player,competition','limit='.$limit));
		}

		return $res->results;
	}


	/**
	 * @desc 找到某场比赛所有球员的数据
	 * @param $playerId
	 * @param $gameId
	 */
	public function findByGameId($gameId,$limit=''){

		if(empty($limit)){
			$res = $this->bmobObj->get("",array('where={"competition":"'.$gameId.'"}','include=player,competition'));
		}else{
			$res = $this->bmobObj->get("",array('where={"competition":"'.$gameId.'"}','include=player,competition','limit='.$limit));
		}

		return $res->results;
	}

	/**
	 * @desc 找到某场比赛某支球队的所有球员的数据
	 * @param $playerId
	 * @param $gameId
	 */
	public function findCompetitionTeamPlayerScore($gameId,$teamId,$limit=''){

		if(empty($limit)){
			$res = $this->bmobObj->get("",array('where={"competition":"'.$gameId.'","team":"'.$teamId.'"}','include=player,competition,team'));
		}else{
			$res = $this->bmobObj->get("",array('where={"competition":"'.$gameId.'","team":"'.$teamId.'"}','include=player,competition,team','limit='.$limit));
		}

		return $res->results;
	}

}