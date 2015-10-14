<?php

class ManageController extends Controller
{

	/**
	 * @desc 基本信息
	 */
	public function actionLeagueManage(){

		$masterId = CommonFunction::getUserId();

		if(empty($masterId)){
			throw new CHttpException(500, '你无权限查看联赛列表');
		}

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueVal = Yii::app()->request->getPost('LeagueModel');
		$result = '';
		if(!empty($leagueVal)){
			$objectId = $leagueVal['leagueid'];
			unset($leagueVal['leagueid']);
			$res = $leagueModel->update($objectId,$leagueVal);
			if(isset($res->updatedAt)){
				$result = 'success';
			}else{
				$result = $res;
			}
		}

		$res = $leagueModel->findByMaster($masterId,1);
		$this->render('leagueManage',array('model'=>$leagueModel,'leagueList'=>$res[0],'result'=>$result));
	}

	/**
	 * @desc 赛程管理
	 */
	public function actionSchedule(){

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueId = $res[0]->objectId;
		
		//根据是否有淘汰赛决定是否显示"新增比赛"按钮
		if( property_exists($res[0], "knockout") ){
			if( $res[0]->knockout ) {
				$isKnockout=true;
			}else{
				$isKnockout=false;
			}
		}else{
			$isKnockout=false;
		}

		$teamModel = new TeamModel();
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		$groupModel = new GroupModel();
		$tournamentModel = new TournamentModel();
		$teamModel = new TeamModel();

		//先找到联赛中的组
		$groupRows = $groupModel->findByLeagueId($leagueId);

		//var_dump($gruopRows);exit;
		$groupTeams = array();
		$groupTeamsArr = array();

		if(!empty($groupRows)){

			foreach($groupRows as $group){
				$groupId = $group->objectId;
				$groupRelTeams = $teamModel->findRowsByRelation("teams","Group",$groupId);
				foreach($groupRelTeams as $team){
					$team->groupName = $group->name;
					$team->groupObjectId = $group->objectId;
					foreach($leagueTeams as $lTeam){
						if($lTeam->objectId == $team->objectId){
							$lTeam->selected = 1;
						}
					}
				}

				//var_dump($game);
				$groupTeamsArr = $groupRelTeams;
				array_push($groupTeams,$groupTeamsArr);
			}

		}

		$games = array();
		$games = $tournamentModel->findByLeague($leagueId);

//var_dump($games);exit;
		$this->render('schedule',array('isKnockout'=>$isKnockout, 'leagueTeams'=>$leagueTeams,'groupTeams'=>$groupTeams,'games'=>$games));

	}

	/**
	 * @desc 赛程管理
	 *
	 */
	public function actionEditSchedule(){

		$masterId = CommonFunction::getUserId();

		$leagueId =  Yii::app()->request->getPost('leagueId');
		$teamId =  Yii::app()->request->getPost('teamId');

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueId = $res[0]->objectId;
		$teamModel = new TeamModel();
		$tournamentModel = new TournamentModel();
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		$games = array();
		$games = $tournamentModel->findByLeague($leagueId);

		$this->render('editSchedule',array('leagueTeams'=>$leagueTeams,'games'=>$games));

	}


	/**
	 * @desc 分组管理
	 */
	public function actionGrouping(){

		$masterId = CommonFunction::getUserId();

		$teamGroup =  Yii::app()->request->getPost('TeamGroup');
		if(isset($teamGroup['GroupId'])){
			$hasTeamGroupId = $teamGroup['GroupId'];
			unset($teamGroup['GroupId']);
		}

		//var_dump($hasTeamGroupId);exit;
		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueId = $res[0]->objectId;
		$doubleLoop = $res[0]->double_loop;
		if(isset($res[0]->city) && isset($res[0]->playground)){
			$leagueCity = $res[0]->city;
		}else{
			$this->redirect(array('/manage/leagueManage','errMsg'=>'请先完善联赛信息'));
		}

		if(isset($res[0]->grouped) && $res[0]->grouped == true){
			Helper::flash('error', "分组完成后，无法再进行分组！", '/site/');
		}

		$groupModel = new GroupModel();
		$teamModel = new TeamModel();
		$TournamentModel = new TournamentModel();

		if(!empty($teamGroup)){

			$arr = array();
			$leagueTeamIds = array();

			foreach($teamGroup as $groupName => $teams){

				$arr = array(
					'name' => $groupName,
					'league' => array(
						"reltoleagueid" => $leagueId
					)
				);

				$existGroup = $groupModel->findLeagueGroupByName($leagueId,$groupName);

// 				如果已存在此分组，则更新分组数据，否则新增数据
				if(!empty($existGroup)){
					throw new CHttpException(500, '分组确认后无法修改！');
				}else{
					$reponse = $groupModel->save($arr);
					$groupId = $reponse->objectId;
				}

				//关联分组对应的球队
				$saveGroupTeams = array();
				$relArr = array();
				foreach($teams as $teamId){
					$relArr = array(
						'table' => 'Team',
						'reltoid' => $teamId
					);
					array_push($saveGroupTeams,$relArr);
				}

				$groupModel->createRelationBatch('teams',$saveGroupTeams,$groupId);

			}

		}

		//找到联赛中的球队
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);
		$leagueTeamIds = array();
		//取得联赛的球队id
		foreach($leagueTeams as $lTeam){
			array_push($leagueTeamIds,$lTeam->objectId);
		}

		if(isset($res[0]->name) && !empty($res[0]->name)){
			$leagueName = $res[0]->name;
		}else{
			$leagueName = '未知联赛';
		}

		$arr = array(
			'msg' => $leagueName.'更新了联赛赛程',
			'status' => 0,
			'pushType' => 1,
			'leagueName' => $leagueName,
			'teams' => $leagueTeamIds
		);

		$leaguePushMsgModel = new LeaguePushMsgModel();
		$leaguePushMsgModel->save($arr);

		//先找到联赛中的组
		$groupRows = $groupModel->findByLeagueId($leagueId);

		$groupTeams = array();
		$groupTeamsArr = array();

		foreach($groupRows as $group){
			$groupId = $group->objectId;
			//找到某个小组的球队
			$groupRelTeams = $teamModel->findRowsByRelation("teams","Group",$groupId);

			foreach($groupRelTeams as $team){
				$team->groupName = $group->name;
				$team->groupObjectId = $group->objectId;
				foreach($leagueTeams as $lTeam){
					if($lTeam->objectId == $team->objectId){
						$lTeam->selected = 1;
					}
				}
			}

			if(!empty($teamGroup)){

				$teamCount  = count($groupRelTeams);

				//循环创建联赛赛事
				if($teamCount > 1){
					$dataBatch = array();
					for($i = 0; $i < $teamCount; $i++){
						for($j = $i + 1; $j < $teamCount; $j++){
							$homeCourtId =  $groupRelTeams[$i]->objectId;
							$opponentId = $groupRelTeams[$j]->objectId;
							$data = array(
								'name' => $groupRelTeams[$i]->name." - ".$groupRelTeams[$j]->name,
								'city' => $leagueCity,
								'nature' => Yii::app()->params['NatureGroupMatch'],
								'home_court' => array('homecourtid' => $homeCourtId),
								'opponent' => array('opponentid' => $opponentId),
								'league' => array('leagueid' => $leagueId),
								'group' => array('groupid' => $groupId),
							);
							array_push($dataBatch,$data);
//							$TournamentRow = $TournamentModel->saveRow($data);
//							$TournamentId = $TournamentRow->objectId;
//							//关联到赛事的球队
//							$TournamentModel->createPointer('home_court','Team',$TournamentId,$homeCourtId);
//							$TournamentModel->createPointer('opponent','Team',$TournamentId,$opponentId);
//							//关联到赛事所在联赛
//							$TournamentModel->createPointer('league','League',$TournamentId,$leagueId);
//							//关联到赛事所在小组
//							$TournamentModel->createPointer('group','Group',$TournamentId,$groupId);
						}
					}

					//双循环（此处增加一个循环）
					if($res[0]->double_loop){

						for($i = 0; $i < $teamCount; $i++){
							for($j = $i + 1; $j < $teamCount; $j++){
								$homeCourtId =  $groupRelTeams[$j]->objectId;
								$opponentId = $groupRelTeams[$i]->objectId;
								$data = array(
									'name' => $groupRelTeams[$j]->name." - ".$groupRelTeams[$i]->name,
									'city' => $leagueCity,
									'nature' => Yii::app()->params['NatureGroupMatch'],
									'home_court' => array('homecourtid' => $homeCourtId),
									'opponent' => array('opponentid' => $opponentId),
									'league' => array('leagueid' => $leagueId),
									'group' => array('groupid' => $groupId),
								);
								array_push($dataBatch,$data);
							}
						}

					}

					$TournamentRow = $TournamentModel->saveBatch($dataBatch);
				}

			}

			$groupTeamsArr = $groupRelTeams;
			array_push($groupTeams,$groupTeamsArr);
		}

		if(!empty($teamGroup)){
			
			//更新赛程发送推送
			$baiduPushModel=new BaiduPushModel();
			$baiduPushModel->sendMessageForAllLeague( 4, 20, $leagueId, "更新了赛程");	
			
			//将联赛标定为已分组
			$upadteGrouped = $leagueModel->update($leagueId,array('grouped'=>true));
			$this->redirect('/manage/schedule');
		}

		$this->render('grouping',array('leagueTeams'=>$leagueTeams,'leagueMsg'=>$res[0],'groupTeams'=>$groupTeams));

	}

	/**
	 * @desc 数据统计
	 */
	public function actionTongji(){

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);
		$leagueId = $res[0]->objectId;
		$teamModel = new TeamModel();
		//找到联赛中的球队
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		$groupModel = new GroupModel();
		$teamScoreModel = new TeamScoreModel();
		$leagueStatModel = new LeagueScoreStatModel();


		$groupTeams = array();
		$groupTeamsArr = array();

		//先找到联赛中的组
		$groupRows = $groupModel->findGroupTeamsByLeague($leagueId);
		//查找联赛中球队的积分信息
		$leagueStatTeams = $leagueStatModel->findTeamByLeagueId($leagueId);
//		var_dump($leagueStatTeams);exit;

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

		$playerScoreModel = new PlayerScoreModel();
		$playerData = $playerScoreModel->findByLeague($leagueId);
		$playerArr = array();
		foreach($playerData as $playerScore){
			$playerId = $playerScore->player->objectId;
			if(!in_array($playerId,$playerArr)){
				array_push($playerArr,$playerId);
			}
		}

		$playerGoalArr = array();
		foreach($playerArr as $playerId){
			$playerGoals = 0;
			foreach($playerData as $playerScore){
				if(($playerId == $playerScore->player->objectId) && isset($playerScore->goals) && is_numeric($playerScore->goals)){
					//统计球员的总进球数
					$playerGoals += $playerScore->goals;
				}
			}
			$playerGoalArr[$playerId] = $playerGoals;
		}
		arsort($playerGoalArr);
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
//		var_dump($playerArr);var_dump($playerGoalArr);var_dump($playerRangeArr);exit;
		$this->render('tongji',array('leagueTeams'=>$leagueTeams,'groupRows'=>$groupRows,"groupTeams"=>$groupTeams,'playerRangeArr'=>$playerRangeArr,'leagueId'=>$leagueId));

	}

	//添加淘汰赛的页面
	public function actionAddManage(){

		$masterId = CommonFunction::getUserId();

		$teamGroup =  Yii::app()->request->getPost('TeamGroup');

		//var_dump($hasTeamGroupId);exit;
		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueId = $res[0]->objectId;
		$leagueGrounds = $res[0]->playground;
		
		$teamModel = new TeamModel();
		$tournamentModel = new TournamentModel();
		$groupModel = new GroupModel();

		if(isset($res[0]->city) && isset($res[0]->playground)){
			$leagueCity = $res[0]->city;
		}else{
			$this->redirect(array('/manage/leagueManage','errMsg'=>'请先完善联赛信息'));
		}

		//找到联赛中的球队
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		if(isset($res[0]->name) && !empty($res[0]->name)){
			$leagueName = $res[0]->name;
		}else{
			$leagueName = '未知联赛';
		}
//		print_r($leagueTeams);exit("dafasfdasdf");
		$this->render('addManage',array('leagueTeams'=>$leagueTeams,'leagueId'=>$leagueId, "leagueGrounds"=>$leagueGrounds));
		
		
	}	
	
	//添加淘汰赛
	public function actionAddManageSchedule(){
	
		if (!Yii::app()->request->isAjaxRequest){
			throw new CHttpException(500, '此方法只允许ajax调用');
		}

		$masterId = CommonFunction::getUserId();

		$gameDate =  Yii::app()->request->getPost('game_date');
		$gameTime =  Yii::app()->request->getPost('game_time');
		$gameAddress =  Yii::app()->request->getPost('game_address');
		$leagueId = Yii::app()->request->getPost('leagueId');
		$courtId =  Yii::app()->request->getPost('home_court_id');
		$courtName =  Yii::app()->request->getPost('home_court_name');
		$opponentId =  Yii::app()->request->getPost('opponent_id');
		$opponentName = Yii::app()->request->getPost('opponent_name');		
		
		if(empty($leagueId) || empty($gameDate) || empty($gameTime) || empty($gameAddress)){
			
			CommonFunction::ajaxResult(State::$SYS_PARAM_ERROR_CODE, State::$SYS_PARAM_ERROR_MSG );
		}
		
		$leagueModel = new LeagueModel();
		$res = $leagueModel->findByMaster($masterId,1);
		if(empty($res)){
			throw new CHttpException(500, '该用户无权限管理联赛');
		}
		$leagueId = $res[0]->objectId;
		$leagueName = $res[0]->name;
		$TournamentModel = new TournamentModel();

		$gameDateTime = $gameDate.' '.$gameTime.':00';
		$dataBatch = array();
		$data = array(
										'name' => $courtName." - ".$opponentName,
										'city' => $res[0]->city,
										'nature' => 2,
										'home_court' => array('homecourtid' => $courtId),
										'opponent' => array('opponentid' => $opponentId),
										'league' => array('leagueid' => $leagueId),
										"event_date" => array(
										"__type" => "Date",
											"iso" => $gameDateTime
										),
										"start_time" => array(
											"__type" => "Date",
											"iso" => $gameDateTime
										),
										"site" => $gameAddress
		
									);
									
		array_push($dataBatch,$data);
		
		$res = $TournamentModel->saveBatch($dataBatch);
		//更新赛程发送推送
//		$baiduPushModel=new BaiduPushModel();
//		$baiduPushModel->sendMessageForAllLeague( 4, 20, $leagueId, "更新了赛程");	
		
		if(isset($res[0]->success)){
			$response = 'success';
		}else{
			$response = 'fail';
		}

		CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,array('response'=>$response));
		
	}		
	
	public function actionEditManage(){

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);
		$leagueId = $res[0]->objectId;
		$leagueGrounds = $res[0]->playground;
		$teamModel = new TeamModel();
		$tournamentModel = new TournamentModel();
		$groupModel = new GroupModel();
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		$games = array();
		$games = $tournamentModel->findByLeague($leagueId);

		//先找到联赛中的组
		$groupRows = $groupModel->findByLeagueId($leagueId);

		//var_dump($gruopRows);exit;
		$groupTeams = array();
		$groupTeamsArr = array();

		if(!empty($groupRows)){

			foreach($groupRows as $group){
				$groupId = $group->objectId;
				$groupRelTeams = $teamModel->findRowsByRelation("teams","Group",$groupId);
				foreach($groupRelTeams as $team){
					$team->groupName = $group->name;
					$team->groupObjectId = $group->objectId;
					foreach($leagueTeams as $lTeam){
						if($lTeam->objectId == $team->objectId){
							$lTeam->selected = 1;
						}
					}
				}


				$groupTeamsArr = $groupRelTeams;
				array_push($groupTeams,$groupTeamsArr);
			}

		}

		//var_dump($games);exit;
		$this->render('editManage',array('leagueTeams'=>$leagueTeams,'games'=>$games,'leagueGrounds'=>$leagueGrounds,'groupTeams'=>$groupTeams));

	}

	/**
	 * @desc 编辑赛事信息
	 */
	public function actionEditGameSchedule(){

		if (!Yii::app()->request->isAjaxRequest){
			throw new CHttpException(500, '此方法只允许ajax调用');
		}

		$masterId = CommonFunction::getUserId();

		$gameDate =  Yii::app()->request->getPost('game_date');
		$gameTime =  Yii::app()->request->getPost('game_time');
		$gameAddress =  Yii::app()->request->getPost('game_address');
		$gameId = Yii::app()->request->getPost('gameid');

		if(empty($gameId) || empty($gameDate) || empty($gameTime) || empty($gameAddress)){
			CommonFunction::ajaxResult(State::$SYS_PARAM_ERROR_CODE, State::$SYS_PARAM_ERROR_MSG );
		}

		$leagueModel = new LeagueModel();
		$res = $leagueModel->findByMaster($masterId,1);
		if(empty($res)){
			throw new CHttpException(500, '该用户无权限管理联赛');
		}
		$leagueId = $res[0]->objectId;
		$leagueName = $res[0]->name;
		$gameModel = new TournamentModel();

		$leagueTeam = $gameModel->findLeagueTeam($gameId,$leagueId);

		if(empty($leagueTeam)){
			CommonFunction::ajaxResult(State::$SYS_PERMISSION_ERROR_CODE, State::$SYS_PERMISSION_ERROR_MSG);
		}

		//var_dump($leagueTeam);exit;

//		$date = array(
//			'event_date' => $gameDate.' 00:00:00',
//			'start_time' => '0000-00-00 '.$gameTime,
//			'site' => $gameAddress
//		);
//		$gameDate = date ( "Y-m-d" );
//		$gameTime = date ( "H:i:s" );

		//$date = $gameDate.' 00:00:00';
		$gameDateTime = $gameDate.' '.$gameTime.':00';
		$res = '';
		try{
			$res = $gameModel->updateSchedule($gameId,$gameDateTime,$gameDateTime,$gameAddress);
		}catch (Exception $e){
			//echo $e;
		}
		
		//更新赛程发送推送
		$baiduPushModel=new BaiduPushModel();
		$baiduPushModel->sendMessageForAllLeague( 4, 20, $leagueId, "更新了赛程");	
		
		if(isset($res->updatedAt)){
			$response = 'success';
		}else{
			$response = 'fail';
		}

		CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,array('response'=>$response));

	}

	/**
	 * @desc 编辑赛事结果
	 */
	public function actionResultManage(){

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueId = $res[0]->objectId;

		$teamModel = new TeamModel();
		$tournamentModel = new TournamentModel();
		$playScoreModel = new PlayerScoreModel();
		$groupModel = new GroupModel();

		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		//先找到联赛中的组
		$groupRows = $groupModel->findByLeagueId($leagueId);

		//var_dump($gruopRows);exit;
		$groupTeams = array();
		$groupTeamsArr = array();

		if(!empty($groupRows)){

			foreach($groupRows as $group){
				$groupId = $group->objectId;
				$groupRelTeams = $teamModel->findRowsByRelation("teams","Group",$groupId);
				foreach($groupRelTeams as $team){
					$team->groupName = $group->name;
					$team->groupObjectId = $group->objectId;
					foreach($leagueTeams as $lTeam){
						if($lTeam->objectId == $team->objectId){
							$lTeam->selected = 1;
						}
					}
				}


				$groupTeamsArr = $groupRelTeams;
				array_push($groupTeams,$groupTeamsArr);
			}

		}

		//var_dump($groupTeams);exit;

		$games = array();
		$games = $tournamentModel->findByLeague($leagueId);

		$leagueGamesData = $playScoreModel->findByLeague($leagueId);
		//var_dump($leagueGamesData);exit;

		foreach($games as $k => $game){
			if(isset($game->start_time->iso)){
				$fromStartTime = time() - strtotime($game->start_time->iso);
//			echo $fromStartTime.'||'.$game->start_time->iso.'||'.date ( "Y-m-d H:i:s" ).'||'.strtotime($game->start_time->iso).'<br/>';
				if($fromStartTime > 7200 && (!isset($game->isVerify) || !$game->isVerify)){
					$game->allowResultEdit = true;
				}else{
					$game->allowResultEdit = false;
				}
				//比赛开始后2小时，认为比赛结束
				if($fromStartTime < 7200){
					//echo (time() - strtotime($game->start_time->iso)).'<br/>'.$game->start_time->iso;
					unset($games[$k]);
				}else{
					foreach($leagueGamesData as $k => $gameData){
						if(isset($gameData->competition->objectId) && isset($game->objectId) && isset($gameData->team->objectId) && isset($game->home_court->objectId) && ($gameData->competition->objectId == $game->objectId) && ($gameData->team->objectId == $game->home_court->objectId)){
							//这场比赛的主队球员进球情况
							$game->home_court->playerscore[] = array(
								'player' => empty($gameData->player->nickname) ? '匿名' : $gameData->player->nickname,
								'score' =>  $gameData->goals
							);

						}elseif(isset($gameData->competition->objectId) && isset($game->objectId) && isset($gameData->team->objectId) && isset($game->opponent->objectId) &&  ($gameData->competition->objectId == $game->objectId) && ($gameData->team->objectId == $game->opponent->objectId)){
							//这场比赛的客队球员进球情况
							$game->opponent->playerscore[] = array(
								'player' => empty($gameData->player->nickname) ? '匿名' : $gameData->player->nickname,
								'score' =>  $gameData->goals
							);

						}
					}
				}
			}else{
				unset($games[$k]);
			}

		}



		$this->render('resultManage',array('leagueTeams'=>$leagueTeams,'groupTeams'=>$groupTeams,'games'=>$games));

	}

	/**
	 * @desc 编辑比赛结果
	 */
	public function actionEditGameResult(){

		if (!Yii::app()->request->isAjaxRequest){
			throw new CHttpException(500, '此方法只允许ajax调用');
		}

		$masterId = CommonFunction::getUserId();

		$gameId =  Yii::app()->request->getPost('gameid');
		$homeTeamScore =  Yii::app()->request->getPost('home_team_score');
		$opponentTeamScore =  Yii::app()->request->getPost('opponent_team_score');

		if(empty($gameId) || !is_numeric($homeTeamScore) || !is_numeric($opponentTeamScore)){
			CommonFunction::ajaxResult(State::$SYS_PARAM_ERROR_CODE, State::$SYS_PARAM_ERROR_MSG );
		}

		$leagueModel = new LeagueModel();
		$res = $leagueModel->findByMaster($masterId,1);
		if(empty($res)){
			throw new CHttpException(500, '该用户无权限管理联赛');
		}
		$leagueId = $res[0]->objectId;

		$gameModel = new TournamentModel();
		$userModel = new UserModel();

		$gameArr = $gameModel->findByObjectId($gameId);

		if(isset($gameArr[0])){
			$game = $gameArr[0];
			if(isset($game->home_court->captain->objectId)){
				$homeTeamCaptainId = $game->home_court->captain->objectId;
				$homeTeamCaptain = $userModel->getByObjectId($homeTeamCaptainId);
				if(!empty($homeTeamCaptain)){
					if(isset($homeTeamCaptain->username) && !empty($homeTeamCaptain->username)){
						$homeTeamCaptainUsername = $homeTeamCaptain->username;
						$pushMsg = '比赛已通过认证';
						CommonFunction::pushAppMsg($homeTeamCaptainUsername,$pushMsg);
					}

				}
				//var_dump($homeTeamCaptain);
				//echo $homeTeamCaptainId;
			}
			if(isset($game->opponent->captain->objectId)){
				$opponentTeamCaptainId = $game->opponent->captain->objectId;
				$opponentTeamCaptain = $userModel->getByObjectId($opponentTeamCaptainId);
				//var_dump($opponentTeamCaptain);
				//echo $opponentTeamCaptainId;
			}
		}
//		var_dump($game);exit;

		$res = '';
		try{
			$res = $gameModel->updateScore($gameId,$homeTeamScore,$opponentTeamScore);

		}catch (Exception $e){
			//echo $e;
		}
	//	var_dump($res);exit;
		if(isset($res->updatedAt)){

			if(isset($gameArr[0])){
				$game = $gameArr[0];
				$teamScoreModel = new TeamScoreModel();
				if(isset($game->home_court->objectId)){
					$homeTeamId = $game->home_court->objectId;
					if(isset($game->home_court->name)){
						$homeTeamName = $game->home_court->name;
					}
					$diffScore = $homeTeamScore - $opponentTeamScore;
					$win = false;
					$draw = false;
					$loss = false;
					$score = 0;
					if($diffScore > 0){
						$win = true;
						$score = 3;
					}elseif($diffScore == 0){
						$draw = true;
						$score = 1;
					}elseif($diffScore < 0){
						$loss = true;
					}
					$homeTeamBasic = array(
						'league'=>array(
							"__type"=>"Pointer",
							"className"=>"League",
							"objectId"=>$leagueId
						),
						'competition'=>array(
							"__type"=>"Pointer",
							"className"=>"Tournament",
							"objectId"=>$gameId
						),
						'team'=>array(
							"__type"=>"Pointer",
							"className"=>"Team",
							"objectId"=>$homeTeamId
						),
						'name'=>$homeTeamName
					);
					$homeTeamDev = array(
						'goals'=>$homeTeamScore,
						'goals_against'=>$opponentTeamScore,
						'goal_difference'=>$diffScore,
						'win'=>$win,
						'draw'=>$draw,
						'loss'=>$loss,
						'score'=>$score
					);
					$hasData = $teamScoreModel->findByCompetitionTeam($gameId,$homeTeamId);

					if(!isset($hasData[0]->objectId)){
						$homeTeamData = array_merge($homeTeamBasic,$homeTeamDev);
						$teamScoreModel->save($homeTeamData);
					}else{
						$teamScoreId = $hasData[0]->objectId;
						$teamScoreModel->update($teamScoreId,$homeTeamDev);
					}

				}

				if(isset($game->opponent->objectId)){
					$opponentTeamId = $game->opponent->objectId;
					if(isset($game->opponent->name)){
						$opponentTeamName = $game->opponent->name;
					}
					$diffScore = $opponentTeamScore - $homeTeamScore;
					$win2 = false;
					$draw2 = false;
					$loss2 = false;
					$score2 = 0;
					if($diffScore > 0){
						$win2 = true;
						$score2 = 3;
					}elseif($diffScore == 0){
						$draw2 = true;
						$score2 = 1;
					}elseif($diffScore < 0){
						$loss2 = true;
					}
					$opponentTeamBasic = array(
						'league'=>array(
							"__type"=>"Pointer",
							"className"=>"League",
							"objectId"=>$leagueId
						),
						'competition'=>array(
							"__type"=>"Pointer",
							"className"=>"Tournament",
							"objectId"=>$gameId
						),
						'team'=>array(
							"__type"=>"Pointer",
							"className"=>"Team",
							"objectId"=>$opponentTeamId
						),
						'name'=>$opponentTeamName
					);
					$opponentTeamDev = array(
						'goals'=>$opponentTeamScore,
						'goals_against'=>$homeTeamScore,
						'goal_difference'=>$diffScore,
						'win'=>$win2,
						'draw'=>$draw2,
						'loss'=>$loss2,
						'score'=>$score2
					);

					$hasData2 = $teamScoreModel->findByCompetitionTeam($gameId,$opponentTeamId);

					if(!isset($hasData2[0]->objectId)){
						$opponentTeamData = array_merge($opponentTeamBasic,$opponentTeamDev);
						$teamScoreModel->save($opponentTeamData);
					}else{
						$teamScoreId2 = $hasData2[0]->objectId;
						$teamScoreModel->update($teamScoreId2,$opponentTeamDev);
					}

				}

			}

			$response = 'success';
		}else{
			$response = 'fail';
		}

		CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,array('response'=>$response));

	}

	/**
	 * @desc 联赛管理
	 */
	public function actionTeamManage(){

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueId = $res[0]->objectId;
		if(isset($res[0]->city)){
			$localCity = $res[0]->city;
		}else{
			$localCity = Yii::app()->params['defaultCityCode'];
		}

		$teamModel = new TeamModel();
		$initTeams = $teamModel->findServeralTeams($localCity,5);
		//找到联赛中的所有球队
//		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);
		$leagueTeams = $teamModel->findLeagueTeams("League",$leagueId);
		$leagueTeamsArr = CommonFunction::ob2ar($leagueTeams);
		$teamidArr = array();
		foreach($leagueTeamsArr as $team){
			array_push($teamidArr,$team['objectId']);
		}

		foreach($initTeams as &$searchTeam){
			if(in_array($searchTeam->objectId,$teamidArr)){
				//已选入联赛的则设置此值
				$searchTeam->hasLeague = 1;
			}
		}

		$this->render('teamManage',array('leagueList'=>$res[0],'leagueTeams'=>$leagueTeams,'initTeams'=>$initTeams));
	}


	/**
	 * @desc 查找球队
	 * @throws CHttpException
	 */
	public function actionSearchTeamAjax(){

		if (!Yii::app()->request->isAjaxRequest){
			throw new CHttpException(500, '此方法只允许ajax调用');
		}

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		$res = $leagueModel->findByMaster($masterId,1);
		if(empty($res)){
			throw new CHttpException(500, '该用户无权限管理联赛');
		}
		$name = Yii::app()->request->getQuery('name');

		$teamModel = new TeamModel();
		$result = $teamModel->findTeamsByName($name);
		//找到联赛中的所有球队
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$res[0]->objectId);
		$leagueTeamsArr = CommonFunction::ob2ar($leagueTeams);
		$teamidArr = array();
		foreach($leagueTeamsArr as $team){
			if(isset($team['objectId'])){
				array_push($teamidArr,$team['objectId']);
			}
		}
		//	var_dump($leagueTeamsArr);

		foreach($result as &$searchTeam){
			if(in_array($searchTeam->objectId,$teamidArr)){
				//已选入联赛的则设置此值
				$searchTeam->hasLeague = 1;
			}
		}

		CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,$result);
	}


	/**
	 * @desc 获取球员所加入的球队
	 */
	public function actionGetUserTeams(){

		if (!Yii::app()->request->isAjaxRequest){
			throw new CHttpException(500, '此方法只允许ajax调用');
		}

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		$res = $leagueModel->findByMaster($masterId,1);
		if(empty($res)){
			throw new CHttpException(500, '该用户无权限管理联赛');
		}

		$username = Yii::app()->request->getQuery('username');

		$user = new UserModel();
		$userRes = $user->getUserByUsername($username);
		if(empty($userRes)){
			CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,"noteam");
		}else{
			$userid = $userRes[0]->objectId;
		}
//		var_dump($userRes);
//		echo $userid;
		$teamModel = new TeamModel();
		$userTeams = $teamModel->findTeamsByCaptain($userid);

		$userTeamNameArr = array();
		foreach($userTeams as $userTeam){
			if(isset($userTeam->name)){
				array_push($userTeamNameArr,$userTeam->name);
			}
		}

		CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,array('response'=>json_encode($userTeamNameArr)));
	}

	public function actionGameResult(){

		$masterId = CommonFunction::getUserId();

		$leagueModel = new LeagueModel();
		//判断用户是否有管理联赛的权限
		$res = $leagueModel->allowEditLeague($masterId);

		$leagueId = $res->results[0]->objectId;

		$content = CommonFunction::ob2ar($res);

		foreach ($content["results"] as $key) {
			echo $key["name"];
		}

		$teamModel = new TeamModel();
		$tournamentModel = new TournamentModel();
		$leagueTeams = $teamModel->findRowsByRelation("teams","League",$leagueId);

		$games = array();
		$games = $tournamentModel->findByLeague($leagueId);

		foreach($games as $k => $game){
			//比赛开始后2小时，认为比赛结束
			if(time() - strtotime($game->start_time->iso) > 7200){
				unset($games[$k]);
			}
		}

		$this->render('gameResult',array('leagueTeams'=>$leagueTeams,'games'=>$games));

	}

	public function actionEditM(){
		$this->render('editManageBak');
	}

	public function actionTest(){
//		$cloudCode = new BmobCloudCode('resulttest');
//		$res = $cloudCode->get(array("name"=>111222));
//		var_dump(json_decode($res,true));exit;
//		$test=new UserModel();
//		$res=$test->getUserByTeam("093dc7adf2","11ccef1103");

		
//		$teamModel = new TeamModel();
//		$leagueTeams = $teamModel->findMembers("f5967d0626");
////		
//		$baiduPushModel=new BaiduPushModel();
//		$baiduPushModel->push($leagueTeams,"更新赛事","更新赛事啊啊啊111", 4, 21, array("leagueId"=>"f5967d0626"));		
		
		
//		//更新赛程发送推送
//		$baiduPushModel=new BaiduPushModel();
//		$baiduPushModel->sendMessageForAllLeague( 4, 21, "3171e5c832","aaaa");	
		
		$leagueModel = new LeagueModel();
		
			$res = $leagueModel->createRelation('teams','Team',"c341dfb5a3","202de4d820");

		
		
		
		
	}
	
	/**
	 * @desc 修复android严重比赛结果后没保存TeamScore的问题
	 */
	public function actionTestSaveTeamScore(){

				$masterId = CommonFunction::getUserId();
		$gameId =  "b404c1fc88";
		$homeTeamScore =  "8";
		$opponentTeamScore =  "0";

		$leagueModel = new LeagueModel();
		$res = $leagueModel->findByMaster($masterId,1);
		if(empty($res)){
			throw new CHttpException(500, '该用户无权限管理联赛');
		}
		$leagueId = $res[0]->objectId;

		$gameModel = new TournamentModel();
		$userModel = new UserModel();

		$gameArr = $gameModel->findByObjectId($gameId);

		if(isset($gameArr[0])){
			$game = $gameArr[0];
			if(isset($game->home_court->captain->objectId)){
				$homeTeamCaptainId = $game->home_court->captain->objectId;
				$homeTeamCaptain = $userModel->getByObjectId($homeTeamCaptainId);
				if(!empty($homeTeamCaptain)){
					if(isset($homeTeamCaptain->username) && !empty($homeTeamCaptain->username)){
						$homeTeamCaptainUsername = $homeTeamCaptain->username;
					}

				}

			}
			if(isset($game->opponent->captain->objectId)){
				$opponentTeamCaptainId = $game->opponent->captain->objectId;
				$opponentTeamCaptain = $userModel->getByObjectId($opponentTeamCaptainId);

			}
		}
//		var_dump($game);exit;

		$res = '';
		try{
//			$res = $gameModel->updateScore($gameId,$homeTeamScore,$opponentTeamScore);

		}catch (Exception $e){
			//echo $e;
		}
		if(true){

			if(isset($gameArr[0])){
				$game = $gameArr[0];
				$teamScoreModel = new TeamScoreModel();
				if(isset($game->home_court->objectId)){
					$homeTeamId = $game->home_court->objectId;
					if(isset($game->home_court->name)){
						$homeTeamName = $game->home_court->name;
					}
					$diffScore = $homeTeamScore - $opponentTeamScore;
					$win = false;
					$draw = false;
					$loss = false;
					$score = 0;
					if($diffScore > 0){
						$win = true;
						$score = 3;
					}elseif($diffScore == 0){
						$draw = true;
						$score = 1;
					}elseif($diffScore < 0){
						$loss = true;
					}
					$homeTeamBasic = array(
						'league'=>array(
							"__type"=>"Pointer",
							"className"=>"League",
							"objectId"=>$leagueId
						),
						'competition'=>array(
							"__type"=>"Pointer",
							"className"=>"Tournament",
							"objectId"=>$gameId
						),
						'team'=>array(
							"__type"=>"Pointer",
							"className"=>"Team",
							"objectId"=>$homeTeamId
						),
						'name'=>$homeTeamName
					);
					$homeTeamDev = array(
						'goals'=>$homeTeamScore,
						'goals_against'=>$opponentTeamScore,
						'goal_difference'=>$diffScore,
						'win'=>$win,
						'draw'=>$draw,
						'loss'=>$loss,
						'score'=>$score
					);
					$hasData = $teamScoreModel->findByCompetitionTeam($gameId,$homeTeamId);

					if(!isset($hasData[0]->objectId)){
						$homeTeamData = array_merge($homeTeamBasic,$homeTeamDev);
						$teamScoreModel->save($homeTeamData);
					}else{
						$teamScoreId = $hasData[0]->objectId;
						$teamScoreModel->update($teamScoreId,$homeTeamDev);
					}

				}

				if(isset($game->opponent->objectId)){
					$opponentTeamId = $game->opponent->objectId;
					if(isset($game->opponent->name)){
						$opponentTeamName = $game->opponent->name;
					}
					$diffScore = $opponentTeamScore - $homeTeamScore;
					$win2 = false;
					$draw2 = false;
					$loss2 = false;
					$score2 = 0;
					if($diffScore > 0){
						$win2 = true;
						$score2 = 3;
					}elseif($diffScore == 0){
						$draw2 = true;
						$score2 = 1;
					}elseif($diffScore < 0){
						$loss2 = true;
					}
					$opponentTeamBasic = array(
						'league'=>array(
							"__type"=>"Pointer",
							"className"=>"League",
							"objectId"=>$leagueId
						),
						'competition'=>array(
							"__type"=>"Pointer",
							"className"=>"Tournament",
							"objectId"=>$gameId
						),
						'team'=>array(
							"__type"=>"Pointer",
							"className"=>"Team",
							"objectId"=>$opponentTeamId
						),
						'name'=>$opponentTeamName
					);
					$opponentTeamDev = array(
						'goals'=>$opponentTeamScore,
						'goals_against'=>$homeTeamScore,
						'goal_difference'=>$diffScore,
						'win'=>$win2,
						'draw'=>$draw2,
						'loss'=>$loss2,
						'score'=>$score2
					);

					$hasData2 = $teamScoreModel->findByCompetitionTeam($gameId,$opponentTeamId);

					if(!isset($hasData2[0]->objectId)){
						$opponentTeamData = array_merge($opponentTeamBasic,$opponentTeamDev);
						$teamScoreModel->save($opponentTeamData);
					}else{
						$teamScoreId2 = $hasData2[0]->objectId;
						$teamScoreModel->update($teamScoreId2,$opponentTeamDev);
					}

				}

			}

			$response = 'success';
		}else{
			$response = 'fail';
		}

	}
	

}