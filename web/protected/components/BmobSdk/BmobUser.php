<?php

include_once 'BmobRestClient.php';

/**
 * BmobUser User对象类
 * @author newjueqi
 * @authort 2014.03.28
 * @license http://www.gnu.org/copyleft/lesser.html Distributed under the Lesser General Public License (LGPL)
 */
class BmobUser extends BmobRestClient{

	public function __construct($class = '')
	{
		parent::__construct();
	}
	
	/**
	 * 用户注册, 其中username和password为必填字段
	 * @param array $data 需要传入的参数, 其中username和password为必填参数
	 */	
	public function register($data = array())
	{

		if ( isset($data['username']) && isset($data['password']) 
		&& $data['username'] != '' && $data['password'] != '') {
			$request = $this->sendRequest(array(
				'method' => 'POST',
	    		'sendRequestUrl' => 'users',
				'data' => $data
			));
	    	return $request;
			
		} else {
			$this->throwError('用户名和密码不能为空');
		}
	}
	
	/**
	 * 用户登录, 其中username和password为必填字段
	 * @param string $username 用户名, 必填
	 * @param string $password 密码, 必填
	 */		
	public function login($username, $password)
	{
		if (!empty($username) || !empty($password)) {
			$request = $this->sendRequest(array(
				'method' => 'GET',
	    		'sendRequestUrl' => 'login',
		    	'data' => array(
		    		'username' => $username,
		    		'password' => $password
		    	)
			));
	    	return $request;			
		} else {
			$this->throwError('用户名和密码不能为空');
		}
	
	}

	/**
	 * 获取用户的信息
	 * @param string $userId 用户id, 必填
	 */			
	public function get($userId = 0)
	{
		if ($userId) {
			
			//获取某个用户的信息
			$request = $this->sendRequest(array(
				'method' => 'GET',
	    		'sendRequestUrl' => 'users/'.$userId,
			));
	    	return $request;			
		} else {
			//获取所有用户的信息
			$request = $this->sendRequest(array(
				'method' => 'GET',
	    		'sendRequestUrl' => 'users',
			));
	    	return $request;	
		}
		
	}

	/**
	 * 获取用户的信息
	 * @param string $userId 用户id, 必填
	 */
	public function getByCondition($condition)
	{

		//获取所有用户的信息
		$request = $this->sendRequest(array(
			'method' => 'GET',
			'sendRequestUrl' => 'users',
			'condition' => $condition
		));
		return $request;

	}


	/**
	 * 更新用户的信息
	 * @param string $userId 用户id, 必填
	 * @param string $sessionToken 在用户登录或注册后获取, 必填
	 * @param array $data 需要更新的用户属性
	 */		
	public function update($userId, $sessionToken, $data = array())
	{
		if(!empty($userId) || !empty($sessionToken)){
			
			if ($data) {
				$request = $this->sendRequest(array(
					'method' => 'PUT',
					'sendRequestUrl' => 'users/'.$userId,
		    		'sessionToken' => $sessionToken,
					'data' => $data
				));
			} else {
				$this->throwError('请输入需要更新的属性');
			}
			
	    	return $request;			
		} else {
			$this->throwError('用户id和sessionToken不能为空');
		}
		
	}

	/**
	 * 请求重设密码,前提是用户将email与他们的账户关联起来
	 * @param string $email
	 */
	public function requestPasswordReset($email)
	{
		if (!empty($email)) {
			$request = $this->sendRequest(array(
			'method' => 'POST',
			'sendRequestUrl' => 'requestPasswordReset',
			'data' => array("email"=>$email)
			));

			return $request;
		} else {
			$this->throwError('email is required for the requestPasswordReset method');
		}

	}		
	
	/**
	 * 删除用户
	 * @param string $userId
	 * @param string $sessionToken
	 */
	public function delete($userId, $sessionToken)
	{
		if(!empty($userId) || !empty($sessionToken)) {
			$request = $this->sendRequest(array(
				'method' => 'DELETE',
				'sendRequestUrl' => 'users/'.$userId,
	    		'sessionToken' => $sessionToken
			));
			
	    	return $request;			
		} else {
			$this->throwError('用户id和sessionToken不能为空');
		}
		
	}

	

	
	
	
	

}

?>