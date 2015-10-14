<?php

class CommonFunction{


	/**
	 * @desc 对象转数组
	 * @param $obj
	 * @return array
	 */
	public static function ob2ar($obj) {
		if(is_object($obj)) {
			$obj = (array)$obj;
			$obj = self::ob2ar($obj);
		} elseif(is_array($obj)) {
			foreach($obj as $key => $value) {
				$obj[$key] = self::ob2ar($value);
			}
		}
		return $obj;
	}

	/**
	 * @desc ajax 返回值
	 */
	public static function ajaxResult($code=1000, $msg='成功', $data=null, $return=false){
		$r = array(
			'status' => array('code' => $code, 'msg' => $msg)
		);
		if($data){
			$r['data'] = $data;
		}

		if ($return) {
			return json_encode($r);
		}
		else {
			echo json_encode($r);
			Yii::app()->end();
		}
	}

	/**
	 * @desc 赛事属性转换
	 */
	public static function code2GameFormat($code){
		$gameFormat = '友谊赛';
		switch($code){
			case "1":
				$gameFormat = '小组赛';
				break;
			case  "2":
				$gameFormat = '淘汰赛';
				break;
			case  "3":
				$gameFormat = '友谊赛';
				break;
			default:
				$gameFormat = '友谊赛';
		}

		return $gameFormat;
	}


	/**
	 * @desc 发送手机短信
	 */
	public static function sendMobileMsg($url,$data){

		$header = "Content-type: text/xml";//定义content-type为xml

		if(is_array($data)){
			$data = http_build_query($data);
		}

		$ch = curl_init(); //初始化curl
		curl_setopt($ch, CURLOPT_URL, $url);//设置链接
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);//设置是否返回信息
		curl_setopt($ch, CURLOPT_POST, 1);//设置为POST方式
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
		curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//POST数据
		$response = curl_exec($ch);//接收返回信息
		if(curl_errno($ch)){//出错则显示错误信息
			print curl_error($ch);
		}
		curl_close($ch); //关闭curl链接
		return $response;//显示返回信息

	}

	/**
	 * @desc 获取用户id
	 */
	public static function getUserId(){
		isset(Yii::app()->user->oid) ? $masterId = Yii::app()->user->oid : $masterId = '';
		return $masterId;
	}

	//check a email address
	public static function checkEmail($value)
	{
		return (bool)preg_match('/^[a-z0-9._%+-]+@(?:[a-z0-9-]+.)+[a-z]{2,4}$/i', $value);
	}

	//check a mobile number
	public static function checkMobile($value)
	{
		return (bool)preg_match('/^0?(13[0-9]|15[0-9]|17[678]|18[0-9]|14[57])[0-9]{8}$/i', $value);
	}

	/**
	 * @desc 判断该联赛是否已分组
	 * @return bool
	 */
	public static function isGrouped(){
		$masterId = self::getUserId();
		$leagueModel = new LeagueModel();
		$res = $leagueModel->findByMaster($masterId,1);
		if(isset($res[0]->grouped) && $res[0]->grouped == true){
			return true;
		}else{
			return false;
		}
	}

	/**
	 * @desc 推送消息到应用
	 */
	public static function pushAppMsg($uid,$pushMsg){

		//暂时不用这个推送
		return;
		
		$device = new InstallationModel();
		$msg = $device->findByUid($uid);
		if(isset($msg[0]) && !empty($msg[0])){
			$deviceMsg = $msg[0];
			$push = new PushMsgModel();
			if(isset($deviceMsg->deviceToken) && isset($deviceMsg->deviceType) && $deviceMsg->deviceType == 'ios'){
				$push->createIosPush($deviceMsg->deviceToken,$pushMsg);
			}elseif(isset($deviceMsg->installationId) && isset($deviceMsg->deviceType) && $deviceMsg->deviceType == 'android'){
				$push->createAndroidPush($deviceMsg->installationId,$pushMsg);
			}
		}

	}

}