<?php

class LeagueController extends Controller
{

	/**
	 * @desc 添加球队
	 */
	public function actionAddTeam(){

		$masterId = CommonFunction::getUserId();

		$leagueId =  Yii::app()->request->getPost('leagueId');
		$teamId =  Yii::app()->request->getPost('teamId');

		if(empty($leagueId) || empty($teamId)){
			CommonFunction::ajaxResult(State::$SYS_PARAM_ERROR_CODE, State::$SYS_PARAM_ERROR_MSG );
		}

		$leagueModel = new LeagueModel();

		$groupModel = new GroupModel();
		$Groups = $groupModel->findByLeagueId($leagueId);
		if(empty($Groups)){

			$res = $leagueModel->createRelation('teams','Team',$leagueId,$teamId);

			if(isset($res->updatedAt)){
				$resM = $leagueModel->findByMaster($masterId,1);
				$teamModel = new TeamModel();
				$leagueTeams = $teamModel->findRowsByRelation("teams","League",$resM[0]->objectId);

				$addTeam = $teamModel->findTeamByObjectId($teamId);

				if(isset($addTeam[0]->captain->username)){
					$uid = $addTeam[0]->captain->username;
					$pushMsg = '你的球队：'.$addTeam[0]->name.'，已被添加进联赛：'.$resM[0]->name;
					
					//给队长发送联赛邀请
					$baiduPushModel=new BaiduPushModel();
					$baiduPushModel->sendInviteMessageForTeamCaptain(  $leagueId, $teamId,  $addTeam[0]->captain );	
					
//					CommonFunction::pushAppMsg($uid,$pushMsg);
//					$device = new InstallationModel();
//					$msg = $device->findByUid($uid);
//					if(isset($msg[0]) && !empty($msg[0])){
//
//						$deviceMsg = $msg[0];
//						$push = new PushMsgModel();
//						$pushMsg = '你的球队：'.$addTeam[0]->name.'，已被添加进联赛：'.$resM[0]->name;
//
//						if(isset($deviceMsg->deviceToken) && isset($deviceMsg->deviceType) && $deviceMsg->deviceType == 'ios'){
//							$push->createIosPush($deviceMsg->deviceToken,$pushMsg);
//						}elseif(isset($deviceMsg->installationId) && isset($deviceMsg->deviceType) && $deviceMsg->deviceType == 'android'){
//							$push->createAndroidPush($deviceMsg->installationId,$pushMsg);
//						}
//
//					}

				}

			}

			CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,array('leagueTeams'=>$leagueTeams));

		}else{
			CommonFunction::ajaxResult(State::$TEAM_ADD_ERROR_CODE, State::$TEAM_ADD_ERROR_MSG );
		}


	}

	/**
	 * @desc 删除球队
	 */
	public function actionDeleteTeam(){

		$masterId = CommonFunction::getUserId();

		$leagueId =  Yii::app()->request->getPost('leagueId');
		$teamId =  Yii::app()->request->getPost('teamId');

		if(empty($leagueId) || empty($teamId)){
			CommonFunction::ajaxResult(State::$SYS_PARAM_ERROR_CODE, State::$SYS_PARAM_ERROR_MSG );
		}

		$leagueModel = new LeagueModel();
		$groupModel = new GroupModel();

		$Groups = $groupModel->findByLeagueId($leagueId);
		if(empty($Groups)){

			$res = $leagueModel->removeRelation('teams','Team',$leagueId,$teamId);

			if(isset($res->updatedAt)){
				$resM = $leagueModel->findByMaster($masterId,1);
				$teamModel = new TeamModel();
				$leagueTeams = $teamModel->findRowsByRelation("teams","League",$resM[0]->objectId);

				$deleteTeam = $teamModel->findTeamByObjectId($teamId);

				if(isset($deleteTeam[0]->captain->username)){
					$uid = $deleteTeam[0]->captain->username;
					$pushMsg = '你的球队：'.$deleteTeam[0]->name.'，已被联赛【'.$resM[0]->name.'】移除出联赛';
					CommonFunction::pushAppMsg($uid,$pushMsg);
//					$device = new InstallationModel();
//					$msg = $device->findByUid($uid);
//					if(isset($msg[0]) && !empty($msg[0])){
//						$deviceMsg = $msg[0];
//						$push = new PushMsgModel();
//						$pushMsg = '你的球队：'.$deleteTeam[0]->name.'，已被联赛【'.$resM[0]->name.'】移除出联赛';
//						if(isset($deviceMsg->deviceToken) && isset($deviceMsg->deviceType) && $deviceMsg->deviceType == 'ios'){
//							$push->createIosPush($deviceMsg->deviceToken,$pushMsg);
//						}elseif(isset($deviceMsg->installationId) && isset($deviceMsg->deviceType) && $deviceMsg->deviceType == 'android'){
//							$push->createAndroidPush($deviceMsg->installationId,$pushMsg);
//						}
//					}
				}

			}

			CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,array('leagueTeams'=>$leagueTeams));

		}else{
			CommonFunction::ajaxResult(State::$TEAM_DELETE_ERROR_CODE, State::$TEAM_DELETE_ERROR_MSG );
		}

	}

	/**
	 * @desc 邀请球队
	 */
	public function actionInviteTeam(){

		isset(Yii::app()->user->oid) ? $masterId = Yii::app()->user->oid : $masterId = '';

		$teamName =  Yii::app()->request->getPost('teamname');
		$mobileNum =  Yii::app()->request->getPost('mobilenum');

		if(empty($teamName) || empty($mobileNum) || !CommonFunction::checkMobile($mobileNum)){
			CommonFunction::ajaxResult(State::$TEAM_SENDMSG_ERROR_CODE, State::$TEAM_SENDMSG_ERROR_MSG );
		}

		$leagueModel = new LeagueModel();
		$resM = $leagueModel->findByMaster($masterId,1);
		$leagueId = $resM[0]->objectId;
		$leagueName = $resM[0]->name;
		$inviteCode = $resM[0]->inviteCode;

		$msgUrl = Yii::app()->params['inviteMsgUrl'];

		if(preg_match("/^0?(13[0-9]|15[0-9]|17[678]|18[0-9]|14[57])[0-9]{8}$/i", $mobileNum)){
//			$data = array(
//				'account'=>Yii::app()->params['MsgUsername'],
//				'password'=>Yii::app()->params['MsgPwd'],
//				'destMobiles'=> $mobileNum,
//				'msgContents'=>'诚邀你的球队：'.$teamName.',加入联赛：'.$leagueName.',邀请码是：'.$leagueId.'【踢球吧】'
//			);
//			$msgBack = CommonFunction::sendMobileMsg($msgUrl,$data);
			$data = array(
				'mobile'=>$mobileNum,
				'content'=>'诚邀你的球队：'.$teamName.',加入联赛：'.$leagueName.', 联赛邀请码是：'.$inviteCode
			);
			$mobileMsgModel = new BmobMobileMsg();
			$msgBack = $mobileMsgModel->send($data);
		} else {
			CommonFunction::ajaxResult(State::$TEAM_SENDMSG_ERROR_CODE, State::$TEAM_SENDMSG_ERROR_MSG );
		}

//		echo $msgBack;exit;
//		$msgBack = 1;
		if(!is_numeric($msgBack) || $msgBack > 0){
			$msgBack = 1;
		}

		CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG,array('response'=>$msgBack));

	}

	/**
	 * @desc 调用云端代码更新联赛榜单数据
	 */
	public function actionUpdateLeagueRange(){

		$leagueId = Yii::app()->request->getPost('leagueid');

		$cloudCodeModel = new BmobCloudCode('leagueScoreSingle');
		$res = $cloudCodeModel->get(array('leagueId'=>"$leagueId"));

		if(empty($res)){
			CommonFunction::ajaxResult(State::$LEAGUE_RANGE_ERROR_CODE, State::$LEAGUE_RANGE_ERROR_MSG);
		}else{
					//更新积分榜发送推送
			$baiduPushModel=new BaiduPushModel();
			$baiduPushModel->sendMessageForAllLeague( 4, 21, $leagueId, "更新了积分榜");	
			CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG, array('response'=>$res));
		}

	}


	/**
	 * @desc 调用云端代码更新联赛射手榜数据
	 */
	public function actionUpdateShooterData(){

		$leagueId = Yii::app()->request->getPost('leagueid');

		$cloudCodeModel = new BmobCloudCode('userGoalAssist');
		$res = $cloudCodeModel->get(array('leagueId'=>"$leagueId"));

		if(empty($res)){
			CommonFunction::ajaxResult(State::$SHOOTER_RANGE_ERROR_CODE, State::$SHOOTER_RANGE_ERROR_MSG);
		}else{
								//更新射手榜发送推送
			$baiduPushModel=new BaiduPushModel();
			$baiduPushModel->sendMessageForAllLeague( 4, 21, $leagueId, "更新了射手榜");	
			CommonFunction::ajaxResult(State::$SUSSION_CODE, State::$SUSSION_MSG, array('response'=>$res));
		}

	}


	public function actionPushMsg(){

		$device = new InstallationModel();
		$msg = $device->findByUid('18666486846');
//		var_dump($msg);
		$deviceMsg = $msg[0];
		$push = new PushMsgModel();
		if(isset($deviceMsg->deviceType) && $deviceMsg->deviceType == 'ios'){
			$push->createIosPush($deviceMsg->deviceToken);
		}

	}


}