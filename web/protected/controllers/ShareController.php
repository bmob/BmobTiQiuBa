<?php

class ShareController extends Controller
{
	public $layout = 'share';
	/**
	 * @desc 分享联赛数据
	 */
	public function actionLeagueData(){

		$leagueId = Yii::app()->request->getQuery('league', '');

		$teamModel = new TeamModel();
		//找到联赛中的球队
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		$groupModel = new GroupModel();
		$leagueStatModel = new LeagueScoreStatModel();

		$groupTeams = array();
		$groupTeamsArr = array();

		//先找到联赛中的组
		$groupRows = $groupModel->findGroupTeamsByLeague($leagueId);
		//查找联赛中球队的积分信息
		$leagueStatTeams = $leagueStatModel->findTeamByLeagueId($leagueId);

		if(isset($leagueStatTeams[0]->league->name)){
			$leagueName = $leagueStatTeams[0]->league->name;
		}else{
			$leagueName = '未知联赛';
		}

		foreach($groupRows as $group){

			$groupId = $group->objectId;
			//找到每个组的球队
			$groupRelTeams = $teamModel->findRowsByRelation("teams","Group",$groupId);
			$groupSortTeams = array();
			foreach($leagueStatTeams as $statTeam){

				foreach($groupRelTeams as $team){
					$team->groupName = $group->name;
					$team->groupObjectId = $group->objectId;
					foreach($leagueTeams as $lTeam){
						if($lTeam->objectId == $team->objectId){
							$lTeam->selected = 1;
						}
					}

					if(isset($statTeam->team->objectId)){
						if($statTeam->team->objectId == $team->objectId){
							$team->stat = $statTeam;
							array_push($groupSortTeams,$team);
						}
					}
				}

			}

			$group->relteams = $groupSortTeams;
			$groupTeamsArr = $groupRelTeams;
			array_push($groupTeams,$groupTeamsArr);

		}

		$this->render('leagueData',array('leagueTeams'=>$leagueTeams,'groupRows'=>$groupRows,"groupTeams"=>$groupTeams,'leagueName'=>$leagueName));
	}

	/**
	 * @desc 分享射手榜
	 */
	public function actionPlayerScoreData(){

		$leagueId = Yii::app()->request->getQuery('league', '');

		$playerScoreModel = new PlayerScoreModel();
		$playerData = $playerScoreModel->findByLeague($leagueId);
		if(isset($playerData[0]->league->name)){
			$leagueName = $playerData[0]->league->name;
		}else{
			$leagueName = '未知联赛';
		}

		//找到属于该联赛的所有球员
		$playerArr = array();
		foreach($playerData as $playerScore){
			$playerId = $playerScore->player->objectId;
			if(!in_array($playerId,$playerArr)){
				array_push($playerArr,$playerId);
			}
		}

		//统计球员在某个联赛的进球总数
		$playerGoalArr = array();
		foreach($playerArr as $playerId){
			$playerGoals = 0;
			foreach($playerData as $playerScore){
				if(($playerId == $playerScore->player->objectId) && isset($playerScore->goals) && is_numeric($playerScore->goals)){
					$playerGoals += $playerScore->goals;
				}
			}
			$playerGoalArr[$playerId] = $playerGoals;
		}
		arsort($playerGoalArr);
		//合并球员的一些信息
		$playerRangeArr = array();
		foreach($playerGoalArr as $playerRange => $playerGoal){
			foreach($playerData as $playerScore){
				if(($playerRange == $playerScore->player->objectId)){
					if(!isset($playerScore->player->nickname) || empty($playerScore->player->nickname)){
						$playerScore->player->nickname = '匿名';
					}
					if(!isset($playerScore->team->name) || empty($playerScore->team->name)){
						$playerScore->team->name = '匿名球队';
					}
					$playerRangeArr[$playerRange] = array(
						'totalGoals' => $playerGoal,
						'name' => $playerScore->player->nickname,
						'team' => $playerScore->team->name
					);
				}
			}
		}

		$this->render('playerScoreData',array('playerRangeArr'=>$playerRangeArr,'leagueName'=>$leagueName));
	}

	/**
	 * @desc 分享球员评分
	 */
	public function actionPlayerComment(){

		$playerId = Yii::app()->request->getQuery('player', '');
		$gameId = Yii::app()->request->getQuery('game', '');

		$playerScoreModel = new PlayerScoreModel();
		$playerScoreData = $playerScoreModel->findCompetitionPlayerScore($playerId,$gameId,1);
		$playerScore = array();
		if(isset($playerScoreData[0]) && !empty($playerScoreData[0])){
			$playerScore = $playerScoreData[0];
		}

		$commentModel = new CommentModel();
		$comments = $commentModel->findPlayerComment($playerId,$gameId);

		
		$this->render('playerComment',array('playerScore'=>$playerScore,'comments'=>$comments));
	}

	/**
	 * @desc 分享球员比赛数据
	 */
	public function actionPersonGameData(){

		$playerId = Yii::app()->request->getQuery('player', '');
		$gameId = Yii::app()->request->getQuery('game', '');

		$playerScoreModel = new PlayerScoreModel();
		$playerScoreData = $playerScoreModel->findCompetitionPlayerScore($playerId,$gameId,1);
		$playerScore = array();
		if(isset($playerScoreData[0]) && !empty($playerScoreData[0])){
			$playerScore = $playerScoreData[0];
		}

		$this->render('personGameData',array('playerScore'=>$playerScore));
	}

	/**
	 * @desc 表赛报告
	 */
	public function actionGameData(){

		$gameId = Yii::app()->request->getQuery('game', '');
		$teamId = Yii::app()->request->getQuery('team', '');

		$tournament = new TournamentModel();
	 	$gameDatas = $tournament->findByObjectId($gameId);
		$gameData = array();
		if(isset($gameDatas[0])){
			$gameData = $gameDatas[0];
		}

		$playerScoreModel = new PlayerScoreModel();
		$userModel = new UserModel();
		//$playerData = $playerScoreModel->findByLeague($leagueId);

		$teamMembers = array();
		$tempData=$gameDatas[0];
		
		$playMembers=$playerScoreModel->findScorePlayer($gameId, $teamId);
		
//		print_r($gameData  );exit("dafafdas");
		
		//$playerData = $playerScoreModel->findByGameId($teamId);
		$playerData = $playerScoreModel->findCompetitionTeamPlayerScore($gameId,$teamId);


		//找到属于该联赛的所有球员
		$playerArr = array();
		foreach($playerData as $playerScore){
			$playerId = $playerScore->player->objectId;
			if(!in_array($playerId,$playerArr)){
				array_push($playerArr,$playerId);
			}
		}

		//统计球员在某个联赛的进球总数
		$playerGoalArr = array();
		foreach($playerArr as $playerId){
			$playerGoals = 0;
			foreach($playerData as $playerScore){
				if(($playerId == $playerScore->player->objectId) && isset($playerScore->goals) && is_numeric($playerScore->goals)){
					$playerGoals += $playerScore->goals;
				}
			}
			$playerGoalArr[$playerId] = $playerGoals;
		}
		arsort($playerGoalArr);
		//合并球员的一些信息
		$playerRangeArr = array();
		foreach($playerGoalArr as $playerRange => $playerGoal){
			foreach($playerData as $playerScore){
				if(($playerRange == $playerScore->player->objectId)){
					if(!isset($playerScore->player->nickname) || empty($playerScore->player->nickname)){
						$playerScore->player->nickname = '匿名';
					}
					if(!isset($playerScore->team->name) || empty($playerScore->team->name)){
						$playerScore->team->name = '匿名球队';
					}
					$playerRangeArr[$playerRange] = array(
						'totalGoals' => $playerGoal,
						'name' => $playerScore->player->nickname,
						'team' => $playerScore->team->name
					);
				}
			}
		}

		//统计球员在某个联赛的助攻总数
		$playerAssistsArr = array();
		foreach($playerArr as $playerId){
			$playerAssists = 0;
			foreach($playerData as $playerScore){
				if(($playerId == $playerScore->player->objectId) && isset($playerScore->assists) && is_numeric($playerScore->assists)){
					$playerAssists += $playerScore->assists;
				}
			}
			$playerAssistsArr[$playerId] = $playerAssists;
		}
		arsort($playerAssistsArr);
		//合并球员的一些信息
		$playerAssistsRangeArr = array();
		foreach($playerAssistsArr as $playerRange => $playerAssists){
			foreach($playerData as $playerScore){
				if(($playerRange == $playerScore->player->objectId)){
					if(!isset($playerScore->player->nickname) || empty($playerScore->player->nickname)){
						$playerScore->player->nickname = '匿名';
					}
					if(!isset($playerScore->team->name) || empty($playerScore->team->name)){
						$playerScore->team->name = '匿名球队';
					}
					$playerAssistsRangeArr[$playerRange] = array(
						'totalAssists' => $playerAssists,
						'name' => $playerScore->player->nickname,
						'team' => $playerScore->team->name
					);
				}
			}
		}

		
		
		$this->render('gameData',array("teamId"=>$teamId, 'gameData'=>$gameData,'playMembers'=>$playMembers,'playerRangeArr'=>$playerRangeArr,'playerAssistsRangeArr'=>$playerAssistsRangeArr));

	}

	/**
	 * @desc 球队阵容
	 */
	public function actionGameLineup(){

		$teamId = Yii::app()->request->getQuery('team', '');
		$LineupModel = new LineupModel();
		$lineupData = $LineupModel->findLineupByTeamId($teamId);
		
		$teamModel = new TeamModel();
		$team = $teamModel->findTeamByObjectId($teamId);		
		if( $team ){
			$team=$team[0];
		}
		
		$backPlayers = array();
		$strikerPlayers = array();
		$forwardPlayers = array();
		$goalkeeperPlayers = array();

		if(isset($lineupData[0])){
			$lineupId = $lineupData[0]->objectId;
			$userModel = new UserModel();
			$backPlayers = $userModel->findRowsByRelation("back","Lineup",$lineupId);
			$strikerPlayers = $userModel->findRowsByRelation("striker","Lineup",$lineupId);
			$forwardPlayers = $userModel->findRowsByRelation("forward","Lineup",$lineupId);
			$goalkeeperPlayers = $lineupData[0]->goalkeeper;
		}

//		print_r($team);exit("dafasfda");

		$this->render('gameLineup',array(
			'team' => $team,
			'backPlayers' => $backPlayers,
			'strikerPlayers' => $strikerPlayers,
			'forwardPlayers' => $forwardPlayers,
			'goalkeeperPlayers' => $goalkeeperPlayers
		));
	}


	/**
	 * @desc 球员个人数据
	 */
	public function actionPersonTotalData(){

		$userId = Yii::app()->request->getQuery('user', '');
		$userData = array();
		if(!empty($userId)){
			$userModel = new UserModel();
			$userData = $userModel->getByObjectId($userId);
		}

		$this->render('userTotalData',array('userData'=>$userData));

	}

	/**
	 * @desc 球员个人数据
	 */
	public function actionPersonTotalGame(){

		$userId = Yii::app()->request->getQuery('user', '');
		$userData = array();
		if(!empty($userId)){
			$userModel = new UserModel();
			$userData = $userModel->getByObjectId($userId);
		}

		//var_dump($userData);exit;
		$this->render('userTotalGame',array('userData'=>$userData));

	}

	/**
	 * @desc 球员个人数据
	 */
	public function actionPersonTotalGoals(){

		$userId = Yii::app()->request->getQuery('user', '');
		$userData = array();
		if(!empty($userId)){
			$userModel = new UserModel();
			$userData = $userModel->getByObjectId($userId);
		}

		//var_dump($userData);exit;
		$this->render('userTotalGoals',array('userData'=>$userData));

	}

	/**
	 * @desc 球员个人数据
	 */
	public function actionPersonTotalAssists(){

		$userId = Yii::app()->request->getQuery('user', '');
		$userData = array();
		if(!empty($userId)){
			$userModel = new UserModel();
			$userData = $userModel->getByObjectId($userId);
		}

		//var_dump($userData);exit;
		$this->render('userTotalAssists',array('userData'=>$userData));

	}

	/**
	 * @desc 球员个人数据
	 */
	public function actionPersonTotalAvg(){

		$userId = Yii::app()->request->getQuery('user', '');
		$userData = array();
		if(!empty($userId)){
			$userModel = new UserModel();
			$userData = $userModel->getByObjectId($userId);
		}

		//var_dump($userData);exit;
		$this->render('userTotalAvg',array('userData'=>$userData));

	}


	/**
	 * @desc 下载界面
	 */
	public function actionDownload(){

		$this->render('downloadPage');

	}


}