<?php

Yii::import("application.extensions.curl.Curl", true);

class ScheduleChangePushCommand extends CConsoleCommand
{
	public function run($args)
	{
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

//				$res = Yii::app()->CURL->run($url.'?'.$query,FALSE,$data);

			}

			var_dump($res);exit;

		}

	}

}