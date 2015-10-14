<?php
class CommentModel extends BaseModel
{
	public $name;
	public $bmobObj;

	/**
	 * Declares the validation rules.
	 * The rules state that username and password are required,
	 * and password needs to be authenticated.
	 */
	public function rules()
	{
		return array(
			// username and password are required
			array('name', 'required'),

		);
	}

	/**
	 * Declares attribute labels.
	 */
	public function attributeLabels()
	{
		return array(
			'name'=>'名称',
		);
	}


	public function __construct(){
		parent::__construct();
		$this->bmobObj = new BmobObject("Comment");
		return $this->bmobObj;
	}


	/**
	 * @desc 查找某球员在某场比赛的评分记录
	 * @param $accept_comm
	 * @param $competition
	 * @return mixed
	 */
	public function findPlayerComment($accept_comm,$competition){
		$res = $this->bmobObj->get("",array('where={"accept_comm":"'.$accept_comm.'","competition":"'.$competition.'"}','include=accept_comm,komm'));
		return $res->results;
	}


}


