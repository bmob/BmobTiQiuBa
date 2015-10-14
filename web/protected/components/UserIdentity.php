<?php

/**
 * UserIdentity represents the data needed to identity a user.
 * It contains the authentication method that checks if the provided
 * data can identity the user.
 */
class UserIdentity extends CUserIdentity
{
	/**
	 * Authenticates a user.
	 * The example implementation makes sure if the username and password
	 * are both 'demo'.
	 * In practical applications, this should be changed to authenticate
	 * against some persistent user identity storage (e.g. database).
	 * @return boolean whether authentication succeeds.
	 */
	public function authenticate()
	{
		try {
			$bmobObj = new BmobUser();
			$users=$bmobObj->login($this->username,$this->password);

			if($users->username !== $this->username){
				$this->errorCode=self::ERROR_USERNAME_INVALID;
			}
			else {
				if(!isset($users->nickname) || empty($users->nickname)){
					$users->nickname = "匿名";
				}
				$this->setState("nickname", $users->nickname);
				$this->setState('oid',$users->objectId);
				$this->errorCode = self::ERROR_NONE;
			}
		} catch (Exception $e) {
			$this->errorCode = self::ERROR_PASSWORD_INVALID;
		}



		return !$this->errorCode;
	}
}