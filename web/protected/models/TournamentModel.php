<?php

class TournamentModel extends BaseModel
{


	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("Tournament");
		return $this->bmobObj;
	}

	/**
	 * @desc 创建一条记录
	 * @param $arr
	 * @return bool|mixed
	 */
	public function save($arr){
		return $this->bmobObj->create($arr); //添加对象
	}

	/**
	 * @desc 创建一条包含关联关系的数据
	 */
	public function saveRow($arr){
		foreach($arr as $k => $v){
			if($k == 'name'){
				$arr[$k] = (String)$v;
			}elseif($k == 'home_court'){
				$homeCourtId = $v["homecourtid"];
				$arr[$k] = array(
					"__type" => "Pointer",
					"className" => "Team",
					"objectId" => "$homeCourtId"
				);
			}elseif($k == 'opponent'){
				$opponentId = $v["opponentid"];
				$arr[$k] = array(
					"__type" => "Pointer",
					"className" => "Team",
					"objectId" => "$opponentId"
				);
			}elseif($k == 'league'){
				$leagueId = $v["leagueid"];
				$arr[$k] = array(
					"__type" => "Pointer",
					"className" => "Team",
					"objectId" => "$leagueId"
				);
			}elseif($k == 'group'){
				$groupId = $v["groupid"];
				$arr[$k] = array(
					"__type" => "Pointer",
					"className" => "Team",
					"objectId" => "$groupId"
				);
			}
		}

		return $this->bmobObj->create($arr); //添加对象
	}

	/**
	 * @desc 批量生成赛程
	 * @param $saveBatchArr
	 * @return bool|mixed
	 */
	public function saveBatch($saveBatchArr){

		$saveDataArr = array();
		$saveArrSend = array();
		foreach($saveBatchArr as $arr){
			$arrSend = array();
			foreach($arr as $k => $v){

				if($k == 'name'){
					$arr[$k] = (String)$v;
				}elseif($k == 'home_court'){
					$homeCourtId = $v["homecourtid"];
					$arr[$k] = array(
						"__type" => "Pointer",
						"className" => "Team",
						"objectId" => "$homeCourtId"
					);
				}elseif($k == 'opponent'){
					$opponentId = $v["opponentid"];
					$arr[$k] = array(
						"__type" => "Pointer",
						"className" => "Team",
						"objectId" => "$opponentId"
					);
				}elseif($k == 'league'){
					$leagueId = $v["leagueid"];
					$arr[$k] = array(
						"__type" => "Pointer",
						"className" => "Team",
						"objectId" => "$leagueId"
					);
				}elseif($k == 'group'){
					$groupId = $v["groupid"];
					$arr[$k] = array(
						"__type" => "Pointer",
						"className" => "Team",
						"objectId" => "$groupId"
					);
				}

			}

			$arrSend['method'] = "POST";
			$arrSend['path'] = "/1/classes/Tournament";
			$arrSend['body'] = $arr;
			array_push($saveArrSend,$arrSend);
		}

		$batchArr = array(
			'requests' => $saveArrSend
		);

//		var_dump($batchArr);exit;

		return $this->bmobObj->createBatch($batchArr); //添加对象
	}

	/**
	 * @desc 更新赛程
	 */
	public function updateSchedule($objectId,$eventDate,$startTime,$site){

		$data = array(

			"event_date" => array(
				"__type" => "Date",
				"iso" => $eventDate
			),

			"start_time" => array(
				"__type" => "Date",
				"iso" => $startTime
			),

			"site" => $site

		);

		$res = $this->bmobObj->update($objectId,$data);

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
			),
		);

		$res = $this->bmobObj->update($objectId,$data);

		return $res;

	}

	/**
	 * @desc 更新比赛比分
	 */
	public function updateScore($objectId,$homeTeamScore,$opponentTeamScore){

		$data = array(
			"score_h" => $homeTeamScore,
			"score_o2" => $homeTeamScore,
			"score_o" => $opponentTeamScore,
			"score_h2" => $opponentTeamScore,
			"isVerify" => true
		);

		$res = $this->bmobObj->update($objectId,$data);

		return $res;

	}



	/**
	 * @desc 查找属于该联赛的所有比赛
	 */
	public function findByLeague($leagueId,$limit = ''){

		if(!empty($limit)){
			$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','limit='.$limit,'order=start_time'));
		}else{
			$res = $this->bmobObj->get("",array('where={"league":"'.$leagueId.'"}','include=home_court,opponent','order=start_time'));
		}
		return $res->results;
	}

	/**
	 * @desc 查找某条记录
	 */
	public function findLeagueTeam($gameId,$leagueId){

		$res = $this->bmobObj->get("",array('where={"objectId":"'.$gameId.'","league":"'.$leagueId.'"}'));
		return $res->results;

	}


}