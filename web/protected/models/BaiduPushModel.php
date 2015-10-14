<?php
include_once Yii::app()->getBasePath() . '/components/Baidu-Push-SDK-Php/Channel.class.php';

class BaiduPushModel extends BaseModel
{
    public $apiKey;
	public $secretKey;
	public $channel;
	
	public function __construct(){
		parent::__construct();
		$this->apiKey= Yii::app()->params['baiduPushApiKey'];
		$this->secretKey= Yii::app()->params['baiduPushSecretKey'];
		$this->channel= new Channel ( $this->apiKey, $this->secretKey ) ;
	}

	/**
	 * @desc 百度云推送
	 * @param $users 用户的对象数组
	 * @param $title	推送的标题
	 * @param $msg	推送的内容
	 * @param $type	详细看文档
	 * @param $subType	详细看文档
	 * @param $msg_type　推送的类型:0：消息（透传）1：通知
	 * @param $options
	 * @return bool|mixed
	 */
	public function push($users, $title, $msg, $type, $subType, $optional,  $msg_type=1){
		
		$pushMsgModel = new PushMsgModel();
		
		if(!is_array($users)){
			$users=array($users);
		}
		
		if( count($users)>0 ){
			
			$masterId = CommonFunction::getUserId();
			
			$content=$msg;
			$saveBatchArr = array();

			
			//保存推送消息到PushMsg表
			foreach($users as $user){

				if(isset($user->username) && !empty($user->username)){

					$extra = array(
						"belongId" => $user->username,
						"title" => $title,
						"type" => $type,
						"time" => time(),
						"targetId" => $this->getTargetId($subType, $optional),
						"subtype" => $subType
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

				}

			}

			try{
				$results = $pushMsgModel->saveBatch($saveBatchArr);
			}catch(Exception $e){
				return $e->getMessage();
			}
			
			
			//发送百度推送
			for ($i = 0; $i < count($users); $i++) {
				$user=$users[$i];
				$result=$results[$i];
				if( !property_exists($user, 'pushUserId') ){
					continue;
				}
				if( $user->pushUserId=="" ){
					continue;
				}
				$push_type = 1; //推送单播消息
				$optional[Channel::USER_ID] = $user->pushUserId; //如果推送单播消息，需要指定user
				
				$message=array();
				if(  $user->deviceType=="ios" ){
					//指定发到ios设备
					$optional[Channel::DEVICE_TYPE] = 4;
					
					//apns证书状态
					$optional[Channel::DEPLOY_STATUS] = Yii::app()->params['apnDeployStatus'] ;
			
					$message['aps']['alert']=$msg;
					$message['aps']['sound']="";
					$message['aps']['badge']=0;
					
					$message['objectId']=$result->success->objectId;
					$message['belongId'] = $user->username;
					$message['targetId'] = $this->getTargetId($subType, $optional);
					$message['title']=$title;
					$message['time'] =  time();
					$message['type'] = $type;					
					$message['subtype'] =  $subType;
					$message['flag'] = "notice";		
										
				}else{
					//android
					$optional[Channel::DEVICE_TYPE] = 3;
					
					$message['title']=$title;
					$message['description']=$msg;
					
					$message['custom_content']['objectId']=$result->success->objectId;
					$message['custom_content']['belongId'] = $user->username;
					$message['custom_content']['targetId'] = $this->getTargetId($subType, $optional);
					$message['custom_content']['title']=$title;
					$message['custom_content']['time'] =  time();
					$message['custom_content']['type'] = $type;					
					$message['custom_content']['subtype'] =  $subType;
					$message['custom_content']['flag'] = "notice";	
					
				}
				
				$optional[Channel::MESSAGE_TYPE] = $msg_type;
				$message_key = md5(json_encode($message));
				
			    $ret = $this->channel->pushMessage ( $push_type, json_encode($message), $message_key, $optional ) ;
			    
//			    echo "send pushId:".$user->pushUserId."<br/>";
			    
				//检查返回值
			    if ( false === $ret )
			    {
			        echo ( 'baiduPush_WRONG, ' . __FUNCTION__ . ' ERROR!!!!<br/>' );
			        echo ( 'baiduPush_ERROR NUMBER: ' . $this->channel->errno ( ) . '<br/>' );
			        echo ( 'baiduPush_ERROR MESSAGE: ' . $this->channel->errmsg ( ) . '<br/>' );
			        echo ( 'baiduPush_REQUEST ID: ' . $this->channel->getRequestId ( ) . '<br/>' );
			         echo (  '<br/>' );
			    }
   
			}
			
			
		}
		
//		Helper::flash('error', "你无权限编辑联赛信息（请确认你至少有一个联赛的管理权限）！", '/site/');
	}
    
    public function getTargetId( $subType, $options ){
    	if( $subType== 20 || $subType== 21 ) {  //发布赛程和更新数据，返回联赛id
    		return $options['leagueId'];
    	}elseif( $subType== 12 ) { //邀请球队加入联赛
    		return $options['targetId'];
    	}
    	return "";
    }
	
    /**
     * 给联赛的所有人发送消息
     */
    public function sendMessageForAllLeague(  $type, $subType,$leagueId, $message) {
    			//更新赛程发送推送
		$teamModel = new TeamModel();
		$leagueTeams = $teamModel->findMembers($leagueId);
		
		$leagueModel = new LeagueModel();
		$res = $leagueModel->get($leagueId);
		
		if(empty($res)){
			throw new CHttpException(500, '获取联赛信息失败');
		}
		$leagueName = $res->name;
		
		
		$this->push($leagueTeams,$leagueName,$message, $type, $subType, array("leagueId"=>$leagueId));		
    }

    /**
     * 给邀请球赛的队长发送邀请推送
     * @param unknown_type $leagueId 联赛的id
     * @param unknown_type $teamId		球队的id
     * @param unknown_type $captain　队长的object
     */
    public function sendInviteMessageForTeamCaptain($leagueId, $teamId, $captain){
    	
    	$targetId=$leagueId."&".$teamId;
		$leagueModel = new LeagueModel();
		$res = $leagueModel->get($leagueId);
		
		if(empty($res)){
			throw new CHttpException(500, '获取联赛信息失败');
		}

		$leagueName = $res->name;    	
		$this->push($captain,$leagueName,"你的球队已被邀请参加联赛", 4, 12, array("targetId"=>$targetId));		
    	
    }
    
}
