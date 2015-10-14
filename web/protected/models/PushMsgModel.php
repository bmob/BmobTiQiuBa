<?php
class PushMsgModel extends BaseModel
{

	public $name;
	public $bmobPush;

	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("PushMsg");
		return $this->bmobObj;
	}

	/**
	 * Declares the validation rules.
	 * The rules state that username and password are required,
	 * and password needs to be authenticated.
	 */
	public function rules()
	{
		return array(
			// username and password are required
		);
	}

	/**
	 * Declares attribute labels.
	 */
	public function attributeLabels()
	{
		return array(
		);
	}

	/**
	 * @desc 推送消息给某个ios设备
	 */
	public function createIosPush($deviceToken,$pushMsg){

		$data = array(
			"where" => array(
				"deviceType" => "ios",
				"deviceToken" => $deviceToken
			),
			"data" => array(
				"alert" =>  $pushMsg
			)
		);

		$this->bmobPush->push($data);

	}

	/**
	 * @desc 推送消息给某个android设备
	 * @param $installationId
	 * @param $pushMsg
	 */
	public function createAndroidPush($installationId,$pushMsg){

		$data = array(
			"where" => array(
				"deviceType" => "android",
				"installationId" => $installationId
			),
			"data" => array(
				"alert" =>  $pushMsg
			)
		);

		$this->bmobPush->push($data);

	}

	/**
	 * @desc 添加消息到消息表
	 * @param $arr
	 * @return mixed
	 */
	public function addPushMsg($arr){

		return $this->bmobObj->create($arr);

	}

	/**
	 * @desc 批量生成推送信息
	 * @param $saveBatchArr
	 * @return bool|mixed
	 */
	public function saveBatch($saveBatchArr){

		$saveDataArr = array();
		$saveArrSend = array();
		foreach($saveBatchArr as $arr){
			$arrSend = array();
			$arrSend['method'] = "POST";
			$arrSend['path'] = "/1/classes/PushMsg";
			$arrSend['body'] = $arr;
			array_push($saveArrSend,$arrSend);
		}

		$batchArr = array(
			'requests' => $saveArrSend
		);

//		var_dump($batchArr);exit;
		return $this->bmobObj->createBatch($batchArr); //添加对象
	}


}