<?php
include_once 'BmobRestClient.php';

/**
* BmobPushMsg Bmob推送消息类
* @author karvin
* @authort 2014.10.13
* @license http://www.gnu.org/copyleft/lesser.html Distributed under the Lesser General Public License (LGPL)
*/
class BmobPushMsg extends BmobRestClient
{

	public function __construct($class = '')
	{
		parent::__construct();
	}

	/**
	 * 设置对象的属性
	 * @param array $data
	 */
	public function setData($data = array())
	{

		//每次使用前先清空对象属性数组
		$this->data = array();
		if ($data) {
			foreach ($data as $name=>$value) {
				if($name != '_className'){
					$this->data[$name] = $value;
				}
			}
		}

	}

	public function push($data = array()){

		//添加对象的属性
		$this->setData($data);

		if(count($this->data) > 0){
			$sendRequest = $this->sendRequest(array(
				'method' => 'POST',
				'sendRequestUrl' => 'push',
				'data' => $this->data,
			));
			return $sendRequest;
		}else {
			$this->throwError('发送消息时请添加对象数据！');
		}

	}


}
	