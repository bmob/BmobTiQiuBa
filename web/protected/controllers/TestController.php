<?php

class TestController extends Controller
{

	/**
	 * $secret_key //应用的secret key
	 * $method //GET或POST
	 * $url url
	 * $arrContent //请求参数(包括GET和POST的所有参数，不含计算的sign)
	 * return $sign string
	 **/
	function genSign($secret_key, $method, $url, $arrContent) {
		$gather = $method.$url;
		ksort($arrContent);
		foreach($arrContent as $key => $value) {
			$gather .= $key.'='.$value;
		}
		$gather .= $secret_key;
		$sign = md5(urlencode($gather));
		return $sign;
	}


	public function actionPushMsg(){

		$url = Yii::app()->params['baiduPushUrl'];

		$data = array();

//		$pushChannelId = '5087863206650481995';
//		$pushUserId = '835193518001501739';
//		$pushChannelId = '4977988759767876470';
//		$pushUserId = '1096173785012458930';
	//	$pushUserId = '835193518001501739';

		//my
		//$pushUserId = '751819122609825405';

		$apikey = 'vDBzvsU11eUq2240spz6nOdU';
		$secret_key = 'klXStAgu1GuFVyq8BdsUuoqaYhiit5hQ';//此处替换为应用的secret key

		$timestamp = time();

		$content = '网站端测试推送';

		$aps = array(
			"alert" => "$content",
			"sound" => "1",
			"badge" => 1
		);

		$mess = array(
			"title" => "hello",
			"description" => $content,
			"aps" => $aps
		);

		$method = 'POST';
		$arrContent = array(
			'method' => 'push_msg',
			'apikey' => $apikey,
//			'user_id' => $pushUserId,
			'push_type' => 2,
			//'channel_id' => $pushChannelId,
			'tag' => '093dc7adf2',
			'device_type' => 4,
			'message_type' => 1,
			'deploy_status' => 1,
			'messages' => json_encode($mess),
			'msg_keys' => '1',
			'timestamp'=> $timestamp,
			'expires' => intval($timestamp) + 600,
		);

		$sign = $this->genSign($secret_key, $method, $url, $arrContent);

		$arrContent['sign'] = $sign;

		//var_dump($arrContent);exit;

		$query = http_build_query($arrContent);

//		{"aps":{"alert":"稻草人已成功加入您所属的球队","badge":0},
//			"belongId":"11ccef1103",
//			"flag":"notice",
//			"status":0,
//			"subtype":6,
//			"targetId":"15521272396",
//			"time":1423646769,
//			"title":"三体战队",
//			"type":2,
//			"extra":"{\"teamId\":\"11ccef1103\"}"}

//		$extra = array(
//			'aps' => $aps,
//			'belongId' => 'b59277d390',
//			"flag" => "notice",
//			"status" => 0,
//			"subtype" => 6,
//			"targetId" => "15521272396",
//			"time" => time(),
//			"title" => "三体战队",
//			"type" => 2,
//			"extra" => array(
//				"teamId" => '11ccef1103'
//			)
//		);

		$extra = array(
			"belongId" => "18666486843",
			"title" => "21ce",
			"type" => 2,
			"time" => time(),
//			"type" =>
			"targetId" => "18666486843",
			"subtype" => 18
		);

		$saveArr = array(
			'belongUsername' => '18666486843',
			'isRead' => 0,
			'status' => 0,
			'msgType' => 0,
			'extra' => json_encode($extra),
			'content' => $content
		);

		$pushMsgModel = new PushMsgModel();
		$result = $pushMsgModel->addPushMsg($saveArr);
		//var_dump($result);exit;
	//	echo $url.'?'.$query;exit;
		$res = CommonFunction::sendMobileMsg($url.'?'.$query,$data);

		var_dump($res);

	}

	public function actionPushTeamMsg(){


		$url = Yii::app()->params['baiduPushUrl'];

		$data = array();

//		$pushChannelId = '5087863206650481995';
//		$pushUserId = '835193518001501739';
//		$pushChannelId = '4977988759767876470';
//		$pushUserId = '1096173785012458930';
		//	$pushUserId = '835193518001501739';
		//my
		//$pushUserId = '751819122609825405';

		$apikey = 'vDBzvsU11eUq2240spz6nOdU';
		$secret_key = 'klXStAgu1GuFVyq8BdsUuoqaYhiit5hQ';//此处替换为应用的secret key

		$timestamp = time();

		$content = '网站端测试推送';
		$aps = array(
			"alert" => "$content",
			"sound" => "1",
			"badge" => 1
		);

		$mess = array(
			"title" => "hello",
			"description" => $content,
			"aps" => $aps
		);

		$method = 'POST';
		$arrContent = array(
			'method' => 'push_msg',
			'apikey' => $apikey,
			//	'user_id' => $pushUserId,
			'push_type' => 2,
			//'channel_id' => $pushChannelId,
			'tag' => '093dc7adf2',
			'device_type' => 4,
			'message_type' => 1,
			'deploy_status' => 1,
			'messages' => json_encode($mess),
			'msg_keys' => '1',
			'timestamp'=> $timestamp,
			'expires' => intval($timestamp) + 600,
		);

		$sign = $this->genSign($secret_key, $method, $url, $arrContent);

		$arrContent['sign'] = $sign;

		//var_dump($arrContent);exit;

		$query = http_build_query($arrContent);

		$teamId = '093dc7adf2';

//		$teamModel = new TeamModel();
//		$team = $teamModel->findTeamByObjectId($teamId);

		$userModel = new UserModel();
		$teamUsers = $userModel->findRowsByRelation("footballer","Team",$teamId);

		foreach($teamUsers as $user){
			$user->username;
		}

		var_dump($teamUsers);exit;

		$extra = array(
			"belongId" => "18666486843",
			"title" => "21ce",
			"type" => 2,
			"time" => time(),
//			"type" =>
			"targetId" => "18666486843",
			"subtype" => 18
		);

		$saveArr = array(
			'belongUsername' => '18666486843',
			'isRead' => 0,
			'status' => 0,
			'msgType' => 0,
			'extra' => json_encode($extra),
			'content' => $content
		);

		$pushMsgModel = new PushMsgModel();
		$result = $pushMsgModel->addPushMsg($saveArr);
		//var_dump($result);exit;
		//	echo $url.'?'.$query;exit;
		$res = CommonFunction::sendMobileMsg($url.'?'.$query,$data);

		var_dump($res);

	}

	public function actionTeams(){

		$leagueTeamIds = array();
		$teamModel = new TeamModel();
		//找到联赛中的球队
		$leagueTeams = $teamModel->findRowsByRelation("teams","League","52a05804d7");

		foreach($leagueTeams as $lTeam){
			array_push($leagueTeamIds,$lTeam->objectId);
		}

//		$leagueTeamIdsStr = '["'.implode('","',$leagueTeamIds).'"]';

		$arr = array(
			'msg' => 'Hello , 网站端推送',
			'status' => 0,
			'pushType' => 1,
			'teams' => $leagueTeamIds
		);

		$leaguePushMsgModel = new LeaguePushMsgModel();
		$leaguePushMsgModel->save($arr);

		var_dump($leagueTeamIds);exit;

	}


	public function actionTeamsUserPush(){

		$userModel = new UserModel();
		$pushMsgModel = new PushMsgModel();

		$url = Yii::app()->params['baiduPushUrl'];
		$apikey = Yii::app()->params['baiduPushApiKey'];
		$secret_key = Yii::app()->params['baiduPushSecretKey'];//此处替换为应用的secret key
		$data = array();
		$timestamp = time();

		//var_dump($users);exit;

		$leaguePushMsgModel = new LeaguePushMsgModel();
		//找到需要进行消息推送的球队
		$pushData = $leaguePushMsgModel->findPush(0,1);
//		var_dump($pushData);exit;

		$pushTeams = array();
		if(isset($pushData[0]->teams)){
			$pushTeams = $pushData[0]->teams;
		}

		$content = '更新了赛程';
		$method = 'POST';

		$aps = array(
			"alert" => "$content",
			"sound" => "1",
			"badge" => 1
		);

		$mess = array(
			"title" => "更新了赛程",
			"description" => $content,
			"aps" => $aps
		);

		if(!empty($pushTeams)){

			foreach($pushTeams as $team){

				$arrContent = array(
					'method' => 'push_msg',
					'apikey' => $apikey,
					//	'user_id' => $pushUserId,
					'push_type' => 2,
					//'channel_id' => $pushChannelId,
					'tag' => $team,
					'device_type' => 4,
					'message_type' => 1,
					'deploy_status' => 1,
					'messages' => json_encode($mess),
					'msg_keys' => '1',
					'timestamp'=> $timestamp,
					'expires' => intval($timestamp) + 600,
				);

				$sign = $this->genSign($secret_key, $method, $url, $arrContent);

				$arrContent['sign'] = $sign;

				//var_dump($arrContent);exit;

				$query = http_build_query($arrContent);

				//找到联赛中的球队
				$users = $userModel->findRowsByRelation("footballer","Team",$team);

				if(!empty($users)){

					$saveBatchArr = array();

					foreach($users as $user){

						if(isset($user->username) && !empty($user->username)){

							$extra = array(
								"belongId" => $user->username,
								"title" => "联赛赛程",
								"type" => 2,
								"time" => time(),
								"targetId" => $user->objectId,
								"subtype" => 19
							);

							$saveArr = array(
								'belongUsername' => $user->username,
								'isRead' => 0,
								'status' => 0,
								'msgType' => 0,
								'extra' => json_encode($extra),
								'content' => $content
							);

							array_push($saveBatchArr,$saveArr);

							//记录球员接收的推送消息
							//$result = $pushMsgModel->addPushMsg($saveArr);

						}

					}

					$result = $pushMsgModel->saveBatch($saveBatchArr);

				}

				//var_dump($result);exit;
				//	echo $url.'?'.$query;exit;
				$res = CommonFunction::sendMobileMsg($url.'?'.$query,$data);

			}

			var_dump($res);exit;

		}

		var_dump($leagueTeams);exit;
		var_dump($pushData);exit;

	}


	public function actionCloudCode(){

		$cloudCodeModel = new BmobCloudCode('leagueScoreSingle');
		$res = $cloudCodeModel->get(array('leagueId'=>'52a05804d7'));

		var_dump($res);exit;
	}


	public function actionLeague(){

		$leagueModel = new LeagueModel();

		$res = $leagueModel->findByMaster('7c7fbc5309',1);
		if($res[0]->double_loop){
			var_dump($res[0]->double_loop);exit;
		}else{
			var_dump($res[0]->double_loop);echo 'ww';exit;
		}



	}


}