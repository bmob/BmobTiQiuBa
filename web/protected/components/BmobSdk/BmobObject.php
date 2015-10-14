<?php

include_once 'BmobRestClient.php';

/**
 * BmobObject object对象类
 * @author newjueqi
 * @authort 2014.03.28
 * @license http://www.gnu.org/copyleft/lesser.html Distributed under the Lesser General Public License (LGPL)
 */
class BmobObject extends BmobRestClient
{
	
	public $_includes = array();
	private $_className = '';

	public function __construct($class = '') 
	{
		if($class != ''){
			$this->_className = $class;
		}
		else{
			$this->throwError('创建对象时请包含对象id');
		}
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
	
	/**
	 * 添加对象
	 * @param  array $data 对象的属性数组
	 * 
	 */
	public function create($data = array()) 
	{
		//添加对象的属性
		$this->setData($data);
		
		if(count($this->data) > 0 && $this->_className != ''){
			$sendRequest = $this->sendRequest(array(
				'method' => 'POST',
				'sendRequestUrl' => 'classes/'.$this->_className,
				'data' => $this->data,
			));
			return $sendRequest;
		}else {
			$this->throwError('创建对象时请添加对象数据或指定对象id');
		}	
		
	}

	/**
	 * @desc 批量添加数据，最多50条
	 * @param  array $data 对象的属性数组
	 */
	public function createBatch($data = array())
	{
		//添加对象的属性
		$this->setData($data);

		if(count($this->data) > 0 && $this->_className != ''){

			$sendRequest = $this->sendRequest(array(
				'method' => 'POST',
				'sendRequestUrl' => 'batch',
				'data' => $this->data,
			));
			return $sendRequest;

		}else {
			$this->throwError('创建对象时请添加对象数据或指定对象id');
		}

	}

	/**
	 * 获取对象
	 * @param string $id 对象id, 当为空时表示获取所有对象
	 * @param array $condition，查询条件
	 */
	public function get($id="", $condition = array())
	{
		if ($this->_className != '') {
			if ($id) {
				$sendRequest = $this->sendRequest(array(
					'method' => 'GET',
					'sendRequestUrl' => 'classes/'.$this->_className.'/'.$id,
					'condition' => $condition,
				));
			} else {
				$sendRequest = $this->sendRequest(array(
					'method' => 'GET',
					'sendRequestUrl' => 'classes/'.$this->_className,
					'condition' => $condition,
				));
			}			
			
			return $sendRequest;
		}else {
			$this->throwError('获取对象时请指定对象id');
		}	
	}
	

	/**
	 * 更新对象的属性
	 * @param string $id 对象id
	 * @param  array $data 对象的属性数组
	 */	
	public function update($id, $data=array())
	{
		
		if($this->_className != '' || !empty($id)){
			
			if ($data) {
				//添加对象的属性
				$this->setData($data);
			} else {
				$this->throwError('请指定要更新的属性');
			}
			
			$sendRequest = $this->sendRequest(array(
				'method' => 'PUT',
				'sendRequestUrl' => 'classes/'.$this->_className.'/'.$id,
				'data' => $this->data,
			));

			return $sendRequest;
			
		}else {
			$this->throwError('修改对象时请指定对象id');
		}	
	}
	
	/**
	 * 删除对象
	 * @param string $id 对象id
	 */		
	public function delete($id)
	{
		if($this->_className != '' || !empty($id)){
			$sendRequest = $this->sendRequest(array(
				'method' => 'DELETE',
				'sendRequestUrl' => 'classes/'.$this->_className.'/'.$id
			));

			return $sendRequest;
		} else {
			$this->throwError('删除对象时请指定对象id');
		}			
	}	

	/**
	 * 任何数字字段进行原子增加或减少的功能
	 * @param string $id 对象id
	 * @param string $field 需要修改的数字字段
	 * @param int $amount 不加负号表示增加, 加负号表示减少
	 */
	public function increment($id, $field, $amount)
	{
		
		if($this->_className != '' || !empty($id)){
			
			$this->data[$field] = $this->dataType('increment', $amount);
			
			$sendRequest = $this->sendRequest(array(
				'method' => 'PUT',
				'sendRequestUrl' => 'classes/'.$this->_className.'/'.$id,
				'data' => $this->data,
			));

			return $sendRequest;
			
		}else {
			$this->throwError('修改对象时请指定对象id');
		}	
		
	}
	

}

?>